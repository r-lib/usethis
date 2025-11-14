# Add a code of conduct

Adds a `CODE_OF_CONDUCT.md` file to the active project and lists in
`.Rbuildignore`, in the case of a package. The goal of a code of conduct
is to foster an environment of inclusiveness, and to explicitly
discourage inappropriate behaviour. The template comes from
<https://www.contributor-covenant.org>, version 2.1:
<https://www.contributor-covenant.org/version/2/1/code_of_conduct/>.

## Usage

``` r
use_code_of_conduct(contact, path = NULL)
```

## Arguments

- contact:

  Contact details for making a code of conduct report. Usually an email
  address.

- path:

  Path of the directory to put `CODE_OF_CONDUCT.md` in, relative to the
  active project. Passed along to
  [`use_directory()`](https://usethis.r-lib.org/dev/reference/use_directory.md).
  Default is to locate at top-level, but `.github/` is also common.

## Details

If your package is going to CRAN, the link to the CoC in your README
must be an absolute link to a rendered website as `CODE_OF_CONDUCT.md`
is not included in the package sent to CRAN. `use_code_of_conduct()`
will automatically generate this link if (1) you use pkgdown and (2)
have set the `url` field in `_pkgdown.yml`; otherwise it will link to a
copy of the CoC on <https://www.contributor-covenant.org>.
