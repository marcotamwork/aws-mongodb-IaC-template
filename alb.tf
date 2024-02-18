resource "aws_lb" "alb" {
  name               = "${var.env}-${var.cluster_name}-alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [module.lb_security_group.security_group_id]
  subnets            = module.vpc.private_subnets

  #enable_deletion_protection = true
  enable_deletion_protection = false
  access_logs {
    bucket  = aws_s3_bucket.s3_alb.id
    prefix  = aws_s3_bucket.s3_alb.id
    enabled = true
  }

}
resource "aws_lb_listener" "http_listener_80" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}
resource "aws_lb_listener" "http_listener_443" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/html"
      status_code  = 200
      message_body = "Load balancer recevied your request"
    }

  }
}

resource "aws_lb_target_group" "target_groups" {

  for_each = toset(["30300", "30400"]) //port
  name     = "${var.env}-${var.cluster_name}-port-${each.value}"
  port     = each.value
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id
  health_check {
    port                = each.value
    protocol            = "HTTP"
    interval            = 30
    unhealthy_threshold = 3
    healthy_threshold   = 3
    path                = each.value == "30300" ? "/api/health" : each.value == "30400" ? "/index.html" : "/"
  }

}



resource "aws_lb_target_group_attachment" "attachment" {
  for_each = {
    for pair in setproduct(keys(aws_lb_target_group.target_groups), data.aws_instances.nodes.ids) :
    "${pair[0]}:${pair[1]}" => {
      target_group = aws_lb_target_group.target_groups[pair[0]]
      instance_id  = pair[1]
    }
  }
  target_group_arn = each.value.target_group.arn
  target_id        = each.value.instance_id
  port             = each.value.target_group.port #30000 to 32768
}




resource "aws_lb_listener_rule" "lb_listener_rule" {

  listener_arn = aws_lb_listener.http_listener_443.arn
    for_each = {
    for pair in setproduct(keys(aws_lb_target_group.target_groups), data.aws_instances.nodes.ids) :
    "${pair[0]}:${pair[1]}" => {
      target_group = aws_lb_target_group.target_groups[pair[0]]
      instance_id  = pair[1]
    }
  }
  action {
    type             = "forward"
    target_group_arn = each.value.target_group.arn
    #target_group_arn = aws_lb_target_group.target_groups.arn #port 30200
  }
  condition {
    host_header {
      #values = [trim("${aws_apigatewayv2_api.graphql_api.api_endpoint}", "https://")]
      values = var.prj_domain
    }
  }
}
