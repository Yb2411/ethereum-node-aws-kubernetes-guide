provider "aws" {
  profile = "anais"
  region  = "eu-west-3"
}

provider "kubernetes" {
  host                   = aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.eks.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.eks.token

  config_context_cluster   = "aws"
  config_context_auth_info = "aws"
  config_context           = "aws"
}
