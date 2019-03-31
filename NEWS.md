# usethis (development version)

## New features

* `git_remotes()` and `use_git_remote()` are new helpers to inspect or modify
  Git remote URLs for the repo associated with the active project (#649).

* `use_rcpp_armadillo()` and `use_rcpp_eigen()` are new functions 
   that set up a package to use RcppArmadillo or RcppEigen, respectively
   (#421, @coatless, @duckmayr).

* `use_tutorial()` creates a new interactive R Markdown tutorial, as implemented
  by the [`learnr` package](https://rstudio.github.io/learnr/index.html)
  (@angela-li, #645).

* `use_ccby_license()` adds a CCBY 4.0 license (#547, @njtierney)

* `git_protocol()` + `use_git_protocol()` and `git2r_credentials()` + `use_git2r_credentials()` are new helpers to summon or set git transport protocol (SSH or HTTPS) or git2r credentials, respectively. These functions are primarily for internal use. Most users can rely on default behaviour, but these helpers can be used to intervene if git2r isn't discovering the right credentials (#653).

* `use_github()` tries harder but also fails earlier, with more informative messages, making it less likely to leave the repo partially configured (#221).

* `git_sitrep()` lets you know what's up with your git, git2r and GitHub 
  config (#328).

* `git_vaccinate()` vaccinates your global git ignore file ensuring that
  you never check in files likely to contain confidental information (#469).
  It is called automatically if `use_git_ignore()` creates a new `.gitnore`
  file.

* `pr_init()`, `pr_fetch()`, `pr_push()`, `pr_pull()`, and `pr_finish()` are a
  new family of helpers designed to help with the GitHub PR process. Currently 
  they assume that you're working on your own repo (i.e. no fork), but once 
  we've happy with them, we'll extend to work on more situations (#346).

* New `proj_activate()` lets you activate a project either opening a new 
  RStudio session (if you use RStudio), or changing the working directory 
  (#511).

* `use_article()` creates articles, vignettes that are automatically
  added to `.Rbuildignore`. These appear on pkgdown sites, but are not 
  included with the package itself (#281).

* `use_citation()` creates a basic `CITATION` template and puts it in the 
  right place (#100).

* `use_c("foo")` sets up `src/` and creates `src/foo.c` (#117).

* `use_devtools()` (#624), `use_conflicted()` (#362), and `use_reprex()` (#465)
  help add useful packages to your `.Rprofile`.
  
* `use_covr_ignore()` makes it easy to ignore files in test coverage (#434).

* `use_github_release()` creates a draft GitHub release using the entries
  in  `NEWS.md` (#137).

* `use_gitlab_ci()` creates a draft gitlab-ci.yaml for use with GitLab 
  (#565, @overmar).

* `use_lgpl_license()` automates set up of the LGL license (#448, @krlmlr).

* `use_partial_warnings()` helps use add standard warning block to your
  `.Rprofile` (#64).

* `use_pkgdown_travis()` helps you set up pkgdown for automatic deployment
  from travis to github pages (#524).

* `use_rcpp("foo")` now creates `src/foo.cpp` (#117).

* `use_release_issue()` creates a GitHub issue containing a release checklist 
  capturing best practices discovered by the tidyverse team (#338)
  
* `write_union` appends the novel `lines`, but does not remove duplicates from
  existing lines (#583, @khailper).

* New `use_addin()` helps setup necessary binding information for RStudio 
  addins. (#353, @haozhu233)


## Partial file management

usethis gains tooling to manage part of a file. This currently used for managing badges in your README, and roxygen import tags:

*   `use_badge()` and friends now automatically add badges if your README 
    contains a specially formatted badge block (#497):

    ```
    <-- badge:start -->
    <-- badge:end -->
    ```
 
*   `use_tibble()` and `use_rcpp()` automatically adding roxygen tags to 
    to `{package}-package.R` if it contains a specially formatted namespace
    block (#517):

    ```R
    ## usethis namespace: start
    ## usethis namespace: end
    NULL
    ```
    
    Unfortunately this means that `use_rcpp()` no longer supports non-roxygen2
    workflows, but I suspect the set of people who use usethis and Rcpp but 
    not roxygen2 is very small.

## Extending and wrapping usethis

* `proj_get()` and `proj_set()` no longer have a `quiet` argument. The 
  user-facing message about setting a project is now under the same control 
  as other messages, i.e. `getOption("usethis.quiet", default = FALSE)` (#441).

* A new family of `ui_` functions makes it possible to make use of the 
  user interface of usethis in your own code (#308). There are four families 
  of functions:

    * block styles: `ui_line()`, `ui_done()`, `ui_todo()`.
    * conditions: `ui_stop()`, `ui_warn()`.
    * questions: `ui_yeah()`, `ui_nope()`.
    * inline styles: `ui_field()`, `ui_value()`, `ui_path()`, `ui_code()`.

* `with_project()` and `local_project()` are new withr-style functions to 
  temporarily set an active usethis project. They make usethis functions easier 
  to use in an *ad hoc* fashion or from another package (#441).

## Tidyverse standards

(These standards are used by all tidyverse packages; you are welcome to use them if you find them helpful.)

* Call `use_tidy_labels()` to update GitHub labels. Colours are less 
  saturated, docs is now documentation, we use some emoji, and performance is 
  no longer automatically added to all repos (#519). Repo specific issues
  should be given colour `#eeeeee` and have an emoji.

* Call `use_logo()` to update the package logo to the latest specifications:
  `man/figure/logo.png` should be 240 x 278, and README should contain
  `<img src="man/figures/logo.png" align="right" height="139" />`.
  This gives a nicer display on retina displays. The logo is also linked to the
  pkgdown site if available (#536).

* When creating a new package, use `create_tidy_package()` to start with a
  package following the tidyverse standards (#461). 

* `NEWS.md` for the development version should use "(development version)" 
  rather than the specific version (#440).

* pkgdown sites should now be built by travis and deployed automatically to
  GitHub pages. `use_pkgdown_travis()` will help you set that up.

* When starting the release process, call `use_release_issue()` to create a 
  release checklist issue.

* Prior to CRAN submission call `use_tidy_release_test_env()` to update the 
  test environment section in `cran-comments()` (#496).

* After acceptance, try `use_github_release()` to automatically create a 
  release. It's created as a draft so you have a chance to look over before
  publishing.

* `use_vignette()` includes the a standard initialisation chunk with
  `knitr::opts_chunk$set(comment = "#>", collapse = TRUE)` which should
  be used for all Rmds.

## Minor bug fixes and improvements

* `browse_github()` now falls back to CRAN organisation (with a warning) if 
  package doesn't have it's own GitHub repo (#186).

* `create_*()`restore the active project if they error part way through, 
  and use `proj_activate()` (#453, #511).

* `edit_r_buildignore()` opens `.Rbuildignore` for manual editing 
   (#462, @bfgray3).

* `edit_r_profile()` and `edit_r_environ()` now respect environment variables
  `R_PROFILE_USER` and `R_ENVIRON_USER` respectively (#480).

* `ui_code_block()` now strips ascii escapes before copying code to clipboard 
  (#447).

* `use_description()` once again prints the generated description (#287).

* `use_description_field()` is no longer sensitive to whitespace, which
  allows `use_vignette()` to work even if the `VignetteBuilder` field is
  spread over multiple lines (#439).

* `use_git_config()` now invisibly returns the previous values of the
  settings.

* `use_github()` and `create_from_github()` gain a `protocol` argument. The
  default is still `"ssh"`, but it can be changed globally to `"https"` with 
  `options(usethis.protocol = "https")`. (#494, @cderv)

* `use_github_labels()` has been rewritten be more flexible. You can
  now supply a repo name, and `descriptions`, and you can set 
  colours/descriptions independently of creating labels. You can also `rename` 
  existing labels (#290). 

* `use_logo()` can override existing logo if user gives permission (#454).
  It also produces retina approrpriate logos by default, and matches the 
  aspect ratio to the <http://hexb.in/sticker.html> specification (#499).

* `use_news_md()` will optionally commit.

* `use_package()` gains a `min_version` argument to specify a minimum
  version requirement (#498). Set to `TRUE` to use the currently installed 
  version (#386). This is used by `use_tidy()` in order to require version 
  0.1.2 or greater of rlang (#484).

* `use_pkgdown()` is now configurable with site options (@jayhesselberth, #467),
  and no longer creates the `docs/` directory (#495).

* `use_test()` no longer forces the filename to be lowercase (#613, @stufield).

* `use_test()` will not include a `context()` in the generated file if used 
  with testthat 2.1.0 and above (the future release of testthat) (#325).

* `use_tidy_description()` sets the `Encoding` field in `DESCRIPTION` 
  (#502, @krlmlr).
  
* `use_tidy_eval()` re-exports `:=` (#595, @jonthegeek).

* `use_tidy_versions()` has source argument so that you can choose to use
  local or CRAN versions (#309).

* `use_travis()` gains an `ext` argument, defaulting to `"org"`. 
  Use `ext = "com"` for `https://travis-ci.com`. (@cderv, #500)

* `use_version()` asks before committing.

* `use_vignette()` now has a `title` argument which is used in YAML header
  (in the two places where it is needed). The vignettes also lose the default
  author and date fields (@rorynolan, #445), and the RMarkdown starter material.
  They gain a standard setup chunk.

* `use_version("dev")` now creates a standard "(development version)" heading
  in `NEWS.md` (#440).

* withr moves from Suggests to Imports.

* `use_vignette` now checks if the vignette name is valid (starts with letter 
  and consists of letters, numbers, hyphen, and underscore) and throws an error 
  if not (@akgold, #555).
  
* `restart_rstudio()` now returns `FALSE` in RStudio if no project is open,
  fixing an issue that caused errors in helpers that suggest restarting 
  RStudio (@gadenbuie, #571).

# usethis 1.4.0

## File system

All usethis file system operations now use the [fs](https://fs.r-lib.org) package (#177). This should not change how usethis functions, but users may notice these features of fs-mediated paths:

  - Paths are "tidy", meaning `/` is the path separator and there are never multiple or trailing `/`.
  - Paths are UTF-8 encoded.
  - A Windows user's home directory is interpreted as `C:\Users\username` (typical of Unix-oriented tools, like Git and ssh; also matches Python), as opposed to `C:\Users\username\Documents` (R's default on Windows). Read more in [`fs::path_expand()`](https://fs.r-lib.org/reference/path_expand.html).

## Extending or wrapping usethis

These changes make it easier for others to extend usethis, i.e. to create workflow packages specific to their organization, or to use usethis in other packages.

* `proj_path()` is newly exported. Use it to build paths within the active project. Like `proj_get()` and `proj_set()`, it is not aimed at end users, but rather for use in extension packages. End users should use [rprojroot](https://rprojroot.r-lib.org) or its simpler companion, [here](https://here.r-lib.org), to programmatically detect a project and
build paths within it (#415, #425).

* `edit_file()`, `write_over()`, and `write_union()` are newly exported helpers. They are mostly for internal use, but can also be useful in packages that extend or customize usethis (#344, #366, #389).

* `use_template()` no longer errors when a user chooses not to overwrite an existing file and simply exits with confirmation that the file is unchanged (#348, #350, @boshek).

* `getOption("usethis.quiet", default = FALSE)` is consulted when printing user-facing messages. Set this option to `TRUE` to suppress output, e.g., to use usethis functions quietly in another package. For example, use `withr::local_options(list(usethis.quiet = TRUE))` in the calling function (#416, #424).

## New functions

* `proj_sitrep()` reports current working directory, the active usethis project, and the active RStudio Project. Call this function if things seem weird and you're not sure what's wrong or how to fix it. Designed for interactive use and debugging, not for programmatic use (#426).

* `use_tibble()` does minimum setup necessary for a package that returns or exports a tibble. For example, this guarantees a tibble will print as a tibble (#324 @martinjhnhadley).

* `use_logo()` resizes and adds a logo to a package (#358, @jimhester).

* `use_spell_check()` adds a whitelist of words and a unit test to spell check package documentation during `R CMD check` (#285 @jeroen).

## Other small changes and bug fixes

* usethis has a new logo! (#429)

* `use_course()` reports progress during download (#276, #380).

* `use_git()` only makes an initial commit of all files if user gives explicit consent (#378).

* `create_from_github()`: the `repo` argument is renamed to `repo_spec`, since it takes input of the form "OWNER/REPO" (#376).

* `use_depsy_badge()` is defunct. The Depsy project has officially concluded and is no longer being maintained (#354).

* `use_github()` fails earlier, with a more informative message, in the absence of a GitHub personal access token (PAT). Also looks for the PAT more proactively in the usual environment variables (i.e., GITHUB_PAT, GITHUB_TOKEN) (#320, #340, @cderv).

* The logic for setting DESCRIPTION fields in `create_package()` and `use_description()` got a Spring Cleaning. Fields directly specified by the user take precedence, then the named list in `getOption("usethis.description")` is consulted, and finally defaults built into usethis. `use_description_defaults()` is a new function that reveals fields found in options and built into usethis. Options specific to one DESCRIPTION field, e.g. `devtools.desc.license`, are no longer supported. Instead, use a single named list for all fields, preferably stored in an option named `"usethis.description"` (however,`"devtools.desc"` is still consulted for backwards compatibility). (#159, #233, #367)

## Dependency changes

New Imports: fs, glue, utils

No longer in Imports: backports, httr, rematch2, rmarkdown (moved to Suggests), styler (moved to Suggests)

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
