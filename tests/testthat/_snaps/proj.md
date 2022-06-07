# proj_path() errors with absolute paths

    Code
      proj_path(c("/a", "b", "/c"))
    Condition
      Error:
      ! Paths must be relative to the active project

