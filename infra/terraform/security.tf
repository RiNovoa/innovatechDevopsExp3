resource "aws_security_group" "eks_cluster_sg" {
  name        = "${local.project_name}-eks-sg"
  description = "Security Group principal para EKS"
  vpc_id      = aws_vpc.eks_vpc.id

  ingress {
    description = "HTTPS Kubernetes API"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Salida general"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${local.project_name}-eks-sg"
  }
}
