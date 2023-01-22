#' Use a compatibility file from another repo
#'
#' A "compat" file implements a minimum set of standalone functionality in
#' such a way that it can be copied into another package. `use_compat()`
#' makes it easy to get such a file into your own repo.
#'
#' @inheritParams create_from_github
#' @param file Name of compat file. The `compat-` suffix and file extension
#'   are optional. If ommitted, will allow you to choose from the compat
#'   files offered by that repo.
#' @export
use_compat <- function(repo_spec, file = NULL) {
  proj_get() # force project discovery

  if (is.null(file)) {
    file <- compat_choose()
  } else {
    if (path_ext(file) == "") {
      file <- path_ext_set(file, "R")
    }
    if (!startsWith(file, "compat-")) {
      file <- paste0("compat-", file)
    }
  }

  path <- path("R", file)

  lines <- read_github_file(repo_spec, path = path)
  lines <- c(compat_prefix(repo_spec, path), lines)
  write_over(proj_path(path), lines, overwrite = TRUE)

  dependencies <- find_dependencies(lines, path)
  for (dependency in dependencies) {
    use_compat(repo_spec, dependency)
  }

  invisible()
}

compat_choose <- function(repo_spec) {
  json <- gh::gh(
    "/repos/{repo_spec}/contents/{path}",
    repo_spec = repo_spec,
    path = "R/"
  )

  names <- map_chr(json, "name")
  names <- names[grepl("^compat-", names)]
  compats <- gsub("^compat-|.[Rr]$", "", names)

  choice <- utils::menu(
    choices = compats,
    title = "Which compat file do you want to use (0 to exit)"
  )
  if (choice == 0) {
    cli::cli_abort("Selection cancelled")
  }

  names[choice]
}

compat_prefix <- function(repo_spec, path) {
  c(
    "# Compatibility file: do not edit by hand",
    glue("# Source: <https://github.com/{repo_spec}/blob/main/{path}>"),
    paste0("# ", strrep("-", 72 - 2)),
    "#"
  )
}

find_dependencies <- function(lines, path, call = caller_env()) {
  dividers <- which(lines == "# ---")
  if (length(dividers) != 2) {
    cli::cli_abort("Can't find yaml metadata in {.path {path}}", call = call)
  }

  header <- lines[dividers[[1]]:dividers[[2]]]
  header <- gsub("^# ", "", header)

  temp <- withr::local_tempfile(lines = header)
  yaml <- rmarkdown::yaml_front_matter(temp)

  deps <- yaml$dependencies
  if (!is.null(deps) && !is.character(deps)) {
    cli::cli_abort("Invalid dependencies specification in {.path {path}", call = call)
  }
  deps
}
