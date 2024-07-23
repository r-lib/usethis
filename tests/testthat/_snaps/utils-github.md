# we understand the list of all possible configs

    Code
      all_configs()
    Output
      [1] "no_github"                          "ours"                              
      [3] "theirs"                             "maybe_ours_or_theirs"              
      [5] "fork"                               "maybe_fork"                        
      [7] "fork_cannot_push_origin"            "fork_upstream_is_not_origin_parent"
      [9] "upstream_but_origin_is_not_fork"   

# 'no_github' is reported correctly

    Code
      new_no_github()
    Message
      * Type = "no_github"
      * Host = "NA"
      * Config supports a pull request = FALSE
      * origin = <not configured>
      * upstream = <not configured>
      ! Neither "origin" nor "upstream" is a GitHub repo.
      i Read more about the GitHub remote configurations that usethis supports at:
        <https://happygitwithr.com/common-remote-setups.html>.

# 'ours' is reported correctly

    Code
      new_ours()
    Message
      * Type = "ours"
      * Host = "https://github.com"
      * Config supports a pull request = TRUE
      * origin = "OWNER/REPO" (can push)
      * upstream = <not configured>
      i "origin" is both the source and primary repo.
      i Read more about the GitHub remote configurations that usethis supports at:
        <https://happygitwithr.com/common-remote-setups.html>.

# 'theirs' is reported correctly

    Code
      new_theirs()
    Message
      * Type = "theirs"
      * Host = "https://github.com"
      * Config supports a pull request = FALSE
      * origin = "OWNER/REPO" (can not push)
      * upstream = <not configured>
      ! The only configured GitHub remote is "origin", which you cannot push to.
      i If your goal is to make a pull request, you must fork-and-clone.
      i `usethis::create_from_github()` can do this.
      i Read more about the GitHub remote configurations that usethis supports at:
        <https://happygitwithr.com/common-remote-setups.html>.

# 'fork' is reported correctly

    Code
      new_fork()
    Message
      * Type = "fork"
      * Host = "https://github.com"
      * Config supports a pull request = TRUE
      * origin = "CONTRIBUTOR/REPO" (can push) = fork of "OWNER/REPO"
      * upstream = "OWNER/REPO" (can not push)
      i "origin" is a fork of "OWNER/REPO", which is configured as the "upstream"
        remote.
      i Read more about the GitHub remote configurations that usethis supports at:
        <https://happygitwithr.com/common-remote-setups.html>.

# 'maybe_ours_or_theirs' is reported correctly

    Code
      new_maybe_ours_or_theirs()
    Message
      * Type = "maybe_ours_or_theirs"
      * Host = "https://github.com"
      * Config supports a pull request = NA
      * origin = "OWNER/REPO"
      * upstream = <not configured>
      ! "origin" is a GitHub repo and "upstream" is either not configured or is not a
        GitHub repo.
      i We may be offline or you may need to configure a GitHub personal access
        token.
      i `usethis::gh_token_help()` can help with that.
      i Read more about what this GitHub remote configuration means at:
        <https://happygitwithr.com/common-remote-setups.html>.

# 'maybe_fork' is reported correctly

    Code
      new_maybe_fork()
    Message
      * Type = "maybe_fork"
      * Host = "https://github.com"
      * Config supports a pull request = NA
      * origin = "CONTRIBUTOR/REPO"
      * upstream = "OWNER/REPO"
      ! Both "origin" and "upstream" appear to be GitHub repos. However, we can't
        confirm their relationship to each other (e.g., fork and fork parent) or your
        permissions (e.g. push access).
      i We may be offline or you may need to configure a GitHub personal access
        token.
      i `usethis::gh_token_help()` can help with that.
      i Read more about what this GitHub remote configuration means at:
        <https://happygitwithr.com/common-remote-setups.html>.

