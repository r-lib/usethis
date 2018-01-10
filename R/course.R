download_zip <- function(url) {
  stopifnot(is_string(url))
  dl <- curl::curl_fetch_memory(url)

  httr::stop_for_status(dl$status_code)
  check_host(dl$url)
  check_is_zip(dl)

  cd <- content_disposition(dl)

  filename <- make_filename(cd, fallback = basename(url))

  ## TO DO: Offer a "Save To ..." with working directory as default?
  done("Downloading ZIP file to ", value(filename))
  ## TO DO: Check if 'filename' exists? `writeBin()` has no overwrite arg!
  writeBin(dl$content, filename)
  invisible(filename)
}

tidy_unzip <- function(zipfile) {
  files <- utils::unzip(zipfile, list = TRUE)
  files$unzip_keep <- vapply(files$Name, keep, logical(1), USE.NAMES = FALSE)
  files <- files[files$unzip_keep, ]
  loose <- any(dirname(files$Name) == "/")
  target <- parent <- tools::file_path_sans_ext(zipfile)
  if (loose) {
    ## TO DO: Check if 'target' exists?
    utils::unzip(zipfile, files = files$Name, exdir = target)
  } else {
    ## TO DO: Check if 'parent' exists?
    utils::unzip(zipfile, files = files$Name)
    ## TO DO: make this more general for branchname
    target <- gsub("-master$", "", parent)
    ## TO DO: Check if 'target' exists?
    file.rename(parent, target)
  }
  done(
    "Unpacking ZIP file into ", value(target),
    " (", nrow(files), " files extracted)"
  )

  if (!nope("Shall we delete the ZIP file ", value(zipfile), "?")) {
    done("Deleting ", value(zipfile))
    unlink(zipfile)
  }

  ## TO DO: open target in file explorer
  invisible(target)
}

keep <- function(file,
                 ignores = c(".Rproj.user", ".rproj.user", ".Rhistory", ".RData", ".git")) {
  ignores <- paste0("(\\/|\\A)", gsub("\\.", "[.]", ignores), "(\\/|\\Z)")
  !any(vapply(ignores, function(x) grepl(x, file, perl = TRUE), logical(1)))
}

check_host <- function(url) {
  ## one regex per ZIP file host we are prepared to handle
  ## this should match the URL after all the redirects
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

content_disposition <- function(download) {
  headers <- curl::parse_headers_list(download$headers)
  parse_content_disposition(headers[["content-disposition"]])
}

## https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Disposition
## https://tools.ietf.org/html/rfc6266
## DropBox eg: "attachment; filename=\"foo.zip\"; filename*=UTF-8''foo.zip\"
##  GitHub eg: "attachment; filename=foo-master.zip"
parse_content_disposition <- function(cd) {
  if (!grepl("^attachment;", cd)) {
    stop(
      code("Content-Disposition"), " header doesn't start with ",
      value("attachment"), "\n",
      "Actual header: ", value(cd), call. = FALSE
    )
  }

  cd <- sub("^attachment;\\s*", "", cd, ignore.case = TRUE)
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
  cd <- sub("^\"(.+)\"$", "\\1", cd)

  sanitize_filename(cd)
}

## replace this with something more robust when exists
## https://github.com/r-lib/fs/issues/32
## in the meantime ...
## 1. take basename
## 2. URL encode it
## 3. Replace remaining obvious no-no's: C0 and C1 control characters, ".",
##    "..", Windows reserved filenames, trailing dot or space (Windows thing)
## 4. Truncate to 255 characters
sanitize_filename <- function(x) {
  x <- vapply(
    basename(x),
    function(z) utils::URLencode(z, reserved = TRUE),
    character(1),
    USE.NAMES = FALSE
  )

  alt <- "_"
  x <- gsub(control_regex, alt, x)
  x <- gsub(unix_reserved_regex, alt, x)
  x <- gsub(windows_reserved_regex, alt, x, ignore.case = TRUE)
  x <- gsub(windows_trailing_regex, alt, x)
  substr(x, start = 1, stop = 255)
}

## R itself will truncate and warn on \x00 = embedded nul, leave it off
control_regex <- "[\x01-\x1f\x80-\x9f]"
unix_reserved_regex <- "^[.]{1,2}$"
## https://msdn.microsoft.com/en-us/library/aa365247.aspx
windows_reserved_regex <- "^(con|prn|aux|nul|com[0-9]|lpt[0-9])([.].*)?$"
windows_trailing_regex <- "[. ]+$"
