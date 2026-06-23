# Innovatech DevOps EP3 - AWS EKS, Terraform y CI/CD

## 📝 Descripción

Infraestructura y despliegue automatizado en **AWS** utilizando **Terraform**, **Amazon EKS**, **Amazon ECR**, **Kubernetes** y **GitHub Actions**.

Este proyecto despliega una aplicación compuesta por:

- Frontend React + Vite servido con Nginx.
- Backend Ventas desarrollado con Spring Boot.
- Backend Despachos desarrollado con Spring Boot.
- Base de datos MySQL dentro del clúster Kubernetes.
- Repositorios Amazon ECR para almacenar imágenes Docker.
- Pipeline CI/CD para build, push y deploy automático.
- HPA para escalamiento automático por CPU.
- Kubernetes Secret para credenciales sensibles.

---

## 🧭 Estructura del proyecto

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
│   │   ├── outputs.tf
│   │   └── .terraform.lock.hcl
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

## 🚀 Requisitos

Para ejecutar el proyecto se necesita:

- Terraform CLI instalado.
- AWS CLI instalado.
- kubectl instalado.
- Docker instalado.
- Git instalado.
- Cuenta AWS Academy Learner Lab activa.
- Repositorio GitHub con Actions habilitado.
- Credenciales temporales de AWS Academy.
- Secrets configurados en GitHub Actions.

---

## 📦 ¿Qué despliega este proyecto?

### Terraform

Terraform crea la infraestructura base en AWS:

- VPC personalizada.
- Dos subredes públicas.
- Internet Gateway.
- Route Table pública.
- Security Group para EKS.
- Cluster Amazon EKS.
- Node Group administrado.
- Repositorios Amazon ECR:
  - `innovatech-ep3-frontend`
  - `innovatech-ep3-ventas`
  - `innovatech-ep3-despachos`

### Kubernetes

Kubernetes despliega los componentes de la aplicación dentro de EKS:

- Deployment y Service para MySQL.
- Deployment y Service para backend de ventas.
- Deployment y Service para backend de despachos.
- Deployment y Service tipo LoadBalancer para frontend.
- Horizontal Pod Autoscaler.
- Kubernetes Secret para credenciales de MySQL.

### GitHub Actions

El pipeline CI/CD realiza:

- Build de imágenes Docker.
- Push de imágenes a Amazon ECR.
- Conexión con Amazon EKS.
- Creación del Kubernetes Secret.
- Aplicación de manifiestos Kubernetes.
- Actualización de imágenes en los Deployments.
- Validación del rollout.

---

## ⚙️ Flujo de uso

El orden correcto para levantar el sistema es:

```text
1. Iniciar AWS Academy Learner Lab
2. Configurar credenciales AWS locales
3. Crear infraestructura con Terraform
4. Conectar kubectl con EKS
5. Instalar Metrics Server
6. Configurar GitHub Secrets
7. Ejecutar pipeline desde rama deploy
8. Validar Pods, Services, HPA, Logs y Frontend
```

---

## 1️⃣ Iniciar AWS Academy Learner Lab

Ingresar a AWS Academy y presionar:

```text
Start Lab
```

Luego copiar las credenciales temporales del laboratorio:

```text
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_SESSION_TOKEN
```

Estas credenciales se usan localmente y también en GitHub Actions.

---

## 2️⃣ Configurar credenciales AWS localmente

Ejecutar:

```bash
aws configure
```

Ingresar:

