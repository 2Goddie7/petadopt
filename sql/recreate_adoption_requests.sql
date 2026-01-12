-- ============================================
-- 🔄 RECREAR TABLA ADOPTION_REQUESTS + NOTIFICATIONS
-- ============================================
-- Este script recrea:
--   1. Tabla adoption_requests con flujo completo
--   2. Tabla notifications para Supabase Realtime
--   3. Triggers automáticos para notificaciones
--
-- FLUJO DE ADOPCIÓN:
--   1. Adopter solicita mascota → Mascota pasa a 'pending'
--   2. Mascota 'pending' se oculta de otros adoptantes
--   3. Shelter ve solicitudes y estado de mascotas
--   4. Al aprobar → Mascota 'adopted', otras solicitudes rechazadas
--   5. Al rechazar → Si no hay otras, mascota vuelve a 'available'
--   6. Se puede volver a solicitar una mascota rechazada
--
-- NOTIFICACIONES (Supabase Realtime):
--   - Shelter recibe notificación cuando hay nueva solicitud
--   - Adopter recibe notificación cuando aprueban/rechazan
-- ============================================

-- ============================================
-- 1️⃣ CREAR TABLA ADOPTION_REQUESTS
-- ============================================
DROP TABLE IF EXISTS public.adoption_requests CASCADE;

CREATE TABLE public.adoption_requests (
  -- Primary Key
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Foreign Keys
  pet_id UUID NOT NULL REFERENCES public.pets(id) ON DELETE CASCADE,
  adopter_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  shelter_id UUID NOT NULL REFERENCES public.shelters(id) ON DELETE CASCADE,
  
  -- Datos de la solicitud
  message TEXT,
  status VARCHAR(20) NOT NULL DEFAULT 'pending' 
    CHECK (status IN ('pending', 'approved', 'rejected', 'cancelled')),
  rejection_reason TEXT,
  
  -- Timestamps
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  reviewed_at TIMESTAMPTZ
  
  -- ⚠️ SIN UNIQUE constraint para permitir re-solicitar después de rechazo
  -- La validación se hace en el código Dart (solo bloquea pending/approved)
);

-- ============================================
-- 2️⃣ ÍNDICES PARA CONSULTAS RÁPIDAS
-- ============================================
CREATE INDEX IF NOT EXISTS idx_adoption_requests_pet_id 
  ON public.adoption_requests(pet_id);

CREATE INDEX IF NOT EXISTS idx_adoption_requests_adopter_id 
  ON public.adoption_requests(adopter_id);

CREATE INDEX IF NOT EXISTS idx_adoption_requests_shelter_id 
  ON public.adoption_requests(shelter_id);

CREATE INDEX IF NOT EXISTS idx_adoption_requests_status 
  ON public.adoption_requests(status);

