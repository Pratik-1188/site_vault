# Database Overview

This file describes the current Supabase/Postgres database at a high level. It focuses on what each table represents, how rows relate to each other, and what constraints, triggers, policies, indexes, and views affect behavior.

## Extensions and Custom Types

### Extensions

- `pgcrypto`
  - Used for `gen_random_uuid()`, which generates UUID primary keys.

### Enums

- `site_status`
  - Allowed values: `active`, `completed`, `archived`.
  - Used by `sites.status`.

- `payment_mode`
  - Allowed values: `cash`, `upi`, `card`, `net_banking`, `cheque`, `rtgs`, `neft`, `dd`, `other`.
  - Used by `expenses.payment_mode`.

## Tables

## `firms`

Top-level business entity. A firm owns sites, and site expenses roll up to the firm.

### Columns

- `id`
  - UUID primary key.
  - Defaults to `gen_random_uuid()`.
- `name`
  - Required text.
- `description`
  - Optional text.
- `created_at`
  - Required timestamp.
  - Defaults to `now()`.
- `updated_at`
  - Required timestamp.
  - Defaults to `now()`.
  - Automatically refreshed on update.

### Relationships

- One firm can have many `sites`.
- One firm can have many `expenses` through `expenses.firm_id`.

### Constraints

- Primary key: `id`.
- `name`, `created_at`, and `updated_at` are required.

### Triggers

- `tr_firms_update`
  - Runs before update.
  - Calls `handle_updated_at()`.
  - Keeps `updated_at` current.

### Delete Behavior

- Deleting a firm cascades to its `sites`.
- Expenses tied to those sites are also deleted through the site relationship.

## `profiles`

Application user profile table. Each profile belongs to one Supabase auth user.

### Columns

- `id`
  - UUID primary key.
  - Matches the Supabase `auth.users(id)` value when the profile is created.
  - Does not have a foreign key to `auth.users`, so the profile can remain after the auth user is deleted.
- `display_name`
  - Required text.
  - Must not contain whitespace.
  - Must be unique case-insensitively.
- `is_active`
  - Boolean.
  - Defaults to `true`.
- `created_at`
  - Required timestamp.
  - Defaults to `now()`.
- `updated_at`
  - Required timestamp.
  - Defaults to `now()`.
  - Automatically refreshed on update.

### Relationships

- `expenses.created_by` references `profiles.id`.
- `expenses.paid_by` references `profiles.id`.
- `documents.created_by` references `profiles.id`.

### Constraints

- Primary key: `id`.
- The `id` value is aligned with `auth.users(id)`, but it intentionally does not cascade-delete with auth users.
- Check constraint: `chk_display_name_no_spaces`
  - `display_name` cannot contain spaces or other whitespace.
- Unique index: `unique_display_name_lower`
  - Enforces unique `LOWER(display_name)`.
  - Example: `JohnDoe` and `johndoe` cannot both exist.

### Triggers

- `tr_profiles_update`
  - Runs before update.
  - Calls `handle_updated_at()`.
  - Keeps `updated_at` current.

### Auth Signup Behavior

- Trigger: `on_auth_user_created`
  - Runs after insert on `auth.users`.
  - Calls `public.handle_new_user()`.
- Function: `public.handle_new_user()`
  - Creates a matching row in `public.profiles`.
  - Uses `raw_user_meta_data->>'display_name'` when provided.
  - If the display name is missing or empty, uses the email prefix before `@`.
  - If both display name and email prefix are missing, uses `user_` plus the first 8 characters of the auth user UUID.

### Auth Delete Behavior

- Trigger: `on_auth_user_deleted`
  - Runs before delete on `auth.users`.
  - Calls `public.handle_deleted_user()`.
- Function: `public.handle_deleted_user()`
  - Keeps the `profiles` row.
  - Sets `profiles.is_active` to `false`.
  - Updates `profiles.updated_at`.

### Delete Behavior

- Deleting the auth user does not delete the profile.
- Instead, the profile remains as an inactive historical user record.
- Expenses/documents referencing that profile remain connected to the inactive profile.

## `sites`

Project/site table. Each site belongs to exactly one firm.

### Columns

- `id`
  - UUID primary key.
  - Defaults to `gen_random_uuid()`.
- `firm_id`
  - Required UUID.
  - References `firms(id)`.
- `name`
  - Required text.
- `description`
  - Optional text.
- `started_on`
  - Optional date.
