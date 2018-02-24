# usethis 1.3.0

* usethis has a website: <http://usethis.r-lib.org> (#217). It includes an article with advice on system setup, for usethis and for R development more generally.

* `edit_*()` functions now return the target path, invisibly (#255).

* `edit_git_ignore(scope = "user")` prefers `~/.gitignore`, but detects an existing `~/.gitignore_global`, if it exists. If a new global gitignore file is created, it is created as `~/.gitignore` and recorded in user's git config as the `core.excludesfile` (#255).

* `create_from_github()` gains several arguments and new functionality. The `protocol` argument lets user convey whether remote URLs should be ssh or https. In the case of "fork and clone", the original repo is added as `upstream` remote. It is now possible -- although rarely necessary -- to directly specify the GitHub PAT, credentials (in git2r form), and GitHub host (#214, #214, #253).

* `use_github_labels()` can create or update the colour of arbitrary GitHub issue labels, defaulting to a set of labels and colours used by the tidyverse packages, which are now exposed via `tidy_labels()`. That set now includes the labels "good first issue" and "help wanted" (#168, #249).

* `appveyor_info()` no longer reverses the repo's URL and image link. Corrects the markdown produced by `use_appveyor_badge()` (#240, @llrs). 

* `use_cran_badge()` uses an HTTPS URL for the CRAN badge image (#235, @jdblischak).

* `create_package()` and `create_project()` return a normalized path, even if target directory does not pre-exist (#227, #228).

## New functions

* `use_git_config()` can set user's Git name or email, globally or locally in a project/repo (#267).

* `browse_github_pat()` goes to the webpage where a GitHub user can create a personal access token (PAT) for the GitHub API. If the user configures a PAT, they can use functions like `create_from_github()` and `use_github()` to easily create and connect GitHub repos to local projects. (#248, #257, @jeroen, via @jennybc).

* `use_version()` increments the version of the active package, including an interactive chooser. `use_dev_version()` is now a special case wrapper around this. (#188, #223, @EmilHvitfeldt).

* `use_tidy_github()` creates a standard set of files that make a GitHub repository more navigable for users and contributors: an issue template, contributing guidelines, support documentation, and a code of conduct. All are now placed in a `.github/` subdirectory (#165, @batpigandme).

* `use_bioc_badge` creates a Bioconductor badge that links to the build report (#271, @LiNk-NY).

* `use_binder_badge()` creates a badge indicating the repository can be launched in an executable environment via [Binder](https://mybinder.org/) (#242, @uribo).

# usethis 1.2.0

## New functions

* `use_course()` downloads a folder's worth of materials from a ZIP file, with deliberate choices around the default folder name and location. Developed for use at the start of a workshop. Helps participants obtain materials from, e.g., a DropBox folder or GitHub repo (#196).

* `use_blank_slate()` provides a way to opt in to an RStudio workflow where the user's workspace is neither saved nor reloaded between R sessions. Automated for `scope = "project"`. Provides UI instructions for `scope = "user"`, for now (#139).

* `use_tidy_style()` styles an entire project according to <http://style.tidyverse.org> (#72, #197 @lorenzwalthert).

* GitHub conventions common to tidyverse packages are enacted by `use_tidy_contributing()`, `use_tidy_issue_template()`, and `use_tidy_support()` (@batpigandme, #143, #166).

Other changes

* New projects that don't exhibit other obvious criteria for being a "project" will include a sentinel, empty file named `.here`, so they can be recognized as a project.

* Project launching and switching works on RStudio server (#115, #129).

* `use_template()` is newly exported, so that other packages can provide
templating functions using this framework (@ijlyttle #120).

* `use_readme_rmd()` and `use_readme_md()` work, in a similar fashion, for projects that are and are not a package (#131, #135).

* `use_readme_rmd()` once again creates a pre-commit git hook, to help keep `README.Rmd` and `README.md` in sync (@PeteHaitch #41).

* Substantial increase in unit test coverage.

# usethis 1.1.0

## New helpers

* `browse_github()`, `browse_github_issues()`, `browse_github_pulls()`,
  `browse_cran()` and `browse_travis()` open useful websites related to
   the current project or a named package. (#96, #103).

* `create_from_github()` creates a project from an existing GitHub
  repository, forking if needed (#109).

* `use_cc0_license()` applies a CC0 license, particularly appropriate for data 
  packages (#94)

* `use_lifecycle_badge()` creates a badge describing current stage in 
  project lifecycle (#48).

* `use_pkgdown()` creates the basics needed for a 
  [pkgdown](https://github.com/hadley/pkgdown) website (#88).

* `use_r("foo")` creates and edit `R/foo.R` file. If you have a test file open,
  `use_r()` will open the corresponding `.R` file (#105).

* `use_tidy_versions()` sets minimum version requirement for all dependencies.

## Bug fixes and improvements

* `use_dev_version()` now correctly updates the `Version` field in a package 
  description file. (@tjmahr, #104)

* `use_revdep()` now also git-ignores the SQLite database (#107).

* `use_tidy_eval()` has been tweaked to reflect current guidance (#106)

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
