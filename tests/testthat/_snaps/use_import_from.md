# use_import_from() adds one line for each function

    Code
      roxygen_ns_show()
    Output
      [1] "#' @importFrom tibble deframe" "#' @importFrom tibble enframe"
      [3] "#' @importFrom tibble tibble" 

# use_import_from() generates helpful errors

    Code
      use_import_from(1)
    Condition
      Error:
      x `package` must be a single string.
    Code
      use_import_from(c("tibble", "rlang"))
    Condition
      Error:
      x `package` must be a single string.
    Code
      use_import_from("tibble", "pool_noodle")
    Condition
      Error in `map2()`:
      i In index: 1.
      Caused by error:
      x Can't find `tibble::pool_noodle()`.

