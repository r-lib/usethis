ZIP file structures
================

Various ways to zip the foo folder found here.

``` bash
tree foo
#> foo
#> └── file.txt
#> 
#> 0 directories, 1 file
```

Not Loose Parts or "GitHub style"
---------------------------------

This is the structure of ZIP files yielded by GitHub via links of the forms <https://github.com/r-lib/usethis/archive/master.zip> and <http://github.com/r-lib/usethis/zipball/master/>.

``` bash
zip -r foo-not-loose.zip foo/
```

``` r
foo_not_loose_files <- unzip("foo-not-loose.zip", list = TRUE)
with(
  foo_not_loose_files,
  data.frame(Name = Name, dirname = dirname(Name), basename = basename(Name))
)
#>           Name dirname basename
#> 1         foo/       .      foo
#> 2 foo/file.txt     foo file.txt
```

Loose Parts, the Regular Way
----------------------------

This is the structure of many ZIP files I've seen, just in general.

``` r
cd foo
zip ../foo-loose-regular.zip *
cd ..
```

``` r
foo_loose_regular_files <- unzip("foo-loose-regular.zip", list = TRUE)
with(
  foo_loose_regular_files,
  data.frame(Name = Name, dirname = dirname(Name), basename = basename(Name))
)
#>       Name dirname basename
#> 1 file.txt       . file.txt
```

Loose Parts, the DropBox Way
----------------------------

This is the structure of ZIP files yielded by DropBox via links of this form <https://www.dropbox.com/sh/12345abcde/6789wxyz?dl=1>. I can't figure out how to even do this with zip locally, so I had to create an example on DropBox and download it. Jim Hester reports it is possible with `archive::archive_write_files()`.

<https://www.dropbox.com/sh/5qfvssimxf2ja58/AABz3zrpf-iPYgvQCgyjCVdKa?dl=1>

``` r
# curl::curl_download(
#   "https://www.dropbox.com/sh/5qfvssimxf2ja58/AABz3zrpf-iPYgvQCgyjCVdKa?dl=1",
#    destfile = "foo-loose-dropbox.zip"
# )
foo_loose_dropbox_files <- unzip("foo-loose-dropbox.zip", list = TRUE)
with(
  foo_loose_dropbox_files,
  data.frame(Name = Name, dirname = dirname(Name), basename = basename(Name))
)
#>       Name dirname basename
#> 1        /       /         
#> 2 file.txt       . file.txt
```

Also note that, when unzipping with `unzip` you get this result:

    Archive:  foo-loose-dropbox.zip
    warning:  stripped absolute path spec from /
    mapname:  conversion of  failed
      inflating: file.txt

So this is a pretty odd ZIP packing strategy. But we need to plan for it.
