# release bullets don't change accidentally

    Code
      cat(release_checklist("0.1.0", on_cran = FALSE), sep = "\n")
    Output
      Prepare for release:
      
      * [ ] Check that description is informative
      * [ ] Check licensing of included files
      * [ ] `usethis::use_cran_comments()`
      * [ ] `devtools::check(remote = TRUE, manual = TRUE)`
      * [ ] `devtools::check_win_devel()`
      * [ ] `rhub::check_for_cran()`
      * [ ] `urlchecker::url_check()`
      * [ ] Update `cran-comments.md`
      * [ ] Draft blog post
      
      Submit to CRAN:
      
      * [ ] `usethis::use_version('minor')`
      * [ ] `devtools::submit_cran()`
      * [ ] Approve email
      
      Wait for CRAN...
      
      * [ ] Accepted :tada:
      * [ ] `usethis::use_news_md()`
      * [ ] `usethis::use_github_release()`
      * [ ] `usethis::use_dev_version()`
      * [ ] Update install instructions in README
      * [ ] Finish blog post
      * [ ] Tweet
      * [ ] Add link to blog post in pkgdown news menu

---

    Code
      cat(release_checklist("0.0.1", on_cran = TRUE), sep = "\n")
    Output
      Prepare for release:
      
      * [ ] Check [current CRAN check results](https://cran.rstudio.org/web/checks/check_results_releasebullets.html)
      * [ ] `devtools::check(remote = TRUE, manual = TRUE)`
      * [ ] `devtools::check_win_devel()`
      * [ ] `rhub::check_for_cran()`
      * [ ] `revdepcheck::revdep_check(num_workers = 4)`
      * [ ] `urlchecker::url_check()`
      * [ ] Update `cran-comments.md`
      * [ ] [Polish NEWS](https://style.tidyverse.org/news.html#news-release)
      
      Submit to CRAN:
      
      * [ ] `usethis::use_version('patch')`
      * [ ] `devtools::submit_cran()`
      * [ ] Approve email
      
      Wait for CRAN...
      
      * [ ] Accepted :tada:
      * [ ] `usethis::use_news_md()`
      * [ ] `usethis::use_github_release()`
      * [ ] `usethis::use_dev_version()`

---

    Code
      cat(release_checklist("1.0.0", on_cran = TRUE), sep = "\n")
    Output
      Prepare for release:
      
      * [ ] Check [current CRAN check results](https://cran.rstudio.org/web/checks/check_results_releasebullets.html)
      * [ ] `devtools::check(remote = TRUE, manual = TRUE)`
      * [ ] `devtools::check_win_devel()`
      * [ ] `rhub::check_for_cran()`
      * [ ] `revdepcheck::revdep_check(num_workers = 4)`
      * [ ] `urlchecker::url_check()`
      * [ ] Update `cran-comments.md`
      * [ ] [Polish NEWS](https://style.tidyverse.org/news.html#news-release)
      * [ ] Draft blog post
      
      Submit to CRAN:
      
      * [ ] `usethis::use_version('major')`
      * [ ] `devtools::submit_cran()`
      * [ ] Approve email
      
      Wait for CRAN...
      
      * [ ] Accepted :tada:
      * [ ] `usethis::use_news_md()`
      * [ ] `usethis::use_github_release()`
      * [ ] `usethis::use_dev_version()`
      * [ ] Finish blog post
      * [ ] Tweet
      * [ ] Add link to blog post in pkgdown news menu

