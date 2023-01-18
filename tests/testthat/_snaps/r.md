# compute_name() errors if no RStudio

    Code
      compute_name()
    Condition
      Error:
      ! `name` is absent but must be specified.

# compute_name() validates its inputs

    Code
      compute_name("foo.c")
    Condition
      Error:
      ! `name` must have extension "R", not "c".
    Code
      compute_name("R/foo.c")
    Condition
      Error:
      ! `name` must be a file name without directory.
    Code
      compute_name(c("a", "b"))
    Condition
      Error:
      ! `name` must be a single string
    Code
      compute_name("")
    Condition
      Error:
      ! `name` must not be an empty string
    Code
      compute_name("****")
    Condition
      Error:
      ! `name` ("****") must be a valid file name.
      i A valid file name consists of only ASCII letters, numbers, '-', and '_'.

# compute_active_name() errors if no files open

    Code
      compute_active_name(NULL)
    Condition
      Error:
      ! No file is open in RStudio.
      i Please specify `name`.

# compute_active_name() checks directory

    Code
      compute_active_name("foo/bar.R")
    Condition
      Error:
      ! Open file must be a code or test file.

