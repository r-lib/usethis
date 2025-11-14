# Manage GitHub issue labels

`use_github_labels()` can create new labels, update colours and
descriptions, and optionally delete GitHub's default labels (if
`delete_default = TRUE`). It will never delete labels that have
associated issues.

`use_tidy_github_labels()` calls `use_github_labels()` with tidyverse
conventions powered by `tidy_labels()`, `tidy_labels_rename()`,
`tidy_label_colours()` and `tidy_label_descriptions()`.

### tidyverse label usage

Labels are used as part of the issue-triage process, designed to
minimise the time spent re-reading issues. The absence of a label
indicates that an issue is new, and has yet to be triaged.

There are four mutually exclusive labels that indicate the overall
"type" of issue:

- `bug`: an unexpected problem or unintended behavior.

- `documentation`: requires changes to the docs.

- `feature`: feature requests and enhancement.

- `upkeep`: general package maintenance work that makes future
  development easier.

Then there are five labels that are needed in most repositories:

- `breaking change`: issue/PR will requires a breaking change so should
  be not be included in patch releases.

- `reprex` indicates that an issue does not have a minimal reproducible
  example, and that a reply has been sent requesting one from the user.

- `good first issue` indicates a good issue for first-time contributors.

- `help wanted` indicates that a maintainer wants help on an issue.

- `wip` indicates that someone is working on it or has promised to.

Finally most larger repos will accumulate their own labels for specific
areas of functionality. For example, usethis has labels like
"description", "paths", "readme", because time has shown these to be
common sources of problems. These labels are helpful for grouping issues
so that you can tackle related problems at the same time.

Repo-specific issues should have a grey background (`#eeeeee`) and an
emoji. This keeps the issue page visually harmonious while still giving
enough variation to easily distinguish different types of label.

## Usage

``` r
use_github_labels(
  labels = character(),
  rename = character(),
  colours = character(),
  descriptions = character(),
  delete_default = FALSE
)

use_tidy_github_labels()

tidy_labels()

tidy_labels_rename()

tidy_label_colours()

tidy_label_descriptions()
```

## Arguments

- labels:

  A character vector giving labels to add.

- rename:

  A named vector with names giving old names and values giving new
  names.

- colours, descriptions:

  Named character vectors giving hexadecimal colours (like `e02a2a`) and
  longer descriptions. The names should match label names, and anything
  unmatched will be left unchanged. If you create a new label, and don't
  supply colours, it will be given a random colour.

- delete_default:

  If `TRUE`, removes GitHub default labels that do not appear in the
  `labels` vector and that do not have associated issues.

## Examples

``` r
if (FALSE) { # \dontrun{
# typical use in, e.g., a new tidyverse project
use_github_labels(delete_default = TRUE)

# create labels without changing colours/descriptions
use_github_labels(
  labels = c("foofy", "foofier", "foofiest"),
  colours = NULL,
  descriptions = NULL
)

# change descriptions without changing names/colours
use_github_labels(
  labels = NULL,
  colours = NULL,
  descriptions = c("foofiest" = "the foofiest issue you ever saw")
)
} # }
```
