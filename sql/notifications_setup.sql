-- ============================================
-- 🔔 NOTIFICATIONS SYSTEM - PETADOPT
-- ============================================
-- Sistema de notificaciones usando Supabase Realtime
-- SIN Firebase - Solo flutter_local_notifications + Supabase
--
-- Mensajes fijos:
--   - Shelter: "Nueva solicitud de adopción recibida"
--   - Adopter (aprobada): "Tu solicitud de adopción ha sido aprobada"
--   - Adopter (rechazada): "Tu solicitud de adopción ha sido rechazada"
-- ============================================

-- ============================================
-- 1️⃣ CREAR TABLA NOTIFICATIONS
-- ============================================
DROP TABLE IF EXISTS public.notifications CASCADE;

CREATE TABLE public.notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  type VARCHAR(50) NOT NULL CHECK (type IN (
    'NEW_ADOPTION_REQUEST',
    'ADOPTION_REQUEST_APPROVED',
    'ADOPTION_REQUEST_REJECTED'
  )),
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================
-- 2️⃣ ÍNDICES
-- ============================================
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_notifications_is_read ON public.notifications(user_id, is_read);
CREATE INDEX idx_notifications_created_at ON public.notifications(created_at DESC);

-- ============================================
-- 3️⃣ ROW LEVEL SECURITY
-- ============================================
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users view own notifications" ON public.notifications;
CREATE POLICY "Users view own notifications"
  ON public.notifications FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users update own notifications" ON public.notifications;
CREATE POLICY "Users update own notifications"
  ON public.notifications FOR UPDATE
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "System insert notifications" ON public.notifications;
CREATE POLICY "System insert notifications"
  ON public.notifications FOR INSERT
  WITH CHECK (true);

-- ============================================
-- 4️⃣ GRANTS
-- ============================================
GRANT SELECT, UPDATE ON public.notifications TO authenticated;
GRANT INSERT ON public.notifications TO authenticated;

-- ============================================
-- 5️⃣ FUNCIÓN: NOTIFICAR AL SHELTER (NUEVA SOLICITUD)
-- ============================================
CREATE OR REPLACE FUNCTION public.notify_shelter_new_request()
RETURNS TRIGGER AS $$
DECLARE
  v_shelter_profile_id UUID;
BEGIN
  IF NEW.status = 'pending' THEN
    -- Obtener profile_id del shelter
    SELECT profile_id INTO v_shelter_profile_id
    FROM public.shelters WHERE id = NEW.shelter_id;
    
    IF v_shelter_profile_id IS NOT NULL THEN
      INSERT INTO public.notifications (user_id, type, title, message)
      VALUES (
        v_shelter_profile_id,
        'NEW_ADOPTION_REQUEST',
        'Nueva solicitud',
        'Nueva solicitud de adopción recibida'
      );
    END IF;
  END IF;
  
  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 6️⃣ FUNCIÓN: NOTIFICAR AL ADOPTER (APROBACIÓN/RECHAZO)
-- ============================================
CREATE OR REPLACE FUNCTION public.notify_adopter_request_update()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.status = 'pending' AND NEW.status = 'approved' THEN
    INSERT INTO public.notifications (user_id, type, title, message)
    VALUES (
      NEW.adopter_id,
      'ADOPTION_REQUEST_APPROVED',
      'Solicitud aprobada',
      'Tu solicitud de adopción ha sido aprobada'
    );
  ELSIF OLD.status = 'pending' AND NEW.status = 'rejected' THEN
    INSERT INTO public.notifications (user_id, type, title, message)
    VALUES (
      NEW.adopter_id,
      'ADOPTION_REQUEST_REJECTED',
      'Solicitud rechazada',
      'Tu solicitud de adopción ha sido rechazada'
    );
  END IF;
  
  RETURN NEW;
EXCEPTION WHEN OTHERS THEN
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================
-- 7️⃣ TRIGGERS
-- ============================================
DROP TRIGGER IF EXISTS trigger_notify_shelter_new_request ON public.adoption_requests;
CREATE TRIGGER trigger_notify_shelter_new_request
AFTER INSERT ON public.adoption_requests
FOR EACH ROW
EXECUTE FUNCTION public.notify_shelter_new_request();

DROP TRIGGER IF EXISTS trigger_notify_adopter_request_update ON public.adoption_requests;
CREATE TRIGGER trigger_notify_adopter_request_update
AFTER UPDATE ON public.adoption_requests
FOR EACH ROW
EXECUTE FUNCTION public.notify_adopter_request_update();

-- ============================================
-- 8️⃣ HABILITAR REALTIME
-- ============================================
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_publication_tables 
    WHERE pubname = 'supabase_realtime' 
    AND tablename = 'notifications'
  ) THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
  END IF;
END $$;

-- ============================================
-- ✅ SETUP COMPLETADO
-- ============================================
