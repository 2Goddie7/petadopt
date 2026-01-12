-- ============================================
-- PETADOPT - SETUP COMPLETO UNIFICADO
-- ============================================
-- Orden de ejecución:
-- 1. Extensiones
-- 2. Tipos ENUM
-- 3. Tablas base
-- 4. Índices
-- 5. RLS
-- 6. Funciones
-- 7. Triggers
-- 8. Vistas
-- ============================================

-- ============================================
-- 1️⃣ LIMPIAR (Opcional - descomenta si necesitas reset)
-- ============================================
/*
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users CASCADE;
DROP TRIGGER IF EXISTS on_profile_created ON public.profiles CASCADE;
DROP TRIGGER IF EXISTS on_profile_updated ON public.profiles CASCADE;
DROP TRIGGER IF EXISTS update_shelters_timestamp ON public.shelters CASCADE;
DROP TRIGGER IF EXISTS update_pets_timestamp ON public.pets CASCADE;
DROP TRIGGER IF EXISTS on_adoption_request_created ON public.adoption_requests CASCADE;

DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;
DROP FUNCTION IF EXISTS public.handle_new_profile() CASCADE;
DROP FUNCTION IF EXISTS public.handle_profile_update() CASCADE;
DROP FUNCTION IF EXISTS public.update_updated_at_column() CASCADE;

DROP VIEW IF EXISTS public.pets_with_shelter_info CASCADE;
DROP VIEW IF EXISTS public.adoption_requests_with_details CASCADE;
DROP VIEW IF EXISTS public.favorites_with_pet_info CASCADE;

DROP TABLE IF EXISTS public.chat_history CASCADE;
DROP TABLE IF EXISTS public.favorites CASCADE;
DROP TABLE IF EXISTS public.adoption_requests CASCADE;
DROP TABLE IF EXISTS public.pets CASCADE;
DROP TABLE IF EXISTS public.shelters CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;

DROP TYPE IF EXISTS public.user_type CASCADE;
DROP TYPE IF EXISTS public.pet_species CASCADE;
DROP TYPE IF EXISTS public.pet_gender CASCADE;
DROP TYPE IF EXISTS public.pet_size CASCADE;
DROP TYPE IF EXISTS public.adoption_status CASCADE;
DROP TYPE IF EXISTS public.request_status CASCADE;
*/

-- ============================================
-- 2️⃣ EXTENSIONES
-- ============================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================
-- 3️⃣ TIPOS ENUM
-- ============================================
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'user_type') THEN
    CREATE TYPE public.user_type AS ENUM ('adopter', 'shelter');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'pet_species') THEN
    CREATE TYPE public.pet_species AS ENUM ('dog', 'cat', 'other');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'pet_gender') THEN
    CREATE TYPE public.pet_gender AS ENUM ('male', 'female');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'pet_size') THEN
    CREATE TYPE public.pet_size AS ENUM ('small', 'medium', 'large');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'adoption_status') THEN
    CREATE TYPE public.adoption_status AS ENUM ('available', 'pending', 'adopted');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'request_status') THEN
    CREATE TYPE public.request_status AS ENUM ('pending', 'approved', 'rejected', 'cancelled');
  END IF;
END$$;

-- ============================================
-- 4️⃣ TABLAS
-- ============================================

-- TABLA 1: PROFILES (Usuarios)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL UNIQUE,
  full_name TEXT NOT NULL,
  user_type public.user_type NOT NULL DEFAULT 'adopter',
  phone TEXT,
  avatar_url TEXT,
  bio TEXT,
  location TEXT,
  latitude DECIMAL(10,8),
  longitude DECIMAL(11,8),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- TABLA 2: SHELTERS (Refugios)
