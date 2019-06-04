## see end of file for some cURL notes

#' Download and unpack a ZIP file
#'
#' Functions to download and unpack a ZIP file into a local folder of files,
#' with very intentional default behaviour. Useful in pedagogical settings or
#' anytime you need a large audience to download a set of files quickly and
#' actually be able to find them.
#'
#' @param url Link to a ZIP file containing the materials. Various short forms
#'   are accepted, to reduce the typing burden in live settings:
#'
#'     * bit.ly or rstd.io shortlinks: "bit.ly/xxx-yyy-zzz" or "rstd.io/foofy"
#'     * GitHub repo spec: "OWNER/REPO"
#'   Function works well with DropBox folders and GitHub repos, but should work
#'   for ZIP files generally. See examples and [use_course_details] for more.
#' @param destdir The new folder is stored here. If `NULL`, defaults to user's
#'   Desktop or some other conspicuous place.
#' @param cleanup Whether to delete the original ZIP file after unpacking its
#'   contents. In an interactive setting, `NA` leads to a menu where user can
#'   approve the deletion (or decline).
#'
#' @return Path to the new directory holding the unpacked ZIP file, invisibly.
#' @name zip-utils
#' @examples
#' \dontrun{
#' # download the source of usethis from GitHub, behind a bit.ly shortlink
#' use_course("bit.ly/usethis-shortlink-example")
#' use_course("http://bit.ly/usethis-shortlink-example")
#'
#' ## download the source of rematch2 package, from CRAN and GitHub
#' use_course("https://cran.r-project.org/bin/windows/contrib/3.4/rematch2_2.0.1.zip")
#'
#' ## from GitHub, 3 ways
#' use_course("r-lib/rematch2")
#' use_course("https://github.com/r-lib/rematch2/archive/master.zip")
#' use_course("https://api.github.com/repos/r-lib/rematch2/zipball/master")
#' }
NULL

#' @describeIn zip-utils Designed with live workshops in mind. Includes
#'   intentional friction to highlight the download destination. Workflow:
#' * User executes, e.g., `use_course("bit.ly/xxx-yyy-zzz")`.
#' * User is asked to notice and confirm the location of the new folder. Specify
#'   `destdir` to prevent this.
#' * User is asked if they'd like to delete the ZIP file.
#' * If new folder contains an `.Rproj` file, a new instance of RStudio is
#'   launched. Otherwise, the folder is opened in the file manager, e.g. Finder
#'   or File Explorer.
#' @export
use_course <- function(url, destdir = NULL) {
  url <- normalize_url(url)
  destdir_not_specified <- is.null(destdir)
  destdir <- user_path_prep(destdir %||% conspicuous_place())
  check_path_is_directory(destdir)

  if (destdir_not_specified && interactive()) {
    ui_line(c(
      "Downloading into {ui_path(destdir)}.",
      "Prefer a different location? Cancel, try again, and specify {ui_code('destdir')}"
    ))
    if (ui_nope("OK to proceed?")) {
      ui_stop("Aborting.")
    }
  }

  ui_done("Downloading from {ui_value(url)}")
  zipfile <- tidy_download(url, destdir)
  ui_done("Download stored in {ui_path(zipfile)}")
  check_is_zip(attr(zipfile, "content-type"))
  tidy_unzip(zipfile, cleanup = NA)
}

#' @describeIn zip-utils More useful in day-to-day work. Downloads in current
#'   working directory, by default, and allows `cleanup` behaviour to be
#'   specified.
#' @export
use_zip <- function(url,
                    destdir = getwd(),
                    cleanup = if (interactive()) NA else FALSE) {
  url <- normalize_url(url)
  check_path_is_directory(destdir)
  ui_done("Downloading from {ui_value(url)}")
  zipfile <- tidy_download(url, destdir)
  ui_done("Download stored in {ui_path(zipfile)}")
  check_is_zip(attr(zipfile, "content-type"))
  tidy_unzip(zipfile, cleanup)
}

