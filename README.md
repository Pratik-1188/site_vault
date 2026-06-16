# Site Vault

Site Vault is a Flutter app backed by a local Supabase instance for managing firms, sites, expenses, documents, and related analytics.

## Local Development

Run the Flutter app against the local Supabase environment:

```powershell
flutter run --dart-define-from-file=config/local.json
```

Run as a server
```powershell
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080 --dart-define-from-file=config/local.json
```

If you are running the app on Android and Supabase is exposed locally, forward the API port:

```powershell
adb reverse tcp:54321 tcp:54321
```

## Database Behavior Tests

Run the local database behavior test script:

```powershell
supabase db query --local --file supabase\tests\database_behavior.sql
powershell -ExecutionPolicy Bypass -File .\supabase\tests\run_database_behavior.ps1
```

## Site Status Rules

The site status currently supports three values:

- `active`
- `completed`
- `deleted`

The current database already treats `deleted` as a special archival state. When a site is updated to `deleted`, a trigger soft-deletes related expenses by setting `soft_deleted_at` on rows in `expenses`. Documents are not removed by that trigger.

In the UI, `active` sites are editable. `completed` and `deleted` sites are locked in read-only mode.

## Status Transition Matrix

| Status change | Current behavior | Ideal behavior | Should this change be allowed |
|---|---|---|---|
| `active` -> `completed` | Allowed. The site is saved with `status = completed`, `completed_on = now()`, and the site becomes locked/read-only in the detail screen. Child expenses and documents are not changed. | Keep this as a valid lifecycle step for finished work. Preserve history and lock the site from routine edits. | Yes |
| `completed` -> `active` | Not allowed from the current UI because completed sites are read-only. If forced through the repository or database, the row can be updated, and `completed_on` is cleared because the app only sets it for `completed`. Child records are not restored or changed. | Reopen the site only if the business process explicitly supports reactivation. If reopened, restore editability and make the intent explicit in history. | Usually no |
| `active` -> `deleted` | Allowed. The site changes to `deleted`, the site is locked, and the database trigger soft-deletes related expenses by setting `soft_deleted_at`. Documents remain in place. | Treat this as an archive/delete action. Keep the site record for audit/history, soft-delete expenses, and keep documents attached unless a separate cleanup policy exists. | Yes |
| `deleted` -> `active` | Not allowed from the current UI because deleted sites are read-only. If forced, the site can be updated back to `active`, but the previously soft-deleted expenses stay soft-deleted. Documents are unchanged. | Only allow this if you have a real restore workflow that also explains what happens to the archived expenses. | Usually no |
| `completed` -> `deleted` | Not allowed from the current UI because completed sites are read-only. If forced, the site becomes `deleted`, `completed_on` is cleared by the app update path, and the expenses trigger will soft-delete related expenses. Documents remain. | If you need this transition, treat it as an administrative archive action with clear audit history. | Usually no |
| `deleted` -> `completed` | Not allowed from the current UI because deleted sites are read-only. If forced, the site can be updated, but the child expenses remain soft-deleted because there is no restore trigger. | Generally avoid this unless you also implement a controlled restore of archived data. | No |

## Notes

- The current app logic only sets `completed_on` when the status is `completed`.
- The site repository updates the site row only; child record side effects come from Supabase triggers.
- Expenses are already soft-deleted individually elsewhere in the app, so site deletion follows the same archival pattern.