- `completed_on`
  - Optional date.
- `status`
  - Required `site_status`.
  - Defaults to `active`.
- `created_at`
  - Required timestamp.
  - Defaults to `now()`.
- `updated_at`
  - Required timestamp.
  - Defaults to `now()`.
  - Automatically refreshed on update.

### Relationships

- Each site belongs to one `firm`.
- One site can have many `expenses`.
- One site can have many `documents`.

### Constraints

- Primary key: `id`.
- Foreign key: `firm_id` references `firms(id)` with `ON DELETE CASCADE`.
- Check constraint: `chk_site_dates`
  - `completed_on` can be null.
  - If `completed_on` is present, `started_on` must also be present.
  - `completed_on` must be greater than or equal to `started_on`.
- Unique index: `idx_sites_id_firm`
  - Enforces uniqueness on `(id, firm_id)`.
  - Supports the composite foreign key from `expenses`.

### Triggers

- `tr_sites_update`
  - Runs before update.
  - Calls `handle_updated_at()`.
  - Keeps `updated_at` current.

### Delete Behavior

- Deleting a firm deletes its sites.
- Deleting a site deletes related expenses and documents.

## `expense_categories`

Lookup table for expense categories.

### Columns

- `id`
  - UUID primary key.
  - Defaults to `gen_random_uuid()`.
- `name`
  - Required text.
- `is_active`
  - Boolean.
  - Defaults to `true`.
- `created_at`
  - Timestamp.
  - Defaults to `now()`.

### Relationships

- `expenses.category_id` references `expense_categories.id`.

### Constraints

- Primary key: `id`.
- `name` is required.
- Unique index: `unique_category_name_lower`
  - Enforces unique category names case-insensitively.

### Triggers

- No `updated_at` column and no update trigger.

### Delete Behavior

- Categories referenced by expenses cannot be deleted unless the expense references are removed or updated first.

## `vendors`

Lookup table for vendors/suppliers.

### Columns

- `id`
  - UUID primary key.
  - Defaults to `gen_random_uuid()`.
- `name`
  - Required text.
- `contact_info`
  - Optional text.
- `is_active`
  - Boolean.
  - Defaults to `true`.
- `created_at`
  - Timestamp.
  - Defaults to `now()`.

### Relationships

- `expenses.vendor_id` references `vendors.id`.

### Constraints

- Primary key: `id`.
- `name` is required.
- Unique index: `unique_vendor_name_lower`
  - Enforces unique vendor names case-insensitively.

### Triggers

- No `updated_at` column and no update trigger.

### Delete Behavior

- Vendors referenced by expenses cannot be deleted unless the expense references are removed or updated first.

## `expenses`

Main transaction table. Every expense belongs to a firm and a site, has staff profile references, and may point to a category/vendor.

### Columns

- `id`
  - UUID primary key.
  - Defaults to `gen_random_uuid()`.
- `firm_id`
  - Required UUID.
- `site_id`
  - Required UUID.
- `created_by`
  - Required UUID.
  - References the profile that created the expense.
- `paid_by`
  - Required UUID.
  - References the profile that paid the expense.
- `title`
  - Required text.
  - Must be more than 2 characters after trimming.
- `description`
  - Optional text.
- `expense_date`
  - Required date.
- `category_id`
  - Optional UUID.
  - References `expense_categories(id)`.
- `vendor_id`
  - Optional UUID.
  - References `vendors(id)`.
- `amount`
  - Required numeric value with 2 decimal places.
  - Must be greater than `0`.
- `gst_percentage`
  - Optional numeric value.
  - Must be between `0` and `100` when present.
- `gst_amount`
  - Optional numeric value.
- `payment_mode`
  - Required `payment_mode`.
  - Defaults to `cash`.
- `is_refundable`
  - Required boolean.
  - Defaults to `false`.
- `soft_deleted_at`
  - Optional timestamp.
  - When set, the expense is treated as deleted by app queries/views.
- `created_at`
  - Required timestamp.
  - Defaults to `now()`.
- `updated_at`
  - Required timestamp.
  - Defaults to `now()`.
  - Automatically refreshed on update.

### Relationships

- `created_by` references `profiles(id)`.
- `paid_by` references `profiles(id)`.
- `category_id` references `expense_categories(id)`.
- `vendor_id` references `vendors(id)`.
- `(site_id, firm_id)` references `sites(id, firm_id)`.

### Constraints

