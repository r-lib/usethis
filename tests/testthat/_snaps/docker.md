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

