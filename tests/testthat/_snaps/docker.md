# use_dockerfile() outputs expected messages

    Code
      use_dockerfile(R_version = "4.3.2", use_quarto = TRUE, use_tidyverse = TRUE,
        open = FALSE)
    Message
      v Adding ".dockerignore" to '.Rbuildignore'.
      v Adding "^Dockerfile$" to '.Rbuildignore'.
      v Writing 'Dockerfile'.
      v Dockerfile created at 'Dockerfile'
      i To build: `docker build -t testpkg:4.3.2 .`
      i To run: `docker run -it testpkg:4.3.2`
      i R version: 4.3.2
      i Quarto: enabled
      i Tidyverse: enabled

# use_dockerfile() errors on vector R_version

    Code
      use_dockerfile(R_version = c("4.3.0", "4.4.0"), open = FALSE)
    Condition
      Error in `use_dockerfile()`:
      x `R_version` must be a single character string.

# use_dockerfile() errors when base_image includes a tag

    Code
      use_dockerfile(base_image = "rocker/r-ver:4.3.3", open = FALSE)
    Condition
      Error in `use_dockerfile()`:
      ! `base_image` must not include a tag.
      i Pass just the image name (e.g., "rocker/r-ver") and use `R_version` to control the tag.