# 'fork_cannot_push_origin' is reported correctly

    Code
      new_fork_cannot_push_origin()
    Message
      * Type = "fork_cannot_push_origin"
      * Host = "https://github.com"
      * Config supports a pull request = FALSE
      * origin = "CONTRIBUTOR/REPO"
      * upstream = "OWNER/REPO"
      ! The "origin" remote is a fork, but you can't push to it.
      i Read more about the GitHub remote configurations that usethis supports at:
        <https://happygitwithr.com/common-remote-setups.html>.

# 'fork_upstream_is_not_origin_parent' is reported correctly

    Code
      new_fork_upstream_is_not_origin_parent()
    Message
      * Type = "fork_upstream_is_not_origin_parent"
      * Host = "https://github.com"
      * Config supports a pull request = FALSE
      * origin = "CONTRIBUTOR/REPO" (can push) = fork of "NEW_OWNER/REPO"
      * upstream = "OLD_OWNER/REPO" (can not push)
      ! The "origin" GitHub remote is a fork, but its parent is not configured as the
        "upstream" remote.
      i Read more about the GitHub remote configurations that usethis supports at:
        <https://happygitwithr.com/common-remote-setups.html>.

# 'upstream_but_origin_is_not_fork' is reported correctly

    Code
      new_upstream_but_origin_is_not_fork()
    Message
      * Type = "upstream_but_origin_is_not_fork"
      * Host = "https://github.com"
      * Config supports a pull request = FALSE
      * origin = "CONTRIBUTOR/REPO"
      * upstream = "OWNER/REPO"
      ! Both "origin" and "upstream" are GitHub remotes, but "origin" is not a fork
        and, in particular, is not a fork of "upstream".
      i Read more about the GitHub remote configurations that usethis supports at:
        <https://happygitwithr.com/common-remote-setups.html>.

# 'fork_upstream_is_not_origin_parent' is detected correctly

    Code
      stop_bad_github_remote_config(cfg)
    Condition
      Error in `stop_bad_github_remote_config()`:
      x Unsupported GitHub remote configuration: "fork_upstream_is_not_origin_parent"
      * Host = "https://github.com"
      * origin = "jennybc/gh" (can push) = fork of "r-lib/gh"
      * upstream = "r-pkgs/gh" (can push)
      ! The "origin" GitHub remote is a fork, but its parent is not configured as the "upstream" remote.
      i Read more about the GitHub remote configurations that usethis supports at:
        <https://happygitwithr.com/common-remote-setups.html>.

# bad github config error

    Code
      stop_bad_github_remote_config(new_fork_upstream_is_not_origin_parent())
    Condition
      Error in `stop_bad_github_remote_config()`:
      x Unsupported GitHub remote configuration: "fork_upstream_is_not_origin_parent"
      * Host = "https://github.com"
      * origin = "CONTRIBUTOR/REPO" (can push) = fork of "NEW_OWNER/REPO"
      * upstream = "OLD_OWNER/REPO" (can not push)
      ! The "origin" GitHub remote is a fork, but its parent is not configured as the "upstream" remote.
      i Read more about the GitHub remote configurations that usethis supports at:
        <https://happygitwithr.com/common-remote-setups.html>.

# maybe bad github config error

    Code
      stop_maybe_github_remote_config(new_maybe_fork())
    Condition
      Error in `stop_maybe_github_remote_config()`:
      x Pull request functions can't work with GitHub remote configuration: "maybe_fork".
      i The most likely problem is that we aren't discovering your GitHub personal access token.
      * Host = "https://github.com"
      * origin = "CONTRIBUTOR/REPO"
      * upstream = "OWNER/REPO"
      ! Both "origin" and "upstream" appear to be GitHub repos. However, we can't confirm their relationship to each other (e.g., fork and fork parent) or your permissions (e.g. push access).
      i We may be offline or you may need to configure a GitHub personal access token.
      i `usethis::gh_token_help()` can help with that.
      i Read more about what this GitHub remote configuration means at:
        <https://happygitwithr.com/common-remote-setups.html>.

