locals {
  prefix_slash  = "/${join("/", var.prefixes)}"
  prefix_hyphen = join("-", var.prefixes)

  account_id = data.aws_caller_identity.current.account_id
}
