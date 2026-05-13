-- ════════════════════════════════════════════════════════════════
-- CLINICA CENTRAL — Schema Supabase
-- 
-- Acest script CREEAZA tabele complet noi cu prefix `cc_`.
-- NU MODIFICA nimic existent (carduri, etc.).
-- 
-- ATENTIE: Ruleaza acest script pe AMBELE proiecte Supabase:
--   1. Proiectul de STAGING
--   2. Proiectul de PRODUCTION
-- ════════════════════════════════════════════════════════════════


-- ────────────────────────────────────────────────────────────────
-- 1. TABELA: cc_useri_acces
--    Cine are voie sa intre in aplicatia Clinica Central.
--    Tabela noua, separata de useri_clinica (de la carduri).
-- ────────────────────────────────────────────────────────────────
create table if not exists public.cc_useri_acces (
  user_id uuid primary key references auth.users(id) on delete cascade,
  email text not null,
  nume text,
  acces_central boolean default true,
  adaugat_de uuid references auth.users(id),
  created_at timestamptz default now()
);

alter table public.cc_useri_acces enable row level security;

-- Userii cu acces isi pot vedea propria intrare (pentru afisare nume in topbar)
create policy "Useri cu acces isi vad propria intrare"
  on public.cc_useri_acces for select
  using (auth.uid() = user_id);

-- Doar service_role (sau admin manual din UI) pot adauga useri noi.
-- Daca vrei sa permiti adminilor sa adauge useri din aplicatie, adauga policy aici.


-- ────────────────────────────────────────────────────────────────
-- 2. TABELA: cc_cereri
--    Istoricul tuturor cererilor de analize procesate.
-- ────────────────────────────────────────────────────────────────
create table if not exists public.cc_cereri (
  id uuid primary key default gen_random_uuid(),
  cnp_pacient text not null,
  user_id uuid references auth.users(id),
  user_email text,
  
  -- Sumar pentru listing rapid
  numar_analize int not null,
  numar_laboratoare int not null,
  numar_eprubete int not null,
  total_lista_ron numeric(10,2) not null,
  total_final_ron numeric(10,2) not null,
  economie_ron numeric(10,2) not null,
  
  -- Detalii complete ca JSONB
  items jsonb not null,         -- toate analizele cu denumire, pret, laborator, detalii
  groups jsonb not null,        -- grupate pe laboratoare
  eprubete jsonb not null,      -- sumar eprubete
  discounts jsonb not null,     -- discount-uri aplicate la momentul cererii
  
  -- Metadata
  created_at timestamptz default now(),
  notes text                    -- observatii manuale
);

create index if not exists cc_cereri_cnp_idx on public.cc_cereri (cnp_pacient);
create index if not exists cc_cereri_created_at_idx on public.cc_cereri (created_at desc);
create index if not exists cc_cereri_user_idx on public.cc_cereri (user_id);

alter table public.cc_cereri enable row level security;

-- Useri cu acces_central in cc_useri_acces pot vedea toate cererile
create policy "Cereri vizibile pentru useri cu acces central"
  on public.cc_cereri for select
  using (
    exists (
      select 1 from public.cc_useri_acces
      where user_id = auth.uid() and acces_central = true
    )
  );

create policy "Useri cu acces central pot crea cereri"
  on public.cc_cereri for insert
  with check (
    exists (
      select 1 from public.cc_useri_acces
      where user_id = auth.uid() and acces_central = true
    )
  );

create policy "Useri cu acces central pot edita cereri"
  on public.cc_cereri for update
  using (
    exists (
      select 1 from public.cc_useri_acces
      where user_id = auth.uid() and acces_central = true
    )
  );


-- ────────────────────────────────────────────────────────────────
-- VERIFICARE — listeaza tabelele create
-- ────────────────────────────────────────────────────────────────
-- Ruleaza dupa script ca sa vezi ca s-au creat tabelele:
--
-- select table_name from information_schema.tables
-- where table_schema = 'public' and table_name like 'cc_%';
-- 
-- Trebuie sa vezi: cc_useri_acces, cc_cereri
-- ────────────────────────────────────────────────────────────────


-- ════════════════════════════════════════════════════════════════
-- DUPA RULAREA SCRIPTULUI — pasi manuali:
-- ════════════════════════════════════════════════════════════════
--
-- 1. Adauga useri cu acces:
--    a. Authentication → Users → vezi (sau creezi) userul
--    b. Copiezi user_id (UUID)
--    c. Table Editor → cc_useri_acces → Insert row:
--         - user_id: <UUID>
--         - email:   <email>
--         - nume:    <numele>
--         - acces_central: true (default)
--
-- 2. Configurezi Authentication:
--    a. Authentication → Providers → Email → Enable: ON
--    b. Confirm email: OFF (sau ON daca vrei verificare prin email)
--    c. Allow new users to sign up: OFF (asa, doar adminul adauga useri)
--
-- ════════════════════════════════════════════════════════════════
