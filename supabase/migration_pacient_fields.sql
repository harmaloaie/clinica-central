-- ════════════════════════════════════════════════════════════════
-- MIGRARE: Adauga campuri pentru pacient in cc_cereri
--
-- Adauga coloanele:
--   - pacient_prenume     (text, optional)
--   - pacient_nume        (text, optional)
--   - pacient_email       (text, optional)
--   - pacient_telefon_prefix (text, optional)
--   - pacient_telefon_numar  (text, optional)
--
-- Coloana existenta `cnp_pacient` RAMANE NEATINSA.
-- Coloanele noi sunt nullable, deci datele existente nu sunt afectate.
--
-- ATENTIE: Ruleaza acest script pe AMBELE proiecte Supabase:
--   1. Proiectul de STAGING (intai)
--   2. Proiectul de PRODUCTION (dupa ce stage merge ok)
-- ════════════════════════════════════════════════════════════════

ALTER TABLE public.cc_cereri
  ADD COLUMN IF NOT EXISTS pacient_prenume text,
  ADD COLUMN IF NOT EXISTS pacient_nume text,
  ADD COLUMN IF NOT EXISTS pacient_email text,
  ADD COLUMN IF NOT EXISTS pacient_telefon_prefix text,
  ADD COLUMN IF NOT EXISTS pacient_telefon_numar text;

-- Index pe nume pentru cautare mai rapida
CREATE INDEX IF NOT EXISTS cc_cereri_pacient_nume_idx
  ON public.cc_cereri (pacient_nume, pacient_prenume);

-- ────────────────────────────────────────────────────────────────
-- VERIFICARE — listeaza coloanele tabelei cc_cereri
-- ────────────────────────────────────────────────────────────────
-- Dupa rulare, ar trebui sa vezi (printre altele):
--   cnp_pacient, pacient_prenume, pacient_nume,
--   pacient_email, pacient_telefon_prefix, pacient_telefon_numar
--
-- SELECT column_name, data_type, is_nullable
-- FROM information_schema.columns
-- WHERE table_schema = 'public' AND table_name = 'cc_cereri'
-- ORDER BY ordinal_position;
-- ────────────────────────────────────────────────────────────────
