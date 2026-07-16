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
#'   Default `"rocker/r-base"` (rocker project). Do not include a tag;
#'   the tag is controlled by `R_version`.
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
#' Local packages (`.` notation) must be in `DESCRIPTION::Imports`.
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
  base_image = "rocker/r-base",
  workdir = "/workspace",
  repos = paste0(
    "https://packagemanager.rstudio.com/cran/__linux__/jammy/",
    Sys.Date()
  ),
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

  desc <- proj_desc()
  suggests <- desc$get_field("Suggests", default = "")
  imports <- desc$get_field("Imports", default = "")
  all_deps <- tolower(paste(suggests, imports))

  if (is.null(use_quarto)) {
    use_quarto <- grepl("quarto", all_deps, fixed = TRUE)
  }

  if (is.null(use_pandoc)) {
    use_pandoc <- grepl("rmarkdown", all_deps, fixed = TRUE)
  }

  project_name <- project_name()
  is_pkg <- is_package()

  # Build R packages list
  r_pkgs <- c()
  if (use_tidyverse) {
    r_pkgs <- c(r_pkgs, "tidyverse")
  }
  if (use_tidymodels) {
    r_pkgs <- c(r_pkgs, "tidymodels")
  }
  if (use_quarto) {
    r_pkgs <- c(r_pkgs, "quarto")
  }
  if (use_latex) {
    r_pkgs <- c(r_pkgs, "tinytex")
  }
  if (use_pandoc) {
    r_pkgs <- c(r_pkgs, "rmarkdown")
  }

  # Extract packages from DESCRIPTION
  if (is_pkg) {
    desc_imports <- parse_dependencies(imports)
    desc_suggests <- parse_dependencies(suggests)
    r_pkgs <- c(r_pkgs, desc_imports, desc_suggests)
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

  # Use apt for Debian-based rocker images
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
# Multi-stage build for R package: {project_name}

# Stage 1: builder
FROM {base_image}:{R_version} AS builder

WORKDIR /build

# Install system dependencies
{sys_pkgs_str}

# Install R packages
RUN R --quiet --no-save <<'EOF'
pkgs <- {r_pkgs_str}
install.packages(pkgs, repos = \"{repos}\")
EOF

# Stage 2: final runtime
FROM {base_image}:{R_version}

# Create non-root user (skip if already exists)
RUN id -u ruser >/dev/null 2>&1 || useradd -m -u 1000 ruser

WORKDIR {workdir}

# Copy R packages from builder
COPY --from=builder /usr/local/lib/R /usr/local/lib/R

# Install system deps for runtime
{sys_pkgs_str}

# Copy project source
COPY --chown=ruser:ruser . .

# Switch to non-root user
USER ruser

# Set R repo and startup options
ENV R_LIBS_USER=/home/ruser/R/library
RUN mkdir -p /home/ruser/R/library

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
        ".claude",
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

  ui_bullets(c(
    "v" = "Dockerfile created at {.path {pth('Dockerfile')}}",
    "i" = "To build: {.code docker build -t {tolower(project_name)}:{R_version} .}",
    "i" = "To run: {.code docker run -it {tolower(project_name)}:{R_version}}",
    "i" = "R version: {R_version}",
    if (use_quarto) c("i" = "Quarto: enabled"),
    if (use_tidyverse) c("i" = "Tidyverse: enabled"),
    if (use_tidymodels) c("i" = "Tidymodels: enabled"),
    if (use_latex) c("i" = "LaTeX: enabled")
  ))

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
  bad <- pkgs[!grepl("^[A-Za-z][A-Za-z0-9.]+$", pkgs)]
  if (length(bad) > 0) {
    ui_abort(c(
      "x" = "Invalid package name{?s}: {.val {bad}}.",
      "i" = "Package names must start with a letter and contain only ASCII letters, digits, and '.'."
    ))
  }
  invisible()
}


#' Parse package dependencies from DESCRIPTION field
#'
#' @keywords internal
#' @noRd
parse_dependencies <- function(deps_str) {
  if (!nzchar(deps_str)) {
    return(character(0))
  }

  # Split by comma, clean whitespace and version specs
  deps <- strsplit(deps_str, ",")[[1]]
  deps <- trimws(deps)
  # Remove version specs: package (>= 1.0) -> package
  deps <- sub("\\s*\\(.*\\)$", "", deps)
  deps <- trimws(deps)
  deps <- unique(deps[nzchar(deps)])
  sort(deps)
}
