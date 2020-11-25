test_that("parse_github_remotes() works, on named list or named character", {
  urls <- list(
    https      = "https://github.com/OWNER/REPO.git",
    ghe        = "https://github.acme.com/OWNER/REPO.git",
    browser    = "https://github.com/OWNER/REPO",
    ssh        = "git@github.com:OWNER/REPO.git",
    gitlab1    = "https://gitlab.com/OWNER/REPO.git",
    gitlab2    = "git@gitlab.com:OWNER/REPO.git",
    bitbucket1 = "https://bitbucket.org/OWNER/REPO.git",
    bitbucket2 = "git@bitbucket.org:OWNER/REPO.git"
  )
  parsed <- parse_github_remotes(urls)
  expect_equal(parsed$name, names(urls))
  expect_equal(unique(parsed$repo_owner), "OWNER")
  expect_equal(
    parsed$host,
    c("github.com", "github.acme.com", "github.com", "github.com",
      "gitlab.com", "gitlab.com", "bitbucket.org", "bitbucket.org")
  )
  expect_equal(unique(parsed$repo_name), "REPO")
  expect_equal(
    parsed$protocol,
    c("https", "https", "https", "ssh", "https", "ssh", "https", "ssh")
  )

  parsed2 <- parse_github_remotes(unlist(urls))
  expect_equal(parsed, parsed2)
})

test_that("parse_github_remotes() works on edge cases", {
  parsed <- parse_github_remotes("https://github.com/HenrikBengtsson/R.rsp")
  expect_equal(parsed$repo_owner, "HenrikBengtsson")
  expect_equal(parsed$repo_name, "R.rsp")
})

test_that("parse_github_remotes() works for length zero input", {
  expect_error_free(
    parsed <- parse_github_remotes(character())
  )
  expect_equal(nrow(parsed), 0)
  expect_setequal(
    names(parsed),
    c("name", "url", "host", "repo_owner", "repo_name", "protocol")
  )
})

test_that("parse_repo_url() passes a naked repo spec through", {
  out <- parse_repo_url("OWNER/REPO")
  expect_equal(
    out,
    list(repo_spec = "OWNER/REPO", host = NULL)
  )
})

test_that("parse_repo_url() handles GitHub remote URLs", {
  urls <- list(
    https      = "https://github.com/OWNER/REPO.git",
    ghe        = "https://github.acme.com/OWNER/REPO.git",
    browser    = "https://github.com/OWNER/REPO",
    ssh        = "git@github.com:OWNER/REPO.git"
  )
  out <- map(urls, parse_repo_url)
  expect_match(map_chr(out, "repo_spec"), "OWNER/REPO", fixed = TRUE)
  out_host <- map_chr(out, "host")
  expect_match(
    out_host[c("https", "browser", "ssh")],
    "https://github.com",
    fixed = TRUE
  )
  expect_equal(out_host[["ghe"]], "https://github.acme.com")
})

test_that("parse_repo_url() errors for non-GitHub remote URLs", {
  urls <- list(
    gitlab1    = "https://gitlab.com/OWNER/REPO.git",
    gitlab2    = "git@gitlab.com:OWNER/REPO.git",
    bitbucket1 = "https://bitbucket.org/OWNER/REPO.git",
    bitbucket2 = "git@bitbucket.org:OWNER/REPO.git"
  )
  safely_parse_repo_url <- purrr::safely(parse_repo_url)
  out <- map(urls, safely_parse_repo_url)
  out_result <- map(out, "result")
  expect_true(all(map_lgl(out_result, is.null)))
})

test_that("github_remote_list() works", {
  create_local_project()
  use_git()
  use_git_remote("origin", "https://github.com/OWNER/REPO.git")
  use_git_remote("upstream", "https://github.com/THEM/REPO.git")
  use_git_remote("foofy", "https://github.com/OTHERS/REPO.git")
  use_git_remote("gitlab", "https://gitlab.com/OTHERS/REPO.git")
  use_git_remote("bitbucket", "git@bitbucket.org:OWNER/REPO.git")

  grl <- github_remote_list()
  expect_setequal(grl$remote, c("origin", "upstream"))
  expect_setequal(grl$repo_spec, c("OWNER/REPO", "THEM/REPO"))

  grl <- github_remote_list(c("upstream", "foofy"))
  expect_setequal(grl$remote, c("upstream", "foofy"))
  nms <- names(grl)

  grl <- github_remote_list(c("gitlab", "bitbucket"))
  expect_equal(nrow(grl), 0)
  expect_named(grl, nms)
})

test_that("github_remotes(), github_remote_list() accept explicit 0-row input", {
  x <- data.frame(name = character(), url = character(), stringsAsFactors = FALSE)
  grl <- github_remote_list(x = x)
  expect_equal(nrow(grl), 0)
  expect_true(all(map_lgl(grl, is.character)))

  gr <- github_remotes(x = x)
  expect_equal(nrow(grl), 0)
})

test_that("github_remotes() works", {
  skip_on_cran()
  skip_if_offline("github.com")
  skip_if_no_git_user()

  create_local_project()
  use_git()

  # no git remotes = 0-row edge case
  expect_error_free(
    grl <- github_remotes()
  )

  # a public remote = no token necessary to get github info
  use_git_remote("origin", "https://github.com/r-lib/usethis.git")
  expect_error_free(
    grl <- github_remotes()
  )
  expect_false(grl$is_fork)
  expect_true(is.na(grl$parent_repo_owner))

  # no git remote by this name = 0-row edge case
  expect_error_free(
    grl <- github_remotes("foofy")
  )

  # gh::gh() call should fail, so we should get no info from github
  use_git_remote("origin", "https://github.com/r-lib/DOESNOTEXIST.git", overwrite = TRUE)
  expect_error_free(
    grl <- github_remotes()
  )
  expect_true(is.na(grl$is_fork))
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
  local_interactive(FALSE)
  create_local_project()
  use_git()
  use_git_remote("origin", "https://github.com/jennybc/gh.git")
  use_git_remote("upstream", "https://github.com/r-pkgs/gh.git")
  gr <- github_remotes(github_get = FALSE)
  gr$github_got <- TRUE
  gr$is_fork <- c(TRUE, FALSE)
  gr$can_push <- TRUE
  gr$perm_known <- TRUE
  gr$parent_repo_owner <- c("r-lib", NA)
  with_mock(
    github_remotes = function(...) gr,
    cfg <- github_remote_config()
  )
  expect_equal(cfg$type, "fork_upstream_is_not_origin_parent")
})