CREATE INDEX IF NOT EXISTS idx_adoption_requests_created_at 
  ON public.adoption_requests(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_adoption_requests_status_adopter 
  ON public.adoption_requests(status, adopter_id);

-- ============================================
-- 3️⃣ TRIGGER: ACTUALIZAR UPDATED_AT AUTOMÁTICAMENTE
-- ============================================
CREATE OR REPLACE FUNCTION public.update_adoption_request_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_adoption_request_timestamp 
  ON public.adoption_requests;

CREATE TRIGGER trigger_update_adoption_request_timestamp
BEFORE UPDATE ON public.adoption_requests
FOR EACH ROW
EXECUTE FUNCTION public.update_adoption_request_timestamp();

-- ============================================
-- 4️⃣ FUNCIÓN: SINCRONIZAR ESTADO DE MASCOTA
-- ============================================
-- Esta función mantiene sincronizado el adoption_status de la mascota
-- con el estado de las solicitudes de adopción.

CREATE OR REPLACE FUNCTION public.sync_pet_adoption_status()
RETURNS TRIGGER AS $$
BEGIN
  -- ========================================
  -- CASO 1: Nueva solicitud pendiente (INSERT)
  -- ========================================
  IF (TG_OP = 'INSERT' AND NEW.status = 'pending') THEN
    -- Marcar mascota como 'pending' (en proceso de adopción)
    UPDATE public.pets
    SET adoption_status = 'pending', updated_at = NOW()
    WHERE id = NEW.pet_id;
    
    RETURN NEW;
  END IF;
  
  -- ========================================
  -- CASO 2: Solicitud eliminada (DELETE)
  -- ========================================
  IF (TG_OP = 'DELETE' AND OLD.status = 'pending') THEN
    -- Si no hay otras solicitudes pendientes, volver a 'available'
    IF NOT EXISTS (
      SELECT 1 FROM public.adoption_requests
      WHERE pet_id = OLD.pet_id AND status = 'pending'
    ) THEN
      UPDATE public.pets
      SET adoption_status = 'available', updated_at = NOW()
      WHERE id = OLD.pet_id AND adoption_status = 'pending';
    END IF;
    
    RETURN OLD;
  END IF;
  
  -- ========================================
  -- CASO 3: Estado actualizado (UPDATE)
  -- ========================================
  IF (TG_OP = 'UPDATE') THEN
    -- 3a. Solicitud APROBADA -> Mascota a 'adopted'
    IF (NEW.status = 'approved' AND OLD.status = 'pending') THEN
      UPDATE public.pets
      SET adoption_status = 'adopted', updated_at = NOW()
      WHERE id = NEW.pet_id;
      
      -- Rechazar automáticamente otras solicitudes pendientes
      UPDATE public.adoption_requests
      SET 
        status = 'rejected', 
        rejection_reason = 'Otra solicitud fue aprobada para esta mascota',
        reviewed_at = NOW(),
        updated_at = NOW()
      WHERE pet_id = NEW.pet_id
        AND id != NEW.id
        AND status = 'pending';
      
      RETURN NEW;
    END IF;
    
    -- 3b. Solicitud RECHAZADA -> Verificar si volver a 'available'
    IF (NEW.status = 'rejected' AND OLD.status = 'pending') THEN
      -- Solo si no hay otras solicitudes pendientes o aprobadas
      IF NOT EXISTS (
        SELECT 1 FROM public.adoption_requests
        WHERE pet_id = NEW.pet_id 
          AND id != NEW.id 
          AND status IN ('pending', 'approved')
      ) THEN
        UPDATE public.pets
        SET adoption_status = 'available', updated_at = NOW()
        WHERE id = NEW.pet_id;
      END IF;
      
      RETURN NEW;
    END IF;
    
    -- 3c. Solicitud CANCELADA -> Verificar si volver a 'available'
    IF (NEW.status = 'cancelled' AND OLD.status = 'pending') THEN
      IF NOT EXISTS (
        SELECT 1 FROM public.adoption_requests
        WHERE pet_id = NEW.pet_id 
          AND id != NEW.id 
          AND status IN ('pending', 'approved')
      ) THEN
        UPDATE public.pets
        SET adoption_status = 'available', updated_at = NOW()
        WHERE id = NEW.pet_id;
      END IF;
      
      RETURN NEW;
    END IF;
  END IF;
  
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 5️⃣ TRIGGER: EJECUTAR SINCRONIZACIÓN AUTOMÁTICAMENTE
-- ============================================
DROP TRIGGER IF EXISTS sync_pet_status_on_request_change 
  ON public.adoption_requests;

CREATE TRIGGER sync_pet_status_on_request_change
AFTER INSERT OR UPDATE OR DELETE ON public.adoption_requests
FOR EACH ROW
EXECUTE FUNCTION public.sync_pet_adoption_status();

-- ============================================
-- 6️⃣ ROW LEVEL SECURITY (RLS)
-- ============================================
ALTER TABLE public.adoption_requests ENABLE ROW LEVEL SECURITY;

-- Política: Ver propias solicitudes (adopters) o solicitudes para mis mascotas (shelters)
DROP POLICY IF EXISTS "View own adoption requests" ON public.adoption_requests;
CREATE POLICY "View own adoption requests" 
  ON public.adoption_requests FOR SELECT USING (
    auth.uid() = adopter_id OR 
    EXISTS (
      SELECT 1 FROM public.shelters 
      WHERE shelters.id = adoption_requests.shelter_id 
        AND shelters.profile_id = auth.uid()
    )
  );

-- Política: Adopters pueden crear solicitudes
DROP POLICY IF EXISTS "Adopters create requests" ON public.adoption_requests;
CREATE POLICY "Adopters create requests" 
  ON public.adoption_requests FOR INSERT 
  WITH CHECK (auth.uid() = adopter_id);

-- Política: Shelters pueden actualizar solicitudes para sus mascotas
DROP POLICY IF EXISTS "Shelters update requests" ON public.adoption_requests;
CREATE POLICY "Shelters update requests" 
  ON public.adoption_requests FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.shelters 
      WHERE shelters.id = adoption_requests.shelter_id 
        AND shelters.profile_id = auth.uid()
    )
  );

-- Política: Adopters pueden cancelar sus solicitudes pendientes
DROP POLICY IF EXISTS "Adopters delete requests" ON public.adoption_requests;
CREATE POLICY "Adopters delete requests" 
  ON public.adoption_requests FOR DELETE 
  USING (auth.uid() = adopter_id AND status = 'pending');

-- ============================================
-- 7️⃣ GRANTS
-- ============================================
GRANT SELECT, INSERT, UPDATE, DELETE ON public.adoption_requests TO authenticated;

-- ============================================
-- 8️⃣ VISTA: SOLICITUDES CON DETALLES COMPLETOS
-- ============================================
DROP VIEW IF EXISTS public.adoption_requests_with_details CASCADE;