#' Helpers to download and unpack a ZIP file
#'
#' Details on the internal functions that power [use_course()] and [use_zip()].
#' These helpers are currently unexported but a course instructor may want more
#' details.
#'
#' @name use_course_details
#' @keywords internal
#'
#' @section tidy_download():
#'
#' ```
#' ## function signature
#' tidy_download(url, destdir = getwd())
#'
#' ## as called inside use_course()
#' tidy_download(
#'   url, ## after post-processing with normalize_url()
#'   # conspicuous_place() = Desktop or home directory or working directory
#'   destdir = destdir %||% conspicuous_place()
#' )
#' ```
#'
#' Special-purpose function to download a ZIP file and automatically determine
#' the file name, which often determines the folder name after unpacking.
#' Developed with DropBox and GitHub as primary targets, possibly via
#' shortlinks. Both platforms offer a way to download an entire folder or repo
#' as a ZIP file, with information about the original folder or repo transmitted
#' in the `Content-Disposition` header. In the absence of this header, a
#' filename is generated from the input URL. In either case, the filename is
#' sanitized. Returns the path to downloaded ZIP file, invisibly.
#'
#' **DropBox:**
#'
#' To make a folder available for ZIP download, create a shared link for it:
#' * <https://www.dropbox.com/help/files-folders/view-only-access>
#'
#' A shared link will have this form:
#' ```
#' https://www.dropbox.com/sh/12345abcde/6789wxyz?dl=0
#' ```
#' Replace the `dl=0` at the end with `dl=1` to create a download link. The ZIP
#' download link will have this form:
#' ```
#' https://www.dropbox.com/sh/12345abcde/6789wxyz?dl=1
#' ```
#' This download link (or a shortlink that points to it) is suitable as input
#' for `tidy_download()`. After one or more redirections, this link will
#' eventually lead to a download URL. For more details, see
#' <https://www.dropbox.com/help/desktop-web/force-download> and
#' <https://www.dropbox.com/en/help/desktop-web/download-entire-folders>.
#'
#' **GitHub:**
#'
#' Click on the repo's "Clone or download" button, to reveal a "Download ZIP"
#' button. Capture this URL, which will have this form:
#' ```
#' https://github.com/r-lib/usethis/archive/master.zip
#' ```
#' This download link (or a shortlink that points to it) is suitable as input
#' for `tidy_download()`. After one or more redirections, this link will
#' eventually lead to a download URL. Here's an alternative link that also leads
#' to ZIP download, albeit with a different filenaming scheme:
#' ```
#' https://api.github.com/repos/r-lib/usethis/zipball/master
#' ```
#'
#' @param url Download link for the ZIP file, possibly behind a shortlink or
#'   other redirect. See Details.
#' @param destdir Path to existing local directory where the ZIP file will be
#'   stored. Defaults to current working directory, but note that [use_course()]
#'   has different default behavior.
#'
#' @examples
#' \dontrun{
#' tidy_download("https://github.com/r-lib/rematch2/archive/master.zip")
#' }
#'
#' @section tidy_unzip():
#'
#' Special-purpose function to unpack a ZIP file and (attempt to) create the
#' directory structure most people want. When unpacking an archive, it is easy
#' to get one more or one less level of nesting than you expected.
#'
#' It's especially important to finesse the directory structure here: we want
#' the same local result when unzipping the same content from either GitHub or
#' DropBox ZIP files, which pack things differently. Here is the intent:
#' * If the ZIP archive `foo.zip` does not contain a single top-level directory,
#' i.e. it is packed as "loose parts", unzip into a directory named `foo`.
#' Typical of DropBox ZIP files.
#' * If the ZIP archive `foo.zip` has a single top-level directory (which, by
#' the way, is not necessarily called "foo"), unpack into said directory.
#' Typical of GitHub ZIP files.
#'
#' Returns path to the directory holding the unpacked files, invisibly.
#'
#' **DropBox:**
#' The ZIP files produced by DropBox are special. The file list tends to contain
#' a spurious directory `"/"`, which we ignore during unzip. Also, if the
#' directory is a Git repo and/or RStudio Project, we unzip-ignore various
#' hidden files, such as `.RData`, `.Rhistory`, and those below `.git/` and
#' `.Rproj.user`.
#'
#' @param zipfile Path to local ZIP file.
#'
#' @examples
#' \dontrun{
#' tidy_download("https://github.com/r-lib/rematch2/archive/master.zip")
#' tidy_unzip("rematch2-master.zip")
#' }
NULL

