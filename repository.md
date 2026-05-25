# Repository Layer Documentation

This document describes the repository layer of the **Site Vault** application, outlining the database tables/views accessed and the specific queries/operations performed by each repository file.

---

## Shared Repositories

### `firm_repository.dart`
- **File Path**: `lib/shared/repository/firm_repository.dart`
- **Tables Accessed**:
  - `firms`
- **Queries & Operations**:
  - **Fetch all firms**: Selects all columns from `firms`, ordered alphabetically by `name` ascending.
    ```dart
    _client.from('firms').select().order('name', ascending: true);
    ```

### `storage_repository.dart`
- **File Path**: `lib/shared/repository/storage_repository.dart`
- **Tables Accessed**:
  - *None* (performs binary storage bucket operations on Supabase Storage)
- **Queries & Operations**:
  - **Upload file**: Uploads raw binary file bytes to the specified Supabase Storage bucket and path, then returns its public URL.
    ```dart
    _client.storage.from(bucket).uploadBinary(storagePath, fileBytes, ...);
    _client.storage.from(bucket).getPublicUrl(storagePath);
    ```
  - **Delete file**: Extracts the relative path from the public URL and removes the object from the specified storage bucket.
    ```dart
    _client.storage.from(bucket).remove([relativePath]);
    ```

---

## Feature Repositories

### `admin_repository.dart`
- **File Path**: `lib/feature/admin/repository/admin_repository.dart`
- **Tables Accessed**:
  - `vendors`
  - `expense_categories`
  - `profiles`
- **Queries & Operations**:
  - **Fetch all vendors**: Selects all vendors, ordered by `name` ascending.
    ```dart
    _client.from('vendors').select().order('name', ascending: true);
    ```
  - **Create vendor**: Inserts a new vendor row.
    ```dart
    _client.from('vendors').insert({...}).select().single();
    ```
  - **Update vendor**: Updates a vendor's `name`, `contact_info`, and `is_active` status by matching `id`.
    ```dart
    _client.from('vendors').update({...}).eq('id', id).select().single();
    ```
  - **Fetch all expense categories**: Selects all categories, ordered by `name` ascending.
    ```dart
    _client.from('expense_categories').select().order('name', ascending: true);
    ```
  - **Create expense category**: Inserts a new category row.
    ```dart
    _client.from('expense_categories').insert({...}).select().single();
    ```
  - **Update expense category**: Updates a category's `name` and `is_active` status by matching `id`.
    ```dart
    _client.from('expense_categories').update({...}).eq('id', id).select().single();
    ```
  - **Fetch all staff profiles**: Selects all profile rows, ordered by `display_name` ascending.
    ```dart
    _client.from('profiles').select().order('display_name', ascending: true);
    ```
  - **Update staff profile**: Updates a profile's `display_name` and `is_active` status by matching `id`.
    ```dart
    _client.from('profiles').update({...}).eq('id', id).select().single();
    ```

### `analytics_repository.dart`
- **File Path**: `lib/feature/analytics/repository/analytics_repository.dart`
- **Tables & Views Accessed**:
  - `view_firm_analytics` (View)
  - `view_site_analytics` (View)
  - `view_category_analytics` (View)
  - `view_monthly_analytics` (View)
  - `view_vendor_analytics` (View)
- **Queries & Operations**:
  - **Fetch executive firm summaries**: Fetches all rows from `view_firm_analytics`.
    ```dart
    _client.from('view_firm_analytics').select();
    ```
  - **Fetch single site summary**: Fetches single row from `view_site_analytics` matching `site_id`.
    ```dart
    _client.from('view_site_analytics').select().eq('site_id', siteId).maybeSingle();
    ```
  - **Fetch category spend distribution**: Fetches from `view_category_analytics`, optionally filtered by `site_id` or `firm_id`.
    ```dart
    _client.from('view_category_analytics').select().eq('site_id' or 'firm_id', id);
    ```
  - **Fetch monthly cashflow trend list**: Fetches from `view_monthly_analytics`, optionally filtered by `site_id` or `firm_id`, ordered by `month_date` ascending.
    ```dart
    _client.from('view_monthly_analytics').select().eq('site_id' or 'firm_id', id).order('month_date', ascending: true);
    ```
  - **Fetch site-specific vendor spending splits**: Fetches from `view_vendor_analytics` matching `site_id`, ordered by `total_spend` descending.
    ```dart
    _client.from('view_vendor_analytics').select().eq('site_id', siteId).order('total_spend', ascending: false);
    ```

