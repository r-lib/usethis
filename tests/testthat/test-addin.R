context("use_addin")

test_that("use_addin() creates the first addins.dcf as promised, default", {
  scoped_temporary_package()
  use_addin()

  addin_dcf <- readLines(proj_path("inst", "rstudio", "addins.dcf"))
  expect_true(
    all(
      c("Name: New Addin Name", "Description: New Addin Description",
        "Binding: new_addin", "Interactive: false") %in% addin_dcf
    )
  )
})

test_that("use_addin() creates the first addins.dcf as promised, option", {
  scoped_temporary_package()
  use_addin("addin.test")

  addin_dcf <- readLines(proj_path("inst", "rstudio", "addins.dcf"))
  expect_true(
    all(
      c("Name: New Addin Name", "Description: New Addin Description",
        "Binding: addin.test", "Interactive: false") %in% addin_dcf
    )
  )
})

test_that("use_addin() can create bindings for multiple addins.", {
  scoped_temporary_package()
  use_addin("addin1")
  use_addin("addin_2")

  addin_dcf <- readLines(proj_path("inst", "rstudio", "addins.dcf"))
  expect_true(
    all(
      c("Name: New Addin Name", "Description: New Addin Description",
        "Binding: addin1", "Interactive: false", "",
        "Name: New Addin Name", "Description: New Addin Description",
        "Binding: addin_2", "Interactive: false", "") %in% addin_dcf
    )
  )
})
