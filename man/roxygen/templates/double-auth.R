#' @section Authentication:
#' This function potentially interacts with GitHub in two different ways:
#' * via the GitHub REST API
#' * as a conventional Git remote
#'
#' Therefore two types of auth happen.
#'

#' To create a new repo on GitHub, we **must** call the GitHub REST API, i.e.
#' this isn't one of the standard remote Git operations. Therefore you must make
#' a GitHub personal access token (PAT) available. See [gh_token_help()] for
#' advice on getting and storing your token.
#'

#' When we clone or pull from GitHub or push to it, depending on the protocol
#' (HTTPS vs. SSH) and the privacy of the repo, we may also need regular Git
#' credentials, just like we'd need with command line Git.
#'
#' We highly recommend using the HTTPS protocol, unless you have a specific
#' preference for SSH. If you are an "HTTPS person", your GitHub PAT (see above)
#' can also be used to authorize standard Git remote operations. Therefore, once
#' you've configured your PAT, your setup is complete!
#'

#' But what if you prefer the SSH protocol? usethis uses the gert package for
#' Git operations and gert, in turn, relies on the credentials package for auth:
#' * <https://docs.ropensci.org/gert>
#' * <https://docs.ropensci.org/credentials/>
#'

#' In usethis v2.0.0, we switched from git2r to gert + credentials. The main
#' motivation is to provide a smoother user experience by discovering and using
#' the same credentials as command line Git (and, therefore, the same as
#' RStudio). The credentials package *should* automatically discover your SSH
#' keys. This works so well that we have removed all credential-handling
#' workarounds from usethis. If you have credential problems, focus your
#' troubleshooting on getting the credentials package to find your SSH keys. Its
#' [introductory
#' vignette](https://cran.r-project.org/web/packages/credentials/vignettes/intro.html)
#' is a good place to start.
