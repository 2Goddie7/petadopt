-- ============================================
-- FIX: Flujo de Adopción - Mascotas Pendientes
-- ============================================
-- Este script corrige el problema donde las mascotas con solicitudes 
-- de adopción pendientes siguen apareciendo como disponibles

-- 1. Recrear la vista pets_with_shelter_info con la columna shelter_address
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
  p.adoption_status,  -- ✅ Esta columna es CRÍTICA para el filtrado
  p.shelter_id,
  p.views_count,
  p.created_at,
  p.updated_at,
  p.personality_traits,
  s.shelter_name,
  s.city AS shelter_city,
  s.address AS shelter_address,  -- ✅ Nueva columna para dirección exacta
  s.latitude AS shelter_latitude,
  s.longitude AS shelter_longitude,
  s.phone AS shelter_phone,
  pr.email AS shelter_email
FROM public.pets p
LEFT JOIN public.shelters s ON p.shelter_id = s.id
LEFT JOIN public.profiles pr ON s.profile_id = pr.id;

-- Otorgar permisos
GRANT SELECT ON public.pets_with_shelter_info TO authenticated;
GRANT SELECT ON public.pets_with_shelter_info TO anon;

-- 2. Verificar que todas las mascotas con solicitudes pendientes estén marcadas como 'pending'
-- (Esto es un one-time fix para datos existentes)
UPDATE public.pets
SET adoption_status = 'pending'
WHERE id IN (
  SELECT DISTINCT pet_id
  FROM public.adoption_requests
  WHERE status = 'pending'
)
AND adoption_status = 'available';

-- 3. Verificar que las mascotas sin solicitudes pendientes estén disponibles
UPDATE public.pets
SET adoption_status = 'available'
WHERE id NOT IN (
  SELECT DISTINCT pet_id
  FROM public.adoption_requests
  WHERE status = 'pending'
)
AND adoption_status = 'pending';

-- 4. Crear una función para mantener sincronizado el estado de la mascota
-- cuando se crea o elimina una solicitud de adopción
CREATE OR REPLACE FUNCTION public.sync_pet_adoption_status()
RETURNS TRIGGER AS $$
BEGIN
  -- Si se crea una solicitud pendiente, actualizar mascota a pending
  IF (TG_OP = 'INSERT' AND NEW.status = 'pending') THEN
    UPDATE public.pets
    SET adoption_status = 'pending'
    WHERE id = NEW.pet_id;
    
  -- Si se elimina una solicitud pendiente, verificar si hay otras
  ELSIF (TG_OP = 'DELETE' AND OLD.status = 'pending') THEN
    -- Si no hay otras solicitudes pendientes, volver a available
    IF NOT EXISTS (
      SELECT 1 FROM public.adoption_requests
      WHERE pet_id = OLD.pet_id AND status = 'pending'
    ) THEN
      UPDATE public.pets
      SET adoption_status = 'available'
      WHERE id = OLD.pet_id AND adoption_status = 'pending';
    END IF;
    
  -- Si se actualiza el estado de la solicitud
  ELSIF (TG_OP = 'UPDATE') THEN
    -- Si se aprueba, marcar como adoptado
    IF (NEW.status = 'approved' AND OLD.status = 'pending') THEN
      UPDATE public.pets
      SET adoption_status = 'adopted'
      WHERE id = NEW.pet_id;
      
    -- Si se rechaza, volver a available (solo si no hay otras solicitudes pendientes)
    ELSIF (NEW.status = 'rejected' AND OLD.status = 'pending') THEN
      IF NOT EXISTS (
        SELECT 1 FROM public.adoption_requests
        WHERE pet_id = NEW.pet_id AND status = 'pending' AND id != NEW.id
      ) THEN
        UPDATE public.pets
        SET adoption_status = 'available'
        WHERE id = NEW.pet_id;
      END IF;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 5. Crear el trigger para ejecutar la función automáticamente
DROP TRIGGER IF EXISTS sync_pet_status_on_request_change ON public.adoption_requests;

CREATE TRIGGER sync_pet_status_on_request_change
AFTER INSERT OR UPDATE OR DELETE ON public.adoption_requests
FOR EACH ROW
EXECUTE FUNCTION public.sync_pet_adoption_status();

-- 6. Verificación: Consulta para revisar el estado actual
-- Descomentar para ejecutar manualmente:
-- SELECT 
--   p.id,
--   p.name,
--   p.adoption_status,
--   COUNT(ar.id) as pending_requests
-- FROM public.pets p
-- LEFT JOIN public.adoption_requests ar ON p.id = ar.pet_id AND ar.status = 'pending'
-- GROUP BY p.id, p.name, p.adoption_status
-- HAVING COUNT(ar.id) > 0 OR p.adoption_status = 'pending';

-- ============================================
-- INSTRUCCIONES:
-- 1. Ejecuta este script completo en el SQL Editor de Supabase
-- 2. La vista ahora incluirá shelter_address
-- 3. Las mascotas con solicitudes pendientes automáticamente 
--    se marcarán como 'pending' y no aparecerán para otros adoptantes
-- 4. El trigger mantendrá sincronizado el estado automáticamente
-- ============================================
