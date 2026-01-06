# PetAdopt - Guía de Configuración

## 🚀 Pasos para hacer funcionar la aplicación

### 1. Configuración de Supabase

#### A. Crear Proyecto en Supabase
1. Ve a [supabase.com](https://supabase.com)
2. Crea un nuevo proyecto
3. Anota la **URL del Proyecto** y la **Anon Key**

#### B. Ejecutar Script de Base de Datos
1. En tu proyecto de Supabase, ve a **SQL Editor**
2. Copia y pega todo el contenido del archivo `supabase_schema.sql` (el que me diste)
3. Ejecuta el script completo
4. Verifica que se crearon todas las tablas

#### C. Crear Usuario de Prueba
1. Ve a **Authentication** → **Add User**
2. Crea un usuario con:
   - Email: `shelter@test.com`
   - Password: `123456`
   - User Metadata: 
     ```json
     {
       "full_name": "Refugio Patitas Felices",
       "user_type": "shelter"
     }
     ```
3. Anota el **UUID** del usuario creado

#### D. Insertar Datos de Prueba
1. Abre el archivo `supabase_test_data.sql`
2. Reemplaza los UUIDs de ejemplo con el UUID de tu usuario
3. Ejecuta el script en SQL Editor
4. Verifica que se crearon los refugios y mascotas

### 2. Configuración de la Aplicación

#### A. Archivo .env
Crea/edita el archivo `.env` en la raíz del proyecto:

```env
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-anon-key-aqui
GEMINI_API_KEY=tu-api-key-de-gemini (opcional)
```

#### B. Instalar Dependencias
```bash
flutter pub get
```

#### C. Ejecutar la Aplicación
```bash
# Web
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios
```

### 3. Probar la Aplicación

1. **Login**: Ingresa con `shelter@test.com` / `123456`
2. **Ver Mascotas**: Ve a la pestaña "Mascotas" para ver las mascotas de prueba
3. **Filtrar**: Usa el botón de filtros para buscar por especie/tamaño
4. **Ver Detalle**: Toca una mascota para ver su detalle completo

## 📁 Estructura del Proyecto

```
lib/
├── config/
│   └── dependency_injection/
│       └── injection_container.dart    # Inyección de dependencias
├── core/
│   ├── constants/
│   │   └── api_constants.dart         # Configuración de Supabase
│   ├── error/
│   │   └── failures.dart              # Manejo de errores
│   └── usecases/
│       └── usecase.dart               # Casos de uso base
├── features/
│   ├── auth/                          # Autenticación
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── pets/                          # Mascotas
│   │   ├── data/
│   │   │   ├── models/
│   │   │   │   └── pet_model.dart    # Modelo con fromJson/toJson
│   │   │   └── repositories/
│   │   │       └── pet_repository_impl.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   │   └── pet.dart          # Entidad Pet
│   │   │   ├── repositories/
│   │   │   │   └── pet_repository.dart
│   │   │   └── usecases/
│   │   │       ├── get_all_pets.dart
│   │   │       └── search_pets.dart
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   ├── pets_bloc.dart
│   │       │   ├── pets_event.dart
│   │       │   └── pets_state.dart
│   │       └── pages/
│   │           └── pets_list_page.dart
│   ├── profile/                       # Perfil de usuario
│   └── ...
└── main.dart                          # Entry point con BLoCs
```

## 🔧 Funcionalidades Implementadas

### ✅ Completado
- [x] Entidades de dominio (Pet, Shelter, UserProfile)
- [x] Modelos de datos con mapeo a Supabase
- [x] Repositorios con integración a Supabase
- [x] BLoC para gestión de estado de mascotas
- [x] Pantalla de lista de mascotas funcional
- [x] Filtros de búsqueda (especie, tamaño, ciudad)
- [x] Carga de datos desde Supabase
- [x] Refresh de datos (pull to refresh)
- [x] Caché de imágenes con CachedNetworkImage

### ⏳ Pendiente
- [ ] Pantalla de detalle de mascota
- [ ] Pantalla para crear/editar mascota
- [ ] Sistema de solicitudes de adopción
- [ ] Chat AI con Gemini
- [ ] Mapa con ubicación de refugios
- [ ] Subida de imágenes a Supabase Storage
- [ ] Sistema de favoritos

## 🐛 Solución de Problemas Comunes

### Error: "Couldn't find constructor 'ProfilePage'"
**Solución**: Los imports ya están agregados en `main.dart` y `home_page.dart`

### Error: "RLS policy violation"
**Solución**: Verifica que ejecutaste todo el script SQL incluyendo la sección de permisos al final

### Error: "No data found"
**Solución**: 
1. Verifica que creaste el usuario en Authentication
2. Ejecuta el script de datos de prueba con el UUID correcto
3. Revisa que el usuario tenga `user_type = 'shelter'` en su metadata

### Las imágenes no cargan
**Solución**: 
1. Usa URLs públicas de Unsplash (ejemplo en el SQL)
2. O sube tus propias imágenes a Supabase Storage:
   - Crea un bucket llamado `pet-images`
   - Hazlo público
   - Sube las imágenes
   - Usa las URLs generadas

## 📞 Contacto y Soporte

Si tienes problemas:
1. Revisa los logs en la consola
2. Verifica que Supabase esté configurado correctamente
3. Asegúrate de que el archivo `.env` tenga las credenciales correctas

## 🎯 Próximos Pasos

1. **Detalle de Mascota**: Implementar pantalla con toda la información
2. **Crear Mascota**: Formulario para refugios con subida de imágenes
3. **Adopciones**: Sistema completo de solicitudes
4. **Mapa**: Mostrar refugios cercanos usando geolocalización
5. **Chat AI**: Asistente virtual para ayudar en adopciones

¡Listo! Tu aplicación debería funcionar perfectamente con estos pasos. 🚀
