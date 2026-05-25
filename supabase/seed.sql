-- ########################################################
-- SEED DATA: CORE FIRMS (Production Synced UUIDs - DO NOT CHANGE)
-- ########################################################

INSERT INTO public.firms (id, name, description, created_at, updated_at)
VALUES 
    (
        '0f140f6f-d994-4695-a838-bee13b3802f1', 
        'KK Electricals', 
        'Electrical contracting and maintenance division', 
        '2026-04-17 14:31:33.008922+00', 
        '2026-04-17 14:31:33.008922+00'
    ),
    (
        '169eceeb-dfc3-4535-b6ad-2e9f8eb884d3', 
        'KK Associates', 
        'Consultancy and project management services', 
        '2026-04-17 14:31:33.008922+00', 
        '2026-04-17 14:31:33.008922+00'
    ),
    (
        '4e01a36a-87c0-4cca-9428-a2747a130c96', 
        'KK Solar', 
        'Solar panel installation and renewable energy projects', 
        '2026-04-17 14:31:33.008922+00', 
        '2026-04-17 14:31:33.008922+00'
    )
ON CONFLICT (id) DO NOTHING;


-- ########################################################
-- SEED DATA: STAFF PROFILES (JohnDoe)
-- ########################################################

-- Create JohnDoe in auth.users
INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    recovery_sent_at,
    last_sign_in_at,
    raw_app_meta_data,
    raw_user_meta_data,
    created_at,
    updated_at,
    confirmation_token,
    email_change,
    email_change_token_new,
    recovery_token
) VALUES (
    '00000000-0000-0000-0000-000000000000',
    'd3b07384-d113-4ec5-a50d-8d4e9ad2c2e0',
    'authenticated',
    'authenticated',
    'john@kkgroup.com',
    crypt('password123', gen_salt('bf')),
    now(),
    NULL,
    now(),
    '{"provider": "email", "providers": ["email"]}',
    '{"display_name": "JohnDoe"}',
    now(),
    now(),
    '',
    '',
    '',
    ''
) ON CONFLICT (id) DO NOTHING;

-- Explicitly ensure public.profiles has JohnDoe
INSERT INTO public.profiles (id, display_name, is_active)
VALUES ('d3b07384-d113-4ec5-a50d-8d4e9ad2c2e0', 'JohnDoe', TRUE)
ON CONFLICT (id) DO UPDATE SET display_name = 'JohnDoe', is_active = TRUE;


-- ########################################################
-- SEED DATA: SITES (One active site under each firm)
-- ########################################################

INSERT INTO public.sites (id, firm_id, name, description, started_on, status)
VALUES 
    (
        'b817c1bf-3fb8-410a-8bf8-d65239a5de62',
        '0f140f6f-d994-4695-a838-bee13b3802f1', -- KK Electricals
        'Metro Station Lighting', 
        'Installation of LED arrays and emergency alarms at central terminal', 
        '2026-04-01', 
        'active'
    ),
    (
        'c928d2cf-4fc9-420b-9cf9-e76340b6df73',
        '169eceeb-dfc3-4535-b6ad-2e9f8eb884d3', -- KK Associates
        'Smart City Planning', 
        'Digital infrastructure consulting and hydraulic modeling', 
        '2026-02-20', 
        'active'
    ),
    (
        'd039e3df-5fd0-430c-adf0-f87451c7e884',
        '4e01a36a-87c0-4cca-9428-a2747a130c96', -- KK Solar
        'Agro-Solar Farm', 
        '3MW grid installation on visual farmlands', 
        '2026-02-15', 
        'active'
    )
ON CONFLICT (id) DO NOTHING;


-- ########################################################
-- SEED DATA: EXPENSE CATEGORIES
-- ########################################################

INSERT INTO public.expense_categories (id, name, is_active)
VALUES 
    ('a1111111-1111-1111-1111-111111111111', 'Materials', TRUE),
    ('a2222222-2222-2222-2222-222222222222', 'Labor & Wages', TRUE),
    ('a3333333-3333-3333-3333-333333333333', 'Equipment Rental', TRUE),
    ('a4444444-4444-4444-4444-444444444444', 'Permits & Fees', TRUE)
ON CONFLICT (id) DO NOTHING;


-- ########################################################
-- SEED DATA: VENDORS
-- ########################################################

INSERT INTO public.vendors (id, name, contact_info, is_active)
VALUES 
    ('81111111-1111-1111-1111-111111111111', 'Apex Electrical Supplies', 'contact@apexelectrical.com', TRUE),
    ('82222222-2222-2222-2222-222222222222', 'Solar Tech Manufacturing', 'support@solartech.com', TRUE),
    ('83333333-3333-3333-3333-333333333333', 'KK Contracting Services', 'contracts@kkgroup.com', TRUE),
    ('84444444-4444-4444-4444-444444444444', 'Global Heavy Machinery', 'rentals@globalmachinery.com', TRUE)
ON CONFLICT (id) DO NOTHING;


