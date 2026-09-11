# Continuous integration setup and badges

**\[questioning\]**

These functions are not actively used by the tidyverse team, and may not
currently work. Use at your own risk.

Sets up third-party continuous integration (CI) services for an R
package on GitLab or CircleCI. These functions:

- Add service-specific configuration files and add them to
  `.Rbuildignore`.

- Activate a service or give the user a detailed prompt.

- Provide the markdown to insert a badge into README.

## Usage

``` r
use_gitlab_ci()

use_circleci(browse = rlang::is_interactive(), image = "rocker/verse:latest")

use_circleci_badge(repo_spec = NULL)
```

## Arguments

- browse:

  Open a browser window to enable automatic builds for the package.

- image:

  The Docker image to use for build. Must be available on
  [DockerHub](https://hub.docker.com). The
  [rocker/verse](https://hub.docker.com/r/rocker/verse) image includes
  TeXLive, pandoc, and the tidyverse packages. For a minimal image, try
  [rocker/r-ver](https://hub.docker.com/r/rocker/r-ver). To specify a
  version of R, change the tag from `latest` to the version you want,
  e.g. `rocker/r-ver:3.5.3`.

- repo_spec:

  Optional GitHub repo specification in this form: `owner/repo`. This
  can usually be inferred from the GitHub remotes of active project.

## `use_gitlab_ci()`

Adds a basic `.gitlab-ci.yml` to the top-level directory of a package.
This is a configuration file for the [GitLab
CI/CD](https://docs.gitlab.com/ee/ci/) continuous integration service.

## `use_circleci()`

Adds a basic `.circleci/config.yml` to the top-level directory of a
package. This is a configuration file for the
[CircleCI](https://circleci.com/) continuous integration service.

## `use_circleci_badge()`

Only adds the [Circle CI](https://circleci.com/) badge. Use for a
project where Circle CI is already configured.
