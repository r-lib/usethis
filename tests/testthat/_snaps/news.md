# use_news_md() sets (development version)/'Initial submission' in new pkg

    Code
      read_utf8(proj_path("NEWS.md"))
    Output
      [1] "# {TESTPKG} (development version)"
      [2] ""                                          
      [3] "* Initial submission."                     

# use_news_md() sets bullet to 'Added a NEWS.md file...' when on CRAN

    Code
      read_utf8(proj_path("NEWS.md"))
    Output
      [1] "# {TESTPKG} (development version)"               
      [2] ""                                                         
      [3] "* Added a `NEWS.md` file to track changes to the package."

# use_news_md() sets version number when 'production version'

    Code
      read_utf8(proj_path("NEWS.md"))
    Output
      [1] "# {TESTPKG} 0.2.0"                              
      [2] ""                                                         
      [3] "* Added a `NEWS.md` file to track changes to the package."