### `auth_repository.dart`
- **File Path**: `lib/feature/auth/repository/auth_repository.dart`
- **Tables Accessed**:
  - *None* (manages user authentication via Supabase Auth services)
- **Queries & Operations**:
  - **Sign in**: Authenticates a user with email and password.
    ```dart
    _client.auth.signInWithPassword(email: email, password: password);
    ```
  - **Sign out**: Signs out of the current Supabase session.
    ```dart
    _client.auth.signOut();
    ```
  - **Get current user**: Retrieves current session metadata.
    ```dart
    _client.auth.currentUser;
    ```
  - **Auth state stream**: Observes authentication state changes.
    ```dart
    _client.auth.onAuthStateChange;
    ```

### `document_repository.dart`
- **File Path**: `lib/feature/document/repository/document_repository.dart`
- **Tables Accessed**:
  - `documents`
  - `profiles` (joined dynamically via foreign key relation)
- **Queries & Operations**:
  - **Fetch documents for site**: Fetches active (non-soft-deleted) documents for a specific `site_id`, ordered by `created_at` descending, with uploader profiles joined.
    ```dart
    _client.from('documents').select('*, profiles(*)').eq('site_id', siteId).isFilter('soft_deleted_at', null).order('created_at', ascending: false);
    ```
  - **Create document**: Inserts a new document row and selects the inserted record with uploader profile joined.
    ```dart
    _client.from('documents').insert(data).select('*, profiles(*)').single();
    ```
  - **Soft delete document**: Updates the document's `soft_deleted_at` and `updated_at` timestamps to the current time.
    ```dart
    _client.from('documents').update({'soft_deleted_at': now, 'updated_at': now}).eq('id', documentId);
    ```

### `expense_repository.dart`
- **File Path**: `lib/feature/expense/repository/expense_repository.dart`
- **Tables Accessed**:
  - `expenses`
  - `expense_categories` (joined dynamically or fetched directly)
  - `vendors` (joined dynamically or fetched directly)
  - `profiles` (fetched directly)
  - `expense_attachments`
- **Queries & Operations**:
  - **Fetch active expenses for site**: Selects all non-soft-deleted expenses for `site_id`, ordered by `expense_date` descending, with related `expense_categories` and `vendors` joined.
    ```dart
    _client.from('expenses').select('*, expense_categories(*), vendors(*)').eq('site_id', siteId).isFilter('soft_deleted_at', null).order('expense_date', ascending: false);
    ```
  - **Create expense**: Inserts a new expense row and selects the result with related categories/vendors joined.
    ```dart
    _client.from('expenses').insert(data).select('*, expense_categories(*), vendors(*)').single();
    ```
  - **Update expense**: Updates an expense row by its ID and selects the result with related categories/vendors joined.
    ```dart
    _client.from('expenses').update(data).eq('id', id).select('*, expense_categories(*), vendors(*)').single();
    ```
  - **Soft delete expense**: Updates `soft_deleted_at` and `updated_at` to the current time for the matched ID.
    ```dart
    _client.from('expenses').update({'soft_deleted_at': now, 'updated_at': now}).eq('id', expenseId);
    ```
  - **Fetch active categories**: Selects active categories ordered by `name` ascending.
    ```dart
    _client.from('expense_categories').select().eq('is_active', true).order('name', ascending: true);
    ```
  - **Fetch active vendors**: Selects active vendors ordered by `name` ascending.
    ```dart
    _client.from('vendors').select().eq('is_active', true).order('name', ascending: true);
    ```
  - **Fetch active profiles**: Selects active profiles ordered by `display_name` ascending.
    ```dart
    _client.from('profiles').select().eq('is_active', true).order('display_name', ascending: true);
    ```
  - **Add attachment**: Inserts a record mapping `expense_id` to its uploaded file URL.
    ```dart
    _client.from('expense_attachments').insert({'expense_id': expenseId, 'file_url': fileUrl});
    ```
  - **Fetch attachments for expense**: Selects file URLs matching `expense_id`.
    ```dart
    _client.from('expense_attachments').select('file_url').eq('expense_id', expenseId);
    ```

### `site_repository.dart`
- **File Path**: `lib/feature/site/repository/site_repository.dart`
- **Tables Accessed**:
  - `sites`
- **Queries & Operations**:
  - **Fetch all sites**: Selects all sites ordered by `created_at` descending.
    ```dart
    _client.from('sites').select().order('created_at', ascending: false);
    ```
