#' Manage GitHub issue labels
#'
#' @description
#' `use_github_labels()` can create new labels, update colours and descriptions,
#' and optionally delete GitHub's default labels (if `delete_default = TRUE`).
#' It will never delete labels that have associated issues.
#'
#' `use_tidy_labels()` calls `use_github_labels()` with tidyverse conventions
#' powered by `tidy_labels()`, `tidy_labels_rename()`, `tidy_label_colours()` and
#' `tidy_label_descriptions()`.
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
#' * `wip` indicates that someone else is working on it or has promised to.
#' * `good first issue` indicates a good issue for first-time contributors.
#' * `help wanted` indicates that a maintainer wants help on an issue.
#'
#' @param repo_spec Optional repository specification (`owner/repo`) if you
#'   don't want to target the current project.
#' @param labels A character vector giving labels to add.
#' @param rename A named vector with names giving old names and values giving
#'   new values.
#' @param colours,descriptions Named character vectors giving hexadecimal
#'   colours (like `e02a2a`) and longer descriptions. The names should match
#'   label names, and anything unmatched will be left unchanged. If you
#'   create a new label, and don't supply colours, it will be givein a random
#'   colour.
#' @param delete_default If `TRUE`, will remove GitHub default labels that do
#'   not appear in the `labels` vector, and do not have associated issues.
#'   to your workflow).
#' @inheritParams use_github_links
#' @export
#' @examples
#' \dontrun{
#' # typical use in, e.g., a new tidyverse project
#' use_github_labels(delete_default = TRUE)
#'
#' # create labels without changing colours/descriptions
#' use_github_labels(
#'   labels = c("foofy", "foofier", "foofiest"),
#'   colours = NULL,
#'   descriptions = NULL
#' )
#'
#' # change descriptions without changing names/colours
#' use_github_labels(
#'   labels = NULL,
#'   colours = NULL,
#'   descriptions = c("foofiest" = "the foofiest issue you ever saw")
#' )
#' }
use_github_labels <- function(repo_spec = github_repo_spec(),
                              labels = character(),
                              rename = character(),
                              colours = character(),
                              descriptions = character(),
                              delete_default = FALSE,
                              auth_token = github_token(),
                              host = NULL) {
  check_uses_github()
  check_github_token(auth_token)

  gh <- function(endpoint, ...) {
    out <- gh::gh(
      endpoint,
      ...,
      owner = spec_owner(repo_spec),
      repo = spec_repo(repo_spec),
      .token = auth_token,
      .api_url = host,
      .send_headers = c(
        "Accept" = "application/vnd.github.symmetra-preview+json"
      )
    )
    if (identical(out[[1]], "")) {
      list()
    } else {
      out
    }
  }

  cur_labels <- gh("GET /repos/:owner/:repo/labels")
  cur_label_names <- purrr::map_chr(cur_labels, "name")

  # Rename existing labels
  to_rename <- intersect(cur_label_names, names(rename))
  if (length(to_rename) > 0) {
    delta <- purrr::map2_chr(
      to_rename, rename[to_rename],
      ~ paste0(ui_value(.x), " -> ", ui_value(.y))
    )
    ui_done("Renaming labels: {paste0(delta, collapse = ', ')}")

    for (label in to_rename) {
      gh(
        "PATCH /repos/:owner/:repo/labels/:current_name",
        current_name = label,
        name = rename[[label]]
      )
    }

    update <- match(to_rename, cur_label_names)
    cur_label_names[update] <- rename[to_rename]
  }

  # Add missing labels
  to_add <- setdiff(labels, cur_label_names)
  if (length(to_add) > 0) {
    ui_done("Adding missing labels: {ui_value(to_add)}")

    for (label in to_add) {
      gh(
        "POST /repos/:owner/:repo/labels",
        name = label,
        color = purrr::pluck(colours, label, .default = random_colour()),
        description = purrr::pluck(descriptions, label, .default = "")
      )
    }
  }

  # Update colours
  to_update <- intersect(cur_label_names, names(colours))
  if (length(to_update) > 0) {
    ui_done("Updating colours")

    for (label in to_update) {
      gh(
        "PATCH /repos/:owner/:repo/labels/:name",
        name = label,
        color = colours[[label]]
      )
    }
  }

  # Update descriptions
  to_update <- intersect(cur_label_names, names(descriptions))
  if (length(to_update) > 0) {
    ui_done("Updating descriptions")

    for (label in to_update) {
      gh(
        "PATCH /repos/:owner/:repo/labels/:name",
        name = label,
        description = descriptions[[label]]
      )
    }
  }

  # Delete unused default labels
  if (delete_default) {
    default <- purrr::map_lgl(cur_labels, "default")
    to_remove <- setdiff(cur_label_names[default], labels)

    if (length(to_remove) > 0) {
      ui_done("Removing default labels: {ui_value(to_remove)}")

      for (label in to_remove) {
        issues <- gh("GET /repos/:owner/:repo/issues", labels = label)
        if (length(issues) > 0) {
          ui_todo("Delete {ui_value(label)} label manually; it has associated issues")
        } else {
          gh("DELETE /repos/:owner/:repo/labels/:name", name = label)
        }
      }
    }
  }
}



#' @export
#' @rdname use_github_labels
use_tidy_labels <- function(repo_spec = github_repo_spec(),
                            auth_token = github_token(),
                            host = NULL) {
  use_github_labels(
    repo_spec = repo_spec,
    labels = tidy_labels(),
    rename = tidy_labels_rename(),
    colours = tidy_label_colours(),
    descriptions = tidy_label_descriptions(),
    delete_default = TRUE,
    auth_token = auth_token,
    host = host
  )
}

#' @rdname use_github_labels
#' @export
tidy_labels <- function() {
  names(tidy_label_colours())
}

#' @rdname use_github_labels
#' @export
tidy_labels_rename <- function() {
  c(
    "enhancement" = "feature",
    "question" = "reprex",
    "good first issue" = "good first issue :heart:",
    "help wanted" = "help wanted :heart:",
    "docs" = "documentation"
  )
}


#' @rdname use_github_labels
#' @export
tidy_label_colours <- function() {
  # http://tristen.ca/hcl-picker/#/hlc/5/0.26/E0B3A2/E1B996
  c(
    "breaking change :skull_and_crossbones:" = "E0B3A2",
    "bug" = "E0B3A2",
    "documentation" = "CBBAB8",
    "feature" = "B4C3AE",
    "good first issue :heart:" = "CBBAB8",
    "help wanted :heart:" = "C5C295",
    "reprex" = "C5C295",
    "tidy-dev-day :nerd_face:" = "CBBAB8",
    "wip" = "E1B996"
  )
}

#' @rdname use_github_labels
#' @export
tidy_label_descriptions <- function() {
  c(
    "bug" = "an unexpected problem or unintended behavior",
    "feature" = "a feature request or enhancement",
    "reprex" = "needs a minimal reproducible example",
    "wip" = "work in progress",
    "documentation" = "",
    "good first issue :heart:" = "good issue for first-time contributors",
    "help wanted :heart:" = "we'd love your help!",
    "breaking change :skull_and_crossbones:" = "API change likely to affect existing code",
    "tidy-dev-day :nerd_face:" = "Tidyverse Developer Day rstd.io/tidy-dev-day"
  )
}

random_colour <- function() {
  format(as.hexmode(sample(256 * 256 * 256 - 1, 1)), width = 6)
}
