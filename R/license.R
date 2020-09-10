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
#' * [AGPL v3](https://choosealicense.com/licenses/agpl-3.0/): requires sharing
#'   of improvements.
#' * [LGPL v3](https://choosealicense.com/licenses/lgpl-3.0/): requires sharing
#'   of improvements.
#' * [CCBY 4.0](https://creativecommons.org/licenses/by/4.0/): Free to share and
#'    adapt, must give appropriate credit. Appropriate for data packages.
#'
#' See <https://choosealicense.com> for more details and other options.
#'
#' @details
#' CRAN does not permit you to include copies of standard licenses in your
#' package, so these functions save the license as `LICENSE.md` and add it
#' to `.Rbuildignore`.
#'
#' @name licenses
#' @param copyright_holder Name of the copyright holder or holders. This
#'   defaults to "{package name} authors"; you should only change this if you
#'   use a CLA to assign copyright to a single entity.
#' @seealso For more details, refer to the the
#'   [license chapter](https://r-pkgs.org/license.html) in _R Packages_.
#' @aliases NULL
NULL

#' @rdname licenses
#' @export
use_mit_license <- function(copyright_holder = NULL) {
  data <- list(
    year = format(Sys.Date(), "%Y"),
    copyright_holder = copyright_holder %||% glue("{project_name()} authors")
  )

  if (is_package()) {
    use_description_field("License", "MIT + file LICENSE", overwrite = TRUE)
    use_template("year-copyright.txt", save_as = "LICENSE", data = data)
  }

  use_license_template("mit", data)
}

#' @rdname licenses
#' @export
use_gpl3_license <- function() {
  if (is_package()) {
    use_description_field("License", "GPL-3", overwrite = TRUE)
  }
  use_license_template("GPL-3")
}

#' @rdname licenses
#' @export
use_agpl3_license <- function() {
  if (is_package()) {
    use_description_field("License", "AGPL-3", overwrite = TRUE)
  }
  use_license_template("AGPL-3")
}

#' @rdname licenses
#' @export
use_lgpl_license <- function() {
  if (is_package()) {
    use_description_field("License", "LGPL (>= 2.1)", overwrite = TRUE)
  }
  use_license_template("LGPL-2.1")
}

#' @rdname licenses
#' @export
use_apl2_license <- function() {
  if (is_package()) {
    use_description_field("License", "Apache License (>= 2.0)", overwrite = TRUE)
  }
  use_license_template("apache-2.0")
}

#' @rdname licenses
#' @export
use_cc0_license <- function() {
  if (is_package()) {
    use_description_field("License", "CC0", overwrite = TRUE)
  }
  use_license_template("cc0")
}

#' @rdname licenses
#' @export
use_ccby_license <- function() {
  if (is_package()) {
    use_description_field("License", "CC BY 4.0", overwrite = TRUE)
  }
  use_license_template("ccby-4")
}

use_license_template <- function(license, data = list()) {
  license_template <- glue("license-{license}.md")

  use_template(license_template,
    save_as = "LICENSE.md",
    data = data,
    ignore = TRUE
  )
}
