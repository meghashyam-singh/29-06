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