# Learn a specialized skill

**\[experimental\]**

`learn_tidy_skill()` prints detailed instructions for performing a
specialized R package development task the way the tidyverse team does.
It's primarily designed to be called by AI coding agents: the
`AGENTS.md` created by
[`use_tidy_agents()`](https://usethis.r-lib.org/dev/reference/use_tidy_agents.md)
tells agents when to read each skill.

## Usage

``` r
learn_tidy_skill(name)
```

## Arguments

- name:

  Name of the skill:

  - `"arg-checking"`: add input checking to a function.

  - `"deprecate"`: deprecate a function or argument.

## Examples

``` r
if (FALSE) { # \dontrun{
learn_tidy_skill("deprecate")
} # }
```
