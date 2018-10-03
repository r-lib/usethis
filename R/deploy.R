#' Setup deployment for Travis CI
#'
#' Creates a public-private key pair,
#' adds the public key to the GitHub repository via [travis::github_add_key()],
#' and stores the private key as an encrypted environment variable in Travis CI
#' via [travis::travis_set_var()],
#' possibly in a different repository.
#' The \pkg{tic} companion package contains facilities for installing such a key
#' during a Travis CI build.
#'
#' @export
use_travis_deploy <- function() {

  check_installed("travis")
  check_installed("tic")
  check_installed("openssl")

  path <- proj_get()
  repo <- github_repo()

  # authenticate on github and travis and set up keys/vars

  # generate deploy key pair
  key <- openssl::rsa_keygen()

  # encrypt private key using tempkey and iv
  pub_key <- tic::get_public_key(key)
  private_key <- tic::encode_private_key(key)

  # add to GitHub first, because this can fail because of missing org permissions
  title <- glue("travis+tic for {repo}")
  travis::github_add_key(pub_key, title = title, path = path)

  travis::travis_set_var("id_rsa", private_key, public = FALSE, repo = path)

  message(glue("Successfully added private deploy key to {repo}",
               " as secure environment variable id_rsa to Travis CI."))

}
