# capturing some manual tests re: detecting missing user email or name
# https://github.com/r-lib/usethis/pull/1721

dat <- gert::git_config_global()
if ("user.name" %in% dat$name) {
  old_name <- dat$value[dat$name == "user.name"]
  usethis::use_git_config(user.name = NULL)
  withr::defer(usethis::use_git_config(user.name = old_name))
}
if ("user.email" %in% dat$name) {
  old_email <- dat$value[dat$name == "user.email"]
  usethis::use_git_config(user.email = NULL)
  withr::defer(usethis::use_git_config(user.email = old_email))
}
usethis::git_sitrep(scope = "user")
usethis::git_sitrep(scope = "project")
usethis::git_sitrep()
withr::deferred_run()

dat <- gert::git_config_global()
if ("user.name" %in% dat$name) {
  old_name <- dat[dat$name == "user.name", ]$value
  usethis::use_git_config(user.name = NULL)
  withr::defer(usethis::use_git_config(user.name = old_name))
}
usethis::git_sitrep(scope = "user")
usethis::git_sitrep(scope = "project")
usethis::git_sitrep()
withr::deferred_run()

dat <- gert::git_config_global()
if ("user.email" %in% dat$name) {
  old_email <- dat[dat$name == "user.email", ]$value
  usethis::use_git_config(user.email = NULL)
  withr::defer(usethis::use_git_config(user.email = old_email))
}
usethis::git_sitrep(scope = "user")
usethis::git_sitrep(scope = "project")
usethis::git_sitrep()
withr::deferred_run()
