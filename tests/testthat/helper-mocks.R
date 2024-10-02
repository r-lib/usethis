local_cran_version <- function(version, .env = caller_env()) {
  local_mocked_bindings(cran_version = function() version, .env = .env)
}

local_check_installed <- function(.env = caller_env()) {
  local_mocked_bindings(check_installed = function(...) NULL, .env = .env)
}

local_rstudio_available <- function(val, .env = caller_env()) {
  local_mocked_bindings(rstudio_available = function(...) val, .env = .env)
}

local_target_repo_spec <- function(spec, .env = caller_env()) {
  local_mocked_bindings(target_repo_spec = function(...) spec, .env = .env)
}

local_roxygen_update_ns <- function(.env = caller_env()) {
  local_mocked_bindings(roxygen_update_ns = function(...) NULL, .env = .env)
}

local_check_fun_exists <- function(.env = caller_env()) {
  local_mocked_bindings(check_fun_exists = function(...) NULL, .env = .env)
}

local_ui_yep <- function(.env = caller_env()) {
  local_mocked_bindings(ui_yep = function(...) TRUE, .env = .env)
}

local_git_default_branch_remote <- function(.env = caller_env()) {
  local_mocked_bindings(
    git_default_branch_remote = function(cfg, remote) {
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
