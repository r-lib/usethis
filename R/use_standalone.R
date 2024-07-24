#' Use a standalone file from another repo
#'
#' @description
#' A "standalone" file implements a minimum set of functionality in such a way
#' that it can be copied into another package. `use_standalone()` makes it easy
#' to get such a file into your own repo.
#'
#' It always overwrites an existing standalone file of the same name, making
#' it easy to update previously imported code.
#'
#' @section Supported fields:
#'

#' A standalone file has YAML frontmatter that provides additional information,
#' such as where the file originates from and when it was last updated. Here is
#' an example:
#'
#' ```
#' ---
#' repo: r-lib/rlang
#' file: standalone-types-check.R
#' last-updated: 2023-03-07
#' license: https://unlicense.org
#' dependencies: standalone-obj-type.R
#' imports: rlang (>= 1.1.0)
#' ---
#' ```
#'
#' Two of these fields are consulted by `use_standalone()`:
#'
#' - `dependencies`: A file or a list of files in the same repo that
#'   the standalone file depends on. These files are retrieved
#'   automatically by `use_standalone()`.
#'
#' - `imports`: A package or list of packages that the standalone file
#'    depends on. A minimal version may be specified in parentheses,
#'    e.g. `rlang (>= 1.0.0)`. These dependencies are passed to
#'    [use_package()] to ensure they are included in the `Imports:`
#'    field of the `DESCRIPTION` file.
#'
#' Note that lists are specified with standard YAML syntax, using
#' square brackets, for example: `imports: [rlang (>= 1.0.0), purrr]`.
#'
#' @inheritParams create_from_github
#' @inheritParams use_github_file
#' @param file Name of standalone file. The `standalone-` prefix and file
#'   extension are optional. If omitted, will allow you to choose from the
#'   standalone files offered by that repo.
#' @export
#' @examples
#' \dontrun{
#' use_standalone("r-lib/rlang", file = "types-check")
#' use_standalone("r-lib/rlang", file = "types-check", ref = "standalone-dep")
#' }
use_standalone <- function(repo_spec, file = NULL, ref = NULL, host = NULL) {
  check_is_project()
  maybe_name(file)
  maybe_name(host)
  maybe_name(ref)

  parsed_repo_spec <- parse_repo_url(repo_spec)
  if (!is.null(parsed_repo_spec$host)) {
    repo_spec <- parsed_repo_spec$repo_spec
    host <- parsed_repo_spec$host
  }

  if (is.null(file)) {
    file <- standalone_choose(repo_spec, ref = ref, host = host)
  } else {
    file <- as_standalone_file(file)
  }

  src_path <- path("R", file)
  dest_path <- path("R", as_standalone_dest_file(file))

  lines <- read_github_file(repo_spec, path = src_path, ref = ref, host = host)
  lines <- c(standalone_header(repo_spec, src_path, ref, host), lines)
  write_over(proj_path(dest_path), lines, overwrite = TRUE)

  dependencies <- standalone_dependencies(lines, path)

  for (dependency in dependencies$deps) {
    use_standalone(repo_spec, dependency, ref = ref, host = host)
  }

  imports <- dependencies$imports

  for (i in seq_len(nrow(imports))) {
    import <- imports[i, , drop = FALSE]

    if (is.na(import$ver)) {
      ver <- NULL
    } else {
      ver <- import$ver
    }
    ui_silence(
      use_package(import$pkg, min_version = ver)
    )
  }

  invisible()
}

standalone_choose <- function(repo_spec, ref = NULL, host = NULL, error_call = caller_env()) {
  json <- gh::gh(
    "/repos/{repo_spec}/contents/{path}",
    repo_spec = repo_spec,
    ref = ref,
    .api_url = host,
    path = "R/"
  )

  names <- map_chr(json, "name")
  names <- names[grepl("^standalone-", names)]
  choices <- gsub("^standalone-|.[Rr]$", "", names)

  if (length(choices) == 0) {
    cli::cli_abort(
      "No standalone files found in {repo_spec}.",
      call = error_call
    )
  }

  if (!is_interactive()) {
    cli::cli_abort(
      c(
        "`file` is absent, but must be supplied.",
        i = "Possible options are {.or {choices}}."
      ),
      call = error_call
    )
  }

  choice <- utils::menu(
    choices = choices,
    title = "Which standalone file do you want to use (0 to exit)?"
  )
  if (choice == 0) {
    cli::cli_abort("Selection cancelled", call = error_call)
  }

  names[[choice]]
}

