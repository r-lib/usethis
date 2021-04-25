if (require(testthat)) {
  library({{{ name }}})

  test_check("{{{ name }}}")
} else
  warning("'{{{ name }}}' requires 'testthat' for tests")
