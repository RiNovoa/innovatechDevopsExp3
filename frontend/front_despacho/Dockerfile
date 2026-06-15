# Etapa 1: Build
FROM node:18-alpine AS builder
WORKDIR /app

# Argumento para la URL del backend (valor por defecto para desarrollo local)
ARG VITE_API_URL=http://localhost:8081
ENV VITE_API_URL=$VITE_API_URL

# Copiar dependencias
COPY package*.json ./
RUN npm ci

# Copiar el resto y construir
COPY . .
RUN npm run build

# Etapa 2: Servir con nginx (usuario no root)
FROM nginx:alpine
RUN rm -rf /usr/share/nginx/html/*
COPY --from=builder /app/dist /usr/share/nginx/html
RUN chown -R nginx:nginx /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]