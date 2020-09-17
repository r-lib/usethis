#' Create Jenkinsfile for Jenkins CI Pipelines
#'
#' `use_jenkins()` adds a basic Jenkinsfile for R packages to the project root
#' directory. The Jenkinsfile stages take advantage of calls to `make`, and so
#' calling this function will also run `use_make()` if a Makefile does not
#' already exist at the project root.
#'
#' @seealso The [documentation on Jenkins
#'   Pipelines](https://www.jenkins.io/doc/book/pipeline/jenkinsfile/).
#' @seealso [use_make()]
#' @export
use_jenkins <- function() {
  use_make()
  use_template(
    "Jenkinsfile",
    data = list(name = project_name())
  )
  use_build_ignore("Jenkinsfile")
}
