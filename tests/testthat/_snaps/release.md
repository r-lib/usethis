# release bullets don't change accidentally

    Code
      cat(release_checklist("0.1.0", on_cran = FALSE), sep = "\n")
    Output
      First release:
      
      * [ ] `usethis::use_cran_comments()`
      * [ ] Proofread `Title:` and `Description:`
      * [ ] Check that all exported functions have `@return` and `@examples`
      * [ ] Check that `Authors@R:` includes a copyright holder (role 'cph')
      * [ ] Check [licensing of included files](https://r-pkgs.org/license.html#code-you-bundle)
      * [ ] Review <https://github.com/DavisVaughan/extrachecks>
      
      Prepare for release:
      
      * [ ] `urlchecker::url_check()`
      * [ ] `devtools::check(remote = TRUE, manual = TRUE)`
      * [ ] `devtools::check_win_devel()`
      * [ ] `rhub::check_for_cran()`
      * [ ] Draft blog post
      
      Submit to CRAN:
      
      * [ ] `usethis::use_version('minor')`
      * [ ] `devtools::submit_cran()`
      * [ ] Approve email
      
      Wait for CRAN...
      
      * [ ] Accepted :tada:
      * [ ] `usethis::use_github_release()`
      * [ ] `usethis::use_dev_version()`
      * [ ] `usethis::use_news_md()`
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
      * [ ] [Polish NEWS](https://style.tidyverse.org/news.html#news-release)
      * [ ] `urlchecker::url_check()`
      * [ ] `devtools::check(remote = TRUE, manual = TRUE)`
      * [ ] `devtools::check_win_devel()`
      * [ ] `rhub::check_for_cran()`
      * [ ] `revdepcheck::revdep_check(num_workers = 4)`
      * [ ] Update `cran-comments.md`
      
      Submit to CRAN:
      
      * [ ] `usethis::use_version('patch')`
      * [ ] `devtools::submit_cran()`
      * [ ] Approve email
      
      Wait for CRAN...
      
      * [ ] Accepted :tada:
      * [ ] `usethis::use_github_release()`
      * [ ] `usethis::use_dev_version()`
      * [ ] `usethis::use_news_md()`

---

    Code
      cat(release_checklist("1.0.0", on_cran = TRUE), sep = "\n")
    Output
      Prepare for release:
      
      * [ ] Check [current CRAN check results](https://cran.rstudio.org/web/checks/check_results_releasebullets.html)
      * [ ] [Polish NEWS](https://style.tidyverse.org/news.html#news-release)
      * [ ] `urlchecker::url_check()`
      * [ ] `devtools::check(remote = TRUE, manual = TRUE)`
      * [ ] `devtools::check_win_devel()`
      * [ ] `rhub::check_for_cran()`
      * [ ] `revdepcheck::revdep_check(num_workers = 4)`
      * [ ] Update `cran-comments.md`
      * [ ] Draft blog post
      
      Submit to CRAN:
      
      * [ ] `usethis::use_version('major')`
      * [ ] `devtools::submit_cran()`
      * [ ] Approve email
      
      Wait for CRAN...
      
      * [ ] Accepted :tada:
      * [ ] `usethis::use_github_release()`
      * [ ] `usethis::use_dev_version()`
      * [ ] `usethis::use_news_md()`
      * [ ] Finish blog post
      * [ ] Tweet
      * [ ] Add link to blog post in pkgdown news menu

