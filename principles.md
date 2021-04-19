# usethis design principles

*This is an experiment in making key package design principles explicit, versus only implicit in the code. The goal is to make maintenance easier, when spread out over time and across people.*

## Active project

Many usethis functions act on the **active project**, the path to which is stored in the internal environment `proj`, specifically in `proj$cur`.
We do this instead of constantly passing around a base path or relying on the working directory.
It is implied that such functions create or modify files inside the active project.
This is mostly true of `use_*()` functions, though there are exceptions.
For example, `use_course()` makes no reference to the active project.

The project is activated upon first need, i.e. eventually some function calls `proj_get()` and, if `proj$cur` is `NULL`, we attempt to activate a project at (or above) current working directory.

Direct read/write of `proj$cur` should never happen, even internally.
Instead, use `proj_get()` and `proj_set()`.
If that is not possible (i.e. you don't want to trigger project activation), use `proj_get_()` and `proj_set_()`.
If one must use `proj_set_()` directly, remember the stored project path should be processed with `proj_path_prep()`.

Form paths to files within the project with `proj_path()`.
Get paths relative to the project with `proj_rel_path()`.

### Activation upon load or attach? No.

We've contemplated project activation in `.onLoad()` or `.onAttach()`, but it's not clear which is more appropriate.
Which suggests that neither is appropriate.
If we ever do this, `zzz.R` would include something like this:

``` {.r}
.onLoad <- function(libname, pkgname) {
  try(proj_set(".", quiet = TRUE), silent = TRUE)
}
```

Why not `.onAttach()`?

-   A package that imported usethis would also need to set project on attach.
-   Currently user can open R, attach (or load) usethis, and then change working directory to their target project. As long as they are in the project the first time `proj_get()` is called, the correct project will be made active. This is not our preferred workflow, but it is common.

## Helper functions

With some ambivalence, internally-oriented helpers like `write_union()` are exported.
This helps developers who are extending usethis to create a package to standardize project setup within their own organization.

The downside is that we aren't exactly sure yet what we're willing to guarantee about these helpers.

### Permission to overwrite

`write_over()` returns `FALSE` and does nothing if there is no need to overwrite (proposed file contents are same as existing) or if user says "no" and returns `TRUE` if it ovewrites.
So if downstream logic depends on whether something new was written, consult the return value.
`write_over()` is rarely called directly, but is usually called via `use_template()`, in which case the same handling should apply to its return value.

### Helpers and the active project

Two opposing mindsets:

-   Helpers should be low-level and general and *not* make direct use of the active project, nor change the active project (or activate on in the first place). I.e. project-based paths should be formed by the caller.
-   Everything should refer to the active project, unless there's a specific reason not to.

Ideally, the exported file writing helpers would not make direct reference to the active project.
However, we violate this, with due care, when it benefits us:

-   `write_utf8()` potentially consults the project in which `path` lives in re: line ending.
    So its implementation takes care to respect that, but also to not change the active project.

-   `write_over()` (`can_overwrite()`, really) does same, except in that case we're determining whether `path` is within a Git repo.

-   `write_union()` uses the active project, if such exists, to create a humane path in its message.
    It also actively avoids activating or changing the project.

Git/GitHub helpers generally assume we're working on the Git repo that is also the active project.
These are unexported.
Prefer `git_repo()` to `proj_get()`, when you have a choice, to get the benefit of the `check_uses_git()` that's in `git_repo()`.

## Home directory

usethis relies on fs for file system operations.
The main thing users will notice is the treatment of home directory on Windows.
A Windows user's home directory is interpreted as `C:\Users\username` (typical of Unix-oriented tools, like Git and ssh; also matches Python), as opposed to `C:\Users\username\Documents` (R's default on Windows).
In order to be consistent everywhere, all paths supplied by the user should be processed with `user_path_prep()`.

## Communicating with the user

User-facing messages are emitted via helpers in `ui.R` and *everything* is eventually routed through `rlang::inform()` via `ui_inform()`.
This is all intentional and should be preserved.

This is so we can control verbosity package-wide with the `usethis.quiet` option, which defaults to `FALSE`.

-   Exploited in usethis tests: option is set and unset in `setup.R` and `teardown.R`. Eliminates the need for ubiquitous `capture_output()` calls.
-   Other packages can muffle a usethis call via, e.g., `withr::local_options(list(usethis.quiet = TRUE))`.
-   Use `ui_silence()` for executing small bits of code silently.

## Git/GitHub

Which GitHub remote configs the `pr_*()` functions accept, plus how and why they do it:

-   `pr_init()` calls `github_remote_config(github_get = NA)` and challenges configs other than "ours" and "fork". I want it to work with the "maybe" configs, because sometimes you're offline or don't have your PAT in the credential store. These come up for me during development.
-   `pr_resume()` only checks config (indirectly) if it calls `choose_branch()`. I want to be able to use this function offline or in the absence of a PAT, since its main job is to switch branches. It seems inappropriate to do a hard check of the GitHub remote config.
-   `pr_pause()` calls `target_repo(github_get = FALSE, ask = FALSE)` and will therefore accept "maybe" configs. Similar reasoning to `pr_resume()`: it seems like it should work, e.g., offline, since it's mostly about switching branches. Eventually calls `pr_pull_source_override()`.
-   `pr_view()` gets target repo with `github_get = NA`, so it works for "maybe" configs. Seems low stakes enough to not be too picky.
-   `pr_fetch()`, `pr_pull()`, `pr_merge_main()`, `pr_finish()`, all require "ours" or "fork", via an early call to `target_repo(github_get = TRUE)` or `check_ours_or_fork()`. They could probably work for other configs, e.g., "theirs", but it's not worth the added complexity.
-   `pr_push()` requires "ours" or "fork" and, in fact, gets the actual config, because it's potentially used to select the remote to push to (`origin` or `upstream`) if user can push to both.

When you need to create a new Git URL and have to decide between HTTPS or SSH:

-   Consult existing remotes for the repo, probably `origin`, if possible
-   Call `git_protocol()`, which will do something sensible

If the default summoning of Git credentials or GitHub PAT doesn't work for the user, help them diagnose that.
But we are NOT in the credential management business and we aren't going to offer fine control of this at, say, the level of individual functions.

Functions that might make a commit should use `challenge_uncommitted_changes()` in the initial sanity-checking block to encourage starting in a clean state, i.e. with no uncommitted files or, if `untracked = TRUE` is specified, also with no untracked files.
We allow people to proceed at their own risk.

Always make commits with `git_commit_ask()`.
This why `git_commit()`, which wraps `gert::git_add()` and `gert::git_commit()`, is defined *inside* `git_commit_ask()`.
Whenever possible, specify `paths` for `git_commit_ask()`.
It should almost always be possible to know exactly which files we might have touched or created.
If you need to make a commit in a noninteractive context, like a test, use `gert::git_commit()`.

Use `git_uncommitted(untracked = TRUE)` and `git_ask_commit(untracked = TRUE)` if it's possible that the work we've done has **created** a new file that should be tracked.
Use `untracked = FALSE` if our work should only modify and pre-existing file.
