# use_version() errors for invalid `which`

    Code
      use_version("1.2.3")
    Condition
      Error in `choose_version()`:
      ! `which` must be one of "major", "minor", "patch", or "dev", not "1.2.3".

# use_version() increments version in DESCRIPTION, edits NEWS

    Code
      writeLines(read_utf8(proj_path("NEWS.md")))
    Output
      # {TESTPKG} 2.0.0
      
      * Added a `NEWS.md` file to track changes to the package.

# use_version() updates (development version) directly

    Code
      writeLines(read_utf8(proj_path("NEWS.md")))
    Output
      # {TESTPKG} 0.0.2
      
      # {TESTPKG} 0.0.1
      
      * Added a `NEWS.md` file to track changes to the package.

# use_version() updates version.c

    Code
      writeLines(lines)
    Output
      foo;
      const char {TESTPKG}_version = "1.0.0.9000";
      bar;

