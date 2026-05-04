# Guía de citación (trabajo académico)

Usa el estilo que exija tu universidad (APA, ISO, Vancouver, etc.). A continuación hay **plantillas** que puedes adaptar.

## Proyecto de software (repositorio)

**Ejemplo (estilo APA 7, software):**

> Ortiz, I. (*s. f.*). *Fluttor* (Versión 1.0) [Código fuente]. GitHub. `https://github.com/USUARIO/GameBird` (o la URL real del repositorio). Fecha de consulta: *día mes año*.

Sustituye la URL por la del repositorio público o anexo que entregues.

## Documentación interna (este árbol `docs/`)

Para citar un capítulo concreto (por ejemplo el sistema de puntuación):

> Ortiz, I. (*s. f.*). *Fluttor — documentación técnica*: Capítulo 5, Persistencia y puntuación. Incluido en el repositorio del proyecto (ruta `Fluttor/docs/05-persistencia-y-puntuacion.md`). Fecha de consulta: *fecha*.

Si la normativa exige URL y el repo es privado, documenta en anexos un `.zip` con versión y fecha y cita el anexo.

## Versión y reproducibilidad

Para tesis o memorias se recomienda consignar:

1. **Commit de Git** (`git rev-parse HEAD`) en la fecha del experimento o del entregable.
2. **Versión de Xcode** y **SDK de iOS** usados al compilar (`xcodebuild -version`).
3. **Dispositivo o simulador** empleado en pruebas.

Puedes copiar esos datos al final de `01-introduccion-y-marco-tecnico.md` cuando cierres una versión del trabajo.
