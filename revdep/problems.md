# badger

<details>

* Version: 0.2.4
* GitHub: https://github.com/GuangchuangYu/badger
* Source code: https://github.com/cran/badger
* Date/Publication: 2024-06-08 10:20:02 UTC
* Number of recursive dependencies: 64

Run `revdepcheck::cloud_details(, "badger")` for more info

</details>

## Newly broken

*   checking dependencies in R code ... WARNING
    ```
    Missing or unexported object: ‘usethis::git_branch_default’
    ```

# fusen

<details>

* Version: 0.7.1
* GitHub: https://github.com/Thinkr-open/fusen
* Source code: https://github.com/cran/fusen
* Date/Publication: 2025-01-26 07:10:02 UTC
* Number of recursive dependencies: 110

Run `revdepcheck::cloud_details(, "fusen")` for more info

</details>

## Newly broken

*   checking tests ... ERROR
    ```
      Running ‘testthat.R’
    Running the tests in ‘tests/testthat.R’ failed.
    Complete output:
      > # This file is part of the standard setup for testthat.
      > # It is recommended that you do not modify it.
      > #
      > # Where should you do additional test configuration?
      > # Learn more about the roles of various files in:
      > # * https://r-pkgs.org/testing-design.html#sec-tests-files-overview
      > # * https://testthat.r-lib.org/articles/special-files.html
    ...
       14.           └─rlang::abort(...)
      ── Failure ('test-create_fusen_rsproject.R:142:3'): Can create in a subdirectory ──
      dir.exists(dummysubdir) is not TRUE
      
      `actual`:   FALSE
      `expected`: TRUE 
      
      [ FAIL 2 | WARN 2 | SKIP 14 | PASS 984 ]
      Error: Test failures
      Execution halted
    ```

