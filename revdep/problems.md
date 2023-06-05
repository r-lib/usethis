# altdoc

<details>

* Version: 0.2.0
* GitHub: https://github.com/etiennebacher/altdoc
* Source code: https://github.com/cran/altdoc
* Date/Publication: 2023-05-26 18:50:08 UTC
* Number of recursive dependencies: 82

Run `revdepcheck::cloud_details(, "altdoc")` for more info

</details>

## Newly broken

*   checking tests ... ERROR
    ```
      Running ‘spelling.R’
      Running ‘testthat.R’
    Running the tests in ‘tests/testthat.R’ failed.
    Last 13 lines of output:
       2.   └─usethis:::cran_version()
       3.     └─utils::available.packages()
       4.       └─utils::contrib.url(repos, type)
      ── Error ('test-utils.R:48:3'): import_* functions work ────────────────────────
      Error in `contrib.url(repos, type)`: trying to use CRAN without setting a mirror
      Backtrace:
          ▆
       1. └─usethis::use_news_md() at test-utils.R:48:2
       2.   └─usethis:::cran_version()
       3.     └─utils::available.packages()
       4.       └─utils::contrib.url(repos, type)
      
      [ FAIL 5 | WARN 0 | SKIP 13 | PASS 86 ]
      Error: Test failures
      Execution halted
    ```

# cffr

<details>

* Version: 0.5.0
* GitHub: https://github.com/ropensci/cffr
* Source code: https://github.com/cran/cffr
* Date/Publication: 2023-05-05 12:00:02 UTC
* Number of recursive dependencies: 71

Run `revdepcheck::cloud_details(, "cffr")` for more info

</details>

## Newly broken

*   checking tests ... ERROR
    ```
      Running ‘testthat.R’
    Running the tests in ‘tests/testthat.R’ failed.
    Last 13 lines of output:
      • On CRAN (110)
      
      ══ Failed tests ════════════════════════════════════════════════════════════════
      ── Failure ('test-cff_to_bibtex.R:416:3'): Errors ──────────────────────────────
      `b <- cff_to_bibtex("testthat")` produced warnings.
      
      [ FAIL 1 | WARN 10 | SKIP 110 | PASS 311 ]
      Deleting unused snapshots:
      • write_bib/append.bib
      • write_bib/ascii.bib
      • write_bib/noext.bib
      • write_citation/append
      • write_citation/noext
      Error: Test failures
      Execution halted
    ```

# exampletestr

<details>

* Version: 1.7.0
* GitHub: https://github.com/rorynolan/exampletestr
* Source code: https://github.com/cran/exampletestr
* Date/Publication: 2022-12-06 19:20:02 UTC
* Number of recursive dependencies: 97

Run `revdepcheck::cloud_details(, "exampletestr")` for more info

</details>

## Newly broken

*   checking tests ... ERROR
    ```
      Running ‘spelling.R’
      Running ‘testthat.R’
    Running the tests in ‘tests/testthat.R’ failed.
    Last 13 lines of output:
        7. │ ├─usethis::ui_path(usethis::proj_path(test_file_name), usethis::proj_path())
        8. │ │ └─fs::is_dir(x)
        9. │ │   └─fs::file_info(path, follow = follow)
       10. │ │     └─fs::path_expand(path)
       11. │ └─usethis::proj_path(test_file_name)
       12. │   └─usethis::ui_stop("Paths must be relative to the active project")
       13. └─glue (local) `<fn>`("usethis::ui_path(usethis::proj_path(test_file_name),\nusethis::proj_path())")
       14.   ├─.transformer(expr, env) %||% .null
       15.   └─glue (local) .transformer(expr, env)
       16.     └─base::eval(parse(text = text, keep.source = FALSE), envir)
       17.       └─base::eval(parse(text = text, keep.source = FALSE), envir)
      
      [ FAIL 2 | WARN 4 | SKIP 0 | PASS 16 ]
      Error: Test failures
      Execution halted
    ```

# fledge

<details>

