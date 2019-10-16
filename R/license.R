#' License a package
#'
#' @description
#' Adds the necessary infrastructure to declare your package as licensed
#' with one of these popular open source licenses:
#'
#' * [CC0](https://creativecommons.org/publicdomain/zero/1.0/): dedicated
#'   to public domain. Appropriate for data packages.
#' * [MIT](https://choosealicense.com/licenses/mit/): simple and permissive.
#' * [Apache 2.0](https://choosealicense.com/licenses/apache-2.0/):
#'   provides patent protection.
#' * [GPL v3](https://choosealicense.com/licenses/gpl-3.0/): requires sharing
#'   of improvements.
#' * [AGPL v3](https://choosealicense.com/licenses/gpl-3.0/): requires sharing
#'   of improvements.
#' * [LGPL v3](https://choosealicense.com/licenses/lgpl-3.0/): requires sharing
#'   of improvements.
#' * [CCBY 4.0](https://creativecommons.org/licenses/by/4.0/): Free to share and
#'    adapt, must give appropriate credit. Appropriate for data packages.
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
#' @seealso The [license
#'   section](https://r-pkgs.org/description.html#license) of [R
#'   Packages](https://r-pkgs.org).
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
    "year-copyright.txt",
    save_as = "LICENSE",
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
use_agpl3_license <- function(name = find_name()) {
  force(name)
  check_is_package("use_agpl3_license()")

  use_description_field("License", "AGPL-3", overwrite = TRUE)
  use_license_template("AGPL-3", name)
}

#' @rdname licenses
#' @export
use_lgpl_license <- function(name = find_name()) {
  force(name)
  check_is_package("use_lgpl_license()")

  use_description_field("License", "LGPL (>= 2.1)", overwrite = TRUE)
  use_license_template("LGPL-2.1", name)
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

#' @rdname licenses
#' @export
use_ccby_license <- function(name = find_name()) {
  force(name)
  check_is_package("use_ccby_license()")

  use_description_field("License", "CC BY 4.0", overwrite = TRUE)
  use_license_template("ccby-4", name)
}

use_license_template <- function(license, name) {
  license_template <- glue("license-{license}.md")

  use_template(
    license_template,
    save_as = "LICENSE.md",
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

  ui_stop(
    "
    {ui_code('name')} argument is missing.
    Set it globally with {ui_code('options(usethis.full_name = \"My name\")')}\\
    probably in your {ui_path('.Rprofile')}.
    "
  )
}
