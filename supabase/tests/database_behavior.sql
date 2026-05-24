DO $$
DECLARE
  profile_name text;
  profile_active boolean;
  temp_firm uuid;
  temp_site uuid;
  temp_doc uuid;
  original_ts timestamptz;
  updated_ts timestamptz;
  doc_count integer;
  total_spend numeric;
BEGIN
  -- Profile display name falls back to the email prefix.
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
    '11111111-1111-1111-1111-111111111111',
    'authenticated',
    'authenticated',
    'johndoe143@gmail.com',
    crypt('password123', gen_salt('bf')),
    now(),
    NULL,
    now(),
    '{"provider": "email", "providers": ["email"]}',
    NULL,
    now(),
    now(),
    '',
    '',
    '',
    ''
  );

  SELECT display_name, is_active
  INTO profile_name, profile_active
  FROM profiles
  WHERE id = '11111111-1111-1111-1111-111111111111';

  IF profile_name IS DISTINCT FROM 'johndoe143' THEN
    RAISE EXCEPTION 'profile display name should come from email prefix';
  END IF;

  IF profile_active IS DISTINCT FROM TRUE THEN
    RAISE EXCEPTION 'new profile should be active';
  END IF;

  -- Explicit display_name should win over the email prefix.
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
    '22222222-2222-2222-2222-222222222222',
    'authenticated',
    'authenticated',
    'alpha@example.com',
    crypt('password123', gen_salt('bf')),
    now(),
    NULL,
    now(),
    '{"provider": "email", "providers": ["email"]}',
    '{"display_name": "Alpha"}',
    now(),
    now(),
    '',
    '',
    '',
    ''
  );

  SELECT display_name
  INTO profile_name
  FROM profiles
  WHERE id = '22222222-2222-2222-2222-222222222222';

  IF profile_name IS DISTINCT FROM 'Alpha' THEN
    RAISE EXCEPTION 'explicit display name should win over email prefix';
  END IF;

  -- Deleting the auth user should keep the profile and flip it inactive.
  DELETE FROM auth.users
  WHERE id = '11111111-1111-1111-1111-111111111111';

  SELECT is_active
  INTO profile_active
  FROM profiles
  WHERE id = '11111111-1111-1111-1111-111111111111';

  IF profile_active IS DISTINCT FROM FALSE THEN
    RAISE EXCEPTION 'profile should remain and be marked inactive after auth delete';
  END IF;

  -- Clean up the first profile row now that we have verified the delete behavior.
  DELETE FROM profiles
  WHERE id = '11111111-1111-1111-1111-111111111111';

  -- Duplicate display names should be rejected case-insensitively.
  BEGIN
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
      '33333333-3333-3333-3333-333333333333',
      'authenticated',
      'authenticated',
      'alpha2@example.com',
      crypt('password123', gen_salt('bf')),
      now(),
      NULL,
      now(),
      '{"provider": "email", "providers": ["email"]}',
      '{"display_name": "Alpha"}',
      now(),
      now(),
      '',
      '',
      '',
      ''
    );
    RAISE EXCEPTION 'duplicate display_name should fail';
  EXCEPTION
    WHEN unique_violation THEN
      NULL;
  END;

  -- Clean up the Alpha profile after verifying uniqueness.
  DELETE FROM auth.users
  WHERE id = '22222222-2222-2222-2222-222222222222';
  DELETE FROM profiles
  WHERE id = '22222222-2222-2222-2222-222222222222';

  -- Create a reusable test-only user for expense and document rows.
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
    '44444444-4444-4444-4444-444444444444',
    'authenticated',
    'authenticated',
    'tempdoc@example.com',
    crypt('password123', gen_salt('bf')),
    now(),
    NULL,
    now(),
    '{"provider": "email", "providers": ["email"]}',
    '{"display_name": "TempDocUser"}',
    now(),
    now(),
    '',
    '',
    '',
    ''
  );

  -- Site date validation: completed_on requires started_on.
  BEGIN
    INSERT INTO sites (id, firm_id, name, started_on, completed_on, status)
    VALUES (
      gen_random_uuid(),
      '0f140f6f-d994-4695-a838-bee13b3802f1',
      'Invalid Site',
      NULL,
      CURRENT_DATE,
      'active'
    );
    RAISE EXCEPTION 'completed_on without started_on should fail';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
  END;

  -- Expense amount must be greater than zero.
  BEGIN
    INSERT INTO expenses (
      firm_id,
      site_id,
      created_by,
      paid_by,
      title,
      expense_date,
      amount,
      payment_mode,
      is_refundable
    ) VALUES (
      '0f140f6f-d994-4695-a838-bee13b3802f1',
      'b817c1bf-3fb8-410a-8bf8-d65239a5de62',
      '44444444-4444-4444-4444-444444444444',
      '44444444-4444-4444-4444-444444444444',
      'Zero Expense',
      CURRENT_DATE,
      0,
      'cash',
      false
    );
    RAISE EXCEPTION 'amount = 0 should fail';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
  END;

  -- GST percentage must stay within 0..100.
  BEGIN
    INSERT INTO expenses (
      firm_id,
      site_id,
      created_by,
      paid_by,
      title,
      expense_date,
      amount,
      gst_percentage,
      payment_mode,
      is_refundable
    ) VALUES (
      '0f140f6f-d994-4695-a838-bee13b3802f1',
      'b817c1bf-3fb8-410a-8bf8-d65239a5de62',
      '44444444-4444-4444-4444-444444444444',
      '44444444-4444-4444-4444-444444444444',
      'Bad GST',
      CURRENT_DATE,
      100,
      101,
      'cash',
      false
    );
    RAISE EXCEPTION 'gst_percentage above 100 should fail';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
  END;

  -- Title must be longer than 2 trimmed characters.
  BEGIN
    INSERT INTO expenses (
      firm_id,
      site_id,
      created_by,
      paid_by,
      title,
      expense_date,
      amount,
      payment_mode,
      is_refundable
    ) VALUES (
      '0f140f6f-d994-4695-a838-bee13b3802f1',
      'b817c1bf-3fb8-410a-8bf8-d65239a5de62',
      'd3b07384-d113-4ec5-a50d-8d4e9ad2c2e0',
      'd3b07384-d113-4ec5-a50d-8d4e9ad2c2e0',
      '  a ',
      CURRENT_DATE,
      100,
      'cash',
      false
    );
    RAISE EXCEPTION 'short title should fail';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
  END;

  -- Expense firm/site mismatch should fail the composite FK.
  BEGIN
    INSERT INTO expenses (
      firm_id,
      site_id,
      created_by,
      paid_by,
      title,
      expense_date,
      amount,
      payment_mode,
      is_refundable
    ) VALUES (
      '169eceeb-dfc3-4535-b6ad-2e9f8eb884d3',
      'b817c1bf-3fb8-410a-8bf8-d65239a5de62',
      '44444444-4444-4444-4444-444444444444',
      '44444444-4444-4444-4444-444444444444',
      'Firm mismatch',
      CURRENT_DATE,
      100,
      'cash',
      false
    );
    RAISE EXCEPTION 'mismatched firm and site should fail';
  EXCEPTION
    WHEN foreign_key_violation THEN
      NULL;
  END;

  -- Document update trigger should refresh updated_at.
  temp_firm := gen_random_uuid();
  temp_site := gen_random_uuid();

  INSERT INTO firms (id, name, description, created_at, updated_at)
  VALUES (
    temp_firm,
    'Temp Test Firm',
    'Temporary test-only firm',
    TIMESTAMPTZ '2000-01-01 00:00:00+00',
    TIMESTAMPTZ '2000-01-01 00:00:00+00'
  );

  INSERT INTO sites (id, firm_id, name, started_on, status, created_at, updated_at)
  VALUES (
    temp_site,
    temp_firm,
    'Temp Test Site',
    CURRENT_DATE,
    'active',
    TIMESTAMPTZ '2000-01-01 00:00:00+00',
    TIMESTAMPTZ '2000-01-01 00:00:00+00'
  );

  INSERT INTO documents (
    id,
    site_id,
    created_by,
    file_name,
    description,
    file_url,
    created_at,
    updated_at
  ) VALUES (
    gen_random_uuid(),
    temp_site,
    '44444444-4444-4444-4444-444444444444',
    'temp-spec.pdf',
    'temporary document',
    'https://example.com/temp-spec.pdf',
    TIMESTAMPTZ '2000-01-01 00:00:00+00',
    TIMESTAMPTZ '2000-01-01 00:00:00+00'
  )
  RETURNING id, updated_at
  INTO temp_doc, original_ts;

  UPDATE documents
  SET description = 'updated document'
  WHERE id = temp_doc
  RETURNING updated_at INTO updated_ts;

  IF updated_ts IS DISTINCT FROM original_ts THEN
    NULL;
  ELSE
    RAISE EXCEPTION 'documents.updated_at should change on update';
  END IF;

  -- Analytics view should aggregate temporary expenses for the site.
  INSERT INTO expenses (
    firm_id,
    site_id,
    created_by,
    paid_by,
    title,
    expense_date,
    amount,
    payment_mode,
    is_refundable
  ) VALUES
    (
      temp_firm,
      temp_site,
      '44444444-4444-4444-4444-444444444444',
      '44444444-4444-4444-4444-444444444444',
      'Temp Expense 1',
      CURRENT_DATE,
      100,
      'cash',
      false
    ),
    (
      temp_firm,
      temp_site,
      '44444444-4444-4444-4444-444444444444',
      '44444444-4444-4444-4444-444444444444',
      'Temp Expense 2',
      CURRENT_DATE,
      50,
      'cash',
      false
    );

  SELECT vsa.total_spend
  INTO total_spend
  FROM view_site_analytics AS vsa
  WHERE vsa.site_id = temp_site;

  IF total_spend IS DISTINCT FROM 150::numeric THEN
    RAISE EXCEPTION 'site analytics should aggregate temporary expenses';
  END IF;

  DELETE FROM sites
  WHERE id = temp_site;

  SELECT COUNT(*)
  INTO doc_count
  FROM documents
  WHERE id = temp_doc;

  IF doc_count <> 0 THEN
    RAISE EXCEPTION 'documents should delete when the parent site is deleted';
  END IF;

  DELETE FROM firms
  WHERE id = temp_firm;

  DELETE FROM auth.users
  WHERE id = '44444444-4444-4444-4444-444444444444';
  DELETE FROM profiles
  WHERE id = '44444444-4444-4444-4444-444444444444';
END;
$$;
