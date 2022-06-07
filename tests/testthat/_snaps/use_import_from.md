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
      ! `package` must be a single string
    Code
      use_import_from(c("tibble", "rlang"))
    Condition
      Error:
      ! `package` must be a single string
    Code
      use_import_from("tibble", "pool_noodle")
    Condition
      Error:
      ! Can't find `tibble::pool_noodle()`

