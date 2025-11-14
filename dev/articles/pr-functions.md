# Pull request helpers

## Contributing to someone else’s package

So, you want to contribute to an R package? That’s fantastic!

Here we walk through the process of making a so-called **pull request**
to the [praise](https://github.com/rladies/praise) package. This package
is designed to help package developers “build friendly R packages that
praise their users if they have done something good, or they just need
it to feel better.” You can use praise to construct encouraging feedback
by sampling from its collection of positive adjectives, adverbs, verbs,
smileys, and exclamations:

``` r
library(praise)

template <- "${EXCLAMATION} - your pull request is ${adjective}!"

praise(template)
#> [1] "YEE-HAW - your pull request is groovy!"
```

We are going to propose a new adjective: “formidable”.

## What’s a pull request?

A [pull
request](https://help.github.com/en/articles/about-pull-requests) is how
you propose a change to a GitHub repository. Think of it as a *request*
for the maintainer to *pull* your changes into their repo.

The `pr_*()` family of functions is designed to make working with GitHub
pull requests as painless as possible, for both contributors and package
maintainers. They are designed to support the Git and GitHub workflows
recommended in [Happy Git and GitHub for the
useR](http://happygitwithr.com/).

A pull request (PR) involves two players, a contributor and a reviewer.
To make it more clear who runs which code, the code chunks in this
article are color coded: code executed by the contributor appears in
chunks with light gray background and code executed by the reviewer
appears in chunks with beige background.

``` r
# contributor code
```

``` r
# reviewer code
```

## Set up advice

This article assumes that you have already done the Git and GitHub parts
of the [setup
vignette](https://usethis.r-lib.org/articles/articles/usethis-setup) and
that you have configured a GitHub personal access token, as described in
[Managing Git(Hub)
Credentials](https://usethis.r-lib.org/articles/articles/git-credentials.md).
A good way to check that you are ready to use the `pr_*` family of
functions is to run
[`git_sitrep()`](https://usethis.r-lib.org/dev/reference/git_sitrep.md),
which prints info about your current Git, gert, and GitHub setup.

Specifically, the `pr_*()` functions make use of:

- The GitHub API, which requires a personal access token (PAT).
  - [`create_github_token()`](https://usethis.r-lib.org/dev/reference/github-token.md)
    helps you set one up.
- Your preferred Git transport protocol: `"https"` or `"ssh"`.
  - If usethis can’t figure this out, it might ask you. You can set the
    `usethis.protocol` option to proactively address this.
- gert, an R package which does Git operations from R. The gert package,
  in turn, relies on the credentials package to obtain your Git
  credentials.
  - If you use the `"https"` protocol, your GitHub PAT is the only
    credential you need. Which is a good reason to choose `"https"`!

## Attach usethis

All the code below assumes you’ve attached usethis in your R session:

``` r
library(usethis)
```

## Fork and clone

The first step is to fork the source repository, to get your own copy on
GitHub, and then clone that, to get your own local copy. There are many
ways to accomplish these two steps, but here we demonstrate
[`usethis::create_from_github()`](https://usethis.r-lib.org/dev/reference/create_from_github.md):

``` r
create_from_github("rladies/praise")
```

``` r
#> ℹ Defaulting to 'https' Git protocol
#> ✓ Setting `fork = TRUE`
#> ✓ Creating '/Users/mine/Desktop/praise/'
#> ✓ Forking 'rladies/praise'
#> ✓ Cloning repo from 'https://github.com/mine-cetinkaya-rundel/praise.git' into '/Users/mine/Desktop/praise'
#> ✓ Setting active project to '/Users/mine/Desktop/praise'
#> ℹ Default branch is 'master'
#> ✓ Adding 'upstream' remote: 'https://github.com/rladies/praise.git'
#> ✓ Pulling in changes from default branch of the source repo 'upstream/master'
#> ✓ Setting remote tracking branch for local 'master' branch to 'upstream/master'
#> ✓ Opening '/Users/mine/Desktop/praise/' in new RStudio session
#> ✓ Setting active project to '<no active project>'
```

What this does:

- Forks the praise repo, owned by rladies on GitHub, into your GitHub
  account.
- Clones your praise repo into a folder named “praise” on your desktop
  (or similar).
  - `origin` remote is set to your praise repo.
- Does additional Git setup:
  - `upstream` remote is set to the praise repo owned by rladies.
  - `master` branch is set to track `upstream/master`, so you can pull
    upstream changes in the future.
- Opens a new instance of RStudio in the praise project, if you’re
  working in RStudio. Otherwise, switches your current R session to that
  project.

Arguments you might like to know about:

- Specify `fork = TRUE` or `fork = FALSE` if you don’t want to defer to
  the default behaviour.
- Use `destdir` to put praise in a specific location on your computer.
  You can set the `usethis.destdir` option if you always want usethis to
  put new projects in a specific directory.

## Branch, then make your change

We start the process of contributing to the package with
[`pr_init()`](https://usethis.r-lib.org/dev/reference/pull-requests.md),
which creates a branch in our repository for the pull request. It is a
good idea to make your pull requests from a feature branch, not from the
repo’s default branch, which is `master` here (another common choice is
`main`). We’ll call this branch `"formidable"`.

``` r
pr_init(branch = "formidable")
```

``` r
#> ✓ Setting active project to '/Users/mine/Desktop/praise'
#> ℹ Pulling changes from 'upstream/master'
#> ✓ Creating and switching to local branch 'formidable'
#> ● Use `pr_push()` to create PR.
```

This creates a local branch called `formidable` and we switch to it (or
“check it out”). Now you can work locally, making changes to files and
committing them to Git.

Let’s go ahead and make the change, which is adding the word
“formidable” to the `R/adjective.R` file in the package. Below is the
diff and the commit associated with this change.

![Screenshot of the RStudio Git pane showing the file R/adjective.R
staged for a commit. The preview of the file highlights the addition of
the line formidabel, with no comma at the end of the line. The Commit
message says Add formidable to adjectives. ](img/pr-functions-diff.png)

You might spot that we made two mistakes here:

1.  We intended to add “formidable”, but added “formidabel” instead.
2.  We forgot a comma at the end of the line.

Let’s assume we didn’t actually catch these mistakes, and didn’t build
and check the package, which would have revealed the missing comma. We
all make mistakes.

## Submit pull request

[`pr_push()`](https://usethis.r-lib.org/dev/reference/pull-requests.md)
pushes the local change to your copy of praise on GitHub and puts you in
position to make your pull request.

``` r
pr_push()
```

``` r
#> ✓ Checking that local branch 'formidable' has the changes in 'origin/formidable'
#> ✓ Pushing local 'formidable' branch to 'origin/formidable'
#> ✓ Create PR at link given below
#> ✓ Opening URL 'https://github.com/mine-cetinkaya-rundel/praise/compare/formidable'
```

This launches a browser window at the URL specified in the last message,
which looks like the following.

![A screenshot showing the diff on GitHub, with the old version of the
file on the left, and the new version containing the newly added line
formidabel, with no comma, on the right. There is a green button that
says Create Pull Request. ](img/pr-functions-pull-request.png)

Click “Create pull request” to make the PR. After clicking you will be
able to choose between [draft
PR](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/about-pull-requests#draft-pull-requests)
and actual PR (If opening a draft PR, [mark it as ready for
review](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/changing-the-stage-of-a-pull-request)
once you’re done, e.g. after a few more commits and one new call to
[`pr_push()`](https://usethis.r-lib.org/dev/reference/pull-requests.md)).

GitHub will ping the package maintainer and they will review our pull
request. We can view this pull request in the browser with
[`pr_view()`](https://usethis.r-lib.org/dev/reference/pull-requests.md).
And anyone can follow along with this PR
[rladies/praise#90](https://github.com/rladies/praise/pull/90).

``` r
pr_view(90)
```

``` r
#> ✔ Opening URL 'https://github.com/rladies/praise/pull/90'
```

## Review of the pull request

If we’re lucky, and our pull request is perfect, the maintainer will
accept it, a.k.a. merge it. However, in this case, the PR still needs
some work. So the package maintainer leaves us comments requesting
changes.

![A screenshot of the comments section on the pull request. A comment
from a collaborator on the new line says Did you mean to add formidable?
And can you please add a comma at the end? Thanks!
](img/pr-functions-comments.png)

Being somewhat new to all this, we try to address one of these comments
(fix spelling) and neglect the other (forget to add the comma). We make
another change and commit it.

![A screenshot of the Rstudio Git pane, showing the changed line with
formidabel changed to formidable. The file R/adjective.R is staged for a
commit, with the commit message Fix Spelling!
](img/pr-functions-address-comments.png)

Run
[`pr_push()`](https://usethis.r-lib.org/dev/reference/pull-requests.md)
again to update the branch in our fork, which is automatically reflected
in the PR.

``` r
pr_push()
```

``` r
#> ✔ Pushing local 'formidable' branch to 'origin:formidable'
#> ✔ Setting upstream tracking branch for 'formidable' to 'origin/formidable'
#> ✔ Create PR at link given below
#> ✔ Opening URL 'https://github.com/mine-cetinkaya-rundel/praise/compare/formidable'
```

Now the reviewer gets another chance to review our changes. At this
point they might choose to just make the necessary changes and push
their commits into our pull request to finish things up.

To do so, the reviewer fetches the PR to their local machine with
[`pr_fetch()`](https://usethis.r-lib.org/dev/reference/pull-requests.md).

``` r
pr_fetch(90)
```

``` r
#> ✔ Setting active project to '/Users/gaborcsardi/works/praise'
#> ✔ Checking out PR 'rladies/praise/#90' (@mine-cetinkaya-rundel): 'Add "formidable" to adjectives'
#> ✔ Adding remote 'mine-cetinkaya-rundel' as 'git@github.com:mine-cetinkaya-rundel/praise.git'
#> ✔ Creating local branch 'mine-cetinkaya-rundel-formidable'
#> ✔ Setting upstream tracking branch for 'mine-cetinkaya-rundel-formidable' to 'mine-cetinkaya-rundel/formidable'
#> ✔ Switching to branch 'mine-cetinkaya-rundel-formidable'
#> ✔ Pulling changes from GitHub PR
```

Fetching the PR creates a local branch for them called
`mine-cetinkaya-rundel-formidable`, which is a text string comprised of
the GitHub username of the contributor and the name of the branch they
had created for this PR.
[`pr_fetch()`](https://usethis.r-lib.org/dev/reference/pull-requests.md)
also then sets an upstream tracking branch for the local branch that got
created and switches to that branch so the reviewer can make their
changes on the correct branch.

Once the reviewer makes the necessary changes, such as adding the
missing comma, they run
[`pr_push()`](https://usethis.r-lib.org/dev/reference/pull-requests.md)
to push their changes into our PR.

``` r
pr_push()
```

``` r
#> ✔ Checking that local branch 'mine-cetinkaya-rundel-formidable' has the changes in 'mine-cetinkaya-rundel/formidable'
#> ✔ Pushing local 'mine-cetinkaya-rundel-formidable' branch to 'mine-cetinkaya-rundel:formidable'
#> ✔ View PR at 'https://github.com/rladies/praise/pull/90' or call `pr_view()`
```

## Merge and finish

Finally, the reviewer merges our pull request on GitHub. Locally, they
can run
[`pr_finish()`](https://usethis.r-lib.org/dev/reference/pull-requests.md)
to switch back to the default branch (usually named `main` or `master`),
pull, delete the local branch created during the process of interacting
with our PR, and remove the associated remote.

``` r
pr_finish()
```

``` r
#> ✔ Checking that remote branch 'mine-cetinkaya-rundel/formidable' has the changes in 'local/mine-cetinkaya-rundel-formidable'
#> ✔ Switching back to 'master' branch
#> ✔ Pulling changes from GitHub source repo 'origin/master'
#> ✔ Deleting local 'mine-cetinkaya-rundel-formidable' branch
#> ✔ Removing remote 'mine-cetinkaya-rundel'
```

Since the reviewer has contributed some code to our pull request, we can
get that code back to our computer with
[`pr_pull()`](https://usethis.r-lib.org/dev/reference/pull-requests.md).
This is optional here, since the full PR has already been incorporated
into the default branch of the source repo (usually named `main` or
`master`). But
[`pr_pull()`](https://usethis.r-lib.org/dev/reference/pull-requests.md)
can be useful in PRs if there are a few rounds of alternating
contributions from you and the maintainer.

``` r
pr_pull()
```

``` r
#> ✓ Pulling from 'origin/formidable'
#> Performing fast-forward merge, no commit needed
```

Finally, we can also conclude the PR process on our end with
[`pr_finish()`](https://usethis.r-lib.org/dev/reference/pull-requests.md).

``` r
pr_finish()
```

``` r
#> ✓ Checking that remote branch 'origin/formidable' has the changes in 'formidable'
#> ✓ Switching back to default branch ('master')
#> ℹ Pulling changes from 'origin/master'
#> ✓ Deleting local 'formidable' branch
```

Remember you can see how this whole PR unfolded at
[rladies/praise#90](https://github.com/rladies/praise/pull/90).

## Other helpful functions

There are a few other functions in the `pr_*()` family that we didn’t
encounter in this PR scenario:

- [`pr_merge_main()`](https://usethis.r-lib.org/dev/reference/pull-requests.md)
  is used for getting changes that have occurred in the main line of
  development while we have been working on this PR. If you’re working
  in a fork, this does `git pull upstream master`. If you’re making a PR
  from an internal branch, this does `git pull origin master`. This can
  be useful to execute in your PR branch, if there are big changes in
  the project and your PR has become un-mergeable. This is also useful
  to execute whenever you return to the default branch (usually named
  `main` or `master`) and, indeed,
  [`pr_pause()`](https://usethis.r-lib.org/dev/reference/pull-requests.md)
  includes this. This makes sure that your copy of the package is
  up-to-date with the source repo.

- [`pr_pause()`](https://usethis.r-lib.org/dev/reference/pull-requests.md)
  makes sure you’re synced with the PR, switches back to the default
  branch, and calls
  [`pr_merge_main()`](https://usethis.r-lib.org/dev/reference/pull-requests.md)
  to keep you up-to-date with the source repo. This is likely something
  a package maintainer reviewing numerous PRs will need to use, as they
  switch back and forth between reviewing/extending PRs and the main
  line of development on the default branch.

- [`pr_resume()`](https://usethis.r-lib.org/dev/reference/pull-requests.md)
  helps you resume work on a PR after you’ve spent some time with
  another branch checked out. If you give it no arguments, it will
  present an interactive choice of local branches and indicates which,
  if any, are associated with a PR.
