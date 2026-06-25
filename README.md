<div align="center">

# 🗳️ Veedor App — Control Electoral Ecuador 2026

Sistema móvil para el escrutinio electoral de una organización política, con tres roles diferenciados (Coordinador Provincial, Coordinador de Recinto, Veedor de Mesa) y flujo de registro de actas con validación de nitidez, geolocalización y trazabilidad por GPS.

[![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Appwrite](https://img.shields.io/badge/Appwrite-BaaS-F02E65?logo=appwrite&logoColor=white)](https://appwrite.io)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white)](#)

</div>

---

## 📋 Descripción del Proyecto

Aplicación móvil Android/iOS para gestionar el **escrutinio electoral** de una organización política ecuatoriana. Cubre el ciclo completo:

- **Gestión jerárquica de usuarios** (creación de cuentas por niveles)
- **Asignación de recintos, mesas (JRV) y veedores**
- **Registro fotográfico de actas** con validación de nitidez y captura automática de GPS
- **Edición y auditoría** de actas en cualquier momento
- **Reportes de avance** por recinto con coordenadas de origen

> ⚠️ **Conectividad inestable:** la app está preparada para operar con Appwrite como BaaS, asumiendo que la conexión puede fallar en el día de las elecciones. La sincronización offline con SQLite es un entregable adicional (ver Limitaciones Conocidas).

---

## 🚀 Stack Tecnológico

| Capa | Tecnología | Versión | Justificación |
|---|---|---|---|
| Framework | Flutter | 3.24+ | Multiplataforma, hot-reload, ecosistema maduro |
| Lenguaje | Dart | 3.5+ | Tipado fuerte, null safety |
| State Management | **flutter_bloc** | ^8.1 | Estados explícitos + testabilidad |
| Dependency Injection | **get_it** | ^7.7 | Service locator, sin code-gen |
| Functional Validation | **dartz** | ^0.10 | `Either<Failure, T>` para errores de dominio |
| Backend | **Appwrite Cloud** | 1.6+ | Open-source, sin límite de transacciones |
| Auth | Appwrite Account | — | JWT, OAuth, recovery nativo |
| Storage | Appwrite Storage | — | Bucket para fotos de actas |
| GPS | **geolocator** | ^13.0 | Permisos, lat/lng, settings |
| Cámara | **image_picker** | ^1.1 | Captura desde cámara nativa |
| Nitidez | **image** | ^4.2 | Laplacian variance (OpenCV-style) |
| Equatable | **equatable** | ^2.0 | Value equality para BLoC states |

---

## 🏗️ Arquitectura

### Patrón: Clean Architecture + BLoC

```
lib/
├── core/                          # Configuración transversal
│   ├── di/                        # GetIt: injection_container.dart
│   ├── error/                     # Failures + Exceptions
│   ├── network/                   # Cliente Appwrite
│   ├── theme/                     # Tema de la app
│   └── utils/                     # Validadores, helpers
│
├── features/
│   ├── auth/                      # Login, recuperación, cambio password
│   ├── provincial/                # Rol 1: Coordinador Provincial
│   ├── recinto/                   # Rol 2: Coordinador de Recinto
│   └── veedor/                    # Rol 3: Veedor de Mesa
│
├── app.dart                       # MaterialApp + rutas
└── main.dart                      # Bootstrap + DI + BlocObserver
```

### Separación de capas (explicable en sustentación)

| Capa | Responsabilidad | Depende de |
|---|---|---|
| **Presentation** | UI + gestión de eventos del usuario | Domain |
| **Domain** | Entidades, reglas de negocio, casos de uso | **Nada** (puro Dart) |
| **Data** | Implementaciones: HTTP, local storage, mappers | Domain |

> **Por qué Clean Architecture y no MVC/MVVM simple:** permite testear la lógica de negocio (Domain) sin Flutter ni Appwrite. El 100% de los `usecases/` se testean con mocks de repositorios.

---

## ⚙️ Instalación

### Prerrequisitos

- **Flutter SDK** ≥ 3.24
- **Android Studio** + SDK 34+
- **Node.js** ≥ 18 (solo para ejecutar el script de setup de Appwrite)
- **Cuenta en [Appwrite Cloud](https://cloud.appwrite.io)**

### Pasos

```bash
# 1. Clonar el repositorio
git clone <URL_DEL_REPO>
cd veedor_app

# 2. Instalar dependencias
flutter pub get

# 3. Correr en emulador o dispositivo físico
flutter run
```

---

## 🔐 Configuración de Appwrite

### Paso 1 — Crear proyecto en Appwrite Cloud

1. Ir a cloud.appwrite.io → New Project
2. Anotar **Project ID** y crear una **API Key**
3. Actualizar `lib/core/config/constants.dart` con tus IDs.

### Paso 2 — Ejecutar Setup

En la carpeta raíz del proyecto, entrar a tools y ejecutar `node setup-appwrite.js` (asegúrate de tener instalado node-appwrite).

---

## 👥 Credenciales de Prueba

> ⚠️ Estas credenciales son **DEMO** y deben crearse manualmente en la BD para probar.

| Rol | Cédula (usuario) | Contraseña | Provincia / Recinto |
|---|---|---|---|
| **Coordinador Provincial** | `1712345678` | `Ecuador2026` | Pichincha / Todos |
| **Coordinador de Recinto** | `0923456789` | `Ecuador2026` | Colegio "XYZ", Quito |
| **Veedor de Mesa** | `1756789012` | `Ecuador2026` | JRV-001, Colegio "XYZ" |

---

## 🎯 Decisiones Técnicas

### ¿Por qué BLoC y no Provider/Riverpod?

> *"Mi app tiene 4 features con flujos asíncronos largos (GPS, upload, queries). Necesito estados explícitos y testeables que representen Loading/Success/Error. BLoC me da eso out-of-the-box con `sealed class` + `Stream<State>`."*

### ¿Por qué Clean Architecture y no MVVM?

> *"Las reglas de negocio del proceso electoral (validación matemática, jerarquía de creación de usuarios, validaciones de nitidez/GPS) son complejas y sujetas a cambios por normativa electoral. Clean Architecture me permite testear el 100% de los use cases con mocks, sin Flutter ni Appwrite."*

### ¿Por qué Laplacian Variance para nitidez?

> *"Es la técnica estándar de Computer Vision para detectar desenfoque. Mide la energía de alta frecuencia de la imagen: una foto nítida tiene bordes definidos (varianza alta), una borrosa tiene bordes difusos (varianza baja). Es invariante a iluminación y se calcula en O(n)."*

---

## ⚠️ Limitaciones Conocidas

| # | Limitación | Impacto | Estado |
|---|---|---|---|
| 1 | **Sin sincronización offline** (SQLite) | -15 pts extra no obtenidos | 🟡 Planificado |
| 2 | **Reglas de acceso a nivel de documento** implementadas solo en `actas` (otras colecciones usan filtro en cliente) | Riesgo de over-fetching | 🟡 Documentado en `docs/SECURITY.md` |
| 3 | **Concurrencia:** si dos usuarios editan un acta a la vez, gana el último (`$updatedAt` de Appwrite) | Posible pérdida de cambios | 🟡 Trade-off aceptado, documentado |

---

## 📄 Licencia

Este proyecto es de código abierto bajo la licencia **MIT**. Ver LICENSE.
