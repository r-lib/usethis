# License a package

Adds the necessary infrastructure to declare your package as licensed
with one of these popular open source licenses:

Permissive:

- [MIT](https://choosealicense.com/licenses/mit/): simple and
  permissive.

- [Apache 2.0](https://choosealicense.com/licenses/apache-2.0/): MIT +
  provides patent protection.

Copyleft:

- [GPL v2](https://choosealicense.com/licenses/gpl-2.0/): requires
  sharing of improvements.

- [GPL v3](https://choosealicense.com/licenses/gpl-3.0/): requires
  sharing of improvements.

- [AGPL v3](https://choosealicense.com/licenses/agpl-3.0/): requires
  sharing of improvements.

- [LGPL v2.1](https://choosealicense.com/licenses/lgpl-2.1/): requires
  sharing of improvements.

- [LGPL v3](https://choosealicense.com/licenses/lgpl-3.0/): requires
  sharing of improvements.

Creative commons licenses appropriate for data packages:

- [CC0](https://creativecommons.org/publicdomain/zero/1.0/): dedicated
  to public domain.

- [CC-BY](https://creativecommons.org/licenses/by/4.0/): Free to share
  and adapt, must give appropriate credit.

See <https://choosealicense.com> for more details and other options.

Alternatively, for code that you don't want to share with others,
`use_proprietary_license()` makes it clear that all rights are reserved,
and the code is not open source.

## Usage

``` r
use_mit_license(copyright_holder = NULL)

use_gpl_license(version = 3, include_future = TRUE)

use_agpl_license(version = 3, include_future = TRUE)

use_lgpl_license(version = 3, include_future = TRUE)

use_apache_license(version = 2, include_future = TRUE)

use_cc0_license()

use_ccby_license()

use_proprietary_license(copyright_holder)
```

## Arguments

- copyright_holder:

  Name of the copyright holder or holders. This defaults to
  `"{package name} authors"`; you should only change this if you use a
  CLA to assign copyright to a single entity.

- version:

  License version. This defaults to latest version all licenses.

- include_future:

  If `TRUE`, will license your package under the current and any
  potential future versions of the license. This is generally considered
  to be good practice because it means your package will automatically
  include "bug" fixes in licenses.

## Details

CRAN does not permit you to include copies of standard licenses in your
package, so these functions save the license as `LICENSE.md` and add it
to `.Rbuildignore`.

## See also

For more details, refer to the the [license
chapter](https://r-pkgs.org/license.html) in *R Packages*.
