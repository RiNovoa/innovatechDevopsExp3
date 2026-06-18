# Innovatech DevOps EP3 - AWS EKS, Terraform y CI/CD

## 📝 Descripción

Este proyecto implementa el despliegue de una aplicación de microservicios en **Amazon Web Services (AWS)** utilizando **Terraform** como herramienta de Infraestructura como Código e **Amazon EKS** como plataforma de orquestación de contenedores.

La solución despliega los siguientes componentes:

- Frontend desarrollado con React + Vite servido mediante Nginx.
- Backend de Ventas desarrollado con Spring Boot.
- Backend de Despachos desarrollado con Spring Boot.
- Base de datos MySQL desplegada dentro del clúster Kubernetes.
- Repositorios privados en Amazon ECR para almacenar las imágenes Docker.
- Pipeline CI/CD con GitHub Actions para construir, subir y desplegar imágenes.
- Horizontal Pod Autoscaler para escalar servicios según consumo de CPU.
- Kubernetes Secret para el manejo de credenciales sensibles.

---

## 🧭 Estructura del Proyecto

```text
innovatechDevopsExp3/
├── backend/
│   ├── back-Ventas_SpringBoot/
│   └── back-Despachos_SpringBoot/
├── frontend/
│   └── front_despacho/
├── infra/
│   ├── terraform/
│   │   ├── versions.tf
│   │   ├── provider.tf
│   │   ├── variables.tf
│   │   ├── locals.tf
│   │   ├── iam.tf
│   │   ├── network.tf
│   │   ├── security.tf
│   │   ├── eks.tf
│   │   ├── ecr.tf
│   │   └── outputs.tf
│   └── k8s/
│       ├── secret.example.yml
│       ├── mysql.yml
│       ├── backend-ventas.yml
│       ├── backend-despachos.yml
│       ├── frontend.yml
│       └── hpa.yml
├── .github/
│   └── workflows/
│       └── deploy.yml
├── .gitignore
└── README.md
```

---

## 🚀 Tecnologías Utilizadas

- AWS Academy Learner Lab
- Amazon EKS
- Amazon ECR
- Amazon EC2 Node Group
- Terraform
- Kubernetes
- Docker
- GitHub Actions
- Spring Boot
- React + Vite
- Nginx
- MySQL
- Metrics Server
- Horizontal Pod Autoscaler

---

## ⚙️ Arquitectura Implementada

La arquitectura se basa en un clúster **Amazon EKS** creado mediante Terraform.

### Componentes principales

| Componente | Tecnología | Descripción |
| --- | --- | --- |
| Frontend | React + Vite + Nginx | Interfaz web expuesta públicamente |
| Backend Ventas | Spring Boot | API REST para gestión de ventas |
| Backend Despachos | Spring Boot | API REST para gestión de despachos |
| Base de datos | MySQL 8.0 | Base de datos interna del clúster |
| Orquestación | Amazon EKS | Administración de contenedores |
| Registro de imágenes | Amazon ECR | Almacenamiento privado de imágenes Docker |
| CI/CD | GitHub Actions | Build, push y deploy automático |
| Autoscaling | Kubernetes HPA | Escalamiento automático por CPU |

---

## ☁️ Infraestructura AWS

Terraform crea los siguientes recursos:

- VPC personalizada.
- Dos subredes públicas en distintas zonas de disponibilidad.
- Internet Gateway.
- Route Table pública.
- Security Group para EKS.
- Cluster Amazon EKS.
- Node Group administrado.
- Repositorios Amazon ECR:
  - `innovatech-ep3-frontend`
  - `innovatech-ep3-ventas`
  - `innovatech-ep3-despachos`

La infraestructura se encuentra separada en distintos archivos `.tf` para mejorar la organización y mantenibilidad del proyecto.

---

## 🔐 Manejo de credenciales y Secrets

El proyecto **no utiliza archivos `.env`** para almacenar credenciales.

Las credenciales sensibles se manejan mediante:

1. **GitHub Secrets**, utilizados por el pipeline CI/CD.
2. **Kubernetes Secret**, aplicado dentro del clúster EKS.
3. Archivo `infra/k8s/secret.example.yml`, utilizado solo como plantilla sin credenciales reales.

