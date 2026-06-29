# Política de Seguridad y Permisos

## Equipos (Teams) en Appwrite
- `coordinadores-provinciales` — bootstrapeado manualmente.
- `coordinadores-recinto` — creado por el provincial.
- `veedores` — creado por el coordinador de recinto.

## Permisos por colección

| Colección | Crear | Leer | Actualizar | Borrar |
|---|---|---|---|---|
| `users` | Provincial, Recinto | Autenticados | Provincial, Recinto | Provincial |
| `recintos` | Provincial | Autenticados | Provincial | Provincial |
| `mesas` | Provincial, Recinto | Autenticados | Recinto | Provincial |
| `asignaciones` | Recinto, Provincial | Autenticados | Recinto | Recinto |
| `organizaciones` | Provincial | Autenticados | Provincial | Provincial |
| `actas` | Veedor | Autenticados | Veedor, Recinto | — |
| `actas-fotos` (bucket) | Veedor, Recinto | Autenticados | Veedor, Recinto | Recinto |

## Reglas de acceso a nivel de documento

- **Veedor**: solo ve y modifica `actas` cuya `mesaId` esté en sus `asignaciones` activas.
- **Coordinador de Recinto**: solo ve/modifica datos de su `recintoId`.
- **Coordinador Provincial**: ve todos los recintos de su provincia.

## Validaciones en cliente (defensa adicional)

1. **Cédula ecuatoriana**: algoritmo módulo 10 + código de provincia
2. **Varianza Laplaciana**: nitidez mínima para aceptar foto de acta
3. **GPS obligatorio**: si el permiso está denegado, no permite continuar
4. **Suma de votos == total sufragantes**: validación matemática
5. **Voto individual ≤ total**: ningún campo puede superar el total

## Manejo de conflictos en sincronización offline

Estrategia: **Last-Write-Wins con timestamp**.
- Cada acta local tiene `updatedAt` que se compara con la versión del servidor
- Si existe la combinación `mesaId + tipoActa` en la nube, se actualiza
- Se reintentan hasta 5 veces antes de marcar como `error` definitivo
- El usuario puede forzar reintento desde la pantalla de pendientes

## Limitaciones aceptadas
1. **Over-fetching**: en consultas menores se filtra en cliente
2. **Last-write-wins**: edición concurrente gana el último `$updatedAt`
3. **Sin encriptación local**: SQLite sin SQLCipher (los datos son público por diseño)
