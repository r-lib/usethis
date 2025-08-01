## see end of file for some cURL notes

#' Download and unpack a ZIP file
#'
#' Functions to download and unpack a ZIP file into a local folder of files,
#' with very intentional default behaviour. Useful in pedagogical settings or
#' anytime you need a large audience to download a set of files quickly and
#' actually be able to find them. After download, the new folder is opened in
#' a new session of the user's IDE, if possible, or in the default file manager
#' provided by the operating system. The underlying helpers are documented in
#' [use_course_details].
#'
#' @param url Link to a ZIP file containing the materials. To reduce the chance
#'   of typos in live settings, these shorter forms are accepted:
#'
#'   * GitHub repo spec: "OWNER/REPO". Equivalent to
#'     `https://github.com/OWNER/REPO/DEFAULT_BRANCH.zip`.
#'   * bit.ly, pos.it, or rstd.io shortlinks: "bit.ly/xxx-yyy-zzz",
#'     "pos.it/foofy" or "rstd.io/foofy". The instructor must then arrange for
#'     the shortlink to point to a valid download URL for the target ZIP file.
#'     The helper [create_download_url()] helps to create such URLs for GitHub,
#'     DropBox, and Google Drive.
#' @param destdir Destination for the new folder. Defaults to the location
#'   stored in the global option `usethis.destdir`, if defined, or to the user's
#'   Desktop or similarly conspicuous place otherwise.
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
#' # download the source of rematch2 package from CRAN
#' use_course("https://cran.r-project.org/bin/windows/contrib/4.5/rematch2_2.1.2.zip")
#'
#' # download the source of rematch2 package from GitHub, 4 ways
#' use_course("r-lib/rematch2")
#' use_course("https://api.github.com/repos/r-lib/rematch2/zipball/HEAD")
#' use_course("https://api.github.com/repos/r-lib/rematch2/zipball/main")
#' use_course("https://github.com/r-lib/rematch2/archive/main.zip")
#' }
NULL

#' @describeIn zip-utils
#'
#'  Designed with live workshops in mind. Includes intentional friction to
#'  highlight the download destination. Workflow:
#' * User executes, e.g., `use_course("bit.ly/xxx-yyy-zzz")`.
#' * User is asked to notice and confirm the location of the new folder. Specify
#'   `destdir` or configure the `"usethis.destdir"` option to prevent this.
#' * User is asked if they'd like to delete the ZIP file.
#' * If possible, the new folder is launched in a new session of the user's IDE.
#'   Otherwise, the folder is opened in the file manager, e.g. Finder on macOS
#'   or File Explorer on Windows.
#' @export
use_course <- function(url, destdir = getOption("usethis.destdir")) {
  url <- normalize_url(url)
  destdir_not_specified <- is.null(destdir)
  destdir <- user_path_prep(destdir %||% conspicuous_place())
  check_path_is_directory(destdir)

  if (destdir_not_specified && is_interactive()) {
    ui_bullets(c(
      "i" = "Downloading into {.path {pth(destdir)}}.",
      "_" = "Prefer a different location? Cancel, try again, and specify
             {.arg destdir}."
    ))
    if (ui_nah("OK to proceed?")) {
      ui_bullets(c(x = "Cancelling download."))
      return(invisible())
    }
  }

  ui_bullets(c("v" = "Downloading from {.url {url}}."))
  zipfile <- tidy_download(url, destdir)
  ui_bullets(c("v" = "Download stored in {.path {pth(zipfile)}}."))
  check_is_zip(attr(zipfile, "content-type"))
  tidy_unzip(zipfile, cleanup = NA)
}

