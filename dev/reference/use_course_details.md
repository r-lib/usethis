# Helpers to download and unpack a ZIP file

Details on the internal and helper functions that power
[`use_course()`](https://usethis.r-lib.org/dev/reference/zip-utils.md)
and [`use_zip()`](https://usethis.r-lib.org/dev/reference/zip-utils.md).
Only `create_download_url()` is exported.

## Usage

``` r
tidy_download(url, destdir = getwd())
tidy_unzip(zipfile, cleanup = FALSE)

create_download_url(url)
```

## Arguments

- url:

  A GitHub, DropBox, or Google Drive URL.

  - For `create_download_url()`: A URL copied from a web browser.

  - For `tidy_download()`: A download link for a ZIP file, possibly
    behind a shortlink or other redirect. `create_download_url()` can be
    helpful for creating this URL from typical browser URLs.

- destdir:

  Path to existing local directory where the ZIP file will be stored.
  Defaults to current working directory, but note that
  [`use_course()`](https://usethis.r-lib.org/dev/reference/zip-utils.md)
  has different default behavior.

- zipfile:

  Path to local ZIP file.

- cleanup:

  Whether to delete the ZIP file after unpacking. In an interactive
  session, `cleanup = NA` leads to asking the user if they want to
  delete or keep the ZIP file.

## tidy_download()

    # how it's used inside use_course()
    tidy_download(
      # url has been processed with internal helper normalize_url()
      url,
      # conspicuous_place() = `getOption('usethis.destdir')` or desktop or home
      # directory or working directory
      destdir = destdir %||% conspicuous_place()
    )

Special-purpose function to download a ZIP file and automatically
determine the file name, which often determines the folder name after
unpacking. Developed with DropBox and GitHub as primary targets,
possibly via shortlinks. Both platforms offer a way to download an
entire folder or repo as a ZIP file, with information about the original
folder or repo transmitted in the `Content-Disposition` header. In the
absence of this header, a filename is generated from the input URL. In
either case, the filename is sanitized. Returns the path to downloaded
ZIP file, invisibly.

`tidy_download()` is setup to retry after a download failure. In an
interactive session, it asks for user's consent. All retries use a
longer connect timeout.

### DropBox

To make a folder available for ZIP download, create a shared link for
it:

- <https://help.dropbox.com/share/create-and-share-link>

A shared link will have this form:

    https://www.dropbox.com/sh/12345abcde/6789wxyz?dl=0

Replace the `dl=0` at the end with `dl=1` to create a download link:

    https://www.dropbox.com/sh/12345abcde/6789wxyz?dl=1

You can use `create_download_url()` to do this conversion.

This download link (or a shortlink that points to it) is suitable as
input for `tidy_download()`. After one or more redirections, this link
will eventually lead to a download URL. For more details, see
<https://help.dropbox.com/share/force-download> and
<https://help.dropbox.com/sync/download-entire-folders>.

### GitHub

Click on the repo's "Clone or download" button, to reveal a "Download
ZIP" button. Capture this URL, which will have this form:

    https://github.com/r-lib/usethis/archive/main.zip

This download link (or a shortlink that points to it) is suitable as
input for `tidy_download()`. After one or more redirections, this link
will eventually lead to a download URL. Here are other links that also
lead to ZIP download, albeit with a different filenaming scheme (REF
could be a branch name, a tag, or a SHA):

    https://github.com/github.com/r-lib/usethis/zipball/HEAD
    https://api.github.com/repos/r-lib/rematch2/zipball/REF
    https://api.github.com/repos/r-lib/rematch2/zipball/HEAD
    https://api.github.com/repos/r-lib/usethis/zipball/REF

You can use `create_download_url()` to create the "Download ZIP" URL
from a typical GitHub browser URL.

### Google Drive

To our knowledge, it is not possible to download a Google Drive folder
as a ZIP archive. It is however possible to share a ZIP file stored on
Google Drive. To get its URL, click on "Get the shareable link" (within
the "Share" menu). This URL doesn't allow for direct download, as it's
designed to be processed in a web browser first. Such a sharing link
looks like:

    https://drive.google.com/open?id=123456789xxyyyzzz

To be able to get the URL suitable for direct download, you need to
extract the "id" element from the URL and include it in this URL format:

    https://drive.google.com/uc?export=download&id=123456789xxyyyzzz

Use `create_download_url()` to perform this transformation
automatically.

## tidy_unzip()

Special-purpose function to unpack a ZIP file and (attempt to) create
the directory structure most people want. When unpacking an archive, it
is easy to get one more or one less level of nesting than you expected.

It's especially important to finesse the directory structure here: we
want the same local result when unzipping the same content from either
GitHub or DropBox ZIP files, which pack things differently. Here is the
intent:

- If the ZIP archive `foo.zip` does not contain a single top-level
  directory, i.e. it is packed as "loose parts", unzip into a directory
  named `foo`. Typical of DropBox ZIP files.

- If the ZIP archive `foo.zip` has a single top-level directory (which,
  by the way, is not necessarily called "foo"), unpack into said
  directory. Typical of GitHub ZIP files.

Returns path to the directory holding the unpacked files, invisibly.

**DropBox:** The ZIP files produced by DropBox are special. The file
list tends to contain a spurious directory `"/"`, which we ignore during
unzip. Also, if the directory is a Git repo and/or RStudio Project, we
unzip-ignore various hidden files, such as `.RData`, `.Rhistory`, and
those below `.git/` and `.Rproj.user`.

## Examples

``` r
if (FALSE) { # \dontrun{
tidy_download("https://github.com/r-lib/rematch2/archive/main.zip")
tidy_unzip("rematch2-main.zip")
} # }
# GitHub
create_download_url("https://github.com/r-lib/usethis")
#> [1] "https://github.com/r-lib/usethis/zipball/HEAD"
create_download_url("https://github.com/r-lib/usethis/issues")
#> [1] "https://github.com/r-lib/usethis/zipball/HEAD"

# DropBox
create_download_url("https://www.dropbox.com/sh/12345abcde/6789wxyz?dl=0")
#> [1] "https://www.dropbox.com/sh/12345abcde/6789wxyz?dl=1"

# Google Drive
create_download_url("https://drive.google.com/open?id=123456789xxyyyzzz")
#> [1] "https://drive.google.com/uc?export=download&id=123456789xxyyyzzz"
create_download_url("https://drive.google.com/open?id=123456789xxyyyzzz/view")
#> [1] "https://drive.google.com/uc?export=download&id=123456789xxyyyzzz"
```