El archivo real:

```text
infra/k8s/secret.yml
```

no se sube al repositorio porque está incluido en `.gitignore`.

### Secrets requeridos en GitHub Actions

En GitHub se deben configurar los siguientes secrets:

```text
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_SESSION_TOKEN
MYSQL_ROOT_PASSWORD
MYSQL_USER
MYSQL_PASSWORD
```

Ejemplo de valores para MySQL en ambiente de prueba:

```text
MYSQL_ROOT_PASSWORD=root123
MYSQL_USER=root
MYSQL_PASSWORD=root123
```

Durante el pipeline, GitHub Actions genera temporalmente el archivo `secret.yml`, lo aplica al clúster como Kubernetes Secret y luego el archivo desaparece junto con la máquina temporal del workflow.

---

## 📦 Manifiestos Kubernetes

Los manifiestos se encuentran en:

```text
infra/k8s/
```

| Archivo | Función |
| --- | --- |
| `secret.example.yml` | Plantilla del Secret sin credenciales reales |
| `mysql.yml` | ConfigMap, Deployment y Service de MySQL |
| `backend-ventas.yml` | Deployment y Service del backend de ventas |
| `backend-despachos.yml` | Deployment y Service del backend de despachos |
| `frontend.yml` | Deployment y Service LoadBalancer del frontend |
| `hpa.yml` | Horizontal Pod Autoscaler de frontend y backends |

---

## 🔄 Pipeline CI/CD

El pipeline se encuentra en:

```text
.github/workflows/deploy.yml
```

Se ejecuta automáticamente al hacer `push` a la rama:

```text
deploy
```

### Flujo del pipeline

1. Descarga el código del repositorio.
2. Configura credenciales temporales de AWS Academy.
3. Inicia sesión en Amazon ECR.
4. Construye la imagen Docker del backend de ventas.
5. Sube la imagen del backend de ventas a ECR.
6. Construye la imagen Docker del backend de despachos.
7. Sube la imagen del backend de despachos a ECR.
8. Construye la imagen Docker del frontend.
9. Sube la imagen del frontend a ECR.
10. Conecta `kubectl` con el clúster EKS.
11. Crea el Kubernetes Secret desde GitHub Secrets.
12. Aplica los manifiestos Kubernetes.
13. Actualiza las imágenes de los Deployments.
14. Espera el rollout de los servicios.
15. Muestra el estado final de Pods, Services y HPA.

---

## 🌿 Flujo de ramas

El proyecto utiliza las siguientes ramas:

| Rama | Uso |
| --- | --- |
| `main` | Versión estable final |
| `develop` | Integración de cambios |
| `deploy` | Rama que dispara GitHub Actions |
| `feature/*` | Desarrollo de nuevas funcionalidades |
| `fix/*` | Correcciones puntuales |

Flujo recomendado:

```bash
git checkout develop
git pull origin develop

git checkout deploy
git pull origin deploy
git merge develop
git push origin deploy
```

---

## 🛠️ Requisitos previos

Antes de ejecutar el proyecto se necesita:

- AWS CLI instalado.
- Terraform instalado.
- kubectl instalado.
- Docker instalado.
- Git instalado.
- Cuenta AWS Academy Learner Lab activa.
- Repositorio GitHub con Actions habilitado.
- Secrets configurados en GitHub Actions.

---

## 🔑 Configurar credenciales AWS Academy

En AWS Academy, copiar las credenciales del Learner Lab y configurarlas localmente.

```bash
aws configure
```

Ingresar:

```text
AWS Access Key ID
AWS Secret Access Key
Default region name: us-east-1
Default output format: json
```

Luego configurar el token temporal:

```bash
aws configure set aws_session_token "TOKEN_DEL_LAB"
```

Validar conexión:

```bash
aws sts get-caller-identity
```

---

## 🏗️ Crear infraestructura con Terraform

Desde la raíz del proyecto:

```bash
cd infra/terraform
terraform init
terraform validate
terraform apply -auto-approve
```

Al finalizar, Terraform mostrará salidas como:

