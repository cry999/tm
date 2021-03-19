# -----
#  VPC
# -----
resource "aws_vpc" "main" {
  enable_dns_support   = true
  enable_dns_hostnames = true
  cidr_block           = local.vpc_cidr

  tags = merge(var.common_tags, {
    "Name" = "${local.prefix_slash}/vpc"
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags, {
    "Name" = "${local.prefix_slash}/igw"
  })
}

# ---------
#  Subnets
# ---------
resource "aws_subnet" "pub1" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = data.aws_availability_zones.az.names[0]
  cidr_block              = local.public_subnet1_cidr
  map_public_ip_on_launch = false

  tags = merge(var.common_tags, {
    "Name" = "${local.prefix_slash}/pub-az1"
  })
}

resource "aws_subnet" "pub2" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = data.aws_availability_zones.az.names[1]
  cidr_block              = local.public_subnet2_cidr
  map_public_ip_on_launch = false


  tags = merge(var.common_tags, {
    "Name" = "${local.prefix_slash}/pub-az2"
  })
}

resource "aws_subnet" "prv1" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = data.aws_availability_zones.az.names[0]
  cidr_block              = local.private_subnet1_cidr
  map_public_ip_on_launch = false

  tags = merge(var.common_tags, {
    "Name" = "${local.prefix_slash}/prv-az1"
  })
}

resource "aws_subnet" "prv2" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = data.aws_availability_zones.az.names[1]
  cidr_block              = local.private_subnet2_cidr
  map_public_ip_on_launch = false

  tags = merge(var.common_tags, {
    "Name" = "${local.prefix_slash}/prv-az2"
  })
}

# ---------
#  Routing
# ---------
resource "aws_route_table" "pub" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags, {
    "Name" = "${local.prefix_slash}/pub-rt"
  })
}

resource "aws_route_table" "prv1" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags, {
    "Name" = "${local.prefix_slash}/prv-1-rt"
  })
}

resource "aws_route_table" "prv2" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags, {
    "Name" = "${local.prefix_slash}/prv-2-rt"
  })
}

