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

# use_pkgdown() nudges towards use_logo() if the package seems to have a logo

    Code
      use_pkgdown()
    Message
      v Adding "^_pkgdown\\.yml$", "^docs$", and "^pkgdown$" to '.Rbuildignore'.
      v Adding "docs" to '.gitignore'.
      [ ] If your package has a logo, see use_logo (`?usethis::use_logo()`) to set it
        up.
      v Writing '_pkgdown.yml'.
      [ ] Edit '_pkgdown.yml'.

# use_pkgdown() nudges towards build_favicons().

    Code
      use_pkgdown()
    Message
      v Adding "^_pkgdown\\.yml$", "^docs$", and "^pkgdown$" to '.Rbuildignore'.
      v Adding "docs" to '.gitignore'.
      [ ] Call `pkgdown::build_favicons(pkg = '.', overwrite = FALSE)` to create
        favicons for your website.
      v Writing '_pkgdown.yml'.
      [ ] Edit '_pkgdown.yml'.

