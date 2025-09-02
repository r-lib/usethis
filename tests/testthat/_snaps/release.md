# release bullets don't change accidentally

    Code
      writeLines(release_checklist("0.1.0", on_cran = FALSE))
    Output
      First release:
      
      * [ ] `usethis::use_news_md()`
      * [ ] `usethis::use_cran_comments()`
      * [ ] Update (aspirational) install instructions in README
      * [ ] Proofread `Title:` and `Description:`
      * [ ] Check that all exported functions have `@return` and `@examples`
      * [ ] Check that `Authors@R:` includes a copyright holder (role 'cph')
      * [ ] Check [licensing of included files](https://r-pkgs.org/license.html#sec-code-you-bundle)
      * [ ] Review <https://github.com/DavisVaughan/extrachecks>
      
      Prepare for release:
      
      * [ ] `git pull`
      * [ ] `usethis::use_github_links()`
      * [ ] `urlchecker::url_check()`
      * [ ] `devtools::check(remote = TRUE, manual = TRUE)`
      * [ ] `devtools::check_win_devel()`
      * [ ] `git push`
      * [ ] Draft blog post
      
      Submit to CRAN:
      
      * [ ] `usethis::gh_lock_branch()`
      * [ ] `usethis::use_version('minor')`
      * [ ] `devtools::submit_cran()`
      * [ ] Approve email
      
      Wait for CRAN...
      
      * [ ] Accepted :tada:
      * [ ] `usethis::gh_unlock_branch()`
      * [ ] Finish & publish blog post
      * [ ] Add link to blog post in pkgdown news menu
      * [ ] `usethis::use_github_release()`
      * [ ] `usethis::use_dev_version(push = TRUE)`
      * [ ] `usethis::use_news_md()`
      * [ ] Share on social media

---

    Code
      writeLines(release_checklist("0.0.1", on_cran = TRUE))
    Output
      Prepare for release:
      
      * [ ] `git pull`
      * [ ] Check [current CRAN check results](https://cran.rstudio.org/web/checks/check_results_{TESTPKG}.html)
      * [ ] `usethis::use_news_md()`
      * [ ] [Polish NEWS](https://style.tidyverse.org/news.html#news-release)
      * [ ] `usethis::use_github_links()`
      * [ ] `urlchecker::url_check()`
      * [ ] `devtools::check(remote = TRUE, manual = TRUE)`
      * [ ] `devtools::check_win_devel()`
      * [ ] `revdepcheck::revdep_check(num_workers = 4)`
      * [ ] Update `cran-comments.md`
      * [ ] `git push`
      
      Submit to CRAN:
      
      * [ ] `usethis::gh_lock_branch()`
      * [ ] `usethis::use_version('patch')`
      * [ ] `devtools::submit_cran()`
      * [ ] Approve email
      
      Wait for CRAN...
      
      * [ ] Accepted :tada:
      * [ ] `usethis::gh_unlock_branch()`
      * [ ] `usethis::use_github_release()`
      * [ ] `usethis::use_dev_version(push = TRUE)`
      * [ ] `usethis::use_news_md()`

---

    Code
      writeLines(release_checklist("1.0.0", on_cran = TRUE))
    Output
      Prepare for release:
      
      * [ ] `git pull`
      * [ ] Check [current CRAN check results](https://cran.rstudio.org/web/checks/check_results_{TESTPKG}.html)
      * [ ] `usethis::use_news_md()`
      * [ ] [Polish NEWS](https://style.tidyverse.org/news.html#news-release)
      * [ ] `usethis::use_github_links()`
      * [ ] `urlchecker::url_check()`
      * [ ] `devtools::check(remote = TRUE, manual = TRUE)`
      * [ ] `devtools::check_win_devel()`
      * [ ] `revdepcheck::revdep_check(num_workers = 4)`
      * [ ] Update `cran-comments.md`
      * [ ] `git push`
      * [ ] Draft blog post
      
      Submit to CRAN:
      
      * [ ] `usethis::gh_lock_branch()`
      * [ ] `usethis::use_version('major')`
      * [ ] `devtools::submit_cran()`
      * [ ] Approve email
      
      Wait for CRAN...
      
      * [ ] Accepted :tada:
      * [ ] `usethis::gh_unlock_branch()`
      * [ ] Finish & publish blog post
      * [ ] Add link to blog post in pkgdown news menu
      * [ ] `usethis::use_github_release()`
      * [ ] `usethis::use_dev_version(push = TRUE)`
      * [ ] `usethis::use_news_md()`
      * [ ] Share on social media

# construct correct revdep bullet

    Code
      release_revdepcheck(on_cran = FALSE)
    Output
      NULL
    Code
      release_revdepcheck(on_cran = TRUE, is_posit_pkg = FALSE)
    Output
      [1] "* [ ] `revdepcheck::revdep_check(num_workers = 4)`"
    Code
      release_revdepcheck(on_cran = TRUE, is_posit_pkg = TRUE)
    Output
      [1] "* [ ] `revdepcheck::cloud_check()`"
    Code
      release_revdepcheck(on_cran = TRUE, is_posit_pkg = TRUE, env = env)
    Output
      [1] "* [ ] `revdepcheck::cloud_check(extra_revdeps = c(\"waldo\", \"testthat\"))`"

# RStudio-ness detection works

    Code
      writeLines(release_checklist("1.0.0", on_cran = TRUE))
    Output
      Prepare for release:
      
      * [ ] `git pull`
      * [ ] Check [current CRAN check results](https://cran.rstudio.org/web/checks/check_results_{TESTPKG}.html)
      * [ ] `usethis::use_news_md()`
      * [ ] [Polish NEWS](https://style.tidyverse.org/news.html#news-release)
      * [ ] `usethis::use_github_links()`
      * [ ] `urlchecker::url_check()`
      * [ ] `devtools::check(remote = TRUE, manual = TRUE)`
      * [ ] `devtools::check_win_devel()`
      * [ ] `revdepcheck::cloud_check()`
      * [ ] Update `cran-comments.md`
      * [ ] `git push`
      * [ ] Draft blog post
      
      Submit to CRAN:
      
      * [ ] `usethis::gh_lock_branch()`
      * [ ] `usethis::use_version('major')`
      * [ ] `devtools::submit_cran()`
      * [ ] Approve email
      
      Wait for CRAN...
      
      * [ ] Accepted :tada:
      * [ ] `usethis::gh_unlock_branch()`
      * [ ] Finish & publish blog post
      * [ ] Add link to blog post in pkgdown news menu
      * [ ] `usethis::use_github_release()`
      * [ ] `usethis::use_dev_version(push = TRUE)`
      * [ ] `usethis::use_news_md()`
      * [ ] Share on social media
      * [ ] Slack link to blog post, bluesky, and linkedin in #open-source-comms

# no revdep release bullets when there are no revdeps

    Code
      writeLines(release_checklist("1.0.0", on_cran = TRUE))
    Output
      Prepare for release:
      
      * [ ] `git pull`
      * [ ] Check [current CRAN check results](https://cran.rstudio.org/web/checks/check_results_{TESTPKG}.html)
      * [ ] `usethis::use_news_md()`
      * [ ] [Polish NEWS](https://style.tidyverse.org/news.html#news-release)
      * [ ] `usethis::use_github_links()`
      * [ ] `urlchecker::url_check()`
      * [ ] `devtools::check(remote = TRUE, manual = TRUE)`
      * [ ] `devtools::check_win_devel()`
      * [ ] Update `cran-comments.md`
      * [ ] `git push`
      * [ ] Draft blog post
      
      Submit to CRAN:
      
      * [ ] `usethis::gh_lock_branch()`
      * [ ] `usethis::use_version('major')`
      * [ ] `devtools::submit_cran()`
      * [ ] Approve email
      
      Wait for CRAN...
      
      * [ ] Accepted :tada:
      * [ ] `usethis::gh_unlock_branch()`
      * [ ] Finish & publish blog post
      * [ ] Add link to blog post in pkgdown news menu
      * [ ] `usethis::use_github_release()`
      * [ ] `usethis::use_dev_version(push = TRUE)`
      * [ ] `usethis::use_news_md()`
      * [ ] Share on social media

