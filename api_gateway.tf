#module "apigateway-v2" {
#  source  = "terraform-aws-modules/apigateway-v2/aws"
#  version = "2.2.2"
#
#  name = "${random_pet.this.id}-http-vpc-links"
#  description   = "HTTP API Gateway with VPC links"
#  protocol_type = "HTTP"
#
#  cors_configuration = {
#    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
#    allow_methods = ["*"]
#    allow_origins = ["*"]
#  }
#}