# usethis design principles

*This is an experiment in making key package design principles explicit, versus only implicit in the code. The goal is to make maintenance easier, when spread out over time and across people.*

## Active project

Many usethis functions act on the **active project**, the path to which is stored in the internal environment `proj`, specifically in `proj$cur`. We do this instead of constantly passing around a base path. It is implied that such functions create or modify files inside the active project. This is mostly true of `use_*()` functions, though there are exceptions. For example, `use_course()` makes no reference to the active project.

The project is activated upon first need, i.e. eventually some function calls `proj_get()` and, if `proj$cur` is `NULL`, we attempt to activate a project at (or above) current working directory.

### Activation upon load or attach? No.

We've contemplated project activation in `.onLoad()` or `.onAttach()`, but it's not clear which is more appropriate. Which suggests that neither is appropriate. If we ever do this, `zzz.R` would include something like this:

``` r
.onLoad <- function(libname, pkgname) {
  try(proj_set(".", quiet = TRUE), silent = TRUE)
}
```

## Helper functions

With some ambivalence, internally-oriented helpers like `write_union()` are exported. This helps developers who are extending usethis to create a package to standardize project setup within their own organization.

The downside is that we aren't exactly sure yet what we're willing to guarantee about these helpers.

### Helpers and the active project

Current mindset: helpers should *not* make direct use of the active project, i.e. project-based paths should be formed by the caller.

Uncomfortable fact: `write_union()` uses the active project, if such exists, to create a humane path in its message. However, unlike `use_*()` functions, it does not call `proj_get()` to set an active project when `proj$cur` is `NULL`. We like this behaviour but the design feels muddy.
