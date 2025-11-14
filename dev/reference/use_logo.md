# Use a package logo

This function helps you use a logo in your package:

- Enforces a specific size

- Stores logo image file at `man/figures/logo.png`

- Produces the markdown text you need in README to include the logo

## Usage

``` r
use_logo(img, geometry = "240x278", retina = TRUE)
```

## Arguments

- img:

  The path to an existing image file

- geometry:

  a
  [magick::geometry](https://docs.ropensci.org/magick/reference/geometry.html)
  string specifying size. The default assumes that you have a hex logo
  using spec from
  [http://hexb.in/sticker.html](http://hexb.in/sticker.md).

- retina:

  `TRUE`, the default, scales the image on the README, assuming that
  geometry is double the desired size.

## Examples

``` r
if (FALSE) { # \dontrun{
use_logo("usethis.png")
} # }
```
