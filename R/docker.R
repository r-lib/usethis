#' Set up Docker for an R package
#'
#' @description
#' Automate Docker containerization for an R package or project.
#' Creates a multi-stage Dockerfile optimized for R development.
#'
#' @param R_version Character vector of R version to use (e.g., "4.4.0").
#'   Defaults to current version via `paste0("4.", R.version$minor)`.
#' @param use_quarto Logical. Include Quarto (>= 1.5.1) for documentation rendering.
#'   Default `TRUE` if suggested packages include quarto.
#' @param use_tidyverse Logical. Include tidyverse collection (ggplot2, dplyr, tidyr, etc.).
#'   Default `FALSE`.
#' @param use_tidymodels Logical. Include tidymodels for modeling workflows.
#'   Default `FALSE`.
#' @param use_latex Logical. Include TinyTeX for LaTeX/PDF rendering.
#'   Default `FALSE`.
#' @param use_pandoc Logical. Include pandoc for document conversion.
#'   Default `TRUE` if rmarkdown is in Suggests.
#' @param use_git Logical. Include git in the image. Default `TRUE`.
#' @param additional_packages Character vector of additional system packages to install
#'   (e.g., `c("curl-dev", "openssl-dev")`). Default `NULL`.
#' @param base_image Character. Base image URI. Default `"r-base"` (rocker project).
#' @param workdir Character. Working directory inside container. Default `"/workspace"`.
#' @param open Logical. Open the generated Dockerfile after creation? Default `TRUE`
#'   if interactive.
#'
#' @details
#' Uses multi-stage Docker build:
#' 1. **builder stage**: Installs system dependencies, R packages, and tools.
#' 2. **final stage**: Minimal runtime image with installed packages and project code.
#'
#' Best practices applied:
#' - Layer caching for fast iterative builds
#' - Separate system deps, R package deps, and source code layers
#' - Non-root user for security
#' - `.dockerignore` to reduce build context
#'
#' Package dependencies are extracted from DESCRIPTION imports/suggests.
#' Local packages (`.` notation) must be in `DESCRIPTION::Imports`.
#'
#' @return `NULL` invisibly. Called for side effects (file creation).
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
  open = rlang::is_interactive()
) {
  check_is_project()

  # Set defaults
  if (is.null(R_version)) {
    R_version <- paste0(R.version$major, ".", R.version$minor)
  }

  desc <- proj_desc()
  suggests <- tolower(desc$get_field("Suggests", default = ""))
  imports <- tolower(desc$get_field("Imports", default = ""))
  all_deps <- paste(suggests, imports)

  if (is.null(use_quarto)) {
    use_quarto <- grepl("quarto", all_deps)
  }

  if (is.null(use_pandoc)) {
    use_pandoc <- grepl("rmarkdown", all_deps)
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
  r_pkgs_str <- paste0('c("', paste(r_pkgs, collapse = '", "'), '")')

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
    "# Multi-stage build for R package: {project_name}\n# Stage 1: builder\nFROM {base_image}:{R_version} AS builder\n\nWORKDIR /build\n\n# Install system dependencies\n{sys_pkgs_str}\n\n# Install R packages\nRUN R --quiet --no-save <<'EOF'\npkgs <- {r_pkgs_str}\ninstall.packages(pkgs, repos = \"https://cloud.r-project.org\")\nEOF\n\n# Stage 2: final runtime\nFROM {base_image}:{R_version}\n\n# Create non-root user (or use existing if UID in use)\nRUN useradd -m -u 1000 ruser || echo 'User already exists'\n\nWORKDIR {workdir}\n\n# Copy system deps + R packages from builder\nCOPY --from=builder /usr/local/lib/R /usr/local/lib/R\nCOPY --from=builder /usr/bin /usr/bin\nCOPY --from=builder /usr/local/bin /usr/local/bin\n\n# Install minimal system deps for runtime\n{sys_pkgs_str}\n\n# Copy project source\nCOPY --chown=ruser:ruser . .\n\n# Switch to non-root user\nUSER ruser\n\n# Set R repo and startup options\nENV R_LIBS_USER=/home/ruser/R/library\nRUN mkdir -p /home/ruser/R/library\n\n# Default: R interactive\nCMD [\"R\", \"--no-save\"]\n",
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
        "pkgdown/"
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
