-- ########################################################
-- SEED DATA: CORE FIRMS (Production Synced UUIDs)
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
-- SEED DATA: SITES (Distributed across 3 Firms)
-- ########################################################

INSERT INTO public.sites (firm_id, name, description, started_on, completed_on, status)
VALUES 
    -- SITES FOR: KK Electricals (0f140f6f-d994-4695-a838-bee13b3802f1)
    ('0f140f6f-d994-4695-a838-bee13b3802f1', 'City Mall Wiring', 'Full internal wiring for shopping complex', '2026-01-10', '2026-03-15', 'completed'),
    ('0f140f6f-d994-4695-a838-bee13b3802f1', 'Metro Station Lighting', 'Installation of LED arrays', '2026-04-01', NULL, 'active'),
    ('0f140f6f-d994-4695-a838-bee13b3802f1', 'Old Town Substation', 'Maintenance and transformer upgrade', '2025-11-20', NULL, 'archived'),
    ('0f140f6f-d994-4695-a838-bee13b3802f1', 'Industrial Park Phase 1', 'Main grid connection', '2026-02-05', '2026-04-10', 'completed'),
    ('0f140f6f-d994-4695-a838-bee13b3802f1', 'Riverside Apartments', 'Residential panel installations', '2026-04-15', NULL, 'active'),

    -- SITES FOR: KK Associates (169eceeb-dfc3-4535-b6ad-2e9f8eb884d3)
    ('169eceeb-dfc3-4535-b6ad-2e9f8eb884d3', 'Green Belt Audit', 'Environmental impact consultancy', '2026-01-15', '2026-02-28', 'completed'),
    ('169eceeb-dfc3-4535-b6ad-2e9f8eb884d3', 'Highway Feasibility', 'Surveying for new bypass', '2026-03-10', NULL, 'active'),
    ('169eceeb-dfc3-4535-b6ad-2e9f8eb884d3', 'Heritage Site Restoration', 'Structural integrity advisory', '2025-08-12', NULL, 'archived'),
    ('169eceeb-dfc3-4535-b6ad-2e9f8eb884d3', 'Smart City Planning', 'Digital infrastructure consulting', '2026-02-20', NULL, 'active'),
    ('169eceeb-dfc3-4535-b6ad-2e9f8eb884d3', 'Drafting Standards 2026', 'Internal policy update', '2026-01-05', '2026-01-20', 'completed'),
    ('169eceeb-dfc3-4535-b6ad-2e9f8eb884d3', 'Urban Drainage Design', 'Hydraulic modeling for city', '2026-04-05', NULL, 'active'),

    -- SITES FOR: KK Solar (4e01a36a-87c0-4cca-9428-a2747a130c96)
    ('4e01a36a-87c0-4cca-9428-a2747a130c96', 'Agro-Solar Farm', '3MW installation on farmland', '2026-02-15', NULL, 'active'),
    ('4e01a36a-87c0-4cca-9428-a2747a130c96', 'Tech Park Rooftop', 'Corporate office PV array', '2025-12-01', '2026-03-01', 'completed'),
    ('4e01a36a-87c0-4cca-9428-a2747a130c96', 'Solar Streetlights Phase A', 'Municipal solar project', '2026-03-15', NULL, 'active'),
    ('4e01a36a-87c0-4cca-9428-a2747a130c96', 'Old Warehouse Battery', 'Energy storage retrofit', '2025-09-10', NULL, 'archived'),
    ('4e01a36a-87c0-4cca-9428-a2747a130c96', 'Hospital Backup Array', 'Emergency solar supply', '2026-03-20', NULL, 'active')
ON CONFLICT DO NOTHING;