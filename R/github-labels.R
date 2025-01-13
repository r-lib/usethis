#' Manage GitHub issue labels
#'
#' @description
#' `use_github_labels()` can create new labels, update colours and descriptions,
#' and optionally delete GitHub's default labels (if `delete_default = TRUE`).
#' It will never delete labels that have associated issues.
#'
#' `use_tidy_github_labels()` calls `use_github_labels()` with tidyverse
#' conventions powered by `tidy_labels()`, `tidy_labels_rename()`,
#' `tidy_label_colours()` and `tidy_label_descriptions()`.
#'
#' ## tidyverse label usage
#' Labels are used as part of the issue-triage process, designed to minimise the
#' time spent re-reading issues. The absence of a label indicates that an issue
#' is new, and has yet to be triaged.
#'
#' There are four mutually exclusive labels that indicate the overall "type" of
#' issue:
#'
#' * `bug`: an unexpected problem or unintended behavior.
#' * `documentation`: requires changes to the docs.
#' * `feature`: feature requests and enhancement.
#' * `upkeep`: general package maintenance work that makes future development
#'   easier.
#'
#' Then there are five labels that are needed in most repositories:
#'
#' * `breaking change`: issue/PR will requires a breaking change so should
#'   be not be included in patch releases.
#' * `reprex` indicates that an issue does not have a minimal reproducible
#'   example, and that a reply has been sent requesting one from the user.
#' * `good first issue` indicates a good issue for first-time contributors.
#' * `help wanted` indicates that a maintainer wants help on an issue.
#' * `wip` indicates that someone is working on it or has promised to.
#'
#' Finally most larger repos will accumulate their own labels for specific
#' areas of functionality. For example, usethis has labels like "description",
#' "paths", "readme", because time has shown these to be common sources of
#' problems. These labels are helpful for grouping issues so that you can
#' tackle related problems at the same time.
#'
#' Repo-specific issues should have a grey background (`#eeeeee`) and an emoji.
#' This keeps the issue page visually harmonious while still giving enough
#' variation to easily distinguish different types of label.
#'
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
use_github_labels <- function(labels = character(),
                              rename = character(),
                              colours = character(),
                              descriptions = character(),
                              delete_default = FALSE) {

  # Want to ensure we always have the latest label info
  withr::local_options(gh_cache = FALSE)

  tr <- target_repo(github_get = TRUE, ok_configs = c("ours", "fork"))
  check_can_push(tr = tr, "to modify labels")

  gh <- gh_tr(tr)

  cur_labels <- gh("GET /repos/{owner}/{repo}/labels")
  label_attr <- function(x, l, mapper = map_chr) {
    mapper(l, x, .default = NA)
  }

  # Rename existing labels
  cur_label_names <- label_attr("name", cur_labels)
  to_rename <- intersect(cur_label_names, names(rename))
  if (length(to_rename) > 0) {
    dat <- data.frame(from = to_rename, to = rename[to_rename])
    delta <- glue_data(
      dat,
      "{.val <<from>>} {cli::symbol$arrow_right} {.val <<to>>}",
      .open = "<<", .close = ">>"
    )
    ui_bullets(c(
      "v" = "Renaming labels:",
      bulletize(delta)
    ))

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
    ui_bullets(c("i" = "No labels need renaming."))
  }

  cur_labels <- gh("GET /repos/{owner}/{repo}/labels")
  cur_label_names <- label_attr("name", cur_labels)

  # Add missing labels
  if (all(labels %in% cur_label_names)) {
    ui_bullets(c("i" = "No new labels needed."))
  } else {
    to_add <- setdiff(labels, cur_label_names)
    ui_bullets(c(
      "v" = "Adding missing labels:",
      bulletize(usethis_map_cli(to_add))
    ))

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
    ui_bullets(c("i" = "Label colours are up-to-date."))
  } else {
    to_update <- intersect(cur_label_names, names(colours))
    ui_bullets(c(
      "v" = "Updating colours:",
      bulletize(usethis_map_cli(to_update))
    ))

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
    ui_bullets(c("i" = "Label descriptions are up-to-date."))
  } else {
    to_update <- intersect(cur_label_names, names(descriptions))
    ui_bullets(c(
      "v" = "Updating descriptions:",
      bulletize(usethis_map_cli(to_update))
    ))

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
      ui_bullets(c(
        "v" = "Removing default labels:",
        bulletize(usethis_map_cli(to_remove))
      ))

      for (label in to_remove) {
        issues <- gh("GET /repos/{owner}/{repo}/issues", labels = label)
        if (length(issues) > 0) {
          ui_bullets(c(
            "_" = "Delete {.val {label}} label manually; it has associated issues."
          ))
        } else {
          gh("DELETE /repos/{owner}/{repo}/labels/{name}", name = label)
        }
      }
    }
  }
}

#' @export
#' @rdname use_github_labels
use_tidy_github_labels <- function() {
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
    "wip" = "E1B996",
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
    "tidy-dev-day :nerd_face:" = "Tidyverse Developer Day"
  )
}

random_colour <- function() {
  format(as.hexmode(sample(256 * 256 * 256 - 1, 1)), width = 6)
}
