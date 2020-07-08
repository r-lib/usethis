library(usethis)
library(fs)
library(testthat)

options(usethis.destdir = NULL)

cp <- function(x = "") path(usethis:::conspicuous_place(), x)

## use_course() simple usage ----
# Should see:
# 1. Menu confirming download to conspicuous place
# 2. Menu approving deletion of ZIP file
use_course("r-lib/rematch2")

dir_delete(cp("rematch2-master"))
file_delete(cp("rematch2-master.zip"))

## use_course() overwriting existing file ----
use_zip("r-lib/rematch2", destdir = cp(), cleanup = FALSE)
use_course("r-lib/rematch2", destdir = cp())
# Should see:
# Query whether to overwrite pre-existing file
# "No" aborts
# "Yes" proceeds
dir_delete(cp("rematch2-master"))
file_delete(cp("rematch2-master.zip"))

# download of a DropBox folder
# usethis-manual-test folder JB created for development
dropbox <- "https://www.dropbox.com/sh/iep7x58py4vpa9n/AAAju4kvYCjjD6s8WJqyICHBa?dl=1"
use_zip(dropbox, destdir = cp())
expect_true(dir_exists(cp("usethis-manual-test")))
dir_delete(cp("usethis-manual-test"))
file_delete(cp("usethis-manual-test.zip"))

## the ZIP URL favored by devtools
gh_url <- "http://github.com/r-lib/rematch2/zipball/master/"
folder <- use_zip(gh_url, destdir = cp(), cleanup = FALSE)
(zipfile <- dir_ls(cp(), regexp = "r-lib-rematch2-.*[.]zip"))
expect_length(zipfile, 1)
file_delete(zipfile)
dir_delete(folder)
