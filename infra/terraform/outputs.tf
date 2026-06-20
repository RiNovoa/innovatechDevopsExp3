output "cluster_name" {
  value = aws_eks_cluster.eks.name
}

output "cluster_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "frontend_ecr_url" {
  value = aws_ecr_repository.frontend_repo.repository_url
}

output "ventas_ecr_url" {
  value = aws_ecr_repository.ventas_repo.repository_url
}

output "despachos_ecr_url" {
  value = aws_ecr_repository.despachos_repo.repository_url
}

output "connect_kubectl" {
  value = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.eks.name}"
}
