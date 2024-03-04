# proj_path() errors with absolute paths

    Code
      proj_path(c("/a", "b", "/c"))
    Condition
      Error in `proj_path()`:
      x Paths must be relative to the active project, not absolute.

---

    Code
      proj_path("/a", "b", "/c")
    Condition
      Error in `proj_path()`:
      x Paths must be relative to the active project, not absolute.

---

    Code
      proj_path("/a", c("b", "/c"))
    Condition
      Error in `proj_path()`:
      x Paths must be relative to the active project, not absolute.

