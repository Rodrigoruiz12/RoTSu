# Fase base para dependencias y código
FROM node:22-alpine AS base
WORKDIR /app

# Copiar configuración de paquetes, dependencias y seguridad (.npmrc)
COPY package.json package-lock.json* ./

# Instalación determinista y segura
RUN npm install

# Copiar el código fuente
COPY . .

# Fase de pruebas unitarias dentro del contenedor (IE7)
FROM base AS test
RUN npm run test:coverage

# Fase de construcción (Builder)
FROM base AS builder
# Construir aplicación con Vite
RUN npm run build

# Imagen de producción superligera (Nginx para servir estáticos)
FROM nginx:alpine

# Copiar el build generado por Vite en el stage anterior
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

# Iniciar servidor web de producción
CMD ["nginx", "-g", "daemon off;"]
