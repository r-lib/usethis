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

### Permission to overwrite

`write_over()` returns `FALSE` and does nothing if there is no need to overwrite (proposed file contents are same as existing) or if user says "no" and returns `TRUE` if it ovewrites. So if downstream logic depends on whether something new was written, consult the return value. `write_over()` is rarely called directly, but is usually called via `use_template()`, in which case the same handling should apply to its return value.

### Helpers and the active project

Current mindset: helpers should *not* make direct use of the active project, i.e. project-based paths should be formed by the caller.

Uncomfortable fact: `write_union()` uses the active project, if such exists, to create a humane path in its message. However, unlike `use_*()` functions, it does not call `proj_get()` to set an active project when `proj$cur` is `NULL`. We like this behaviour but the design feels muddy.

I perceive that The Git/GitHub functions are currently a bit disordered with respect to this. Specifically, I feel some functions afford control over the path that should really be hard-wired to consult the active project. I plan to revisit them with an attempt to decide which functions should operate on the active project / repo implicitly vs. which functions are considered "helpers" and therefore should take the repo path via an argument. Maybe only exported helpers should take a path? I also need to think about whether to use `proj_get()` or `git_repo()`, the difference being that `git_repo()` puts `proj_get()` behind a `check_uses_git()` guard.

## Home directory

usethis relies on fs for file system operations. The main thing users will notice is the treatment of home directory on Windows. A Windows user's home directory is interpreted as `C:\Users\username` (typical of Unix-oriented tools, like Git and ssh; also matches Python), as opposed to `C:\Users\username\Documents` (R's default on Windows). In order to be consistent everywhere, all paths supplied by the user should be processed with `user_path_prep()`.

## Communicating with the user

User-facing messages are emitted via helpers in `style.R` (see `ui_todo()` and `ui_done()`) and *everything* is eventually routed through `cat_line()`. This is all intentional and should be preserved.

`cat_line()` has a `quiet` argument and `quiet = TRUE` causes it to not produce output. Default value: `quiet = getOption("usethis.quiet", default = FALSE)`.

  * Exploited in usethis tests: option is set and unset in `setup.R` and `teardown.R`. Eliminates the need for ubiquitous `capture_output()` calls.
  * Other packages can muffle a usethis call via, e.g., `withr::local_options(list(usethis.quiet = TRUE))`.
  
Implication: don't call `cat_line(..., quiet = FALSE)` lightly, because it breaks the expectation that the option can be used to silence usethis.

You might also notice that usethis communicates with the user via `cat()` instead of `message()`. Why?

  * Pragmatic explanation: default styling of `message()` (at least in RStudio) is red, which suggests that something is wrong. We prefer default styling to be more neutral and less alarmist.
  * Principled explanation: if one diverts where various streams go, `cat()` follows printed output, whereas `message()` goes to standard error.

## Git

We make a strong assumption that user follows these conventions for branch and remote names:

  * `master` is the main default branch.
  * If you've got only one remote, it's called `origin`.
  * If you've got multiple remotes, one of them is `origin` and it is the main default remote.
  * If you've forked something, you have at least two remotes:
    - `origin` is your copy.
    - `upstream` is the original repo you forked.
  * TODO: update this once I've codified the ~5 scenarios I laid out in my
    Slack survey.

We assume a user habitually uses one transport protocol, either SSH or HTTPS, i.e. that they don't intentionally switch between them willy-nilly.

If the default summoning of Git credentials or protocol or GitHub PAT doesn't work for you, you must set them explicitly via `use_git_credentials()`, `use_git_protocol()`, or `Sys.setenv("GITHUB_PAT")`. We aren't going to offer fine control of this, everywhere, by repetitively offering a ton of function arguments.

I suspect I should declare whether the main purpose of each Git-using function is:

  * Related to Git/GitHub. In which case an early hard requirement for git repo
    is justified.
  * Not related to Git/Github. In which case Git checks like
    `check_uncommitted_changes()` have to either, themselves, operate gracefully
    if not in a git repo or be inside a conditional check for Git-repo-hood.

Functions that might make a commit should use `check_uncommitted_changes()` in the initial sanity-checking block to encourage starting in a clean state, i.e. with no uncommitted or untracked files.

To be determined: when do we check if active project is a git repo? And how, i.e. implicitly by calling `git_repo()` or explicitly by calling `check_uses_git()`?

Always make commits with `git_commit_ask()`. This why `git_commit()`, which wraps `gert::git_add()` and `gert::git_commit()`, is defined *inside* `git_commit_ask()`. Whenever possible, specify `paths` for `git_commit_ask()`. It should almost always be possible to know exactly which files we might have touched or created. If you need to make a commit in a noninteractive context, like a test, use `gert::git_commit()`.

Use `git_uncommitted(untracked = TRUE)` and `git_ask_commit(untracked = TRUE)` if it's possible that the work we've done has **created** a new file that should be tracked. Use `untracked = FALSE` if our work should only modify and pre-existing file.

Functions that do Git operations (or is it just a specific subset? definitely switching branch) should call `rstudio_git_tickle()` before exit. Maybe even via `on.exit()`?

