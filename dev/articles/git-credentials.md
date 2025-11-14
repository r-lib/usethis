# Managing Git(Hub) Credentials

``` r
library(usethis)
```

usethis can help you with many of the Git and GitHub tasks that arise
when managing R projects and packages. Under the hood, two lower-level
packages are critical to this:

- gert, for Git operations, like `git init`, `git commit`, and
  `git push` ([docs.ropensci.org/gert](https://docs.ropensci.org/gert/))
- gh, for GitHub API operations, like creating a repo, forking a repo,
  and opening a pull request ([gh.r-lib.org](https://gh.r-lib.org/))

Both packages need access to credentials in order to act on your behalf:

- gert interacts with GitHub as a Git server, using either the HTTPS or
  SSH protocol
- gh interacts with GitHub via its REST API

This article describes our recommendations for how to set up your Git
and GitHub credentials. Our goal is a setup that works well for usethis
**and** for other tools you may be using, such as command line Git and
Git clients (including, but not limited to, RStudio).

*This is a good time to check that you have up-to-date versions of the
packages we’re talking about here. In particular, you want gh \>=
v1.2.1, which knows about the new token format GitHub announced and
adopted in March 2021.*

## TL;DR: Use HTTPS, 2FA, and a GitHub Personal Access Token

Our main recommendations are:

1.  Adopt HTTPS as your Git transport protocol.
2.  Turn on two-factor authentication for your GitHub account.
3.  Use a personal access token (PAT) for all Git remote operations from
    the command line or from R.
4.  Allow tools to store and retrieve your credentials from the Git
    credential store. If you have previously set your GitHub PAT in
    `.Renviron`, **stop doing that**.

Next we provide some context and a rationale for these recommendations.
In the following section, we explain how to actually implement this.

### HTTPS vs SSH

Instead of HTTPS, you could use SSH. Many people have valid reasons for
preferring SSH and they should carry on. Our recommendation for HTTPS is
because it’s easier than SSH for newcomers to set up correctly,
especially on Windows. GitHub has also long recommended HTTPS to new
users. Finally, using HTTPS with a PAT kills two birds with one stone:
this single credential can be used to authenticate to GitHub as a
regular Git server and for its REST API. If you authenticate via SSH for
“regular” Git work, you still have to set up a PAT for work that uses
the REST API.

![Diagram showing different ways of interacting with GitHub as a server
and the credential needed for each
method](img/pat-kills-both-birds.jpeg)

### Two-factor authentication

Turning on two-factor authentication for important online accounts is
just a good idea, in general. For example, we make 2FA a hard
requirement for all members of the tidyverse and r-lib GitHub
organizations.

In the past, activating 2FA also forced those using HTTPS to use a PAT,
instead of “username + password”, for operations like `git push`. Using
a PAT is now an absolute requirement, for all operations using the HTTPS
protocol, and no longer has anything to do with 2FA.

More background on the deprecation of “username + password” can be found
in GitHub’s blog post [Token authentication requirements for Git
operations](https://github.blog/2020-12-15-token-authentication-requirements-for-git-operations/).

### Git credential helpers and the credential store

It’s awkward to provide your credentials for every single Git
transaction, so it’s customary to let your system remember your
credentials. Git uses so-called credential helpers for this and,
happily, they tend to “just work” these days (especially, on macOS and
Windows) [¹](#fn1). Git credential helpers take advantage of official
OS-provided credential stores, where possible, such as macOS Keychain
and Windows Credential Manager.

Recent innovations in gert and gh mean that Git/GitHub operations from R
can also store and discover credentials using these same official Git
credential helpers. This means we can stop storing GitHub PATs in plain
text in a startup file, like `.Renviron` [²](#fn2). This, in turn,
reduces the risk of accidentally leaking your credentials.

## Practical instructions

How do you actually implement these recommendations? The diagnostic
functions
[`usethis::gh_token_help()`](https://usethis.r-lib.org/dev/reference/github-token.md)
and
[`usethis::git_sitrep()`](https://usethis.r-lib.org/dev/reference/git_sitrep.md)
will offer some of the advice you see here, but directly in your R
session.

### Adopt HTTPS

Make sure to use HTTPS URLs, not SSH, when cloning repos or adding new
remotes:

- HTTPS URLs look like this: `https://github.com/<OWNER>/<REPO>.git`
- SSH URLs look like this: `git@github.com:<OWNER>/<REPO>.git`

usethis defaults to HTTPS in functions like
[`create_from_github()`](https://usethis.r-lib.org/dev/reference/create_from_github.md)
and
[`use_github()`](https://usethis.r-lib.org/dev/reference/use_github.md),
as of v2.0.0[³](#fn3).

It’s fine to adopt HTTPS for new work, even if some of your pre-existing
repos use SSH.  
It’s fine to use HTTPS for one remote in a repo and SSH for another.  
It’s fine to use HTTPS remotes for one repo and SSH remotes for
another.  
It’s fine to interact with a GitHub repo via HTTPS from one computer and
via SSH from another.  
This is not an all-or-nothing or irreversible decision.  
As long as the relevant tools can obtain the necessary credentials from
a cache or you, you are good to go.

### Turn on two-factor authentication

See GitHub’s most current instructions here:

[Securing your account with two-factor authentication
(2FA)](https://docs.github.com/en/authentication/securing-your-account-with-two-factor-authentication-2fa)

If you don’t already use a password manager such as 1Password or
Bitwarden, this is a great time to start! Among other benefits, these
apps can serve as an authenticator for 2FA.

Turning on 2FA is recommended, but optional.

### Get a personal access token (PAT)

``` r
usethis::create_github_token()
```

Assuming you’re signed into GitHub,
[`create_github_token()`](https://usethis.r-lib.org/dev/reference/github-token.md)
takes you to a pre-filled form to create a new PAT. You can get to the
same page in the browser by clicking on “Generate new token” from
<https://github.com/settings/tokens>. The advantage of
[`create_github_token()`](https://usethis.r-lib.org/dev/reference/github-token.md)
is that we have pre-selected some recommended scopes, which you can look
over and adjust before clicking “Generate token”.

![Screenshot: Getting a new personal access token on
GitHub](img/new-personal-access-token-screenshot.png)

It is a very good idea to describe the token’s purpose in the *Note*
field, because one day you might have multiple PATs. We recommend naming
each token after its use case, such as the computer or project you are
using it for, e.g. “personal-macbook-air” or “vm-for-project-xyz”. In
the future, you will find yourself staring at this list of tokens,
because inevitably you’ll need to re-generate or delete one of them.
Make it easy to figure out which token you need to fiddle with.

GitHub encourages the use of perishable tokens, with a default
*Expiration* period of 30 days. Unless you have a specific reason to
fight this, I recommend accepting this default. I assume that GitHub’s
security folks have good reasons for their recommendation. But, of
course, you can adjust the *Expiration* behaviour as you see fit,
including “No expiration”.

Once you’re happy with the token’s *Note*, *Expiration*, and *Scopes*,
click “Generate token”.

You won’t be able to see this token again, so don’t close or navigate
away from this browser window until you store the PAT locally. Copy the
PAT to the clipboard, anticipating what we’ll do next: trigger a prompt
that lets us store the PAT in the Git credential store.

Sidebar about storing your PAT: If you use a password management app,
such as 1Password or Bitwarden (highly recommended!), you might want to
add this PAT (and its *Note*) to the entry for GitHub. Storing your PAT
in the Git credential store is a semi-persistent convenience, sort of
like a browser cache or “remember me” on a website, but it’s quite
possible you will need to re-enter your PAT in the future. You could
decide to embrace the impermanence of your PAT and, if it is somehow
removed from the store, you’ll just re-generate a new PAT and re-enter
it. If you accept the default 30-day expiration period, this is a
workflow you’ll be using often anyway. But if you create long-lasting
tokens or want to play around with the functions for setting or clearing
your Git credentials, it can be handy to have your own record of your
PAT in a secure place, like 1Password or Bitwarden.

### Put your PAT into the local Git credential store

We assume you’ve created a PAT and have it available on your clipboard.

How to insert your PAT in the Git credential store? Do this in R:

``` r
gitcreds::gitcreds_set()
```

You will have the [gitcreds package](https://r-lib.github.io/gitcreds/)
installed, as of usethis v2.0.0, because usethis uses gh, and gh uses
gitcreds.

If you don’t have a PAT stored already, it will prompt you to enter your
PAT. Paste!

``` sh
> gitcreds::gitcreds_set()

? Enter password or token: ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
-> Adding new credentials...
-> Removing credentials from cache...
-> Done.
```

If you already have a stored credential,
[`gitcreds::gitcreds_set()`](https://gitcreds.r-lib.org/reference/gitcreds_get.html)
reveals this and will even let you inspect it. This helps you decide
whether to keep the existing credential or replace it. When in doubt,
embrace a new, known-to-be-good credential over an old one, of uncertain
origins.

``` sh
> gitcreds::gitcreds_set()

-> Your current credentials for 'https://github.com':

  protocol: https
  host    : github.com
  username: PersonalAccessToken
  password: <-- hidden -->

-> What would you like to do? 

1: Keep these credentials
2: Replace these credentials
3: See the password / token

Selection: 2

-> Removing current credentials...

? Enter new password or token: ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
-> Adding new credentials...
-> Removing credentials from cache...
-> Done.
```

**If you have previously made your GitHub PAT available by setting the
`GITHUB_PAT` environment variable in `.Renviron`, you need to actively
stop doing that!** If you have any doubt about your previous practices,
open `.Renviron`, look for any line setting the `GITHUB_PAT` or
`GITHUB_TOKEN` environment variable, and delete that line.
[`usethis::edit_r_environ()`](https://usethis.r-lib.org/dev/reference/edit.md)
can be helpful for getting `.Renviron` open for editing. Don’t forget to
restart R for this change to take effect!

You can check that your PAT has been successfully stored with
[`usethis::gh_token_help()`](https://usethis.r-lib.org/dev/reference/github-token.md)
**executed in a fresh R session**:

``` r
gh_token_help()
```

The more general function
[`usethis::git_sitrep()`](https://usethis.r-lib.org/dev/reference/git_sitrep.md)
will also report on your PAT, along with other aspects of your
Git/GitHub setup.

``` r
git_sitrep()
```

### Ongoing PAT maintenance

You are going to be (re-)generating and (re-)storing your PAT on a
schedule dictated by its expiration period. By default, once per month.

When the PAT expires, return to <https://github.com/settings/tokens> and
click on its *Note*. (You do label your tokens nicely by use case,
right? Right?) At this point, you can optionally adjust scopes and then
click “Regenerate token”. You can optionally modify its *Expiration* and
then click “Regenerate token” (again). As before, copy the PAT to the
clipboard, call
[`gitcreds::gitcreds_set()`](https://gitcreds.r-lib.org/reference/gitcreds_get.html),
and paste!

Hopefully it’s becoming clear why each token’s *Note* is so important.
The actual token may be changing, e.g., once a month, but its use case
(and scopes) are much more persistent and stable.

Sidebar: the gitcreds package plays the same role for gh as the
[credentials package](https://docs.ropensci.org/credentials/) does for
gert. Both gitcreds and credentials provide an R interface to the Git
credential store, but are targeting slightly different use cases. The
gitcreds and credentials packages are evolving convergently and may, in
fact, merge into one. But in the meantime, there is some chance that
they use a different “key”, in the “key-value” sense, when storing or
retrieving your PAT. Therefore, it is conceivable that gert+credentials
may also prompt you once for your PAT, in which case you should just
provide it again. To explicitly check if gert+credentials can discover
your PAT, call
[`credentials::set_github_pat()`](https://docs.ropensci.org/credentials/reference/set_github_pat.html).
If it cannot, this will lead to a prompt where you can enter it.

## Additional resources

Most users should be ready to work with Git and GitHub from R now,
specifically with gert, gh, and usethis. In this section, we cover more
specialized topics that only apply to certain users.

### GitHub Enterprise

As of v2.0.0, usethis should fully support GitHub Enterprise
deployments. If you find this is not true, please [open an
issue](https://github.com/r-lib/usethis/issues/new).

There are a few usethis functions that support an explicit `host`
argument, but in general, usethis honors the GitHub host implicit in
URLs, e.g., the locally configured Git remotes, or inherits the default
behaviour of gh. The gh package honors the `GITHUB_API_URL` environment
variable which, when unset, falls back to `https://api.github.com`.

In general, usethis, gh, and gitcreds should all work with GitHub
Enterprise, as long as the intended GitHub host is discoverable or
specified. For example, you can store a PAT for a GitHub Enterprise
deployment like so:

``` r
gitcreds::gitcreds_set("https://github.acme.com")
```

You can also troubleshoot PATs with GHE with the usual functions:

``` r
usethis::gh_token_help("https://github.acme.com")
# or
usethis::git_sitrep()
```

At the time of writing,
[`credentials::set_github_pat()`](https://docs.ropensci.org/credentials/reference/set_github_pat.html)
is hard-wired to “github.com”, but this may be generalized in the
future.

### What about `.Renviron`?

In the past, the most common way to make a GitHub PAT available in R was
to define it as the `GITHUB_PAT` environment variable in the `.Renviron`
startup file. This still works, since gitcreds+gh and credentials+gert
check environment variables before they consult the Git credential
store. However, this also means that the presence of a legacy
`GITHUB_PAT` in your `.Renviron` can get in the way of your adoption of
the new approach!

If you have any doubt about your previous practices, open `.Renviron`,
look for any line setting the `GITHUB_PAT` environment variable, and
delete it.
[`usethis::edit_r_environ()`](https://usethis.r-lib.org/dev/reference/edit.md)
can be helpful for getting `.Renviron` open for editing. Don’t forget to
restart R for this change to take effect.

Why do gitcreds+gh and credentials+gert even check environment
variables? Once they retrieve a PAT from the store, they temporarily
cache it in an environment variable, which persists for the duration of
the current R session. This allows a discovered PAT to be reused,
potentially by multiple packages, repeatedly over the course of an R
session.

Using `.Renviron` as your primary PAT store is less secure and, if you
can, it is safer to keep your PAT in the Git credential store and let
packages that need it to discover it there upon first need. Linux users
may still need to use the `.Renviron` method, since they don’t have easy
access to OS-managed stores like the macOS Keychain or Windows
Credential Manager.

If you still need to use `.Renviron` method,
[`usethis::edit_r_environ()`](https://usethis.r-lib.org/dev/reference/edit.md)
opens that file for editing.

``` r
usethis::edit_r_environ()
```

Add a line like this, **but substitute your PAT**:

``` sh
GITHUB_PAT=ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

Make sure this file ends in a newline! Lack of a newline can lead to
silent failure to load startup files, which can be tricky to debug. Take
care that this file is not accidentally pushed to the cloud, e.g. Google
Drive or GitHub.

Restart R for changes in `.Renviron` to take effect.

### What about the remotes and pak packages?

The [remotes](https://remotes.r-lib.org) and
[pak](https://pak.r-lib.org) packages both help us to install R packages
from GitHub:

``` r
remotes::install_github("r-lib/usethis")

pak::pkg_install("r-lib/usethis")
```

Lifecycle-wise, remotes is being replaced by pak, but we are still in
the transition period, where both are maintained.

Both of these packages potentially need a GitHub PAT. A PAT is
necessary, for example, to install from a private GitHub repo. Even when
accessing public resources, a PAT is helpful because it implies a much
higher rate limit for requests to the GitHub API.

pak uses the same PAT-finding approach as usethis/gh/gitcreds. Once
you’ve done the setup described above, pak should “just work”, with the
same PAT as everything else.

remotes does NOT use the new PAT-finding approach and, instead, only
consults the `GITHUB_PAT` environment variable, falling back to a
built-in generic credential.

What should you do re: installing packages from GitHub?

My personal recommendation: Use `pak::pkg_install("OWNER/REPO")` for
your explicit “install from GitHub” needs. Allow remotes to use its
fallback credential, if it ever gets called implicitly. Do NOT define
`GITHUB_PAT` in `.Renviron`.

If you want to keep using remotes, instead of pak, you could just rely
on the built-in credential. This will suffice if rate-limiting is the
only concern, but obviously will not provide access to private
repositories.

If you really want to use remotes, with your own PAT, you can “tickle”
gitcreds, via
[`gitcreds::gitcreds_get()`](https://gitcreds.r-lib.org/reference/gitcreds_get.html),
to get it to load your PAT from the store into the `GITHUB_PAT`
environment variable, where remotes will happily find it. This could be
done interactively as needed, written into individual scripts, or even
executed in a startup file. This still avoids defining `GITHUB_PAT` in
`.Renviron`.

``` r
Sys.setenv(GITHUB_PAT = gitcreds::gitcreds_get(use_cache = FALSE)$password)
```

If you use remotes, make sure to update to the latest version, to
guarantee that the built-in credential is valid.

### Continuous integration

On a headless system, such as on a CI/CD platform like GitHub Actions,
you won’t be able to interactively store a PAT with
[`gitcreds::gitcreds_set()`](https://gitcreds.r-lib.org/reference/gitcreds_get.html)
or
[`credentials::set_github_pat()`](https://docs.ropensci.org/credentials/reference/set_github_pat.html).
In the case of GitHub Actions, an access token is automatically
available to the workflow and can be exposed to R as the `GITHUB_PAT`
environment variable like so:

``` yaml
env:
  GITHUB_PAT: ${{ secrets.GITHUB_TOKEN }}
```

If this automatic token doesn’t have sufficient permissions, you’ll need
to create a suitable token and store it as a repository secret.

This is also the general approach for CI/CD platforms other than GitHub
Actions:

- Provide the PAT as a secure `GITHUB_PAT` environment variable.
- Use regular environment variables to store less sensitive settings,
  such as the API host.

Take care not to expose your PAT by, e.g., printing environment
variables to a log file.

## How to learn more

gh and gitcreds

- gh: [gh.r-lib.org](https://gh.r-lib.org/)
- gh vignette: [Managing Personal Access
  Tokens](https://gh.r-lib.org/articles/managing-personal-access-tokens.html)
- gitcreds:
  [r-lib.github.io/gitcreds/](https://r-lib.github.io/gitcreds/)

gert and credentials

- gert: [docs.ropensci.org/gert](https://docs.ropensci.org/gert/)
- credentials:
  [docs.ropensci.org/credentials](https://docs.ropensci.org/credentials/)
- rOpenSci tech note: [A better way to manage your GitHub personal
  access tokens](https://ropensci.org/technotes/2020/07/07/github-pat/)

------------------------------------------------------------------------

1.  If you’re trying to follow the advice in this article and things
    don’t work the way we say they do, consider that you may need to
    update Git. Credential helpers are absolutely an area of Git that
    has improved rapidly in recent years and the gitcreds and
    credentials package work best with recent versions of Git.

2.  An even more dangerous practice is to hard-code a PAT in an R
    script, which is never a good idea.

3.  As always, the `usethis.protocol` option can be configured to
    customize your own default.
