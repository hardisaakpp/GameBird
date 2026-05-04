# 10. Anexos: historial y referencias cruzadas

## 10.1 Propósito

Conserva **trazabilidad** de decisiones y correcciones sin mezclar el relato histórico con la arquitectura normativa de los capítulos 1–9.

## 10.2 Resúmenes de correcciones (bugs)

| Documento original | Tema |
| ------------------ | ---- |
| `Fluttor/BUGFIX_SUMMARY.md` | Errores de `scene.frame` vs `self.frame` en bienvenida |
| `Fluttor/FluttorGame/Sounds/BUGFIX_SUMMARY.md` | Incidencias del subsistema de audio |

Ambos permanecen en el repositorio como **anexos técnicos**; la convención actual del código está en las extensiones de `GameScene` y en `AudioManager`.

## 10.3 Documentación duplicada obsoleta

Si encuentras archivos `.md` fuera de `docs/` con solo un párrafo de redirección, la versión **consolidada** para citar en la tesis es el capítulo correspondiente en **`Fluttor/docs/`**.

## 10.4 DocC (Components)

Catálogo del módulo: **`Fluttor/Components.docc/Components.md`**, enlazado desde [Capítulo 2 — Arquitectura](02-arquitectura-del-sistema.md).

## 10.5 Lista maestra de archivos Markdown del repo

Para una lista actualizada, ejecutar en la raíz del repositorio:

```bash
find Fluttor -name '*.md' | sort
```

Úsalo como checklist al preparar el **anexo documental** de la memoria.
