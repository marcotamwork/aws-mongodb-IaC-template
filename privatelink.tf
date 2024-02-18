/*data "mongodbatlas_advanced_cluster" "atlas-cluser" {
  project_id = mongodbatlas_project.atlas-project.id
  name       = mongodbatlas_advanced_cluster.atlas-cluster.name
  depends_on = [mongodbatlas_privatelink_endpoint_service.atlaseplink]
}

output "privatelink_connection_string" {
  value = lookup(mongodbatlas_advanced_cluster.atlas-cluster.connection_strings[0].aws_private_link_srv, aws_vpc_endpoint.ptfe_service.id)
}

resource "mongodbatlas_privatelink_endpoint" "atlaspl" {
  project_id    = mongodbatlas_project.atlas-project.id
  provider_name = "AWS"
  region        = var.region
}

resource "aws_vpc_endpoint" "ptfe_service" {
  vpc_id             = module.vpc.vpc_id
  service_name       = mongodbatlas_privatelink_endpoint.atlaspl.endpoint_service_name
  vpc_endpoint_type  = "Interface"
  subnet_ids         = [aws_subnet.primary-az1.id, aws_subnet.primary-az2.id]
  security_group_ids = [aws_security_group.primary_default.id]
}

resource "mongodbatlas_privatelink_endpoint_service" "atlaseplink" {
  project_id          = mongodbatlas_privatelink_endpoint.atlaspl.project_id
  endpoint_service_id = aws_vpc_endpoint.ptfe_service.id
  private_link_id     = mongodbatlas_privatelink_endpoint.atlaspl.id
  provider_name       = "AWS"
}*/