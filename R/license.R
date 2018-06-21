#' License a package
#'
#' @description
#' Adds the necessary infrastructure to declare your package as licensed
#' with one of four popular open source license:
#'
#' * [CC0](https://creativecommons.org/publicdomain/zero/1.0/): dedicated
#'   to public domain. Appropriate for data packages.
#' * [MIT](https://choosealicense.com/licenses/mit/): simple and permissive.
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
#'   individuals with `;`. You can supply a global default with
#'   `options(usethis.full_name = "My name")`.
#' @aliases NULL
NULL

#' @rdname licenses
#' @export
use_mit_license <- function(name = find_name()) {
  force(name)
  check_is_package("use_mit_license()")

  use_description_field("License", "MIT + file LICENSE", overwrite = TRUE)
  use_license_template("mit", name)

  # Fill in template
  use_template(
    "license-mit.txt",
    "LICENSE",
    data = license_data(name)
  )
}


#' @rdname licenses
#' @export
use_gpl3_license <- function(name = find_name()) {
  force(name)
  check_is_package("use_gpl3_license()")

  use_description_field("License", "GPL-3", overwrite = TRUE)
  use_license_template("GPL-3", name)
}

#' @rdname licenses
#' @export
use_apl2_license <- function(name = find_name()) {
  force(name)
  check_is_package("use_apl2_license()")

  use_description_field("License", "Apache License (>= 2.0)", overwrite = TRUE)
  use_license_template("apache-2.0", name)
}

#' @rdname licenses
#' @export
use_cc0_license <- function(name = find_name()) {
  force(name)
  check_is_package("use_cc0_license()")

  use_description_field("License", "CC0", overwrite = TRUE)
  use_license_template("cc0", name)
}


use_license_template <- function(license, name) {
  license_template <- glue("license-{license}.md")

  use_template(
    license_template,
    "LICENSE.md",
    data = license_data(name),
    ignore = TRUE
  )
}

license_data <- function(name, base_path = proj_get()) {
  list(
    year = format(Sys.Date(), "%Y"),
    name = name,
    project = project_name(base_path)
  )
}


find_name <- function() {
  name <- getOption("usethis.full_name")
  if (!is.null(name)) {
    return(name)
  }

  name <- getOption("devtools.name")
  if (!is.null(name) && name != "Your name goes here") {
    return(name)
  }

  stop_glue(
    "{code('name')} argument is missing.\n",
    "Set it globally with {code('options(usethis.full_name = \"My name\")')}",
    ", probably in your {value('.Rprofile')}."
  )
}
