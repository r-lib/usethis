# use_logo() shows a clickable path with README

    Code
      use_logo("logo.png")
    Message
      v Creating 'man/figures/'.
      v Resized 'logo.png' to 240x278.
      [ ] Add logo to 'README.md' with the following html:
        # {TESTPKG} <img src="man/figures/logo.png" align="right" height="90" alt="" />

# use_logo() writes a file in lowercase and it knows that

    Code
      use_logo("LoGo.PNG")
    Message
      v Creating 'man/figures/'.
      v Resized 'LoGo.PNG' to 240x278.
      [ ] Add logo to your README with the following html:
        # {TESTPKG} <img src="man/figures/logo.png" align="right" height="90" alt="" />

