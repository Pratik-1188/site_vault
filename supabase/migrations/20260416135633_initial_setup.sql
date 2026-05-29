-- ########################################################
-- 1. EXTENSIONS & ENUMS
-- ########################################################

-- UUID generator
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Site lifecycle status
DO $$ BEGIN
CREATE TYPE site_status AS ENUM ('active', 'completed', 'deleted');
EXCEPTION WHEN duplicate_object THEN null; END $$;

-- Payment modes used in expenses
DO $$ BEGIN
CREATE TYPE payment_mode AS ENUM (
'cash', 'upi', 'card', 'net_banking',
'cheque', 'rtgs', 'neft', 'dd', 'other'
);
EXCEPTION WHEN duplicate_object THEN null; END $$;

-- ########################################################
-- 2. CORE BUSINESS TABLES
-- ########################################################

-- FIRMS: Top-level business entities
CREATE TABLE firms (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
name TEXT NOT NULL,
description TEXT,
created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- PROFILES: Application users
CREATE TABLE profiles (
id UUID PRIMARY KEY,
display_name TEXT NOT NULL,
is_active BOOLEAN DEFAULT TRUE,
created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
CONSTRAINT chk_display_name_no_spaces CHECK (
    display_name !~ '\s'
)
);
-- Case-insensitive unique display_name
CREATE UNIQUE INDEX unique_display_name_lower
ON profiles (LOWER(display_name));

-- SITES: Projects under firms
CREATE TABLE sites (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
firm_id UUID NOT NULL REFERENCES firms(id) ON DELETE CASCADE,

name TEXT NOT NULL,
description TEXT,

started_on DATE,
completed_on DATE,

status site_status NOT NULL DEFAULT 'active',

CONSTRAINT chk_site_dates CHECK (
    completed_on IS NULL OR
    (started_on IS NOT NULL AND completed_on >= started_on)
),
created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Needed for composite FK
CREATE UNIQUE INDEX idx_sites_id_firm
ON sites(id, firm_id);

-- ########################################################
-- 3. SUPPORT TABLES
-- ########################################################

-- EXPENSE CATEGORIES
CREATE TABLE expense_categories (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
name TEXT NOT NULL,
is_active BOOLEAN DEFAULT TRUE,
created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE UNIQUE INDEX unique_category_name_lower
ON expense_categories (LOWER(name));

-- VENDORS
CREATE TABLE vendors (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
name TEXT NOT NULL,
contact_info TEXT,
is_active BOOLEAN DEFAULT TRUE,
created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE UNIQUE INDEX unique_vendor_name_lower
ON vendors (LOWER(name));

-- ########################################################
-- 4. EXPENSES
-- ########################################################

CREATE TABLE expenses (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

firm_id UUID NOT NULL,
site_id UUID NOT NULL,

created_by UUID NOT NULL REFERENCES profiles(id),

title TEXT NOT NULL,
description TEXT,
attachment_path TEXT,

expense_date DATE NOT NULL,

category_id UUID REFERENCES expense_categories(id),
vendor_id UUID REFERENCES vendors(id),

amount NUMERIC(15, 2) NOT NULL CHECK (amount > 0),

gst_percentage NUMERIC(5,2),
gst_amount NUMERIC(15,2),

payment_mode payment_mode NOT NULL DEFAULT 'cash',

is_refundable BOOLEAN NOT NULL DEFAULT FALSE,

-- Soft delete
soft_deleted_at TIMESTAMPTZ,
created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

-- Validate GST %
CONSTRAINT chk_gst_percentage CHECK (
    gst_percentage IS NULL OR 
    (gst_percentage >= 0 AND gst_percentage <= 100)
),

-- Prevent empty titles
CONSTRAINT chk_title_length CHECK (
    length(trim(title)) > 2
)
);

-- Enforce site belongs to firm
ALTER TABLE expenses
ADD CONSTRAINT fk_expense_site_firm
FOREIGN KEY (site_id, firm_id)
REFERENCES sites(id, firm_id)
ON DELETE CASCADE;

-- ########################################################
-- 5. ATTACHMENTS & DOCUMENTS
-- ########################################################

-- DOCUMENTS
CREATE TABLE documents (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),


site_id UUID NOT NULL REFERENCES sites(id) ON DELETE CASCADE,

created_by UUID NOT NULL REFERENCES profiles(id),

file_name TEXT NOT NULL,
description TEXT,
file_url TEXT NOT NULL,

-- Soft delete
soft_deleted_at TIMESTAMPTZ,
created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);


-- ########################################################
-- 6. AUTOMATION (TRIGGERS)
-- ########################################################

-- Auto-update updated_at
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

-- Soft-delete expenses when a site is marked deleted
CREATE OR REPLACE FUNCTION public.handle_site_deleted()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
UPDATE public.expenses
SET soft_deleted_at = COALESCE(soft_deleted_at, NOW())
WHERE site_id = NEW.id
  AND firm_id = NEW.firm_id
  AND soft_deleted_at IS NULL;
RETURN NEW;
END;
$$;

-- Create a storage bucket and default folders when a site is created
CREATE OR REPLACE FUNCTION public.handle_site_created()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, storage
AS $$
DECLARE
  v_bucket_id text := NEW.id::text;
BEGIN
  INSERT INTO storage.buckets (id, name, public)
  VALUES (v_bucket_id, v_bucket_id, false)
  ON CONFLICT (id) DO NOTHING;

  INSERT INTO storage.objects (bucket_id, name)
  VALUES (v_bucket_id, 'documents/.init')
  ON CONFLICT (bucket_id, name) DO NOTHING;

  INSERT INTO storage.objects (bucket_id, name)
  VALUES (v_bucket_id, 'expenses/.init')
  ON CONFLICT (bucket_id, name) DO NOTHING;

  RETURN NEW;
END;
$$;

-- Apply trigger everywhere needed
CREATE TRIGGER tr_firms_update BEFORE UPDATE ON firms FOR EACH ROW EXECUTE FUNCTION handle_updated_at();
CREATE TRIGGER tr_profiles_update BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION handle_updated_at();
CREATE TRIGGER tr_sites_update BEFORE UPDATE ON sites FOR EACH ROW EXECUTE FUNCTION handle_updated_at();
CREATE TRIGGER tr_expense_categories_update BEFORE UPDATE ON expense_categories FOR EACH ROW EXECUTE FUNCTION handle_updated_at();
CREATE TRIGGER tr_vendors_update BEFORE UPDATE ON vendors FOR EACH ROW EXECUTE FUNCTION handle_updated_at();
CREATE TRIGGER tr_expenses_update BEFORE UPDATE ON expenses FOR EACH ROW EXECUTE FUNCTION handle_updated_at();
CREATE TRIGGER tr_documents_update BEFORE UPDATE ON documents FOR EACH ROW EXECUTE FUNCTION handle_updated_at();
CREATE TRIGGER tr_sites_soft_delete_expenses AFTER UPDATE OF status ON sites FOR EACH ROW WHEN (NEW.status = 'deleted' AND OLD.status IS DISTINCT FROM NEW.status) EXECUTE FUNCTION public.handle_site_deleted();
CREATE TRIGGER tr_sites_create_storage AFTER INSERT ON sites FOR EACH ROW EXECUTE FUNCTION public.handle_site_created();

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
INSERT INTO public.profiles (id, display_name)
VALUES (
new.id,
COALESCE(
    NULLIF(new.raw_user_meta_data->>'display_name', ''),
    NULLIF(split_part(new.email, '@', 1), ''),
    'user_' || substr(new.id::text, 1, 8)
)
);
RETURN new;
END;
$$;

CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- Mark profile inactive when auth user is deleted
CREATE OR REPLACE FUNCTION public.handle_deleted_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
UPDATE public.profiles
SET
    is_active = FALSE,
    updated_at = NOW()
WHERE id = old.id;
RETURN old;
END;
$$;

CREATE TRIGGER on_auth_user_deleted
BEFORE DELETE ON auth.users
FOR EACH ROW EXECUTE PROCEDURE public.handle_deleted_user();

-- ########################################################
-- 7. PERFORMANCE INDEXES (IMPORTANT FOR ANALYTICS)
-- ########################################################

CREATE INDEX idx_expenses_site ON expenses(site_id);
CREATE INDEX idx_expenses_firm ON expenses(firm_id);
CREATE INDEX idx_expenses_date ON expenses(expense_date);
CREATE INDEX idx_expenses_category ON expenses(category_id);

CREATE INDEX idx_documents_site ON documents(site_id);

-- ########################################################
-- 8. Logging
-- ########################################################

CREATE TABLE public.audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    table_name TEXT NOT NULL,
    operation TEXT NOT NULL, -- 'INSERT', 'UPDATE', or 'DELETE'
    record_id UUID,          -- ID of the altered record
    old_data JSONB,          -- Null on INSERT
    new_data JSONB,          -- Null on DELETE
    changed_by UUID REFERENCES public.profiles(id), -- Tracks your user profile
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Turn on standard index tracking for fast system searching later
CREATE INDEX idx_audit_table ON public.audit_logs(table_name);
CREATE INDEX idx_audit_user ON public.audit_logs(changed_by);

CREATE TRIGGER tr_audit_logs_update BEFORE UPDATE ON public.audit_logs FOR EACH ROW EXECUTE FUNCTION handle_updated_at();

CREATE OR REPLACE FUNCTION public.process_audit_log()
RETURNS TRIGGER AS $$
DECLARE
    current_user_id UUID;
    target_id UUID;
BEGIN
    -- 1. Extract the active Supabase User UUID from the transaction context metadata
    BEGIN
        current_user_id := auth.uid();
    EXCEPTION WHEN OTHERS THEN
        current_user_id := NULL; -- Handles fallback edge-cases (like system seed files running)
    END;

    -- 2. Extract the target record's unique ID dynamically
    IF (TG_OP = 'DELETE') THEN
        target_id := OLD.id;
    ELSE
        target_id := NEW.id;
    END IF;

    -- 3. Ingest the data tracking variables into our ledger
    INSERT INTO public.audit_logs (
        table_name,
        operation,
        record_id,
        old_data,
        new_data,
        changed_by
    )
    VALUES (
        TG_TABLE_NAME, -- Automatically inserts the name of the target database table
        TG_OP,         -- Automatically inserts 'INSERT', 'UPDATE', or 'DELETE'
        target_id,
        CASE WHEN TG_OP IN ('UPDATE', 'DELETE') THEN to_jsonb(OLD) ELSE NULL END,
        CASE WHEN TG_OP IN ('INSERT', 'UPDATE') THEN to_jsonb(NEW) ELSE NULL END,
        current_user_id
    );

    -- Keep out of the way of the original operation loop
    IF (TG_OP = 'DELETE') THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 1. Track Corporate Entities
CREATE TRIGGER tr_audit_firms
AFTER INSERT OR UPDATE OR DELETE ON public.firms
FOR EACH ROW EXECUTE FUNCTION public.process_audit_log();

-- 2. Track Team Profiles
CREATE TRIGGER tr_audit_profiles
AFTER INSERT OR UPDATE OR DELETE ON public.profiles
FOR EACH ROW EXECUTE FUNCTION public.process_audit_log();

-- 3. Track Project Sites
CREATE TRIGGER tr_audit_sites
AFTER INSERT OR UPDATE OR DELETE ON public.sites
FOR EACH ROW EXECUTE FUNCTION public.process_audit_log();

-- 4. Track Expense Categories
CREATE TRIGGER tr_audit_expense_categories
AFTER INSERT OR UPDATE OR DELETE ON public.expense_categories
FOR EACH ROW EXECUTE FUNCTION public.process_audit_log();

-- 5. Track Vendor Registers
CREATE TRIGGER tr_audit_vendors
AFTER INSERT OR UPDATE OR DELETE ON public.vendors
FOR EACH ROW EXECUTE FUNCTION public.process_audit_log();

-- 6. Track Financial Ledger Entries
CREATE TRIGGER tr_audit_expenses
AFTER INSERT OR UPDATE OR DELETE ON public.expenses
FOR EACH ROW EXECUTE FUNCTION public.process_audit_log();

-- 7. Track Site Reference Documents
CREATE TRIGGER tr_audit_documents
AFTER INSERT OR UPDATE OR DELETE ON public.documents
FOR EACH ROW EXECUTE FUNCTION public.process_audit_log();

-- ########################################################
-- 9. SECURITY (RLS)
-- ########################################################

ALTER TABLE firms ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE sites ENABLE ROW LEVEL SECURITY;
ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE expense_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE vendors ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- Simple full access (small trusted team)
CREATE POLICY "Team Full Access" ON firms
FOR ALL TO authenticated, anon
USING (true)
WITH CHECK (true);

CREATE POLICY "Team Full Access" ON profiles
FOR ALL TO authenticated, anon
USING (true)
WITH CHECK (true);

CREATE POLICY "Team Full Access" ON sites
FOR ALL TO authenticated, anon
USING (true)
WITH CHECK (true);

CREATE POLICY "Team Full Access" ON expenses
FOR ALL TO authenticated, anon
USING (true)
WITH CHECK (true);

CREATE POLICY "Team Full Access" ON documents
FOR ALL TO authenticated, anon
USING (true)
WITH CHECK (true);

CREATE POLICY "Team Full Access" ON expense_categories
FOR ALL TO authenticated, anon
USING (true)
WITH CHECK (true);

CREATE POLICY "Team Full Access" ON vendors
FOR ALL TO authenticated, anon
USING (true)
WITH CHECK (true);

CREATE POLICY "Team Full Access" ON storage.objects
FOR ALL TO authenticated, anon
USING (true)
WITH CHECK (true);

CREATE POLICY "Team Full Access" ON audit_logs
FOR ALL TO authenticated, anon
USING (true)
WITH CHECK (true);
