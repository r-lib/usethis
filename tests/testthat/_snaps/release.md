# release bullets don't change accidentally

    Code
      writeLines(release_checklist("0.1.0", on_cran = FALSE))
    Output
      First release:
      
      * [ ] `usethis::use_cran_comments()`
      * [ ] Update (aspirational) install instructions in README
      * [ ] Proofread `Title:` and `Description:`
      * [ ] Check that all exported functions have `@return` and `@examples`
      * [ ] Check that `Authors@R:` includes a copyright holder (role 'cph')
      * [ ] Check [licensing of included files](https://r-pkgs.org/license.html#code-you-bundle)
      * [ ] Review <https://github.com/DavisVaughan/extrachecks>
      
      Prepare for release:
      
      * [ ] `git pull`
      * [ ] Check if any deprecation processes should be advanced, as described in [Gradual deprecation](https://lifecycle.r-lib.org/articles/communicate.html#gradual-deprecation)
      * [ ] `urlchecker::url_check()`
      * [ ] `devtools::check(remote = TRUE, manual = TRUE)`
      * [ ] `devtools::check_win_devel()`
      * [ ] `rhub::check_for_cran()`
      * [ ] `git push`
      * [ ] Draft blog post
      
      Submit to CRAN:
      
      * [ ] `usethis::use_version('minor')`
      * [ ] `devtools::submit_cran()`
      * [ ] Approve email
      
      Wait for CRAN...
      
      * [ ] Accepted :tada:
      * [ ] `git push`
      * [ ] `usethis::use_github_release()`
      * [ ] `usethis::use_dev_version()`
      * [ ] `usethis::use_news_md()`
      * [ ] `git push`
      * [ ] Finish blog post
      * [ ] Tweet
      * [ ] Add link to blog post in pkgdown news menu

---

    Code
      writeLines(release_checklist("0.0.1", on_cran = TRUE))
    Output
      Prepare for release:
      
      * [ ] `git pull`
      * [ ] Check [current CRAN check results](https://cran.rstudio.org/web/checks/check_results_{TESTPKG}.html)
      * [ ] [Polish NEWS](https://style.tidyverse.org/news.html#news-release)
      * [ ] `urlchecker::url_check()`
      * [ ] `devtools::check(remote = TRUE, manual = TRUE)`
      * [ ] `devtools::check_win_devel()`
      * [ ] `rhub::check_for_cran()`
      * [ ] `revdepcheck::revdep_check(num_workers = 4)`
      * [ ] Update `cran-comments.md`
      * [ ] `git push`
      
      Submit to CRAN:
      
      * [ ] `usethis::use_version('patch')`
      * [ ] `devtools::submit_cran()`
      * [ ] Approve email
      
      Wait for CRAN...
      
      * [ ] Accepted :tada:
      * [ ] `git push`
      * [ ] `usethis::use_github_release()`
      * [ ] `usethis::use_dev_version()`
      * [ ] `usethis::use_news_md()`
      * [ ] `git push`

---

    Code
      writeLines(release_checklist("1.0.0", on_cran = TRUE))
    Output
      Prepare for release:
      
      * [ ] `git pull`
      * [ ] Check [current CRAN check results](https://cran.rstudio.org/web/checks/check_results_{TESTPKG}.html)
      * [ ] Check if any deprecation processes should be advanced, as described in [Gradual deprecation](https://lifecycle.r-lib.org/articles/communicate.html#gradual-deprecation)
      * [ ] [Polish NEWS](https://style.tidyverse.org/news.html#news-release)
      * [ ] `urlchecker::url_check()`
      * [ ] `devtools::check(remote = TRUE, manual = TRUE)`
      * [ ] `devtools::check_win_devel()`
      * [ ] `rhub::check_for_cran()`
      * [ ] `revdepcheck::revdep_check(num_workers = 4)`
      * [ ] Update `cran-comments.md`
      * [ ] `git push`
      * [ ] Draft blog post
      
      Submit to CRAN:
      
      * [ ] `usethis::use_version('major')`
      * [ ] `devtools::submit_cran()`
      * [ ] Approve email
      
      Wait for CRAN...
      
      * [ ] Accepted :tada:
      * [ ] `git push`
      * [ ] `usethis::use_github_release()`
      * [ ] `usethis::use_dev_version()`
      * [ ] `usethis::use_news_md()`
      * [ ] `git push`
      * [ ] Finish blog post
      * [ ] Tweet
      * [ ] Add link to blog post in pkgdown news menu

---

    Code
      writeLines(release_checklist("1.0.0", on_cran = TRUE))
    Output
      Prepare for release:
      
      * [ ] `git pull`
      * [ ] Check [current CRAN check results](https://cran.rstudio.org/web/checks/check_results_{TESTPKG}.html)
      * [ ] Check if any deprecation processes should be advanced, as described in [Gradual deprecation](https://lifecycle.r-lib.org/articles/communicate.html#gradual-deprecation)
      * [ ] [Polish NEWS](https://style.tidyverse.org/news.html#news-release)
      * [ ] `usethis::use_github_links()`
      * [ ] `urlchecker::url_check()`
      * [ ] `devtools::check(remote = TRUE, manual = TRUE)`
      * [ ] `devtools::check_win_devel()`
      * [ ] `rhub::check_for_cran()`
      * [ ] `revdepcheck::revdep_check(num_workers = 4)`
      * [ ] Update `cran-comments.md`
      * [ ] `git push`
      * [ ] Draft blog post
      
      Submit to CRAN:
      
      * [ ] `usethis::use_version('major')`
      * [ ] `devtools::submit_cran()`
      * [ ] Approve email
      
      Wait for CRAN...
      
      * [ ] Accepted :tada:
      * [ ] `git push`
      * [ ] `usethis::use_github_release()`
      * [ ] `usethis::use_dev_version()`
      * [ ] `usethis::use_news_md()`
      * [ ] `git push`
      * [ ] Finish blog post
      * [ ] Tweet
      * [ ] Add link to blog post in pkgdown news menu

# construct correct revdep bullet

    Code
      release_revdepcheck(on_cran = FALSE)
    Output
      NULL
    Code
      release_revdepcheck(on_cran = TRUE, is_rstudio_pkg = FALSE)
    Output
      [1] "* [ ] `revdepcheck::revdep_check(num_workers = 4)`"
    Code
      release_revdepcheck(on_cran = TRUE, is_rstudio_pkg = TRUE)
    Output
      [1] "* [ ] `revdepcheck::cloud_check()`"
    Code
      release_revdepcheck(on_cran = TRUE, is_rstudio_pkg = TRUE, env = env)
    Output
      [1] "* [ ] `revdepcheck::cloud_check(extra_revdeps = c(\"waldo\", \"testthat\"))`"

# RStudio-ness detection works

    Code
      writeLines(release_checklist("1.0.0", on_cran = TRUE))
    Output
      Prepare for release:
      
      * [ ] `git pull`
      * [ ] Check [current CRAN check results](https://cran.rstudio.org/web/checks/check_results_{TESTPKG}.html)
      * [ ] Check if any deprecation processes should be advanced, as described in [Gradual deprecation](https://lifecycle.r-lib.org/articles/communicate.html#gradual-deprecation)
      * [ ] [Polish NEWS](https://style.tidyverse.org/news.html#news-release)
      * [ ] `urlchecker::url_check()`
      * [ ] `devtools::check(remote = TRUE, manual = TRUE)`
      * [ ] `devtools::check_win_devel()`
      * [ ] `rhub::check_for_cran()`
      * [ ] `revdepcheck::cloud_check()`
      * [ ] Update `cran-comments.md`
      * [ ] `git push`
      * [ ] Draft blog post
      * [ ] Slack link to draft blog in #open-source-comms
      
      Submit to CRAN:
      
      * [ ] `usethis::use_version('major')`
      * [ ] `devtools::submit_cran()`
      * [ ] Approve email
      
      Wait for CRAN...
      
      * [ ] Accepted :tada:
      * [ ] `git push`
      * [ ] `usethis::use_github_release()`
      * [ ] `usethis::use_dev_version()`
      * [ ] `usethis::use_news_md()`
      * [ ] `git push`
      * [ ] Finish blog post
      * [ ] Tweet
      * [ ] Add link to blog post in pkgdown news menu

