-- =================================================
-- ACTUALIZACIÓN: Agregar campos bio y location a profiles
-- =================================================
-- Ejecutar en Supabase SQL Editor
-- =================================================

-- Agregar columna bio (biografía) a la tabla profiles
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS bio TEXT;

-- Agregar columna location (ubicación) a la tabla profiles
ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS location TEXT;

-- Comentarios para documentación
COMMENT ON COLUMN profiles.bio IS 'Biografía o descripción del usuario/refugio';
COMMENT ON COLUMN profiles.location IS 'Ubicación o ciudad del usuario/refugio';

-- Verificar que las columnas se agregaron correctamente
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'profiles'
AND column_name IN ('bio', 'location');
