locals {
  prefix_slash  = "/${join("/", var.prefixes)}"
  prefix_hyphen = join("-", var.prefixes)
}
