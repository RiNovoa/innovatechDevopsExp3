output "backend_private_ip" {
  description = "IP Privada del Backend"
  value       = aws_instance.backend.private_ip
}

output "ec2_database_ip" {
  description = "La IP publica de la instancia EC2 que aloja MariaDB"
  value       = aws_instance.backend.public_ip
}

output "instruccion_frontend" {
  description = "Donde ver el frontend"
  value       = "Ve a AWS -> ECS -> Clusters -> app -> Tasks -> Entra a la tarea corriendo y copia la Public IP"
}