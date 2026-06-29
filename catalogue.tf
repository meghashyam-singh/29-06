resource "aws_instance" "catalogue" {
    ami = data.aws_ami.ami_id.id
    instance_type = var.environment == "dev" ? "t3.micro" : "t3.medium"
    subnet_id = split(",", data.aws_ssm_parameter.private_subnet_ids.value)[0]
    vpc_security_group_ids = [ data.aws_ssm_parameter.catalogue_sg_id.value ]
    tags = {
        Name = "${local.common_name}_catalogue"
    }
}