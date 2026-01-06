-- =================================================
-- DATOS DE PRUEBA PARA PETADOPT
-- =================================================
-- Ejecutar después de crear la base de datos
-- Asegúrate de tener usuarios creados en Authentication primero
-- =================================================

-- 1. Insertar perfiles de prueba (reemplaza los UUIDs con los de tus usuarios reales)
-- Obtén los UUIDs desde: Dashboard → Authentication → Users

-- Ejemplo: Si tienes un usuario con email shelter@test.com
-- INSERT INTO profiles (id, email, full_name, user_type, phone)
-- VALUES (
--   'REEMPLAZAR-CON-UUID-REAL',
--   'shelter@test.com',
--   'Refugio Patitas Felices',
--   'shelter',
--   '+593991234567'
-- );

-- 2. Insertar refugio de prueba
-- INSERT INTO shelters (profile_id, shelter_name, description, address, city, country, latitude, longitude, phone, website)
-- VALUES (
--   'REEMPLAZAR-CON-PROFILE-ID',
--   'Refugio Patitas Felices',
--   'Refugio dedicado al rescate y adopción de perros y gatos en Quito',
--   'Av. 6 de Diciembre N34-123',
--   'Quito',
--   'Ecuador',
--   -0.180653,
--   -78.467838,
--   '+593991234567',
--   'https://patitasfelices.com'
-- );

-- 3. Insertar mascotas de prueba
-- Reemplaza SHELTER-ID con el ID del refugio creado arriba

-- INSERT INTO pets (
--   shelter_id, name, species, breed, age_years, age_months, gender, size,
--   description, personality_traits, main_image_url, images_urls,
--   is_vaccinated, is_dewormed, is_sterilized, has_microchip
-- ) VALUES
-- (
--   'SHELTER-ID',
--   'Max',
--   'dog',
--   'Labrador Retriever',
--   3,
--   6,
--   'male',
--   'large',
--   'Max es un perro muy cariñoso y juguetón. Le encanta correr y jugar con niños. Es perfecto para familias activas.',
--   ARRAY['Juguetón', 'Cariñoso', 'Activo', 'Obediente'],
--   'https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=500',
--   ARRAY[
--     'https://images.unsplash.com/photo-1587300003388-59208cc962cb?w=500',
--     'https://images.unsplash.com/photo-1558788353-f76d92427f16?w=500'
--   ],
--   true,
--   true,
--   true,
--   true
-- ),
-- (
--   'SHELTER-ID',
--   'Luna',
--   'cat',
--   'Persa',
--   2,
--   0,
--   'female',
--   'small',
--   'Luna es una gatita tranquila y elegante. Le gusta dormir y recibir mimos. Ideal para apartamentos.',
--   ARRAY['Tranquila', 'Cariñosa', 'Independiente'],
--   'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=500',
--   ARRAY[
--     'https://images.unsplash.com/photo-1574158622682-e40e69881006?w=500',
--     'https://images.unsplash.com/photo-1615789591457-74a63395c990?w=500'
--   ],
--   true,
--   true,
--   true,
--   false
-- ),
-- (
--   'SHELTER-ID',
--   'Rocky',
--   'dog',
--   'Pastor Alemán',
--   5,
--   0,
--   'male',
--   'large',
--   'Rocky es un perro guardián leal y protector. Necesita dueños experimentados y espacio para ejercitarse.',
--   ARRAY['Leal', 'Protector', 'Inteligente', 'Obediente'],
--   'https://images.unsplash.com/photo-1568572933382-74d440642117?w=500',
--   ARRAY[
--     'https://images.unsplash.com/photo-1568572933382-74d440642117?w=500',
--     'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?w=500'
--   ],
--   true,
--   true,
--   false,
--   true
-- ),
-- (
--   'SHELTER-ID',
--   'Mimi',
--   'cat',
--   'Siamés',
--   1,
--   8,
--   'female',
--   'small',
--   'Mimi es una gatita muy vocal y sociable. Le encanta la compañía humana y seguir a su dueño por todos lados.',
--   ARRAY['Sociable', 'Vocal', 'Juguetona', 'Curiosa'],
--   'https://images.unsplash.com/photo-1513360371669-4adf3dd7dff8?w=500',
--   ARRAY[
--     'https://images.unsplash.com/photo-1513360371669-4adf3dd7dff8?w=500'
--   ],
--   true,
--   true,
--   true,
--   false
-- ),
-- (
--   'SHELTER-ID',
--   'Toby',
--   'dog',
--   'Beagle',
--   4,
--   3,
--   'male',
--   'medium',
--   'Toby es un perro muy alegre y curioso. Le encanta seguir rastros y explorar. Perfecto para aventureros.',
--   ARRAY['Curioso', 'Alegre', 'Activo', 'Amigable'],
--   'https://images.unsplash.com/photo-1505628346881-b72b27e84530?w=500',
--   ARRAY[
--     'https://images.unsplash.com/photo-1505628346881-b72b27e84530?w=500',
--     'https://images.unsplash.com/photo-1543466835-00a7907e9de1?w=500'
--   ],
--   true,
--   true,
--   true,
--   true
-- );

-- =================================================
-- GUÍA PARA USAR IMÁGENES PROPIAS:
-- =================================================
-- 1. Ve a https://unsplash.com y busca "dog" o "cat"
-- 2. Copia la URL de la imagen que te guste
-- 3. Agrega ?w=800 al final para optimizar el tamaño
-- 
-- O mejor aún:
-- 1. Sube tus propias imágenes a Supabase Storage
-- 2. Crea un bucket llamado "pet-images"
-- 3. Haz el bucket público
-- 4. Sube las imágenes y usa las URLs generadas
-- =================================================

-- Verificar los datos insertados
SELECT 
    p.name,
    p.species,
    p.breed,
    p.age_years,
    p.adoption_status,
    s.shelter_name,
    s.city
FROM pets p
JOIN shelters s ON p.shelter_id = s.id
ORDER BY p.created_at DESC;
