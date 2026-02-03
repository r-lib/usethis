# Package index

## Create

Create a project *de novo* or from an existing source, either local or
remote

- [`create_package()`](https://usethis.r-lib.org/dev/reference/create_package.md)
  [`create_project()`](https://usethis.r-lib.org/dev/reference/create_package.md)
  [`create_quarto_project()`](https://usethis.r-lib.org/dev/reference/create_package.md)
  **\[experimental\]** : Create a package or project
- [`create_from_github()`](https://usethis.r-lib.org/dev/reference/create_from_github.md)
  : Create a project from a GitHub repo
- [`use_course()`](https://usethis.r-lib.org/dev/reference/zip-utils.md)
  [`use_zip()`](https://usethis.r-lib.org/dev/reference/zip-utils.md) :
  Download and unpack a ZIP file

## Active project

Query or set the project targeted by usethis functions that don’t take a
path

- [`proj_activate()`](https://usethis.r-lib.org/dev/reference/proj_activate.md)
  : Activate a project
- [`proj_sitrep()`](https://usethis.r-lib.org/dev/reference/proj_sitrep.md)
  : Report working directory and usethis/RStudio project
- [`proj_get()`](https://usethis.r-lib.org/dev/reference/proj_utils.md)
  [`proj_set()`](https://usethis.r-lib.org/dev/reference/proj_utils.md)
  [`proj_path()`](https://usethis.r-lib.org/dev/reference/proj_utils.md)
  [`with_project()`](https://usethis.r-lib.org/dev/reference/proj_utils.md)
  [`local_project()`](https://usethis.r-lib.org/dev/reference/proj_utils.md)
  : Utility functions for the active project

## Package development

Add or modify files typically found in R packages

- [`use_data()`](https://usethis.r-lib.org/dev/reference/use_data.md)
  [`use_data_raw()`](https://usethis.r-lib.org/dev/reference/use_data.md)
  : Create package data

- [`use_package()`](https://usethis.r-lib.org/dev/reference/use_package.md)
  [`use_dev_package()`](https://usethis.r-lib.org/dev/reference/use_package.md)
  : Depend on another package

- [`use_import_from()`](https://usethis.r-lib.org/dev/reference/use_import_from.md)
  : Import a function from another package

- [`use_r()`](https://usethis.r-lib.org/dev/reference/use_r.md)
  [`use_test()`](https://usethis.r-lib.org/dev/reference/use_r.md) :
  Create or edit R or test files

- [`use_rmarkdown_template()`](https://usethis.r-lib.org/dev/reference/use_rmarkdown_template.md)
  : Add an RMarkdown Template

- [`use_spell_check()`](https://usethis.r-lib.org/dev/reference/use_spell_check.md)
  : Use spell check

- [`use_test_helper()`](https://usethis.r-lib.org/dev/reference/use_test_helper.md)
  : Create or edit a test helper file

- [`use_vignette()`](https://usethis.r-lib.org/dev/reference/use_vignette.md)
  [`use_article()`](https://usethis.r-lib.org/dev/reference/use_vignette.md)
  : Create a vignette or article

- [`use_addin()`](https://usethis.r-lib.org/dev/reference/use_addin.md)
  : Add minimal RStudio Addin binding

- [`use_citation()`](https://usethis.r-lib.org/dev/reference/use_citation.md)
  : Create a CITATION template

- [`use_tutorial()`](https://usethis.r-lib.org/dev/reference/use_tutorial.md)
  : Create a learnr tutorial

- [`use_author()`](https://usethis.r-lib.org/dev/reference/use_author.md)
  :

  Add an author to the `Authors@R` field in DESCRIPTION

## Package setup

Package setup tasks, typically performed once.

- [`create_package()`](https://usethis.r-lib.org/dev/reference/create_package.md)
  [`create_project()`](https://usethis.r-lib.org/dev/reference/create_package.md)
  [`create_quarto_project()`](https://usethis.r-lib.org/dev/reference/create_package.md)
  **\[experimental\]** : Create a package or project

- [`use_data_table()`](https://usethis.r-lib.org/dev/reference/use_data_table.md)
  : Prepare for importing data.table

- [`use_description()`](https://usethis.r-lib.org/dev/reference/use_description.md)
  [`use_description_defaults()`](https://usethis.r-lib.org/dev/reference/use_description.md)
  : Create or modify a DESCRIPTION file

- [`use_mit_license()`](https://usethis.r-lib.org/dev/reference/licenses.md)
  [`use_gpl_license()`](https://usethis.r-lib.org/dev/reference/licenses.md)
  [`use_agpl_license()`](https://usethis.r-lib.org/dev/reference/licenses.md)
  [`use_lgpl_license()`](https://usethis.r-lib.org/dev/reference/licenses.md)
  [`use_apache_license()`](https://usethis.r-lib.org/dev/reference/licenses.md)
  [`use_cc0_license()`](https://usethis.r-lib.org/dev/reference/licenses.md)
  [`use_ccby_license()`](https://usethis.r-lib.org/dev/reference/licenses.md)
  [`use_proprietary_license()`](https://usethis.r-lib.org/dev/reference/licenses.md)
  : License a package

- [`use_namespace()`](https://usethis.r-lib.org/dev/reference/use_namespace.md)
  :

  Use a basic `NAMESPACE`

- [`use_coverage()`](https://usethis.r-lib.org/dev/reference/use_coverage.md)
  [`use_covr_ignore()`](https://usethis.r-lib.org/dev/reference/use_coverage.md)
  : Test coverage

- [`edit_r_profile()`](https://usethis.r-lib.org/dev/reference/edit.md)
  [`edit_r_environ()`](https://usethis.r-lib.org/dev/reference/edit.md)
  [`edit_r_buildignore()`](https://usethis.r-lib.org/dev/reference/edit.md)
  [`edit_r_makevars()`](https://usethis.r-lib.org/dev/reference/edit.md)
  [`edit_rstudio_snippets()`](https://usethis.r-lib.org/dev/reference/edit.md)
  [`edit_rstudio_prefs()`](https://usethis.r-lib.org/dev/reference/edit.md)
  [`edit_git_config()`](https://usethis.r-lib.org/dev/reference/edit.md)
  [`edit_git_ignore()`](https://usethis.r-lib.org/dev/reference/edit.md)
  [`edit_pkgdown_config()`](https://usethis.r-lib.org/dev/reference/edit.md)
  : Open configuration files

- [`use_build_ignore()`](https://usethis.r-lib.org/dev/reference/use_build_ignore.md)
  :

  Add files to `.Rbuildignore`

- [`use_cpp11()`](https://usethis.r-lib.org/dev/reference/use_cpp11.md)
  : Use C++ via the cpp11 package

- [`use_make()`](https://usethis.r-lib.org/dev/reference/use_make.md) :
  Create Makefile

- [`use_rcpp()`](https://usethis.r-lib.org/dev/reference/use_rcpp.md)
  [`use_rcpp_armadillo()`](https://usethis.r-lib.org/dev/reference/use_rcpp.md)
  [`use_rcpp_eigen()`](https://usethis.r-lib.org/dev/reference/use_rcpp.md)
  [`use_c()`](https://usethis.r-lib.org/dev/reference/use_rcpp.md) : Use
  C, C++, RcppArmadillo, or RcppEigen

- [`use_tibble()`](https://usethis.r-lib.org/dev/reference/use_tibble.md)
  **\[questioning\]** : Prepare to return a tibble

- [`use_tidy_github_actions()`](https://usethis.r-lib.org/dev/reference/tidyverse.md)
  [`create_tidy_package()`](https://usethis.r-lib.org/dev/reference/tidyverse.md)
  [`use_tidy_description()`](https://usethis.r-lib.org/dev/reference/tidyverse.md)
  [`use_tidy_dependencies()`](https://usethis.r-lib.org/dev/reference/tidyverse.md)
  [`use_tidy_contributing()`](https://usethis.r-lib.org/dev/reference/tidyverse.md)
  [`use_tidy_support()`](https://usethis.r-lib.org/dev/reference/tidyverse.md)
  [`use_tidy_issue_template()`](https://usethis.r-lib.org/dev/reference/tidyverse.md)
  [`use_tidy_coc()`](https://usethis.r-lib.org/dev/reference/tidyverse.md)
  [`use_tidy_github()`](https://usethis.r-lib.org/dev/reference/tidyverse.md)
  [`use_tidy_logo()`](https://usethis.r-lib.org/dev/reference/tidyverse.md)
  [`use_tidy_upkeep_issue()`](https://usethis.r-lib.org/dev/reference/tidyverse.md)
  : Helpers for tidyverse development

- [`use_logo()`](https://usethis.r-lib.org/dev/reference/use_logo.md) :
  Use a package logo

- [`use_news_md()`](https://usethis.r-lib.org/dev/reference/use_news_md.md)
  :

  Create a simple `NEWS.md`

- [`use_package_doc()`](https://usethis.r-lib.org/dev/reference/use_package_doc.md)
  : Package-level documentation

- [`use_roxygen_md()`](https://usethis.r-lib.org/dev/reference/use_roxygen_md.md)
  : Use roxygen2 with markdown

- [`use_readme_rmd()`](https://usethis.r-lib.org/dev/reference/use_readme_rmd.md)
  [`use_readme_md()`](https://usethis.r-lib.org/dev/reference/use_readme_rmd.md)
  : Create README files

- [`use_badge()`](https://usethis.r-lib.org/dev/reference/badges.md)
  [`use_cran_badge()`](https://usethis.r-lib.org/dev/reference/badges.md)
  [`use_bioc_badge()`](https://usethis.r-lib.org/dev/reference/badges.md)
  [`use_lifecycle_badge()`](https://usethis.r-lib.org/dev/reference/badges.md)
  [`use_binder_badge()`](https://usethis.r-lib.org/dev/reference/badges.md)
  [`use_r_universe_badge()`](https://usethis.r-lib.org/dev/reference/badges.md)
  [`use_posit_cloud_badge()`](https://usethis.r-lib.org/dev/reference/badges.md)
  : README badges

- [`use_gitlab_ci()`](https://usethis.r-lib.org/dev/reference/use_gitlab_ci.md)
  [`use_circleci()`](https://usethis.r-lib.org/dev/reference/use_gitlab_ci.md)
  [`use_circleci_badge()`](https://usethis.r-lib.org/dev/reference/use_gitlab_ci.md)
  **\[questioning\]** : Continuous integration setup and badges

- [`use_pkgdown()`](https://usethis.r-lib.org/dev/reference/use_pkgdown.md)
  [`use_pkgdown_github_pages()`](https://usethis.r-lib.org/dev/reference/use_pkgdown.md)
  : Use pkgdown

- [`use_github_links()`](https://usethis.r-lib.org/dev/reference/use_github_links.md)
  : Use GitHub links in URL and BugReports

- [`use_lifecycle()`](https://usethis.r-lib.org/dev/reference/use_lifecycle.md)
  : Use lifecycle badges

- [`use_standalone()`](https://usethis.r-lib.org/dev/reference/use_standalone.md)
  : Use a standalone file from another repo

- [`use_testthat()`](https://usethis.r-lib.org/dev/reference/use_testthat.md)
  : Sets up overall testing infrastructure

- [`use_air()`](https://usethis.r-lib.org/dev/reference/use_air.md) :
  Configure a project to use Air

- [`use_claude_code()`](https://usethis.r-lib.org/dev/reference/use_claude_code.md)
  **\[experimental\]** : Configure a project to use Claude Code

## Package release

- [`use_cran_comments()`](https://usethis.r-lib.org/dev/reference/use_cran_comments.md)
  : CRAN submission comments
- [`use_github_release()`](https://usethis.r-lib.org/dev/reference/use_github_release.md)
  : Publish a GitHub release
- [`use_release_issue()`](https://usethis.r-lib.org/dev/reference/use_release_issue.md)
  : Create a release checklist in a GitHub issue
- [`use_revdep()`](https://usethis.r-lib.org/dev/reference/use_revdep.md)
  : Reverse dependency checks
- [`use_version()`](https://usethis.r-lib.org/dev/reference/use_version.md)
  [`use_dev_version()`](https://usethis.r-lib.org/dev/reference/use_version.md)
  : Increment package version

## Continuous integration

- [`use_github_action()`](https://usethis.r-lib.org/dev/reference/use_github_action.md)
  **\[experimental\]** : Set up a GitHub Actions workflow
- [`use_gitlab_ci()`](https://usethis.r-lib.org/dev/reference/use_gitlab_ci.md)
  [`use_circleci()`](https://usethis.r-lib.org/dev/reference/use_gitlab_ci.md)
  [`use_circleci_badge()`](https://usethis.r-lib.org/dev/reference/use_gitlab_ci.md)
  **\[questioning\]** : Continuous integration setup and badges
- [`use_jenkins()`](https://usethis.r-lib.org/dev/reference/use_jenkins.md)
  : Create Jenkinsfile for Jenkins CI Pipelines

## Tidyverse development

Conventions used in the tidyverse and r-lib organisations

- [`use_tidy_github_actions()`](https://usethis.r-lib.org/dev/reference/tidyverse.md)
  [`create_tidy_package()`](https://usethis.r-lib.org/dev/reference/tidyverse.md)
  [`use_tidy_description()`](https://usethis.r-lib.org/dev/reference/tidyverse.md)
  [`use_tidy_dependencies()`](https://usethis.r-lib.org/dev/reference/tidyverse.md)
  [`use_tidy_contributing()`](https://usethis.r-lib.org/dev/reference/tidyverse.md)
  [`use_tidy_support()`](https://usethis.r-lib.org/dev/reference/tidyverse.md)
  [`use_tidy_issue_template()`](https://usethis.r-lib.org/dev/reference/tidyverse.md)
  [`use_tidy_coc()`](https://usethis.r-lib.org/dev/reference/tidyverse.md)
  [`use_tidy_github()`](https://usethis.r-lib.org/dev/reference/tidyverse.md)
  [`use_tidy_logo()`](https://usethis.r-lib.org/dev/reference/tidyverse.md)
  [`use_tidy_upkeep_issue()`](https://usethis.r-lib.org/dev/reference/tidyverse.md)
  : Helpers for tidyverse development
- [`use_github_labels()`](https://usethis.r-lib.org/dev/reference/use_github_labels.md)
  [`use_tidy_github_labels()`](https://usethis.r-lib.org/dev/reference/use_github_labels.md)
  [`tidy_labels()`](https://usethis.r-lib.org/dev/reference/use_github_labels.md)
  [`tidy_labels_rename()`](https://usethis.r-lib.org/dev/reference/use_github_labels.md)
  [`tidy_label_colours()`](https://usethis.r-lib.org/dev/reference/use_github_labels.md)
  [`tidy_label_descriptions()`](https://usethis.r-lib.org/dev/reference/use_github_labels.md)
  : Manage GitHub issue labels
- [`use_tidy_thanks()`](https://usethis.r-lib.org/dev/reference/use_tidy_thanks.md)
  : Identify contributors via GitHub activity

## Configuration

Configure the behaviour of R or RStudio or usethis, globally as a user
or for a specific project

- [`usethis_options`](https://usethis.r-lib.org/dev/reference/usethis_options.md)
  : Options consulted by usethis

- [`ui_silence()`](https://usethis.r-lib.org/dev/reference/ui_silence.md)
  : Suppress usethis's messaging

- [`use_blank_slate()`](https://usethis.r-lib.org/dev/reference/use_blank_slate.md)
  : Don't save/load user workspace between sessions

- [`use_conflicted()`](https://usethis.r-lib.org/dev/reference/rprofile-helper.md)
  [`use_reprex()`](https://usethis.r-lib.org/dev/reference/rprofile-helper.md)
  [`use_usethis()`](https://usethis.r-lib.org/dev/reference/rprofile-helper.md)
  [`use_devtools()`](https://usethis.r-lib.org/dev/reference/rprofile-helper.md)
  [`use_partial_warnings()`](https://usethis.r-lib.org/dev/reference/rprofile-helper.md)
  :

  Helpers to make useful changes to `.Rprofile`

- [`edit_r_profile()`](https://usethis.r-lib.org/dev/reference/edit.md)
  [`edit_r_environ()`](https://usethis.r-lib.org/dev/reference/edit.md)
  [`edit_r_buildignore()`](https://usethis.r-lib.org/dev/reference/edit.md)
  [`edit_r_makevars()`](https://usethis.r-lib.org/dev/reference/edit.md)
  [`edit_rstudio_snippets()`](https://usethis.r-lib.org/dev/reference/edit.md)
  [`edit_rstudio_prefs()`](https://usethis.r-lib.org/dev/reference/edit.md)
  [`edit_git_config()`](https://usethis.r-lib.org/dev/reference/edit.md)
  [`edit_git_ignore()`](https://usethis.r-lib.org/dev/reference/edit.md)
  [`edit_pkgdown_config()`](https://usethis.r-lib.org/dev/reference/edit.md)
  : Open configuration files

## Git and GitHub

- [`create_from_github()`](https://usethis.r-lib.org/dev/reference/create_from_github.md)
  : Create a project from a GitHub repo
- [`use_git()`](https://usethis.r-lib.org/dev/reference/use_git.md) :
  Initialise a git repository
- [`use_github()`](https://usethis.r-lib.org/dev/reference/use_github.md)
  : Connect a local repo with GitHub
- [`use_github_action()`](https://usethis.r-lib.org/dev/reference/use_github_action.md)
  **\[experimental\]** : Set up a GitHub Actions workflow
- [`use_github_file()`](https://usethis.r-lib.org/dev/reference/use_github_file.md)
  : Copy a file from any GitHub repo into the current project
- [`use_github_labels()`](https://usethis.r-lib.org/dev/reference/use_github_labels.md)
  [`use_tidy_github_labels()`](https://usethis.r-lib.org/dev/reference/use_github_labels.md)
  [`tidy_labels()`](https://usethis.r-lib.org/dev/reference/use_github_labels.md)
  [`tidy_labels_rename()`](https://usethis.r-lib.org/dev/reference/use_github_labels.md)
  [`tidy_label_colours()`](https://usethis.r-lib.org/dev/reference/use_github_labels.md)
  [`tidy_label_descriptions()`](https://usethis.r-lib.org/dev/reference/use_github_labels.md)
  : Manage GitHub issue labels
- [`use_github_links()`](https://usethis.r-lib.org/dev/reference/use_github_links.md)
  : Use GitHub links in URL and BugReports
- [`use_github_pages()`](https://usethis.r-lib.org/dev/reference/use_github_pages.md)
  : Configure a GitHub Pages site
- [`use_github_release()`](https://usethis.r-lib.org/dev/reference/use_github_release.md)
  : Publish a GitHub release
- [`git_sitrep()`](https://usethis.r-lib.org/dev/reference/git_sitrep.md)
  : Git/GitHub sitrep
- [`create_github_token()`](https://usethis.r-lib.org/dev/reference/github-token.md)
  [`gh_token_help()`](https://usethis.r-lib.org/dev/reference/github-token.md)
  : Get help with GitHub personal access tokens
- [`git_vaccinate()`](https://usethis.r-lib.org/dev/reference/git_vaccinate.md)
  : Vaccinate your global gitignore file
- [`use_git_config()`](https://usethis.r-lib.org/dev/reference/use_git_config.md)
  : Configure Git
- [`use_git_ignore()`](https://usethis.r-lib.org/dev/reference/use_git_ignore.md)
  : Tell Git to ignore files
- [`git_protocol()`](https://usethis.r-lib.org/dev/reference/git_protocol.md)
  [`use_git_protocol()`](https://usethis.r-lib.org/dev/reference/git_protocol.md)
  : See or set the default Git protocol
- [`use_git_remote()`](https://usethis.r-lib.org/dev/reference/use_git_remote.md)
  [`git_remotes()`](https://usethis.r-lib.org/dev/reference/use_git_remote.md)
  : Configure and report Git remotes
- [`use_git_hook()`](https://usethis.r-lib.org/dev/reference/use_git_hook.md)
  : Add a git hook
- [`use_code_of_conduct()`](https://usethis.r-lib.org/dev/reference/use_code_of_conduct.md)
  : Add a code of conduct
- [`use_readme_rmd()`](https://usethis.r-lib.org/dev/reference/use_readme_rmd.md)
  [`use_readme_md()`](https://usethis.r-lib.org/dev/reference/use_readme_rmd.md)
  : Create README files
- [`git_default_branch()`](https://usethis.r-lib.org/dev/reference/git-default-branch.md)
  [`git_default_branch_configure()`](https://usethis.r-lib.org/dev/reference/git-default-branch.md)
  [`git_default_branch_rediscover()`](https://usethis.r-lib.org/dev/reference/git-default-branch.md)
  [`git_default_branch_rename()`](https://usethis.r-lib.org/dev/reference/git-default-branch.md)
  : Get or set the default Git branch
- [`browse_package()`](https://usethis.r-lib.org/dev/reference/browse-this.md)
  [`browse_project()`](https://usethis.r-lib.org/dev/reference/browse-this.md)
  [`browse_github()`](https://usethis.r-lib.org/dev/reference/browse-this.md)
  [`browse_github_issues()`](https://usethis.r-lib.org/dev/reference/browse-this.md)
  [`browse_github_pulls()`](https://usethis.r-lib.org/dev/reference/browse-this.md)
  [`browse_github_actions()`](https://usethis.r-lib.org/dev/reference/browse-this.md)
  [`browse_circleci()`](https://usethis.r-lib.org/dev/reference/browse-this.md)
  [`browse_cran()`](https://usethis.r-lib.org/dev/reference/browse-this.md)
  : Visit important project-related web pages
- [`edit_r_profile()`](https://usethis.r-lib.org/dev/reference/edit.md)
  [`edit_r_environ()`](https://usethis.r-lib.org/dev/reference/edit.md)
  [`edit_r_buildignore()`](https://usethis.r-lib.org/dev/reference/edit.md)
  [`edit_r_makevars()`](https://usethis.r-lib.org/dev/reference/edit.md)
  [`edit_rstudio_snippets()`](https://usethis.r-lib.org/dev/reference/edit.md)
  [`edit_rstudio_prefs()`](https://usethis.r-lib.org/dev/reference/edit.md)
  [`edit_git_config()`](https://usethis.r-lib.org/dev/reference/edit.md)
  [`edit_git_ignore()`](https://usethis.r-lib.org/dev/reference/edit.md)
  [`edit_pkgdown_config()`](https://usethis.r-lib.org/dev/reference/edit.md)
  : Open configuration files
- [`issue_close_community()`](https://usethis.r-lib.org/dev/reference/issue-this.md)
  [`issue_reprex_needed()`](https://usethis.r-lib.org/dev/reference/issue-this.md)
  : Helpers for GitHub issues
- [`use_tidy_github_actions()`](https://usethis.r-lib.org/dev/reference/tidyverse.md)
  [`create_tidy_package()`](https://usethis.r-lib.org/dev/reference/tidyverse.md)
  [`use_tidy_description()`](https://usethis.r-lib.org/dev/reference/tidyverse.md)
  [`use_tidy_dependencies()`](https://usethis.r-lib.org/dev/reference/tidyverse.md)
  [`use_tidy_contributing()`](https://usethis.r-lib.org/dev/reference/tidyverse.md)
  [`use_tidy_support()`](https://usethis.r-lib.org/dev/reference/tidyverse.md)
  [`use_tidy_issue_template()`](https://usethis.r-lib.org/dev/reference/tidyverse.md)
  [`use_tidy_coc()`](https://usethis.r-lib.org/dev/reference/tidyverse.md)
  [`use_tidy_github()`](https://usethis.r-lib.org/dev/reference/tidyverse.md)
  [`use_tidy_logo()`](https://usethis.r-lib.org/dev/reference/tidyverse.md)
  [`use_tidy_upkeep_issue()`](https://usethis.r-lib.org/dev/reference/tidyverse.md)
  : Helpers for tidyverse development
- [`use_release_issue()`](https://usethis.r-lib.org/dev/reference/use_release_issue.md)
  : Create a release checklist in a GitHub issue
- [`use_upkeep_issue()`](https://usethis.r-lib.org/dev/reference/use_upkeep_issue.md)
  : Create an upkeep checklist in a GitHub issue

## Pull requests

- [`pr_init()`](https://usethis.r-lib.org/dev/reference/pull-requests.md)
  [`pr_resume()`](https://usethis.r-lib.org/dev/reference/pull-requests.md)
  [`pr_fetch()`](https://usethis.r-lib.org/dev/reference/pull-requests.md)
  [`pr_push()`](https://usethis.r-lib.org/dev/reference/pull-requests.md)
  [`pr_pull()`](https://usethis.r-lib.org/dev/reference/pull-requests.md)
  [`pr_merge_main()`](https://usethis.r-lib.org/dev/reference/pull-requests.md)
  [`pr_view()`](https://usethis.r-lib.org/dev/reference/pull-requests.md)
  [`pr_pause()`](https://usethis.r-lib.org/dev/reference/pull-requests.md)
  [`pr_finish()`](https://usethis.r-lib.org/dev/reference/pull-requests.md)
  [`pr_forget()`](https://usethis.r-lib.org/dev/reference/pull-requests.md)
  : Helpers for GitHub pull requests

## Edit

- [`edit_r_profile()`](https://usethis.r-lib.org/dev/reference/edit.md)
  [`edit_r_environ()`](https://usethis.r-lib.org/dev/reference/edit.md)
  [`edit_r_buildignore()`](https://usethis.r-lib.org/dev/reference/edit.md)
  [`edit_r_makevars()`](https://usethis.r-lib.org/dev/reference/edit.md)
  [`edit_rstudio_snippets()`](https://usethis.r-lib.org/dev/reference/edit.md)
  [`edit_rstudio_prefs()`](https://usethis.r-lib.org/dev/reference/edit.md)
  [`edit_git_config()`](https://usethis.r-lib.org/dev/reference/edit.md)
  [`edit_git_ignore()`](https://usethis.r-lib.org/dev/reference/edit.md)
  [`edit_pkgdown_config()`](https://usethis.r-lib.org/dev/reference/edit.md)
  : Open configuration files

- [`rename_files()`](https://usethis.r-lib.org/dev/reference/rename_files.md)
  :

  Automatically rename paired `R/` and `test/` files

## Browse

- [`browse_package()`](https://usethis.r-lib.org/dev/reference/browse-this.md)
  [`browse_project()`](https://usethis.r-lib.org/dev/reference/browse-this.md)
  [`browse_github()`](https://usethis.r-lib.org/dev/reference/browse-this.md)
  [`browse_github_issues()`](https://usethis.r-lib.org/dev/reference/browse-this.md)
  [`browse_github_pulls()`](https://usethis.r-lib.org/dev/reference/browse-this.md)
  [`browse_github_actions()`](https://usethis.r-lib.org/dev/reference/browse-this.md)
  [`browse_circleci()`](https://usethis.r-lib.org/dev/reference/browse-this.md)
  [`browse_cran()`](https://usethis.r-lib.org/dev/reference/browse-this.md)
  : Visit important project-related web pages

## Helpers

These functions are mostly for internal use. But they are useful for
those who wish to offer usethis-like support for, e.g., workflows
specific to an organisation.

- [`use_template()`](https://usethis.r-lib.org/dev/reference/use_template.md)
  : Use a usethis-style template
- [`use_directory()`](https://usethis.r-lib.org/dev/reference/use_directory.md)
  : Use a directory
- [`use_rmarkdown_template()`](https://usethis.r-lib.org/dev/reference/use_rmarkdown_template.md)
  : Add an RMarkdown Template
- [`use_rstudio()`](https://usethis.r-lib.org/dev/reference/use_rstudio.md)
  : Add RStudio Project infrastructure
- [`use_rstudio_preferences()`](https://usethis.r-lib.org/dev/reference/use_rstudio_preferences.md)
  : Set global RStudio preferences

## Deprecated functions

- [`use_tidy_style()`](https://usethis.r-lib.org/dev/reference/tidy-deprecated.md)
  **\[deprecated\]** : Deprecated tidyverse functions
