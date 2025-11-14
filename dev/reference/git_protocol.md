# See or set the default Git protocol

Git operations that address a remote use a so-called "transport
protocol". usethis supports HTTPS and SSH. The protocol dictates the Git
URL format used when usethis needs to configure the first GitHub remote
for a repo:

- `protocol = "https"` implies `https://github.com/<OWNER>/<REPO>.git`

- `protocol = "ssh"` implies `git@github.com:<OWNER>/<REPO>.git`

Two helper functions are available:

- `git_protocol()` reveals the protocol "in force". As of usethis
  v2.0.0, this defaults to "https". You can change this for the duration
  of the R session with `use_git_protocol()`. Change the default for all
  R sessions with code like this in your `.Rprofile` (easily editable
  via
  [`edit_r_profile()`](https://usethis.r-lib.org/dev/reference/edit.md)):

      options(usethis.protocol = "ssh")

- `use_git_protocol()` sets the Git protocol for the current R session

This protocol only affects the Git URL for newly configured remotes. All
existing Git remote URLs are always respected, whether HTTPS or SSH.

## Usage

``` r
git_protocol()

use_git_protocol(protocol)
```

## Arguments

- protocol:

  One of "https" or "ssh"

## Value

The protocol, either "https" or "ssh"

## Examples

``` r
if (FALSE) { # \dontrun{
git_protocol()

use_git_protocol("ssh")
git_protocol()

use_git_protocol("https")
git_protocol()
} # }
```
