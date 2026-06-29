<div align="center">

# 🗳️ Veedor App — Control Electoral Ecuador 2026

Sistema móvil para el escrutinio electoral de una organización política, con tres roles diferenciados (Coordinador Provincial, Coordinador de Recinto, Veedor de Mesa) y flujo de registro de actas con validación de nitidez, geolocalización, validación de cédula ecuatoriana, **sincronización offline con SQLite** y dashboard de votos consolidados.

[![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Appwrite](https://img.shields.io/badge/Appwrite-BaaS-F02E65?logo=appwrite&logoColor=white)](https://appwrite.io)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=green)](#)

</div>

---

## 📋 Descripción del Proyecto

Aplicación móvil Android/iOS para gestionar el **escrutinio electoral** de una organización política ecuatoriana. Cubre el ciclo completo:

- **Gestión jerárquica de usuarios** (creación de cuentas por niveles con validación de cédula)
- **Asignación de recintos, mesas (JRV) y veedores** (un veedor puede tener N mesas)
- **5 organizaciones políticas precargadas** para cada dignidad (Alcalde/Prefecto)
- **Registro fotográfico de actas** con validación de nitidez Laplacian y captura automática de GPS
- **Sincronización offline con SQLite** (puntaje extra)
- **Dashboard de votos consolidados** por candidato/dignidad
- **Edición y auditoría** de actas en cualquier momento
- **Reportes de avance** por recinto con coordenadas de origen

> 🟢 **Conectividad inestable:** la app detecta pérdida de conectividad y guarda los datos localmente; cuando se restablece, sincroniza automáticamente.

---

## 🚀 Stack Tecnológico

| Capa | Tecnología | Versión | Justificación |
|---|---|---|---|
| Framework | Flutter | 3.24+ | Multiplataforma, hot-reload, ecosistema maduro |
| Lenguaje | Dart | 3.5+ | Tipado fuerte, null safety |
| State Management | **flutter_bloc** | ^9.1 | Estados explícitos + testabilidad |
| Dependency Injection | **get_it** | ^9.2 | Service locator, sin code-gen |
| Backend | **Appwrite Cloud** | 25.2+ | Open-source, sin límite de transacciones |
| Auth | Appwrite Account | — | JWT, OAuth, recovery nativo |
| Storage | Appwrite Storage | — | Bucket para fotos de actas |
| **Persistencia local** | **sqflite** | ^2.4 | SQLite embebido para offline-first |
| GPS | **geolocator** | ^14.0 | Permisos, lat/lng, settings |
| Cámara | **image_picker** | ^1.2 | Captura desde cámara nativa |
| Nitidez | **image** | ^4.8 | Laplacian variance |
| Conectividad | **connectivity_plus** | ^7.1 | Detección online/offline |
| Equatable | **equatable** | ^2.0 | Value equality para BLoC states |

---

## 🏗️ Arquitectura

### Patrón: Clean Architecture + BLoC

```
lib/
├── core/                                # Configuración transversal
│   ├── config/                          # AppwriteConfig, Constants
│   ├── database/                        # AppDatabase (SQLite)
│   ├── di/                              # GetIt: service_locator.dart
│   ├── error/                           # Failures
│   ├── services/                        # ConnectivityService
│   └── utils/                           # CedulaValidator
│
├── features/
│   ├── auth/                            # Login, recuperación, cambio password
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── home/                            # Dashboards por rol
│   ├── provincial/                      # Rol 1: Coordinador Provincial
│   │   ├── data/
│   │   │   ├── datasources/             # + organizacion, + votos_consolidados
│   │   │   ├── models/                  # + organizacion_model
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/                # + organizacion, + votos_consolidados
│   │   │   ├── repositories/
│   │   │   └── usecases/                # + get_organizaciones, + get_votos_consolidados
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/                   # + votos_consolidados_page
│   │       └── widgets/                 # + dashboard_chart
│   ├── recinto/                         # Rol 2: Coordinador de Recinto
│   │   ├── data/
│   │   ├── domain/
│   │   │   ├── entities/                # + asignacion_entity
│   │   └── presentation/
│   └── veedor/                          # Rol 3: Veedor de Mesa
│       ├── data/
│       │   ├── datasources/             # + acta_local_datasource (SQLite)
│       │   └── services/                # + sync_service (offline→online)
│       ├── domain/
│       │   ├── entities/                # + acta_pendiente_entity
│       │   └── usecases/                # + save_acta_offline, + get_pending_actas
│       └── presentation/
│           ├── bloc/                    # + eventos offline (Save/Sync)
│           └── pages/                   # + pending_actas_page
│
├── app.dart                             # MaterialApp + rutas
└── main.dart                            # Bootstrap + DI
```

### Separación de capas

| Capa | Responsabilidad | Depende de |
|---|---|---|
| **Presentation** | UI + Bloc + gestión de eventos | Domain |
| **Domain** | Entidades, reglas, casos de uso | **Nada** (puro Dart) |
| **Data** | Appwrite + SQLite, repositorios | Domain |

---

## ⚙️ Instalación y Configuración

### 1. Prerrequisitos

- **Flutter SDK** ≥ 3.24
- **Android Studio** + SDK 34+
- **Node.js** ≥ 18 (para configurar Appwrite)
- **Cuenta en [Appwrite Cloud](https://cloud.appwrite.io)**

### 2. Clonar y dependencias

```bash
git clone <URL_DEL_REPO>
cd veedor_app
flutter pub get
```

### 3. Configurar Appwrite (Backend)

```bash
# Crear archivo .env en la raíz con:
APPWRITE_ENDPOINT=https://nyc.cloud.appwrite.io/v1
APPWRITE_PROJECT_ID=<tu_project_id>
APPWRITE_API_KEY=<tu_api_key>

# Ejecutar setup (crea DB, collections, teams, bucket):
node tools/setup-appwrite.js

# Sembrar las 5 organizaciones políticas por dignidad:
node tools/seed-organizaciones.js
```

### 4. Actualizar constants.dart

Verifica que `lib/core/config/constants.dart` tenga los IDs correctos de tu proyecto.

### 5. Compilar APK

```bash
flutter build apk --release
# APK queda en: build/app/outputs/flutter-apk/app-release.apk
```

---

## 🗄️ Modelo de Datos (Appwrite)

### Colecciones

| Colección | Propósito | Permisos |
|---|---|---|
| `users` | Perfiles de usuario (cédula, rol, recintoId) | Provinciales crean coordinadores, Recinto crea veedores |
| `recintos` | Recintos electorales (cantón, parroquia, nombre, mesas) | Provincial crea |
| `mesas` | Mesas (JRV) por recinto | Recinto crea |
| `asignaciones` | Relación N:M veedor↔mesa con flag `activa` | Recinto crea |
| `organizaciones` | Partidos y candidatos (5 Alcalde + 5 Prefecto) | Lectura para todos |
| `actas` | Votos por dignidad + fotoUrl + GPS | Veedor crea, Recinto edita |
| **Bucket `actas-fotos`** | Storage de imágenes | Veedor/Recinto escriben |

### Esquema `organizaciones` (precarga)

```json
{
  "nombre": "Alianza PAIS",
  "siglas": "AP",
  "candidatoNombres": "Juan Carlos",
  "candidatoApellidos": "Pérez Mendoza",
  "dignidad": "Alcalde",
  "numeroLista": 1,
  "colorHex": "#FFB300"
}
```

---

## 🔐 Algoritmo de Validación de Cédula

Implementado en `lib/core/utils/cedula_validator.dart`. Reglas:

1. Exactamente 10 dígitos numéricos
2. Los 2 primeros dígitos corresponden a un código de provincia válido (01-24, 30, 50)
3. El tercer dígito debe ser 0-5 (persona natural)
4. Algoritmo módulo 10 con coeficientes `[2,1,2,1,2,1,2,1,2]`
5. El último dígito es el verificador calculado

Usado en: login, creación de coordinadores, creación de veedores, recuperación de contraseña.

---

## 📡 Sincronización Offline (extra)

### Arquitectura

1. **Detección**: `ConnectivityService` usa `connectivity_plus` para monitorear cambios
2. **Persistencia local**: SQLite (`AppDatabase`) con tabla `actas_pendientes`
3. **Captura**: el form de acta detecta falta de internet y guarda localmente
4. **Sincronización**: `SyncService` reintenta automáticamente cada 2 minutos o cuando vuelve la conexión
5. **Estados**: `pending → syncing → synced` o `error` (con reintentos y backoff)

### Estados de un acta local

```dart
enum ActaSyncStatus { pending, syncing, synced, error }
```

### Manejo de conflictos (estrategia)

- **Last-write-wins con timestamp**: si la mesa/tipo ya existe en la nube, se actualiza con los datos locales
- **Reintentos**: hasta 5 intentos, con `attemptCount` registrado
- **Idempotencia**: usar `mesaId + tipoActa` como clave única

### Visualización

Pantalla `PendingActasPage` muestra todas las actas pendientes con su estado, intentos, y último error.

---

## 👥 Credenciales de Prueba

| Rol | Cédula | Contraseña inicial | Provincia / Recinto |
|---|---|---|---|
| **Coordinador Provincial** | `1712345678` | `Ecuador2026` | Pichincha / Todos |
| **Coordinador de Recinto** | `0923456789` | `Ecuador2026` | Colegio "XYZ", Quito |
| **Veedor de Mesa** | `1756789012` | `Ecuador2026` | JRV-001, Colegio "XYZ" |

> ⚠️ La contraseña debe cambiarse en el primer inicio de sesión.

---

## 🎯 Decisiones Técnicas

### ¿Por qué BLoC y no Provider/Riverpod?

> Mi app tiene 4 features con flujos asíncronos largos (GPS, upload, queries, sync offline). Necesito estados explícitos y testeables que representen Loading/Success/Error/Syncing/Pending. BLoC me da eso out-of-the-box con `sealed class` + `Stream<State>`.

### ¿Por qué Clean Architecture y no MVVM?

> Las reglas del proceso electoral (validación matemática, jerarquía, cédula, sincronización) son complejas y sujetas a cambios por normativa. Clean Architecture me permite testear el 100% de los use cases con mocks, sin Flutter ni Appwrite.

### ¿Por qué Laplacian Variance para nitidez?

> Es la técnica estándar de Computer Vision para detectar desenfoque. Mide la energía de alta frecuencia: una foto nítida tiene bordes definidos (varianza alta), una borrosa tiene bordes difusos (varianza baja). Se calcula en O(n) y se ejecuta en un `compute()` isolate para no bloquear la UI.

### ¿Por qué SQLite (sqflite) en vez de Hive?

> Necesito queries relacionales (`mesaId` + `tipoActa` como índice único) y soporte robusto para flujos transaccionales de sincronización. SQLite es el estándar móvil y permite un manejo de conflictos claro.

---

## 📊 Dashboard de Votos Consolidados

Accesible desde el Panel Provincial (icono de gráfico). Características:

- **Pestañas**: Alcaldes / Prefectos
- **Agregación**: suma de votos por candidato a partir de las actas subidas
- **Visualización**: barras de progreso con porcentaje y conteo de mesas que reportaron
- **Filtrado opcional**: por recinto o global

---

## 📁 Estructura de Archivos Clave

```
lib/
├── core/
│   ├── database/app_database.dart           # SQLite schema
│   ├── services/connectivity_service.dart   # Online/offline
│   ├── utils/cedula_validator.dart          # Algoritmo cédula EC
│   └── di/service_locator.dart              # GetIt
├── features/
│   ├── auth/presentation/pages/login_page.dart
│   ├── home/presentation/pages/{provincial,recinto,veedor}_dashboard.dart
│   ├── provincial/presentation/pages/
│   │   ├── create_recinto_page.dart
│   │   ├── create_coordinador_page.dart
│   │   └── votos_consolidados_page.dart
│   ├── recinto/presentation/pages/
│   │   ├── create_mesa_page.dart
│   │   ├── create_veedor_page.dart
│   │   └── actas_list_page.dart
│   └── veedor/
│       ├── data/services/sync_service.dart
│       ├── data/datasources/acta_local_datasource.dart
│       └── presentation/pages/
│           ├── acta_form_page.dart
│           └── pending_actas_page.dart
└── tools/
    ├── setup-appwrite.js
    └── seed-organizaciones.js
```

---

## 🚧 Limitaciones Conocidas

| # | Limitación | Mitigación |
|---|---|---|
| 1 | Sin notificaciones push | Refrescar manualmente con el botón sync |
| 2 | API `databases.*` deprecated en Appwrite 1.8+ | Migrable a `TablesDB` cuando se requiera |
| 3 | Concurrencia: 2 usuarios editando el mismo acta → last-write-wins | Documentado; en producción usar version optimistic |

---

## 📄 Licencia

MIT. Ver LICENSE.
