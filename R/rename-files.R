#' Automatically rename paired `R/` and `test/` files
#'
#' @description
#' * Moves `R/{old}.R` to `R/{new}.R`
#' * Moves `src/{old}.*` to `src/{new}.*`
#' * Moves `tests/testthat/test-{old}.R` to `tests/testthat/test-{new}.R`
#' * Moves `tests/testthat/test-{old}-*.*` to `tests/testthat/test-{new}-*.*`
#'   and updates paths in the test file.
#' * Removes `context()` calls from the test file, which are unnecessary
#'   (and discouraged) as of testthat v2.1.0.
#'
#' This is a potentially dangerous operation, so you must be using Git in
#' order to use this function.
#'
#' @param old,new Old and new file names (with or without `.R` extensions).
#' @export
rename_files <- function(old, new) {
  check_uses_git()
  challenge_uncommitted_changes(
    msg = "
    There are uncommitted changes and we're about to bulk-rename files. It is \\
    highly recommended to get into a clean Git state before bulk-editing files",
    untracked = TRUE
  )

  old <- sub("\\.R$", "", old)
  new <- sub("\\.R$", "", new)

  # R/ ------------------------------------------------------------------------
  r_old_path <- proj_path("R", old, ext = "R")
  r_new_path <- proj_path("R", new, ext = "R")
  if (file_exists(r_old_path)) {
    ui_bullets(c(
      "v" = "Moving {.path {pth(r_old_path)}} to {.path {pth(r_new_path)}}."
    ))
    file_move(r_old_path, r_new_path)
  }

  # src/ ------------------------------------------------------------------------
  if (dir_exists(proj_path("src"))) {
    src_old <- dir_ls(proj_path("src"), glob = glue("*/src/{old}.*"))

    src_new_file <- gsub(glue("^{old}"), glue("{new}"), path_file(src_old))
    src_new <- path(path_dir(src_old), src_new_file)

    if (length(src_old) > 1) {
      ui_bullets(c(
        "v" = "Moving {.path {pth(src_old)}} to {.path {pth(src_new)}}."
      ))
      file_move(src_old, src_new)
    }
  }

  # tests/testthat/ ------------------------------------------------------------
  if (!uses_testthat()) {
    return(invisible())
  }

  rename_test <- function(path) {
    file <- gsub(glue("^test-{old}"), glue("test-{new}"), path_file(path))
    file <- gsub(glue("^{old}.md"), glue("{new}.md"), file)
    path(path_dir(path), file)
  }
  old_test <- dir_ls(
    proj_path("tests", "testthat"),
    glob = glue("*/test-{old}*")
  )
  new_test <- rename_test(old_test)
  if (length(old_test) > 0) {
    ui_bullets(c(
      "v" = "Moving {.path {pth(old_test)}} to {.path {pth(new_test)}}."
    ))
    file_move(old_test, new_test)
  }
  snaps_dir <- proj_path("tests", "testthat", "_snaps")
  if (dir_exists(snaps_dir)) {
    old_snaps <- dir_ls(snaps_dir, glob = glue("*/{old}.md"))
    if (length(old_snaps) > 0) {
      new_snaps <- rename_test(old_snaps)
      ui_bullets(c(
        "v" = "Moving {.path {pth(old_snaps)}} to {.path {pth(new_snaps)}}."
      ))
      file_move(old_snaps, new_snaps)
    }
  }

  # tests/testthat/test-{new}.R ------------------------------------------------
  test_path <- proj_path("tests", "testthat", glue("test-{new}"), ext = "R")
  if (!file_exists(test_path)) {
    return(invisible())
  }

  lines <- read_utf8(test_path)

  # Remove old context lines
  context <- grepl("context\\(.*\\)", lines)
  if (any(context)) {
    ui_bullets(c("v" = "Removing call to {.fun context}."))
    lines <- lines[!context]
    if (lines[[1]] == "") {
      lines <- lines[-1]
    }
  }

  old_test <- old_test[new_test != test_path]
  new_test <- new_test[new_test != test_path]

  if (length(old_test) > 0) {
    ui_bullets(c("v" = "Updating paths in {.path {pth(test_path)}}."))

    for (i in seq_along(old_test)) {
      lines <- gsub(
        path_file(old_test[[i]]),
        path_file(new_test[[i]]),
        lines,
        fixed = TRUE
      )
    }
  }

  write_utf8(test_path, lines)
}
