# Automatically rename paired `R/` and `test/` files

- Moves `R/{old}.R` to `R/{new}.R`

- Moves `src/{old}.*` to `src/{new}.*`

- Moves `tests/testthat/test-{old}.R` to `tests/testthat/test-{new}.R`

- Moves `tests/testthat/test-{old}-*.*` to
  `tests/testthat/test-{new}-*.*` and updates paths in the test file.

- Removes `context()` calls from the test file, which are unnecessary
  (and discouraged) as of testthat v2.1.0.

This is a potentially dangerous operation, so you must be using Git in
order to use this function.

## Usage

``` r
rename_files(old, new)
```

## Arguments

- old, new:

  Old and new file names (with or without `.R` extensions).
