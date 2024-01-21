resource "aws_ecr_repository" "pyeditoral" {
  name = "pyeditoral"
}

resource "aws_ecr_repository" "nginx" {
  name = "nginx"
}

resource "aws_security_group" "ecs_fargate" {
  name        = "ecs_fargate_security_group"
  description = "Allows inbound access from the ALB only"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.load_balancer.id]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_cluster" "this" {
  name = local.ecs_cluster_name
}

data "template_file" "app" {
  template = file("templates/app.json.tpl")

  vars = {
    docker_image_url_pyeditoral = "572384340159.dkr.ecr.eu-west-1.amazonaws.com/pyeditoral"
    docker_image_url_nginx      = "572384340159.dkr.ecr.eu-west-1.amazonaws.com/nginx"
    region                      = "eu-west-1"
    rds_db_name                 = "PyEditoral"
    rds_username                = "root"
    rds_password                = data.aws_ssm_parameter.db_root_password.value
    rds_hostname                = "pyeditoraldb.cloud34742.site"
    allowed_hosts               = "*" //var.allowed_hosts
    secret_key                  = data.aws_ssm_parameter.app_secret_key.value
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "pyeditoral-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  container_definitions    = data.template_file.app.rendered
  volume {
    name = "efs-volume"
    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.efs.id
      root_directory     = "/efs"
      transit_encryption = "DISABLED"
    }
  }
}

resource "aws_ecs_service" "this" {
  name            = local.ecs_cluster_name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.app.arn
  launch_type     = "FARGATE"
  desired_count   = 1
  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.ecs_fargate.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.default_target_group.arn
    container_name   = "nginx"
    container_port   = 80
  }
}


resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "ecs_task_execution_role"
  assume_role_policy = file("policies/ecs-role.json")
}

resource "aws_iam_role_policy" "ecs_task_execution_role_policy" {
  name   = "ecs_task_execution_role_policy"
  policy = file("policies/ecs-task-execution-policy.json")
  role   = aws_iam_role.ecs_task_execution_role.id
}

resource "aws_iam_role" "ecs_service_role" {
  name               = "ecs_service_role"
  assume_role_policy = file("policies/ecs-role.json")
}

resource "aws_iam_role_policy" "ecs_service_role_policy" {
  name   = "ecs_service_role_policy"
  policy = file("policies/ecs-service-role-policy.json")
  role   = aws_iam_role.ecs_service_role.id
}
