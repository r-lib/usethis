# cartools

Version: 0.1.0

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespaces in Imports field not imported from:
      ‘animation’ ‘devtools’ ‘gapminder’ ‘knitr’ ‘rlist’ ‘rmarkdown’
      ‘roxygen2’ ‘sde’ ‘shiny’ ‘tidyverse’ ‘usethis’ ‘utils’
      All declared Imports should be used.
    ```

# codemetar

Version: 0.1.7

## In both

*   checking tests ...
    ```
     ERROR
    Running the tests in ‘tests/testthat.R’ failed.
    Last 13 lines of output:
      13: structure(store_val(), class = "json")
      14: store_val()
      15: stop(out$err)
      
      ── 2. Failure: add_url_fixmes() works (@test-give_opinions.R#74)  ──────────────
      result_1\[2\] does not match "No connection was possible".
      Actual value: "<NA>"
      
      ══ testthat results  ═══════════════════════════════════════════════════════════
      OK: 135 SKIPPED: 16 FAILED: 2
      1. Error: we can validate this file (@test-codemeta_validate.R#5) 
      2. Failure: add_url_fixmes() works (@test-give_opinions.R#74) 
      
      Error: testthat unit tests failed
      Execution halted
    ```

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘memoise’
      All declared Imports should be used.
    ```

# CongreveLamsdell2016

Version: 1.0.1

## In both

*   checking package dependencies ... ERROR
    ```
    Package required but not available: ‘Ternary’
    
    Packages suggested but not available for checking:
      ‘ape’ ‘Quartet’ ‘TreeSearch’
    
    See section ‘The DESCRIPTION file’ in the ‘Writing R Extensions’
    manual.
    ```

# DataPackageR

Version: 0.15.6

## Newly broken

*   checking examples ... ERROR
    ```
    ...
        * First Last <first.last@example.com> [aut, cre] (<https://orcid.org/YOUR-ORCID-ID>)
    Description: What the package does (one paragraph).
    License: What license it uses
    Encoding: UTF-8
    LazyData: true
    ✔ Writing 'NAMESPACE'
    ✔ Setting active project to '<no active project>'
    ✔ Added DataVersion string to 'DESCRIPTION'
    ✔ Setting active project to '/Users/jenny/rrr/usethis'
    ✔ Creating 'data-raw/'
    ✔ Creating 'data/'
    ✔ Creating 'inst/extdata/'
    ✔ Copied foo.Rmd into 'data-raw'
    ✔ configured 'datapackager.yml' file
    
    ✔ Setting active project to '/private/var/folders/yx/3p5dt4jj1019st0x90vhm9rr0000gn/T/Rtmp4FQvhv/file10c85e989436'
    Warning in normalizePath(file.path(pkg_dir, "inst/extdata"), winslash = "/") :
      path[1]="/private/var/folders/yx/3p5dt4jj1019st0x90vhm9rr0000gn/T/Rtmp4FQvhv/file10c85e989436/inst/extdata": No such file or directory
    FATAL [2019-03-21 12:56:10] You need a valid package data strucutre. Missing ./R ./inst ./data or./data-raw subdirectories.
    Error: exiting
    Execution halted
    ```

*   checking tests ...
    ```
     ERROR
    Running the tests in ‘tests/testthat.R’ failed.
    Last 13 lines of output:
      cars_over_20══ testthat results  ═══════════════════════════════════════════════════════════
      OK: 156 SKIPPED: 0 FAILED: 12
      1. Error: package can be built from different locations (@test-build-locations.R#19) 
      2. Error: assert_data_version (@test-data-version.R#12) 
      3. Error: data objects are saved incrementally in render_root (@test-datapackager-object-read.R#36) 
      4. Error: package built in different edge cases (@test-edge-cases.R#265) 
      5. Error: R file processing works and creates vignettes (@test-r-processing.R#7) 
      6. Failure: data, code, and dependencies are moved into place by skeleton (@test-skeleton-data-dependencies.R#23) 
      7. Failure: data, code, and dependencies are moved into place by skeleton (@test-skeleton-data-dependencies.R#38) 
      8. Failure: data, code, and dependencies are moved into place by skeleton (@test-skeleton-data-dependencies.R#51) 
      9. Error: can update (@test-updating-datapackager-version.R#20) 
      1. ...
      
      Error: testthat unit tests failed
      Execution halted
    ```

*   checking re-building of vignette outputs ... WARNING
    ```
    Error in re-building vignettes:
      ...
    Warning in engine$weave(file, quiet = quiet, encoding = enc) :
      Pandoc (>= 1.12.3) and/or pandoc-citeproc not available. Falling back to R Markdown v1.
    Warning in engine$weave(file, quiet = quiet, encoding = enc) :
      Pandoc (>= 1.12.3) and/or pandoc-citeproc not available. Falling back to R Markdown v1.
    Quitting from lines 170-174 (usingDataPackageR.Rmd) 
    Error: processing vignette 'usingDataPackageR.Rmd' failed with diagnostics:
    exiting
    Execution halted
    ```

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

# fakemake

Version: 1.4.0

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘pkgbuild’
      All declared Imports should be used.
    ```

# KSPM

Version: 0.1.1

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘usethis’
      All declared Imports should be used.
    ```

# prodigenr

Version: 0.4.0

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespaces in Imports field not imported from:
      ‘clipr’ ‘desc’ ‘devtools’
      All declared Imports should be used.
    ```

# riskclustr

Version: 0.1.0

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespaces in Imports field not imported from:
      ‘gtools’ ‘knitr’ ‘usethis’
      All declared Imports should be used.
    ```

# rstanarm

Version: 2.18.2

## In both

*   checking re-building of vignette outputs ... WARNING
    ```
    Error in re-building vignettes:
      ...
    Warning in engine$weave(file, quiet = quiet, encoding = enc) :
      Pandoc (>= 1.12.3) and/or pandoc-citeproc not available. Falling back to R Markdown v1.
    Quitting from lines 2-15 (./children/SETTINGS-knitr.txt) 
    Quitting from lines NA-15 (./children/SETTINGS-knitr.txt) 
    Error: processing vignette 'aov.Rmd' failed with diagnostics:
    object 'params' not found
    Execution halted
    ```

*   checking installed package size ... NOTE
    ```
      installed size is 17.3Mb
      sub-directories of 1Mb or more:
        R      2.0Mb
        libs  13.7Mb
    ```

*   checking Rd cross-references ... NOTE
    ```
    Packages unavailable to check Rd xrefs: ‘gamm4’, ‘biglm’
    ```

*   checking for GNU extensions in Makefiles ... NOTE
    ```
    GNU make is a SystemRequirements.
    ```

# spectrolab

Version: 0.0.8

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespaces in Imports field not imported from:
      ‘devtools’ ‘usethis’
      All declared Imports should be used.
    ```

# vdiffr

Version: 0.3.0

## In both

*   checking dependencies in R code ... NOTE
    ```
    Namespace in Imports field not imported from: ‘freetypeharfbuzz’
      All declared Imports should be used.
    ```