#' @describeIn zip-utils
#'
#' More useful in day-to-day work. Downloads in current working directory, by
#' default, and allows `cleanup` behaviour to be specified.
#' @export
use_zip <- function(
  url,
  destdir = getwd(),
  cleanup = if (rlang::is_interactive()) NA else FALSE
) {
  url <- normalize_url(url)
  check_path_is_directory(destdir)
  ui_bullets(c("v" = "Downloading from {.url {url}}."))
  zipfile <- tidy_download(url, destdir)
  ui_bullets(c("v" = "Download stored in {.path {pth(zipfile)}}."))
  check_is_zip(attr(zipfile, "content-type"))
  tidy_unzip(zipfile, cleanup)
}

#' Helpers to download and unpack a ZIP file
#'
#' @description
#' Details on the internal and helper functions that power [use_course()] and
#' [use_zip()]. Only `create_download_url()` is exported.
#'
#' @name use_course_details
#' @keywords internal
#' @usage
#' tidy_download(url, destdir = getwd())
#' tidy_unzip(zipfile, cleanup = FALSE)
#'
#' @aliases tidy_download tidy_unzip

#' @param url A GitHub, DropBox, or Google Drive URL.
#' * For `create_download_url()`: A URL copied from a web browser.
#' * For `tidy_download()`: A download link for a ZIP file, possibly behind a
#'   shortlink or other redirect. `create_download_url()` can be helpful for
#'   creating this URL from typical browser URLs.
#' @param destdir Path to existing local directory where the ZIP file will be
#'   stored. Defaults to current working directory, but note that [use_course()]
#'   has different default behavior.
#' @param zipfile Path to local ZIP file.
#' @param cleanup Whether to delete the ZIP file after unpacking. In an
#'   interactive session, `cleanup = NA` leads to asking the user if they
#'   want to delete or keep the ZIP file.

#' @section tidy_download():
#'
#' ```
#' # how it's used inside use_course()
#' tidy_download(
#'   # url has been processed with internal helper normalize_url()
#'   url,
#'   # conspicuous_place() = `getOption('usethis.destdir')` or desktop or home
#'   # directory or working directory
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
#' `tidy_download()` is setup to retry after a download failure. In an
#' interactive session, it asks for user's consent. All retries use a longer
#' connect timeout.
#'
#' ## DropBox
#'
#' To make a folder available for ZIP download, create a shared link for it:
#' * <https://help.dropbox.com/share/create-and-share-link>
#'
#' A shared link will have this form:
#' ```
#' https://www.dropbox.com/sh/12345abcde/6789wxyz?dl=0
#' ```
#' Replace the `dl=0` at the end with `dl=1` to create a download link:
#' ```
#' https://www.dropbox.com/sh/12345abcde/6789wxyz?dl=1
#' ```
#' You can use `create_download_url()` to do this conversion.
#'
#' This download link (or a shortlink that points to it) is suitable as input
#' for `tidy_download()`. After one or more redirections, this link will
#' eventually lead to a download URL. For more details, see
#' <https://help.dropbox.com/share/force-download> and
#' <https://help.dropbox.com/sync/download-entire-folders>.
#'
#' ## GitHub
#'
#' Click on the repo's "Clone or download" button, to reveal a "Download ZIP"
#' button. Capture this URL, which will have this form:
#' ```
#' https://github.com/r-lib/usethis/archive/main.zip
#' ```
#' This download link (or a shortlink that points to it) is suitable as input
#' for `tidy_download()`. After one or more redirections, this link will
#' eventually lead to a download URL. Here are other links that also lead to
#' ZIP download, albeit with a different filenaming scheme (REF could be a
#' branch name, a tag, or a SHA):
#' ```
#' https://github.com/github.com/r-lib/usethis/zipball/HEAD
#' https://api.github.com/repos/r-lib/rematch2/zipball/REF
#' https://api.github.com/repos/r-lib/rematch2/zipball/HEAD
#' https://api.github.com/repos/r-lib/usethis/zipball/REF
#' ```
#'
#' You can use `create_download_url()` to create the "Download ZIP" URL from
#' a typical GitHub browser URL.
#'
#' ## Google Drive
#'
#' To our knowledge, it is not possible to download a Google Drive folder as a
#' ZIP archive. It is however possible to share a ZIP file stored on Google
#' Drive. To get its URL, click on "Get the shareable link" (within the "Share"
#' menu). This URL doesn't allow for direct download, as it's designed to be
#' processed in a web browser first. Such a sharing link looks like:
#'
#' ```
#' https://drive.google.com/open?id=123456789xxyyyzzz
#' ```
#'
#' To be able to get the URL suitable for direct download, you need to extract
#' the "id" element from the URL and include it in this URL format:
#'
#' ```
#' https://drive.google.com/uc?export=download&id=123456789xxyyyzzz
#' ```
#'
#' Use `create_download_url()` to perform this transformation automatically.
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
#' @examples
#' \dontrun{
#' tidy_download("https://github.com/r-lib/rematch2/archive/main.zip")
#' tidy_unzip("rematch2-main.zip")
#' }
NULL

