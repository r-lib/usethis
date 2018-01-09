download_zip <- function(url) {
  stopifnot(is_string(url))
  dl <- curl::curl_fetch_memory(url)

  httr::stop_for_status(dl$status_code)
  check_host(dl$url)
  check_is_zip(dl)

  cd <- content_disposition(dl)

  filename <- make_filename(cd, fallback = basename(url))
  message("filename:\n", filename)

  writeBin(dl$content, filename)
  invisible(filename)
}

check_host <- function(url) {
  ## one regex per ZIP file host we are prepared to handle
  hosts <- c(
    dropbox = "^https://dl.dropboxusercontent.com/content_link_zip/",
    github = "^https://codeload.github.com"
  )
  m <- vapply(hosts, function(regex) grepl(regex, x = url), logical(1))
  if (!any(m)) {
    stop("Download URL has unrecognized form:\n", value(url), call. = FALSE)
  }
  invisible()
}

check_is_zip <- function(download) {
  headers <- curl::parse_headers_list(download$headers)
  if (headers[["content-type"]] != "application/zip") {
    stop(
      "Download does not have MIME type ", value("application/zip"), "\n",
      "Instead it's ", value(headers[["content-type"]]), call. = FALSE
    )
  }
  invisible()
}

## https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Disposition
## https://tools.ietf.org/html/rfc6266
content_disposition <- function(download) {
  headers <- curl::parse_headers_list(download$headers)
  parse_content_disposition(headers[["content-disposition"]])
}

parse_content_disposition <- function(cd) {
  if (!grepl("^attachment;", cd)) {
    stop(
      code("Content-Disposition"), " header doesn't start with ",
      value("attachment"), "\n",
      "Actual header: ", value(cd), call. = FALSE
    )
  }
  message("content-disposition:\n", cd)

  cd <- gsub("^attachment;\\s*", "", cd, ignore.case = TRUE)
  cd <- strsplit(cd, "\\s*;\\s*")[[1]]
  cd <- strsplit(cd, "=")
  stats::setNames(
    vapply(cd, `[[`, character(1), 2),
    vapply(cd, `[[`, character(1), 1)
  )
}

make_filename <- function(cd,
                          fallback = basename(tempfile())) {
  ## TO DO(jennybc): the element named 'filename*' is preferred but I'm not
  ## sure how to parse it yet, so targetting 'filename' for now
  ## https://tools.ietf.org/html/rfc6266
  cd <- cd[["filename"]]
  if (is.null(cd) || is.na(cd)) {
    stopifnot(is_string(fallback))
    return(sanitize_filename(fallback))
  }

  ## I know I could use regex and lookahead but this is easier for me to
  ## maintain
  if (grepl("^\"", cd) && grepl("\"$", cd)) {
    cd <- gsub("^\"(.+)\"$", "\\1", cd)
  }

  sanitize_filename(cd)
}

sanitize_filename <- function(x) x
