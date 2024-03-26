# use_package_doc() compatible with roxygen_ns_append()

    Code
      use_package_doc()
    Message
      v Writing 'R/{TESTPKG}-package.R'.
      [ ] Run `devtools::document()` to update package-level documentation.

---

    Code
      roxygen_ns_append("test")
    Message
      v Adding "test" to 'R/{TESTPKG}-package.R'.
    Output
      [1] TRUE

