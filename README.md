

# AWS Infrastructure with Terraform & CI/CD - ECS Fargate (ProyectoSemestral3)

## 📝 Descripción

Este proyecto implementa una infraestructura automatizada en Amazon Web Services (AWS) utilizando **Terraform** como herramienta de Infraestructura como Código (IaC). 

La solución despliega una arquitectura robusta basada en contenedores utilizando **Amazon ECS con AWS Fargate**, siguiendo un enfoque práctico de arquitectura serverless y microservicios.

> 💡 **Nota:** Este proyecto centraliza el almacenamiento de imágenes mediante **Amazon ECR** y gestiona la observabilidad a través de **AWS CloudWatch Logs**.

---

## 🧭 Estructura del Proyecto

```text
infra/terraform/
├── main.tf            # Infraestructura principal AWS
├── variables.tf       # Variables globales
├── outputs.tf         # Salidas del sistema
├── terraform.tfvars   # Variables de entorno de Terraform
└── README.md          # Documentación del proyecto

```

---

## 🚀 Requisitos Previos

Antes de ejecutar el proyecto, asegúrate de contar con lo siguiente:

* **Terraform CLI** (versión `>= 1.0`)
* **AWS CLI** configurado localmente
* **Docker Desktop** instalado y en ejecución
* Cuenta de **AWS Academy Learner Lab** activa
* **GitHub Actions** habilitado en el repositorio

### 🔑 Credenciales Temporales de AWS

Asegúrate de exportar tus credenciales en tu terminal antes de interactuar con Terraform:

```bash
export AWS_ACCESS_KEY_ID="tu_access_key"
export AWS_SECRET_ACCESS_KEY="tu_secret_key"
export AWS_SESSION_TOKEN="tu_session_token"

```

---

## ⚙️ Arquitectura Implementada

### 🔹 Red y Conectividad (VPC)

* VPC personalizada.
* Subredes públicas y privadas distribuidas estratégicamente.
* **Internet Gateway** y **NAT Gateway** para la salida controlada a internet.
* Tablas de ruteo configuradas de forma aislada.

### 🔹 Capa de Seguridad (Security Groups)

Se definieron políticas de tráfico restrictivas para los siguientes componentes:

* **Frontend:** Acceso HTTP público (Puerto `80`).
* **Backend Ventas:** Puerto `8080`.
* **Backend Despachos:** Puerto `8081`.
* **Base de datos MariaDB:** Puerto `3306` (restringido a los microservicios).
* **Acceso SSH:** Puerto `22`.

### 🔹 Servicios Desplegados y Orquestación

#### Amazon ECS + Fargate

Orquestación de tres microservicios principales en modalidad Serverless:

| Servicio | Puerto | Tipo | Tecnología Base |
| --- | --- | --- | --- |
| **Frontend** | `80` | Capa Pública / Web | Nginx + Vite + React |
| **Backend Ventas** | `8080` | Capa Privada / API | Spring Boot |
| **Backend Despachos** | `8081` | Capa Privada / API | Spring Boot |

#### Amazon ECR (Elastic Container Registry)

Repositorios privados dedicados para el almacenamiento seguro de las imágenes Docker de cada servicio:

* `innovatech-ep2-frontend`
* `innovatech-ep2-back-ventas`
* `innovatech-ep2-back-despachos`

#### Almacenamiento de Datos (EC2 + MariaDB)

* Instancia **AWS EC2** configurada para ejecutar un servidor **MariaDB 10.5**.
* Centraliza y provee persistencia de datos para ambos microservicios.
* Configuración automatizada en el arranque mediante scripts en `user_data`.

---

## 🔄 Pipeline CI/CD con GitHub Actions

El proyecto automatiza la integración y el despliegue continuo mediante un flujo de trabajo configurado en `.github/workflows/deploy.yml`.

### Flujo Automatizado de Despliegue

Al realizar un `push` a la rama **`deploy`**, el pipeline ejecuta las siguientes acciones de forma secuencial:

1. **Backend Ventas:** Construcción de la imagen Docker y subida al repositorio `innovatech-ep2-back-ventas`.
2. **Backend Despachos:** Construcción de la imagen Docker y subida al repositorio `innovatech-ep2-back-despachos`.
3. **Frontend:** Empaquetado de la aplicación e inyección hacia `innovatech-ep2-frontend`.

---

## 🛠️ Guía de Uso y Despliegue Local

Sigue estos pasos para desplegar la infraestructura en tu cuenta de AWS:

### Paso 1: Clonar el repositorio

```bash
git clone <url-del-repositorio>
cd infra/terraform

```

### Paso 2: Inicializar el entorno de Terraform

Descarga los proveedores necesarios (AWS) y configura el backend:

```bash
terraform init

```

### Paso 3: Validar y Planificar

Revisa el plan de ejecución para verificar qué recursos se crearán:

```bash
terraform plan

```

### Paso 4: Aplicar Cambios

Despliega toda la infraestructura en la nube (esto puede tomar un par de minutos):

```bash
terraform apply -auto-approve

```

---

## 🗄️ Detalles Técnico de Componentes

### Persistencia de Datos

La cadena de conexión compartida que utilizan los microservicios para interactuar con la base de datos es:

```text
jdbc:mysql://<PRIVATE_IP_EC2>:3306/test

```

### 📊 Monitoreo y Observabilidad

Los registros generados por los contenedores de ECS se centralizan en **Amazon CloudWatch Logs**, segmentados en tres grupos diferenciados para facilitar el troubleshooting:

* `/ecs/frontend`
* `/ecs/backend-ventas`
* `/ecs/backend-despachos`

---

## 🌐 Puntos de Acceso a la Aplicación

Una vez desplegada la infraestructura, se puede acceder a los servicios mediante las siguientes URLs:

* **Frontend:** `http://35.173.193.214/`
* **Backend Ventas:** `http://35.173.193.214:8080/`
* **Backend Despachos:** `http://35.173.193.214:8081/`

---

## 📌 Buenas Prácticas Implementadas

* **Infraestructura como Código (IaC):** Modularización completa utilizando Terraform.
* **Arquitectura Serverless:** Uso de AWS Fargate para eliminar la gestión operativa de servidores en los contenedores.
* **Seguridad:** Aislamiento de redes y políticas estrictas con Grupos de Seguridad.
* **Automatización:** Pipeline de CI/CD nativo con GitHub Actions sin intervención manual.
* **Parametrización:** Uso de variables reutilizables mediante archivos `tfvars`.

---

## 🔧 Posibles Mejoras Futuras

* [ ] Incorporar un **Application Load Balancer (ALB)** para distribuir la carga eficientemente.
* [ ] Implementar políticas de **Auto Scaling** basadas en consumo de CPU/Memoria.
* [ ] Migrar la base de datos MariaDB desde EC2 hacia un servicio gestionado como **Amazon RDS**.
* [ ] Cifrar las conexiones utilizando **HTTPS** mediante AWS Certificate Manager (ACM).
* [ ] Configurar nombres de dominio personalizados con **Amazon Route53**.
* [ ] Implementar **AWS ECS Service Discovery** para la comunicación interna entre microservicios.

```

```
