# RoTSu - Microservicio Frontend Corporativo

Este repositorio contiene la implementación del microservicio frontend para **RoTSu**, una empresa de desarrollo de software y soluciones tecnológicas orientada a Pymes y corporaciones. 

El proyecto fue construido bajo estrictos estándares de ingeniería de software, enfocándose en la modularidad de componentes, un pipeline robusto de CI/CD, contenedorización optimizada y una arquitectura orientada a la seguridad de la cadena de suministro (Supply Chain Security).

---

## 1. Arquitectura de Software y Diseño

### Stack Tecnológico
La aplicación está desarrollada utilizando:
- **React 19** empacado con **Vite**, y gestionado a través de **pnpm** (Gestor de paquetes rápido, estricto y eficiente en espacio de disco).
- **TailwindCSS v4** y CSS Nativo (Variables CSS) para un estilizado utilitario y un control milimétrico sobre el diseño responsivo.
- **Framer Motion** para la gestión de micro-interacciones y animaciones de UI.
- **React Router DOM** configurado como Multi-Page Application (MPA).

### Prevención de Ataques de Cadena de Suministro (Supply Chain Security)
Para robustecer la seguridad del ciclo de vida del software, se integró el archivo de configuración `.npmrc`. Esto incluye medidas mitigantes severas para prevenir ataques como:
- **Dependency Confusion / DNS Hijacking**: Al forzar las descargas por `https` estricto y bloquear la consulta de registros no oficiales.
- **Validaciones automáticas de auditoría**: Intercepta de manera preventiva librerías con vulnerabilidades críticas reportadas desde el momento de instalación (`audit-level=high`).
- **Phantom Dependencies**: Gracias al motor interno de `pnpm` y la configuración `public-hoist-pattern=`, se evita que paquetes maliciosos eleven dependencias que permitan la ejecución de scripts arbitrarios de forma silenciosa.

---

## 2. Estrategia de Ramificación: GitFlow

Para organizar el trabajo colaborativo y asegurar entregas continuas sin riesgo, se ha implementado el modelo de ramificación **GitFlow**.
- `main`: Rama de producción. Solo recibe *merges* desde versiones estables y aprobadas.
- `develop`: Rama base de desarrollo. Contiene el historial principal de integración.
Las nuevas funcionalidades (features) y correcciones (hotfixes) se gestionan mediante ramas a partir de `develop`.

---

## 3. DevOps: Contenedorización y Orquestación

### Docker (Imágenes Optimizadas Multi-Stage con Nginx)
Para garantizar una distribución liviana y libre de fallos operacionales ("en mi máquina sí funciona"), el proyecto cuenta con un `Dockerfile` bajo el patrón **Multi-stage Build** (IE1).
1. **Fase Builder (Node.js)**: Utiliza `node:22-alpine` habilitando **Corepack** para usar `pnpm`. Copia el archivo `.npmrc` e instala de forma determinista para realizar el proceso de *build* de Vite.
2. **Fase de Producción (Nginx)**: Utiliza la imagen superligera `nginx:alpine`, la cual solo copia los artefactos estáticos precompilados (`/dist`). Se descarta Node.js por completo, anulando cualquier superficie de ataque basada en Node en tiempo de ejecución.

### Orquestación (Docker Compose)
Se incorporó `docker-compose.yml` para orquestar la solución en clústeres medianos (IE5), mapeando el puerto interno `80` (Nginx) al `3000` de la máquina host.
```bash
docker-compose up -d --build
```
La aplicación se expondrá en `http://localhost:3000`.

---

## 4. Pipeline CI/CD, Trazabilidad y Gobernanza

El proyecto automatiza completamente su ciclo de vida mediante **GitHub Actions** (IE4), ubicado en `.github/workflows/ci-cd.yml`. El pipeline conecta desarrollo con entrega continua a través de 3 etapas (*jobs*):

1. **Build & Test (Integración Continua)**:
   - Configura Node 22 + `pnpm`.
   - Ejecuta validaciones de integridad con **Vitest** (`pnpm run test`) (IE2). Si una prueba falla, el pipeline aborta, previniendo despliegues rotos.
   
2. **Escaneo de Seguridad Dinámico (Gobernanza) (IE3)**:
   - Utiliza **Snyk** (`snyk/actions/node@master`) para analizar vulnerabilidades de dependencias. Implementa *DevSecOps* (Shift-Left).
   - Se apoya pasivamente en **Dependabot** (`.github/dependabot.yml`) para actualizaciones periódicas.

3. **Deploy Simulado (Entrega Continua)**:
   - Construye la imagen Multi-stage mediante `docker buildx` y la orquesta temporalmente con `docker-compose` internamente en el Runner para garantizar un arranque exento de *crashes*.

