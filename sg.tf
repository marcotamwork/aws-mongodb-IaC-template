module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = var.sg_name
  description = "security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 27017
      to_port     = 27017
      protocol    = "tcp"
      description = "MongoDB access from within VPC"
      cidr_blocks = module.vpc.vpc_cidr_block
    }
  ]


  # egress
  egress_cidr_blocks = ["0.0.0.0/0"]

  tags = {
    Environment = var.env
    Terraform   = "true"
  }
}

module "lb_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = var.lb_sg_name
  description = "ALB security group"
  vpc_id      = module.vpc.vpc_id

  # ingress
  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]


  # egress
  egress_cidr_blocks = ["0.0.0.0/0"]

  tags = {
    Environment = var.env
    Terraform   = "true"
  }
}
