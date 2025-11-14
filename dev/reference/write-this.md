# Write into or over a file

Helpers to write into or over a new or pre-existing file. Designed
mostly for for internal use. File is written with UTF-8 encoding.

## Usage

``` r
write_union(path, lines, quiet = FALSE)

write_over(path, lines, quiet = FALSE, overwrite = FALSE)
```

## Arguments

- path:

  Path to target file. It is created if it does not exist, but the
  parent directory must exist.

- lines:

  Character vector of lines. For `write_union()`, these are lines to add
  to the target file, if not already present. For `write_over()`, these
  are the exact lines desired in the target file.

- quiet:

  Logical. Whether to message about what is happening.

- overwrite:

  Force overwrite of existing file?

## Value

Logical indicating whether a write occurred, invisibly.

## Functions

- `write_union()`: writes lines to a file, taking the union of what's
  already there, if anything, and some new lines. Note, there is no
  explicit promise about the line order. Designed to modify simple
  config files like `.Rbuildignore` and `.gitignore`.

- `write_over()`: writes a file with specific lines, creating it if
  necessary or overwriting existing, if proposed contents are not
  identical and user is available to give permission.

## Examples

``` r
write_union("a_file", letters[1:3])
#> ✔ Adding "a", "b", and "c" to a_file.
readLines("a_file")
#> [1] "a" "b" "c"
write_union("a_file", letters[1:5])
#> ✔ Adding "d" and "e" to a_file.
readLines("a_file")
#> [1] "a" "b" "c" "d" "e"

write_over("another_file", letters[1:3])
#> ✔ Writing another_file.
readLines("another_file")
#> [1] "a" "b" "c"
write_over("another_file", letters[1:3])
if (FALSE) { # \dontrun{
## will error if user isn't present to approve the overwrite
write_over("another_file", letters[3:1])
} # }

## clean up
file.remove("a_file", "another_file")
#> [1] TRUE TRUE
```
