# check_is_package() can reveal who's asking

    Code
      check_is_package("foo()")
    Condition
      Error:
      i foo() (`?usethis::foo`) is designed to work with packages.
      x Project "{TESTPROJ}" is not an R package.

# proj_path() errors with absolute paths

    Code
      proj_path(c("/a", "b", "/c"))
    Condition
      Error:
      x Paths must be relative to the active project, not absolute.

---

    Code
      proj_path("/a", "b", "/c")
    Condition
      Error:
      x Paths must be relative to the active project, not absolute.

---

    Code
      proj_path("/a", c("b", "/c"))
    Condition
      Error:
      x Paths must be relative to the active project, not absolute.

