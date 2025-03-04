#' Configure a project to use Air
#'
#' @description
#' [Air](https://posit-dev.github.io/air) is an extremely fast R code
#' formatter. This function sets up a project to use Air. Specifically, it:
#'
#' - Creates an empty `air.toml` configuration file. If either an `air.toml` or
#'   `.air.toml` file already existed, nothing is changed. If the project is an
#'   R package, `.Rbuildignore` is updated to ignore this file.
#'
#' - Creates a `.vscode/` directory and adds recommended settings to
#'   `.vscode/settings.json` and `.vscode/extensions.json`. These settings are
#'   used by the Air extension installed through either VS Code or Positron, see
#'   the Installation section for more details. Specifically it:
#'
#'   - Sets `editor.formatOnSave = true` for R files to enable formatting on
#'     every save.
#'
#'   - Sets `editor.defaultFormatter` to Air for R files to ensure that Air is
#'     always selected as the formatter for this project.
#'
#'   - Sets the Air extension as a "recommended" extension for this project,
#'     which triggers a notification for contributors coming to this project
#'     that don't yet have the Air extension installed.
#'
#'   If the project is an R package, `.Rbuildignore` is updated to ignore the
#'   `.vscode/` directory.
#'
#'   If you'd like to opt out of VS Code / Positron specific setup, set `vscode
#'   = FALSE`, but remember that even if you work in RStudio, other contributors
#'   may prefer another editor.
#'
#' Note that `use_air()` does not actually invoke Air, it just configures your
#' project with the recommended settings. Consult the [editors
#' guide](https://posit-dev.github.io/air/editors.html) to learn how to invoke
#' Air in your preferred editor.
#'
#' ## Installation
#'
#' Note that this setup does not install an Air binary, so there is an
#' additional manual step you must take before using Air for the first time:
#'
#' - For RStudio, follow the [installation
#'   guide](https://posit-dev.github.io/air/editor-rstudio.html).
#'
#' - For Positron, install the [OpenVSX
#'   Extension](https://open-vsx.org/extension/posit/air-vscode).
#'
#' - For VS Code, install the [VS Code
#'   Extension](https://marketplace.visualstudio.com/items?itemName=Posit.air-vscode).
#'
#' - For other editors, check to [see if that editor is
#'   supported](https://posit-dev.github.io/air/editors.html) by Air.
#'
#' @param vscode Either:
#'   - `TRUE` to set up VS Code and Positron specific Air settings. This is the
#'     default.
#'   - `FALSE` to opt out of those settings.
#'
#' @export
#' @examples
#' \dontrun{
#' # Prepare an R package or project to use Air
#' use_air()
#' }
use_air <- function(vscode = TRUE) {
  check_bool(vscode)

  ignore <- is_package()

  # Create empty `air.toml` if it doesn't exist
  create_air_toml(ignore = ignore)

  if (vscode) {
    create_vscode_directory(ignore = ignore)

    # Create project level `settings.json` if it doesn't exist,
    # and write in Air specific formatter settings
    path <- create_vscode_json_file("settings.json")
    write_air_vscode_settings_json(path)

    # Create project level `extensions.json` if it doesn't exist,
    # and write in Air as a recommended extension for this project
    path <- create_vscode_json_file("extensions.json")
    write_air_vscode_extensions_json(path)
  }

  ui_bullets(c(
    "_" = "Read the {.href [Air editors guide](https://posit-dev.github.io/air/editors.html)} to learn how to invoke Air in your preferred editor."
  ))

  invisible(TRUE)
}

#' Creates an empty `air.toml`
#'
#' If either `air.toml` or `.air.toml` already exist, no new file is created.
#'
#' @keywords internal
#' @noRd
create_air_toml <- function(ignore = FALSE) {
  path <- path_first_existing(proj_path(c("air.toml", ".air.toml")))

  if (is.null(path)) {
    # No pre-existing configuration file, create it
    path <- proj_path("air.toml")
    file_create(path)
    ui_bullets(c("v" = "Creating {.path {pth(path)}}."))
  }

  if (ignore) {
    use_build_ignore(air_toml_regex(), escape = FALSE)
  }

  invisible(path)
}

air_toml_regex <- function() {
  # Pre-escaped regex allowing both `air.toml` and `.air.toml`
  "^[\\.]?air\\.toml$"
}

create_vscode_json_file <- function(name) {
  arg_match(name, values = c("settings.json", "extensions.json"))

  path <- proj_path(".vscode", name)

  if (!file_exists(path)) {
    file_create(path)
    ui_bullets(c("v" = "Creating {.path {pth(path)}}."))
  }

  # Tools like jsonlite fail to read empty json files,
  # so if we've just created it, write in `{}`. The easiest
  # way to do that is to write an empty named list.
  if (is_file_empty(path)) {
    jsonlite::write_json(set_names(list()), path = path, pretty = TRUE)
  }

  invisible(path)
}

write_air_vscode_settings_json <- function(path) {
  settings <- jsonlite::read_json(path)
  settings_r <- settings[["[r]"]]

  if (is.null(settings_r)) {
    # Mock it
    settings_r <- set_names(list())
  }

  # Set these regardless of their previous values. Assume that calling
  # `use_air()` is an explicit request to opt in to these settings.
  settings_r[["editor.formatOnSave"]] <- TRUE
  settings_r[["editor.defaultFormatter"]] <- "Posit.air-vscode"

  settings[["[r]"]] <- settings_r

  write_vscode_json(x = settings, path = path)
}

write_air_vscode_extensions_json <- function(path) {
  settings <- jsonlite::read_json(path)
  settings_recommendations <- settings[["recommendations"]]

  if (is.null(settings_recommendations)) {
    # Mock it
    settings_recommendations <- list()
  }

  already_recommended <- any(map_lgl(
    settings_recommendations,
    function(recommendation) {
      identical(recommendation, "Posit.air-vscode")
    }
  ))

  if (!already_recommended) {
    settings_recommendations <- c(
      settings_recommendations,
      list("Posit.air-vscode")
    )
  }

  settings[["recommendations"]] <- settings_recommendations

  write_vscode_json(x = settings, path = path)
}

#' Write JSON to a VS Code settings file
#'
#' @description
#' Small shim to use in place of [jsonlite::write_json()] when writing to
#' `.vscode/settings.json` or `.vscode/extensions.json`.
#'
#' Notably:
#'
#' - 4 space indent, as that is the standard indent level for these files
#'
#' - Auto unbox, because we want `TRUE` to show up as `true` not `[true]`.
#'
#' - Trims newlines from the right hand side after the ending `}`. Unfortunately
#'   setting `pretty = 4L` causes the special libyajl formatter to kick in, and
#'   that always adds a trailing newline after every `]` or `}`, even the last
#'   one, which we don't want.
#'
#' @keywords internal
#' @noRd
write_vscode_json <- function(x, path) {
  json <- jsonlite::toJSON(x, pretty = 4L, auto_unbox = TRUE)
  json <- base::trimws(json, which = "right")
  base::writeLines(json, path, useBytes = TRUE)
}