```text
cluster_name
cluster_endpoint
frontend_ecr_url
ventas_ecr_url
despachos_ecr_url
connect_kubectl
```

---

## 🔌 Conectar kubectl con EKS

Después de crear el clúster:

```bash
aws eks update-kubeconfig --region us-east-1 --name innovatech-ep3-eks
```

Validar nodos:

```bash
kubectl get nodes
```

Resultado esperado:

```text
NAME                          STATUS   ROLES    AGE   VERSION
ip-10-0-10-xxx.ec2.internal   Ready    <none>   5m    v1.xx
ip-10-0-20-xxx.ec2.internal   Ready    <none>   5m    v1.xx
```

---

## 📊 Instalar Metrics Server

El HPA necesita Metrics Server para leer consumo de CPU y memoria.

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

Esperar que quede listo:

```bash
kubectl rollout status deployment/metrics-server -n kube-system
```

Validar métricas:

```bash
kubectl top nodes
kubectl top pods
```

Si aparece el error:

```text
Metrics API not available
```

ejecutar:

```bash
kubectl patch deployment metrics-server -n kube-system --type=json -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
kubectl rollout restart deployment/metrics-server -n kube-system
kubectl rollout status deployment/metrics-server -n kube-system
```

Luego volver a probar:

```bash
kubectl top nodes
kubectl top pods
```

---

## 🚀 Ejecutar despliegue CI/CD

El despliegue se realiza al hacer push a la rama `deploy`.

```bash
git checkout deploy
git pull origin deploy
git merge develop
git push origin deploy
```

También se puede disparar el pipeline con un commit vacío:

```bash
git checkout deploy
git pull origin deploy
git commit --allow-empty -m "chore(eks): prueba pipeline"
git push origin deploy
```

---

## ✅ Comandos de validación

### Ver nodos

```bash
kubectl get nodes
```

### Ver Pods

```bash
kubectl get pods -o wide
```

### Ver Deployments

```bash
kubectl get deployments
```

### Ver Services

```bash
kubectl get svc
```

### Ver HPA

```bash
kubectl get hpa
```

### Ver métricas de nodos

```bash
kubectl top nodes
```

### Ver métricas de Pods

```bash
kubectl top pods
```

### Ver estado de rollout

```bash
kubectl rollout status deployment/frontend
kubectl rollout status deployment/backend-ventas
kubectl rollout status deployment/backend-despachos
```

---

## 🌐 Acceso al Frontend

El frontend se expone mediante un Service de tipo `LoadBalancer`.

Obtener la URL pública:

```bash
kubectl get svc frontend
```

El campo `EXTERNAL-IP` mostrará el DNS público del Load Balancer.

Ejemplo:

```text
frontend   LoadBalancer   172.20.xxx.xxx   xxxxx.us-east-1.elb.amazonaws.com   80:xxxxx/TCP
```

Abrir en navegador:

```text
http://xxxxx.us-east-1.elb.amazonaws.com
```

---

## 🔎 Pruebas de endpoints

Probar frontend:

```bash
curl http://DNS_DEL_LOAD_BALANCER/
```

Probar backend de ventas a través del frontend/Nginx:

```bash
curl http://DNS_DEL_LOAD_BALANCER/api/v1/ventas
```

Probar backend de despachos a través del frontend/Nginx:

```bash
curl http://DNS_DEL_LOAD_BALANCER/api/v1/despachos
```

---

## 📜 Logs

### Logs del frontend

```bash
kubectl logs deployment/frontend
```

### Logs del backend de ventas

```bash
kubectl logs deployment/backend-ventas
```

### Logs del backend de despachos

```bash
kubectl logs deployment/backend-despachos
```

### Logs de MySQL

```bash
kubectl logs deployment/mysql
```

### Logs en tiempo real

```bash
kubectl logs -f deployment/backend-ventas
```

---

## 📈 HPA y Auto Scaling

El proyecto implementa Horizontal Pod Autoscaler con objetivo de CPU al 50%.

Ver HPA:

```bash
kubectl get hpa
```

Resultado esperado:

