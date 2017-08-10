uses_roxygen <- function(base_path = ".") {
  desc::desc_has_fields("RoxygenNote", base_path)
}
