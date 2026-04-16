-- ########################################################
-- 1. EXTENSIONS & ENUMS
-- ########################################################
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Site progress tracking
DO $$ BEGIN
    CREATE TYPE site_status AS ENUM ('active', 'completed', 'archived');
EXCEPTION WHEN duplicate_object THEN null; END $$;

-- Payment methods for accounting
DO $$ BEGIN
    CREATE TYPE payment_mode AS ENUM ('cash', 'upi', 'card', 'net_banking', 'cheque', 'rtgs', 'neft', 'dd', 'other');
EXCEPTION WHEN duplicate_object THEN null; END $$;

-- ########################################################
-- 2. CORE TABLES
-- ########################################################

-- FIRMS: The three legal entities
CREATE TABLE firms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- PROFILES: Syncs with Supabase Auth to show names instead of UUIDs
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    avatar_url TEXT,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- SITES: Grouped under a firm
CREATE TABLE sites (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    firm_id UUID NOT NULL REFERENCES firms(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    started_on DATE,
    completed_on DATE,
    status site_status NOT NULL DEFAULT 'active',
    -- Soft delete and audit
    deleted_at TIMESTAMPTZ, 
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- EXPENSES: Financial records
CREATE TABLE expenses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    created_by UUID NOT NULL REFERENCES profiles(id), -- Linked to the user name
    title TEXT NOT NULL,
    description TEXT,
    amount NUMERIC(15, 2) NOT NULL DEFAULT 0.00 CHECK (amount >= 0),
    is_gst_bill BOOLEAN NOT NULL DEFAULT FALSE,
    payment_mode payment_mode NOT NULL DEFAULT 'cash',
    paid_by TEXT NOT NULL,
    paid_to TEXT NOT NULL,
    is_refundable BOOLEAN NOT NULL DEFAULT FALSE,
    attachments TEXT[] DEFAULT '{}', -- Multiple receipt/PDF URLs
    -- Soft delete and audit
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- DOCUMENTS: Site related files
CREATE TABLE documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    created_by UUID NOT NULL REFERENCES profiles(id),
    name TEXT NOT NULL,
    description TEXT,
    attachment_url TEXT NOT NULL,
    -- Soft delete and audit
    deleted_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ########################################################
-- 3. AUTOMATION (Triggers & Functions)
-- ########################################################

-- FUNCTION: Update the 'updated_at' column automatically on change
CREATE OR REPLACE FUNCTION handle_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SET search_path = pg_catalog, public
AS $$
BEGIN
    NEW.updated_at = pg_catalog.now();
    RETURN NEW;
END;
$$;

-- APPLY UPDATED_AT TRIGGERS
CREATE TRIGGER tr_firms_update BEFORE UPDATE ON firms FOR EACH ROW EXECUTE FUNCTION handle_updated_at();
CREATE TRIGGER tr_profiles_update BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION handle_updated_at();
CREATE TRIGGER tr_sites_update BEFORE UPDATE ON sites FOR EACH ROW EXECUTE FUNCTION handle_updated_at();
CREATE TRIGGER tr_expenses_update BEFORE UPDATE ON expenses FOR EACH ROW EXECUTE FUNCTION handle_updated_at();
CREATE TRIGGER tr_documents_update BEFORE UPDATE ON documents FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

-- FUNCTION: Automatically create a Profile when a user signs up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name)
  VALUES (
    new.id, 
    COALESCE(new.raw_user_meta_data->>'full_name', 'New Team Member')
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql security definer;

-- APPLY PROFILE SYNC TRIGGER
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- ########################################################
-- 4. SECURITY (RLS) & REALTIME
-- ########################################################

-- Enable RLS
ALTER TABLE firms ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE sites ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;

-- POLICY: Since it's a small team, all authenticated users have full access to everything
-- This allows anyone on the 10-person team to see/edit any of the 3 firms
CREATE POLICY "Team Full Access" ON firms FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Team Full Access" ON profiles FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Team Full Access" ON sites FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Team Full Access" ON expenses FOR ALL TO authenticated USING (true) WITH CHECK (true);
CREATE POLICY "Team Full Access" ON documents FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- REALTIME: Enable for the expenses table
ALTER PUBLICATION supabase_realtime ADD TABLE expenses;

-- PERFORMANCE: Indexes for site lookups
CREATE INDEX idx_sites_firm ON sites(firm_id);
CREATE INDEX idx_expenses_site ON expenses(site_id);
CREATE INDEX idx_documents_site ON documents(site_id);