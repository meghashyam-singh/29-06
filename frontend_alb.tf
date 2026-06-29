resource "aws_lb" "frontend" {
    load_balancer_type = "application"
    name = "${local.common_name}_frontend_alb"
    internal = true
    security_groups = [ data.aws_ssm_parameter.frontend_alb_sg_id.value ]
    subnets = split(",", data.aws_ssm_parameter.public_subnet_ids.value)
}