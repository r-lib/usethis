#' License a package
#'
#' @description
#' Adds the necessary infrastructure to declare your package as licensed
#' with one of these popular open source licenses:
#'
#' Permissive:
#' * [MIT](https://choosealicense.com/licenses/mit/): simple and permissive.
#' * [Apache 2.0](https://choosealicense.com/licenses/apache-2.0/): MIT +
#'   provides patent protection.
#'
#' Copyleft:
#' * [GPL v2](https://choosealicense.com/licenses/gpl-2.0/): requires sharing
#'   of improvements.
#' * [GPL v3](https://choosealicense.com/licenses/gpl-3.0/): requires sharing
#'   of improvements.
#' * [AGPL v3](https://choosealicense.com/licenses/agpl-3.0/): requires sharing
#'   of improvements.
#' * [LGPL v2.1](https://choosealicense.com/licenses/lgpl-2.1/): requires sharing
#'   of improvements.
#' * [LGPL v3](https://choosealicense.com/licenses/lgpl-3.0/): requires sharing
#'   of improvements.
#'
#' Creative commons licenses appropriate for data packages:
#' * [CC0](https://creativecommons.org/publicdomain/zero/1.0/): dedicated
#'   to public domain.
#' * [CC-BY](https://creativecommons.org/licenses/by/4.0/): Free to share and
#'    adapt, must give appropriate credit.
#'
#' See <https://choosealicense.com> for more details and other options.
#'
#' Alternatively, for code that you don't want to share with others,
#' `use_proprietary_license()` makes it clear that all rights are reserved,
#' and the code is not open source.
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
#' @param version License version. This defaults to latest version all licenses.
#' @param include_future If `TRUE`, will license your package under the current
#'   and any potential future versions of the license. This is generally
#'   considered to be good practice because it means your package will
#'   automatically include "bug" fixes in licenses.
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
use_gpl_license <- function(version = 3, include_future = TRUE) {
  version <- check_license_version(version, 2:3)

  if (is_package()) {
    abbr <- license_abbr("GPL", version, include_future)
    use_description_field("License", abbr, overwrite = TRUE)
  }
  use_license_template(glue("GPL-{version}"))
}

#' @rdname licenses
#' @export
use_agpl_license <- function(version = 3, include_future = TRUE) {
  version <- check_license_version(version, 3)

  if (is_package()) {
    abbr <- license_abbr("AGPL", version, include_future)
    use_description_field("License", abbr, overwrite = TRUE)
  }
  use_license_template(glue("AGPL-{version}"))
}

#' @rdname licenses
#' @export
use_lgpl_license <- function(version = 3, include_future = TRUE) {
  version <- check_license_version(version, c(2.1, 3))
  if (is_package()) {
    abbr <- license_abbr("LGPL", version, include_future)
    use_description_field("License", abbr, overwrite = TRUE)
  }
  use_license_template(glue("LGPL-{version}"))
}

#' @rdname licenses
#' @export
use_apache_license <- function(version = 2, include_future = TRUE) {
  version <- check_license_version(version, 2)

  if (is_package()) {
    abbr <- license_abbr("Apache License", version, include_future)
    use_description_field("License", abbr, overwrite = TRUE)
  }
  use_license_template(glue("apache-{version}"))
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

#' @rdname licenses
#' @export
use_proprietary_license <- function(copyright_holder) {
  data <- list(
    year = year(),
    copyright_holder = copyright_holder
  )

  if (is_package()) {
    use_description_field("License", "file LICENSE", overwrite = TRUE)
  }
  use_template("license-proprietary.txt", save_as = "LICENSE", data = data)
}

# Fallbacks ---------------------------------------------------------------

#' @rdname licenses
#' @export
#' @usage NULL
use_gpl3_license <- function() {
  use_gpl_license(3)
}

#' @rdname licenses
#' @export
#' @usage NULL
use_agpl3_license <- function() {
  use_agpl_license(3)
}

#' @rdname licenses
#' @export
#' @usage NULL
use_apl2_license <- function() {
  use_apache_license(2)
}

# Helpers -----------------------------------------------------------------

use_license_template <- function(license, data = list()) {
  license_template <- glue("license-{license}.md")

  use_template(license_template,
    save_as = "LICENSE.md",
    data = data,
    ignore = TRUE
  )
}

check_license_version <- function(version, possible) {
  version <- as.double(version)

  if (!version %in% possible) {
    possible <- glue_collapse(possible, sep = ", ", last = ", or ")
    ui_stop("`version` must be {possible}")
  }

  version
}

license_abbr <- function(name, version, include_future) {
  if (include_future) {
    glue_chr("{name} (>= {version})")
  } else {
    if (name %in% c("GPL", "LGPL", "AGPL")) {
      # Standard abbreviations listed at
      # https://cran.rstudio.com/doc/manuals/r-devel/R-exts.html#Licensing
      glue_chr("{name}-{version}")
    } else {
      glue_chr("{name} (== {version})")
    }
  }
}