resource "aws_route" "pub_all" {
  route_table_id         = aws_route_table.pub.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "pub_1_all" {
  route_table_id = aws_route_table.pub.id
  subnet_id      = aws_subnet.pub1.id
}

resource "aws_route_table_association" "pub_2_all" {
  route_table_id = aws_route_table.pub.id
  subnet_id      = aws_subnet.pub2.id
}

resource "aws_route_table_association" "prv_1_def" {
  route_table_id = aws_route_table.prv1.id
  subnet_id      = aws_subnet.prv1.id
}

resource "aws_route_table_association" "prv_2_def" {
  route_table_id = aws_route_table.prv2.id
  subnet_id      = aws_subnet.prv2.id
}

# ----------------
#  Security Group
# ----------------
resource "aws_security_group" "prv" {
  name        = "${local.prefix_hyphen}-prv-sg"
  vpc_id      = aws_vpc.main.id
  description = "Traffic from bastion"

  tags = merge(var.common_tags, {
    "Name" = "${local.prefix_slash}/prv-sg"
  })
}

resource "aws_security_group_rule" "prv_ssh" {
  type              = "ingress"
  security_group_id = aws_security_group.prv.id

  protocol    = "tcp"
  from_port   = 22
  to_port     = 22
  cidr_blocks = [aws_vpc.main.cidr_block]
}

resource "aws_security_group_rule" "prv_from_vpc" {
  type              = "ingress"
  security_group_id = aws_security_group.prv.id

  protocol    = "-1"
  from_port   = 0
  to_port     = 0
  cidr_blocks = [aws_vpc.main.cidr_block]
}

resource "aws_security_group_rule" "prv_from_alb" {
  type              = "ingress"
  security_group_id = aws_security_group.prv.id

  protocol                 = "-1"
  from_port                = 0
  to_port                  = 0
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group" "pub" {
  name        = "${local.prefix_hyphen}-pub-sg"
  vpc_id      = aws_vpc.main.id
  description = "Traffic from bastion"

  tags = merge(var.common_tags, {
    "Name" = "${local.prefix_slash}/pub-sg"
  })
}

resource "aws_security_group_rule" "pub_ssh" {
  type              = "ingress"
  security_group_id = aws_security_group.pub.id

  protocol    = "tcp"
  from_port   = 22
  to_port     = 22
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "pub_from_vpc" {
  type              = "ingress"
  security_group_id = aws_security_group.pub.id

  protocol    = "-1"
  from_port   = 0
  to_port     = 0
  cidr_blocks = [aws_vpc.main.cidr_block]
}

resource "aws_security_group" "db" {
  name        = "${local.prefix_hyphen}-db-sg"
  vpc_id      = aws_vpc.main.id
  description = "Traffic from private subnet to RDS"

  tags = merge(var.common_tags, {
    "Name" = "${local.prefix_slash}/db-sg"
  })
}

resource "aws_security_group_rule" "db_from_prv" {
  type              = "ingress"
  security_group_id = aws_security_group.db.id

  protocol                 = "tcp"
  from_port                = 3306
  to_port                  = 3306
  source_security_group_id = aws_security_group.prv.id
}

resource "aws_security_group" "ecs_task" {
  name   = "${local.prefix_hyphen}-ECSTaskSG"
  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags, {
    "Name" = "${local.prefix_slash}/ecs-task-sg"
  })
}

resource "aws_security_group_rule" "ecs_task_https_all" {
  type              = "egress"
  security_group_id = aws_security_group.ecs_task.id

  protocol    = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_blocks = [aws_vpc.main.cidr_block]
}

resource "aws_security_group_rule" "ecs_task_https_s3" {
  type              = "egress"
  security_group_id = aws_security_group.ecs_task.id

  protocol        = "tcp"
  from_port       = 443
  to_port         = 443
  prefix_list_ids = [aws_vpc_endpoint.s3.prefix_list_id]
}

# --------------
#  VPC Endpoint
# --------------
locals {
  subnet_ids = [
    aws_subnet.prv1.id,
    aws_subnet.prv2.id,
  ]

  subnet_route_table_ids = [
    aws_route_table.prv1.id,
    aws_route_table.prv2.id,
  ]

  service_name_prefix = "com.amazonaws.${var.region}"
}

resource "aws_security_group" "vpc_endpoint" {
  name        = "${local.prefix_hyphen}-vpc-endpoint-sg"
  description = "Traffic into VPC Endpoint"
  vpc_id      = aws_vpc.main.id

  tags = merge(var.common_tags, {
    "Name" = "${local.prefix_slash}/vpc-endpoint-sg"
  })
}

resource "aws_security_group_rule" "vpc_endpoint_https" {
  type              = "ingress"
  security_group_id = aws_security_group.vpc_endpoint.id

  protocol    = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.main.id
  service_name        = "${local.service_name_prefix}.ssm"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = local.subnet_ids
  security_group_ids  = [aws_security_group.vpc_endpoint.id]

  tags = merge(var.common_tags, {
    "Name" = "${local.prefix_slash}/ssm-vpc-endpoint"
  })
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = aws_vpc.main.id
  service_name        = "${local.service_name_prefix}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = local.subnet_ids
  security_group_ids  = [aws_security_group.vpc_endpoint.id]

  tags = merge(var.common_tags, {
    "Name" = "${local.prefix_slash}/secretsmanager"
  })
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.main.id
  service_name        = "${local.service_name_prefix}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = local.subnet_ids
  security_group_ids  = [aws_security_group.vpc_endpoint.id]

  tags = merge(var.common_tags, {
    "Name" = "${local.prefix_slash}/ecr-api-vpc-endpoint"
  })
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.main.id
  service_name        = "${local.service_name_prefix}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = local.subnet_ids
  security_group_ids  = [aws_security_group.vpc_endpoint.id]

  tags = merge(var.common_tags, {
    "Name" = "${local.prefix_slash}/ecr-dkr-vpc-endpoint"
  })
}

resource "aws_vpc_endpoint" "monitoring" {
  vpc_id              = aws_vpc.main.id
  service_name        = "${local.service_name_prefix}.monitoring"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = local.subnet_ids
  security_group_ids  = [aws_security_group.vpc_endpoint.id]

  tags = merge(var.common_tags, {
    "Name" = "${local.prefix_slash}/monitoring-vpc-endpoint"
  })
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "${local.service_name_prefix}.logs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = local.subnet_ids
  security_group_ids  = [aws_security_group.vpc_endpoint.id]

  tags = merge(var.common_tags, {
    "Name" = "${local.prefix_slash}/logs-vpc-endpoint"
  })
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "${local.service_name_prefix}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = local.subnet_route_table_ids
  policy            = data.aws_iam_policy_document.s3_vpc_endpoint.json

  tags = merge(var.common_tags, {
    "Name" = "${local.prefix_slash}/s3-vpc-endpoint"
  })
}

# ---------------------------
#  Application Load Balancer
# ---------------------------
locals {
  launch_subnets = [
    aws_subnet.prv1.id,
    aws_subnet.prv2.id,
  ]
}

resource "aws_security_group" "alb" {
  name   = "${local.prefix_hyphen}-alb-sg"
  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags, {
    "Name" = "${local.prefix_slash}/alb-sg"
  })
}

resource "aws_security_group_rule" "alb_http" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id

  protocol    = "tcp"
  from_port   = 80
  to_port     = 80
  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_to_ecs" {
  type              = "egress"
  security_group_id = aws_security_group.alb.id

  protocol                 = "tcp"
  from_port                = 80
  to_port                  = 80
  source_security_group_id = aws_security_group.ecs_task.id
}

resource "aws_lb_target_group" "server" {
  name        = "${local.prefix_hyphen}-server-tg"
  vpc_id      = aws_vpc.main.id
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"

  health_check {
    matcher           = "200-299"
    interval          = 10
    path              = "/"
    protocol          = "HTTP"
    timeout           = 5
    healthy_threshold = 2
  }

  tags = merge(var.common_tags, {
    "Name" = "${local.prefix_slash}/server-tg"
  })
}

resource "aws_lb" "alb" {
  name            = "${local.prefix_hyphen}-alb"
  subnets         = local.launch_subnets
  security_groups = [aws_security_group.alb.id]

  tags = merge(var.common_tags, {
    "Name" = "${local.prefix_slash}/alb"
  })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.server.arn
  }

  depends_on = [aws_lb_target_group.server]
}

resource "aws_lb_listener_rule" "http" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 1

  condition {
    path_pattern {
      values = ["/"]
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.server.arn
  }
}
