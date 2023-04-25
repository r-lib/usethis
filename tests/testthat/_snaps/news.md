# use_news_md() sets (development version)/'Initial submission' in new pkg

    Code
      writeLines(read_utf8(proj_path("NEWS.md")))
    Output
      # {TESTPKG} (development version)
      
      * Initial CRAN submission.

# use_news_md() sets bullet to 'Added a NEWS.md file...' when on CRAN

    Code
      writeLines(read_utf8(proj_path("NEWS.md")))
    Output
      # {TESTPKG} (development version)
      
      * Added a `NEWS.md` file to track changes to the package.

# use_news_md() sets version number when 'production version'

    Code
      writeLines(read_utf8(proj_path("NEWS.md")))
    Output
      # {TESTPKG} 0.2.0
      
      * Initial CRAN submission.

