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
    ('0f140f6f-d994-4695-a838-bee13b3802f1', 'Skyline Tower Phase 2', 'High-rise electrical fitting', '2026-05-01', NULL, 'active'),
    ('0f140f6f-d994-4695-a838-bee13b3802f1', 'Grand Plaza Elevator', 'Lift control system install', '2026-02-28', '2026-04-12', 'completed'),
    ('0f140f6f-d994-4695-a838-bee13b3802f1', 'South Wharf Power', 'Marine electrical services', '2025-10-15', '2025-12-20', 'completed'),
    ('0f140f6f-d994-4695-a838-bee13b3802f1', 'Airport Hangar 4', 'Emergency lighting and sirens', '2026-06-10', NULL, 'active'),
    ('0f140f6f-d994-4695-a838-bee13b3802f1', 'Central Jail Security', 'CCTV and perimeter alarm grid', '2025-07-20', NULL, 'archived'),
    ('0f140f6f-d994-4695-a838-bee13b3802f1', 'Tech Hub Server Room', 'UPS and cooling power setup', '2026-03-22', NULL, 'active'),
    ('0f140f6f-d994-4695-a838-bee13b3802f1', 'Railway Yard Signals', 'Automated signaling wiring', '2026-01-30', '2026-03-30', 'completed'),
    ('0f140f6f-d994-4695-a838-bee13b3802f1', 'Green Heights Gym', 'Lighting and sound system', '2026-04-20', NULL, 'active'),

    -- SITES FOR: KK Associates (169eceeb-dfc3-4535-b6ad-2e9f8eb884d3)
    ('169eceeb-dfc3-4535-b6ad-2e9f8eb884d3', 'Green Belt Audit', 'Environmental impact consultancy', '2026-01-15', '2026-02-28', 'completed'),
    ('169eceeb-dfc3-4535-b6ad-2e9f8eb884d3', 'Highway Feasibility', 'Surveying for new bypass', '2026-03-10', NULL, 'active'),
    ('169eceeb-dfc3-4535-b6ad-2e9f8eb884d3', 'Heritage Site Restoration', 'Structural integrity advisory', '2025-08-12', NULL, 'archived'),
    ('169eceeb-dfc3-4535-b6ad-2e9f8eb884d3', 'Smart City Planning', 'Digital infrastructure consulting', '2026-02-20', NULL, 'active'),
    ('169eceeb-dfc3-4535-b6ad-2e9f8eb884d3', 'Drafting Standards 2026', 'Internal policy update', '2026-01-05', '2026-01-20', 'completed'),
    ('169eceeb-dfc3-4535-b6ad-2e9f8eb884d3', 'Urban Drainage Design', 'Hydraulic modeling for city', '2026-04-05', NULL, 'active'),
    ('169eceeb-dfc3-4535-b6ad-2e9f8eb884d3', 'Metro Extension Audit', 'Safety and compliance review', '2026-05-15', NULL, 'active'),
    ('169eceeb-dfc3-4535-b6ad-2e9f8eb884d3', 'Bridge Integrity Phase 1', 'Nondestructive testing for North Bridge', '2026-02-10', '2026-03-25', 'completed'),
    ('169eceeb-dfc3-4535-b6ad-2e9f8eb884d3', 'Coastal Erosion Survey', 'Geological impact assessment', '2025-12-05', '2026-02-15', 'completed'),
    ('169eceeb-dfc3-4535-b6ad-2e9f8eb884d3', 'Airport Terminal Planning', 'Passenger flow optimization study', '2026-07-20', NULL, 'active'),
    ('169eceeb-dfc3-4535-b6ad-2e9f8eb884d3', 'Town Hall Renovation', 'Historical preservation advisory', '2025-06-15', NULL, 'archived'),
    ('169eceeb-dfc3-4535-b6ad-2e9f8eb884d3', 'Public Transit Review', 'Efficiency analysis for bus routes', '2026-03-05', NULL, 'active'),
    ('169eceeb-dfc3-4535-b6ad-2e9f8eb884d3', 'Waterfront Masterplan', 'Urban development feasibility', '2026-01-10', '2026-04-01', 'completed'),
    ('169eceeb-dfc3-4535-b6ad-2e9f8eb884d3', 'Industrial Safety Standard', 'ISO certification consulting', '2026-04-18', NULL, 'active'),

    -- SITES FOR: KK Solar (4e01a36a-87c0-4cca-9428-a2747a130c96)
    ('4e01a36a-87c0-4cca-9428-a2747a130c96', 'Agro-Solar Farm', '3MW installation on farmland', '2026-02-15', NULL, 'active'),
    ('4e01a36a-87c0-4cca-9428-a2747a130c96', 'Tech Park Rooftop', 'Corporate office PV array', '2025-12-01', '2026-03-01', 'completed'),
    ('4e01a36a-87c0-4cca-9428-a2747a130c96', 'Solar Streetlights Phase A', 'Municipal solar project', '2026-03-15', NULL, 'active'),
    ('4e01a36a-87c0-4cca-9428-a2747a130c96', 'Old Warehouse Battery', 'Energy storage retrofit', '2025-09-10', NULL, 'archived'),
    ('4e01a36a-87c0-4cca-9428-a2747a130c96', 'Hospital Backup Array', 'Emergency solar supply', '2026-03-20', NULL, 'active'),
    ('4e01a36a-87c0-4cca-9428-a2747a130c96', 'Desert Sun Project', '50MW Utility scale solar farm', '2026-08-01', NULL, 'active'),
    ('4e01a36a-87c0-4cca-9428-a2747a130c96', 'Eco Village Microgrid', 'Community solar and battery storage', '2026-02-01', '2026-04-20', 'completed'),
    ('4e01a36a-87c0-4cca-9428-a2747a130c96', 'Retail Center Solar', 'Rooftop parking canopy PV', '2025-11-10', '2026-01-30', 'completed'),
    ('4e01a36a-87c0-4cca-9428-a2747a130c96', 'Island Power Phase 2', 'Off-grid solar for remote island', '2026-06-25', NULL, 'active'),
    ('4e01a36a-87c0-4cca-9428-a2747a130c96', 'Experimental Wind-Solar', 'Hybrid renewable test site', '2025-05-12', NULL, 'archived'),
    ('4e01a36a-87c0-4cca-9428-a2747a130c96', 'University Green Roof', 'Integrated PV and vegetation', '2026-03-12', NULL, 'active'),
    ('4e01a36a-87c0-4cca-9428-a2747a130c96', 'Data Center Solar Grid', 'Direct DC supply for servers', '2026-01-20', '2026-03-15', 'completed'),
    ('4e01a36a-87c0-4cca-9428-a2747a130c96', 'Expressway Solar Studs', 'Photovoltaic road safety markers', '2026-04-10', NULL, 'active')
ON CONFLICT DO NOTHING;