# 1. downloads from `url`
# 2. determines filename from content-description header (with fallbacks)
# 3. returned path has content-type and content-description as attributes
tidy_download <- function(url, destdir = getwd()) {
  check_path_is_directory(destdir)
  tmp <- file_temp("tidy-download-")
  h <- curl::new_handle(noprogress = FALSE, progressfunction = progress_fun)
  curl::curl_download(url, tmp, quiet = FALSE, mode = "wb", handle = h)
  cat_line()

  cd <- content_disposition(h)
  base_name <- make_filename(cd, fallback = path_file(url))
  full_path <- path(destdir, base_name)

  if (!can_overwrite(full_path)) {
    ui_stop("Aborting.")
  }
  attr(full_path, "content-type") <- content_type(h)
  attr(full_path, "content-disposition") <- cd

  file_move(tmp, full_path)
  invisible(full_path)
}

tidy_unzip <- function(zipfile, cleanup = FALSE) {
  base_path <- path_dir(zipfile)

  filenames <- utils::unzip(zipfile, list = TRUE)[["Name"]]

  ## deal with DropBox's peculiar habit of including "/" as a file --> drop it
  filenames <- filenames[filenames != "/"]

  ## DropBox ZIP files often include lots of hidden R, RStudio, and Git files
  filenames <- filenames[keep_lgl(filenames)]

  td <- top_directory(filenames)
  loose_parts <- is.na(td)

  if (loose_parts) {
    target <- path_ext_remove(zipfile)
    utils::unzip(zipfile, files = filenames, exdir = target)
  } else {
    target <- path(path_dir(zipfile), td)
    utils::unzip(zipfile, files = filenames, exdir = path_dir(zipfile))
  }
  ui_done(
    "Unpacking ZIP file into {ui_path(target, base_path)} \\
    ({length(filenames)} files extracted)"
  )

  if (isNA(cleanup)) {
    cleanup <- interactive() &&
      ui_yeah("Shall we delete the ZIP file ({ui_path(zipfile, base_path)})?")
  }

  if (isTRUE(cleanup)) {
    ui_done("Deleting {ui_path(zipfile, base_path)}")
    file_delete(zipfile)
  }

  if (interactive()) {
    rproj_path <- dir_ls(target, regexp = "[.]Rproj$")
    if (length(rproj_path) == 1 && rstudioapi::hasFun("openProject")) {
      ui_done("Opening project in RStudio")
      rstudioapi::openProject(target, newSession = TRUE)
    } else if (!in_rstudio_server()) {
      ui_done("Opening {ui_path(target, base_path)} in the file manager")
      utils::browseURL(path_real(target))
    }
  }

  invisible(target)
}

normalize_url <- function(url) {
  stopifnot(is.character(url))
  has_scheme <- grepl("^http[s]?://", url)

  if (has_scheme) {
    return(url)
  }

  if (!is_shortlink(url)) {
    url <- tryCatch(
      expand_github(url),
      error = function(e) url
    )
  }

  paste0("https://", url)
}

is_shortlink <- function(url) {
  shortlink_hosts <- c("rstd\\.io", "bit\\.ly")
  any(purrr::map_lgl(shortlink_hosts, grepl, x = url))
}

expand_github <- function(url) {
  # mostly to handle errors in the spec
  repo_spec <- parse_repo_spec(url)
  glue::glue_data(repo_spec, "github.com/{owner}/{repo}/archive/master.zip")
}

conspicuous_place <- function() {
  Filter(dir_exists, c(
    path_home("Desktop"),
    path_home(),
    path_home_r(),
    path_tidy(getwd())
  ))[[1]]
}

