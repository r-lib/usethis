# use_pipe(export = FALSE) adds roxygen to package doc

    Code
      roxygen_ns_show()
    Output
      [1] "#' @importFrom magrittr %>%"

# use_pipe() should produce a lifecycle deprecated warning

    Code
      create_local_package()
      use_package_doc()
      use_pipe(export = FALSE)
    Condition
      Warning:
      `use_pipe()` was deprecated in usethis 3.2.2.