# 1. downloads from `url`
# 2. calls a retry-capable helper to download the ZIP file
# 3. determines filename from content-description header (with fallbacks)
# 4. returned path has content-type and content-description as attributes
tidy_download <- function(url, destdir = getwd()) {
  check_path_is_directory(destdir)
  tmp <- file_temp("tidy-download-")

  h <- download_url(url, destfile = tmp)
  cli::cat_line()

  cd <- content_disposition(h)
  base_name <- make_filename(cd, fallback = path_file(url))
  full_path <- path(destdir, base_name)

  if (!can_overwrite(full_path)) {
    ui_abort(
      "
      Cancelling download, to avoid overwriting {.path {pth(full_path)}}."
    )
  }
  attr(full_path, "content-type") <- content_type(h)
  attr(full_path, "content-disposition") <- cd

  file_move(tmp, full_path)
  invisible(full_path)
}

download_url <- function(
  url,
  destfile,
  handle = curl::new_handle(),
  n_tries = 3,
  retry_connecttimeout = 40L
) {
  handle_options <- list(noprogress = FALSE, progressfunction = progress_fun)
  curl::handle_setopt(handle, .list = handle_options)

  we_should_retry <- function(i, n_tries, status) {
    if (i >= n_tries) {
      FALSE
    } else if (inherits(status, "error")) {
      # TODO: find a way to detect a (connect) timeout more specifically?
      # https://github.com/jeroen/curl/issues/154
      # https://ec.haxx.se/usingcurl/usingcurl-timeouts
      # "Failing to connect within the given time will cause curl to exit with a
      # timeout exit code (28)."
      # (however, note that all timeouts lead to this same exit code)
      # https://ec.haxx.se/usingcurl/usingcurl-returns
      # "28. Operation timeout. The specified time-out period was reached
      # according to the conditions. curl offers several timeouts, and this exit
      # code tells one of those timeout limits were reached."
      # https://github.com/curl/curl/blob/272282a05416e42d2cc4a847a31fd457bc6cc827/lib/strerror.c#L143-L144
      # "Timeout was reached" <-- actual message we could potentially match
      TRUE
    } else {
      FALSE
    }
  }

  status <- try_download(url, destfile, handle = handle)
  if (inherits(status, "error") && is_interactive()) {
    ui_bullets(c("x" = status$message))
    if (
      ui_nah(c(
        "!" = "Download failed :(",
        "i" = "See above for everything we know about why it failed.",
        " " = "Shall we try a couple more times, with a longer timeout?"
      ))
    ) {
      n_tries <- 1
    }
  }

  i <- 1
  # invariant: we have made i download attempts
  while (we_should_retry(i, n_tries, status)) {
    if (i == 1) {
      curl::handle_setopt(
        handle,
        .list = c(connecttimeout = retry_connecttimeout)
      )
    }
    i <- i + 1
    ui_bullets(c("i" = "Retrying download ... attempt {i}."))
    status <- try_download(url, destfile, handle = handle)
  }

  if (inherits(status, "error")) {
    stop(status)
  }

  invisible(handle)
}

