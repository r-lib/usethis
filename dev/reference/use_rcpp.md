# Use C, C++, RcppArmadillo, or RcppEigen

Adds infrastructure commonly needed when using compiled code:

- Creates `src/`

- Adds required packages to `DESCRIPTION`

- May create an initial placeholder `.c` or `.cpp` file

- Creates `Makevars` and `Makevars.win` files (`use_rcpp_armadillo()`
  only)

## Usage

``` r
use_rcpp(name = NULL)

use_rcpp_armadillo(name = NULL)

use_rcpp_eigen(name = NULL)

use_c(name = NULL)
```

## Arguments

- name:

  Either a string giving a file name (without directory) or `NULL` to
  take the name from the currently open file in RStudio.
