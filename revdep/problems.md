# circle

<details>

* Version: 0.7.2
* GitHub: https://github.com/ropensci/circle
* Source code: https://github.com/cran/circle
* Date/Publication: 2022-08-24 07:50:02 UTC
* Number of recursive dependencies: 76

Run `revdepcheck::cloud_details(, "circle")` for more info

</details>

## Newly broken

*   checking dependencies in R code ... WARNING
    ```
    Missing or unexported object: ‘usethis::github_token’
    ```

## In both

*   checking running R code from vignettes ... ERROR
    ```
    Errors in running code in vignettes:
    when running code in ‘circle.Rmd’
      ...
    
    > knitr::opts_chunk$set(collapse = TRUE, comment = "#>")
    
    > knitr::include_graphics("../man/figures/user-key.png")
    
      When sourcing ‘circle.R’:
    Error: Cannot find the file(s): "../man/figures/user-key.png"
    Execution halted
    
      ‘circle.Rmd’ using ‘UTF-8’... failed
      ‘tic.Rmd’ using ‘UTF-8’... OK
    ```

# exampletestr

<details>

* Version: 1.7.1
* GitHub: https://github.com/rorynolan/exampletestr
* Source code: https://github.com/cran/exampletestr
* Date/Publication: 2023-06-11 03:10:02 UTC
* Number of recursive dependencies: 97

Run `revdepcheck::cloud_details(, "exampletestr")` for more info

</details>

## Newly broken

*   checking tests ... ERROR
    ```
      Running ‘spelling.R’
      Running ‘testthat.R’
    Running the tests in ‘tests/testthat.R’ failed.
    Complete output:
      > library(testthat)
      > library(exampletestr)
      > 
      > get_os <- function() {
      +   sysinf <- Sys.info()
      +   if (!is.null(sysinf)) {
    ...
        6. └─exampletestr:::extract_examples("detect", tempdir(check = TRUE))
        7.   └─usethis::local_project(path = pkg_dir, quiet = TRUE)
        8.     └─usethis::proj_set(path = path, force = force)
        9.       └─usethis:::ui_abort(...)
       10.         └─cli::cli_abort(...)
       11.           └─rlang::abort(...)
      
      [ FAIL 1 | WARN 0 | SKIP 0 | PASS 27 ]
      Error: Test failures
      Execution halted
    ```

## In both

*   checking running R code from vignettes ... ERROR
    ```
    Errors in running code in vignettes:
    when running code in ‘one-file-at-a-time.Rmd’
      ...
    > knitr::opts_knit$set(root.dir = paste0(tempdir(), 
    +     "/", "tempkg"))
    
    > usethis::proj_set(".")
    
      When sourcing ‘one-file-at-a-time.R’:
    Error: ✖ Path '/tmp/RtmpGIYvQt/file132af710168/vignettes/' does not appear to
    ...
    
      When sourcing ‘whole-package.R’:
    Error: ✖ Path '/tmp/RtmpauCurR/file133f1dd70a93/vignettes/' does not appear to
      be inside a project or package.
    ℹ Read more in the help for `usethis::proj_get()`.
    Execution halted
    
      ‘one-file-at-a-time.Rmd’ using ‘UTF-8’... failed
      ‘one-function-at-a-time.Rmd’ using ‘UTF-8’... OK
      ‘whole-package.Rmd’ using ‘UTF-8’... failed
    ```
