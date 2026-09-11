# Use C++ via the cpp11 package

Adds infrastructure needed to use the [cpp11](https://cpp11.r-lib.org)
package, a header-only R package that helps R package developers handle
R objects with C++ code:

- Creates `src/`

- Adds cpp11 to `DESCRIPTION`

- Creates `src/code.cpp`, an initial placeholder `.cpp` file

## Usage

``` r
use_cpp11()
```