```text
NAME                    REFERENCE                      TARGETS      MINPODS   MAXPODS   REPLICAS
backend-ventas-hpa      Deployment/backend-ventas      cpu: 5%/50%  2         4         2
backend-despachos-hpa   Deployment/backend-despachos   cpu: 3%/50%  2         4         2
frontend-hpa            Deployment/frontend            cpu: 2%/50%  1         3         1
```

El umbral de 50% permite escalar los Pods cuando el consumo de CPU supera la mitad de los recursos solicitados, manteniendo disponibilidad ante aumentos de carga.

---

## 🔁 Rollout y recuperación

### Ver historial de rollout

```bash
kubectl rollout history deployment/frontend
```

```bash
kubectl rollout history deployment/backend-ventas
```

```bash
kubectl rollout history deployment/backend-despachos
```

### Reiniciar un Deployment

```bash
kubectl rollout restart deployment/frontend
```

### Ver estado después del reinicio

```bash
kubectl rollout status deployment/frontend
```

---

## 🧪 Verificación en AWS Console

Además de los comandos, se puede validar desde AWS Console:

### Amazon EKS

Ruta:

```text
AWS Console → EKS → Clusters → innovatech-ep3-eks
```

Evidencias recomendadas:

- Cluster activo.
- Node Group creado.
- Nodos en estado Ready.
- Workloads visibles.
- Services creados.

### Amazon ECR

Ruta:

```text
AWS Console → ECR → Repositories
```

Repositorios esperados:

```text
innovatech-ep3-frontend
innovatech-ep3-ventas
innovatech-ep3-despachos
```

Cada repositorio debe contener imágenes con tags:

```text
latest
hash del commit
```

### EC2 Load Balancer

Ruta:

```text
AWS Console → EC2 → Load Balancers
```

Ahí se puede ver el DNS público del Load Balancer asociado al frontend.

---

## 🧹 Apagado seguro del ambiente

Antes de destruir Terraform, se recomienda eliminar los recursos Kubernetes para liberar el Load Balancer y evitar errores de dependencias en subredes.

Desde la raíz del proyecto:

```bash
kubectl delete -f infra/k8s/frontend.yml --ignore-not-found=true
kubectl delete -f infra/k8s/hpa.yml --ignore-not-found=true
kubectl delete -f infra/k8s/backend-ventas.yml --ignore-not-found=true
kubectl delete -f infra/k8s/backend-despachos.yml --ignore-not-found=true
kubectl delete -f infra/k8s/mysql.yml --ignore-not-found=true
```

Esperar 2 a 5 minutos para que AWS libere el Load Balancer.

Luego destruir infraestructura:

```bash
cd infra/terraform
terraform destroy -auto-approve
```

---

## 📸 Evidencias recomendadas para la presentación

Se recomienda capturar:

- `terraform apply` exitoso.
- Cluster EKS creado.
- Node Group activo.
- Repositorios ECR con imágenes.
- GitHub Actions exitoso.
- Build y push de imágenes.
- Deploy a EKS exitoso.
- `kubectl get nodes`.
- `kubectl get pods -o wide`.
- `kubectl get svc`.
- `kubectl get hpa`.
- `kubectl top nodes`.
- `kubectl top pods`.
- Logs de frontend y backends.
- URL pública del frontend funcionando.
- Endpoints `/api/v1/ventas` y `/api/v1/despachos`.

---

## 📌 Buenas prácticas implementadas

- Infraestructura como Código con Terraform.
- Separación de Terraform por responsabilidad.
- Uso de Amazon EKS para orquestación.
- Uso de Amazon ECR para imágenes privadas.
- CI/CD automatizado con GitHub Actions.
- Uso de Kubernetes Secret para credenciales.
- No se versionan archivos `.env` ni secretos reales.
- Uso de Services internos tipo ClusterIP para backends y base de datos.
- Exposición pública solo del frontend mediante LoadBalancer.
- Uso de probes de salud en los contenedores.
- HPA basado en CPU.
- Comandos documentados para métricas, logs y recuperación.

---

## 👥 Equipo

Proyecto desarrollado para la Evaluación Parcial 3 de la asignatura de Introducción a Herramientas DevOps.
