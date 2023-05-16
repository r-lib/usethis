#' Open file for editing
#'
#' Opens a file for editing in RStudio, if that is the active environment, or
#' via [utils::file.edit()] otherwise. If the file does not exist, it is
#' created. If the parent directory does not exist, it is also created.
#' `edit_template()` specifically opens templates in `inst/templates` for use
#' with [use_template()].
#'
#' @details
#' If in RStudio, `edit_file()` has the ability to open a file at line number, or column number
#' using the pattern `file.R:xx:yy`, where `xx` is the line number, and `yy` is the column number.
#'
#' @param path Path to target file.
#' @param open Whether to open the file for interactive editing.
#' @return Target path, invisibly.
#' @export
#' @keywords internal
#'
#' @examples
#' \dontrun{
#' edit_file("DESCRIPTION")
#' edit_file("~/.gitconfig")
#' edit_file("DESCRIPTION#23")
#' edit_file("DESCRIPTION:22:8")
#' }
edit_file <- function(path, open = rlang::is_interactive()) {
  open <- open && is_interactive()
  line_numbers_details <- get_line_number(path)

  path <- user_path_prep(line_numbers_details$path)
  create_directory(path_dir(path))
  file_create(path)

  if (!open) {
    ui_todo("Edit {ui_path(path)}")
    return(invisible(path))
  }

  ui_todo("Modify {ui_path(path)}")
  if (rstudio_available() && rstudioapi::hasFun("navigateToFile")) {
    rstudioapi::navigateToFile(
      path,
      line = line_numbers_details$line,
      column = line_numbers_details$column
    )
  } else {
    utils::file.edit(path)
  }
  invisible(path)
}

# Returns a list of 3, path, line, and column
get_line_number <- function(path) {
  line_num_regex <- "[\\:\\#]\\d+\\:?\\d*$"

  has_line_numbers <- re_match(path, pattern = line_num_regex)
  if (is.na(has_line_numbers$.match)) {
    return(list(path = path, line = -1L, column = -1L))
  }
  path <- gsub(pattern = has_line_numbers$.match, replacement = "", x = has_line_numbers$.text)
  line_numbers <- unlist(strsplit(x = has_line_numbers$.match, split = "\\:|\\#"))
  line_numbers <- as.integer(line_numbers)

  # What to do if both line and number is specified
  if (has_length(line_numbers, 3)) {
    return(list(path = path, line = line_numbers[2], column = line_numbers[3]))
  }
  # The default if only the line is specified
  list(path = path, line = line_numbers[2], column = -1L)
}

#' @param template The target template file. If not specified, existing template
#'  files are offered for interactive selection.
#' @export
#' @rdname edit_file
edit_template <- function(template = NULL, open = rlang::is_interactive()) {
  check_is_package("edit_template()")

  if (is.null(template)) {
    ui_info("No template specified... checking {ui_path('inst/templates')}")
    template <- choose_template()
  }

  if (is_empty(template)) {
    return(invisible())
  }

  path <- proj_path("inst", "templates", template)
  edit_file(path, open)
}

choose_template <- function() {
  if (!is_interactive()) {
    return(character())
  }
  templates <- path_file(dir_ls(proj_path("inst", "templates"), type = "file"))
  if (is_empty(templates)) {
    return(character())
  }

  choice <- utils::menu(
    choices = templates,
    title = "Which template do you want to edit? (0 to exit)"
  )

  templates[choice]
}

#' Open configuration files
#'
#' * `edit_r_profile()` opens `.Rprofile`
#' * `edit_r_environ()` opens `.Renviron`
#' * `edit_r_makevars()` opens `.R/Makevars`
#' * `edit_git_config()` opens `.gitconfig` or `.git/config`
#' * `edit_git_ignore()` opens global (user-level) gitignore file and ensures
#'   its path is declared in your global Git config.
#' * `edit_pkgdown_config` opens the pkgdown YAML configuration file for the
#'   current Project.
#' * `edit_rstudio_snippets()` opens RStudio's snippet config for the given type.
#' * `edit_rstudio_prefs()` opens RStudio's preference file.
#'
#' The `edit_r_*()` functions consult R's notion of user's home directory.
#' The `edit_git_*()` functions (and \pkg{usethis} in general) inherit home
#' directory behaviour from the \pkg{fs} package, which differs from R itself
#' on Windows. The \pkg{fs} default is more conventional in terms of the
#' location of user-level Git config files. See [fs::path_home()] for more
#' details.
#'
#' Files created by `edit_rstudio_snippets()` will *mask*, not supplement,
#' the built-in default snippets. If you like the built-in snippets, copy them
#' and include with your custom snippets.
#'
#' @return Path to the file, invisibly.
#'
#' @param scope Edit globally for the current __user__, or locally for the
#'   current __project__
#' @name edit
NULL

