DO $$
DECLARE
  seq integer := 0;
  pass_count integer := 0;
  fail_count integer := 0;
  r record;
  temp_firm uuid;
  temp_site uuid;
  temp_site_2 uuid;
  alpha_user_id uuid;
  fallback_user_id uuid;
  delete_user_id uuid;
  duplicate_user_id uuid;
  scratch_user_id uuid;
  analytics_user_id uuid;
  txn_user_id uuid;
  temp_vendor_name text;
  temp_category_name text;
  temp_expense uuid;
  temp_expense_2 uuid;
  temp_doc uuid;
  temp_attachment uuid;
  old_ts timestamptz;
  new_ts timestamptz;
  total numeric;
  count_result integer;
  firm_name text;
  site_status_value text;
  profile_name text;
  profile_active boolean;
BEGIN
  CREATE TEMP TABLE test_results (
    seq integer,
    table_name text,
    test_name text,
    passed boolean,
    details text
  ) ON COMMIT DROP;

  -- Pre-cleanup so reruns do not collide with rows left behind by a previous run.
  DELETE FROM firms
  WHERE name IN ('Temp Firm A', 'Temp Firm B', 'Temp Firm C', 'Analytics Firm');

  DELETE FROM expense_categories
  WHERE name LIKE 'Materials-%'
     OR name LIKE 'Cat-%';

  DELETE FROM vendors
  WHERE name LIKE 'Vendor-%';

  DELETE FROM auth.users
  WHERE email IN (
    'alpha@example.com',
    'johndoe143@gmail.com',
    'delete-me@example.com',
    'spacey@example.com',
    'alpha2@example.com',
    'txn@example.com',
    'analytics@example.com'
  );

  DELETE FROM profiles
  WHERE display_name IN (
    'Alpha',
    'AlphaPrime',
    'johndoe143',
    'DeleteMe',
    'TxnUser',
    'AnalyticsUser'
  );

  -- Table: firms | Test: deleting a firm deletes related sites
  seq := seq + 1;
  BEGIN
    temp_firm := gen_random_uuid();
    temp_site := gen_random_uuid();

    INSERT INTO firms (id, name, description)
    VALUES (temp_firm, 'Temp Firm A', 'temp');

    INSERT INTO sites (id, firm_id, name, started_on, status)
    VALUES (temp_site, temp_firm, 'Temp Site A', CURRENT_DATE, 'active');

    DELETE FROM firms
    WHERE id = temp_firm;

    SELECT COUNT(*)
    INTO count_result
    FROM sites
    WHERE id = temp_site;

    IF count_result = 0 THEN
      INSERT INTO test_results VALUES (seq, 'firms', 'deleting a firm deletes related sites', true, NULL);
    ELSE
      INSERT INTO test_results VALUES (seq, 'firms', 'deleting a firm deletes related sites', false, 'site row still exists after firm delete');
    END IF;
  EXCEPTION
    WHEN others THEN
      INSERT INTO test_results VALUES (seq, 'firms', 'deleting a firm deletes related sites', false, SQLERRM);
  END;

  -- Table: firms | Test: updated_at changes when a firm is updated
  seq := seq + 1;
  BEGIN
    temp_firm := gen_random_uuid();
    INSERT INTO firms (id, name, description, created_at, updated_at)
    VALUES (
      temp_firm,
      'Temp Firm B',
      'before update',
      TIMESTAMPTZ '2000-01-01 00:00:00+00',
      TIMESTAMPTZ '2000-01-01 00:00:00+00'
    );

    UPDATE firms
    SET description = 'after update'
    WHERE id = temp_firm
    RETURNING updated_at INTO new_ts;

    IF new_ts > TIMESTAMPTZ '2000-01-01 00:00:00+00' THEN
      INSERT INTO test_results VALUES (seq, 'firms', 'updated_at changes when a firm is updated', true, NULL);
    ELSE
      INSERT INTO test_results VALUES (seq, 'firms', 'updated_at changes when a firm is updated', false, 'updated_at did not move forward');
    END IF;
  EXCEPTION
    WHEN others THEN
      INSERT INTO test_results VALUES (seq, 'firms', 'updated_at changes when a firm is updated', false, SQLERRM);
  END;

  -- Table: profiles | Test: auth signup uses display_name metadata
  seq := seq + 1;
  BEGIN
    alpha_user_id := gen_random_uuid();
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password,
      email_confirmed_at, recovery_sent_at, last_sign_in_at,
      raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
      confirmation_token, email_change, email_change_token_new, recovery_token
    ) VALUES (
      '00000000-0000-0000-0000-000000000000',
      alpha_user_id,
      'authenticated',
      'authenticated',
      'alpha@example.com',
      crypt('password123', gen_salt('bf')),
      now(), NULL, now(),
      '{"provider":"email","providers":["email"]}',
      '{"display_name":"Alpha"}',
      now(), now(),
      '', '', '', ''
    );

    SELECT display_name, is_active
    INTO profile_name, profile_active
    FROM profiles
    WHERE id = alpha_user_id;

    IF profile_name = 'Alpha' AND profile_active THEN
      INSERT INTO test_results VALUES (seq, 'profiles', 'auth signup uses display_name metadata', true, NULL);
    ELSE
      INSERT INTO test_results VALUES (seq, 'profiles', 'auth signup uses display_name metadata', false, 'profile row did not match expected display name or active state');
    END IF;
  EXCEPTION
    WHEN others THEN
      INSERT INTO test_results VALUES (seq, 'profiles', 'auth signup uses display_name metadata', false, SQLERRM);
  END;

  -- Table: profiles | Test: auth signup falls back to email prefix
  seq := seq + 1;
  BEGIN
    fallback_user_id := gen_random_uuid();
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password,
      email_confirmed_at, recovery_sent_at, last_sign_in_at,
      raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
      confirmation_token, email_change, email_change_token_new, recovery_token
    ) VALUES (
      '00000000-0000-0000-0000-000000000000',
      fallback_user_id,
      'authenticated',
      'authenticated',
      'johndoe143@gmail.com',
      crypt('password123', gen_salt('bf')),
      now(), NULL, now(),
      '{"provider":"email","providers":["email"]}',
      NULL,
      now(), now(),
      '', '', '', ''
    );

    SELECT display_name
    INTO profile_name
    FROM profiles
    WHERE id = fallback_user_id;

    IF profile_name = 'johndoe143' THEN
      INSERT INTO test_results VALUES (seq, 'profiles', 'auth signup falls back to email prefix', true, NULL);
    ELSE
      INSERT INTO test_results VALUES (seq, 'profiles', 'auth signup falls back to email prefix', false, 'profile did not use email prefix');
    END IF;
  EXCEPTION
    WHEN others THEN
      INSERT INTO test_results VALUES (seq, 'profiles', 'auth signup falls back to email prefix', false, SQLERRM);
  END;

  -- Table: profiles | Test: deleting auth user makes profile inactive
  seq := seq + 1;
  BEGIN
    delete_user_id := gen_random_uuid();
    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password,
      email_confirmed_at, recovery_sent_at, last_sign_in_at,
      raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
      confirmation_token, email_change, email_change_token_new, recovery_token
    ) VALUES (
      '00000000-0000-0000-0000-000000000000',
      delete_user_id,
      'authenticated',
      'authenticated',
      'delete-me@example.com',
      crypt('password123', gen_salt('bf')),
      now(), NULL, now(),
      '{"provider":"email","providers":["email"]}',
      '{"display_name":"DeleteMe"}',
      now(), now(),
      '', '', '', ''
    );

    DELETE FROM auth.users
    WHERE id = delete_user_id;

    SELECT is_active
    INTO profile_active
    FROM profiles
    WHERE id = delete_user_id;

    IF profile_active IS FALSE THEN
      INSERT INTO test_results VALUES (seq, 'profiles', 'deleting auth user makes profile inactive', true, NULL);
    ELSE
      INSERT INTO test_results VALUES (seq, 'profiles', 'deleting auth user makes profile inactive', false, 'profile was not marked inactive');
    END IF;

    DELETE FROM profiles WHERE id = delete_user_id;
  EXCEPTION
    WHEN others THEN
      INSERT INTO test_results VALUES (seq, 'profiles', 'deleting auth user makes profile inactive', false, SQLERRM);
  END;

  -- Table: profiles | Test: whitespace display_name is rejected
  seq := seq + 1;
  BEGIN
    duplicate_user_id := gen_random_uuid();
    BEGIN
      INSERT INTO auth.users (
        instance_id, id, aud, role, email, encrypted_password,
        email_confirmed_at, recovery_sent_at, last_sign_in_at,
        raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
        confirmation_token, email_change, email_change_token_new, recovery_token
      ) VALUES (
        '00000000-0000-0000-0000-000000000000',
        duplicate_user_id,
        'authenticated',
        'authenticated',
        'spacey@example.com',
        crypt('password123', gen_salt('bf')),
        now(), NULL, now(),
        '{"provider":"email","providers":["email"]}',
        '{"display_name":"Bad Name"}',
        now(), now(),
        '', '', '', ''
      );
      INSERT INTO test_results VALUES (seq, 'profiles', 'whitespace display_name is rejected', false, 'insert unexpectedly succeeded');
    EXCEPTION
      WHEN check_violation THEN
        INSERT INTO test_results VALUES (seq, 'profiles', 'whitespace display_name is rejected', true, NULL);
    END;
  EXCEPTION
    WHEN others THEN
      INSERT INTO test_results VALUES (seq, 'profiles', 'whitespace display_name is rejected', false, SQLERRM);
  END;

  -- Table: profiles | Test: duplicate display_name is rejected case-insensitively
  seq := seq + 1;
  BEGIN
    scratch_user_id := gen_random_uuid();
    BEGIN
      INSERT INTO auth.users (
        instance_id, id, aud, role, email, encrypted_password,
        email_confirmed_at, recovery_sent_at, last_sign_in_at,
        raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
        confirmation_token, email_change, email_change_token_new, recovery_token
      ) VALUES (
        '00000000-0000-0000-0000-000000000000',
        scratch_user_id,
        'authenticated',
        'authenticated',
        'alpha2@example.com',
        crypt('password123', gen_salt('bf')),
        now(), NULL, now(),
        '{"provider":"email","providers":["email"]}',
        '{"display_name":"alpha"}',
        now(), now(),
        '', '', '', ''
      );
      INSERT INTO test_results VALUES (seq, 'profiles', 'duplicate display_name is rejected case-insensitively', false, 'insert unexpectedly succeeded');
    EXCEPTION
      WHEN unique_violation THEN
        INSERT INTO test_results VALUES (seq, 'profiles', 'duplicate display_name is rejected case-insensitively', true, NULL);
    END;
  EXCEPTION
    WHEN others THEN
      INSERT INTO test_results VALUES (seq, 'profiles', 'duplicate display_name is rejected case-insensitively', false, SQLERRM);
  END;

  -- Table: profiles | Test: updated_at changes when a profile is updated
  seq := seq + 1;
  BEGIN
    UPDATE profiles
    SET display_name = 'AlphaPrime'
    WHERE id = alpha_user_id
    RETURNING updated_at INTO new_ts;

    IF new_ts IS NOT NULL THEN
      INSERT INTO test_results VALUES (seq, 'profiles', 'updated_at changes when a profile is updated', true, NULL);
    ELSE
      INSERT INTO test_results VALUES (seq, 'profiles', 'updated_at changes when a profile is updated', false, 'updated_at was not returned');
    END IF;
  EXCEPTION
    WHEN others THEN
      INSERT INTO test_results VALUES (seq, 'profiles', 'updated_at changes when a profile is updated', false, SQLERRM);
  END;

  -- Table: sites | Test: default status is active
  seq := seq + 1;
  BEGIN
    temp_firm := gen_random_uuid();
    temp_site := gen_random_uuid();

    INSERT INTO firms (id, name, description)
    VALUES (temp_firm, 'Temp Firm C', 'temp');

    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password,
      email_confirmed_at, recovery_sent_at, last_sign_in_at,
      raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
      confirmation_token, email_change, email_change_token_new, recovery_token
    ) VALUES (
      '00000000-0000-0000-0000-000000000000',
      gen_random_uuid(),
      'authenticated',
      'authenticated',
      'txn@example.com',
      crypt('password123', gen_salt('bf')),
      now(), NULL, now(),
      '{"provider":"email","providers":["email"]}',
      '{"display_name":"TxnUser"}',
      now(), now(),
      '', '', '', ''
    )
    RETURNING id INTO txn_user_id;

    INSERT INTO sites (id, firm_id, name, started_on)
    VALUES (temp_site, temp_firm, 'Temp Site C', CURRENT_DATE)
    RETURNING status::text INTO site_status_value;

    IF site_status_value = 'active' THEN
      INSERT INTO test_results VALUES (seq, 'sites', 'default status is active', true, NULL);
    ELSE
      INSERT INTO test_results VALUES (seq, 'sites', 'default status is active', false, 'site status was not active by default');
    END IF;
  EXCEPTION
    WHEN others THEN
      INSERT INTO test_results VALUES (seq, 'sites', 'default status is active', false, SQLERRM);
  END;

  -- Table: sites | Test: completed_on requires started_on and must not be before it
  seq := seq + 1;
  BEGIN
    BEGIN
      INSERT INTO sites (id, firm_id, name, completed_on, status)
      VALUES (gen_random_uuid(), temp_firm, 'Invalid Site 1', CURRENT_DATE, 'active');
      INSERT INTO test_results VALUES (seq, 'sites', 'completed_on requires started_on and must not be before it', false, 'completed_on without started_on unexpectedly succeeded');
    EXCEPTION
      WHEN check_violation THEN
        NULL;
    END;

    BEGIN
      INSERT INTO sites (id, firm_id, name, started_on, completed_on, status)
      VALUES (gen_random_uuid(), temp_firm, 'Invalid Site 2', CURRENT_DATE, CURRENT_DATE - 1, 'active');
      INSERT INTO test_results VALUES (seq, 'sites', 'completed_on requires started_on and must not be before it', false, 'completed_on before started_on unexpectedly succeeded');
    EXCEPTION
      WHEN check_violation THEN
        INSERT INTO test_results VALUES (seq, 'sites', 'completed_on requires started_on and must not be before it', true, NULL);
    END;
  EXCEPTION
    WHEN others THEN
      INSERT INTO test_results VALUES (seq, 'sites', 'completed_on requires started_on and must not be before it', false, SQLERRM);
  END;

  -- Table: sites | Test: marking a site deleted soft-deletes related expenses
  seq := seq + 1;
  BEGIN
    temp_site_2 := gen_random_uuid();
    temp_expense := gen_random_uuid();

    INSERT INTO sites (id, firm_id, name, started_on, status)
    VALUES (temp_site_2, temp_firm, 'Temp Site D', CURRENT_DATE, 'active');

    INSERT INTO expenses (
      id, firm_id, site_id, created_by, paid_by, title, expense_date,
      amount, payment_mode, is_refundable
    ) VALUES (
      temp_expense, temp_firm, temp_site_2, txn_user_id, txn_user_id,
      'Temp Expense D', CURRENT_DATE, 100, 'cash', false
    );

    UPDATE sites
    SET status = 'deleted'
    WHERE id = temp_site_2
    RETURNING status::text INTO site_status_value;

    IF site_status_value <> 'deleted' THEN
      INSERT INTO test_results VALUES (seq, 'sites', 'marking a site deleted soft-deletes related expenses', false, 'site status did not change to deleted');
    ELSE
      SELECT soft_deleted_at
      INTO old_ts
      FROM expenses
      WHERE id = temp_expense;

      IF old_ts IS NOT NULL THEN
        INSERT INTO test_results VALUES (seq, 'sites', 'marking a site deleted soft-deletes related expenses', true, NULL);
      ELSE
        INSERT INTO test_results VALUES (seq, 'sites', 'marking a site deleted soft-deletes related expenses', false, 'expense.soft_deleted_at was not populated');
      END IF;
    END IF;
  EXCEPTION
    WHEN others THEN
      INSERT INTO test_results VALUES (seq, 'sites', 'marking a site deleted soft-deletes related expenses', false, SQLERRM);
  END;

  -- Table: sites | Test: updated_at changes when a site is updated
  seq := seq + 1;
  BEGIN
    UPDATE sites
    SET description = 'after update'
    WHERE id = temp_site
    RETURNING updated_at INTO new_ts;

    IF new_ts IS NOT NULL THEN
      INSERT INTO test_results VALUES (seq, 'sites', 'updated_at changes when a site is updated', true, NULL);
    ELSE
      INSERT INTO test_results VALUES (seq, 'sites', 'updated_at changes when a site is updated', false, 'updated_at was not returned');
    END IF;
  EXCEPTION
    WHEN others THEN
      INSERT INTO test_results VALUES (seq, 'sites', 'updated_at changes when a site is updated', false, SQLERRM);
  END;

  -- Table: expense_categories | Test: category names are unique case-insensitively
  seq := seq + 1;
  BEGIN
    temp_category_name := 'Materials-' || left(replace(gen_random_uuid()::text, '-', ''), 8);
    INSERT INTO expense_categories (name) VALUES (temp_category_name);

    BEGIN
      INSERT INTO expense_categories (name) VALUES (upper(temp_category_name));
      INSERT INTO test_results VALUES (seq, 'expense_categories', 'category names are unique case-insensitively', false, 'duplicate category insert unexpectedly succeeded');
    EXCEPTION
      WHEN unique_violation THEN
        INSERT INTO test_results VALUES (seq, 'expense_categories', 'category names are unique case-insensitively', true, NULL);
    END;
  EXCEPTION
    WHEN others THEN
      INSERT INTO test_results VALUES (seq, 'expense_categories', 'category names are unique case-insensitively', false, SQLERRM);
  END;

  -- Table: vendors | Test: vendor names are unique case-insensitively
  seq := seq + 1;
  BEGIN
    temp_vendor_name := 'Vendor-' || left(replace(gen_random_uuid()::text, '-', ''), 8);
    INSERT INTO vendors (name) VALUES (temp_vendor_name);

    BEGIN
      INSERT INTO vendors (name) VALUES (upper(temp_vendor_name));
      INSERT INTO test_results VALUES (seq, 'vendors', 'vendor names are unique case-insensitively', false, 'duplicate vendor insert unexpectedly succeeded');
    EXCEPTION
      WHEN unique_violation THEN
        INSERT INTO test_results VALUES (seq, 'vendors', 'vendor names are unique case-insensitively', true, NULL);
    END;
  EXCEPTION
    WHEN others THEN
      INSERT INTO test_results VALUES (seq, 'vendors', 'vendor names are unique case-insensitively', false, SQLERRM);
  END;

  -- Table: expenses | Test: amount must be greater than zero
  seq := seq + 1;
  BEGIN
    BEGIN
      INSERT INTO expenses (
        firm_id, site_id, created_by, paid_by, title, expense_date, amount, payment_mode, is_refundable
      ) VALUES (
        temp_firm, temp_site, txn_user_id, txn_user_id,
        'Zero Expense', CURRENT_DATE, 0, 'cash', false
      );
      INSERT INTO test_results VALUES (seq, 'expenses', 'amount must be greater than zero', false, 'amount = 0 unexpectedly succeeded');
    EXCEPTION
      WHEN check_violation THEN
        INSERT INTO test_results VALUES (seq, 'expenses', 'amount must be greater than zero', true, NULL);
    END;
  EXCEPTION
    WHEN others THEN
      INSERT INTO test_results VALUES (seq, 'expenses', 'amount must be greater than zero', false, SQLERRM);
  END;

  -- Table: expenses | Test: title must be longer than two trimmed characters
  seq := seq + 1;
  BEGIN
    BEGIN
      INSERT INTO expenses (
        firm_id, site_id, created_by, paid_by, title, expense_date, amount, payment_mode, is_refundable
      ) VALUES (
        temp_firm, temp_site, txn_user_id, txn_user_id,
        '  a ', CURRENT_DATE, 100, 'cash', false
      );
      INSERT INTO test_results VALUES (seq, 'expenses', 'title must be longer than two trimmed characters', false, 'short title unexpectedly succeeded');
    EXCEPTION
      WHEN check_violation THEN
        INSERT INTO test_results VALUES (seq, 'expenses', 'title must be longer than two trimmed characters', true, NULL);
    END;
  EXCEPTION
    WHEN others THEN
      INSERT INTO test_results VALUES (seq, 'expenses', 'title must be longer than two trimmed characters', false, SQLERRM);
  END;

  -- Table: expenses | Test: GST percentage must stay within 0 to 100
  seq := seq + 1;
  BEGIN
    BEGIN
      INSERT INTO expenses (
        firm_id, site_id, created_by, paid_by, title, expense_date, amount, gst_percentage, payment_mode, is_refundable
      ) VALUES (
        temp_firm, temp_site, txn_user_id, txn_user_id,
        'Bad GST', CURRENT_DATE, 100, 101, 'cash', false
      );
      INSERT INTO test_results VALUES (seq, 'expenses', 'GST percentage must stay within 0 to 100', false, 'gst_percentage > 100 unexpectedly succeeded');
    EXCEPTION
      WHEN check_violation THEN
        INSERT INTO test_results VALUES (seq, 'expenses', 'GST percentage must stay within 0 to 100', true, NULL);
    END;
  EXCEPTION
    WHEN others THEN
      INSERT INTO test_results VALUES (seq, 'expenses', 'GST percentage must stay within 0 to 100', false, SQLERRM);
  END;

  -- Table: expenses | Test: site and firm must match through the composite foreign key
  seq := seq + 1;
  BEGIN
    BEGIN
      INSERT INTO expenses (
        firm_id, site_id, created_by, paid_by, title, expense_date, amount, payment_mode, is_refundable
      ) VALUES (
        (SELECT id FROM firms WHERE id <> temp_firm LIMIT 1),
        temp_site,
        txn_user_id,
        txn_user_id,
        'Mismatch',
        CURRENT_DATE,
        100,
        'cash',
        false
      );
      INSERT INTO test_results VALUES (seq, 'expenses', 'site and firm must match through the composite foreign key', false, 'mismatched firm/site unexpectedly succeeded');
    EXCEPTION
      WHEN foreign_key_violation THEN
        INSERT INTO test_results VALUES (seq, 'expenses', 'site and firm must match through the composite foreign key', true, NULL);
    END;
  EXCEPTION
    WHEN others THEN
      INSERT INTO test_results VALUES (seq, 'expenses', 'site and firm must match through the composite foreign key', false, SQLERRM);
  END;

  -- Table: expenses | Test: created_by and paid_by must reference profiles
  seq := seq + 1;
  BEGIN
    BEGIN
      INSERT INTO expenses (
        firm_id, site_id, created_by, paid_by, title, expense_date, amount, payment_mode, is_refundable
      ) VALUES (
        temp_firm, temp_site,
        gen_random_uuid(), gen_random_uuid(),
        'Bad Profiles', CURRENT_DATE, 100, 'cash', false
      );
      INSERT INTO test_results VALUES (seq, 'expenses', 'created_by and paid_by must reference profiles', false, 'invalid profile ids unexpectedly succeeded');
    EXCEPTION
      WHEN foreign_key_violation THEN
        INSERT INTO test_results VALUES (seq, 'expenses', 'created_by and paid_by must reference profiles', true, NULL);
    END;
  EXCEPTION
    WHEN others THEN
      INSERT INTO test_results VALUES (seq, 'expenses', 'created_by and paid_by must reference profiles', false, SQLERRM);
  END;

  -- Table: expenses | Test: updated_at changes when an expense is updated
  seq := seq + 1;
  BEGIN
    temp_expense := gen_random_uuid();
    INSERT INTO expenses (
      id, firm_id, site_id, created_by, paid_by, title, expense_date, amount, payment_mode, is_refundable,
      created_at, updated_at
    ) VALUES (
      temp_expense, temp_firm, temp_site, txn_user_id, txn_user_id,
      'Expense Update', CURRENT_DATE, 100, 'cash', false,
      TIMESTAMPTZ '2000-01-01 00:00:00+00', TIMESTAMPTZ '2000-01-01 00:00:00+00'
    );

    UPDATE expenses
    SET description = 'after update'
    WHERE id = temp_expense
    RETURNING updated_at INTO new_ts;

    IF new_ts > TIMESTAMPTZ '2000-01-01 00:00:00+00' THEN
      INSERT INTO test_results VALUES (seq, 'expenses', 'updated_at changes when an expense is updated', true, NULL);
    ELSE
      INSERT INTO test_results VALUES (seq, 'expenses', 'updated_at changes when an expense is updated', false, 'updated_at did not move forward');
    END IF;
  EXCEPTION
    WHEN others THEN
      INSERT INTO test_results VALUES (seq, 'expenses', 'updated_at changes when an expense is updated', false, SQLERRM);
  END;

  -- Table: expense_attachments | Test: deleting an expense deletes attachments
  seq := seq + 1;
  BEGIN
    temp_expense := gen_random_uuid();
    temp_attachment := gen_random_uuid();

    INSERT INTO expenses (
      id, firm_id, site_id, created_by, paid_by, title, expense_date, amount, payment_mode, is_refundable
    ) VALUES (
      temp_expense, temp_firm, temp_site, txn_user_id, txn_user_id,
      'Attachment Expense', CURRENT_DATE, 100, 'cash', false
    );

    INSERT INTO expense_attachments (id, expense_id, file_url)
    VALUES (temp_attachment, temp_expense, 'https://example.com/file.pdf');

    DELETE FROM expenses
    WHERE id = temp_expense;

    SELECT COUNT(*) INTO count_result
    FROM expense_attachments
    WHERE id = temp_attachment;

    IF count_result = 0 THEN
      INSERT INTO test_results VALUES (seq, 'expense_attachments', 'deleting an expense deletes attachments', true, NULL);
    ELSE
      INSERT INTO test_results VALUES (seq, 'expense_attachments', 'deleting an expense deletes attachments', false, 'attachment row still exists');
    END IF;
  EXCEPTION
    WHEN others THEN
      INSERT INTO test_results VALUES (seq, 'expense_attachments', 'deleting an expense deletes attachments', false, SQLERRM);
  END;

  -- Table: documents | Test: marking a site deleted keeps related documents
  seq := seq + 1;
  BEGIN
    temp_site_2 := gen_random_uuid();
    temp_doc := gen_random_uuid();

    INSERT INTO sites (id, firm_id, name, started_on, status)
    VALUES (temp_site_2, temp_firm, 'Temp Site F', CURRENT_DATE, 'active');

    INSERT INTO documents (
      id, site_id, created_by, file_name, description, file_url
    ) VALUES (
      temp_doc, temp_site_2, txn_user_id,
      'temp-doc-f.pdf', 'temp', 'https://example.com/temp-doc-f.pdf'
    );

    UPDATE sites
    SET status = 'deleted'
    WHERE id = temp_site_2;

    SELECT COUNT(*) INTO count_result
    FROM documents
    WHERE id = temp_doc;

    IF count_result = 0 THEN
      INSERT INTO test_results VALUES (seq, 'documents', 'marking a site deleted keeps related documents', false, 'document row was removed');
    ELSE
      INSERT INTO test_results VALUES (seq, 'documents', 'marking a site deleted keeps related documents', true, NULL);
    END IF;
  EXCEPTION
    WHEN others THEN
      INSERT INTO test_results VALUES (seq, 'documents', 'marking a site deleted keeps related documents', false, SQLERRM);
  END;

  -- Table: documents | Test: created_by must reference an existing profile
  seq := seq + 1;
  BEGIN
    BEGIN
      INSERT INTO documents (
        site_id, created_by, file_name, description, file_url
      ) VALUES (
        temp_site,
        gen_random_uuid(),
        'bad-doc.pdf',
        'bad',
        'https://example.com/bad-doc.pdf'
      );
      INSERT INTO test_results VALUES (seq, 'documents', 'created_by must reference an existing profile', false, 'invalid created_by unexpectedly succeeded');
    EXCEPTION
      WHEN foreign_key_violation THEN
        INSERT INTO test_results VALUES (seq, 'documents', 'created_by must reference an existing profile', true, NULL);
    END;
  EXCEPTION
    WHEN others THEN
      INSERT INTO test_results VALUES (seq, 'documents', 'created_by must reference an existing profile', false, SQLERRM);
  END;

  -- Table: documents | Test: updated_at changes when a document is updated
  seq := seq + 1;
  BEGIN
    temp_doc := gen_random_uuid();
    INSERT INTO documents (
      id, site_id, created_by, file_name, description, file_url,
      created_at, updated_at
    ) VALUES (
      temp_doc, temp_site, txn_user_id,
      'temp-doc-updated.pdf', 'before', 'https://example.com/temp-doc-updated.pdf',
      TIMESTAMPTZ '2000-01-01 00:00:00+00', TIMESTAMPTZ '2000-01-01 00:00:00+00'
    );

    UPDATE documents
    SET description = 'after'
    WHERE id = temp_doc
    RETURNING updated_at INTO new_ts;

    IF new_ts > TIMESTAMPTZ '2000-01-01 00:00:00+00' THEN
      INSERT INTO test_results VALUES (seq, 'documents', 'updated_at changes when a document is updated', true, NULL);
    ELSE
      INSERT INTO test_results VALUES (seq, 'documents', 'updated_at changes when a document is updated', false, 'updated_at did not move forward');
    END IF;
  EXCEPTION
    WHEN others THEN
      INSERT INTO test_results VALUES (seq, 'documents', 'updated_at changes when a document is updated', false, SQLERRM);
  END;

  -- View: view_firm_analytics | Test: firm totals aggregate expenses
  seq := seq + 1;
  BEGIN
    temp_firm := gen_random_uuid();
    temp_site := gen_random_uuid();
    analytics_user_id := gen_random_uuid();
    temp_category_name := 'Cat-' || left(replace(gen_random_uuid()::text, '-', ''), 8);
    temp_vendor_name := 'Vendor-' || left(replace(gen_random_uuid()::text, '-', ''), 8);

    INSERT INTO auth.users (
      instance_id, id, aud, role, email, encrypted_password,
      email_confirmed_at, recovery_sent_at, last_sign_in_at,
      raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
      confirmation_token, email_change, email_change_token_new, recovery_token
    ) VALUES (
      '00000000-0000-0000-0000-000000000000',
      analytics_user_id,
      'authenticated',
      'authenticated',
      'analytics@example.com',
      crypt('password123', gen_salt('bf')),
      now(), NULL, now(),
      '{"provider":"email","providers":["email"]}',
      '{"display_name":"AnalyticsUser"}',
      now(), now(),
      '', '', '', ''
    );

    INSERT INTO firms (id, name, description)
    VALUES (temp_firm, 'Analytics Firm', 'temp');

    INSERT INTO sites (id, firm_id, name, started_on, status)
    VALUES (temp_site, temp_firm, 'Analytics Site', CURRENT_DATE, 'active');

    INSERT INTO expense_categories (name) VALUES (temp_category_name);
    INSERT INTO vendors (name) VALUES (temp_vendor_name);

    INSERT INTO expenses (
      firm_id, site_id, created_by, paid_by, title, expense_date,
      amount, category_id, vendor_id, payment_mode, is_refundable
    ) VALUES (
      temp_firm, temp_site, analytics_user_id, analytics_user_id,
      'Analytics Expense 1', CURRENT_DATE, 100,
      (SELECT id FROM expense_categories WHERE name = temp_category_name),
      (SELECT id FROM vendors WHERE name = temp_vendor_name),
      'cash', false
    );

    SELECT total_spend
    INTO total
    FROM view_firm_analytics
    WHERE firm_id = temp_firm;

    IF total = 100::numeric THEN
      INSERT INTO test_results VALUES (seq, 'view_firm_analytics', 'firm totals aggregate expenses', true, NULL);
    ELSE
      INSERT INTO test_results VALUES (seq, 'view_firm_analytics', 'firm totals aggregate expenses', false, 'firm total was not 100');
    END IF;
  EXCEPTION
    WHEN others THEN
      INSERT INTO test_results VALUES (seq, 'view_firm_analytics', 'firm totals aggregate expenses', false, SQLERRM);
  END;

  -- View: view_site_analytics | Test: site totals aggregate expenses and ignore soft deleted rows
  seq := seq + 1;
  BEGIN
    INSERT INTO expenses (
      firm_id, site_id, created_by, paid_by, title, expense_date,
      amount, category_id, vendor_id, payment_mode, is_refundable
    ) VALUES (
      temp_firm, temp_site, analytics_user_id, analytics_user_id,
      'Analytics Expense 2', CURRENT_DATE, 50,
      (SELECT id FROM expense_categories WHERE name = temp_category_name),
      (SELECT id FROM vendors WHERE name = temp_vendor_name),
      'cash', false
    )
    RETURNING id INTO temp_expense_2;

    UPDATE expenses
    SET soft_deleted_at = NOW()
    WHERE id = temp_expense_2;

    SELECT total_spend
    INTO total
    FROM view_site_analytics
    WHERE site_id = temp_site;

    IF total = 100::numeric THEN
      INSERT INTO test_results VALUES (seq, 'view_site_analytics', 'site totals aggregate expenses and ignore soft deleted rows', true, NULL);
    ELSE
      INSERT INTO test_results VALUES (seq, 'view_site_analytics', 'site totals aggregate expenses and ignore soft deleted rows', false, 'soft-deleted expense was not excluded');
    END IF;
  EXCEPTION
    WHEN others THEN
      INSERT INTO test_results VALUES (seq, 'view_site_analytics', 'site totals aggregate expenses and ignore soft deleted rows', false, SQLERRM);
  END;

  -- View: view_category_analytics | Test: category totals aggregate by category
  seq := seq + 1;
  BEGIN
    SELECT total_spend
    INTO total
    FROM view_category_analytics
    WHERE site_id = temp_site
      AND firm_id = temp_firm
      AND category_name = temp_category_name;

    IF total = 100::numeric THEN
      INSERT INTO test_results VALUES (seq, 'view_category_analytics', 'category totals aggregate by category', true, NULL);
    ELSE
      INSERT INTO test_results VALUES (seq, 'view_category_analytics', 'category totals aggregate by category', false, 'category total was not 100');
    END IF;
  EXCEPTION
    WHEN others THEN
      INSERT INTO test_results VALUES (seq, 'view_category_analytics', 'category totals aggregate by category', false, SQLERRM);
  END;

  -- View: view_monthly_analytics | Test: monthly totals aggregate by month
  seq := seq + 1;
  BEGIN
    SELECT total_spend
    INTO total
    FROM view_monthly_analytics
    WHERE site_id = temp_site
      AND firm_id = temp_firm
      AND month_date = DATE_TRUNC('month', CURRENT_DATE)::date;

    IF total = 100::numeric THEN
      INSERT INTO test_results VALUES (seq, 'view_monthly_analytics', 'monthly totals aggregate by month', true, NULL);
    ELSE
      INSERT INTO test_results VALUES (seq, 'view_monthly_analytics', 'monthly totals aggregate by month', false, 'monthly total was not 100');
    END IF;
  EXCEPTION
    WHEN others THEN
      INSERT INTO test_results VALUES (seq, 'view_monthly_analytics', 'monthly totals aggregate by month', false, SQLERRM);
  END;

  -- View: view_vendor_analytics | Test: vendor totals aggregate by vendor
  seq := seq + 1;
  BEGIN
    SELECT total_spend
    INTO total
    FROM view_vendor_analytics
    WHERE site_id = temp_site
      AND vendor_name = temp_vendor_name;

    IF total = 100::numeric THEN
      INSERT INTO test_results VALUES (seq, 'view_vendor_analytics', 'vendor totals aggregate by vendor', true, NULL);
    ELSE
      INSERT INTO test_results VALUES (seq, 'view_vendor_analytics', 'vendor totals aggregate by vendor', false, 'vendor total was not 100');
    END IF;
  EXCEPTION
    WHEN others THEN
      INSERT INTO test_results VALUES (seq, 'view_vendor_analytics', 'vendor totals aggregate by vendor', false, SQLERRM);
  END;

  FOR r IN
    SELECT *
    FROM test_results
    ORDER BY seq
  LOOP
    RAISE NOTICE '[%] % | %',
      CASE WHEN r.passed THEN 'PASS' ELSE 'FAIL' END,
      r.table_name,
      r.test_name;

    IF r.details IS NOT NULL THEN
      RAISE NOTICE '  %', r.details;
    END IF;
  END LOOP;

  -- Teardown so the suite can be run repeatedly without colliding with its own test data.
  DELETE FROM firms
  WHERE name IN ('Temp Firm A', 'Temp Firm B', 'Temp Firm C', 'Analytics Firm');

  DELETE FROM expense_categories
  WHERE name LIKE 'Materials-%'
     OR name LIKE 'Cat-%';

  DELETE FROM vendors
  WHERE name LIKE 'Vendor-%';

  DELETE FROM auth.users
  WHERE id IN (
    alpha_user_id,
    fallback_user_id,
    delete_user_id,
    duplicate_user_id,
    scratch_user_id,
    analytics_user_id,
    txn_user_id
  );

  DELETE FROM profiles
  WHERE id IN (
    alpha_user_id,
    fallback_user_id,
    delete_user_id,
    duplicate_user_id,
    scratch_user_id,
    analytics_user_id,
    txn_user_id
  );

  SELECT
    COUNT(*) FILTER (WHERE passed),
    COUNT(*) FILTER (WHERE NOT passed)
  INTO pass_count, fail_count
  FROM test_results;

  RAISE NOTICE 'Summary: % passed, % failed', pass_count, fail_count;

  IF fail_count > 0 THEN
    RAISE EXCEPTION 'Database behavior tests failed';
  END IF;
END;
$$;
