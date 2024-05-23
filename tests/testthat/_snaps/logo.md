# use_logo() shows a clickable path with README

    Code
      use_logo("logo.png")
    Message
      v Creating 'man/figures/'.
      v Resized 'logo.png' to 240x278.
      [ ] Add logo to 'README.md' with the following html:
        # {TESTPKG} <img src="man/figures/logo.png" align="right" height="90" alt="" />

# use_logo() nudges towards adding favicons

    Code
      use_logo("logo.png")
    Message
      v Creating 'man/figures/'.
      v Resized 'logo.png' to 240x278.
      [ ] Add logo to your README with the following html:
      ! pkgdown config does not specify the site's 'url', which is optional but
        recommended.
        # {TESTPKG} <img src="man/figures/logo.png" align="right" height="90" alt="" />
      [ ] Call `pkgdown::build_favicons(pkg = '.', overwrite = TRUE)` to rebuild
        favicons.

