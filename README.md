# Venta Rápida Minimarket - Documentación Técnica

## 1. Descripción General del Proyecto

**Venta Rápida Minimarket** es una aplicación interna para Android, desarrollada con Flutter y Firebase, diseñada para agilizar radicalmente el proceso de ventas en el punto físico de un minimarket. La aplicación está optimizada para un rendimiento crítico y opera bajo una arquitectura **Offline-First**, garantizando la continuidad del negocio incluso sin conexión a internet.

El sistema soporta dos roles de usuario:

*   **`Empleado`**: Accede al "Modo Venta Rápida" (POS), realiza ventas y puede registrar nuevos productos sobre la marcha.
*   **`Administrador`**: Tiene acceso completo, incluyendo el modo venta, un panel de reportes de cierre de caja y futuras funciones de gestión.

### Características Principales

*   **Flujo de Escaneo Único**: Escanea un producto y se añade al carrito instantáneamente. Si no existe, se abre una ficha de alta rápida.
*   **Checkout en Dos Toques**: Proceso de cobro ultra-rápido con selección de método de pago (Yape, Efectivo, Tarjeta).
*   **Arquitectura Offline-First**: Todas las operaciones (ventas, creación de productos) son funcionales sin internet. Los datos se sincronizan automáticamente al recuperar la conexión.
*   **Autenticación por Roles**: La interfaz y las funcionalidades se adaptan al rol del usuario logueado.
*   **Panel de Reportes (Admin)**: Visualización en tiempo real del cierre de caja, desglosado por método de pago y resumen de productos vendidos.

## 2. Arquitectura del Sistema

La aplicación sigue una **Arquitectura Limpia** (Clean Architecture) para separar las responsabilidades y mejorar la mantenibilidad del código. Las capas principales son:

*   **`Data`**: Contiene la lógica de acceso a datos. Incluye los modelos de datos de Firestore, los repositorios que abstraen las fuentes de datos (remotas y locales) y los servicios que interactúan directamente con Firebase y el almacenamiento local.
*   **`Domain`**: Es el corazón de la aplicación. Contiene las entidades de negocio (objetos puros de Dart) y los casos de uso (no implementados explícitamente en esta versión, pero la estructura lo permite).
*   **`Presentation`**: Responsable de la UI y la gestión de estado. Utiliza el patrón **Provider** para manejar el estado de la aplicación de forma reactiva.

### Diagrama de Arquitectura

```
[         Cliente Android (Flutter)         ]
|                                           |
|  +---------------------------------------+  |
|  |           Presentation (UI)           |  |
|  | - Screens (Login, POS, Report)        |  |
|  | - Widgets (Dialogs, Cards)            |  |
|  | - Providers (Auth, Cart, Product)     |  |
|  +--------------------^------------------+  |
|                       | (Notifica cambios)  |
|  +--------------------|------------------+  |
|  |           Domain (Entidades)          |  |
|  | - UserEntity, ProductEntity, Sale...  |  |
|  +--------------------^------------------+  |
|                       | (Abstracción)       |
|  +--------------------|------------------+  |
|  |            Data (Repositorios)        |  |
|  | - ProductRepository, SaleRepository   |  |
|  | - OfflineSyncService, FirestoreService|  |
|  +--------------------^------------------+  |
|                       | (API Calls, Sync)   |
|                       V                     |
[           Backend (Firebase)              ]
```

## 3. Estructura de Carpetas

El proyecto está organizado de la siguiente manera dentro de la carpeta `lib`:

```
lib/
├── core/                 # Lógica y widgets compartidos
│   ├── constants/        # Constantes de la app (roles, colecciones)
│   ├── theme/            # Tema visual de la app
│   └── widgets/          # Widgets reutilizables
│
├── data/                 # Capa de datos
│   ├── models/           # Modelos de datos (para Firestore)
│   ├── repositories/     # Repositorios (abstracción de datos)
│   └── services/         # Servicios (Firebase, Offline Sync)
│
├── domain/               # Capa de dominio
│   └── entities/         # Entidades de negocio (objetos puros)
│
├── presentation/         # Capa de presentación
│   ├── providers/        # Gestores de estado (Providers)
│   ├── screens/          # Pantallas principales de la app
│   └── widgets/          # Widgets específicos de una pantalla
│
├── firebase_options.dart # Configuración de Firebase
└── main.dart             # Punto de entrada de la aplicación
```

## 4. Configuración y Puesta en Marcha

Sigue estos pasos para configurar y ejecutar el proyecto.

### Prerrequisitos

*   Tener [Flutter](https://flutter.dev/docs/get-started/install) instalado (última versión estable).
*   Tener una cuenta de [Firebase](https://firebase.google.com/).
*   Tener [Node.js](https://nodejs.org/) y [Firebase CLI](https://firebase.google.com/docs/cli) instalados.

### Pasos de Configuración

1.  **Clonar el Repositorio**:
    ```bash
    git clone <URL_DEL_REPOSITORIO>
    cd <NOMBRE_DEL_REPOSITORIO>
    ```

2.  **Configurar Firebase**:
    Sigue las instrucciones detalladas en el archivo `firebase_init.md`. Este proceso incluye:
    *   Crear el proyecto en Firebase.
    *   Añadir la app de Android y descargar `google-services.json`.
    *   Habilitar Authentication y Firestore.
    *   Crear los usuarios de prueba (admin y empleado).
    *   Desplegar las reglas de seguridad de Firestore (`firestore.rules`).

3.  **Instalar Dependencias**:
    ```bash
    flutter pub get
    ```

4.  **Ejecutar la Aplicación**:
    Conecta un dispositivo Android o inicia un emulador y ejecuta:
    ```bash
    flutter run
    ```

## 5. Generación del APK

Para generar el archivo APK para instalación directa, ejecuta el siguiente comando:

```bash
flutter build apk --release
```

El archivo APK se encontrará en `build/app/outputs/flutter-apk/app-release.apk`.

## 6. Pila Tecnológica (Tech Stack)

*   **Framework**: Flutter
*   **Backend**: Firebase (Authentication, Firestore)
*   **Gestión de Estado**: Provider
*   **Escáner de Códigos**: `mobile_scanner`
*   **Base de Datos Offline**: Firestore Offline Persistence
*   **Sonido**: `audioplayers`

## 7. Reglas de Seguridad de Firestore

Las reglas de seguridad son un componente crítico para proteger los datos. Están definidas en `firestore.rules` y garantizan que:

*   Los **Empleados** solo puedan crear ventas en su sucursal y leer productos.
*   Los **Administradores** tengan acceso completo a todas las colecciones.
*   Los usuarios solo puedan leer y modificar los datos a los que tienen permiso explícito.

Para más detalles, consulta el archivo `firestore.rules`.

---
*Documentación generada por Manus AI.*

