# download_url() retry logic works as advertised

    Code
      out <- download_url(url = "URL", destfile = "destfile")

---

    Code
      out <- download_url(url = "URL", destfile = "destfile")
    Message <message>
      i Retrying download ... attempt 2

---

    Code
      out <- download_url(url = "URL", destfile = "destfile")
    Message <message>
      i Retrying download ... attempt 2
      i Retrying download ... attempt 3

---

    Code
      out <- download_url(url = "URL", destfile = "destfile", n_tries = 3)
    Message <message>
      i Retrying download ... attempt 2
      i Retrying download ... attempt 3
    Error <simpleError>
      try 3

---

    Code
      out <- download_url(url = "URL", destfile = "destfile", n_tries = 10)
    Message <message>
      i Retrying download ... attempt 2
      i Retrying download ... attempt 3
      i Retrying download ... attempt 4

