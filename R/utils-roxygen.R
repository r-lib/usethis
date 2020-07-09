# functions to help reduce duplication and increase consistency in the docs

# repo_spec ----
param_repo_spec <- function(...) {
  template <- glue("
    @param repo_spec \\
    Optional GitHub repo specification in this form: `owner/repo`. \\
    This can usually be inferred from the GitHub remotes of active \\
    project.
    ")
  dots <- list2(...)
  if (length(dots) > 0) {
    template <- c(template, dots)
  }
  glue_collapse(template, sep = " ")
}