#' @export
#' @rdname edit
edit_r_profile <- function(scope = c("user", "project")) {
  path <- scoped_path_r(scope, ".Rprofile", envvar = "R_PROFILE_USER")
  edit_file(path)
  ui_todo("Restart R for changes to take effect")
  invisible(path)
}

#' @export
#' @rdname edit
edit_r_environ <- function(scope = c("user", "project")) {
  path <- scoped_path_r(scope, ".Renviron", envvar = "R_ENVIRON_USER")
  edit_file(path)
  ui_todo("Restart R for changes to take effect")
  invisible(path)
}

#' @export
#' @rdname edit
edit_r_buildignore <- function() {
  check_is_package("edit_r_buildignore()")
  edit_file(proj_path(".Rbuildignore"))
}

#' @export
#' @rdname edit
edit_r_makevars <- function(scope = c("user", "project")) {
  path <- scoped_path_r(scope, ".R", "Makevars")
  edit_file(path)
}

#' @export
#' @rdname edit
#' @param type Snippet type (case insensitive text).
edit_rstudio_snippets <- function(type = c(
                                    "r", "markdown", "c_cpp", "css",
                                    "html", "java", "javascript", "python", "sql", "stan", "tex"
                                    )) {

  type <- tolower(type)
  type <- match.arg(type)
  file <- path_ext_set(type, "snippets")

  # Snippet location changed in 1.3:
  # https://blog.rstudio.com/2020/02/18/rstudio-1-3-preview-configuration/
  new_rstudio <- !rstudioapi::isAvailable() || rstudioapi::getVersion() >= "1.3.0"
  old_path <- path_home_r(".R", "snippets", file)
  new_path <- rstudio_config_path("snippets", file)

  # Mimic RStudio behaviour: copy to new location if you edit
  if (new_rstudio && file_exists(old_path) && !file_exists(new_path)) {
    create_directory(path_dir(new_path))
    file_copy(old_path, new_path)
    ui_done("Copying snippets file to {ui_path(new_path)}")
  }

  path <- if (new_rstudio) new_path else old_path
  if (!file_exists(path)) {
    ui_done("New snippet file at {ui_path(path)}")
    ui_info(c(
      "This masks the default snippets for {ui_field(type)}.",
      "Delete this file and restart RStudio to restore the default snippets."
    ))
  }
  edit_file(path)
}

#' @export
#' @rdname edit
edit_rstudio_prefs <- function() {
  path <- rstudio_config_path("rstudio-prefs.json")

  edit_file(path)
  ui_todo("Restart RStudio for changes to take effect")
  invisible(path)
}

scoped_path_r <- function(scope = c("user", "project"), ..., envvar = NULL) {
  scope <- match.arg(scope)

  # Try environment variable in user scopes
  if (scope == "user" && !is.null(envvar)) {
    env <- Sys.getenv(envvar, unset = "")
    if (!identical(env, "")) {
      return(user_path_prep(env))
    }
  }

  root <- switch(scope,
    user = path_home_r(),
    project = proj_get()
  )
  path(root, ...)
}

# git paths ---------------------------------------------------------------
# Note that on windows R's definition of ~ is in a nonstandard place,
# so it is important to use path_home(), not path_home_r()

#' @export
#' @rdname edit
edit_git_config <- function(scope = c("user", "project")) {
  scope <- match.arg(scope)
  path <- switch(
    scope,
    user = path_home(".gitconfig"),
    project = proj_path(".git", "config")
  )
  invisible(edit_file(path))
}

#' @export
#' @rdname edit
edit_git_ignore <- function(scope = c("user", "project")) {
  scope <- match.arg(scope)
  if (scope == "user") {
    ensure_core_excludesFile()
  }
  file <- git_ignore_path(scope)

  if (scope == "user" && !file_exists(file)) {
    git_vaccinate()
  }

  invisible(edit_file(file))
}

git_ignore_path <- function(scope = c("user", "project")) {
  scope <- match.arg(scope)
  switch(
    scope,
    user = git_cfg_get("core.excludesFile", where = "global"),
    project = proj_path(".gitignore")
  )
}

# pkgdown ---------------------------------------------------------------
#' @export
#' @rdname edit
edit_pkgdown_config <- function() {
  path <- pkgdown_config_path()
  if (is.null(path)) {
    ui_oops("No pkgdown config file found in current Project.")
  } else {
    invisible(edit_file(path))
  }
}
