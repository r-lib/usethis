#' Set up Docker for an R package
#'
#' @description
#' Automate Docker containerization for an R package or project.
#' Creates a multi-stage Dockerfile optimized for R development.
#'
#' @param R_version Character string of R version to use (e.g., "4.4.0").
#'   Defaults to current version via `paste0(R.version$major, ".", R.version$minor)`.
#' @param use_quarto Logical. Include Quarto (>= 1.5.1) for documentation rendering.
#'   Default `TRUE` if quarto is in Imports or Suggests.
#' @param use_tidyverse Logical. Include tidyverse collection (ggplot2, dplyr, tidyr, etc.).
#'   Default `FALSE`.
#' @param use_tidymodels Logical. Include tidymodels for modeling workflows.
#'   Default `FALSE`.
#' @param use_latex Logical. Include TinyTeX for LaTeX/PDF rendering.
#'   Default `FALSE`.
#' @param use_pandoc Logical. Include pandoc for document conversion.
#'   Default `TRUE` if rmarkdown is in Imports or Suggests.
#' @param use_git Logical. Include git in the image. Default `TRUE`.
#' @param additional_packages Character vector of additional system packages to install
#'   (e.g., `c("curl-dev", "libxml2-dev")`). Default `NULL`.
#' @param base_image Character. Base image URI without tag.
#'   Default `"rocker/r-ver"` (Ubuntu Jammy-based, includes pandoc).
#'   Do not include a tag; the tag is controlled by `R_version`.
#' @param workdir Character. Working directory inside container. Default `"/workspace"`.
#' @param repos Character. R package repositories for `install.packages()`.
#'   Default uses [Posit Public Package Manager](https://packagemanager.posit.co)
#'   with a date-pinned snapshot for reproducibility.
#' @param open Logical. Open the generated Dockerfile after creation? Default `TRUE`
#'   if interactive.
#'
#' @details
#' Uses multi-stage Docker build:
#' 1. **builder stage**: Installs system dependencies and R packages.
#' 2. **final stage**: Runtime image with installed packages and project code.
#'
#' Best practices applied:
#' - Layer caching for fast iterative builds
#' - Separate system deps, R package deps, and source code layers
#' - Non-root user for security
#' - `.dockerignore` to reduce build context
#' - Date-pinned package repository for reproducibility
#'
#' Package dependencies are extracted from DESCRIPTION imports/suggests.
#'
#' @return `TRUE` invisibly. Called for side effects (file creation).
#'
#' @seealso
#' - [Docker documentation](https://docs.docker.com/develop/dev-best-practices/)
#' - [Rocker project](https://rocker-project.org/) for R base images
#' - [Quarto](https://quarto.org/) for documentation
#'
#' @export
#' @examples
#' \dontrun{
#' # Basic R package with tidyverse
#' use_dockerfile(use_tidyverse = TRUE)
#'
#' # Full stack: tidymodels, Quarto, LaTeX
#' use_dockerfile(
#'   use_tidymodels = TRUE,
#'   use_quarto = TRUE,
#'   use_latex = TRUE
#' )
#'
#' # Custom R version and system packages
#' use_dockerfile(
#'   R_version = "4.3.2",
#'   additional_packages = c("curl-dev", "libxml2-dev")
#' )
#' }
use_dockerfile <- function(
  R_version = NULL,
  use_quarto = NULL,
  use_tidyverse = FALSE,
  use_tidymodels = FALSE,
  use_latex = FALSE,
  use_pandoc = NULL,
  use_git = TRUE,
  additional_packages = NULL,
  base_image = "rocker/r-ver",
  workdir = "/workspace",
  repos = NULL,
  open = rlang::is_interactive()
) {
  check_is_project()

  if (grepl(":", base_image)) {
    ui_abort(c(
      "!" = "{.arg base_image} must not include a tag.",
      "i" = "Pass just the image name (e.g., {.val rocker/r-ver}) and use {.arg R_version} to control the tag."
    ))
  }

  # Set defaults
  if (is.null(R_version)) {
    R_version <- paste0(R.version$major, ".", R.version$minor)
  }

  if (length(R_version) != 1L) {
    ui_abort("{.arg R_version} must be a single character string.")
  }

  if (is.null(repos)) {
    repos <- paste0(
      "https://packagemanager.posit.co/cran/__linux__/jammy/",
      Sys.Date()
    )
  }

  desc <- proj_desc()
  deps <- desc$get_deps()

  # Robustly get all dependencies from DESCRIPTION
  r_pkgs <- deps$package[
    deps$type %in% c("Depends", "Imports", "Suggests", "LinkingTo")
  ]
  r_pkgs <- setdiff(r_pkgs, "R") # Remove R itself

  if (is.null(use_quarto)) {
    use_quarto <- "quarto" %in% tolower(r_pkgs)
  }

  if (is.null(use_pandoc)) {
    use_pandoc <- "rmarkdown" %in% tolower(r_pkgs)
  }

  project_name <- project_name()

  # Build R packages list
  if (use_tidyverse) {
    r_pkgs <- c(r_pkgs, "tidyverse")
  }
  if (use_tidymodels) {
    r_pkgs <- c(r_pkgs, "tidymodels")
  }
  if (use_quarto) {
    r_pkgs <- c(r_pkgs, "quarto")
  }
  # Note: if use_latex, we use system texlive rather than tinytex to avoid bloat
  if (use_pandoc) {
    r_pkgs <- c(r_pkgs, "rmarkdown")
  }

  r_pkgs <- unique(sort(r_pkgs))
  check_docker_pkgs(r_pkgs)

  r_pkgs_str <- if (length(r_pkgs)) {
    paste0('c("', paste(r_pkgs, collapse = '", "'), '")')
  } else {
    "character(0)"
  }

  # Build system packages list
  sys_pkgs <- c()
  if (use_git) {
    sys_pkgs <- c(sys_pkgs, "git")
  }

  if (use_latex) {
    sys_pkgs <- c(
      sys_pkgs,
      "texlive-latex-base",
      "texlive-fonts-recommended",
      "texlive-latex-extra"
    )
  }

  if (!is.null(additional_packages)) {
    sys_pkgs <- c(sys_pkgs, additional_packages)
  }

  sys_pkgs <- unique(sys_pkgs)

  # Use apt for Debian/Ubuntu-based rocker images
  if (length(sys_pkgs) > 0) {
    sys_pkgs_str <- paste0(
      "RUN apt-get update && apt-get install -y --no-install-recommends ",
      paste(sys_pkgs, collapse = " "),
      " && rm -rf /var/lib/apt/lists/*"
    )
  } else {
    sys_pkgs_str <- "# No additional system packages needed"
  }

  # Build Dockerfile content
  dockerfile_content <- glue(
    "
# syntax=docker/dockerfile:1.6

# Multi-stage build for R package: {project_name}

# Stage 1: builder
FROM {base_image}:{R_version} AS builder

ENV R_LIBS=/rlib
WORKDIR /build

# Install system dependencies
{sys_pkgs_str}

# Install R packages into a dedicated library
RUN mkdir -p /rlib && Rscript -e 'install.packages({r_pkgs_str}, repos = \"{repos}\", lib = \"/rlib\")'

# Stage 2: final runtime
FROM {base_image}:{R_version}

LABEL org.opencontainers.image.title=\"{project_name}\"

# Create non-root user (skip if already exists)
RUN id -u ruser >/dev/null 2>&1 || useradd -m -u 1000 ruser

# Install runtime system deps
{sys_pkgs_str}

WORKDIR {workdir}

# Copy R packages from builder
COPY --from=builder /rlib /rlib
ENV R_LIBS=/rlib

# Copy project source
COPY --chown=ruser:ruser . .

# Ensure working directory is owned by non-root user
RUN chown -R ruser:ruser {workdir}

# Switch to non-root user
USER ruser

# Default: R interactive
CMD [\"R\", \"--no-save\"]
",
    .trim = FALSE
  )

  # Ensure .dockerignore exists
  dockerignore_path <- proj_path(".dockerignore")
  if (!fs::file_exists(dockerignore_path)) {
    use_build_ignore(".dockerignore", escape = FALSE)
    writeLines(
      c(
        ".git",
        ".gitignore",
        ".Rbuildignore",
        ".Rproj.user",
        ".vscode",
        "README.md",
        "NEWS.md",
        "*.log",
        "*.swp",
        "*.swo",
        "*~",
        ".DS_Store",
        "revdep/",
        "pkgdown/",
        "renv/library",
        "renv/staging"
      ),
      dockerignore_path
    )
  }

  # Ensure Dockerfile is in .Rbuildignore
  use_build_ignore("Dockerfile")

  # Write Dockerfile
  new <- write_over(
    proj_path("Dockerfile"),
    dockerfile_content,
    quiet = FALSE
  )

  # Cleanly construct UI features list
  features <- c(
    use_quarto && "Quarto",
    use_tidyverse && "Tidyverse",
    use_tidymodels && "Tidymodels",
    use_latex && "LaTeX"
  )
  features <- features[features]

  bullets <- c(
    "v" = "Dockerfile created at {.path {pth('Dockerfile')}}",
    "i" = "To build: {.code docker build -t {tolower(project_name)}:{R_version} .}",
    "i" = "To run: {.code docker run -it {tolower(project_name)}:{R_version}}",
    "i" = "R version: {R_version}",
    if (length(features)) "i" <- "Features: {paste(features, collapse = ', ')}"
  )

  ui_bullets(bullets)

  if (open) {
    edit_file(proj_path("Dockerfile"))
  }

  invisible(TRUE)
}


#' Validate package names for Dockerfile generation
#'
#' @keywords internal
#' @noRd
check_docker_pkgs <- function(pkgs) {
  if (length(pkgs) == 0) {
    return(invisible())
  }
  # Per WRE: start with letter, >= 2 chars, <= 63 chars, letters/digits/dots, no trailing dot
  bad <- pkgs[
    !grepl("^[A-Za-z][A-Za-z0-9.]{1,62}$", pkgs) | grepl("\\.$", pkgs)
  ]
  if (length(bad) > 0) {
    ui_abort(c(
      "x" = "Invalid package name{?s}: {.val {bad}}.",
      "i" = "Package names must start with a letter, be 2-63 characters, contain only ASCII letters, digits, and '.', and not end with a '.'."
    ))
  }
  invisible()
}
