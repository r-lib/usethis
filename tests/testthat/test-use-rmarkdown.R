test_that("use_rmarkdown_template() creates everything as promised, defaults", {
  create_local_package()
  use_rmarkdown_template()
  path <- path("inst", "rmarkdown", "templates", "template-name")
  yml <- read_utf8(proj_path(path, "template.yaml"))
  expect_true(
    all(
      c(
        "name: Template Name", "description: >",
        "   A description of the template", "create_dir: FALSE"
      ) %in% yml
    )
  )
  expect_proj_file(path, "skeleton", "skeleton.Rmd")
})

test_that("use_rmarkdown_template() creates everything as promised, args", {
  create_local_package()
  use_rmarkdown_template(
    template_name = "aaa",
    template_dir = "bbb",
    template_description = "ccc",
    template_create_dir = TRUE
  )
  path <- path("inst", "rmarkdown", "templates", "bbb")
  yml <- read_utf8(proj_path(path, "template.yaml"))
  expect_true(
    all(
      c("name: aaa", "description: >", "   ccc", "create_dir: TRUE") %in% yml
    )
  )
  expect_proj_file(path, "skeleton", "skeleton.Rmd")
})