- Primary key: `id`.
- `created_by`, `paid_by`, `title`, `expense_date`, `amount`, `payment_mode`, `is_refundable`, `created_at`, and `updated_at` are required.
- Check constraint on `amount`
  - `amount > 0`.
  - Zero-value expenses are not allowed.
- Check constraint: `chk_gst_percentage`
  - `gst_percentage` can be null.
  - If present, it must be between `0` and `100`.
- Check constraint: `chk_title_length`
  - `length(trim(title)) > 2`.
- Composite foreign key: `fk_expense_site_firm`
  - `(site_id, firm_id)` must match an existing `(sites.id, sites.firm_id)`.
  - This prevents an expense from pointing to a site under one firm while claiming another firm.

### Triggers

- `tr_expenses_update`
  - Runs before update.
  - Calls `handle_updated_at()`.
  - Keeps `updated_at` current.

### Delete Behavior

- Deleting the related site deletes the expense.
- Expense rows are also designed for soft delete using `soft_deleted_at`.
- Analytics views ignore rows where `soft_deleted_at` is not null.

## `expense_attachments`

Attachment table for expense files.

### Columns

- `id`
  - UUID primary key.
  - Defaults to `gen_random_uuid()`.
- `expense_id`
  - Required UUID.
  - References `expenses(id)`.
- `file_url`
  - Required text.
- `created_at`
  - Timestamp.
  - Defaults to `now()`.

### Relationships

- Each attachment belongs to one `expense`.

### Constraints

- Primary key: `id`.
- Foreign key: `expense_id` references `expenses(id)` with `ON DELETE CASCADE`.
- `expense_id` and `file_url` are required.

### Triggers

- No `updated_at` column and no update trigger.

### Delete Behavior

- Deleting an expense deletes its attachments.

## `documents`

Site document vault table. Documents belong directly to a site. The firm is derived through the site instead of being stored redundantly.

### Columns

- `id`
  - UUID primary key.
  - Defaults to `gen_random_uuid()`.
- `site_id`
  - Required UUID.
  - References `sites(id)`.
- `created_by`
  - Required UUID.
  - References `profiles(id)`.
- `file_name`
  - Required text.
- `description`
  - Optional text.
- `file_url`
  - Required text.
- `soft_deleted_at`
  - Optional timestamp.
  - When set, the document is treated as deleted by app queries.
- `created_at`
  - Required timestamp.
  - Defaults to `now()`.
- `updated_at`
  - Required timestamp.
  - Defaults to `now()`.
  - Automatically refreshed on update.

### Relationships

- Each document belongs to one `site`.
- Each document has one uploader profile through `created_by`.
- The document's firm is available through `documents.site_id -> sites.id -> sites.firm_id`.

### Constraints

- Primary key: `id`.
- Foreign key: `site_id` references `sites(id)` with `ON DELETE CASCADE`.
- Foreign key: `created_by` references `profiles(id)`.
- `site_id`, `created_by`, `file_name`, `file_url`, `created_at`, and `updated_at` are required.

### Triggers

- `tr_documents_update`
  - Runs before update.
  - Calls `handle_updated_at()`.
  - Keeps `updated_at` current.

### Delete Behavior

- Deleting a site deletes its documents.
- Document rows are also designed for soft delete using `soft_deleted_at`.

## Shared Functions and Triggers

## `handle_updated_at()`

Shared trigger function used by tables with an `updated_at` column.

### Behavior

- Runs before an update.
- Sets `NEW.updated_at` to the current database timestamp.
- Returns the updated row.

### Tables Using It

- `firms`
- `profiles`
- `sites`
- `expenses`
- `documents`

## `public.handle_new_user()`

Signup helper function for auth users.

### Behavior

- Runs after a new row is inserted into `auth.users`.
- Inserts a matching row into `public.profiles`.
- Uses `raw_user_meta_data->>'display_name'` when present and not empty.
- Otherwise uses the email prefix before `@`.
- If there is no usable email prefix, creates a fallback display name using `user_` plus the first 8 characters of the new user UUID.

### Trigger Using It

- `on_auth_user_created`
  - Runs after insert on `auth.users`.
- `on_auth_user_deleted`
  - Runs before delete on `auth.users`.
  - Marks the matching profile inactive instead of deleting it.

## Row Level Security

RLS is enabled on every application table:

- `firms`
- `profiles`
- `sites`
- `expenses`
- `documents`
- `expense_categories`
- `vendors`
- `expense_attachments`

