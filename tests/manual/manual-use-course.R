devtools::load_all()
library(fs)

## Inspiration for manual tests. Pretty rough.

# download_zip() ----

## download_zip <- function(url, destdir = NULL, pedantic = TRUE) {...}

## destdir: NULL, given & exists, given & does not exist
## pedantic: TRUE, FALSE
## filesystem state: target filepath already exists & does not exist
## 3 * 2 * 3 combinations to look at, in theory, but many impossible/boring

## in reality, pedantic only matters when destdir = NULL and it's orthogonal
## to pre-existing file a target filepath
## if destdir doesn't exist, then target filepath can't exist

gh_url <- "https://github.com/r-lib/rematch2/archive/master.zip"

owd <- setwd(path_temp())

## Scenarios:

## destdir = NULL, pedantic = TRUE, target filepath doesn't exist ----
file_delete("rematch2-master.zip")
download_zip(gh_url, pedantic = TRUE)
## should get "Proceed...?" prompt
## no --> aborts
## yes --> downloads
expect_true(file_exists("rematch2-master.zip"))

## destdir = NULL, target filepath does exist ----
expect_true(file_exists("rematch2-master.zip"))
download_zip(gh_url)
## should get "Overwrite...?" query
## no --> aborts
## yes --> downloads
expect_true(file_exists("rematch2-master.zip"))

## destdir given & exists, target filepath doesn't exist ----
dir_create("a")
expect_true(file_exists("a"))
file_delete("a/rematch2-master.zip")
expect_false(file_exists("a/rematch2-master.zip"))
download_zip(gh_url, destdir = "a")
## should just download
expect_true(file_exists("a/rematch2-master.zip"))

## destdir given & exists, target filepath does exist ----
expect_true(file_exists("a/rematch2-master.zip"))
download_zip(gh_url, destdir = "a")
## should get "Overwrite...?" query
## no --> aborts
## yes --> downloads

## destdir given & does not exist ----
expect_false(file_exists("b"))
download_zip(gh_url, destdir = "b")
## should get error re: Directory does not exist

## Download from various places ----

## usethis-test folder JB created for development
dropbox1 <- "https://www.dropbox.com/sh/0pedgdob30bbbei/AACYL0JyZD6XcpZk_-YmtpgXa?dl=1"
download_zip(dropbox1, pedantic = FALSE)

## an actual workshop folder from Hadley (big and slow)
dropbox2 <- "https://www.dropbox.com/sh/ofc1gifr77ofej8/AACuBrToN1Yjo_ZxWfrYnEbJa?dl=1"
download_zip(dropbox2, pedantic = FALSE)

## the ZIP URL favored by devtools
gh_url <- "http://github.com/r-lib/rematch2/zipball/master/"
download_zip(gh_url, pedantic = FALSE)

## don't be surprised if asked whether to Overwrite, this may have been
## downloaded before, via other means
bitly <- "http://bit.ly/uusseetthhiiss"
download_zip(bitly, pedantic = FALSE)

# tidy_unzip() ----

## if they are in wd
tidy_unzip("17-tidy-tools.zip")
tidy_unzip("r-lib-rematch2-335a55f.zip")
tidy_unzip("rematch2-master.zip")
tidy_unzip("usethis-test.zip")

## if they are in ~/tmp
tidy_unzip("~/tmp/manual/17-tidy-tools.zip")
tidy_unzip("~/tmp/manual/r-lib-rematch2-335a55f.zip")
tidy_unzip("rematch2-master.zip")
tidy_unzip("~/tmp/manual/usethis-test.zip")

# one-off test of GitHub vs DropBox
download_zip("https://github.com/jennybc/yo/archive/master.zip", pedantic = FALSE)
download_zip("https://www.dropbox.com/sh/afydxe6pkpz8v6m/AADHbMZAaW3IQ8zppH9mjNsga?dl=1", pedantic = FALSE)

tidy_unzip("yo-master.zip")
file_move("yo-master", "yo")
## git commit here
file_delete("yo")
tidy_unzip("yo.zip")
## should see no diff on files in yo

## Usage to feature in PR

devtools::load_all("")

## ZIP from GitHub (it's a package, but you get the idea)
rematch2 <- use_course("https://github.com/r-lib/rematch2/archive/master.zip")
dir_ls(rematch2, all = TRUE, recursive = TRUE)

devtools::load_all("")

system.time(
hadley <- use_course(
"https://www.dropbox.com/sh/ofc1gifr77ofej8/AACuBrToN1Yjo_ZxWfrYnEbJa?dl=1"
)
)

dir_ls(hadley, all = TRUE, recursive = TRUE)

rematch2 <- use_course("github.com/r-lib/rematch2/archive/master.zip")
use_course("rstd.io/usethis-src")
use_course("bit.ly/uusseetthhiiss")

setwd(owd)
