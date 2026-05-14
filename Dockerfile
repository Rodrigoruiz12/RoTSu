# Fase de construcción (Builder)
FROM node:22-alpine AS builder
WORKDIR /app

# Copiar configuración de paquetes, dependencias y seguridad (.npmrc)
COPY package.json package-lock.json* ./

# Instalación determinista y segura
RUN npm install

# Copiar el código fuente
COPY . .

# Construir aplicación con Vite
RUN npm run build

# Imagen de producción superligera (Nginx para servir estáticos)
FROM nginx:alpine

# Copiar el build generado por Vite en el stage anterior
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

# Iniciar servidor web de producción
CMD ["nginx", "-g", "daemon off;"]