try_download <- function(url, destfile, quiet = FALSE, mode = "wb", handle) {
  tryCatch(
    curl::curl_download(
      url = url,
      destfile = destfile,
      quiet = quiet,
      mode = mode,
      handle = handle
    ),
    error = function(e) e
  )
}

tidy_unzip <- function(zipfile, cleanup = FALSE) {
  base_path <- path_dir(zipfile)

  filenames <- utils::unzip(zipfile, list = TRUE)[["Name"]]

  ## deal with DropBox's peculiar habit of including "/" as a file --> drop it
  filenames <- filenames[filenames != "/"]

  ## DropBox ZIP files often include lots of hidden R, RStudio, and Git files
  filenames <- filenames[keep_lgl(filenames)]

  parents <- path_before_slash(filenames)
  unique_parents <- unique(parents)
  if (length(unique_parents) == 1 && unique_parents != "") {
    target <- path(base_path, unique_parents)
    utils::unzip(zipfile, files = filenames, exdir = base_path)
  } else {
    # there is no parent; archive contains loose parts
    target <- path_ext_remove(zipfile)
    utils::unzip(zipfile, files = filenames, exdir = target)
  }
  ui_bullets(c(
    "v" = "Unpacking ZIP file into {.path {pth(target, base_path)}}
           ({length(filenames)} file{?s} extracted)."
  ))

  if (isNA(cleanup)) {
    cleanup <- is_interactive() &&
      ui_yep(
        "Shall we delete the ZIP file ({.path {pth(zipfile, base_path)}})?"
      )
  }

  if (isTRUE(cleanup)) {
    ui_bullets(c("v" = "Deleting {.path {pth(zipfile, base_path)}}."))
    file_delete(zipfile)
  }

  if (is_interactive()) {
    proj_root <- proj_find(target)
    if (rstudio_available() && rstudioapi::hasFun("openProject")) {
      if (is.null(proj_root)) {
        file_create(path(target, ".here"))
      }
      ui_bullets(c(
        "v" = "Opening {.path {pth(target, base = NA)}} in a new session."
      ))
      rstudioapi::openProject(target, newSession = TRUE)
    } else if (!in_rstudio_server()) {
      ui_bullets(c(
        "v" = "Opening {.path {pth(target, base_path)}} in the file manager."
      ))
      utils::browseURL(path_real(target))
    }
  }

  invisible(unclass(target))
}

#' @rdname use_course_details
#' @examples
#' # GitHub
#' create_download_url("https://github.com/r-lib/usethis")
#' create_download_url("https://github.com/r-lib/usethis/issues")
#'
#' # DropBox
#' create_download_url("https://www.dropbox.com/sh/12345abcde/6789wxyz?dl=0")
#'
#' # Google Drive
#' create_download_url("https://drive.google.com/open?id=123456789xxyyyzzz")
#' create_download_url("https://drive.google.com/open?id=123456789xxyyyzzz/view")
#' @export
create_download_url <- function(url) {
  check_name(url)
  stopifnot(grepl("^http[s]?://", url))

  switch(
    classify_url(url),
    drive = modify_drive_url(url),
    dropbox = modify_dropbox_url(url),
    github = modify_github_url(url),
    hopeless_url(url)
  )
}

classify_url <- function(url) {
  if (grepl("drive.google.com", url)) {
    return("drive")
  }
  if (grepl("dropbox.com/sh", url)) {
    return("dropbox")
  }
  if (grepl("github.com", url)) {
    return("github")
  }
  "unknown"
}

modify_drive_url <- function(url) {
  # id-isolating approach taken from the gargle / googleverse
  id_loc <- regexpr("/d/([^/])+|/folders/([^/])+|id=([^/])+", url)
  if (id_loc == -1) {
    return(hopeless_url(url))
  }
  id <- gsub("/d/|/folders/|id=", "", regmatches(url, id_loc))
  glue_chr("https://drive.google.com/uc?export=download&id={id}")
}