```text
AWS Access Key ID: TU_ACCESS_KEY
AWS Secret Access Key: TU_SECRET_KEY
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

Resultado esperado:

```json
{
    "UserId": "...",
    "Account": "...",
    "Arn": "..."
}
```

---

## 3️⃣ Crear infraestructura con Terraform

Desde la raíz del proyecto:

```bash
cd infra/terraform
```

Inicializar Terraform:

```bash
terraform init
```

Formatear archivos:

```bash
terraform fmt
```

Validar configuración:

```bash
terraform validate
```

Revisar plan:

```bash
terraform plan
```

Crear infraestructura:

```bash
terraform apply -auto-approve
```

Al finalizar, Terraform mostrará outputs similares a:

```text
cluster_name = "innovatech-ep3-eks"
cluster_endpoint = "..."
frontend_ecr_url = "..."
ventas_ecr_url = "..."
despachos_ecr_url = "..."
connect_kubectl = "aws eks update-kubeconfig --region us-east-1 --name innovatech-ep3-eks"
```

---

## 4️⃣ Conectar kubectl con EKS

Después de crear el clúster, ejecutar:

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

Este paso solo es necesario cuando:

- Se usa un computador nuevo.
- Se recrea el clúster EKS.
- Se resetea AWS Academy.
- `kubectl` apunta a un endpoint anterior.

---

## 5️⃣ Instalar Metrics Server

Metrics Server permite obtener métricas de CPU y memoria para el HPA.

Instalar:

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

Luego validar nuevamente:

```bash
kubectl top nodes
kubectl top pods
```

---

## 6️⃣ Configurar GitHub Secrets

En GitHub ir a:

```text
Repository → Settings → Secrets and variables → Actions → New repository secret
```

Configurar los siguientes secrets:

```text
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
AWS_SESSION_TOKEN
MYSQL_ROOT_PASSWORD
MYSQL_USER
MYSQL_PASSWORD
```

Valores usados para MySQL en ambiente de prueba:

```text
MYSQL_ROOT_PASSWORD=root123
MYSQL_USER=root
MYSQL_PASSWORD=root123
```

Los secrets de AWS deben corresponder a las credenciales temporales actuales del Learner Lab.

---

## 7️⃣ Ejecutar despliegue CI/CD

El pipeline se ejecuta al hacer push a la rama:

```text
deploy
```

Flujo recomendado:

```bash
git checkout develop
git pull origin develop

git checkout deploy
git pull origin deploy
git merge develop
git push origin deploy
```

También se puede ejecutar con un commit vacío:

```bash
git checkout deploy
git pull origin deploy
git commit --allow-empty -m "chore(eks): prueba pipeline"
git push origin deploy
```

---

## 🔄 CI/CD del proyecto

### CI - Continuous Integration

La etapa de CI construye y publica imágenes Docker:

```text
Código fuente
   ↓
Build Docker
   ↓
Push a Amazon ECR
```

Incluye:

- Build backend ventas.
- Push backend ventas a ECR.
- Build backend despachos.
- Push backend despachos a ECR.
- Build frontend.
- Push frontend a ECR.

### CD - Continuous Deployment

La etapa de CD despliega en Amazon EKS:

```text
Amazon ECR
   ↓
kubectl apply / kubectl set image
   ↓
Deployments actualizados en EKS
```

Incluye:

- Conexión con EKS.
- Creación de Kubernetes Secret.
- Aplicación de manifiestos.
- Actualización de imágenes.
- Validación del rollout.
- Estado final de Pods, Services y HPA.

---

## 🔐 Manejo de Secrets

El proyecto no utiliza archivos `.env` para credenciales sensibles.

Las credenciales de MySQL se manejan mediante:

- GitHub Secrets.
- Kubernetes Secret.
- Archivo `secret.example.yml` como plantilla sin datos reales.

El archivo real:

```text
infra/k8s/secret.yml
```

no se sube al repositorio porque está incluido en `.gitignore`.

### Flujo de Secrets

```text
GitHub Secrets
      ↓
GitHub Actions genera secret.yml temporalmente
      ↓
kubectl apply -f infra/k8s/secret.yml
      ↓
Kubernetes crea mysql-secret
      ↓
MySQL y backends consumen credenciales con secretKeyRef
```

### Comprobar Secret

Después del deploy:

```bash
kubectl get secret mysql-secret
```

Resultado esperado:

```text
NAME           TYPE     DATA   AGE
mysql-secret   Opaque   3      14m
```

Ver claves sin mostrar valores sensibles:

```bash
kubectl describe secret mysql-secret
```

Resultado esperado:

```text
Name:         mysql-secret
Namespace:    default
Type:         Opaque

Data
====
MYSQL_ROOT_PASSWORD:             7 bytes
SPRING_DATASOURCE_USERNAME:      4 bytes
SPRING_DATASOURCE_PASSWORD:      7 bytes
```

---

## ✅ Validación del despliegue

Ver Pods:

```bash
kubectl get pods -o wide
```

Ver Deployments:

```bash
kubectl get deployments
```

Ver Services:

```bash
kubectl get svc
```

Ver HPA:

```bash
kubectl get hpa
```

Ver métricas:

```bash
kubectl top nodes
kubectl top pods
```

Ver rollout:

```bash
kubectl rollout status deployment/frontend
kubectl rollout status deployment/backend-ventas
kubectl rollout status deployment/backend-despachos
```

---

## 🌐 Acceso al Frontend

El frontend se expone mediante un Service de tipo `LoadBalancer`.

Obtener URL pública:

```bash
kubectl get svc frontend
```

Resultado esperado:

```text
NAME       TYPE           CLUSTER-IP       EXTERNAL-IP                                      PORT(S)
frontend   LoadBalancer   172.20.xxx.xxx   xxxxx.us-east-1.elb.amazonaws.com                80:xxxxx/TCP
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

