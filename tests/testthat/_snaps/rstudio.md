# we error if there isn't exactly one Rproj files

    Code
      rproj_path(path)
    Condition
      Error:
      ! "test" is not an RStudio Project.

---

    Code
      rproj_path(path)
    Condition
      Error:
      ! "test" must contain a single .Rproj file.
      i Found 'a.Rproj' and 'b.Rproj'.

# a non-RStudio project is not recognized

    Code
      rproj_path()
    Condition
      Error:
      ! "{TESTPKG}" is not an RStudio Project.

