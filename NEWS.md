# usethis 0.0.0.9000

* `use_git()` will prompt you to restart RStudio if needed (and possible) (#42).

* The output from all usethis commands has been reviewed to be informative 
  but not overwhelming. usethis takes advantage of colour to help chunk
  the output and clearly differentiate what you need to do vs. what has
  been done for you.

* New `use_dev_package()` works like `use_package()` but also adds the 
  repo to the `Remotes` field (#32).

* `use_vignette()` now adds `*.html` and `*.R` to your `.gitgnore` so you
  don't accidentally add in compiled vignette products (#35).

* `use_description()` now sets `ByteCompile: true` so you can benefit from
  the byte compiler (#29)

* `use_readme_rmd()` now puts images in `man/figures/` and no longer
  adds to `.Rbuildgnore`. This ensures that the rendered `README.md` will
  also work on CRAN (#16, #19). The first chunk now uses `include = FALSE`
  and is named setup (#19).

* `use_github()` now has an organisation parameter so you can create repos
  in organisations (#4).

* Functions are now designed to work with a directory that's not necessarily
  a package. This doesn't always make sense but in the long term makes
  usesthis more flexible for other tasks like (e.g.) data analysis.

* `use_template()` and `use_test()` now convert title to a slug that only
  contains lowercase letters, numbers, and `-`.

* `use_package_doc()` uses more modern roxygen2 template requires even less
  duplication.

* Removed old `add_build_ignore()`

* `use_build_ignore()` now strips trailing `/`