-- ########################################################
-- SEED DATA: EXPENSES (Non-refundable under each site)
-- ########################################################

INSERT INTO public.expenses (
    id, firm_id, site_id, created_by, paid_by, title, description, 
    expense_date, category_id, vendor_id, amount, gst_percentage, gst_amount, 
    payment_mode, is_refundable
)
VALUES
    -- Expenses for Site 1: Metro Station Lighting (KK Electricals)
    (
        'e1111111-1111-1111-1111-111111111111',
        '0f140f6f-d994-4695-a838-bee13b3802f1',
        'b817c1bf-3fb8-410a-8bf8-d65239a5de62',
        'd3b07384-d113-4ec5-a50d-8d4e9ad2c2e0',
        'd3b07384-d113-4ec5-a50d-8d4e9ad2c2e0',
        'Electrical Cable Supply',
        'Heavy-duty copper conduit cable reels for main terminal feeds',
        '2026-04-12',
        'a1111111-1111-1111-1111-111111111111', -- Materials
        '81111111-1111-1111-1111-111111111111', -- Apex Electrical Supplies
        15000.00,
        18.00,
        2700.00,
        'upi',
        FALSE
    ),
    (
        'e2222222-2222-2222-2222-222222222222',
        '0f140f6f-d994-4695-a838-bee13b3802f1',
        'b817c1bf-3fb8-410a-8bf8-d65239a5de62',
        'd3b07384-d113-4ec5-a50d-8d4e9ad2c2e0',
        'd3b07384-d113-4ec5-a50d-8d4e9ad2c2e0',
        'Site Helper Wages',
        'Daily wage distribution for helper assistance on cabling layout',
        '2026-04-15',
        'a2222222-2222-2222-2222-222222222222', -- Labor & Wages
        NULL,
        4500.00,
        NULL,
        NULL,
        'cash',
        FALSE
    ),

    -- Expenses for Site 2: Smart City Planning (KK Associates)
    (
        'e3333333-3333-3333-3333-333333333333',
        '169eceeb-dfc3-4535-b6ad-2e9f8eb884d3',
        'c928d2cf-4fc9-420b-9cf9-e76340b6df73',
        'd3b07384-d113-4ec5-a50d-8d4e9ad2c2e0',
        'd3b07384-d113-4ec5-a50d-8d4e9ad2c2e0',
        'Topographic Survey Permit',
        'Municipal planning council fee for aerial bypass survey authorization',
        '2026-03-05',
        'a4444444-4444-4444-4444-444444444444', -- Permits & Fees
        NULL,
        1200.00,
        NULL,
        NULL,
        'other',
        FALSE
    ),
    (
        'e4444444-4444-4444-4444-444444444444',
        '169eceeb-dfc3-4535-b6ad-2e9f8eb884d3',
        'c928d2cf-4fc9-420b-9cf9-e76340b6df73',
        'd3b07384-d113-4ec5-a50d-8d4e9ad2c2e0',
        'd3b07384-d113-4ec5-a50d-8d4e9ad2c2e0',
        'Drafting Software Subscription',
        'Engineering CAD and structural modeling suite license renewals',
        '2026-03-25',
        'a1111111-1111-1111-1111-111111111111', -- Materials (Software)
        '83333333-3333-3333-3333-333333333333', -- KK Contracting Services
        8500.00,
        18.00,
        1530.00,
        'card',
        FALSE
    ),

    -- Expenses for Site 3: Agro-Solar Farm (KK Solar)
    (
        'e5555555-5555-5555-5555-555555555555',
        '4e01a36a-87c0-4cca-9428-a2747a130c96',
        'd039e3df-5fd0-430c-adf0-f87451c7e884',
        'd3b07384-d113-4ec5-a50d-8d4e9ad2c2e0',
        'd3b07384-d113-4ec5-a50d-8d4e9ad2c2e0',
        'Solar Panel Mounting Rails',
        'Galvanized steel structural rails for multi-angle panel mount racks',
        '2026-03-10',
        'a1111111-1111-1111-1111-111111111111', -- Materials
        '82222222-2222-2222-2222-222222222222', -- Solar Tech Manufacturing
        28000.00,
        12.00,
        3360.00,
        'rtgs',
        FALSE
    ),
    (
        'e6666666-6666-6666-6666-666666666666',
        '4e01a36a-87c0-4cca-9428-a2747a130c96',
        'd039e3df-5fd0-430c-adf0-f87451c7e884',
        'd3b07384-d113-4ec5-a50d-8d4e9ad2c2e0',
        'd3b07384-d113-4ec5-a50d-8d4e9ad2c2e0',
        'Excavator Site Rental',
        '3-day rent for trench digger assisting underground layout cabling',
        '2026-03-18',
        'a3333333-3333-3333-3333-333333333333', -- Equipment Rental
        '84444444-4444-4444-4444-444444444444', -- Global Heavy Machinery
        12500.00,
        18.00,
        2250.00,
        'neft',
        FALSE
    )
ON CONFLICT (id) DO NOTHING;