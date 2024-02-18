module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  create_cluster_security_group = false
  create_node_security_group    = false

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets # Encryption key
  /* create_kms_key = true

  cluster_encryption_config = {
    resources = ["secrets"]
  }
  kms_key_deletion_window_in_days = 7
  enable_kms_key_rotation         = true */

  cluster_addons = {
    coredns = {
      addon_version     = "v1.9.3-eksbuild.3"
      resolve_conflicts = "OVERWRITE"
      timeouts = {
        create = "25m"
        delete = "10m"
      }
    }
    kube-proxy = {
      addon_version     = "v1.27.1-eksbuild.1"
      resolve_conflicts = "OVERWRITE"
    }
    aws-ebs-csi-driver = {
      addon_version            = "v1.19.0-eksbuild.1"
      resolve_conflicts        = "OVERWRITE"
      service_account_role_arn = aws_iam_role.ebs_csi_role.arn
      timeouts = {
        create = "25m"
        delete = "10m"
      }
    }
    vpc-cni = {
      addon_version     = "v1.12.6-eksbuild.2"
      resolve_conflicts = "OVERWRITE"
    }
  }


  eks_managed_node_groups = {
    node_group_1 = {
      min_size                              = 2
      max_size                              = var.eks_max_instance_count
      desired_size                          = var.eks_instance_count
      instance_types                        = [var.eks_instance_type]
      create_security_group                 = false
      attach_cluster_primary_security_group = true
      /* launch_template_id                    = aws_launch_template.eks_node_with_keypair.id
      launch_template_version               = aws_launch_template.eks_node_with_keypair.default_version */
    }
  }

  tags = {
    Environment = var.env
    Terraform   = "true"
  }
}

resource "aws_iam_role" "ebs_csi_role" {
  name = "${var.env}-ebs-csi-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${module.eks.oidc_provider}"
        }
      },
    ]
  })
}

data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
resource "aws_iam_role_policy_attachment" "ebs_csi_policy" {
  policy_arn = data.aws_iam_policy.ebs_csi_policy.arn
  role       = aws_iam_role.ebs_csi_role.id
}
