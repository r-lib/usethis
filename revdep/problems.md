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
        'test-write_citation.R:46:3', 'test-write_citation.R:111:3'
      
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

