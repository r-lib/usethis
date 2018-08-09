#' Manage GitHub issue labels
#'
#' @description `use_github_labels()` creates new labels and/or changes label
#'   colours. It does not generally remove labels. But if you set
#'   `delete_default = TRUE`, it will delete labels that are (1) flagged by the
#'   API as being [GitHub default
#'   labels](https://help.github.com/articles/about-labels/#using-default-labels)
#'   and (2) not present in the labels you provide via `labels`.
#'
#'   `tidy_labels()` returns the labels and colours commonly used by tidyverse
#'   packages.
#'
#' @section Label usage:
#' Labels are used as part of the issue-triage process, designed to minimise the
#' time spent re-reading issues. The absence of a label indicates that an issue
#' is new, and has yet to be triaged.
#' * `reprex` indicates that an issue does not have a minimal reproducible
#'   example, and that a reply has been sent requesting one from the user.
#' * `bug` type, indicates an unexpected problem or unintended behavior.
#' * `feature` type, indicates a feature request or enhancement.
#' * `docs` type, indicates an issue with the documentation.
#' * `performance` indicates a non-breaking area related to performance.
#' * `wip` indicates that someone else is working on it or has promised to.
#' * `good first issue` indicates a good issue for first-time contributors.
#' * `help wanted` indicates that a maintainer wants help on an issue.
#'
#' @param labels Named character vector of labels. The names are the label text,
#'   such as "bug", and the values are the label colours in hexadecimal, such as
#'   "e02a2a". First, labels that don't yet exist are created, then label
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

  gh <- function(endpoint, ...) {
    gh::gh(
      endpoint,
      ...,
      owner = github_owner(),
      repo = github_repo(),
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
    done("Adding missing labels: {collapse(value(new_labels))}")

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
    done("Setting label colours: {collapse(value(col_labels))}")

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
      done("Removing labels: {collapse(value(def_labels))}")

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
                 "bug" = "e02a2a",
             "feature" = "009800",
              "reprex" = "eb6420",
                 "wip" = "eb6420",
                "docs" = "0052cc",
         "performance" = "fbca04",
    "good first issue" = "484fb5",
         "help wanted" = "008672"
  )
}
