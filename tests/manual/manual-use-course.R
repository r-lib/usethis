devtools::load_all("~/rrr/usethis")

# ZIP file URLs ----

## usethis-test folder JB created for development
dropbox1 <- "https://www.dropbox.com/sh/0pedgdob30bbbei/AACYL0JyZD6XcpZk_-YmtpgXa?dl=1"
## an actual workshop folder from Hadley (big and slow)
dropbox2 <- "https://www.dropbox.com/sh/ofc1gifr77ofej8/AACuBrToN1Yjo_ZxWfrYnEbJa?dl=1"
gh_url <- "https://github.com/jennybc/buzzy/archive/master.zip"
bitly <- "http://bit.ly/uusseetthhiiss"

# download_zip() ----

## download_zip <- function(url, destdir = NULL, pedantic = TRUE) {...}

## destdir: NULL, given & exists, given & does not exist
## pedantic: TRUE, FALSE
## filesystem state: target filepath already exists & does not exist
## 3 * 2 * 3 combinations to look at, in theory, but many impossible/boring

## in reality, pedantic only matters when destdir = NULL and it's orthogonal
## to pre-existing file a target filepath
## if destdir doesn't exist, then target filepath can't exist

## Scenarios:

## destdir = NULL, pedantic = TRUE, target filepath doesn't exist ----
unlink("buzzy-master.zip")
download_zip(gh_url)
## should get "Proceed...?" prompt
## no --> aborts
## yes --> downloads
expect_true(file.exists("buzzy-master.zip"))

## destdir = NULL, target filepath does exist ----
expect_true(file.exists("buzzy-master.zip"))
download_zip(gh_url)
## should get "Proceed...?" prompt SAY YES
## should get "Overwrite...?" query
## no --> aborts
## yes --> downloads
expect_true(file.exists("buzzy-master.zip"))

## destdir given & exists, target filepath doesn't exist ----
expect_true(file.exists("~/tmp/a"))
expect_false(file.exists("~/tmp/a/buzzy-master.zip"))
download_zip(gh_url, destdir = "~/tmp/a")
## should just download
expect_true(file.exists("~/tmp/a/buzzy-master.zip"))

## destdir given & exists, target filepath does exist ----
expect_true(file.exists("~/tmp/a/buzzy-master.zip"))
download_zip(gh_url, destdir = "~/tmp/a")
## should get "Overwrite...?" query
## no --> aborts
## yes --> downloads

## destdir given & does not exist ----
expect_false(file.exists("~/tmp/b"))
download_zip(gh_url, destdir = "~/tmp/b")
## should get error re: Directory does not exist


# tidy_unzip() ----

# dropbox <- download_zip("url")
# dropbox <- tidy_unzip(dropbox)
# list.files(dropbox)
# list.files(dropbox2, recursive = TRUE)

