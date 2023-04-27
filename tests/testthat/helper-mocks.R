mock_cran_version <- function(version, .env = caller_env()) {
  local_mocked_bindings(cran_version = function() version, .env = .env)
}

mock_check_installed <- function(.env = caller_env()) {
  local_mocked_bindings(check_installed = function(...) TRUE, .env = .env)
}

mock_check_is_package <- function(.env = caller_env()) {
  local_mocked_bindings(
    check_is_package = function(...) invisible(),
    .env = .env
  )
}

mock_rstudio_not_available <- function(.env = caller_env()) {
  local_mocked_bindings(rstudio_available = function(...) FALSE, .env = .env)
}

mock_target_repo_spec <- function(spec, .env = caller_env()) {
  local_mocked_bindings(target_repo_spec = function(...) spec, .env = .env)
}

mock_roxygen_update_ns <- function(.env = caller_env()) {
  local_mocked_bindings(roxygen_update_ns = function(...) NULL, .env = .env)
}

mock_check_functions_exist <- function(.env = caller_env()) {
  local_mocked_bindings(
    check_functions_exist = function(...) TRUE,
    .env = .env
  )
}

mock_ui_yeah <- function(.env = caller_env()) {
  local_mocked_bindings(ui_yeah = function(...) TRUE, .env = .env)
}

mock_git_default_branch_remote <- function(.env = caller_env()) {
  local_mocked_bindings(
    git_default_branch_remote = function(remote) {
      list(
        name = remote,
        is_configured = TRUE,
        url = NA_character_,
        repo_spec = NA_character_,
        default_branch = as.character(glue("default-branch-of-{remote}"))
      )
    },
    .env = .env
  )
}
