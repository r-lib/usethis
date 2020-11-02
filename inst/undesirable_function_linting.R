# using my fork / PR
# https://github.com/jennybc/lintr/tree/functions-not-objects
# https://github.com/jimhester/lintr/pull/557

base_file_system_functions <- c(
  "Sys.chmod",
  "Sys.readlink",
  "Sys.setFileTime",
  "Sys.umask",
  "dir",
  "dir.create",
  "dir.exists",
  "file.access",
  "file.append",
  "file.copy",
  "file.create",
  "file.exists",
  "file.info",
  "file.link",
  "file.mode",
  "file.mtime",
  "file.path",
  "file.remove",
  "file.rename",
  "file.size",
  "file.symlink",
  "list.files",
  "list.dirs",
  "normalizePath",
  "path.expand",
  "tempdir",
  "tempfile",
  "unlink",
  "basename",
  "dirname"
)

fs_msg <- "Avoid base file system functions; use fs instead"
my_undesirable_functions <-
  rep_len(fs_msg, length(base_file_system_functions))
names(my_undesirable_functions) <- base_file_system_functions
# TODO: do I want a warning or an error?
my_undesirable_function_linter <-
  lintr::undesirable_function_linter(fun = my_undesirable_functions)

# out <- lintr::lint_package(linters = my_undesirable_function_linter)
# print(out)
# if (length(out)) stop("lints found")

#https://github.com/rich-iannone/pointblank/blob/e132043ba806873aa20c1a0d60a3960c14e81c64/.github/workflows/lint.yaml#L47
#https://github.com/wlandau/learndrake/blob/2fc96a0db20711f429b59a3c15381ba39de08e0a/.github/workflows/lint.yaml
