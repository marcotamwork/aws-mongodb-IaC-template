# Create a Project
resource "mongodbatlas_project" "atlas-project" {
  org_id = var.mongodbatlas_org_id
  name = var.mongodbatlas_project_name
}

# Create a Database User
resource "mongodbatlas_database_user" "db-user" {
  username = var.mongodbatlas_db_username
  password = var.mongodbatlas_db_password
  project_id = mongodbatlas_project.atlas-project.id
  auth_database_name = "admin"
  roles {
    role_name     = "readWrite"
    database_name = var.mongodbatlas_db_name
  }
}

# Create Database IP Access List
resource "mongodbatlas_project_ip_access_list" "ip" {
  project_id = mongodbatlas_project.atlas-project.id
  ip_address = var.mongodbatlas_ip_address
}

# Create an Atlas Cluster
#resource "mongodbatlas_cluster" "atlas-cluster" {
# project_id = mongodbatlas_project.atlas-project.id
# name = "${var.mongodbatlas_project_name}-${var.mongodbatlas_environment}-cluster"
# cluster_type = "REPLICASET"
# disk_size_gb = 5
# //Provider Settings "block"
# provider_name = var.mongodbatlas_cloud_provider
# provider_region_name = var.mongodbatlas_region
# provider_instance_size_name = var.mongodbatlas_cluster_instance_size_name
# provider_backup_enabled = true // enable cloud provider snapshots
# provider_disk_iops = 100
# provider_encrypt_ebs_volume = false
# }

# Create an Atlas Advanced Cluster
resource "mongodbatlas_advanced_cluster" "atlas-cluster" {
  project_id = mongodbatlas_project.atlas-project.id
  name = "${var.mongodbatlas_project_name}-${var.mongodbatlas_environment}-cluster"
  cluster_type = "REPLICASET"
  backup_enabled = true
  mongo_db_major_version = var.mongodbatlas_mongodb_version
#  provider_instance_size_name = var.mongodbatlas_cluster_instance_size_name
  replication_specs {
    region_configs {
      electable_specs {
        instance_size = var.mongodbatlas_cluster_instance_size_name
        node_count    = 3
      }
      analytics_specs {
        instance_size = var.mongodbatlas_cluster_instance_size_name
        node_count    = 1
      }
      priority      = 7
      provider_name = var.mongodbatlas_cloud_provider
      region_name   = var.mongodbatlas_region
    }
  }
}

# Outputs to Display
output "atlas_cluster_connection_string" { value = mongodbatlas_advanced_cluster.atlas-cluster.connection_strings.0.standard_srv }
#output "atlas_cluster_connection_string" { value = mongodbatlas_cluster.atlas-cluster.connection_strings.0.standard_srv }
output "ip_access_list"    { value = mongodbatlas_project_ip_access_list.ip.ip_address }
output "project_name"      { value = mongodbatlas_project.atlas-project.name }
output "username"          { value = mongodbatlas_database_user.db-user.username }
output "user_password"     {
  sensitive = true
  value = mongodbatlas_database_user.db-user.password
}

#output "privatelink_connection_string" {
#  value = lookup(mongodbatlas_advanced_cluster.atlas-cluster.connection_strings[0].aws_private_link_srv, aws_vpc_endpoint.ptfe_service.id)
#}