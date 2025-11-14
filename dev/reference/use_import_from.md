# Import a function from another package

`use_import_from()` imports a function from another package by adding
the roxygen2 `@importFrom` tag to the package-level documentation (which
can be created with
[`use_package_doc()`](https://usethis.r-lib.org/dev/reference/use_package_doc.md)).
Importing a function from another package allows you to refer to it
without a namespace (e.g., `fun()` instead of `package::fun()`).

`use_import_from()` also re-documents the NAMESPACE, and re-load the
current package. This ensures that `fun` is immediately available in
your development session.

## Usage

``` r
use_import_from(package, fun, load = is_interactive())
```

## Arguments

- package:

  Package name

- fun:

  A vector of function names

- load:

  Logical. Re-load with
  [`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html)?

## Value

Invisibly, `TRUE` if the package document has changed, `FALSE` if not.

## Examples

``` r
if (FALSE) { # \dontrun{
use_import_from("glue", "glue")
} # }
```
