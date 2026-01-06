  -- ============================================
  -- PETADOPT - SCRIPT COMPLETO CORREGIDO
  -- ============================================

  -- ============================================
  -- 0️⃣ LIMPIAR TODO
  -- ============================================

  DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users CASCADE;
  DROP TRIGGER IF EXISTS on_profile_created ON public.profiles CASCADE;
  DROP TRIGGER IF EXISTS update_shelters_timestamp ON public.shelters CASCADE;
  DROP TRIGGER IF EXISTS update_pets_timestamp ON public.pets CASCADE;

  DROP FUNCTION IF EXISTS public.handle_new_user() CASCADE;
  DROP FUNCTION IF EXISTS public.handle_new_profile() CASCADE;
  DROP FUNCTION IF EXISTS public.update_updated_at_column() CASCADE;

  DROP VIEW IF EXISTS public.pets_with_shelter_info CASCADE;
  DROP VIEW IF EXISTS public.favorites_with_pet_info CASCADE;
  DROP VIEW IF EXISTS public.adoption_requests_with_details CASCADE;

  DROP TABLE IF EXISTS public.chat_history CASCADE;
  DROP TABLE IF EXISTS public.favorites CASCADE;
  DROP TABLE IF EXISTS public.adoption_requests CASCADE;
  DROP TABLE IF EXISTS public.adoption_applications CASCADE;
  DROP TABLE IF EXISTS public.pets CASCADE;
  DROP TABLE IF EXISTS public.adopters CASCADE;
  DROP TABLE IF EXISTS public.shelters CASCADE;
  DROP TABLE IF EXISTS public.profiles CASCADE;

  DROP TYPE IF EXISTS public.request_status CASCADE;
  DROP TYPE IF EXISTS public.adoption_status CASCADE;
  DROP TYPE IF EXISTS public.pet_size CASCADE;
  DROP TYPE IF EXISTS public.pet_gender CASCADE;
  DROP TYPE IF EXISTS public.pet_species CASCADE;
  DROP TYPE IF EXISTS public.user_type CASCADE;
  DROP TYPE IF EXISTS public.user_role CASCADE;

  -- ============================================
  -- 1️⃣ EXTENSIONES
  -- ============================================

  CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
  CREATE EXTENSION IF NOT EXISTS "pgcrypto";

  -- ============================================
  -- 2️⃣ TIPOS ENUM (NOMBRES CORRECTOS)
  -- ============================================

  CREATE TYPE public.user_type AS ENUM ('adopter', 'shelter');
  CREATE TYPE public.pet_species AS ENUM ('dog', 'cat', 'other');
  CREATE TYPE public.pet_gender AS ENUM ('male', 'female');
  CREATE TYPE public.pet_size AS ENUM ('small', 'medium', 'large');
  CREATE TYPE public.adoption_status AS ENUM ('available', 'pending', 'adopted');
  CREATE TYPE public.request_status AS ENUM ('pending', 'approved', 'rejected');

  -- ============================================
  -- 3️⃣ TABLAS
  -- ============================================

  -- Perfiles (CORREGIDO: user_type + full_name)
  CREATE TABLE public.profiles (
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

  -- Refugios (CORREGIDO: shelter_name es la columna principal)
  CREATE TABLE public.shelters (
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

  -- Mascotas (NOMBRES CORRECTOS DE COLUMNAS)
  CREATE TABLE public.pets (
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
    main_image_url TEXT DEFAULT '',
    images_urls TEXT[] DEFAULT '{}',
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

  -- Solicitudes de adopción (NOMBRES CORRECTOS)
  CREATE TABLE public.adoption_requests (
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

  -- Favoritos
  CREATE TABLE public.favorites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    pet_id UUID NOT NULL REFERENCES public.pets(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, pet_id)
  );

  -- Chat History
  CREATE TABLE public.chat_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    response TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
  );

  -- ============================================
  -- 4️⃣ ÍNDICES
  -- ============================================

  CREATE INDEX idx_profiles_user_type ON public.profiles(user_type);
  CREATE INDEX idx_shelters_profile_id ON public.shelters(profile_id);
  CREATE INDEX idx_shelters_city ON public.shelters(city);
  CREATE INDEX idx_pets_shelter_id ON public.pets(shelter_id);
  CREATE INDEX idx_pets_species ON public.pets(species);
  CREATE INDEX idx_pets_adoption_status ON public.pets(adoption_status);
  CREATE INDEX idx_adoption_requests_pet_id ON public.adoption_requests(pet_id);
  CREATE INDEX idx_adoption_requests_adopter_id ON public.adoption_requests(adopter_id);
  CREATE INDEX idx_adoption_requests_shelter_id ON public.adoption_requests(shelter_id);
  CREATE INDEX idx_adoption_requests_status ON public.adoption_requests(status);
  CREATE INDEX idx_favorites_user_id ON public.favorites(user_id);
  CREATE INDEX idx_favorites_pet_id ON public.favorites(pet_id);
  CREATE INDEX idx_chat_history_user_id ON public.chat_history(user_id);

  -- ============================================
  -- 5️⃣ RLS
  -- ============================================

  ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
  ALTER TABLE public.shelters ENABLE ROW LEVEL SECURITY;
  ALTER TABLE public.pets ENABLE ROW LEVEL SECURITY;
  ALTER TABLE public.adoption_requests ENABLE ROW LEVEL SECURITY;
  ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;
  ALTER TABLE public.chat_history ENABLE ROW LEVEL SECURITY;

  -- ============================================
  -- 6️⃣ POLÍTICAS RLS
  -- ============================================

  -- Profiles
  DROP POLICY IF EXISTS "Public can view all profiles" ON public.profiles;
  CREATE POLICY "Public can view all profiles" 
    ON public.profiles FOR SELECT 
    USING (true);

  DROP POLICY IF EXISTS "Users can update own profile" ON public.profiles;
  CREATE POLICY "Users can update own profile" 
    ON public.profiles FOR UPDATE 
    USING (auth.uid() = id);

  DROP POLICY IF EXISTS "Users can insert own profile" ON public.profiles;
  CREATE POLICY "Users can insert own profile" 
    ON public.profiles FOR INSERT 
    WITH CHECK (auth.uid() = id);

  -- Shelters
  DROP POLICY IF EXISTS "Anyone can view shelters" ON public.shelters;
  CREATE POLICY "Anyone can view shelters" 
    ON public.shelters FOR SELECT 
    USING (true);

  DROP POLICY IF EXISTS "Users can create their shelter" ON public.shelters;
  CREATE POLICY "Users can create their shelter" 
    ON public.shelters FOR INSERT 
    WITH CHECK (auth.uid() = profile_id);

  DROP POLICY IF EXISTS "Shelters can update their own info" ON public.shelters;
  CREATE POLICY "Shelters can update their own info" 
    ON public.shelters FOR UPDATE 
    USING (auth.uid() = profile_id);

  -- Pets
  DROP POLICY IF EXISTS "Anyone can view available pets" ON public.pets;
  CREATE POLICY "Anyone can view available pets" 
    ON public.pets FOR SELECT 
    USING (true);

  DROP POLICY IF EXISTS "Shelters can insert their own pets" ON public.pets;
  CREATE POLICY "Shelters can insert their own pets" 
    ON public.pets FOR INSERT 
    WITH CHECK (
      EXISTS (
        SELECT 1 FROM public.shelters 
        WHERE shelters.profile_id = auth.uid() 
        AND shelters.id = pets.shelter_id
      )
    );

  DROP POLICY IF EXISTS "Shelters can update their own pets" ON public.pets;
  CREATE POLICY "Shelters can update their own pets" 
    ON public.pets FOR UPDATE 
    USING (
      EXISTS (
        SELECT 1 FROM public.shelters 
        WHERE shelters.profile_id = auth.uid() 
        AND shelters.id = pets.shelter_id
      )
    );

  DROP POLICY IF EXISTS "Shelters can delete their own pets" ON public.pets;
  CREATE POLICY "Shelters can delete their own pets" 
    ON public.pets FOR DELETE 
    USING (
      EXISTS (
        SELECT 1 FROM public.shelters 
        WHERE shelters.profile_id = auth.uid() 
        AND shelters.id = pets.shelter_id
      )
    );

  -- Adoption Requests
  DROP POLICY IF EXISTS "Users can view their own requests" ON public.adoption_requests;
  CREATE POLICY "Users can view their own requests" 
    ON public.adoption_requests FOR SELECT 
    USING (
      auth.uid() = adopter_id OR 
      EXISTS (
        SELECT 1 FROM public.shelters 
        WHERE shelters.id = adoption_requests.shelter_id 
        AND shelters.profile_id = auth.uid()
      )
    );

  DROP POLICY IF EXISTS "Adopters can create requests" ON public.adoption_requests;
  CREATE POLICY "Adopters can create requests" 
    ON public.adoption_requests FOR INSERT 
    WITH CHECK (auth.uid() = adopter_id);

  DROP POLICY IF EXISTS "Shelters can update requests" ON public.adoption_requests;
  CREATE POLICY "Shelters can update requests" 
    ON public.adoption_requests FOR UPDATE 
    USING (
      EXISTS (
        SELECT 1 FROM public.shelters 
        WHERE shelters.id = adoption_requests.shelter_id 
        AND shelters.profile_id = auth.uid()
      )
    );

  DROP POLICY IF EXISTS "Adopters can delete own requests" ON public.adoption_requests;
  CREATE POLICY "Adopters can delete own requests" 
    ON public.adoption_requests FOR DELETE 
    USING (auth.uid() = adopter_id AND status = 'pending');

  -- Favorites
  DROP POLICY IF EXISTS "Users can view their own favorites" ON public.favorites;
  CREATE POLICY "Users can view their own favorites" 
    ON public.favorites FOR SELECT 
    USING (auth.uid() = user_id);

  DROP POLICY IF EXISTS "Users can insert their own favorites" ON public.favorites;
  CREATE POLICY "Users can insert their own favorites" 
    ON public.favorites FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

  DROP POLICY IF EXISTS "Users can delete their own favorites" ON public.favorites;
  CREATE POLICY "Users can delete their own favorites" 
    ON public.favorites FOR DELETE 
    USING (auth.uid() = user_id);

  -- Chat History
  DROP POLICY IF EXISTS "Users can view their own chat" ON public.chat_history;
  CREATE POLICY "Users can view their own chat" 
    ON public.chat_history FOR SELECT 
    USING (auth.uid() = user_id);

  DROP POLICY IF EXISTS "Users can insert their own chat" ON public.chat_history;
  CREATE POLICY "Users can insert their own chat" 
    ON public.chat_history FOR INSERT 
    WITH CHECK (auth.uid() = user_id);

  DROP POLICY IF EXISTS "Users can delete their own chat" ON public.chat_history;
  CREATE POLICY "Users can delete their own chat" 
    ON public.chat_history FOR DELETE 
    USING (auth.uid() = user_id);

  -- ============================================
  -- 7️⃣ FUNCIONES Y TRIGGERS
  -- ============================================

  -- Función para actualizar updated_at
  CREATE OR REPLACE FUNCTION public.update_updated_at_column()
  RETURNS TRIGGER AS $$
  BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
  END;
  $$ LANGUAGE plpgsql;

  -- Función para crear perfil automáticamente (CORREGIDA)
  CREATE OR REPLACE FUNCTION public.handle_new_user()
  RETURNS TRIGGER AS $$
  DECLARE
    user_type_value TEXT;
    full_name_value TEXT;
  BEGIN
    -- Extraer datos del metadata
    user_type_value := COALESCE(NEW.raw_user_meta_data->>'user_type', NEW.raw_user_meta_data->>'role', 'adopter');
    full_name_value := COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.raw_user_meta_data->>'name', 'Usuario');
    
    -- Insertar perfil
    INSERT INTO public.profiles (id, email, full_name, user_type, phone, location, latitude, longitude)
    VALUES (
      NEW.id,
      NEW.email,
      full_name_value,
      user_type_value::public.user_type,
      NEW.raw_user_meta_data->>'phone',
      NEW.raw_user_meta_data->>'address',
      CASE 
        WHEN NEW.raw_user_meta_data->>'latitude' IS NOT NULL THEN 
          (NEW.raw_user_meta_data->>'latitude')::DECIMAL(10,8)
        ELSE NULL
      END,
      CASE 
        WHEN NEW.raw_user_meta_data->>'longitude' IS NOT NULL THEN 
          (NEW.raw_user_meta_data->>'longitude')::DECIMAL(11,8)
        ELSE NULL
      END
    );
    
    RETURN NEW;
  END;
  $$ LANGUAGE plpgsql SECURITY DEFINER;

  -- Función para crear shelter automáticamente si es shelter (CORREGIDA)
  CREATE OR REPLACE FUNCTION public.handle_new_profile()
  RETURNS TRIGGER AS $$
  BEGIN
    IF NEW.user_type = 'shelter' THEN
      INSERT INTO public.shelters (
        profile_id,
        shelter_name,
        address,
        city,
        country,
        latitude,
        longitude,
        phone
      ) VALUES (
        NEW.id,
        NEW.full_name,
        COALESCE(NEW.location, 'Dirección no especificada'),
        'Quito',
        'Ecuador',
        COALESCE(NEW.latitude, -0.180653),
        COALESCE(NEW.longitude, -78.467834),
        NEW.phone
      );
    END IF;
    
    RETURN NEW;
  END;
  $$ LANGUAGE plpgsql SECURITY DEFINER;

  -- Activar triggers
  CREATE TRIGGER on_auth_user_created 
    AFTER INSERT ON auth.users 
    FOR EACH ROW 
    EXECUTE FUNCTION public.handle_new_user();

  CREATE TRIGGER on_profile_created 
    AFTER INSERT ON public.profiles 
    FOR EACH ROW 
    EXECUTE FUNCTION public.handle_new_profile();

  CREATE TRIGGER update_shelters_timestamp
    BEFORE UPDATE ON public.shelters
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

  CREATE TRIGGER update_pets_timestamp
    BEFORE UPDATE ON public.pets
    FOR EACH ROW
    EXECUTE FUNCTION public.update_updated_at_column();

  -- ============================================
  -- 8️⃣ VISTAS
  -- ============================================

  -- Vista de mascotas con info del refugio
  DROP VIEW IF EXISTS public.pets_with_shelter_info CASCADE;

  CREATE VIEW public.pets_with_shelter_info AS
  SELECT 
    p.*,
    s.shelter_name,
    s.city AS shelter_city,
    s.latitude AS shelter_latitude,
    s.longitude AS shelter_longitude
  FROM public.pets p
  LEFT JOIN public.shelters s ON p.shelter_id = s.id;

  GRANT SELECT ON public.pets_with_shelter_info TO authenticated;
  GRANT SELECT ON public.pets_with_shelter_info TO anon;

  -- Vista de favoritos con info completa
  DROP VIEW IF EXISTS public.favorites_with_pet_info CASCADE;

  CREATE VIEW public.favorites_with_pet_info AS
  SELECT 
    f.id AS favorite_id,
    f.user_id,
    f.pet_id,
    f.created_at AS favorited_at,
    p.*,
    s.shelter_name,
    s.city AS shelter_city,
    s.latitude AS shelter_latitude,
    s.longitude AS shelter_longitude
  FROM public.favorites f
  INNER JOIN public.pets p ON f.pet_id = p.id
  LEFT JOIN public.shelters s ON p.shelter_id = s.id;

  GRANT SELECT ON public.favorites_with_pet_info TO authenticated;

  -- Vista de solicitudes con detalles
  DROP VIEW IF EXISTS public.adoption_requests_with_details CASCADE;

  CREATE VIEW public.adoption_requests_with_details AS
  SELECT 
    ar.*,
    p.name AS pet_name,
    p.species AS pet_species,
    p.breed AS pet_breed,
    p.main_image_url AS pet_image_url,
    adopter.full_name AS adopter_name,
    adopter.email AS adopter_email,
    adopter.phone AS adopter_phone,
    s.shelter_name
  FROM public.adoption_requests ar
  LEFT JOIN public.pets p ON ar.pet_id = p.id
  LEFT JOIN public.profiles adopter ON ar.adopter_id = adopter.id
  LEFT JOIN public.shelters s ON ar.shelter_id = s.id;

  GRANT SELECT ON public.adoption_requests_with_details TO authenticated;

  -- ============================================
  -- ✅ SCRIPT COMPLETADO
  -- ============================================
