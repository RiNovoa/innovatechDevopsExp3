resource "aws_ecr_repository" "frontend_repo" {
  name         = "${local.project_name}-frontend"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${local.project_name}-frontend"
  }
}

resource "aws_ecr_repository" "ventas_repo" {
  name         = "${local.project_name}-ventas"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${local.project_name}-ventas"
  }
}

resource "aws_ecr_repository" "despachos_repo" {
  name         = "${local.project_name}-despachos"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "${local.project_name}-despachos"
  }
}
