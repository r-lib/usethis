# Add an author to the `Authors@R` field in DESCRIPTION

`use_author()` adds a person to the `Authors@R` field of the DESCRIPTION
file, creating that field if necessary. It will not modify, e.g., the
role(s) or email of an existing author (judged using their "Given
Family" name). For that we recommend editing DESCRIPTION directly. Or,
for programmatic use, consider calling the more specialized functions
available in the desc package directly.

`use_author()` also surfaces two other situations you might want to
address:

- Explicit use of the fields `Author` or `Maintainer`. We recommend
  switching to the more modern `Authors@R` field instead, because it
  offers richer metadata for various downstream uses. (Note that
  `Authors@R` is *eventually* processed to create `Author` and
  `Maintainer` fields, but only when the `tar.gz` is built from package
  source.)

- Presence of the fake author placed by
  [`create_package()`](https://usethis.r-lib.org/dev/reference/create_package.md)
  and
  [`use_description()`](https://usethis.r-lib.org/dev/reference/use_description.md).
  This happens when usethis has to create a DESCRIPTION file and the
  user hasn't given any author information via the `fields` argument or
  the global option `"usethis.description"`. The placeholder looks
  something like `First Last <first.last@example.com> [aut, cre]` and
  `use_author()` offers to remove it in interactive sessions.

## Usage

``` r
use_author(given = NULL, family = NULL, ..., role = "ctb")
```

## Arguments

- given:

  a character vector with the *given* names, or a list thereof.

- family:

  a character string with the *family* name, or a list thereof.

- ...:

  Arguments passed on to
  [`utils::person`](https://rdrr.io/r/utils/person.html)

  `middle`

  :   a character string with the collapsed middle name(s). Deprecated,
      see **Details**.

  `email`

  :   a character string (or vector) giving an e-mail address (each), or
      a list thereof.

  `comment`

  :   a character string (or vector) providing comments, or a list
      thereof.

  `first`

  :   a character string giving the first name. Deprecated, see
      **Details**.

  `last`

  :   a character string giving the last name. Deprecated, see
      **Details**.

- role:

  a character vector specifying the role(s) of the person (see
  **Details**), or a list thereof.

## Examples

``` r
if (FALSE) { # \dontrun{
use_author(
  given = "Lucy",
  family = "van Pelt",
  role = c("aut", "cre"),
  email = "lucy@example.com",
  comment = c(ORCID = "LUCY-ORCID-ID")
)

use_author("Charlie", "Brown")
} # }
```
