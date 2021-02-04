#' @section Git/GitHub Authentication:

#' Many usethis functions, including those documented here, potentially interact
#' with GitHub in two different ways:

#' * Via the GitHub REST API. Examples: create a repo, a fork, or a pull
#' request.

#' * As a conventional Git remote. Examples: clone, fetch, or push.
#'

#' Therefore two types of auth can happen and your credentials must be
#' discoverable. Which credentials do we mean?
#'

#' * A GitHub personal access token (PAT) must be discoverable by the gh
#'   package, which is used for GitHub operations via the REST API. See
#'   [gh_token_help()] for more about getting and configuring a PAT.

#' * If you use the HTTPS protocol for Git remotes, your PAT is also used for
#'   Git operations, such as `git push`. Usethis uses the gert package for this,
#'   so the PAT must be discoverable by gert. Generally gert and gh will
#'   discover and use the same PAT. This ability to "kill two birds with one
#'   stone" is why HTTPS + PAT is our recommended auth strategy for those new
#'   to Git and GitHub and PRs.
#' * If you use SSH remotes, your SSH keys must also be discoverable, in
#'   addition to your PAT. The public key must be added to your GitHub account.
#'
#' Git/GitHub credential management is covered in a dedicated article:
#' [Managing Git(Hub) Credentials](https://usethis.r-lib.org/articles/articles/git-credentials.html)
