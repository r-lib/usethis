test_that("parse_github_remotes() works on named list or named character", {
  urls <- list(
    https   = "https://github.com/r-lib/devtools.git",
    browser = "https://github.com/r-lib/devtools",
    ssh     = "git@github.com:r-lib/devtools.git"
  )
  parsed <- parse_github_remotes(urls)
  expect_equal(parsed$name, names(urls))
  expect_equal(unique(parsed$repo_owner), "r-lib")
  expect_equal(unique(parsed$repo_name), "devtools")
  expect_equal(parsed$protocol, c("https", "https", "ssh"))

  parsed2 <- parse_github_remotes(unlist(urls))
  expect_equal(parsed, parsed2)
})

test_that("parse_github_remotes() works on edge cases", {
  parsed <- parse_github_remotes("https://github.com/HenrikBengtsson/R.rsp")
  expect_equal(parsed$repo_owner, "HenrikBengtsson")
  expect_equal(parsed$repo_name, "R.rsp")
})

test_that("github_token() works", {
  withr::with_envvar(
    new = c("GITHUB_PAT" = "yes", "GITHUB_TOKEN" = "no"),
    expect_identical(github_token(), "yes")
  )
  withr::with_envvar(
    new = c("GITHUB_PAT" = NA, "GITHUB_TOKEN" = "yes"),
    expect_identical(github_token(), "yes")
  )
  withr::with_envvar(
    new = c("GITHUB_PAT" = NA, "GITHUB_TOKEN" = NA),
    expect_identical(github_token(), "")
  )
})

test_that("have_github_token() is definitive detector for 'we have no PAT'", {
  expect_false(have_github_token(""))
  expect_true(have_github_token("PAT"))
})

test_that("check_github_token() returns NULL if no PAT", {
  expect_null(check_github_token("", allow_empty = TRUE))
})

test_that("check_github_token() returns gh user if gets PAT", {
  with_mock(
    `gh::gh_whoami` = function(auth_token) list(login = "USER"),
    expect_equal(check_github_token("PAT"), list(login = "USER"))
  )
})

test_that("check_github_token() reveals non-401 error", {
  with_mock(
    `gh::gh_whoami` = function(auth_token) stop("gh error"),
    expect_usethis_error(check_github_token("PAT"), "gh error")
  )
})

test_that("check_github_token() errors informatively for bad input", {
  expect_usethis_error(check_github_token(c("PAT1", "PAT2")), "single string")
  expect_usethis_error(check_github_token(NA), "single string")
  expect_usethis_error(check_github_token(NA_character_), "single string")
  expect_usethis_error(check_github_token(""), "No.*available")
})

test_that("github_login() returns user's login", {
  with_mock(
    `gh::gh_whoami` = function(auth_token) list(login = "USER"),
    expect_equal(github_login("PAT"), "USER")
  )
})

test_that("github_remote_protocol() picks up ssh and https", {
  r <- list(url = "git@github.com:OWNER/REPO.git")
  with_mock(
    `usethis:::github_remotes` = function(...) r,
    {
      expect_identical(github_remote_protocol(), "ssh")
    }
  )
  r <- list(url = "https://github.com/OWNER/REPO.git")
  with_mock(
    `usethis:::github_remotes` = function(...) r,
    {
      expect_identical(github_remote_protocol(), "https")
    }
  )
})

test_that("github_remote_protocol() errors for unrecognized URL", {
  r <- list(url = "file:///srv/git/project.git")
  with_mock(
    `usethis:::github_remotes` = function(...) r,
    {
      expect_usethis_error(github_remote_protocol(), "Can't classify the URL")
    }
  )
})

test_that("github_remote_protocol() returns 0-row data frame if no github origin", {
  r <- data.frame(url = character(), stringsAsFactors = FALSE)
  with_mock(
    `usethis:::github_remotes` = function(...) r,
    {
      expect_null(github_remote_protocol())
    }
  )
})

# GitHub remote configuration --------------------------------------------------
# very sparse, but you have to start somewhere!

test_that("fork_upstream_is_not_origin_parent is detected", {
  # We've already encountered this in the wild. Here's how it happens:
  # 1. r-pkgs/gh is created
  # 2. user forks and clones: origin = USER/gh, upstream = r-pkgs/gh
  # 3. parent repo becomes r-lib/gh, due to transfer or ownership or owner
  #    name change
  # Now upstream looks like it does not point to fork parent.
  grl <- data.frame(
    stringsAsFactors   = FALSE,
    remote             = c("origin", "upstream"),
    url                = c("https://github.com/jennybc/gh.git",
                           "https://github.com/r-pkgs/gh.git"),
    repo_owner         = c("jennybc", "r-pkgs"),
    repo_name          = c("gh", "gh"),
    repo_spec          = c("jennybc/gh", "r-pkgs/gh"),
    github_get         = c(TRUE, TRUE),
    is_fork            = c(TRUE, FALSE),
    can_push           = c(TRUE, TRUE),
    parent_repo_owner  = c("r-lib", NA),
    parent_repo_name   = c("gh", NA),
    parent_repo_spec   = c("r-lib/gh", NA),
    can_push_to_parent = c(TRUE, NA)
  )
  with_mock(
    `usethis:::github_remotes` = function(...) grl,
    cfg <- github_remote_config()
  )
  expect_equal(cfg$type, "fork_upstream_is_not_origin_parent")
  expect_false(cfg$pr_ready)
})

