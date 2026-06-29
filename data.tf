data "aws_ssm_parameter" "vpc_id" {
    name = "${local.common_name}_vpc_id"
}

data "aws_ssm_parameter" "catalogue_sg_id" {
    name = "${local.common_name}_catalogue_sg_id"
}

data "aws_ssm_parameter" "user_sg_id" {
    name = "${local.common_name}_user_sg_id"
}

data "aws_ssm_parameter" "cart_sg_id" {
    name = "${local.common_name}_cart_sg_id"
}

data "aws_ssm_parameter" "shipping_sg_id" {
    name = "${local.common_name}_shipping_sg_id"
}

data "aws_ssm_parameter" "payment_sg_id" {
    name = "${local.common_name}_payment_sg_id"
}

data "aws_ssm_parameter" "frontend_sg_id" {
    name = "${local.common_name}_frontend_sg_id"
}

data "aws_ssm_parameter" "bastion_sg_id" {
    name = "${local.common_name}_bastion_sg_id"
}

data "aws_ssm_parameter" "backend_alb_sg_id" {
    name = "${local.common_name}_backend_alb_sg_id"
}

data "aws_ssm_parameter" "frontend_alb_sg_id" {
    name = "${local.common_name}_frontend_alb_sg_id"
}

data "aws_ami" "ami_id" {
    owners = ["973714476881"]
    most_recent = true

    filter {
        name = "architecture"
        values = ["x86_64"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }

    filter {
        name = "root-device-name"
        values = ["/dev/sda1"]
    }
}

data "aws_ssm_parameter" "private_subnet_ids" {
    name = "${local.common_name}_private_subnet_ids"
}

data "aws_ssm_parameter" "public_subnet_ids" {
    name = "${local.common_name}_public_subnet_ids"
}