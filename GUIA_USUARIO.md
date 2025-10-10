# Guía de Usuario - Venta Rápida Minimarket

## Introducción

**Venta Rápida Minimarket** es una aplicación diseñada para hacer que el proceso de ventas en tu minimarket sea rápido, simple y eficiente. Esta guía te ayudará a entender cómo usar la aplicación según tu rol.

## Inicio de Sesión

Al abrir la aplicación, verás la pantalla de inicio de sesión.

### Credenciales de Prueba

**Administrador:**
- Email: `admin@minimarket.com`
- Contraseña: `admin123456`

**Empleado:**
- Email: `empleado@minimarket.com`
- Contraseña: `empleado123456`

> **Nota:** En producción, estas contraseñas deben ser cambiadas por el administrador.

## Para Empleados: Modo Venta Rápida

### 1. Pantalla Principal (POS)

Después de iniciar sesión como empleado, verás la pantalla de **Modo Venta** con:

- **Escáner de código de barras** en la parte superior
- **Lista de productos** en el carrito
- **Total de la venta** en la parte inferior
- **Botón COBRAR** para finalizar la venta

### 2. Agregar Productos al Carrito

#### Opción A: Producto Existente

1. Apunta la cámara al código de barras del producto
2. El producto se agregará automáticamente al carrito
3. Escucharás un sonido de confirmación
4. El total se actualizará instantáneamente

#### Opción B: Producto Nuevo (Alta Rápida)

Si escaneas un producto que no existe en el sistema:

1. Aparecerá un diálogo de **"Producto No Encontrado"**
2. Ingresa el **Nombre del Producto**
3. Ingresa el **Precio de Venta** (en soles)
4. Opcionalmente, ingresa el **Stock Inicial**
5. Presiona **"Guardar y Agregar"**
6. El producto se creará y se agregará al carrito automáticamente

### 3. Modificar Cantidades

Si necesitas ajustar la cantidad de un producto en el carrito:

- Presiona el botón **"-"** para disminuir la cantidad
- Presiona el botón **"+"** para aumentar la cantidad
- Si llegas a cantidad 0, el producto se eliminará del carrito

### 4. Finalizar la Venta (Checkout)

1. Presiona el botón verde **"COBRAR [Total]"**
2. Selecciona el método de pago:
   - **YAPE**: Para pagos por Yape
   - **EFECTIVO**: Para pagos en efectivo
   - **TARJETA**: Para pagos con tarjeta
3. Presiona **"Confirmar Venta"**
4. Verás un mensaje de confirmación
5. El carrito se vaciará automáticamente para la siguiente venta

### 5. Trabajar Sin Internet

La aplicación funciona completamente sin conexión a internet:

- Puedes realizar ventas normalmente
- Puedes crear nuevos productos
- Los datos se guardan localmente
- Cuando recuperes la conexión, todo se sincronizará automáticamente con el servidor

## Para Administradores: Funciones Adicionales

Los administradores tienen acceso a todas las funciones de los empleados, más las siguientes:

### 1. Navegación

En la parte inferior de la pantalla, verás dos pestañas:

- **Ventas**: Modo de venta (igual que los empleados)
- **Reportes**: Panel de reportes de cierre de caja

### 2. Panel de Reportes

Al seleccionar la pestaña **"Reportes"**, verás:

#### Resumen del Día

- **Ventas Totales del Día**: Suma total de todas las ventas en soles
- **Transacciones**: Número total de ventas realizadas

#### Desglose por Método de Pago

Verás tres tarjetas mostrando cuánto se vendió con cada método:

- **Efectivo**: Total en efectivo
- **Yape**: Total por Yape
- **Tarjeta**: Total por tarjeta

#### Productos Vendidos

Una lista de todos los productos vendidos en el día, mostrando:

- Nombre del producto
- Cantidad de unidades vendidas

### 3. Sincronización

Si hay ventas pendientes de sincronizar (porque se realizaron sin internet), verás:

- Un indicador naranja que dice **"Hay ventas pendientes de sincronizar"**
- Un botón **"Sincronizar"** para forzar la sincronización inmediata

### 4. Actualizar Reportes

- Desliza hacia abajo en la pantalla de reportes para actualizar los datos
- O presiona el ícono de **actualizar** en la parte superior derecha

## Consejos y Mejores Prácticas

### Para Ventas Rápidas

1. **Mantén la cámara enfocada**: Asegúrate de que el código de barras esté bien iluminado y enfocado
2. **Escanea de uno en uno**: Espera a que el producto se agregue antes de escanear el siguiente
3. **Verifica el total**: Antes de cobrar, confirma que el total sea correcto
4. **Usa el alta rápida**: No pierdas tiempo buscando productos en el sistema, créalos al instante

### Para Administradores

1. **Revisa el reporte diariamente**: Al final del día, verifica el cierre de caja
2. **Sincroniza regularmente**: Si trabajas sin internet, sincroniza cuando recuperes la conexión
3. **Cambia las contraseñas**: Por seguridad, cambia las contraseñas de prueba en producción
4. **Capacita a tu equipo**: Asegúrate de que todos los empleados sepan usar el alta rápida

## Solución de Problemas

### El escáner no funciona

- Verifica que hayas dado permisos de cámara a la aplicación
- Asegúrate de que haya buena iluminación
- Limpia la lente de la cámara

### No puedo iniciar sesión

- Verifica que el email y la contraseña sean correctos
- Asegúrate de tener conexión a internet para el primer inicio de sesión
- Contacta al administrador si olvidaste tu contraseña

### Las ventas no se sincronizan

- Verifica que tengas conexión a internet
- Presiona el botón "Sincronizar" en el panel de reportes
- Si el problema persiste, cierra y vuelve a abrir la aplicación

### El total no se actualiza

- Verifica que los productos se hayan agregado correctamente al carrito
- Si el problema persiste, elimina el producto y vuelve a escanearlo

## Soporte

Si tienes problemas que no puedes resolver con esta guía, contacta al administrador del sistema o al equipo de soporte técnico.

---
*Guía de usuario generada por Manus AI.*