modify_dropbox_url <- function(url) {
  gsub("dl=0", "dl=1", url)
}

modify_github_url <- function(url) {
  # TO CONSIDER: one could use the API for this, which might be more proper and
  # would work if auth is needed
  # https://docs.github.com/en/free-pro-team@latest/rest/reference/repos#download-a-repository-archive-zip
  # https://api.github.com/repos/OWNER/REPO/zipball/
  # but then, in big workshop settings, we might see rate limit problems or
  # get blocked because of too many token-free requests from same IP
  parsed <- parse_github_remotes(url)
  glue_data_chr(
    parsed,
    "{protocol}://{host}/{repo_owner}/{repo_name}/zipball/HEAD"
  )
}

hopeless_url <- function(url) {
  ui_bullets(c(
    "!" = "URL does not match a recognized form for Google Drive or DropBox;
           no change made."
  ))
  url
}

normalize_url <- function(url) {
  check_name(url)
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
  shortlink_hosts <- c("rstd\\.io", "bit\\.ly", "pos\\.it")
  any(map_lgl(shortlink_hosts, grepl, x = url))
}

expand_github <- function(url) {
  # mostly to handle errors in the spec
  repo_spec <- parse_repo_spec(url)
  glue_data_chr(repo_spec, "github.com/{owner}/{repo}/zipball/HEAD")
}

conspicuous_place <- function() {
  destdir_opt <- getOption("usethis.destdir")
  if (!is.null(destdir_opt)) {
    return(path_tidy(destdir_opt))
  }

  Filter(
    dir_exists,
    c(
      path_home("Desktop"),
      path_home(),
      path_home_r(),
      path_tidy(getwd())
    )
  )[[1]]
}

keep_lgl <- function(
  file,
  ignores = c(
    ".Rproj.user",
    ".rproj.user",
    ".Rhistory",
    ".RData",
    ".git",
    "__MACOSX",
    ".DS_Store"
  )
) {
  ignores <- paste0(
    "((\\/|\\A)",
    gsub("\\.", "[.]", ignores),
    "(\\/|\\Z))",
    collapse = "|"
  )
  !grepl(ignores, file, perl = TRUE)
}

path_before_slash <- function(filepath) {
  f <- function(x) {
    parts <- strsplit(x, "/", fixed = TRUE)[[1]]
    if (length(parts) > 1 || grepl("/", x)) {
      parts[1]
    } else {
      ""
    }
  }
  purrr::map_chr(filepath, f)
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
  if (!ct %in% allowed) {
    ui_abort(c(
      "Download does not have MIME type {.val application/zip}.",
      "Instead it's {.val {ct}}."
    ))
  }
  invisible(ct)
}

## https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Content-Disposition
## https://tools.ietf.org/html/rfc6266
## DropBox eg: "attachment; filename=\"foo.zip\"; filename*=UTF-8''foo.zip\"
##  GitHub eg: "attachment; filename=foo-main.zip"
# https://stackoverflow.com/questions/30193569/get-content-disposition-parameters
# http://test.greenbytes.de/tech/tc2231/
parse_content_disposition <- function(cd) {
  if (!grepl("^attachment;", cd)) {
    ui_abort(c(
      "{.code Content-Disposition} header doesn't start with {.val attachment}.",
      "Actual header: {.val cd}"
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
  pct <- if (length(total) && total > 0) {
    paste0("(", round(now / total * 100), "%)")
  } else {
    ""
  }
  if (now > 10000) {
    cat("\rDownloaded:", sprintf("%.2f", now / 2^20), "MB ", pct)
  }
  TRUE
}

make_filename <- function(cd, fallback = path_file(file_temp())) {
  ## TO DO(jennybc): the element named 'filename*' is preferred but I'm not
  ## sure how to parse it yet, so targeting 'filename' for now
  ## https://tools.ietf.org/html/rfc6266
  cd <- cd[["filename"]]
  if (is.null(cd) || is.na(cd)) {
    check_name(fallback)
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
