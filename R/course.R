download_zip <- function(url) {
  dl <- curl::curl_fetch_memory(url)

  httr::stop_for_status(dl$status_code)
  stopifnot(
    grepl("^https://dl.dropboxusercontent.com/content_link_zip/", dl$url) ||
      grepl("^https://codeload.github.com", dl$url)
  )

  hh <- curl::parse_headers_list(dl$headers)
  stopifnot(hh[["content-type"]] == "application/zip")
  content_disposition <- hh[["content-disposition"]]
  stopifnot(!is.null(content_disposition), nzchar(content_disposition))

  message("content_disposition:\n", content_disposition)
  filename <- strsplit(content_disposition, "\\s*;\\s*")[[1]]
  filename <- grep("^filename=", filename, value = TRUE)
  filename <- rematch2::re_match(
    filename,
    "filename=\"?(?<filename>[^\"]*)\"?"
  )
  filename <- filename$filename
  message("filename:\n", filename)

  ## sanitize filename here

  writeBin(dl$content, filename)
  invisible(filename)
}
