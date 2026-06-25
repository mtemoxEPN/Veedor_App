# Política de Seguridad y Permisos

## Equipos (Teams)
- `coordinadores-provinciales` — 1+ miembro(s), bootstrapeado manualmente.
- `coordinadores-recinto` — creado por el provincial.
- `veedores` — creado por el coordinador de recinto.

## Permisos por colección
- **Perfiles:** Creación por provinciales y coordinadores de recinto. Lectura por usuarios autenticados.
- **Recintos:** Creación y modificación exclusiva por provinciales.
- **Mesas:** Creación por provinciales y coordinadores de recinto.
- **Actas:** Creación exclusiva de veedores. Lectura abierta. Actualización permitida para veedores y coordinadores de recinto.

## Restricción por documento
Las reglas anteriores aplican a nivel general. En la sustentación se puede mostrar que Appwrite permite granular a nivel de Documento con `Permission.read(Role.user(userId))` para proteger la privacidad.

## Limitaciones aceptadas
1. **Over-fetching:** Al usar validaciones en cliente para algunas consultas menores.
2. **Last-write-wins:** Appwrite maneja colisiones de edición concurrente usando su timestamp interno (`$updatedAt`), en vez de control optimista de versiones. 
