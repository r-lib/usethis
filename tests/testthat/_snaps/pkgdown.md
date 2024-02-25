# use_pkgdown() creates and ignores the promised file/dir

    Code
      use_pkgdown()
    Message
      v Adding "^_pkgdown\\.yml$", "^docs$", and "^pkgdown$" to '.Rbuildignore'.
      v Adding "docs" to '.gitignore'.
      v Writing '_pkgdown.yml'.
      [ ] Edit '_pkgdown.yml'.

# pkgdown_url() returns correct data, warns if pedantic

    Code
      pkgdown_url(pedantic = TRUE)
    Message
      ! pkgdown config does not specify the site's 'url', which is optional but
        recommended.
    Output
      NULL

---

    Code
      pkgdown_url(pedantic = TRUE)
    Message
      ! pkgdown config does not specify the site's 'url', which is optional but
        recommended.
    Output
      NULL

