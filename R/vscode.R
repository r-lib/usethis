# unexported function we are experimenting with
use_vscode_debug <- function(open = rlang::is_interactive()) {
  usethis::use_directory(".vscode", ignore = TRUE)

  deps <- desc::desc_get_deps(proj_get())
  lt_pkgs <- deps$package[deps$type == "LinkingTo"]
  possibly_path_package <- purrr::possibly(path_package, otherwise = NA)
  lt_paths <- map_chr(lt_pkgs, ~ possibly_path_package(.x, "include"))
  lt_paths <- purrr::discard(lt_paths, is.na)
  # this is a bit fiddly, but it produces the desired JSON when lt_paths has
  # length 0 or > 0
  # I should probably come back and use jsonlite here instead of use_template()
  lt_paths <- encodeString(lt_paths, quote = '"')
  lt_paths <- glue("        {lt_paths},")
  lt_paths <- glue_collapse(lt_paths, sep = "\n")
  if (length(lt_paths) > 0) {
    lt_paths <- paste0("\n", lt_paths)
  }

  use_template(
    "vscode-c_cpp_properties.json",
    save_as = path(".vscode", "c_cpp_properties.json"),
    data = list(linking_to_includes = lt_paths),
    ignore = FALSE, # the .vscode directory is already ignored
    open = open
  )
  use_template(
    "vscode-launch.json",
    save_as = path(".vscode", "launch.json"),
    ignore = FALSE, # the .vscode directory is already ignored
    open = open
  )

  usethis::use_directory("debug", ignore = TRUE)
  use_template(
    "vscode-debug.R",
    save_as = path("debug", "debug.R"),
    ignore = FALSE, # the debug directory is already ignored
    open = open
  )

  invisible(TRUE)
}
