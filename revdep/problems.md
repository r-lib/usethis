# exampletestr

Version: 1.4.1

## Newly broken

*   checking tests ...
    ```
     ERROR
    Running the tests in ‘tests/testthat.R’ failed.
    Last 13 lines of output:
      more 'from' files than 'to' files
      1: expect_true(all(file.copy(system.file("extdata", c("detect.R", "match.R"), package = "exampletestr"), 
             "R"))) at testthat/test-exemplar.R:211
      2: quasi_label(enquo(object), label)
      3: eval_bare(get_expr(quo), get_env(quo))
      4: file.copy(system.file("extdata", c("detect.R", "match.R"), package = "exampletestr"), 
             "R")
      5: stop("more 'from' files than 'to' files")
      
      ══ testthat results  ═══════════════════════════════════════════════════════════
      OK: 21 SKIPPED: 0 FAILED: 1
      1. Error: `make_tests_shells_file()` works (@test-exemplar.R#211) 
      
      Error: testthat unit tests failed
      Execution halted
    ```

