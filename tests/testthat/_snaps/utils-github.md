# we understand the list of all possible configs

    Code
      all_configs()
    Output
      [1] "no_github"                          "ours"                              
      [3] "theirs"                             "maybe_ours_or_theirs"              
      [5] "fork"                               "maybe_fork"                        
      [7] "fork_cannot_push_origin"            "fork_upstream_is_not_origin_parent"
      [9] "upstream_but_origin_is_not_fork"   

# fork_upstream_is_not_origin_parent is detected

    Code
      stop_bad_github_remote_config(cfg)
    Condition
      Error in `stop_bad_github_remote_config()`:
      ! Unsupported GitHub remote configuration: 'fork_upstream_is_not_origin_parent'
      * Host = 'https://github.com'
      * origin = 'jennybc/gh' (can push) = fork of NA
      * upstream = 'r-pkgs/gh' (can push)
      * The 'origin' GitHub remote is a fork, but its parent is not configured as the 'upstream' remote.
      
      Read more about the GitHub remote configurations that usethis supports at:
      'https://happygitwithr.com/common-remote-setups.html'

