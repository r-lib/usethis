# Get or set the default Git branch

The `git_default_branch*()` functions put some structure around the
somewhat fuzzy (but definitely real) concept of the default branch. In
particular, they support new conventions around the Git default branch
name, globally or in a specific project / Git repository.

## Usage

``` r
git_default_branch()

git_default_branch_configure(name = "main")

git_default_branch_rediscover(current_local_default = NULL)

git_default_branch_rename(from = NULL, to = "main")
```

## Arguments

- name:

  Default name for the initial branch in new Git repositories.

- current_local_default:

  Name of the local branch that is currently functioning as the default
  branch. If unspecified, this can often be inferred.

- from:

  Name of the branch that is currently functioning as the default
  branch.

- to:

  New name for the default branch.

## Value

Name of the default branch.

## Background on the default branch

Technically, Git has no official concept of the default branch. But in
reality, almost all Git repos have an *effective default branch*. If
there's only one branch, this is it! It is the branch that most bug
fixes and features get merged in to. It is the branch you see when you
first visit a repo on a site such as GitHub. On a Git remote, it is the
branch that `HEAD` points to.

Historically, `master` has been the most common name for the default
branch, but `main` is an increasingly popular choice.

## `git_default_branch_configure()`

This configures `init.defaultBranch` at the global (a.k.a user) level.
This setting determines the name of the branch that gets created when
you make the first commit in a new Git repo. `init.defaultBranch` only
affects the local Git repos you create in the future.

## `git_default_branch()`

This figures out the default branch of the current Git repo, integrating
information from the local repo and, if applicable, the `upstream` or
`origin` remote. If there is a local vs. remote mismatch,
`git_default_branch()` throws an error with advice to call
`git_default_branch_rediscover()` to repair the situation.

For a remote repo, the default branch is the branch that `HEAD` points
to.

For the local repo, if there is only one branch, that must be the
default! Otherwise we try to identify the relevant local branch by
looking for specific branch names, in this order:

- whatever the default branch of `upstream` or `origin` is, if
  applicable

- `main`

- `master`

- the value of the Git option `init.defaultBranch`, with the usual deal
  where a local value, if present, takes precedence over a global
  (a.k.a. user-level) value

## `git_default_branch_rediscover()`

This consults an external authority – specifically, the remote **source
repo** on GitHub – to learn the default branch of the current project /
repo. If that doesn't match the apparent local default branch (for
example, the project switched from `master` to `main`), we do the
corresponding branch renaming in your local repo and, if relevant, in
your fork.

See <https://happygitwithr.com/common-remote-setups.html> for more about
GitHub remote configurations and, e.g., what we mean by the source repo.
This function works for the configurations `"ours"`, `"fork"`, and
`"theirs"`.

## `git_default_branch_rename()`

Note: this only works for a repo that you effectively own. In terms of
GitHub, you must own the **source repo** personally or, if
organization-owned, you must have `admin` permission on the **source
repo**.

This renames the default branch in the **source repo** on GitHub and
then calls `git_default_branch_rediscover()`, to make any necessary
changes in the local repo and, if relevant, in your personal fork.

See <https://happygitwithr.com/common-remote-setups.html> for more about
GitHub remote configurations and, e.g., what we mean by the source repo.
This function works for the configurations `"ours"`, `"fork"`, and
`"no_github"`.

Regarding `"no_github"`: Of course, this function does what you expect
for a local repo with no GitHub remotes, but that is not the primary use
case.

## Examples

``` r
if (FALSE) { # \dontrun{
git_default_branch()
} # }
if (FALSE) { # \dontrun{
git_default_branch_configure()
} # }
if (FALSE) { # \dontrun{
git_default_branch_rediscover()

# you can always explicitly specify the local branch that's been playing the
# role of the default
git_default_branch_rediscover("unconventional_default_branch_name")
} # }
if (FALSE) { # \dontrun{
git_default_branch_rename()

# you can always explicitly specify one or both branch names
git_default_branch_rename(from = "this", to = "that")
} # }
```
