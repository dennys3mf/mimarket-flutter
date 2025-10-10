# Configuración de Firebase para Venta Rápida Minimarket

Este documento detalla los pasos para configurar Firebase para la aplicación.

## 1. Crear Proyecto en Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Crea un nuevo proyecto llamado "Venta Rápida Minimarket"
3. Habilita Google Analytics (opcional)

## 2. Agregar Aplicación Android

1. En la consola de Firebase, haz clic en "Agregar app" → Android
2. Ingresa el nombre del paquete: `com.example.mi_tienda_app`
3. Descarga el archivo `google-services.json`
4. Coloca el archivo en `android/app/google-services.json`

## 3. Habilitar Firebase Authentication

1. En Firebase Console, ve a **Authentication**
2. Haz clic en "Comenzar"
3. Habilita el método de inicio de sesión **Email/Contraseña**

## 4. Crear Usuarios Iniciales

Crea los siguientes usuarios en Authentication:

### Usuario Administrador
- **Email:** admin@minimarket.com
- **Contraseña:** admin123456

### Usuario Empleado
- **Email:** empleado@minimarket.com
- **Contraseña:** empleado123456

## 5. Configurar Firestore Database

1. En Firebase Console, ve a **Firestore Database**
2. Haz clic en "Crear base de datos"
3. Selecciona **Modo de producción**
4. Elige la ubicación: **us-central1** (o la más cercana)

## 6. Crear Colección de Usuarios

Después de crear la base de datos, crea manualmente los documentos de usuarios:

### Documento para Admin
**Colección:** `users`  
**ID del documento:** [UID del usuario admin de Authentication]

```json
{
  "email": "admin@minimarket.com",
  "role": "admin",
  "storeId": "sucursal_1"
}
```

### Documento para Empleado
**Colección:** `users`  
**ID del documento:** [UID del usuario empleado de Authentication]

```json
{
  "email": "empleado@minimarket.com",
  "role": "employee",
  "storeId": "sucursal_1"
}
```

## 7. Desplegar Reglas de Seguridad

1. Instala Firebase CLI si no lo tienes:
```bash
npm install -g firebase-tools
```

2. Inicia sesión en Firebase:
```bash
firebase login
```

3. Inicializa el proyecto (desde la raíz del proyecto Flutter):
```bash
firebase init firestore
```

4. Selecciona el proyecto que creaste
5. Acepta los archivos predeterminados
6. Copia el contenido de `firestore.rules` al archivo generado
7. Despliega las reglas:
```bash
firebase deploy --only firestore:rules
```

## 8. Crear Productos de Prueba (Opcional)

Puedes crear algunos productos de prueba en la colección `products`:

### Ejemplo de Producto
**Colección:** `products`  
**ID del documento:** `7501234567890` (código de barras)

```json
{
  "barcode": "7501234567890",
  "name": "Coca Cola 500ml",
  "price": 3.50,
  "stock": {
    "sucursal_1": 50,
    "sucursal_2": 30
  }
}
```

## 9. Habilitar Persistencia Offline

La persistencia offline ya está habilitada en el código de la aplicación (`main.dart`):

```dart
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

## 10. Verificar Configuración

1. Ejecuta la aplicación en modo debug
2. Inicia sesión con las credenciales de prueba
3. Verifica que puedas:
   - Escanear productos
   - Crear nuevos productos
   - Realizar ventas
   - Ver reportes (como admin)

## Notas Importantes

- **Seguridad:** Cambia las contraseñas de prueba en producción
- **Reglas:** Las reglas de Firestore están configuradas para roles específicos
- **Offline:** La aplicación funciona completamente offline y sincroniza automáticamente
- **Costos:** Revisa los límites gratuitos de Firebase para evitar cargos inesperados

## Estructura de Datos en Firestore

```
firestore
├── users
│   └── {userId}
│       ├── email: string
│       ├── role: string ("admin" | "employee")
│       └── storeId: string ("sucursal_1" | "sucursal_2")
│
├── products
│   └── {productId/barcode}
│       ├── barcode: string
│       ├── name: string
│       ├── price: number
│       └── stock: map
│           ├── sucursal_1: number
│           └── sucursal_2: number
│
├── sales
│   └── {saleId}
│       ├── timestamp: timestamp
│       ├── total: number
│       ├── paymentMethod: string ("yape" | "efectivo" | "tarjeta")
│       ├── userId: string
│       ├── storeId: string
│       ├── synced: boolean
│       └── soldItems (subcollection)
│           └── {itemId}
│               ├── productId: string
│               ├── productName: string
│               ├── quantity: number
│               └── priceAtSale: number
│
└── inventoryTransfers (futuro)
    └── {transferId}
        ├── timestamp: timestamp
        ├── fromStoreId: string
        ├── toStoreId: string
        ├── adminId: string
        └── transferredItems (subcollection)
            └── {itemId}
                ├── productId: string
                └── quantity: number
```

## Soporte

Para cualquier problema con la configuración de Firebase, consulta la [documentación oficial de FlutterFire](https://firebase.flutter.dev/).

