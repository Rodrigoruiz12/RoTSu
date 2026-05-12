# Fase de construcción (Builder)
FROM node:22-alpine AS builder
WORKDIR /app

# Habilitar corepack para usar pnpm de manera nativa
RUN corepack enable && corepack prepare pnpm@latest --activate

# Copiar configuración de paquetes, dependencias y seguridad (.npmrc)
COPY package.json pnpm-lock.yaml* .npmrc ./

# Instalación determinista y segura
RUN pnpm install --frozen-lockfile

# Copiar el código fuente
COPY . .

# Construir aplicación con Vite
RUN pnpm run build

# Imagen de producción superligera (Nginx para servir estáticos)
FROM nginx:alpine

# Copiar el build generado por Vite en el stage anterior
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

# Iniciar servidor web de producción
CMD ["nginx", "-g", "daemon off;"]
