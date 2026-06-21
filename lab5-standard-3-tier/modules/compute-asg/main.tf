locals {
  name_prefix = "${var.project}-${var.environment}"

  common_tags = merge(
    var.common_tags,
    {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "instance" {
  name               = "${local.name_prefix}-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ec2-role"
  })
}

resource "aws_iam_role_policy_attachment" "ssm_managed" {
  role       = aws_iam_role.instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "this" {
  name = "${local.name_prefix}-ec2-profile"
  role = aws_iam_role.instance.name
}

resource "aws_launch_template" "this" {
  name_prefix   = "${local.name_prefix}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type

  user_data = base64encode(templatefile("${path.module}/user_data.sh.tftpl", {
    app_port    = var.app_port
    environment = var.environment
    project     = var.project
  }))

  update_default_version = true

  monitoring {
    enabled = var.enable_detailed_monitoring
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.this.name
  }

  network_interfaces {
    associate_public_ip_address = var.associate_public_ip_address
    security_groups             = [var.app_sg_id]
  }

  tag_specifications {
    resource_type = "instance"

    tags = merge(local.common_tags, {
      Name = "${local.name_prefix}-app"
      Tier = "app"
    })
  }
}

resource "aws_autoscaling_group" "this" {
  name                      = "${local.name_prefix}-asg"
  desired_capacity          = var.desired_capacity
  min_size                  = var.min_size
  max_size                  = var.max_size
  vpc_zone_identifier       = var.app_subnet_ids
  target_group_arns         = var.target_group_arns
  health_check_type         = "ELB"
  health_check_grace_period = 180

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }

  instance_refresh {
    strategy = "Rolling"

    preferences {
      min_healthy_percentage = 50
    }
  }

  dynamic "tag" {
    for_each = merge(local.common_tags, {
      Name = "${local.name_prefix}-app"
      Tier = "app"
    })

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

resource "aws_autoscaling_policy" "cpu_target" {
  name                   = "${local.name_prefix}-cpu-target"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.this.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 60
  }
}
