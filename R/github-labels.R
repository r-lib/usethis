#' Manage GitHub issue labels.
#'
#' @description `use_github_labels()` creates new labels and/or changes label
#' colours. It does not generally remove labels, unless you explicitly ask to
#' remove the default GitHub labels that are not present in the labels you
#' provide via `labels`.
#'
#' `tidy_labels()` returns the labels and colours commonly used by tidyverse
#' packages.
#'
#' @param labels Named character vector of labels. The names are the label text,
#'   such as "bug", and the values are the label colours in hexadecimal, such as
#'   "d73a4a". First, labels that don't yet exist are created, then label
#'   colours are updated.
#' @param delete_default If `TRUE`, will remove GitHub default labels that do
#'   not appear in the `labels` vector (presumably defaults that aren't relevant
#'   to your workflow).
#' @inheritParams use_github_links
#' @name use_github_labels
NULL

#' @rdname use_github_labels
#' @export
#' @examples
#' \dontrun{
#' ## typical use in, e.g., a new tidyverse project
#' use_github_labels(delete_default = TRUE)
#' }
use_github_labels <- function(labels = tidy_labels(),
                              delete_default = FALSE,
                              auth_token = NULL,
                              host = NULL) {
  check_uses_github()

  info <- gh::gh_tree_remote(proj_get())
  gh <- function(endpoint, ...) {
    gh::gh(
      endpoint,
      ...,
      owner = info$username,
      repo = info$repo,
      .token = auth_token,
      .api_url = host
    )
  }

  cur_labels <- gh("GET /repos/:owner/:repo/labels")

  # Add missing labels
  if (identical(cur_labels[[1]], "")) {
    cur_label_names <- character()
  } else {
    cur_label_names <- vapply(cur_labels, "[[", "name", FUN.VALUE = character(1))
  }
  new_labels <- setdiff(names(labels), cur_label_names)
  if (length(new_labels) > 0) {
    done("Adding missing labels: ", collapse(value(new_labels)))

    for (label in new_labels) {
      gh(
        "POST /repos/:owner/:repo/labels",
        name = label,
        color = labels[[label]]
      )
    }
  }

  # Correct bad colours
  if (identical(cur_labels[[1]], "")) {
    cur_cols <- character()
  } else {
    cur_cols <- vapply(cur_labels, "[[", "color", FUN.VALUE = character(1))
  }
  tru_cols <- labels[cur_label_names]
  col_labels <- cur_label_names[!is.na(tru_cols) & tru_cols != cur_cols]

  if (length(col_labels) > 0) {
    done("Setting label colours: ", collapse(value(col_labels)))

    for (label in col_labels) {
      gh(
        "PATCH /repos/:owner/:repo/labels/:name",
        name = label,
        color = labels[[label]]
      )
    }
  }

  if (delete_default && length(cur_labels) > 0) {
    default <- vapply(cur_labels, "[[", "default", FUN.VALUE = logical(1))
    def_labels <- setdiff(cur_label_names[default], names(labels))

    if (length(def_labels) > 0) {
      done("Removing default labels: ", collapse(value(def_labels)))

      for (label in def_labels) {
        gh("DELETE /repos/:owner/:repo/labels/:name", name = label)
      }
    }
  }
}

#' @rdname use_github_labels
#' @export
tidy_labels <- function() {
  c(
    "bug" = "d73a4a",
    "feature" = "a2eeef",
    "reprex" = "eb6420",
    "wip" = "eb6420",
    "docs" = "0052cc",
    "performance" = "fbca04",
    "good first issue" = "7057ff",
    "help wanted" = "008672"
  )
}
