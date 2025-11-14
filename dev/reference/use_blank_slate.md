# Don't save/load user workspace between sessions

R can save and reload the user's workspace between sessions via an
`.RData` file in the current directory. However, long-term
reproducibility is enhanced when you turn this feature off and clear R's
memory at every restart. Starting with a blank slate provides timely
feedback that encourages the development of scripts that are complete
and self-contained. More detail can be found in the blog post
[Project-oriented
workflow](https://www.tidyverse.org/blog/2017/12/workflow-vs-script/).

## Usage

``` r
use_blank_slate(scope = c("user", "project"))
```

## Arguments

- scope:

  Edit globally for the current **user**, or locally for the current
  **project**
