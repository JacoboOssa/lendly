# Pantallas Implementadas - Lendly App

## � Flujos de Usuario por Rol

### 👤 Flujo de Arrendador
1. **Inicio de sesión** como arrendador
2. **Home Page** - Visualiza productos disponibles en la plataforma
3. **Publicar Producto** - Puede agregar nuevos productos propios
4. **Mis Productos** - Ve la lista de productos que ha publicado
5. **Editar/Eliminar** - Gestiona sus publicaciones existentes
6. **Gestionar Disponibilidad** - Cambia el estado de sus productos (disponible/no disponible)

### 🏠 Flujo de Arrendatario
1. **Inicio de sesión** como arrendatario
2. **Home Page** - Explora productos disponibles para alquilar
3. **Ver Detalle** - Al presionar un producto, accede a información completa (fotos, ubicación, reseñas)
4. **Evaluar producto** - Decide si le conviene alquilar el producto

## �📱 Pantallas Creadas

### Sprint Anterior

#### 1. Pantalla de Login (`/login`)
- **Ubicación**: `lib/features/auth/presentation/screens/login_screen.dart`
- **Características**:
  - Diseño exacto basado en Figma
  - Campo de email con placeholder "Correo electronico"
  - Campo de contraseña con placeholder "Contraseña" (agregado según solicitud)
  - Botón "Continuar" con navegación a profile
  - Link "¿No tienes cuenta aun? Crea una"
  - Botones de redes sociales (Apple, Google, Facebook)
  - Colores exactos del diseño: fondo gris oscuro (#2C2C2C), card blanco, campos beige (#F5F5F5)

#### 2. Pantalla de Profile (`/profile`)
- **Ubicación**: `lib/features/profile/presentation/screens/profile_screen.dart`
- **Características**:
  - Diseño exacto basado en Figma
  - Avatar circular con fondo púrpura
  - Información del usuario (nombre y email)
  - Menú con opciones: Información personal, Configuración, Mensajes (duplicado)
  - Botón "Cerrar sesion" con fondo púrpura
  - Botón de regreso funcional
  - Colores exactos del diseño: fondo gris oscuro, card off-white (#FAFAFA)

### Sprint Actual

#### 3. Pantalla Publicar Producto - F1 (`/publish`) - ROL: ARRENDADOR
- **Ubicación**: `lib/features/publish/presentation/screens/publish_product_screen.dart`
- **Características**:
  - Formulario completo para crear nueva publicación
  - Campos requeridos:
    - Nombre del producto
    - Descripción detallada
    - Fotos del producto (subida de imágenes)
    - Precio de alquiler
    - Categoría del producto
    - Estado de disponibilidad
  - Botón "Publicar" para confirmar
  - Objetivo: Poner un producto a disposición de otros usuarios
  - Resultado: Creación de nueva publicación con estado "disponible"
  - Diseño adaptado al estilo visual de Lendly

#### 4. Pantalla Editar/Eliminar Publicación - F2 (`/my-products`) - ROL: ARRENDADOR
- **Ubicación**: `lib/features/product/presentation/screens/my_products_screen.dart`
- **Características**:
  - Lista de productos publicados por el arrendador
  - Opciones para cada producto:
    - Editar detalles (nombre, descripción, precio, etc.)
    - Eliminar publicación
  - Objetivo: Mantener actualizada la información de los productos o retirarlos del catálogo
  - Resultado: Modificación o eliminación del registro en base de datos
  - Interfaz intuitiva con acciones claras

#### 5. Pantalla Gestionar Disponibilidad - F3 - ROL: ARRENDADOR
- **Ubicación**: `lib/features/product/presentation/screens/manage_availability_screen.dart`
- **Características**:
  - Toggle o switch para cambiar estado del producto
  - Estados: "disponible" / "no disponible"
  - Objetivo: Controlar cuándo el producto puede ser alquilado
  - Resultado: Actualización del estado del producto
  - Efecto: Modifica la visibilidad en búsquedas
  - Feedback visual inmediato del cambio de estado

#### 6. Pantalla Ver Detalle del Producto - F5 (`/product/:id`) - ROL: ARRENDATARIO
- **Ubicación**: `lib/features/product/presentation/screens/product_detail_screen.dart`
- **Características**:
  - Vista completa del producto seleccionado
  - Información mostrada:
    - Galería de fotos del producto
    - Nombre y descripción completa
    - Precio de alquiler
    - Ubicación del producto
    - Reseñas y calificaciones de otros usuarios
    - Estado de disponibilidad
  - Objetivo: Evaluar si el producto conviene antes de alquilarlo
  - Resultado: Vista detallada que facilita la decisión de solicitud
  - Botón para solicitar alquiler (próxima funcionalidad)

## 🔧 Datos Quemados para Testing

### Usuario 1 - ROL: ARRENDADOR (Propietario)
- **Email**: propietario@gmail.com
- **Contraseña**: 12345678
- **Permisos**: 
  - Ver productos en home
  - Publicar productos
  - Editar/eliminar sus productos
  - Gestionar disponibilidad

### Usuario 2 - ROL: ARRENDATARIO (Alquilador)
- **Email**: alquilador@gmail.com
- **Contraseña**: 12345678
- **Permisos**: 
  - Ver productos en home
  - Ver detalle de productos
  - Solicitar alquiler (próximamente)

### Archivo de Datos Mock
- **Ubicación**: `lib/features/profile/data/mock_data.dart`
- Contiene todos los datos quemados para testing
- Fácil de modificar para cambiar información de prueba
- Incluye productos de ejemplo para ambos roles

## 🚀 Cómo Ejecutar

1. **Ejecutar la aplicación**:
   ```bash
   flutter run
   ```

2. **Navegación por Roles**:
   - La app inicia en la pantalla de login (`/login`)
   - **Para probar como ARRENDADOR**: 
     - Email: `propietario@gmail.com`
     - Contraseña: `12345678`
     - Acceso a: Home, Publicar producto, Mis productos, Gestionar disponibilidad
   - **Para probar como ARRENDATARIO**: 
     - Email: `alquilador@gmail.com`
     - Contraseña: `12345678`
     - Acceso a: Home, Ver detalle de productos

3. **Testing**:
   - Usa las credenciales específicas según el rol que quieras probar
   - Los flujos varían según el tipo de usuario autenticado
   - La navegación se adapta automáticamente al rol del usuario

## 🎨 Colores Utilizados

- **Fondo principal**: #2C2C2C (gris oscuro)
- **Card principal**: #FFFFFF (blanco) / #FAFAFA (off-white)
- **Campos de entrada**: #F5F5F5 (beige claro)
- **Texto principal**: #2C2C2C (gris oscuro)
- **Texto secundario**: #9E9E9E (gris claro)
- **Botón de login**: #98A1BC (azul grisáceo)
- **Botón cerrar sesión**: #555879 (púrpura oscuro)
- **Avatar**: #9C88FF (púrpura claro)

## 📁 Estructura de Archivos

```
lib/
├── features/
│   ├── auth/
│   │   └── presentation/
│   │       └── screens/
│   │           └── login_screen.dart
│   ├── profile/
│   │   ├── data/
│   │   │   └── mock_data.dart
│   │   └── presentation/
│   │       └── screens/
│   │           └── profile_screen.dart
│   ├── publish/
│   │   └── presentation/
│   │       └── screens/
│   │           └── publish_product_screen.dart (F1 - Arrendador)
│   ├── product/
│   │   └── presentation/
│   │       └── screens/
│   │           ├── my_products_screen.dart (F2 - Arrendador)
│   │           ├── manage_availability_screen.dart (F3 - Arrendador)
│   │           └── product_detail_screen.dart (F5 - Arrendatario)
│   └── home/
│       └── presentation/
│           └── screens/
│               └── home_screen.dart (Común para ambos roles)
└── main.dart (actualizado con rutas y navegación por roles)
```

## ✅ Funcionalidades Implementadas

### Sprint Anterior
- [x] Diseño exacto según Figma
- [x] Campo de contraseña agregado en login
- [x] Navegación entre pantallas
- [x] Datos quemados para testing
- [x] Colores exactos del diseño
- [x] Responsive design
- [x] Botones funcionales (con prints para debugging)
- [x] Estructura de carpetas organizada

### Sprint Actual
- [x] **F1 - Publicar Producto**: Formulario completo con campos para nombre, descripción, fotos, precio, categoría y disponibilidad
- [x] **F2 - Editar/Eliminar Publicación**: Gestión de productos existentes del arrendador
- [x] **F3 - Gestionar Disponibilidad**: Toggle para cambiar estado disponible/no disponible
- [x] **F5 - Ver Detalle del Producto**: Vista completa con fotos, información, ubicación y reseñas
- [x] Flujo diferenciado por roles (Arrendador vs Arrendatario)
- [x] Navegación contextual según tipo de usuario

## 📊 Diferenciación por Roles

### Arrendador puede:
- ✅ Ver productos en el home
- ✅ Publicar nuevos productos
- ✅ Ver lista de sus productos
- ✅ Editar información de sus productos
- ✅ Eliminar productos
- ✅ Gestionar disponibilidad de sus productos

### Arrendatario puede:
- ✅ Ver productos disponibles en el home
- ✅ Ver detalle completo de productos
- ✅ Evaluar productos antes de alquilar
- ⏳ Solicitar alquiler (próxima funcionalidad)

## 🔄 Próximos Pasos Sugeridos

1. Implementar sistema de solicitudes de alquiler
2. Conectar con Supabase para persistencia real de productos
3. Agregar sistema de notificaciones
4. Implementar chat entre arrendador y arrendatario
5. Sistema de calificaciones y reseñas
6. Validación de formularios en publicación
7. Gestión de favoritos para arrendatarios
8. Historial de transacciones
9. Sistema de pagos integrado
10. Filtros y búsqueda avanzada de productos
