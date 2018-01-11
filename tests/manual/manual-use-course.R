devtools::load_all("~/rrr/usethis")

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

## Scenarios:

## destdir = NULL, pedantic = TRUE, target filepath doesn't exist ----
unlink("rematch2-master.zip")
download_zip(gh_url)
## should get "Proceed...?" prompt
## no --> aborts
## yes --> downloads
expect_true(file.exists("rematch2-master.zip"))

## destdir = NULL, target filepath does exist ----
expect_true(file.exists("rematch2-master.zip"))
download_zip(gh_url)
## should get "Proceed...?" prompt SAY YES
## should get "Overwrite...?" query
## no --> aborts
## yes --> downloads
expect_true(file.exists("rematch2-master.zip"))

## destdir given & exists, target filepath doesn't exist ----
expect_true(file.exists("~/tmp/a"))
unlink("~/tmp/a/rematch2-master.zip")
expect_false(file.exists("~/tmp/a/rematch2-master.zip"))
download_zip(gh_url, destdir = "~/tmp/a")
## should just download
expect_true(file.exists("~/tmp/a/rematch2-master.zip"))

## destdir given & exists, target filepath does exist ----
expect_true(file.exists("~/tmp/a/rematch2-master.zip"))
download_zip(gh_url, destdir = "~/tmp/a")
## should get "Overwrite...?" query
## no --> aborts
## yes --> downloads

## destdir given & does not exist ----
expect_false(file.exists("~/tmp/b"))
download_zip(gh_url, destdir = "~/tmp/b")
## should get error re: Directory does not exist

## just try a bunch of things
## usethis-test folder JB created for development
dropbox1 <- "https://www.dropbox.com/sh/0pedgdob30bbbei/AACYL0JyZD6XcpZk_-YmtpgXa?dl=1"
download_zip(dropbox1, pedantic = FALSE)
## an actual workshop folder from Hadley (big and slow)
dropbox2 <- "https://www.dropbox.com/sh/ofc1gifr77ofej8/AACuBrToN1Yjo_ZxWfrYnEbJa?dl=1"
download_zip(dropbox2, pedantic = FALSE)
gh_url <- "http://github.com/r-lib/rematch2/zipball/master/"
download_zip(gh_url, pedantic = FALSE)

## don't be surprised if asked whether to Overwrite, this has been downloaded
## before, via other means
bitly <- "http://bit.ly/uusseetthhiiss"
download_zip(bitly, pedantic = FALSE)

# tidy_unzip() ----
