# usethis 1.0.0

This is a new package that extracts out many functions that previously lived in devtools, as well as providing more building blocks so you can create your own helpers. As well as the many new helpers listed below, there are three main improvements to the package:

* More support for general R projects, other than packages.
* A notion of an "active" project that all commands operate on.
* Refined output.

usethis is gradually evolving towards supporting more general R "projects", not just packages. This is still a work in progress, so please let me know if you use a function that you think should work with projects but doesn't. You can also try out the new `create_project()` which creates a basic RStudio project.

The concept of the working directory and the "base path" have been refined. Rather than using an argument to specify the active project, all `use_` functions now use a global active project setting, as returned by `proj_get()`. This is cached throughout a session, although it will be updated by `create_package()` and `create_project()`. You'll now get an clear error if you attempt to `use_something()` outside of a project, and `create_something()` will warn if you're trying to create inside an existing project.

The output from all usethis commands has been reviewed to be informative but not overwhelming. usethis takes advantage of colour (using crayon and RStudio 1.1) to help chunk the output and clearly differentiate what you need to do vs. what has been done for you.

## New functions

* `use_apl2_license()` if you want to use the Apache 2.0 license.

* `use_depsy_badge()` allows including a Depsy badge (@gvegayon, #68).

* `use_dev_package()` works like `use_package()` but also adds the 
  repo to the `Remotes` field (#32).

* `use_github_labels()` will automatically set up a standard set of labels,
  optionally removing the default labels (#1).

* `use_pipe()` creates a template to use magrittr's `%>%` in your package (#15).

* `use_tidy_ci()` which sets up travis and codecov using the tidyverse
  conventions (#14)

* `use_tidy_description()` puts description fields in a standard order
  and alphabetises dependencies.

* `use_tidy_eval()` imports and re-exports the recommend set of tidy eval 
  helpers if your package uses tidy eval (#46).

* `use_usethis()` opens your `.Rprofile` and gives you the code to copy
  and paste in.

## New edit functions

A new class of functions make it easy to edit common config files:

* `edit_r_profile_user()` opens `.Rprofile`
* `edit_r_environ_user()` opens `.Renviron`
* `edit_r_makevars_user()` opens `.R/Makevars`
* `edit_git_config_user()` opens `.gitconfig`
* `edit_git_ignore_user()` opens `.gitignore`
* `edit_rstudio_snippets(type)` opens `~/R/snippets/{type}.snippets`

## Updates

* `use_coverage("codecov")` now sets a default threshold of 1% to try and 
  reduce false positives (#8).

* `use_description()` now sets `ByteCompile: true` so you can benefit from
  the byte compiler (#29)

* The license functions (`use_mit_license()`, `use_apl2_license()`, and 
  `use_gpl3_license()`) save a copy of the standard license text in 
  `LICENSE.md`, which is then added to `.Rbuildignore`. This allows you
  to follow standard licensing best practices while adhering to CRANs 
  requirements (#10).

* `use_package_doc()` uses more modern roxygen2 template requires that 
  less duplication.

* `use_test()` will use the name of the currently open file in RStudio
  if you don't supply an explicit name (#89).

* `use_readme_rmd()` now puts images in `man/figures/` and no longer
  adds to `.Rbuildgnore`. This ensures that the rendered `README.md` will
  also work on CRAN (#16, #19). The first chunk now uses `include = FALSE`
  and is named setup (#19).

* `use_revdep()` creates structure for use with revdepcheck package, the
  preferred way to run revdepchecks. (#33)

## Building blocks

* New `use_badge()` for adding any badge to a README. Now only prints a 
  todo message if the badge does not already exist.

* `use_directory()` is now exported (#27). 

## Bug fixes and minor improvements

* Functions which require code to be copied now automatically put the code on
  the clipboard if it is available (#52).

* `create_package()` no longer creates a dependency on the current version of 
  R.

* `use_build_ignore()` now strips trailing `/`

* `use_git()` will restart RStudio if needed (and possible) (#42).

* `use_github()` now has an organisation parameter so you can create repos
  in organisations (#4).

* `use_template()` and `use_test()` now convert title to a slug that only
  contains lowercase letters, numbers, and `-`.

* `use_vignette()` now adds `*.html` and `*.R` to your `.gitgnore` so you
  don't accidentally add in compiled vignette products (#35).
  
