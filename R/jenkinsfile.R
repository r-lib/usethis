#' Create Jenkinsfile for Jenkins CI Pipelines
#'
#' `use_jenkinsfile()` adds a basic Jenkinsfile for R packages to the project
#' root directory. The Jenkinsfile stages take advantage of calls to `make`, and
#' so calling this function will also run `use_makefile()` if a Makefile does
#' not already exist at the project root.
#'
#' @seealso The [documentation on Jekins
#'   Pipelines](https://jenkins.io/doc/book/pipeline/jenkinsfile/).
#' @seealso [use_makefile()]
#' @export
use_jenkinsfile <- function() {
  if (!uses_makefile()) {
    use_makefile()
  }
  use_template(
    "Jenkinsfile",
    data = list(name = project_name())
  )
  use_build_ignore("Jenkinsfile")
}
