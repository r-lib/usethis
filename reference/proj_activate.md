# Activate a project

Activates a project in the usethis, R session, and (if relevant) RStudio
or Positron senses. If you are in RStudio or Positron, this will open a
new session or window. If not, it will change the working directory and
[active project](https://usethis.r-lib.org/reference/proj_utils.md).

## Usage

``` r
proj_activate(path)
```

## Arguments

- path:

  Project directory

## Value

Single logical value indicating if current session is modified.

## Details

- If using RStudio desktop, the project is opened in a new session.

- If using Positron, the project is opened in a new window.

- If using RStudio or Positron on a server, the project is opened in a
  new browser tab.

- Otherwise, the working directory and active project are changed in the
  current R session.
