# Helpers for GitHub pull requests

The `pr_*` family of functions is designed to make working with GitHub
pull requests (PRs) as painless as possible for both contributors and
package maintainers.

To use the `pr_*` functions, your project must be a Git repo and have
one of these GitHub remote configurations:

- "ours": You can push to the GitHub remote configured as `origin` and
  it's not a fork.

- "fork": You can push to the GitHub remote configured as `origin`, it's
  a fork, and its parent is configured as `upstream`. `origin` points to
  your **personal** copy and `upstream` points to the **source repo**.

"Ours" and "fork" are two of several GitHub remote configurations
examined in [Common remote
setups](https://happygitwithr.com/common-remote-setups.html) in Happy
Git and GitHub for the useR.

The [Pull Request
Helpers](https://usethis.r-lib.org/articles/articles/pr-functions.html)
article walks through the process of making a pull request with the
`pr_*` functions.

The `pr_*` functions also use your Git/GitHub credentials to carry out
various remote operations; see below for more about auth. The `pr_*`
functions also proactively check for agreement re: the default branch in
your local repo and the source repo. See
[`git_default_branch()`](https://usethis.r-lib.org/dev/reference/git-default-branch.md)
for more.

## Usage

``` r
pr_init(branch)

pr_resume(branch = NULL)

pr_fetch(number = NULL, target = c("source", "primary"))

pr_push()

pr_pull()

pr_merge_main()

pr_view(number = NULL, target = c("source", "primary"))

pr_pause()

pr_finish(number = NULL, target = c("source", "primary"))

pr_forget()
```

## Arguments

- branch:

  Name of a new or existing local branch. If creating a new branch, note
  this should usually consist of lower case letters, numbers, and `-`.

- number:

  Number of PR.

- target:

  Which repo to target? This is only a question in the case of a fork.
  In a fork, there is some slim chance that you want to consider pull
  requests against your fork (the primary repo, i.e. `origin`) instead
  of those against the source repo (i.e. `upstream`, which is the
  default).

## Git/GitHub Authentication

Many usethis functions, including those documented here, potentially
interact with GitHub in two different ways:

- Via the GitHub REST API. Examples: create a repo, a fork, or a pull
  request.

- As a conventional Git remote. Examples: clone, fetch, or push.

Therefore two types of auth can happen and your credentials must be
discoverable. Which credentials do we mean?

- A GitHub personal access token (PAT) must be discoverable by the gh
  package, which is used for GitHub operations via the REST API. See
  [`gh_token_help()`](https://usethis.r-lib.org/dev/reference/github-token.md)
  for more about getting and configuring a PAT.

- If you use the HTTPS protocol for Git remotes, your PAT is also used
  for Git operations, such as `git push`. Usethis uses the gert package
  for this, so the PAT must be discoverable by gert. Generally gert and
  gh will discover and use the same PAT. This ability to "kill two birds
  with one stone" is why HTTPS + PAT is our recommended auth strategy
  for those new to Git and GitHub and PRs.

- If you use SSH remotes, your SSH keys must also be discoverable, in
  addition to your PAT. The public key must be added to your GitHub
  account.

Git/GitHub credential management is covered in a dedicated article:
[Managing Git(Hub)
Credentials](https://usethis.r-lib.org/articles/articles/git-credentials.html)

## For contributors

To contribute to a package, first use
`create_from_github("OWNER/REPO")`. This forks the source repository and
checks out a local copy.

Next use `pr_init()` to create a branch for your PR. It is best practice
to never make commits to the default branch branch of a fork (usually
named `main` or `master`), because you do not own it. A pull request
should always come from a feature branch. It will be much easier to pull
upstream changes from the fork parent if you only allow yourself to work
in feature branches. It is also much easier for a maintainer to explore
and extend your PR if you create a feature branch.

Work locally, in your branch, making changes to files, and committing
your work. Once you're ready to create the PR, run `pr_push()` to push
your local branch to GitHub, and open a webpage that lets you initiate
the PR (or draft PR).

To learn more about the process of making a pull request, read the [Pull
Request
Helpers](https://usethis.r-lib.org/articles/articles/pr-functions.html)
vignette.

If you are lucky, your PR will be perfect, and the maintainer will
accept it. You can then run `pr_finish()` to delete your PR branch. In
most cases, however, the maintainer will ask you to make some changes.
Make the changes, then run `pr_push()` to update your PR.

It's also possible that the maintainer will contribute some code to your
PR: to get those changes back onto your computer, run `pr_pull()`. It
can also happen that other changes have occurred in the package since
you first created your PR. You might need to merge the default branch
(usually named `main` or `master`) into your PR branch. Do that by
running `pr_merge_main()`: this makes sure that your PR is compatible
with the primary repo's main line of development. Both `pr_pull()` and
`pr_merge_main()` can result in merge conflicts, so be prepared to
resolve before continuing.

## For maintainers

To download a PR locally so that you can experiment with it, run
`pr_fetch()` and select the PR or, if you already know its number, call
`pr_fetch(<pr_number>)`. If you make changes, run `pr_push()` to push
them back to GitHub. After you have merged the PR, run `pr_finish()` to
delete the local branch and remove the remote associated with the
contributor's fork.

## Overview of all the functions

- `pr_init()`: As a contributor, start work on a new PR by ensuring that
  your local repo is up-to-date, then creating and checking out a new
  branch. Nothing is pushed to or created on GitHub until you call
  `pr_push()`.

- `pr_fetch()`: As a maintainer, review or contribute changes to an
  existing PR by creating a local branch that tracks the remote PR.
  `pr_fetch()` does as little work as possible, so you can also use it
  to resume work on an PR that already has a local branch (where it will
  also ensure your local branch is up-to-date). If called with no
  arguments, up to 9 open PRs are offered for interactive selection.

- `pr_resume()`: Resume work on a PR by switching to an existing local
  branch and pulling any changes from its upstream tracking branch, if
  it has one. If called with no arguments, up to 9 local branches are
  offered for interactive selection, with a preference for branches
  connected to PRs and for branches with recent activity.

- `pr_push()`: The first time it's called, a PR branch is pushed to
  GitHub and you're taken to a webpage where a new PR (or draft PR) can
  be created. This also sets up the local branch to track its remote
  counterpart. Subsequent calls to `pr_push()` make sure the local
  branch has all the remote changes and, if so, pushes local changes,
  thereby updating the PR.

- `pr_pull()`: Pulls changes from the local branch's remote tracking
  branch. If a maintainer has extended your PR, this is how you bring
  those changes back into your local work.

- `pr_merge_main()`: Pulls changes from the default branch of the source
  repo into the current local branch. This can be used when the local
  branch is the default branch or when it's a PR branch.

- `pr_pause()`: Makes sure you're up-to-date with any remote changes in
  the PR. Then switches back to the default branch and pulls from the
  source repo. Use `pr_resume()` with name of branch or use `pr_fetch()`
  to resume using PR number.

- `pr_view()`: Visits the PR associated with the current branch in the
  browser (default) or the specific PR identified by `number`. (FYI
  [`browse_github_pulls()`](https://usethis.r-lib.org/dev/reference/browse-this.md)
  is a handy way to visit the list of all PRs for the current project.)

- `pr_forget()`: Does local clean up when the current branch is an
  actual or notional PR that you want to abandon. Maybe you initiated it
  yourself, via `pr_init()`, or you used `pr_fetch()` to explore a PR
  from GitHub. Only does *local* operations: does not update or delete
  any remote branches, nor does it close any PRs. Alerts the user to any
  uncommitted or unpushed work that is at risk of being lost. If user
  chooses to proceed, switches back to the default branch, pulls changes
  from source repo, and deletes local PR branch. Any associated Git
  remote is deleted, if the "forgotten" PR was the only branch using it.

- `pr_finish()`: Does post-PR clean up, but does NOT actually merge or
  close a PR (maintainer should do this in the browser). If `number` is
  not given, infers the PR from the upstream tracking branch of the
  current branch. If `number` is given, it does not matter whether the
  PR exists locally. If PR exists locally, alerts the user to
  uncommitted or unpushed changes, then switches back to the default
  branch, pulls changes from source repo, and deletes local PR branch.
  If the PR came from an external fork, any associated Git remote is
  deleted, provided it's not in use by any other local branches. If the
  PR has been merged and user has permission, deletes the remote branch
  (this is the only remote operation that `pr_finish()` potentially
  does).

## Examples

``` r
if (FALSE) { # \dontrun{
pr_fetch(123)
} # }
```
