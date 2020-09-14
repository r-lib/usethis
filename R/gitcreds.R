# Experiment inlining r-lib/git-creds.
# This will likely NOT end up in usethis, long-term.

# ------------------------------------------------------------------------
# Public API
# ------------------------------------------------------------------------

gitcreds <- local({

gitcreds_get <- function(url = "https://github.com", use_cache = TRUE,
                         set_cache = TRUE) {

  stopifnot(
    is_string(url), has_no_newline(url),
    is_flag(use_cache),
    is_flag(set_cache)
  )

  cache_ev <- gitcreds_cache_envvar(url)
  if (use_cache && !is.null(ans <- gitcreds_get_cache(cache_ev))) {
    return(ans)
  }

  check_for_git()

  out <- gitcreds_fill(list(url = url), dummy = TRUE)
  creds <- gitcreds_parse_output(out, url)

  if (set_cache) {
    gitcreds_set_cache(cache_ev, creds)
  }

  creds
}

gitcreds_set <- function(url = "https://github.com") {
  if (!is_interactive()) {
    throw(new_error(
      "gitcreds_not_interactive_error",
      message = "`gitcreds_set()` only works in interactive sessions"
    ))
  }
  stopifnot(is_string(url), has_no_newline(url))
  check_for_git()

  current <- tryCatch(
    gitcreds_get(url, use_cache = FALSE, set_cache = FALSE),
    gitcreds_no_credentials = function(e) NULL
  )

  if (!is.null(current)) {
    gitcreds_set_replace(url, current)
  } else {
    gitcreds_set_new(url)
  }

  msg("-> Removing credetials from cache...")
  gitcreds_delete_cache(gitcreds_cache_envvar(url))

  msg("-> Done.")
  invisible()
}

gitcreds_set_replace <- function(url, current) {
  if (!ack(url, current, "Replace")) {
    throw(new_error("gitcreds_abort_replace_error"))
  }

  pat <- readline("\n? Enter new password or token: ")

  username <- get_url_username(url) %||%
    gitcreds_username(url) %||%
    current$username

  msg("-> Removing current credentials...")
  gitcreds_reject(current)

  msg("-> Adding new credentials...")
  gitcreds_approve(list(url = url, username = username, password = pat))

  invisible()
}

gitcreds_set_new <- function(url) {
  pat <- readline("\n? Enter new password or token: ")

  username <- get_url_username(url) %||%
    gitcreds_username(url) %||%
    default_username()

  msg("-> Adding new credentials...")
  gitcreds_approve(list(url = url, username = username, password = pat))

  invisible()
}

gitcreds_delete <- function(url = "https://github.com") {
  if (!is_interactive()) {
    throw(new_error(
      "gitcreds_not_interactive_error",
      message = "`gitcreds_delete()` only works in interactive sessions"
    ))
  }
  stopifnot(is_string(url))
  check_for_git()

  current <- tryCatch(
    gitcreds_get(url, use_cache = FALSE, set_cache = FALSE),
    gitcreds_no_credentials = function(e) NULL
  )

  if (is.null(current)) {
    return(invisible(FALSE))
  }

  if (!ack(url, current, "Delete")) {
    throw(new_error("gitcreds_abort_delete_error"))
  }

  msg("-> Removing current credentials...")
  gitcreds_reject(current)

  msg("-> Removing credetials from cache...")
  gitcreds_delete_cache(gitcreds_cache_envvar(url))

  msg("-> Done.")

  invisible(TRUE)
}

gitcreds_list_helpers <- function() {
  check_for_git()
  out <- git_run(c("config", "--get-all", "credential.helper"))
  clear <- rev(which(out == ""))
  if (length(clear)) out <- out[-(1:clear[1])]
  out
}

gitcreds_cache_envvar <- function(url) {
  pcs <- parse_url(url)

  proto <- sub("^https?_$", "", paste0(pcs$protocol, "_"))
  user <- ifelse(pcs$username != "", paste0(pcs$username, "_AT_"), "")
  host0 <- sub("^api[.]github[.]com$", "github.com", pcs$host)
  host1 <- gsub("[.:]+", "_", host0)
  host <- gsub("[^a-zA-Z0-9_-]", "x", host1)

  slug1 <- paste0(proto, user, host)

  # fix the user name ambiguity, not that it happens often...
  slug2 <- ifelse(grepl("^AT_", slug1), paste0("AT_", slug1), slug1)

  # env vars cannot start with a number
  slug3 <- ifelse(grepl("^[0-9]", slug2), paste0("AT_", slug2), slug2)

  paste0("GITHUB_PAT_", toupper(slug3))
}

gitcreds_get_cache <- function(ev) {
  val <- Sys.getenv(ev, NA_character_)
  if (is.na(val) && ev == "GITHUB_PAT_GITHUB_COM") {
    val <- Sys.getenv("GITHUB_PAT", NA_character_)
  }
  if (is.na(val) && ev == "GITHUB_PAT_GITHUB_COM") {
    val <- Sys.getenv("GITHUB_TOKEN", NA_character_)
  }
  if (is.na(val)) {
    return(NULL)
  }

  unesc <- function(x) {
    gsub("\\\\(.)", "\\1", x)
  }

  # split on `:` that is not preceded by a `\`
  spval <- strsplit(val, "(?<!\\\\):", perl = TRUE)[[1]]
  spval0 <- unesc(spval)

  # Single field, then the token
  if (length(spval) == 1) {
    return(new_gitcreds(
      protocol = NA_character_,
      host = NA_character_,
      username = NA_character_,
      password = unesc(val)
    ))
  }

  # Two fields? Then it is username:password
  if (length(spval) == 2) {
    return(new_gitcreds(
      protocol = NA_character_,
      host = NA_character_,
      username = spval0[1],
      password = spval0[2]
    ))
  }

  # Otherwise a full record
  if (length(spval) %% 2 == 1) {
    warning("Invalid gitcreds credentials in env var `", ev, "`. ",
            "Maybe an unescaped ':' character?")
    return(NULL)
  }

  creds <- structure(
    spval0[seq(2, length(spval0), by = 2)],
    names = spval[seq(1, length(spval0), by = 2)]
  )
  do.call("new_gitcreds", as.list(creds))
}

gitcreds_set_cache <- function(ev, creds) {
  #esc <- function(x) gsub(":", "\\:", x, fixed = TRUE)
  #keys <- esc(names(creds))
  #vals <- esc(unlist(creds, use.names = FALSE))
  #value <- paste0(keys, ":", vals, collapse = ":")
  #do.call("set_env", list(structure(value, names = ev)))
  do.call("set_env", list(structure(creds$password, names = ev)))
  invisible(NULL)
}

gitcreds_delete_cache <- function(ev) {
  Sys.unsetenv(ev)
}

print.gitcreds <- function(x, header = TRUE, ...) {
  cat(format(x, header = header, ...), sep = "\n")
}

format.gitcreds <- function(x, header = TRUE, ...) {
  nms <- names(x)
  vls <- unlist(x, use.names = FALSE)
  vls[nms == "password"] <- "<-- hidden -->"
  c(
    if (header) "<gitcreds>",
    paste0("  ", format(nms), ": ", vls)
  )
}

# ------------------------------------------------------------------------
# Raw git credential API
# ------------------------------------------------------------------------

gitcreds_fill <- function(input, args = character(), dummy = TRUE) {
  if (dummy) {
    helper <- paste0(
      "credential.helper=\"! echo protocol=dummy;",
      "echo host=dummy;",
      "echo username=dummy;",
      "echo password=dummy\""
    )
    args <- c(args, "-c", helper)
  }

  gitcreds_run("fill", input, args)
}

gitcreds_approve <- function(creds, args = character()) {
  gitcreds_run("approve", creds, args)
}

gitcreds_reject <- function(creds, args = character()) {
  gitcreds_run("reject", creds, args)
}

gitcreds_parse_output <- function(txt, url) {
  if (is.null(txt) || txt[1] == "protocol=dummy") {
    throw(new_error("gitcreds_no_credentials", url = url))
  }
  nms <- sub("=.*$", "", txt)
  vls <- sub("^[^=]+=", "", txt)
  structure(as.list(vls), names = nms, class = "gitcreds")
}

gitcreds_run <- function(command, input, args = character()) {
  env <- gitcreds_env()
  oenv <- set_env(env)
  on.exit(set_env(oenv), add = TRUE)

  stdin <- create_gitcreds_input(input)

  git_run(c(args, "credential", command), input = stdin)
}

# ------------------------------------------------------------------------
# Helpers specific to git
# ------------------------------------------------------------------------

git_run <- function(args, input = NULL) {
  stderr_file <- tempfile("gitcreds-stderr-")
  on.exit(unlink(stderr_file, recursive = TRUE), add = TRUE)
  out <- tryCatch(
    suppressWarnings(system2(
      "git", args, input = input, stdout = TRUE, stderr = stderr_file
    )),
    error = function(e) NULL
  )

  if (!is.null(attr(out, "status")) && attr(out, "status") != 0) {
    throw(new_error(
      "git_error",
      args = args,
      stdout = out,
      status = attr(out, "status"),
      stderr = read_file(stderr_file)
    ))
  }

  out
}

ack <- function(url, current, what = "Replace") {
  msg("\n-> Your current credentials for ", squote(url), ":\n")
  msg(paste0(format(current, header = FALSE), collapse = "\n"), "\n")

  choices <- c(
    "Keep these credentials",
    paste(what, "these credentials"),
    if (has_password(current)) "See the password / token"
  )

  repeat {
    ch <- utils::menu(title = "-> What would you like to do?", choices)

    if (ch == 1) return(FALSE)
    if (ch == 2) return(TRUE)

    msg("\nCurrent password: ", current$password, "\n\n")
  }
}

has_password <- function(creds) {
  is_string(creds$password) && creds$password != ""
}

create_gitcreds_input <- function(args) {
  paste0(
    paste0(names(args), "=", args, collapse = "\n"),
    "\n\n"
  )
}

gitcreds_env <- function() {
  # Avoid interactivity and validation with some common credential helpers
  c(
    GCM_INTERACTIVE = "Never",
    GCM_MODAL_PROMPT = "false",
    GCM_VALIDATE = "false"
  )
}

check_for_git <- function() {
  # This is simpler than Sys.which(), and also less fragile
  has_git <- tryCatch({
    suppressWarnings(system2(
      "git", "--version",
      stdout = TRUE, stderr = null_file()
    ))
    TRUE
  }, error = function(e) FALSE)

  if (!has_git) throw(new_error("gitcreds_nogit_error"))
}

gitcreds_username <- function(url = NULL) {
  gitcreds_username_for_url(url) %||% gitcreds_username_generic()
}

gitcreds_username_for_url <- function(url) {
  if (is.null(url)) return(NULL)
  tryCatch(
    git_run(c(
      "config", "--get-urlmatch", "credential.username", shQuote(url)
    )),
    git_error = function(err) {
      if (err$status == 1) NULL else throw(err)
    }
  )
}

gitcreds_username_generic <- function() {
  tryCatch(
    git_run(c("config", "credential.username")),
    git_error = function(err) {
      if (err$status == 1) NULL else throw(err)
    }
  )
}

default_username <- function() {
  if (.Platform$OS.type == "windows") "PersonalAccessToken" else "token"
}

new_gitcreds <- function(...) {
  structure(list(...), class = "gitcreds")
}

# ------------------------------------------------------------------------
# Errors
# ------------------------------------------------------------------------

gitcred_errors <- function() {
  c(
    git_error = "System git failed",
    gitcreds_nogit_error = "Could not find system git",
    gitcreds_not_interactive_error = "gitcreds needs an interactive session",
    gitcreds_abort_replace_error = "User aborted updating credentials",
    gitcreds_abort_delete_error = "User aborted deleting credentials",
    gitcreds_no_credentials = "Could not find any credentials"
  )
}

new_error <- function(class, ..., message = "", call. = TRUE, domain = NULL) {
  if (message == "") message <- gitcred_errors()[[class]]
  message <- .makeMessage(message, domain = domain)
  cond <- list(message = message, ...)
  if (call.) cond$call <- sys.call(-1)
  class(cond) <- c(class, "gitcreds_error", "error", "condition")
  cond
}

throw <- function(cond) {
  stop(cond)
}

# ------------------------------------------------------------------------
# Genetic helpers
# ------------------------------------------------------------------------

set_env <- function(envs) {
  current <- Sys.getenv(names(envs), NA_character_)
  na <- is.na(envs)
  if (any(na)) {
    Sys.unsetenv(names(envs)[na])
  }
  if (any(!na)) {
    do.call("Sys.setenv", as.list(envs[!na]))
  }
  invisible(current)
}

get_url_username <- function(url) {
  nm <- parse_url(url)$username
  if (nm == "") NULL else nm
}

parse_url <- function(url) {
  re_url <- paste0(
    "^(?<protocol>[a-zA-Z0-9]+)://",
    "(?:(?<username>[^@/:]+)(?::(?<password>[^@/]+))?@)?",
    "(?<host>[^/]+)",
    "(?<path>.*)$"            # don't worry about query params here...
  )

  mch <- re_match(url, re_url)
  mch[, setdiff(colnames(mch), c(".match", ".text")), drop = FALSE]
}

is_string <- function(x) {
  is.character(x) && length(x) == 1 && !is.na(x)
}

is_flag <- function(x) {
  is.logical(x) && length(x) == 1 && !is.na(x)
}

has_no_newline <- function(url) {
  ! grepl("\n", url, fixed = TRUE)
}

# From the rematch2 package

re_match <- function(text, pattern, perl = TRUE, ...) {

  stopifnot(is.character(pattern), length(pattern) == 1, !is.na(pattern))
  text <- as.character(text)

  match <- regexpr(pattern, text, perl = perl, ...)

  start  <- as.vector(match)
  length <- attr(match, "match.length")
  end    <- start + length - 1L

  matchstr <- substring(text, start, end)
  matchstr[ start == -1 ] <- NA_character_

  res <- data.frame(
    stringsAsFactors = FALSE,
    .text = text,
    .match = matchstr
  )

  if (!is.null(attr(match, "capture.start"))) {

    gstart  <- attr(match, "capture.start")
    glength <- attr(match, "capture.length")
    gend    <- gstart + glength - 1L

    groupstr <- substring(text, gstart, gend)
    groupstr[ gstart == -1 ] <- NA_character_
    dim(groupstr) <- dim(gstart)

    res <- cbind(groupstr, res, stringsAsFactors = FALSE)
  }

  names(res) <- c(attr(match, "capture.names"), ".text", ".match")
  res
}

null_file <- function() {
  if (.Platform$OS.type == "windows") "nul:" else "/dev/null"
}

`%||%` <- function(l, r) if (is.null(l)) r else l

msg <- function(..., domain = NULL, appendLF = TRUE) {
  cnd <- .makeMessage(..., domain = domain, appendLF = appendLF)
  withRestarts(muffleMessage = function() NULL, {
    signalCondition(simpleMessage(msg))
    output <- default_output()
    cat(cnd, file = output, sep = "")
  })
  invisible()
}

default_output <- function() {
  if (is_interactive() && no_active_sink()) stdout() else stderr()
}

no_active_sink <- function() {
  # See ?sink.number for the explanation
  sink.number("output") == 0 && sink.number("message") == 2
}

# is_interactive <- function() {
#   opt <- getOption("rlib_interactive")
#   opt2 <- getOption("rlang_interactive")
#   if (isTRUE(opt)) {
#     TRUE
#   } else if (identical(opt, FALSE)) {
#     FALSE
#   } else if (isTRUE(opt2)) {
#     TRUE
#   } else if (identical(opt2, FALSE)) {
#     FALSE
#   } else if (tolower(getOption("knitr.in.progress", "false")) == "true") {
#     FALSE
#   } else if (tolower(getOption("rstudio.notebook.executing", "false")) == "true") {
#     FALSE
#   } else if (identical(Sys.getenv("TESTTHAT"), "true")) {
#     FALSE
#   } else {
#     interactive()
#   }
# }

squote <- function(x) {
  old <- options(useFancyQuotes = FALSE)
  on.exit(options(old), add = TRUE)
  sQuote(x)
}

read_file <- function(path, ...) {
  readChar(path, nchars = file.info(path)$size, ...)
}

as.list(current_env())

})

#' @export
gitcreds_set <- gitcreds$gitcreds_set

# foo <- gitcreds$FUNCTION
