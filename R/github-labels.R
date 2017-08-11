#' Create standard github labels for labelling issues.
#'
#' This function creates new labels and changes colours (if needed).
#' It does not generally remove labels, unless you explicit ask to
#' remove GitHub's defaults.
#'
#' @param delete_default If `TRUE`, will remove default labels.
#' @inheritParams use_github_links
#' @export
#' @md
use_github_labels <- function(delete_default = FALSE,
                              auth_token = NULL,
                              host = NULL,
                              base_path = ".") {

  check_uses_github(base_path)

  info <- gh::gh_tree_remote(base_path)
  gh <- function(endpoint, ...) {
    gh::gh(endpoint,
      ...,
      owner = info$username,
      repo = info$repo,
      .token = auth_token,
      .api_url = host
    )
  }

  labels <- gh("GET /repos/:owner/:repo/labels")

  # Add missing labels
  cur_labels <- vapply(labels, "[[", "name", FUN.VALUE = character(1))
  new_labels <- setdiff(names(gh_labels), cur_labels)
  if (length(new_labels) > 0) {
    done(paste0("Adding missing labels: ", paste0(value(new_labels), collapse = ", ")))

    for (label in new_labels) {
      gh(
        "POST /repos/:owner/:repo/labels",
        name = label,
        color = gh_labels[[label]]
      )
    }
  }

  # Correct bad colours
  cur_cols <- vapply(labels, "[[", "color", FUN.VALUE = character(1))
  tru_cols <- gh_labels[cur_labels]
  col_labels <- cur_labels[!is.na(tru_cols) & tru_cols != cur_cols]

  if (length(col_labels) > 1) {
    done(paste0("Setting label colours: ", paste0(value(col_labels), collapse = ", ")))

    for (label in col_labels) {
      gh(
        "PATCH /repos/:owner/:repo/labels/:name",
        name = label,
        color = gh_labels[[label]]
      )
    }
  }

  if (delete_default) {
    default <- vapply(labels, "[[", "default", FUN.VALUE = logical(1))
    def_labels <- setdiff(cur_labels[default], names(gh_labels))

    if (length(def_labels) > 0) {
      done(paste0("Removing default labels: ", paste0(value(def_labels), collapse = ", ")))

      for (label in def_labels) {
        gh("DELETE /repos/:owner/:repo/labels/:name", name = label)
      }
    }
  }
}

gh_labels <- c(
  "bug" =     "e02a2a",
  "feature" = "009800",
  "reprex" =  "eb6420",
  "wip" =     "eb6420",
  "docs" =    "0052cc"
)