CREATE VIEW public.adoption_requests_with_details AS
SELECT 
  ar.id,
  ar.pet_id,
  ar.adopter_id,
  ar.shelter_id,
  ar.status,
  ar.message,
  ar.rejection_reason,
  ar.created_at,
  ar.updated_at,
  ar.reviewed_at,
  -- Info de mascota
  p.name AS pet_name,
  p.species AS pet_species,
  p.breed AS pet_breed,
  p.age_years,
  p.gender,
  p.size,
  COALESCE(p.pet_images->0->>'url', '') AS pet_image_url,
  -- Info de adoptante
  adopter.full_name AS adopter_name,
  adopter.email AS adopter_email,
  adopter.phone AS adopter_phone,
  -- Info de shelter
  s.shelter_name,
  s.city AS shelter_city,
  s.phone AS shelter_phone
FROM public.adoption_requests ar
LEFT JOIN public.pets p ON ar.pet_id = p.id
LEFT JOIN public.profiles adopter ON ar.adopter_id = adopter.id
LEFT JOIN public.shelters s ON ar.shelter_id = s.id;

GRANT SELECT ON public.adoption_requests_with_details TO authenticated;

-- ============================================
-- 9️⃣ RECREAR VISTA pets_with_shelter_info (ACTUALIZADA)
-- ============================================
-- Esta vista incluye shelter_address para la ubicación exacta

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
  p.adoption_status,  -- CRÍTICO: Para filtrar mascotas en proceso de adopción
  p.shelter_id,
  p.views_count,
  p.created_at,
  p.updated_at,
  p.personality_traits,
  s.shelter_name,
  s.city AS shelter_city,
  s.address AS shelter_address,
  s.latitude AS shelter_latitude,
  s.longitude AS shelter_longitude,
  s.phone AS shelter_phone,
  pr.email AS shelter_email
FROM public.pets p
LEFT JOIN public.shelters s ON p.shelter_id = s.id
LEFT JOIN public.profiles pr ON s.profile_id = pr.id;

GRANT SELECT ON public.pets_with_shelter_info TO authenticated;
GRANT SELECT ON public.pets_with_shelter_info TO anon;

-- ============================================
-- 🔟 FUNCIÓN: COMPLETAR ADOPCIÓN (MARCAR COMO ADOPTADO)
-- ============================================
-- Función para marcar explícitamente una mascota como adoptada

DROP FUNCTION IF EXISTS public.complete_adoption(uuid);

CREATE FUNCTION public.complete_adoption(adoption_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  UPDATE public.pets
  SET adoption_status = 'adopted', updated_at = NOW()
  WHERE id = (
    SELECT pet_id FROM public.adoption_requests WHERE id = adoption_id
  );
  
  RETURN TRUE;
EXCEPTION WHEN OTHERS THEN
  RETURN FALSE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION public.complete_adoption TO authenticated;

-- ============================================
-- 1️⃣1️⃣ SINCRONIZAR DATOS EXISTENTES (ONE-TIME FIX)
-- ============================================
-- Ejecuta esto solo una vez después de recrear la tabla

-- Asegurar que mascotas sin solicitudes activas estén disponibles
-- (Solo si hay mascotas marcadas incorrectamente)

/*
-- Descomentar para ejecutar manualmente si es necesario:

UPDATE public.pets
SET adoption_status = 'available', updated_at = NOW()
WHERE adoption_status = 'pending'
  AND id NOT IN (
    SELECT DISTINCT pet_id
    FROM public.adoption_requests
    WHERE status IN ('pending', 'approved')
  );
*/

-- ============================================
-- ✅ SCRIPT COMPLETADO
-- ============================================
-- 
-- FLUJO DE ADOPCIÓN:
-- 
-- 1. ADOPTER solicita mascota:
--    → Se crea adoption_request con status='pending'
--    → Trigger actualiza pet.adoption_status a 'pending'
--    → La mascota YA NO aparece para otros adoptantes
--    → Se crea NOTIFICACIÓN para el shelter
--
-- 2. SHELTER ve solicitud:
--    → Ve todas las solicitudes en adoption_requests_with_details
--    → Ve sus mascotas con adoption_status en pets_with_shelter_info
--    → Puede ver el detalle "En proceso de adopción"
--
-- 3. SHELTER aprueba:
--    → adoption_request.status = 'approved'
--    → Trigger actualiza pet.adoption_status a 'adopted'
--    → Otras solicitudes pending se rechazan automáticamente
--    → Se crea NOTIFICACIÓN para el adopter (aprobada)
--
-- 4. SHELTER rechaza:
--    → adoption_request.status = 'rejected'
--    → Si no hay otras solicitudes, pet vuelve a 'available'
--    → EL ADOPTER PUEDE VOLVER A SOLICITAR
--
-- 5. ADOPTER cancela:
--    → adoption_request se elimina o status='cancelled'
--    → Si no hay otras solicitudes, pet vuelve a 'available'
--
-- ⚠️ NOTA: Para notificaciones ejecutar: notifications_setup.sql
-- ============================================
