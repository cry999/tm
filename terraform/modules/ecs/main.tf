resource "aws_iam_role" "service_role" {
  name               = "${local.prefix_hyphen}-ECSServiceRole"
  assume_role_policy = data.aws_iam_policy_document.assume_service_role.json

  tags = merge(var.common_tags, {
    "Name" = "${local.prefix_slash}/ECSServiceRole"
  })
}

resource "aws_iam_role_policy" "service_role" {
  name   = "${local.prefix_hyphen}-ECSServiceRolePolicy"
  role   = aws_iam_role.service_role.id
  policy = data.aws_iam_policy_document.service_role.json
}

resource "aws_iam_role" "task_execution_role" {
  name               = "${local.prefix_hyphen}-ECSTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.assume_task_execution_role.json

  tags = merge(var.common_tags, {
    "Name" = "${local.prefix_slash}/ECSTaskExecutionRole"
  })
}

resource "aws_iam_role_policy" "ecs_instance_policy" {
  name   = "ECSInstancePolicy"
  role   = aws_iam_role.task_execution_role.id
  policy = data.aws_iam_policy_document.ecs_instance_policy.json
}

# -----
#  ECR 
# -----
resource "aws_ecr_repository" "nginx" {
  name = "${join("/", var.prefixes)}/nginx"

  tags = merge(var.common_tags, {
    "Name" = "${local.prefix_slash}/nginx"
  })
}

resource "aws_ecr_repository" "django" {
  name = "${join("/", var.prefixes)}/django"

  tags = merge(var.common_tags, {
    "Name" = "${local.prefix_slash}/django"
  })
}

# -----------
#  Log Group
# -----------
resource "aws_cloudwatch_log_group" "ecs" {
  name = "/ecs/services${local.prefix_slash}"

  tags = merge(var.common_tags, {
    "Name" = "${local.prefix_slash}/ecs-logs"
  })
}

# ---------
#  Cluster
# ---------
resource "aws_ecs_task_definition" "server" {
  family                   = "${local.prefix_hyphen}-server"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.task_execution_role.arn
  cpu                      = "256"
  memory                   = "512"
  container_definitions = templatefile("${var.template_dir}/container_definitions.json", {
    "imageUrl"     = "${local.account_id}.dkr.ecr.${var.region}.amazonaws.com/${join("/", var.prefixes)}"
    "version"      = "0.0.0"
    "region"       = var.region
    "prefix"       = local.prefix_slash
    "mysql_host"   = var.mysql_host
    "mysql_port"   = var.mysql_port
    "loggroup"     = aws_cloudwatch_log_group.ecs.id
    "streamPrefix" = local.prefix_slash
  })

  tags = merge(var.common_tags, {
    "Name" = "${local.prefix_slash}/ecs-logs"
  })
}

resource "aws_ecs_cluster" "server" {
  name = "${local.prefix_hyphen}-server"

  tags = merge(var.common_tags, {
    "Name" = "${local.prefix_slash}/server-ecs-cluster"
  })
}

resource "aws_ecs_service" "server" {
  name            = "${local.prefix_hyphen}-server"
  cluster         = aws_ecs_cluster.server.id
  desired_count   = 1
  task_definition = aws_ecs_task_definition.server.arn
  launch_type     = "FARGATE"

  load_balancer {
    container_name   = "nginx"
    container_port   = 80
    target_group_arn = var.target_group_arn
  }

  network_configuration {
    subnets          = var.subnets
    security_groups  = [var.service_sg]
    assign_public_ip = true
  }

  tags = merge(var.common_tags, {
    "Name" = "${local.prefix_slash}/server-ecs-service"
  })
}
