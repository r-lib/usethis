# use_import_from() errors if function not found

    Code
      use_import_from("tibble", "pool_noodle")
    Error <usethis_error>
      Can't find `tibble::pool_noodle()`

# use_import_from() errors if more than one package

    Code
      use_import_from(c("tibble", "rlang"), c("tibble", "abort"))
    Error <simpleError>
      isTRUE(length(package) == 1) is not TRUE

