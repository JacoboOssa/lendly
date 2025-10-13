# Pantallas Implementadas - Lendly App

## 📱 Pantallas Creadas

### 1. Pantalla de Login (`/login`)
- **Ubicación**: `lib/features/auth/presentation/screens/login_screen.dart`
- **Características**:
  - Diseño exacto basado en Figma
  - Campo de email con placeholder "Correo electronico"
  - Campo de contraseña con placeholder "Contraseña" (agregado según solicitud)
  - Botón "Continuar" con navegación a profile
  - Link "¿No tienes cuenta aun? Crea una"
  - Botones de redes sociales (Apple, Google, Facebook)
  - Colores exactos del diseño: fondo gris oscuro (#2C2C2C), card blanco, campos beige (#F5F5F5)

### 2. Pantalla de Profile (`/profile`)
- **Ubicación**: `lib/features/profile/presentation/screens/profile_screen.dart`
- **Características**:
  - Diseño exacto basado en Figma
  - Avatar circular con fondo púrpura
  - Información del usuario (nombre y email)
  - Menú con opciones: Información personal, Configuración, Mensajes (duplicado)
  - Botón "Cerrar sesion" con fondo púrpura
  - Botón de regreso funcional
  - Colores exactos del diseño: fondo gris oscuro, card off-white (#FAFAFA)

## 🔧 Datos Quemados para Testing

### Usuario de Prueba
- **Nombre**: Marcelo Software
- **Email**: bimalstha291@gmail.com
- **Avatar**: Icono de persona con fondo púrpura

### Credenciales de Login (para testing)
- **Email**: test@lendly.com
- **Contraseña**: password123

### Archivo de Datos Mock
- **Ubicación**: `lib/features/profile/data/mock_data.dart`
- Contiene todos los datos quemados para testing
- Fácil de modificar para cambiar información de prueba

## 🚀 Cómo Ejecutar

1. **Ejecutar la aplicación**:
   ```bash
   flutter run
   ```

2. **Navegación**:
   - La app inicia en la pantalla de login (`/login`)
   - Al presionar "Continuar" navega a la pantalla de profile (`/profile`)
   - Desde profile se puede regresar con el botón de flecha

3. **Testing**:
   - Usa cualquier email/contraseña en login (no hay validación real)
   - Los datos del usuario se muestran automáticamente en profile

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
│   └── profile/
│       ├── data/
│       │   └── mock_data.dart
│       └── presentation/
│           └── screens/
│               └── profile_screen.dart
└── main.dart (actualizado con rutas)
```

## ✅ Funcionalidades Implementadas

- [x] Diseño exacto según Figma
- [x] Campo de contraseña agregado en login
- [x] Navegación entre pantallas
- [x] Datos quemados para testing
- [x] Colores exactos del diseño
- [x] Responsive design
- [x] Botones funcionales (con prints para debugging)
- [x] Estructura de carpetas organizada

## 🔄 Próximos Pasos Sugeridos

1. Implementar validación de formularios
2. Conectar con Supabase para autenticación real
3. Agregar animaciones de transición
4. Implementar funcionalidad de las opciones del menú
5. Agregar manejo de estados con BLoC
6. Implementar logout real
