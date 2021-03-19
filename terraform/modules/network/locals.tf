locals {
  vpc_cidr = "${var.vpc_cidr_first_2_block}.0.0/16"

  public_subnet1_cidr  = "${var.vpc_cidr_first_2_block}.10.0/24"
  public_subnet2_cidr  = "${var.vpc_cidr_first_2_block}.11.0/24"
  private_subnet1_cidr = "${var.vpc_cidr_first_2_block}.20.0/24"
  private_subnet2_cidr = "${var.vpc_cidr_first_2_block}.21.0/24"

  prefix_slash  = "/${join("/", var.prefixes)}"
  prefix_hyphen = join("-", var.prefixes)
}