as_standalone_file <- function(file) {
  if (path_ext(file) == "") {
    file <- unclass(path_ext_set(file, "R"))
  }
  if (!grepl("standalone-", file)) {
    file <- paste0("standalone-", file)
  }
  file
}

as_standalone_dest_file <- function(file) {
  gsub("standalone-", "import-standalone-", file)
}

standalone_header <- function(repo_spec, path, ref = NULL, host = NULL) {
  ref_string <- ref %||% "HEAD"
  host_string <- host %||% "https://github.com"
  source_comment <-
    glue("# Source: {host_string}/{repo_spec}/blob/{ref_string}/{path}")

  path_string <- path_ext_remove(sub("^standalone-", "", basename(path)))
  ref_string <- if (is.null(ref)) "" else glue(', ref = "{ref}"')
  host_string <- if (is.null(host) || host == "https://github.com") "" else glue(', host = "{host}"')
  code_hint <- glue('usethis::use_standalone("{repo_spec}", "{path_string}"{ref_string}{host_string})')
  generated_comment <- glue('# Generated by: {code_hint}')

  c(
    "# Standalone file: do not edit by hand",
    source_comment,
    generated_comment,
    paste0("# ", strrep("-", 72 - 2)),
    "#"
  )
}

standalone_dependencies <- function(lines, path, error_call = caller_env()) {
  dividers <- which(lines == "# ---")
  if (length(dividers) != 2) {
    cli::cli_abort(
      "Can't find yaml metadata in {.path {path}}.",
      call = error_call
    )
  }

  header <- lines[dividers[[1]]:dividers[[2]]]
  header <- gsub("^# ", "", header)

  temp <- withr::local_tempfile(lines = header)
  yaml <- rmarkdown::yaml_front_matter(temp)

  as_chr_field <- function(field) {
    if (!is.null(field) && !is.character(field)) {
      cli::cli_abort(
        "Invalid dependencies specification in {.path {path}}.",
        call = error_call
      )
    }

    field %||% character()
  }

  deps <- as_chr_field(yaml$dependencies)
  imports <- as_chr_field(yaml$imports)
  imports <- as_version_info(imports, error_call = error_call)

  if (any(stats::na.omit(imports$cmp) != ">=")) {
    cli::cli_abort(
      "Version specification must use {.code >=}.",
      call = error_call
    )
  }

  list(deps = deps, imports = imports)
}

as_version_info <- function(fields, error_call = caller_env()) {
  if (!length(fields)) {
    return(version_info_df())
  }

  if (any(grepl(",", fields))) {
    msg <- c(
      "Version field can't contain comma.",
      "i" = "Do you need to wrap in a list?"
    )
    cli::cli_abort(msg, call = error_call)
  }

  info <- lapply(fields, as_version_info_row, error_call = error_call)
  inject(rbind(!!!info))
}

as_version_info_row <- function(field, error_call = caller_env()) {
  version_regex <- "(.*) \\((.*)\\)$"
  has_ver <- grepl(version_regex, field)

  if (!has_ver) {
    return(version_info_df(field, NA, NA))
  }

  pkg <- sub(version_regex, "\\1", field)
  ver <- sub(version_regex, "\\2", field)

  ver <- strsplit(ver, " ")[[1]]

  if (!is_character(ver, n = 2) || any(is.na(ver)) || !all(nzchar(ver))) {
    cli::cli_abort(
      c(
        "Can't parse version `{field}` in `imports:` field.",
        "i" = "Example of expected version format: `rlang (>= 1.0.0)`."
      ),
      call = error_call
    )
  }

  version_info_df(pkg, ver[[1]], ver[[2]])
}

version_info_df <- function(pkg = chr(), cmp = chr(), ver = chr()) {
  df <- data.frame(
    pkg = as.character(pkg),
    cmp = as.character(cmp),
    ver = as.character(ver)
  )
  structure(df, class = c("tbl", "data.frame"))
}
