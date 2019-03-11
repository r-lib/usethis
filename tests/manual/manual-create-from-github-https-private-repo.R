#devtools::load_all()
library(usethis)
library(testthat)
library(fs)

## confirm that a GitHub PAT is configured
## use it to determine username
(me <- gh::gh_whoami())
(user <- me$login)

## in the browser, create new private repo 'crewsocks' with a README
## TODO: nice to add the gh code to do this here
## TODO: use gh to double check that it's really private
repo_name <- "crewsocks"

## make sure we'll be using HTTPS
use_git_protocol("https")

## this should work
x <- create_from_github(paste0(user, "/", repo_name))

expect_equal(path_file(x), "crewsocks")
expect_true(dir_exists(x))
expect_true(file_exists(path(x, "crewsocks.Rproj")))

## cleanup
dir_delete(x)

## delete the private test repo on GitHub in the browser, if you wish
## TODO: nice to add the gh code to do this here