CREATE TABLE IF NOT EXISTS public.shelters (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id UUID NOT NULL UNIQUE REFERENCES public.profiles(id) ON DELETE CASCADE,
  shelter_name TEXT NOT NULL,
  description TEXT,
  address TEXT NOT NULL,
  city TEXT NOT NULL DEFAULT 'Quito',
  country TEXT NOT NULL DEFAULT 'Ecuador',
  latitude DECIMAL(10,8) NOT NULL,
  longitude DECIMAL(11,8) NOT NULL,
  phone TEXT,
  website TEXT,
  total_pets INTEGER DEFAULT 0,
  total_adoptions INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- TABLA 3: PETS (Mascotas)
CREATE TABLE IF NOT EXISTS public.pets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  shelter_id UUID NOT NULL REFERENCES public.shelters(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  species TEXT NOT NULL,
  breed TEXT NOT NULL,
  age_years INTEGER NOT NULL DEFAULT 0,
  age_months INTEGER NOT NULL DEFAULT 0,
  gender TEXT NOT NULL,
  size TEXT NOT NULL,
  description TEXT NOT NULL,
  personality_traits TEXT[] DEFAULT '{}',
  pet_images JSONB DEFAULT '[]'::jsonb,
  is_vaccinated BOOLEAN DEFAULT FALSE,
  is_dewormed BOOLEAN DEFAULT FALSE,
  is_sterilized BOOLEAN DEFAULT FALSE,
  has_microchip BOOLEAN DEFAULT FALSE,
  needs_special_care BOOLEAN DEFAULT FALSE,
  health_notes TEXT,
  adoption_status TEXT NOT NULL DEFAULT 'available',
  views_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- TABLA 4: ADOPTION_REQUESTS (Solicitudes de Adopción)
CREATE TABLE IF NOT EXISTS public.adoption_requests (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pet_id UUID NOT NULL REFERENCES public.pets(id) ON DELETE CASCADE,
  adopter_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  shelter_id UUID NOT NULL REFERENCES public.shelters(id) ON DELETE CASCADE,
  message TEXT,
  status TEXT NOT NULL DEFAULT 'pending',
  rejection_reason TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  reviewed_at TIMESTAMPTZ,
  UNIQUE(pet_id, adopter_id)
);

-- TABLA 5: FAVORITES (Favoritos)
CREATE TABLE IF NOT EXISTS public.favorites (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  pet_id UUID NOT NULL REFERENCES public.pets(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(user_id, pet_id)
);

-- TABLA 6: CHAT_HISTORY (Historial de Chat)
CREATE TABLE IF NOT EXISTS public.chat_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
  message TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- 5️⃣ ÍNDICES
-- ============================================
CREATE INDEX IF NOT EXISTS idx_profiles_user_type ON public.profiles(user_type);
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);
CREATE INDEX IF NOT EXISTS idx_shelters_profile_id ON public.shelters(profile_id);
CREATE INDEX IF NOT EXISTS idx_shelters_city ON public.shelters(city);
CREATE INDEX IF NOT EXISTS idx_shelters_latitude_longitude ON public.shelters(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_pets_shelter_id ON public.pets(shelter_id);
CREATE INDEX IF NOT EXISTS idx_pets_species ON public.pets(species);
CREATE INDEX IF NOT EXISTS idx_pets_adoption_status ON public.pets(adoption_status);
CREATE INDEX IF NOT EXISTS idx_adoption_requests_pet_id ON public.adoption_requests(pet_id);
CREATE INDEX IF NOT EXISTS idx_adoption_requests_adopter_id ON public.adoption_requests(adopter_id);
CREATE INDEX IF NOT EXISTS idx_adoption_requests_shelter_id ON public.adoption_requests(shelter_id);
CREATE INDEX IF NOT EXISTS idx_adoption_requests_status ON public.adoption_requests(status);
CREATE INDEX IF NOT EXISTS idx_favorites_user_id ON public.favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_favorites_pet_id ON public.favorites(pet_id);
CREATE INDEX IF NOT EXISTS idx_chat_history_user_id ON public.chat_history(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_history_created_at ON public.chat_history(created_at);

-- ============================================
-- 6️⃣ ROW LEVEL SECURITY (RLS)
-- ============================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shelters ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.adoption_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_history ENABLE ROW LEVEL SECURITY;

-- POLICIES - PROFILES
DROP POLICY IF EXISTS "Public can view profiles" ON public.profiles;
CREATE POLICY "Public can view profiles" 
  ON public.profiles FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users update own profile" ON public.profiles;
CREATE POLICY "Users update own profile" 
  ON public.profiles FOR UPDATE USING (auth.uid() = id);

DROP POLICY IF EXISTS "Users insert own profile" ON public.profiles;
CREATE POLICY "Users insert own profile" 
  ON public.profiles FOR INSERT WITH CHECK (auth.uid() = id);

-- POLICIES - SHELTERS
DROP POLICY IF EXISTS "Public view shelters" ON public.shelters;
CREATE POLICY "Public view shelters" 
  ON public.shelters FOR SELECT USING (true);

DROP POLICY IF EXISTS "Create own shelter" ON public.shelters;
CREATE POLICY "Create own shelter" 
  ON public.shelters FOR INSERT WITH CHECK (auth.uid() = profile_id);

DROP POLICY IF EXISTS "Update own shelter" ON public.shelters;
CREATE POLICY "Update own shelter" 
  ON public.shelters FOR UPDATE USING (auth.uid() = profile_id);

-- POLICIES - PETS
DROP POLICY IF EXISTS "Public view pets" ON public.pets;
CREATE POLICY "Public view pets" 
  ON public.pets FOR SELECT USING (true);

DROP POLICY IF EXISTS "Shelters insert pets" ON public.pets;
CREATE POLICY "Shelters insert pets" 
  ON public.pets FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM public.shelters 
      WHERE shelters.profile_id = auth.uid() AND shelters.id = pets.shelter_id)
  );

DROP POLICY IF EXISTS "Shelters update pets" ON public.pets;
CREATE POLICY "Shelters update pets" 
  ON public.pets FOR UPDATE USING (
    EXISTS (SELECT 1 FROM public.shelters 
      WHERE shelters.profile_id = auth.uid() AND shelters.id = pets.shelter_id)
  );

DROP POLICY IF EXISTS "Shelters delete pets" ON public.pets;
CREATE POLICY "Shelters delete pets" 
  ON public.pets FOR DELETE USING (
    EXISTS (SELECT 1 FROM public.shelters 
      WHERE shelters.profile_id = auth.uid() AND shelters.id = pets.shelter_id)
  );

-- POLICIES - ADOPTION_REQUESTS
DROP POLICY IF EXISTS "View own adoption requests" ON public.adoption_requests;
CREATE POLICY "View own adoption requests" 
  ON public.adoption_requests FOR SELECT USING (
    auth.uid() = adopter_id OR 
    EXISTS (SELECT 1 FROM public.shelters 
      WHERE shelters.id = adoption_requests.shelter_id AND shelters.profile_id = auth.uid())
  );

DROP POLICY IF EXISTS "Adopters create requests" ON public.adoption_requests;
CREATE POLICY "Adopters create requests" 
  ON public.adoption_requests FOR INSERT WITH CHECK (auth.uid() = adopter_id);

DROP POLICY IF EXISTS "Shelters update requests" ON public.adoption_requests;
CREATE POLICY "Shelters update requests" 
  ON public.adoption_requests FOR UPDATE USING (
    EXISTS (SELECT 1 FROM public.shelters 
      WHERE shelters.id = adoption_requests.shelter_id AND shelters.profile_id = auth.uid())
  );

DROP POLICY IF EXISTS "Adopters delete requests" ON public.adoption_requests;
CREATE POLICY "Adopters delete requests" 
  ON public.adoption_requests FOR DELETE USING (auth.uid() = adopter_id AND status = 'pending');

-- POLICIES - FAVORITES
DROP POLICY IF EXISTS "Users view own favorites" ON public.favorites;
CREATE POLICY "Users view own favorites" 
  ON public.favorites FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users insert favorites" ON public.favorites;
CREATE POLICY "Users insert favorites" 
  ON public.favorites FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users delete favorites" ON public.favorites;
CREATE POLICY "Users delete favorites" 
  ON public.favorites FOR DELETE USING (auth.uid() = user_id);

-- POLICIES - CHAT_HISTORY
DROP POLICY IF EXISTS "Users view own chat" ON public.chat_history;
CREATE POLICY "Users view own chat" 
  ON public.chat_history FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users insert chat" ON public.chat_history;
CREATE POLICY "Users insert chat" 
  ON public.chat_history FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users delete chat" ON public.chat_history;
CREATE POLICY "Users delete chat" 
  ON public.chat_history FOR DELETE USING (auth.uid() = user_id);

-- ============================================
-- 7️⃣ FUNCIONES
-- ============================================

-- FUNCIÓN: Actualizar timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- FUNCIÓN: Crear perfil automáticamente
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
DECLARE
  user_type_value TEXT;
  full_name_value TEXT;
BEGIN
  user_type_value := COALESCE(NEW.raw_user_meta_data->>'user_type', 'adopter');
  full_name_value := COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email);
  
  INSERT INTO public.profiles (
    id, email, full_name, user_type, phone, location, latitude, longitude
  ) VALUES (
    NEW.id,
    NEW.email,
    full_name_value,
    user_type_value::public.user_type,
    NEW.raw_user_meta_data->>'phone',
    NEW.raw_user_meta_data->>'address',
    CASE WHEN NEW.raw_user_meta_data->>'latitude' IS NOT NULL 
      THEN (NEW.raw_user_meta_data->>'latitude')::DECIMAL(10,8) ELSE NULL END,
    CASE WHEN NEW.raw_user_meta_data->>'longitude' IS NOT NULL 
      THEN (NEW.raw_user_meta_data->>'longitude')::DECIMAL(11,8) ELSE NULL END
  );
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- FUNCIÓN: Crear shelter automáticamente para nuevo perfil
CREATE OR REPLACE FUNCTION public.handle_new_profile()
RETURNS TRIGGER AS $$
DECLARE
  v_location TEXT;
  v_latitude DECIMAL(10,8);
  v_longitude DECIMAL(11,8);
BEGIN
  IF NEW.user_type = 'shelter' THEN
    v_location := COALESCE(NEW.location, 'Dirección no especificada');
    v_latitude := COALESCE(NEW.latitude, -0.180653::DECIMAL(10,8));
    v_longitude := COALESCE(NEW.longitude, -78.467834::DECIMAL(11,8));
    
    INSERT INTO public.shelters (
      profile_id, shelter_name, address, city, country, latitude, longitude, phone
    ) VALUES (
      NEW.id, NEW.full_name, v_location, 'Quito', 'Ecuador', v_latitude, v_longitude, NEW.phone
    );
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- FUNCIÓN: Sincronizar actualizaciones de shelter con profile
CREATE OR REPLACE FUNCTION public.handle_profile_update()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.user_type = 'shelter' THEN
    UPDATE public.shelters SET
      shelter_name = NEW.full_name,
      address = COALESCE(NEW.location, address, 'Dirección no especificada'),
      latitude = COALESCE(NEW.latitude, latitude, -0.180653::DECIMAL(10,8)),
      longitude = COALESCE(NEW.longitude, longitude, -78.467834::DECIMAL(11,8)),
      phone = COALESCE(NEW.phone, phone),
      updated_at = NOW()
    WHERE profile_id = NEW.id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- FUNCIÓN: Manejar aprobación de solicitud de adopción
CREATE OR REPLACE FUNCTION public.handle_adoption_approval()
RETURNS TRIGGER AS $$
BEGIN
  -- Solo ejecutar cuando el status cambia a 'approved'
  IF NEW.status = 'approved' AND OLD.status != 'approved' THEN
    -- Cambiar el estado de la mascota a 'pending'
    UPDATE public.pets 
    SET adoption_status = 'pending', updated_at = NOW()
    WHERE id = NEW.pet_id;
    
    -- Rechazar automáticamente otras solicitudes pendientes para la misma mascota
    UPDATE public.adoption_requests
    SET status = 'rejected', 
        rejection_reason = 'La mascota ya tiene una solicitud aprobada',
        reviewed_at = NOW(),
        updated_at = NOW()
    WHERE pet_id = NEW.pet_id 
      AND id != NEW.id 
      AND status = 'pending';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- FUNCIÓN: Manejar cancelación/rechazo de solicitud
CREATE OR REPLACE FUNCTION public.handle_adoption_cancellation()
RETURNS TRIGGER AS $$
DECLARE
  v_has_pending BOOLEAN;
BEGIN
  -- Solo ejecutar cuando el status cambia a 'cancelled' o 'rejected'
  IF (NEW.status IN ('cancelled', 'rejected')) AND (OLD.status != NEW.status) THEN
    -- Verificar si hay otras solicitudes aprobadas para esta mascota
    SELECT EXISTS(
      SELECT 1 FROM public.adoption_requests
      WHERE pet_id = NEW.pet_id 
        AND id != NEW.id 
        AND status = 'approved'
    ) INTO v_has_pending;
    
    -- Si no hay solicitudes aprobadas, volver la mascota a 'available'
    IF NOT v_has_pending THEN
      UPDATE public.pets 
      SET adoption_status = 'available', updated_at = NOW()
      WHERE id = NEW.pet_id;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 8️⃣ TRIGGERS
-- ============================================
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created 
  AFTER INSERT ON auth.users FOR EACH ROW 
  EXECUTE FUNCTION public.handle_new_user();

DROP TRIGGER IF EXISTS on_profile_created ON public.profiles;
CREATE TRIGGER on_profile_created 
  AFTER INSERT ON public.profiles FOR EACH ROW 
  EXECUTE FUNCTION public.handle_new_profile();

DROP TRIGGER IF EXISTS on_profile_updated ON public.profiles;
CREATE TRIGGER on_profile_updated 
  AFTER UPDATE ON public.profiles FOR EACH ROW 
  EXECUTE FUNCTION public.handle_profile_update();

DROP TRIGGER IF EXISTS update_shelters_timestamp ON public.shelters;
CREATE TRIGGER update_shelters_timestamp
  BEFORE UPDATE ON public.shelters FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS update_pets_timestamp ON public.pets;
CREATE TRIGGER update_pets_timestamp
  BEFORE UPDATE ON public.pets FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

DROP TRIGGER IF EXISTS on_adoption_approved ON public.adoption_requests;
CREATE TRIGGER on_adoption_approved
  AFTER UPDATE ON public.adoption_requests FOR EACH ROW
  EXECUTE FUNCTION public.handle_adoption_approval();

DROP TRIGGER IF EXISTS on_adoption_cancelled ON public.adoption_requests;
CREATE TRIGGER on_adoption_cancelled
  AFTER UPDATE ON public.adoption_requests FOR EACH ROW
  EXECUTE FUNCTION public.handle_adoption_cancellation();

-- ============================================
-- 9️⃣ VISTAS
-- ============================================

-- VISTA 1: Mascotas con info del refugio
DROP VIEW IF EXISTS public.pets_with_shelter_info CASCADE;

CREATE VIEW public.pets_with_shelter_info AS
SELECT 
  p.id,
  p.name,
  p.species,
  p.breed,
  p.age_years,
  p.age_months,
  p.gender,
  p.size,
  p.pet_images,
  p.description,
  p.is_vaccinated,
  p.is_dewormed,
  p.is_sterilized,
  p.has_microchip,
  p.needs_special_care,
  p.health_notes,
  p.adoption_status,
  p.shelter_id,
  p.views_count,
  p.created_at,
  p.updated_at,
  s.shelter_name,
  s.city AS shelter_city,
  s.latitude AS shelter_latitude,
  s.longitude AS shelter_longitude,
  s.phone AS shelter_phone,
  pr.email AS shelter_email     -- ✅ AQUÍ
FROM public.pets p
LEFT JOIN public.shelters s ON p.shelter_id = s.id
LEFT JOIN public.profiles pr ON s.profile_id = pr.id;


GRANT SELECT ON public.pets_with_shelter_info TO authenticated;
GRANT SELECT ON public.pets_with_shelter_info TO anon;

-- VISTA 2: Solicitudes de adopción con detalles
DROP VIEW IF EXISTS public.adoption_requests_with_details CASCADE;
CREATE VIEW public.adoption_requests_with_details AS
SELECT 
  ar.id,
  ar.pet_id,
  ar.adopter_id,
  ar.shelter_id,
  ar.status,
  ar.message,
  ar.created_at,
  ar.updated_at,
  p.name AS pet_name,
  p.species AS pet_species,
  p.breed AS pet_breed,
  COALESCE(p.pet_images->0->>'url', '') AS pet_image_url,
  p.age_years,
  p.gender,
  p.size,
  adopter.full_name AS adopter_name,
  adopter.email AS adopter_email,
  adopter.phone AS adopter_phone,
  s.shelter_name,
  s.city AS shelter_city
FROM public.adoption_requests ar
LEFT JOIN public.pets p ON ar.pet_id = p.id
LEFT JOIN public.profiles adopter ON ar.adopter_id = adopter.id
LEFT JOIN public.shelters s ON ar.shelter_id = s.id;

GRANT SELECT ON public.adoption_requests_with_details TO authenticated;

-- VISTA 3: Favoritos con info completa
DROP VIEW IF EXISTS public.favorites_with_pet_info CASCADE;
CREATE VIEW public.favorites_with_pet_info AS
SELECT 
  p.id,
  p.name,
  p.species,
  p.breed,
  p.age_years,
  p.age_months,
  p.gender,
  p.size,
  p.pet_images,
  p.description,
  p.health_notes,
  p.adoption_status,
  p.shelter_id,
  p.created_at,
  p.updated_at,
  f.user_id,
  f.created_at AS favorited_at,
  s.shelter_name,
  s.city AS shelter_city,
  s.latitude AS shelter_latitude,
  s.longitude AS shelter_longitude
FROM public.favorites f
INNER JOIN public.pets p ON f.pet_id = p.id
LEFT JOIN public.shelters s ON p.shelter_id = s.id;

GRANT SELECT ON public.favorites_with_pet_info TO authenticated;


-- Actualizar la vista para incluir la dirección del refugio
DROP VIEW IF EXISTS public.pets_with_shelter_info CASCADE;

CREATE VIEW public.pets_with_shelter_info AS
SELECT 
  p.id,
  p.name,
  p.species,
  p.breed,
  p.age_years,
  p.age_months,
  p.gender,
  p.size,
  p.pet_images,
  p.description,
  p.is_vaccinated,
  p.is_dewormed,
  p.is_sterilized,
  p.has_microchip,
  p.needs_special_care,
  p.health_notes,
  p.adoption_status,
  p.shelter_id,
  p.views_count,
  p.created_at,
  p.updated_at,
  s.shelter_name,
  s.city AS shelter_city,
  s.address AS shelter_address, -- ✅ Nueva columna agregada
  s.latitude AS shelter_latitude,
  s.longitude AS shelter_longitude,
  s.phone AS shelter_phone,
  pr.email AS shelter_email
FROM public.pets p
LEFT JOIN public.shelters s ON p.shelter_id = s.id
LEFT JOIN public.profiles pr ON s.profile_id = pr.id;

GRANT SELECT ON public.pets_with_shelter_info TO authenticated;
GRANT SELECT ON public.pets_with_shelter_info TO anon;

-- ✅ SETUP COMPLETADO
COMMIT;

-- ============================================
-- 🔟 ALMACENAMIENTO (STORAGE BUCKETS)
-- ============================================

-- Crear bucket para imágenes de mascotas
INSERT INTO storage.buckets (id, name, public)
VALUES ('pet-images', 'pet-images', true)
ON CONFLICT (id) DO NOTHING;

-- Crear bucket para avatares de usuarios
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 🔐 POLÍTICAS DE ALMACENAMIENTO
-- ============================================

-- Política para pet-images (Públicos para leer, shelters para escribir)
DROP POLICY IF EXISTS "Public read pet-images" ON storage.objects;
CREATE POLICY "Public read pet-images" 
  ON storage.objects FOR SELECT 
  USING (bucket_id = 'pet-images');

DROP POLICY IF EXISTS "Shelters write pet-images" ON storage.objects;
CREATE POLICY "Shelters write pet-images" 
  ON storage.objects FOR INSERT 
  WITH CHECK (
    bucket_id = 'pet-images' AND
    auth.role() = 'authenticated'
  );

DROP POLICY IF EXISTS "Shelters delete pet-images" ON storage.objects;
CREATE POLICY "Shelters delete pet-images" 
  ON storage.objects FOR DELETE 
  USING (
    bucket_id = 'pet-images' AND
    auth.role() = 'authenticated'
  );

-- Política para avatars (Públicos para leer, usuarios para escribir propio)
DROP POLICY IF EXISTS "Public read avatars" ON storage.objects;
CREATE POLICY "Public read avatars" 
  ON storage.objects FOR SELECT 
  USING (bucket_id = 'avatars');

DROP POLICY IF EXISTS "Users write own avatars" ON storage.objects;
CREATE POLICY "Users write own avatars" 
  ON storage.objects FOR INSERT 
  WITH CHECK (
    bucket_id = 'avatars' AND
    auth.role() = 'authenticated'
  );
