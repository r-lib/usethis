#' Use MIT, GPL-3, or Apache 2.0 license for your package
#'
#' @description
#' Adds the necessary infrastructure to declare your package as licensed
#' with one of three popular open source license:
#'
#' * [MIT](https://choosealicense.com/licenses/mit/): simple and permission.
#' * [Apache 2.0](https://choosealicense.com/licenses/apache-2.0/):
#'   provides patent protection.
#' * [GPL v3](https://choosealicense.com/licenses/gpl-3.0/): requires sharing
#'   of improvements.
#'
#' See <https://choosealicense.com> for more details and other options.
#'
#' @details
#' CRAN does not allow you to include copies of standard licenses in your
#' package, so these functions save the license as `LICENSE.md` and add it
#' to `.Rbuildignore`.
#'
#' @name licenses
#' @param name Name of the copyright holder or holders. Separate multiple
#'   individuals with `;`.
#' @inheritParams use_template
#' @aliases NULL
#' @md
NULL

#' @rdname licenses
#' @export
use_mit_license <- function(name,
                            base_path = ".") {

  force(name)

  use_description_field(
    "License", "MIT + file LICENSE",
    overwrite = TRUE,
    base_path = base_path
  )
  use_license_template("mit", name, base_path = base_path)

  # Fill in template
  use_template(
    "license-mit.txt",
    "LICENSE",
    data = license_data(name, base_path = base_path),
    base_path = base_path
  )
}


#' @rdname licenses
#' @export
use_gpl3_license <- function(name, base_path = ".") {
  force(name)

  use_description_field(
    "License", "GPL-3",
    overwrite = TRUE,
    base_path = base_path
  )
  use_license_template("GPL-3", name, base_path = base_path)
}

#' @rdname licenses
#' @export
use_apl2_license <- function(name, base_path = ".") {
  force(name)

  use_description_field(
    "License", "Apache License (>= 2.0)",
    overwrite = TRUE,
    base_path = base_path
  )
  use_license_template("apache-2.0", name, base_path = base_path)
}


use_license_template <- function(license, name, base_path = ".") {
  license_template <- paste0("license-", license, ".md")

  use_template(
    license_template,
    "LICENSE.md",
    data = license_data(name, base_path = base_path),
    base_path = base_path,
    ignore = TRUE
  )
}

license_data <- function(name, base_path = ".") {
  list(
    year = format(Sys.Date(), "%Y"),
    name = name,
    project = project_name(base_path)
  )
}
