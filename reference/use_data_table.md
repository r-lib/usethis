# Prepare for importing data.table

`use_data_table()` imports the `data.table()` function from the
data.table package, as well as several important symbols: `:=`, `.SD`,
`.BY`, `.N`, `.I`, `.GRP`, `.NGRP`, `.EACHI`. This is a minimal setup
and you can learn much more in the "Importing data.table" vignette:
`https://rdatatable.gitlab.io/data.table/articles/datatable-importing.html`.
In addition to importing these functions, `use_data_table()` also blocks
the usage of data.table in the `Depends` field of the `DESCRIPTION`
file; `data.table` should be used as an *imported* or *suggested*
package only. See this
[discussion](https://github.com/Rdatatable/data.table/issues/3076).

## Usage

``` r
use_data_table()
```
