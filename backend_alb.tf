resource "aws_lb" "backend" {
    load_balancer_type = "application"
    name = "roboshop-dev-backend-alb"
    internal = true
    security_groups = [ data.aws_ssm_parameter.backend_alb_sg_id.value ]
    subnets = split(",", data.aws_ssm_parameter.private_subnet_ids.value)
}