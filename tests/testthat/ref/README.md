ZIP file structures
================

``` r
devtools::load_all("~/rrr/usethis")
#> ℹ Loading usethis
#> x unloadNamespace("usethis") failed because another loaded package needs it
#> ℹ Forcing unload. If you encounter problems, please restart R.
library(fs)
```

## Different styles of ZIP file

Examples based on foo folder found here.

``` bash
tree foo
#> [01;34mfoo[00m
#> └── file.txt
#> 
#> 0 directories, 1 file
```

### Not Loose Parts, a.k.a. GitHub style

This is the structure of ZIP files yielded by GitHub via links of the
forms <https://github.com/r-lib/usethis/archive/master.zip> and
<http://github.com/r-lib/usethis/zipball/master/>.

``` bash
zip -r foo-not-loose.zip foo/
```

Notice that everything is packaged below one top-level directory.

``` r
foo_not_loose_files <- unzip("foo-not-loose.zip", list = TRUE)
with(
  foo_not_loose_files,
  data.frame(Name = Name, dirname = path_dir(Name), basename = path_file(Name))
)
#>           Name dirname basename
#> 1         foo/       .      foo
#> 2 foo/file.txt     foo file.txt
```

### Loose Parts, the Regular Way

This is the structure of many ZIP files I’ve seen, just in general.

``` bash
cd foo
zip ../foo-loose-regular.zip *
cd ..
```

All the files are packaged in the ZIP archive as “loose parts”,
i.e. there is no explicit top-level directory.

``` r
foo_loose_regular_files <- unzip("foo-loose-regular.zip", list = TRUE)
with(
  foo_loose_regular_files,
  data.frame(Name = Name, dirname = path_dir(Name), basename = path_file(Name))
)
#>       Name dirname basename
#> 1 file.txt       . file.txt
```

### Loose Parts, the DropBox Way

This is the structure of ZIP files yielded by DropBox via links of this
form <https://www.dropbox.com/sh/12345abcde/6789wxyz?dl=1>. I can’t
figure out how to even do this with zip locally, so I had to create an
example on DropBox and download it. Jim Hester reports it is possible
with `archive::archive_write_files()`.

<https://www.dropbox.com/sh/5qfvssimxf2ja58/AABz3zrpf-iPYgvQCgyjCVdKa?dl=1>

It’s basically like the “loose parts” above, except it includes a
spurious top-level directory `"/"`.

``` r
# curl::curl_download(
#   "https://www.dropbox.com/sh/5qfvssimxf2ja58/AABz3zrpf-iPYgvQCgyjCVdKa?dl=1",
#    destfile = "foo-loose-dropbox.zip"
# )
foo_loose_dropbox_files <- unzip("foo-loose-dropbox.zip", list = TRUE)
with(
  foo_loose_dropbox_files,
  data.frame(Name = Name, dirname = path_dir(Name), basename = path_file(Name))
)
#>       Name dirname basename
#> 1        /       /         
#> 2 file.txt       . file.txt
```

Also note that, when unzipping with `unzip` in the shell, you get this
result:

    Archive:  foo-loose-dropbox.zip
    warning:  stripped absolute path spec from /
    mapname:  conversion of  failed
      inflating: file.txt

So this is a pretty odd ZIP packing strategy. But we need to plan for
it.

## Subdirs only at top-level

Let’s make sure we detect loose parts (or not) when the top-level has
only directories, not files.

Example based on the yo directory here:

``` bash
tree yo
#> [01;34myo[00m
#> ├── [01;34msubdir1[00m
#> │   └── file1.txt
#> └── [01;34msubdir2[00m
#>     └── file2.txt
#> 
#> 2 directories, 2 files
```

``` bash
zip -r yo-not-loose.zip yo/
```

``` r
(yo_not_loose_files <- unzip("yo-not-loose.zip", list = TRUE))
#>                   Name Length                Date
#> 1                  yo/      0 2018-01-11 15:48:00
#> 2          yo/subdir1/      0 2018-01-11 15:48:00
#> 3 yo/subdir1/file1.txt     42 2018-01-11 15:48:00
#> 4          yo/subdir2/      0 2018-01-11 15:49:00
#> 5 yo/subdir2/file2.txt     42 2018-01-11 15:49:00
top_directory(yo_not_loose_files$Name)
#> [1] "yo/"
```

``` bash
cd yo
zip -r ../yo-loose-regular.zip *
cd ..
```

``` r
(yo_loose_regular_files <- unzip("yo-loose-regular.zip", list = TRUE))
#>                Name Length                Date
#> 1          subdir1/      0 2018-01-11 15:48:00
#> 2 subdir1/file1.txt     42 2018-01-11 15:48:00
#> 3          subdir2/      0 2018-01-11 15:49:00
#> 4 subdir2/file2.txt     42 2018-01-11 15:49:00
top_directory(yo_loose_regular_files$Name)
#> [1] NA
```

``` r
# curl::curl_download(
#   "https://www.dropbox.com/sh/afydxe6pkpz8v6m/AADHbMZAaW3IQ8zppH9mjNsga?dl=1",
#    destfile = "yo-loose-dropbox.zip"
# )
(yo_loose_dropbox_files <- unzip("yo-loose-dropbox.zip", list = TRUE))
#>                Name Length                Date
#> 1                 /      0 2018-01-11 23:57:00
#> 2 subdir1/file1.txt     42 2018-01-11 23:57:00
#> 3 subdir2/file2.txt     42 2018-01-11 23:57:00
#> 4          subdir1/      0 2018-01-11 23:57:00
#> 5          subdir2/      0 2018-01-11 23:57:00
top_directory(yo_loose_dropbox_files$Name)
#> [1] NA
```
