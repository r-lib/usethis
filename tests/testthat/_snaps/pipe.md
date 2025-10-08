# use_pipe(export = FALSE) adds roxygen to package doc

    Code
      roxygen_ns_show()
    Output
      [1] "#' @importFrom magrittr %>%"

# use_pipe() should produce a lifecycle deprecated warning

    Code
      use_pipe(export = FALSE)
    Condition
      Warning:
      `use_pipe()` was deprecated in usethis 3.2.2.
      i It is recommended to use the base R pipe |> in your package instead; it does not require an import.

