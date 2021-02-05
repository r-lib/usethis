# portalr

<details>

* Version: 0.3.6
* GitHub: https://github.com/weecology/portalr
* Source code: https://github.com/cran/portalr
* Date/Publication: 2020-11-23 19:00:02 UTC
* Number of recursive dependencies: 109

Run `cloud_details(, "portalr")` for more info

</details>

## Newly broken

*   checking tests ... ERROR
    ```
      Running 'testthat.R'
    Running the tests in 'tests/testthat.R' failed.
    Last 13 lines of output:
      ERROR (test-10-summarize_ants.R:6:3): colony_presence_absence returns expected results
      Warning (test-10-summarize_ants.R:21:3): bait_presence_absence returns expected results
      Warning (test-10-summarize_ants.R:21:3): bait_presence_absence returns expected results
      ERROR (test-10-summarize_ants.R:21:3): bait_presence_absence returns expected results
      Warning (test-10-summarize_ants.R:34:3): colony_presence_absence returns expected results
      Warning (test-10-summarize_ants.R:34:3): colony_presence_absence returns expected results
      ERROR (test-10-summarize_ants.R:34:3): colony_presence_absence returns expected results
      Warning (test-10-summarize_ants.R:49:3): bait_presence_absence returns expected results
      ERROR (test-10-summarize_ants.R:49:3): bait_presence_absence returns expected results
      Warning (test-11-phenocam.R:6:1): (code run outside of `test_that()`)
      ERROR (test-11-phenocam.R:6:1): (code run outside of `test_that()`)
      
      [ FAIL 13 | WARN 46 | SKIP 39 | PASS 15 ]
      Error: Test failures
      Execution halted
    ```

## In both

*   checking R files for syntax errors ... WARNING
    ```
    Warning in Sys.setlocale("LC_CTYPE", "en_US.UTF-8") :
      OS reports request to set locale to "en_US.UTF-8" cannot be honored
    ```

*   checking examples ... WARNING
    ```
    checking a package with encoding  'UTF-8'  in an ASCII locale
    ```

