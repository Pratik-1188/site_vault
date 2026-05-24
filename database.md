# Database Overview

This is the simple behavior map for the current Supabase database.

## Extensions and enums

- `pgcrypto`
  - Used for `gen_random_uuid()`.
- `site_status`
  - `active`, `completed`, `archived`.
- `payment_mode`
  - `cash`, `upi`, `card`, `net_banking`, `cheque`, `rtgs`, `neft`, `dd`, `other`.

## `firms`

- Top-level business table.
- A firm can have many sites.
- Deleting a firm deletes its sites.
- `updated_at` is auto-filled on update by a trigger.

## `profiles`

- One row per auth user.
- Row is created automatically when a user is inserted into `auth.users`.
- `display_name` comes from `raw_user_meta_data.display_name`, then the email prefix before `@`, then a fallback `user_<uuid-prefix>`.
- `display_name` cannot contain whitespace.
- `display_name` is unique, case-insensitive.
- Deleting the auth user does not delete the profile.
- Deleting the auth user sets `is_active = false` on the profile instead.
- `updated_at` is auto-filled on update by a trigger.

## `sites`

- Each site belongs to one firm.
- Deleting a firm deletes its sites.
- Deleting a site deletes related expenses and documents.
- `completed_on` requires `started_on`.
- `completed_on` must be on or after `started_on`.
- `status` uses the `site_status` enum.
- `updated_at` is auto-filled on update by a trigger.

## `expense_categories`

- Global lookup table for expense categories.
- Category names are unique, case-insensitive.
- `is_active` is a simple on/off flag.
- No update trigger.

## `vendors`

- Global lookup table for vendors.
- Vendor names are unique, case-insensitive.
- `is_active` is a simple on/off flag.
- No update trigger.

## `expenses`

- Each expense belongs to one site and one firm.
- The database enforces that the site and firm match through a composite foreign key.
- `created_by` and `paid_by` reference `profiles`.
- Deleting a site deletes related expenses.
- `amount` must be greater than `0`.
- `gst_percentage`, when present, must be between `0` and `100`.
- `title` must be longer than 2 trimmed characters.
- `payment_mode` uses the `payment_mode` enum.
- `soft_deleted_at` marks the row as deleted for app queries and analytics.
- `updated_at` is auto-filled on update by a trigger.

## `expense_attachments`

- Each attachment belongs to one expense.
- Deleting an expense deletes its attachments.
- No update trigger.

## `documents`

- Each document belongs to one site.
- `created_by` references `profiles`.
- `firm_id` is not stored in this table.
- The firm is derived through the site.
- Deleting a site deletes related documents.
- `soft_deleted_at` marks the row as deleted for app queries.
- `updated_at` is auto-filled on update by a trigger.

## Shared triggers and functions

- `handle_updated_at()`
  - Used by `firms`, `profiles`, `sites`, `expenses`, and `documents`.
  - Sets `updated_at` before each update.
- `public.handle_new_user()`
  - Runs after insert on `auth.users`.
  - Creates the matching `profiles` row.
- `public.handle_deleted_user()`
  - Runs before delete on `auth.users`.
  - Keeps the profile row and sets `is_active = false`.

## RLS

- Row Level Security is enabled on all application tables.
- Current policies give full access to `authenticated` and `anon`.

## Indexes

- `profiles(LOWER(display_name))`
  - Case-insensitive uniqueness.
- `sites(id, firm_id)`
  - Supports the expense composite foreign key.
- `expense_categories(LOWER(name))`
  - Case-insensitive uniqueness.
- `vendors(LOWER(name))`
  - Case-insensitive uniqueness.
- `expenses(site_id)`
- `expenses(firm_id)`
- `expenses(expense_date)`
- `expenses(category_id)`
- `documents(site_id)`

## Analytics views

- `view_firm_analytics`
  - Firm-level expense totals.
- `view_site_analytics`
  - Site-level expense totals.
- `view_category_analytics`
  - Category spending breakdown.
- `view_monthly_analytics`
  - Month-by-month spending totals.
- `view_vendor_analytics`
  - Vendor spending breakdown.
- All analytics views ignore expenses where `soft_deleted_at` is set.

## Quick mental model

- Firms own sites.
- Sites own expenses and documents.
- Expenses must stay inside the firm that owns the site.
- Documents do not store firm data directly.
- Profiles survive auth deletion, but become inactive.
- Updates refresh `updated_at` automatically.
- Soft deletes hide rows from normal app behavior and analytics.
