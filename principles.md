# usethis design principles

*This is an experiment in making key package design principles explicit, versus only implicit in the code. The goal is to make maintenance easier, when spread out over time and across people.*

## Active project

Many usethis functions act on the **active project**, the path to which is stored in the internal environment `proj`, specifically in `proj$cur`. We do this instead of constantly passing around a base path or relying on the working directory. It is implied that such functions create or modify files inside the active project. This is mostly true of `use_*()` functions, though there are exceptions. For example, `use_course()` makes no reference to the active project.

The project is activated upon first need, i.e. eventually some function calls `proj_get()` and, if `proj$cur` is `NULL`, we attempt to activate a project at (or above) current working directory.

Direct read/write of `proj$cur` should be rare. Even internally, `proj_get()` and `proj_set()` are preferred. The stored project path should be processed with `proj_path_prep()`.

Form paths to files within the project with `proj_path()`. Get paths relative to the project with `proj_rel_path()`.

### Activation upon load or attach? No.

We've contemplated project activation in `.onLoad()` or `.onAttach()`, but it's not clear which is more appropriate. Which suggests that neither is appropriate. If we ever do this, `zzz.R` would include something like this:

``` r
.onLoad <- function(libname, pkgname) {
  try(proj_set(".", quiet = TRUE), silent = TRUE)
}
```

Why not `.onAttach()`?

  * A package that imported usethis would also need to set project on attach.
  * Currently user can open R, attach (or load) usethis, and then change working directory to their target project. As long as they are in the project the first time `proj_get()` is called, the correct project will be made active. This is not our preferred workflow, but it is common.

## Helper functions

With some ambivalence, internally-oriented helpers like `write_union()` are exported. This helps developers who are extending usethis to create a package to standardize project setup within their own organization.

The downside is that we aren't exactly sure yet what we're willing to guarantee about these helpers.

### Helpers and the active project

Current mindset: helpers should *not* make direct use of the active project, i.e. project-based paths should be formed by the caller.

Uncomfortable fact: `write_union()` uses the active project, if such exists, to create a humane path in its message. However, unlike `use_*()` functions, it does not call `proj_get()` to set an active project when `proj$cur` is `NULL`. We like this behaviour but the design feels muddy.

## Home directory

usethis relies on fs for file system operations. The main thing users will notice is the treatment of home directory on Windows. A Windows user's home directory is interpreted as `C:\Users\username` (typical of Unix-oriented tools, like Git and ssh; also matches Python), as opposed to `C:\Users\username\Documents` (R's default on Windows). In order to be consistent everywhere, all paths supplied by the user should be processed with `user_path_prep()`.
