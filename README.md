# bun-react-tailwind-template

To install dependencies:

```bash
bun install
```

To start a development server:

```bash
bun dev
```

To run for production:

```bash
bun start
```

This project was created using `bun init` in bun v1.3.11. [Bun](https://bun.com) is a fast all-in-one JavaScript runtime.

## Flujo de Trabajo (Workflow)
Hemos decidido implementar **GitFlow** para este proyecto. 
**Justificación:** Al ser un equipo colaborativo simulado, GitFlow nos permite mantener una rama `main` estable con código de producción, mientras usamos `develop` para integrar las nuevas características de manera segura. Las ramas `feature/` nos aíslan durante el desarrollo y `hotfix/` nos da agilidad para errores críticos sin interrumpir el desarrollo en curso.

## Convenciones del Proyecto

### Nombrado de Ramas (Naming)
* **Características:** `feature/nombre-de-la-tarea` (ej. `feature/crear-navbar`)
* **Correcciones urgentes:** `hotfix/nombre-del-error` (ej. `hotfix/fix-error-inicio`)

### Convenciones de Commits
Usaremos Conventional Commits:
* `feat:` para nuevas características.
* `fix:` para solución de errores.
* `docs:` para cambios en la documentación.
* `style:` para formato (espacios, punto y coma, etc).

### Proceso de Revisión (Code Review) y Estrategia de Merge
1. Todo código nuevo debe hacerse en una rama derivada de `develop` (o `main` para hotfixes).
2. Se debe abrir un **Pull Request (PR)**.
3. Se requiere la revisión y aprobación de al menos un compañero antes de fusionar.
4. Los merges hacia `develop` se harán usando "Squash and Merge" para mantener el historial limpio, o "Create a merge commit" para mantener trazabilidad.