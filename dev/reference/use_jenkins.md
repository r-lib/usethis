# Create Jenkinsfile for Jenkins CI Pipelines

`use_jenkins()` adds a basic Jenkinsfile for R packages to the project
root directory. The Jenkinsfile stages take advantage of calls to
`make`, and so calling this function will also run
[`use_make()`](https://usethis.r-lib.org/dev/reference/use_make.md) if a
Makefile does not already exist at the project root.

## Usage

``` r
use_jenkins()
```

## See also

The [documentation on Jenkins
Pipelines](https://www.jenkins.io/doc/book/pipeline/jenkinsfile/).

[`use_make()`](https://usethis.r-lib.org/dev/reference/use_make.md)
