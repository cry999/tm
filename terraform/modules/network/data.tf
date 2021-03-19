data "aws_availability_zones" "az" {
  state = "available"
}

data "aws_iam_policy_document" "s3_vpc_endpoint" {
  statement {
    actions   = ["*"]
    effect    = "Allow"
    resources = ["*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}
