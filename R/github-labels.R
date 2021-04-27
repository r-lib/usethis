#' Manage GitHub issue labels
#'
#' @description
#' `use_github_labels()` can create new labels, update colours and descriptions,
#' and optionally delete GitHub's default labels (if `delete_default = TRUE`).
#' It will never delete labels that have associated issues.
#'
#' `use_tidy_labels()` calls `use_github_labels()` with tidyverse conventions
#' powered by `tidy_labels()`, `tidy_labels_rename()`, `tidy_label_colours()`
#' and `tidy_label_descriptions()`.
#'
#' @section Label usage:
#' Labels are used as part of the issue-triage process, designed to minimise the
#' time spent re-reading issues. The absence of a label indicates that an issue
#' is new, and has yet to be triaged.
#' * `reprex` indicates that an issue does not have a minimal reproducible
#'   example, and that a reply has been sent requesting one from the user.
#' * `bug` indicates an unexpected problem or unintended behavior.
#' * `feature` indicates a feature request or enhancement.
#' * `docs` indicates an issue with the documentation.
#' * `wip` indicates that someone is working on it or has promised to.
#' * `good first issue` indicates a good issue for first-time contributors.
#' * `help wanted` indicates that a maintainer wants help on an issue.
#'
#' @param repo_spec,host,auth_token `r lifecycle::badge("deprecated")`: These
#'   arguments are now deprecated and will be removed in the future. Any input
#'   provided via these arguments is not used. The target repo, host, and auth
#'   token are all now determined from the current project's Git remotes.
#' @param labels A character vector giving labels to add.
#' @param rename A named vector with names giving old names and values giving
#'   new names.
#' @param colours,descriptions Named character vectors giving hexadecimal
#'   colours (like `e02a2a`) and longer descriptions. The names should match
#'   label names, and anything unmatched will be left unchanged. If you create a
#'   new label, and don't supply colours, it will be given a random colour.
#' @param delete_default If `TRUE`, removes GitHub default labels that do not
#'   appear in the `labels` vector and that do not have associated issues.
#'
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
use_github_labels <- function(repo_spec = deprecated(),
                              labels = character(),
                              rename = character(),
                              colours = character(),
                              descriptions = character(),
                              delete_default = FALSE,
                              host = deprecated(),
                              auth_token = deprecated()) {
  if (lifecycle::is_present(repo_spec)) {
    deprecate_warn_repo_spec("use_github_labels")
  }
  if (lifecycle::is_present(host)) {
    deprecate_warn_host("use_github_labels")
  }
  if (lifecycle::is_present(auth_token)) {
    deprecate_warn_auth_token("use_github_labels")
  }

  tr <- target_repo(github_get = TRUE)
  if (!isTRUE(tr$can_push)) {
    ui_stop("
      You don't seem to have push access for {ui_value(tr$repo_spec)}, which \\
      is required to modify labels.")
  }
  gh <- gh_tr(tr)

  cur_labels <- gh("GET /repos/{owner}/{repo}/labels")
  label_attr <- function(x, l, mapper = map_chr) {
    mapper(l, x, .default = NA)
  }

  # Rename existing labels
  cur_label_names <- label_attr("name", cur_labels)
  to_rename <- intersect(cur_label_names, names(rename))
  if (length(to_rename) > 0) {
    delta <- purrr::map2_chr(
      to_rename, rename[to_rename],
      ~ paste0(ui_value(.x), " -> ", ui_value(.y))
    )
    ui_done("Renaming labels: {paste0(delta, collapse = '\n')}")

    # Can't do this at label level, i.e. "old_label_name --> new_label_name"
    # Fails if "new_label_name" already exists
    # https://github.com/r-lib/usethis/issues/551
    # Must first PATCH issues, then sort out labels
    issues <- map(
      to_rename,
      ~ gh("GET /repos/{owner}/{repo}/issues", labels = .x)
    )
    issues <- purrr::flatten(issues)
    number <- map_int(issues, "number")
    old_labels <- map(issues, "labels")
    df <- data.frame(
      number = rep.int(number, lengths(old_labels))
    )
    df$labels <- purrr::flatten(old_labels)
    df$labels <- map_chr(df$labels, "name")

    # enact relabelling
    m <- match(df$labels, names(rename))
    df$labels[!is.na(m)] <- rename[m[!is.na(m)]]
    df <- df[!duplicated(df), ]
    new_labels <- split(df$labels, df$number)
    purrr::iwalk(
      new_labels,
      ~ gh(
        "PATCH /repos/{owner}/{repo}/issues/{issue_number}",
        issue_number = .y,
        labels = I(.x)
      )
    )

    # issues have correct labels now; safe to edit labels themselves
    purrr::walk(
      to_rename,
      ~ gh("DELETE /repos/{owner}/{repo}/labels/{name}", name = .x)
    )
    labels <- union(labels, setdiff(rename, cur_label_names))
  } else {
    ui_info("No labels need renaming")
  }

  cur_labels <- gh("GET /repos/{owner}/{repo}/labels")
  cur_label_names <- label_attr("name", cur_labels)

  # Add missing labels
  if (all(labels %in% cur_label_names)) {
    ui_info("No new labels needed")
  } else {
    to_add <- setdiff(labels, cur_label_names)
    ui_done("Adding missing labels: {ui_value(to_add)}")

    for (label in to_add) {
      gh(
        "POST /repos/{owner}/{repo}/labels",
        name = label,
        color = purrr::pluck(colours, label, .default = random_colour()),
        description = purrr::pluck(descriptions, label, .default = "")
      )
    }
  }

  cur_labels <- gh("GET /repos/{owner}/{repo}/labels")
  cur_label_names <- label_attr("name", cur_labels)

  # Update colours
  cur_label_colours <- set_names(
    label_attr("color", cur_labels), cur_label_names
  )
  if (identical(cur_label_colours[names(colours)], colours)) {
    ui_info("Label colours are up-to-date")
  } else {
    to_update <- intersect(cur_label_names, names(colours))
    ui_done("Updating colours: {ui_value(to_update)}")

    for (label in to_update) {
      gh(
        "PATCH /repos/{owner}/{repo}/labels/{name}",
        name = label,
        color = colours[[label]]
      )
    }
  }

  # Update descriptions
  cur_label_descriptions <- set_names(
    label_attr("description", cur_labels), cur_label_names
  )
  if (identical(cur_label_descriptions[names(descriptions)], descriptions)) {
    ui_info("Label descriptions are up-to-date")
  } else {
    to_update <- intersect(cur_label_names, names(descriptions))
    ui_done("Updating descriptions: {ui_value(to_update)}")

    for (label in to_update) {
      gh(
        "PATCH /repos/{owner}/{repo}/labels/{name}",
        name = label,
        description = descriptions[[label]]
      )
    }
  }

  # Delete unused default labels
  if (delete_default) {
    default <- map_lgl(cur_labels, "default")
    to_remove <- setdiff(cur_label_names[default], labels)

    if (length(to_remove) > 0) {
      ui_done("Removing default labels: {ui_value(to_remove)}")

      for (label in to_remove) {
        issues <- gh("GET /repos/{owner}/{repo}/issues", labels = label)
        if (length(issues) > 0) {
          ui_todo("Delete {ui_value(label)} label manually; it has associated issues")
        } else {
          gh("DELETE /repos/{owner}/{repo}/labels/{name}", name = label)
        }
      }
    }
  }
}

#' @export
#' @rdname use_github_labels
use_tidy_labels <- function(repo_spec = deprecated(),
                            host = deprecated(),
                            auth_token = deprecated()) {
  if (lifecycle::is_present(repo_spec)) {
    deprecate_warn_repo_spec("use_tidy_labels")
  }
  if (lifecycle::is_present(host)) {
    deprecate_warn_host("use_tidy_labels")
  }
  if (lifecycle::is_present(auth_token)) {
    deprecate_warn_auth_token("use_tidy_labels")
  }

  use_github_labels(
    labels = tidy_labels(),
    rename = tidy_labels_rename(),
    colours = tidy_label_colours(),
    descriptions = tidy_label_descriptions(),
    delete_default = TRUE
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
    # before           = after
    "enhancement"      = "feature",
    "question"         = "reprex",
    "good first issue" = "good first issue :heart:",
    "help wanted"      = "help wanted :heart:",
    "docs"             = "documentation"
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
    "upkeep" = "C2ACC0",
    "good first issue :heart:" = "CBBAB8",
    "help wanted :heart:" = "C5C295",
    "reprex" = "C5C295",
    "tidy-dev-day :nerd_face:" = "CBBAB8"
  )
}

#' @rdname use_github_labels
#' @export
tidy_label_descriptions <- function() {
  c(
    "bug" = "an unexpected problem or unintended behavior",
    "feature" = "a feature request or enhancement",
    "upkeep" = "maintenance, infrastructure, and similar",
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
