## see end of file for some cURL notes

#' Download a ZIP file
#'
#' Special-purpose function to download a ZIP file and automatically determine
#' the file name, which ultimately determines the folder name after unpacking.
#' Developed for use in live teaching, with DropBox and GitHub as primary
#' targets, possibly via shortlinks. Both platforms offer a way to download an
#' entire folder or repo as a ZIP file, with the original folder or repo name
#' transmitted in the `Content-Disposition` header.
#'
#' @section DropBox:
#'
#' To make a folder available for ZIP download, create a shared link for it:
#' * <https://www.dropbox.com/help/files-folders/view-only-access>
#'
#' The link should have this form:
#' ```
#' https://www.dropbox.com/sh/12345abcde/6789wxyz?dl=0
#' ```
#' Replace the `dl=0` at the end with `dl=1` to create a download link. The ZIP
#' download link should have this form:
#' ```
#' https://www.dropbox.com/sh/12345abcde/6789wxyz?dl=1
#' ```
#' After one or more redirections, this URL will lead to a download URL. For
#' more details, see <https://www.dropbox.com/help/desktop-web/force-download>
#' and <https://www.dropbox.com/en/help/desktop-web/download-entire-folders>.
#'
#' @section GitHub:
#'
#' Click on the repo's "Clone or download" button, to reveal a "Download ZIP"
#' button. Capture this URL, which will have this form:
#' ```
#' https://github.com/r-lib/usethis/archive/master.zip
#' ```
#' After one or more redirections, this URL will lead to a download URL. An
#' alternative URL that also leads to ZIP download, but with a different
#' filenaming scheme:
#' ```
#' http://github.com/r-lib/usethis/zipball/master/
#' ```
#'
#' @param url Download URL for the ZIP file, possibly behind a shortlink or
#'   other redirect. See Details.
#' @param destdir Path to existing local directory where the ZIP file will be
#'   stored. Defaults to current working directory.
#' @param pedantic Logical. When `TRUE` (default) and `destdir = NULL` and in an
#'   interactive session, the user is told where the ZIP file will be stored. If
#'   happy, user can elect to proceed. Otherwise, user can abort and try again
#'   with the desired `destdir`. Intentional friction.
#'
#' @return Path to downloaded ZIP file
#' @keywords internal
#' @examples
#' \dontrun{
#' download_zip("http://bit.ly/uusseetthhiiss")
#' }
download_zip <- function(url, destdir = NULL, pedantic = TRUE) {
  stopifnot(is_string(url))
  dl <- curl::curl_fetch_memory(url)

  httr::stop_for_status(dl$status_code)
  check_is_zip(dl)

  cd <- content_disposition(dl)

  base_path <- destdir %||% getwd()
  check_is_dir(base_path)
  base_name <- make_filename(cd, fallback = basename(url))

  ## DO YOU KNOW WHERE YOUR STUFF IS GOING?!?
  if (pedantic && interactive() && is.null(destdir)) {
    message(
      "ZIP file will be downloaded to ", value(base_name),
      " in current working directory, which is ", value(getwd()), ".\n",
      "If you prefer another location, abort and specify ",
      code("destdir"), "."
    )
    if (nope("Proceed with this download?")) {
      stop("Aborting download", call. = FALSE)
    }
  }
  full_path <- file.path(base_path, base_name)

  if (!can_overwrite(full_path)) {
    ## TO DO: it pains me that can_overwrite() always strips to basename
    stop("Aborting download", call. = FALSE)
  }

  done(
    "Downloading ZIP file to ",
    if (is.null(destdir)) value(base_name) else value(full_path)
  )
  writeBin(dl$content, full_path)
  invisible(full_path)
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
    create_directory(dirname(parent), basename(parent))
    utils::unzip(zipfile, files = files$Name, exdir = dirname(parent))
    ## TO DO: make this more general for branchname
    target <- gsub("-master$", "", parent)
    ## TO DO: Check if 'target' exists?
    file.rename(parent, target)
  }
  done(
    "Unpacking ZIP file into ", value(target),
    " (", nrow(files), " files extracted)"
  )

  if (yep("Shall we delete the ZIP file ", value(zipfile), "?")) {
    done("Deleting ", value(zipfile))
    unlink(zipfile)
  }

  done("Opening ", value(target), " in the file manager")
  browseURL(target)
  invisible(target)
}

keep <- function(file,
                 ignores = c(".Rproj.user", ".rproj.user", ".Rhistory", ".RData", ".git")) {
  ignores <- paste0("(\\/|\\A)", gsub("\\.", "[.]", ignores), "(\\/|\\Z)")
  !any(vapply(ignores, function(x) grepl(x, file, perl = TRUE), logical(1)))
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
  cd <- headers[["content-disposition"]]
  if (is.null(cd)) {
    return()
  }
  parse_content_disposition(cd)
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

## https://stackoverflow.com/questions/21322614/use-curl-to-download-a-dropbox-folder-via-shared-link-not-public-link
## lesson: if using cURL, you'd want these options
## -L, --location (follow redirects)
## -O, --remote-name (name local file like the file part of remote name)
## -J, --remote-header-name (tells -O option to consult Content-Disposition
##   instead of the URL)
## https://curl.haxx.se/docs/manpage.html#OPTIONS