keep_lgl <- function(file,
                     ignores = c(".Rproj.user", ".rproj.user", ".Rhistory", ".RData", ".git", "__MACOSX", ".DS_Store")) {
  ignores <- paste0(
    "((\\/|\\A)", gsub("\\.", "[.]", ignores), "(\\/|\\Z))",
    collapse = "|"
  )
  !grepl(ignores, file, perl = TRUE)
}

top_directory <- function(filenames) {
  in_top <- dirname(filenames) == "."
  unique_top <- unique(filenames[in_top])
  is_directory <- grepl("/$", unique_top)
  if (length(unique_top) > 1 || !is_directory) {
    NA_character_
  } else {
    unique_top
  }
}

content_type <- function(h) {
  headers <- curl::parse_headers_list(curl::handle_data(h)$headers)
  headers[["content-type"]]
}

content_disposition <- function(h) {
  headers <- curl::parse_headers_list(curl::handle_data(h)$headers)
  cd <- headers[["content-disposition"]]
  if (is.null(cd)) {
    return()
  }
  parse_content_disposition(cd)
}

check_is_zip <- function(ct) {
  # "https://www.fueleconomy.gov/feg/epadata/16data.zip" comes with
  # MIME type "application/x-zip-compressed"
  # see https://github.com/r-lib/usethis/issues/573
  allowed <- c("application/zip", "application/x-zip-compressed")
  if (!ct %in% allowed ) {
    ui_stop(c(
      "Download does not have MIME type {ui_value('application/zip')}.",
      "Instead it's {ui_value(ct)}."
    ))
  }
  invisible(ct)
}

## https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Disposition
## https://tools.ietf.org/html/rfc6266
## DropBox eg: "attachment; filename=\"foo.zip\"; filename*=UTF-8''foo.zip\"
##  GitHub eg: "attachment; filename=foo-master.zip"
# https://stackoverflow.com/questions/30193569/get-content-disposition-parameters
# http://test.greenbytes.de/tech/tc2231/
parse_content_disposition <- function(cd) {
  if (!grepl("^attachment;", cd)) {
    ui_stop(c(
      "{ui_code('Content-Disposition')} header doesn't start with {ui_value('attachment')}.",
      "Actual header: {ui_value(cd)}"
    ))
  }

  cd <- sub("^attachment;\\s*", "", cd, ignore.case = TRUE)
  cd <- strsplit(cd, "\\s*;\\s*")[[1]]
  cd <- strsplit(cd, "=")
  stats::setNames(
    vapply(cd, `[[`, character(1), 2),
    vapply(cd, `[[`, character(1), 1)
  )
}

progress_fun <- function(down, up) {
  total <- down[[1]]
  now <- down[[2]]
  pct <- if(length(total) && total > 0) {
    paste0("(", round(now/total * 100), "%)")
  } else {
    ""
  }
  if (now > 10000) {
    cat("\rDownloaded:", sprintf("%.2f", now / 2^20), "MB ", pct)
  }
  TRUE
}

make_filename <- function(cd,
                          fallback = path_file(file_temp())) {
  ## TO DO(jennybc): the element named 'filename*' is preferred but I'm not
  ## sure how to parse it yet, so targetting 'filename' for now
  ## https://tools.ietf.org/html/rfc6266
  cd <- cd[["filename"]]
  if (is.null(cd) || is.na(cd)) {
    stopifnot(is_string(fallback))
    return(path_sanitize(fallback))
  }

  ## I know I could use regex and lookahead but this is easier for me to
  ## maintain
  cd <- sub("^\"(.+)\"$", "\\1", cd)

  path_sanitize(cd)
}

## https://stackoverflow.com/questions/21322614/use-curl-to-download-a-dropbox-folder-via-shared-link-not-public-link
## lesson: if using cURL, you'd want these options
## -L, --location (follow redirects)
## -O, --remote-name (name local file like the file part of remote name)
## -J, --remote-header-name (tells -O option to consult Content-Disposition
##   instead of the URL)
## https://curl.haxx.se/docs/manpage.html#OPTIONS
