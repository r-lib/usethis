# Add an RMarkdown Template

Adds files and directories necessary to add a custom rmarkdown template
to RStudio. It creates:

- `inst/rmarkdown/templates/{{template_dir}}`. Main directory.

- `skeleton/skeleton.Rmd`. Your template Rmd file.

- `template.yml` with basic information filled in.

## Usage

``` r
use_rmarkdown_template(
  template_name = "Template Name",
  template_dir = NULL,
  template_description = "A description of the template",
  template_create_dir = FALSE
)
```

## Arguments

- template_name:

  The name as printed in the template menu.

- template_dir:

  Name of the directory the template will live in within
  `inst/rmarkdown/templates`. If none is provided by the user, it will
  be created from `template_name`.

- template_description:

  Sets the value of `description` in `template.yml`.

- template_create_dir:

  Sets the value of `create_dir` in `template.yml`.

## Examples

``` r
if (FALSE) { # \dontrun{
use_rmarkdown_template()
} # }
```
