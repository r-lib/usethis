# Vaccinate your global gitignore file

Adds `.Rproj.user`, `.Rhistory`, `.Rdata`, `.httr-oauth`, `.DS_Store`,
and `.quarto` to your global (a.k.a. user-level) `.gitignore`. This is
good practice as it decreases the chance that you will accidentally leak
credentials to GitHub. `git_vaccinate()` also tries to detect and fix
the situation where you have a global gitignore file, but it's missing
from your global Git config.

## Usage

``` r
git_vaccinate()
```
