# Download and unpack a ZIP file

Functions to download and unpack a ZIP file into a local folder of
files, with very intentional default behaviour. Useful in pedagogical
settings or anytime you need a large audience to download a set of files
quickly and actually be able to find them. After download, the new
folder is opened in a new session of the user's IDE, if possible, or in
the default file manager provided by the operating system. The
underlying helpers are documented in
[use_course_details](https://usethis.r-lib.org/dev/reference/use_course_details.md).

## Usage

``` r
use_course(url, destdir = getOption("usethis.destdir"))

use_zip(
  url,
  destdir = getwd(),
  cleanup = if (rlang::is_interactive()) NA else FALSE
)
```

## Arguments

- url:

  Link to a ZIP file containing the materials. To reduce the chance of
  typos in live settings, these shorter forms are accepted:

  - GitHub repo spec: "OWNER/REPO". Equivalent to
    `https://github.com/OWNER/REPO/DEFAULT_BRANCH.zip`.

  - bit.ly, pos.it, or rstd.io shortlinks: "bit.ly/xxx-yyy-zzz",
    "pos.it/foofy" or "rstd.io/foofy". The instructor must then arrange
    for the shortlink to point to a valid download URL for the target
    ZIP file. The helper
    [`create_download_url()`](https://usethis.r-lib.org/dev/reference/use_course_details.md)
    helps to create such URLs for GitHub, DropBox, and Google Drive.

- destdir:

  Destination for the new folder. Defaults to the location stored in the
  global option `usethis.destdir`, if defined, or to the user's Desktop
  or similarly conspicuous place otherwise.

- cleanup:

  Whether to delete the original ZIP file after unpacking its contents.
  In an interactive setting, `NA` leads to a menu where user can approve
  the deletion (or decline).

## Value

Path to the new directory holding the unpacked ZIP file, invisibly.

## Functions

- `use_course()`: Designed with live workshops in mind. Includes
  intentional friction to highlight the download destination. Workflow:

  - User executes, e.g., `use_course("bit.ly/xxx-yyy-zzz")`.

  - User is asked to notice and confirm the location of the new folder.
    Specify `destdir` or configure the `"usethis.destdir"` option to
    prevent this.

  - User is asked if they'd like to delete the ZIP file.

  - If possible, the new folder is launched in a new session of the
    user's IDE. Otherwise, the folder is opened in the file manager,
    e.g. Finder on macOS or File Explorer on Windows.

- `use_zip()`: More useful in day-to-day work. Downloads in current
  working directory, by default, and allows `cleanup` behaviour to be
  specified.

## Examples

``` r
if (FALSE) { # \dontrun{
# download the source of usethis from GitHub, behind a bit.ly shortlink
use_course("bit.ly/usethis-shortlink-example")
use_course("http://bit.ly/usethis-shortlink-example")

# download the source of rematch2 package from CRAN
use_course("https://cran.r-project.org/bin/windows/contrib/4.5/rematch2_2.1.2.zip")

# download the source of rematch2 package from GitHub, 4 ways
use_course("r-lib/rematch2")
use_course("https://api.github.com/repos/r-lib/rematch2/zipball/HEAD")
use_course("https://api.github.com/repos/r-lib/rematch2/zipball/main")
use_course("https://github.com/r-lib/rematch2/archive/main.zip")
} # }
```