Each table has a policy named `Team Full Access`.

### Current Policy Behavior

- Applies to both `authenticated` and `anon`.
- Allows all operations.
- Uses `USING (true)`.
- Uses `WITH CHECK (true)`.

In practical terms, RLS is turned on, but these policies allow unrestricted table access to both logged-in users and anonymous clients that have the anon key.

## Indexes

### Unique Indexes

- `unique_display_name_lower`
  - On `profiles(LOWER(display_name))`.
  - Prevents case-insensitive duplicate display names.

- `idx_sites_id_firm`
  - On `sites(id, firm_id)`.
  - Supports the composite foreign key from `expenses`.

- `unique_category_name_lower`
  - On `expense_categories(LOWER(name))`.
  - Prevents case-insensitive duplicate category names.

- `unique_vendor_name_lower`
  - On `vendors(LOWER(name))`.
  - Prevents case-insensitive duplicate vendor names.

### Query/Analytics Indexes

- `idx_expenses_site`
  - On `expenses(site_id)`.
  - Helps site-level expense queries.

- `idx_expenses_firm`
  - On `expenses(firm_id)`.
  - Helps firm-level expense queries and analytics.

- `idx_expenses_date`
  - On `expenses(expense_date)`.
  - Helps date/month-based expense queries.

- `idx_expenses_category`
  - On `expenses(category_id)`.
  - Helps category spending breakdowns.

- `idx_documents_site`
  - On `documents(site_id)`.
  - Helps site document listing.

## Analytics Views

The analytics migration adds read-only views over active expenses. All analytics views ignore soft-deleted expenses by filtering `expenses.soft_deleted_at IS NULL`.

## `view_firm_analytics`

Firm-level spending summary.

### Output

- `firm_id`
- `total_spend`
- `total_gst`
- `total_base`
- `expense_count`

### Behavior

- Groups expenses by `firm_id`.
- Sums total amount, GST amount, and base amount.
- Counts expenses per firm.

## `view_site_analytics`

Site-level spending summary.

### Output

- `site_id`
- `firm_id`
- `total_spend`
- `total_gst`
- `total_base`
- `expense_count`

### Behavior

- Groups expenses by `site_id` and `firm_id`.
- Gives project-level totals.

## `view_category_analytics`

Category spending breakdown.

### Output

- `site_id`
- `firm_id`
- `category_id`
- `category_name`
- `total_spend`

### Behavior

- Left joins `expense_categories`.
- Groups spending by site, firm, and category.
- Allows category breakdowns at site or firm level.

## `view_monthly_analytics`

Monthly spending trend.

### Output

- `site_id`
- `firm_id`
- `month_date`
- `total_spend`

### Behavior

- Groups expenses by site, firm, and month.
- Uses the first day of each month as `month_date`.

## `view_vendor_analytics`

Vendor spending breakdown.

### Output

- `site_id`
- `vendor_id`
- `vendor_name`
- `total_spend`

### Behavior

- Left joins `vendors`.
- Groups spending by site and vendor.
- Useful for seeing which vendors received the most spend on a site.

## High-Level Data Flow

1. A user signs up in Supabase Auth.
2. The `on_auth_user_created` trigger creates a matching `profiles` row.
3. If the auth user is deleted later, the `on_auth_user_deleted` trigger marks the profile inactive.
4. Firms are created as top-level business entities.
5. Sites are created under firms.
6. Expenses are created under a site and firm.
7. The composite expense foreign key guarantees the expense firm matches the site's firm.
8. Documents are created under a site.
9. Documents inherit firm context through their site.
10. Updates to firms, profiles, sites, expenses, and documents automatically refresh `updated_at`.
11. Soft-deleted expenses/documents remain in the database but are hidden from normal app queries and analytics.

## Important Current Design Notes

- `documents` intentionally does not store `firm_id`; it derives firm ownership through `site_id`.
- `expenses` does store `firm_id` for easier firm-level querying and analytics, but the database enforces that it matches the selected site.
- `profiles` intentionally survives auth user deletion so historical expenses/documents can still show who created or paid for them.
- `gst_amount` is stored separately from `gst_percentage`; the database validates percentage range but does not currently verify that `gst_amount` mathematically matches `amount`.
- RLS is enabled, but current policies allow full access to both `authenticated` and `anon`.
- Categories and vendors are global lookup tables, not firm-specific or site-specific.
