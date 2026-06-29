resource "aws_instance" "catalogue" {
    ami = data.aws_ami.ami_id.id
    instance_type = var.environment == "dev" ? "t3.micro" : "t3.medium"
    subnet_id = split(",", data.aws_ssm_parameter.private_subnet_ids.value)[0]
    vpc_security_group_ids = [ data.aws_ssm_parameter.catalogue_sg_id.value ]
    tags = {
        Name = "${local.common_name}_catalogue"
    }
}

resource "terraform_data" "catalogue" {
    triggers_replace = {
        instance_id = aws_instance.catalogue.id
    }

    connection {
        type = "ssh"
        user = "ec2-user"
        password = "DevOps321"
        host = aws_instance.catalogue.private_ip
    }

    provisioner "file" {
        source = "bootstrap.sh"
        destination = "/home/ec2-user/bootstrap.sh"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo chmod +x /home/ec2-user/bootstrap.sh",
            "sudo /home/ec2-user/bootstrap.sh"
        ]
    }
}

resource "aws_ec2_instance_state" "catalogue" {
    instance_id = aws_instance.catalogue.id
    state = "stopped"
    depends_on = [ terraform_data.catalogue ]
}

resource "aws_ami_from_instance" "catalogue" {
    source_instance_id = aws_instance.catalogue.id
    name = "${local.common_name}_catalogue_ami"
    depends_on = [ aws_ec2_instance_state.catalogue ]
}

resource "aws_lb_target_group" "catalogue" {
    name = "roboshop-dev-catalogue"
    port = 8080
    protocol = "HTTP"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    target_type = "instance"
    health_check {
        path                = "/health"
        port                = 8080
        protocol            = "HTTP"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 5
        interval            = 10
        matcher             = "200-299"
    }
}

resource "aws_launch_template" "catalogue" {
  name = "catalogue-launch-template"
  image_id = aws_ami_from_instance.catalogue.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [ data.aws_ssm_parameter.catalogue_sg_id.value ]
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "catalogue-launch-template"
    }
  }
}

resource "aws_autoscaling_group" "catalogue" {
  name                      = "catalogue-asg"
  max_size                  = 5
  min_size                  = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  desired_capacity          = 4
  target_group_arns = [ aws_lb_target_group.catalogue.arn ]
  launch_template {
    id = aws_launch_template.catalogue.id
    version = "$latest"
  }
  vpc_zone_identifier       = split(",", data.aws_ssm_parameter.private_subnet_ids.value)

  tag {
    key                 = "Name"
    value               = "catalogue-asg"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "catalogue" {
  name                   = "catalogue-asg-policy"
  policy_type = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.catalogue.name
  target_tracking_configuration {
  predefined_metric_specification {
    predefined_metric_type = "ASGAverageCPUUtilization"
  }

  target_value = 75
  }
}

resource "terraform_data" "delete_catalogue_instance" {
    triggers_replace = {
        instance_id = aws_instance.catalogue.id
    }

    provisioner "local-exec" {
        command = "aws ec2 terminate-instances --instance-ids ${aws_instance.catalogue.id}"
    }

    depends_on = [aws_ami_from_instance.catalogue]
}