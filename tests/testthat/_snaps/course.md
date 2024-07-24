# download_url() retry logic works as advertised

    Code
      out <- download_url(url = "URL", destfile = "destfile")

---

    Code
      out <- download_url(url = "URL", destfile = "destfile")
    Message
      i Retrying download ... attempt 2.

---

    Code
      out <- download_url(url = "URL", destfile = "destfile")
    Message
      i Retrying download ... attempt 2.
      i Retrying download ... attempt 3.

---

    Code
      out <- download_url(url = "URL", destfile = "destfile", n_tries = 3)
    Message
      i Retrying download ... attempt 2.
      i Retrying download ... attempt 3.
    Condition
      Error:
      ! try 3

---

    Code
      out <- download_url(url = "URL", destfile = "destfile", n_tries = 10)
    Message
      i Retrying download ... attempt 2.
      i Retrying download ... attempt 3.
      i Retrying download ... attempt 4.

# normalize_url() prepends https:// (or not)

    Code
      normalize_url(1)
    Condition
      Error in `normalize_url()`:
      ! `url` must be a valid name, not the number 1.