Probar backend ventas:

```bash
curl http://DNS_DEL_LOAD_BALANCER/api/v1/ventas
```

Probar backend despachos:

```bash
curl http://DNS_DEL_LOAD_BALANCER/api/v1/despachos
```

---

## 📜 Logs

Logs frontend:

```bash
kubectl logs deployment/frontend
```

Logs backend ventas:

```bash
kubectl logs deployment/backend-ventas
```

Logs backend despachos:

```bash
kubectl logs deployment/backend-despachos
```

Logs MySQL:

```bash
kubectl logs deployment/mysql
```

Logs en tiempo real:

```bash
kubectl logs -f deployment/backend-ventas
```

Últimas 50 líneas:

```bash
kubectl logs deployment/backend-ventas --tail=50
```

Logs de los últimos 5 minutos:

```bash
kubectl logs deployment/backend-ventas --since=5m
```

---

## 📈 HPA y Auto Scaling

El proyecto implementa HPA con objetivo de CPU al 50%.

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

Ver detalle:

```bash
kubectl describe hpa backend-ventas-hpa
kubectl describe hpa backend-despachos-hpa
kubectl describe hpa frontend-hpa
```

---

## 🧪 Verificación en AWS Console

### Amazon EKS

Ruta:

```text
AWS Console → EKS → Clusters → innovatech-ep3-eks
```

Se puede verificar:

- Cluster activo.
- Node Group creado.
- Nodos disponibles.
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

Cada repositorio debe tener imágenes con tags:

```text
latest
hash del commit
```

### EC2 Load Balancer

Ruta:

```text
AWS Console → EC2 → Load Balancers
```

Ahí se visualiza el DNS público del Load Balancer asociado al frontend.

---

## 🧹 Apagado seguro

Antes de destruir Terraform, eliminar recursos Kubernetes para liberar el Load Balancer:

```bash
kubectl delete -f infra/k8s/frontend.yml --ignore-not-found=true
kubectl delete -f infra/k8s/hpa.yml --ignore-not-found=true
kubectl delete -f infra/k8s/backend-ventas.yml --ignore-not-found=true
kubectl delete -f infra/k8s/backend-despachos.yml --ignore-not-found=true
kubectl delete -f infra/k8s/mysql.yml --ignore-not-found=true
```

Esperar 2 a 5 minutos.

Luego destruir infraestructura:

```bash
cd infra/terraform
terraform destroy -auto-approve
```

Resultado esperado:

```text
Destroy complete!
```

Después detener el laboratorio:

```text
AWS Academy → End Lab / Stop Lab
```

---

## 🧭 Diagrama de arquitectura

```text
Usuario → LoadBalancer → Frontend → Backends → MySQL
GitHub Actions → Amazon ECR → Amazon EKS
Terraform → VPC + EKS + Node Group + ECR
```

---

## 📌 Mejores prácticas incluidas

- Infraestructura como Código con Terraform.
- Separación de Terraform por responsabilidad.
- Uso de Amazon EKS para orquestación de contenedores.
- Uso de Amazon ECR para imágenes privadas.
- Pipeline CI/CD automatizado con GitHub Actions.
- Uso de GitHub Secrets para credenciales del pipeline.
- Uso de Kubernetes Secret para credenciales de MySQL.
- Archivo `secret.example.yml` como plantilla sin datos sensibles.
- Archivo `secret.yml` ignorado mediante `.gitignore`.
- No se versionan archivos `.env` ni secretos reales.
- Backends y MySQL internos mediante Services tipo ClusterIP.
- Exposición pública solo del frontend mediante LoadBalancer.
- Probes de salud en contenedores.
- HPA basado en CPU.
- Comandos documentados para métricas, logs, rollout y apagado.

---

## 👥 Equipo

Proyecto desarrollado para la Evaluación Parcial 3 de la asignatura Introducción a Herramientas DevOps.

| Integrante | Rol principal |
| --- | --- |
| Ricardo Novoa | Infraestructura Terraform, EKS y documentación |
| Cristóbal Pérez | Aplicación, Kubernetes y pipeline CI/CD |