* Version: 0.1.0
* GitHub: https://github.com/cynkra/fledge
* Source code: https://github.com/cran/fledge
* Date/Publication: 2021-12-07 20:20:02 UTC
* Number of recursive dependencies: 74

Run `revdepcheck::cloud_details(, "fledge")` for more info

</details>

## Newly broken

*   checking examples ... ERROR
    ```
    Running examples in ‘fledge-Ex.R’ failed
    The error most likely occurred in:
    
    > ### Name: bump_version
    > ### Title: Bump package version
    > ### Aliases: bump_version bump_version_impl
    > 
    > ### ** Examples
    > 
    > # Create mock package in a temporary directory.
    ...
    +   fledge::bump_version()
    + })
    sh: 1: git: not found
    sh: 1: git: not found
    sh: 1: git: not found
    sh: 1: git: not found
    Error in contrib.url(repos, type) : 
      trying to use CRAN without setting a mirror
    Calls: with_demo_project ... <Anonymous> -> cran_version -> <Anonymous> -> contrib.url
    Execution halted
    ```

*   checking tests ... ERROR
    ```
      Running ‘testthat.R’
    Running the tests in ‘tests/testthat.R’ failed.
    Last 13 lines of output:
       6.     └─usethis:::cran_version()
       7.       └─utils::available.packages()
       8.         └─utils::contrib.url(repos, type)
      
      [ FAIL 8 | WARN 0 | SKIP 5 | PASS 0 ]
      Deleting unused snapshots:
      • bump_version/NEWS-nondev.md
      • bump_version/NEWS.md
      • finalize-version/NEWS-push-false.md
      • finalize-version/NEWS-push-true.md
      • unbump_version/NEWS.md
      • update-news/NEWS-empty.md
      • update-news/NEWS-new.md
      Error: Test failures
      Execution halted
    ```

# fusen

<details>

* Version: 0.4.1
* GitHub: https://github.com/Thinkr-open/fusen
* Source code: https://github.com/cran/fusen
* Date/Publication: 2022-09-29 14:50:06 UTC
* Number of recursive dependencies: 113

Run `revdepcheck::cloud_details(, "fusen")` for more info

</details>

## Newly broken

*   checking examples ... ERROR
    ```
    Running examples in ‘fusen-Ex.R’ failed
    The error most likely occurred in:
    
    > ### Name: inflate
    > ### Title: Inflate Rmd to package
    > ### Aliases: inflate
    > 
    > ### ** Examples
    > 
    > # Create a new project
    ...
    + )
    ✔ Setting active project to '/tmp/Rtmpu0fqny/dummypackage1eb4449d5950'
    ℹ Loading dummypackage1eb4449d5950
    Writing 'NAMESPACE'
    Loading required namespace: testthat
    ✔ Adding 'knitr' to Suggests field in DESCRIPTION
    Error in get(x, envir = ns, inherits = FALSE) : 
      object 'use_description_field' not found
    Calls: inflate -> create_vignette -> getFromNamespace -> get
    Execution halted
    ```

## In both

*   checking tests ... ERROR
    ```
      Running ‘testthat.R’
    Running the tests in ‘tests/testthat.R’ failed.
    Last 13 lines of output:
      Error in `get(x, envir = ns, inherits = FALSE)`: object 'use_description_field' not found
      Backtrace:
          ▆
       1. ├─usethis::with_project(...) at test-inflate_utils.R:36:0
       2. │ └─base::force(code)
       3. ├─usethis::with_project(...) at test-inflate_utils.R:48:2
       4. │ └─base::force(code)
       5. └─fusen::inflate(...) at test-inflate_utils.R:49:4
       6.   └─fusen:::create_vignette(...)
       7.     └─utils::getFromNamespace("use_description_field", "usethis")
       8.       └─base::get(x, envir = ns, inherits = FALSE)
      
      [ FAIL 18 | WARN 6 | SKIP 7 | PASS 212 ]
      Error: Test failures
      Execution halted
    ```

