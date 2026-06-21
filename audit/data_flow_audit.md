# Data Flow & Architectural Audit

> **Scope:** All feature modules — Admin, Expense, Document, Site, Home  
> **Date:** 2026-06-21  
> **Goal:** Identify violations of structural layer isolation between UI → Provider → Repository

---

## 1. User Input Collection & Form Mapping

### Summary

All forms use **local widget state** (`TextEditingController`, `bool`, `DateTime?`, `String?`) to hold collected data. No form uses a dedicated `FormModel`, `ChangeNotifier`, or provider-side state object. Data extraction happens inline in `_submit()` / `_submitForm()` methods.

### Inventory of All Forms

#### `_VendorFormSheet` — admin_screen.dart

| Input | Type | Line | State Variable |
|-------|------|------|----------------|
| Vendor Business Name * | `TextFormField` | L636 | `_nameController` (L573) |
| Contact / Phone Info | `TextFormField` | L645 | `_contactController` (L574) |
| Active Status | `SwitchListTile` | L656 | `_isActive` (L575) |

Data extracted at L595–596 via `.text.trim()`. Passed as **raw primitives** to provider.

---

#### `_CategoryFormSheet` — admin_screen.dart

| Input | Type | Line | State Variable |
|-------|------|------|----------------|
| Expense Category Name * | `TextFormField` | L749 | `_nameController` (L692) |
| Active Status | `SwitchListTile` | L761 | `_isActive` (L693) |

Data extracted at L711 via `.text.trim()`. Passed as **raw primitives** to provider.

---

#### `_UserFormSheet` — admin_screen.dart

| Input | Type | Line | State Variable |
|-------|------|------|----------------|
| Display Name * | `TextFormField` | L863 | `_displayNameController` (L797) |
| Email Address * | `TextFormField` | L885 | `_emailController` (L795) |
| Password * | `TextFormField` | L904 | `_passwordController` (L796) |
| User Role * | `DropdownButtonFormField<String>` | L920 | `_selectedRole` (L798) |

Data extracted at L811–813. Passed as **raw primitives**. Note: password is NOT trimmed (L812).

---

#### `ExpenseFormSheet` — expense_form_sheet.dart

| Input | Type | Line | State Variable |
|-------|------|------|----------------|
| Title * | `TextFormField` | L328 | `_titleController` (L47) |
| Amount * | `TextFormField` | L348 | `_amountController` (L48) |
| Description | `TextEditingController` declared | L49 | `_descriptionController` — **⚠ orphaned, no widget renders it** |
| Expense Date | `showDatePicker` | L103 | `_selectedDate` (L51) |
| Payment Mode | `DropdownButtonFormField<PaymentMode>` | L431 | `_selectedPaymentMode` (L52) |
| Is Refundable | `SwitchListTile` | L514 | `_isRefundable` (L53) |
| Category | `DropdownButtonFormField<String>` | L410 | `_selectedCategoryId` (L55) |
| Vendor | `DropdownButtonFormField<String>` | L466 | `_selectedVendorId` (L56) |
| GST Bill | `SwitchListTile` | L372 | `_isGst` (L58) |
| File Attachment | `FilePicker` / `ImagePicker` | L148–189 | `_pickedFileName` (L61), `_pickedFileBytes` (L62) |
| Firm / Site | Scope Selector (mixin) | L314 | `selectedFirmId`, `selectedSiteId` |

Data extracted at L259–279 — builds a **full `Expense` DTO** (see §2).

> [!WARNING]
> `_descriptionController` (L49) is declared, initialized (L74–76), and disposed, but **no `TextFormField` widget renders it in `build()`**. It is still read in `_submitForm()` at L266 — users cannot actually input a description.

---

#### `DocumentUploadSheet` — document_upload_sheet.dart

| Input | Type | Line | State Variable |
|-------|------|------|----------------|
| File Name * | `TextFormField` | L209 | `_fileNameController` (L41) |
| Description | `TextFormField` | L226 | `_descriptionController` (L42) |
| File Attachment | `FilePicker` | L70 | `_pickedFileBytes` (L46), `_pickedFileName` (L45) |
| Firm / Site | Scope Selector (mixin) | L198 | `selectedFirmId`, `selectedSiteId` |

Data extracted at L162–174 — builds a **full `SiteDocument` DTO** (see §2).

---

#### `_SiteFormSheet` — site_search_screen.dart

| Input | Type | Line | State Variable |
|-------|------|------|----------------|
| Site Name * | `TextFormField` | L806 | `_nameController` (L739) |
| Description / Scope | `TextFormField` | L825 | `_descriptionController` (L740) |
| Start Date * | `TextFormField` (read-only) + `showDatePicker` | L836 | `_startedOn` (L742) |

Data extracted at L773–774 via `.text.trim()`. Passed as **raw primitives** to provider — but includes hardcoded `status: 'active'` (see §4).

---

#### `SettingsTab` — settings_tab.dart (inline editing)

| Input | Type | Line | State Variable |
|-------|------|------|----------------|
| Site/Project Name | `TextFormField` | L121 | `_nameEditController` (L34) |
| Description | `TextFormField` | L130 | `_descEditController` (L35) |
| Start Date | Date picker | L153 | `_selectedStartDate` (L36) |
| Status changes | Action cards | L252, L271 | Passed as raw string params |

Data passed at L200–205 via callback. **⚠ No form-level validation** (see §3).

---

#### `showEditDocumentDialog` — site_detail_dialogs.dart

| Input | Type | Line | State Variable |
|-------|------|------|----------------|
| File Name * | `TextFormField` | L335 | `fileNameController` (L310) |
| Description | `TextFormField` | L349 | `descriptionController` (L311) |

Constructs a **full `SiteDocument` DTO** at L382–395 (see §2).

---

## 2. UI-Layer DTO Instantiation

### Findings

Three forms instantiate full domain model objects directly in the UI layer. The remaining forms correctly pass raw primitives upstream.

---

#### ⚠ `ExpenseFormSheet._submitForm()` — expense_form_sheet.dart L259–279

```dart
final expense = Expense(
  id: widget.expenseToEdit?.id ?? '',        // ← placeholder empty string
  firmId: selectedFirmId!,
  siteId: selectedSiteId!,
  createdBy: currentUserId,
  title: _titleController.text.trim(),
  description: _descriptionController.text.trim().isEmpty ? null : ...,
  attachmentPath: fileUrl ?? widget.expenseToEdit?.attachmentPath,
  expenseDate: _selectedDate,
  categoryId: _selectedCategoryId,
  vendorId: _selectedVendorId,
  amount: total,
  isGst: _isGst,
  paymentMode: _selectedPaymentMode,
  isRefundable: _isRefundable,
  createdAt: widget.expenseToEdit?.createdAt ?? DateTime.now(),  // ← dead value
  updatedAt: DateTime.now(),                                      // ← dead value
);
```

**Issues:**
- `id: ''` — empty string placeholder, never sent to DB (excluded by serialization) but misleading
- `createdAt` / `updatedAt` set client-side but **excluded from `toJson()`** — dead values that exist only in memory
- Full model object passed to `expenseActionsProvider.createExpense(expense)` at L282

---

#### ⚠ `DocumentUploadSheet._submitForm()` — document_upload_sheet.dart L162–174

```dart
final document = SiteDocument(
  id: '',                                           // ← placeholder
  siteId: selectedSiteId!,
  createdBy: uploaderId,
  fileName: _fileNameController.text.trim(),
  description: ...,
  fileUrl: fileUrl,
  createdAt: DateTime.now(),                         // ← dead value
  updatedAt: DateTime.now(),                         // ← dead value
);
```

**Issues:** Same pattern — `id: ''` placeholder, `createdAt`/`updatedAt` set but excluded from `toInsertJson()`.

---

#### ⚠ `showEditDocumentDialog()` — site_detail_dialogs.dart L382–395

```dart
final updatedDoc = SiteDocument(
  id: document.id,
  siteId: document.siteId,
  createdBy: document.createdBy,
  fileName: fileNameController.text.trim(),
  description: ...,
  fileUrl: document.fileUrl,
  createdAt: document.createdAt,
  updatedAt: DateTime.now(),                         // ← UI sets timestamp
  softDeletedAt: document.softDeletedAt,
  createdByProfile: document.createdByProfile,
);
```

**Issues:** Full DTO constructed in a UI dialog. `updatedAt` set client-side.

---

#### ✅ Forms that pass primitives correctly

| Form | Method | Pattern |
|------|--------|---------|
| `_VendorFormSheet` | `addVendor(name:, contactInfo:)` | Raw strings ✅ |
| `_CategoryFormSheet` | `addCategory(name:)` | Raw string ✅ |
| `_UserFormSheet` | `addUser(email:, password:, displayName:, role:)` | Raw strings ✅ |
| `_SiteFormSheet` | `createSite(firmId:, name:, description:, startedOn:, status:)` | Raw primitives ✅ |
| `SettingsTab` | callback with `(id, name, desc, date)` | Raw primitives ✅ |

---

## 3. Form Validation

### Summary

All forms use **inline `validator:` callbacks** on individual `TextFormField` widgets. No form delegates validation to a utility class, provider, or validation service. Cross-field validations are absent.

### Complete Validation Inventory

| Form | Field | Validator | Location |
|------|-------|-----------|----------|
| **VendorForm** | Name | `val.trim().isEmpty → 'Please enter a name'` | admin_screen.dart L642 |
| | Contact | ❌ None (optional) | |
| **CategoryForm** | Name | `val.trim().isEmpty → 'Please enter a category name'` | admin_screen.dart L757 |
| **UserForm** | Display Name | Empty + min 3 chars + no-spaces regex | admin_screen.dart L868–879 |
| | Email | Empty + `!val.contains('@')` | admin_screen.dart L890–898 |
| | Password | Empty + min 6 chars | admin_screen.dart L909–917 |
| | Role | ❌ None (dropdown always has value) | |
| **ExpenseForm** | Title | Empty + min 3 chars | expense_form_sheet.dart L337–345 |
| | Amount | Empty + `double.tryParse` + must be > 0 | expense_form_sheet.dart L360–369 |
| | Firm/Site | Manual null-check in `_submitForm()` L235–238 | Snackbar error, not field-level |
| | Auth user | Manual null-check in `_submitForm()` L226–233 | Snackbar error |
| **DocumentUpload** | File Name | `val.trim().isEmpty → 'Please enter a file name'` | document_upload_sheet.dart L218–223 |
| | Firm/Site | Manual null-check in `_submitForm()` L118–124 | Snackbar error |
| | File bytes | Manual null-check in `_submitForm()` L126–132 | Snackbar error |
| **SiteForm** | Site Name | Empty + min 3 chars | site_search_screen.dart L814–822 |
| | Start Date | `_startedOn == null` guard in `_submit()` L769 | Short-circuit return |
| **SettingsTab** | Name | ❌ **None** | settings_tab.dart L121–128 |
| | Description | ❌ None | |
| | Start Date | ❌ None — defaults to `DateTime.now()` if null | settings_tab.dart L204 |
| **EditDocDialog** | File Name | `val.trim().isEmpty → 'File Name is required'` | site_detail_dialogs.dart L341–346 |

### Notable Issues

> [!WARNING]
> **`SettingsTab` has zero form validators.** The only guard is a check in `SiteDetailController.saveSiteSettings()` at L132–134 (`name.trim().isEmpty`). An empty site name can reach the controller and display a snackbar error rather than highlighting the field.

> [!NOTE]
> **`ExpenseFormSheet` amount parsing** at L259 uses `double.parse()` (throws on failure) instead of `double.tryParse()`. It relies on the validator at L364 having already run. No `try-catch` wraps L259 — a race condition between validate and submit could cause a `FormatException`.

> [!NOTE]
> **User email validation** at admin_screen.dart L894 uses only `!val.contains('@')` — a very weak check with no proper email format regex.

---

## 4. Enum & Type Mapping Leakage

### 4.1 Site Status — `'active'` / `'completed'` / `'deleted'` scattered as raw strings

**No `SiteStatus` enum exists anywhere in the codebase.** The `Site` model (site.dart L11) stores `status` as a raw `String`. This has led to **22+ hardcoded string comparisons** across 10 files:

#### `'active'` — 14 occurrences

| File | Line | Code |
|------|------|------|
| site_search_screen.dart | L67 | `ref.read(selectedStatusProvider.notifier).update('active')` |
| site_search_screen.dart | L428 | `value: 'active'` (filter chip) |
| site_search_screen.dart | L781 | `status: 'active'` (createSite call) |
| site_provider.dart | L52 | `String? build() => 'active'` (default filter) |
| site_provider.dart | L147 | `String status = 'active'` (createSite param default) |
| site_repository.dart | L58 | `.eq('status', 'active')` (fetchActiveSites query) |
| site_repository.dart | L99 | `String status = 'active'` (createSite param default) |
| site_detail_controller.dart | L82 | `(site?.status ?? 'active') == 'active'` |
| site_detail_controller.dart | L140 | `currentSite?.status ?? 'active'` |
| settings_tab.dart | L55 | `widget.site.status == 'active'` |
| expense_tab.dart | L271 | `widget.site.status == 'active'` |
| documents_tab.dart | L170 | `widget.site.status == 'active'` |
| home_screen.dart | L494 | `newData?['status'] as String? ?? 'active'` |
| admin_screen.dart | L283 | `vendor.isActive ? 'active' : 'inactive'` (StatusBadge) |

#### `'completed'` — 5 occurrences

| File | Line | Code |
|------|------|------|
| site_search_screen.dart | L436 | `value: 'completed'` (filter chip) |
| site_detail_controller.dart | L155 | `targetStatus == 'completed'` |
| settings_tab.dart | L75 | `widget.site.status == 'completed'` |
| settings_tab.dart | L84 | `widget.site.status == 'completed'` |
| settings_tab.dart | L252 | `status: 'completed'` |

#### `'deleted'` — 3 occurrences

| File | Line | Code |
|------|------|------|
| site_search_screen.dart | L444 | `value: 'deleted'` (filter chip) |
| site_detail_dialogs.dart | L33 | `normalizedTo == 'deleted'` |
| settings_tab.dart | L271 | `status: 'deleted'` |

#### `'inactive'` — 4 occurrences

| File | Line | Code |
|------|------|------|
| admin_screen.dart | L283 | `'inactive'` (vendor StatusBadge) |
| admin_screen.dart | L387 | `'inactive'` (category StatusBadge) |
| admin_screen.dart | L504 | `'inactive'` (profile StatusBadge) |
| status_badge.dart | L35 | `case 'inactive':` (switch) |

#### `StatusBadge` widget — status_badge.dart L24–49

The `StatusBadge` widget itself hardcodes a `switch` on raw strings:
```dart
case 'active':    → green
case 'completed': → blue
case 'inactive':  → orange
case 'deleted':   → red
```

---

### 4.2 User Role — `'staff'` / `'admin'` hardcoded in UI

| File | Line | Code |
|------|------|------|
| admin_screen.dart | L798 | `String _selectedRole = 'staff'` (default value) |
| admin_screen.dart | L928 | `value: 'staff'` (dropdown item) |
| admin_screen.dart | L929 | `child: Text('staff')` (displays raw DB value to user) |
| admin_screen.dart | L932 | `value: 'admin'` (dropdown item) |
| admin_screen.dart | L933 | `child: Text('admin')` (displays raw DB value to user) |
| admin_screen.dart | L822 | `'Role': _selectedRole` (review dialog shows raw string) |

> [!IMPORTANT]
> The role dropdown shows **raw database enum values** (`'staff'`, `'admin'`) directly as user-facing text labels. No display-label mapping exists.

---

### 4.3 Payment Mode — ✅ Properly encapsulated

The `PaymentMode` enum in expense.dart (L4–87) correctly encapsulates all DB string mapping:
- `fromString()` — DB string → enum
- `toDbString()` — enum → DB string
- `toDisplayLabel()` — enum → user-facing label

The expense form dropdown uses `PaymentMode.values` and `.toDisplayLabel()` — **no raw DB strings leak into the UI**. This is the model to follow for site status and user role.

---

### 4.4 Table Name Strings in Home Screen

| File | Line | Code |
|------|------|------|
| home_screen.dart | L476 | `if (tableName == 'expenses')` |
| home_screen.dart | L487 | `else if (tableName == 'sites')` |

These compare against audit log table names — acceptable in context but could be constants.

---

## 5. Soft-Delete Filtration

### Architecture Summary

The codebase uses **two different soft-delete strategies** depending on the entity type:

| Entity | Strategy | Field | Filtered Where? |
|--------|----------|-------|-----------------|
| **Expenses** | `soft_deleted_at` timestamp | `expense.softDeletedAt` | Repository query (`.isFilter('soft_deleted_at', null)`) |
| **Documents** | `soft_deleted_at` timestamp | `document.softDeletedAt` | Repository query (`.isFilter('soft_deleted_at', null)`) |
| **Sites** | Status string | `site.status = 'deleted'` | Repository query (`.eq('status', ...)`) — no `soft_deleted_at` column |
| **Vendors** | `is_active` boolean | `vendor.isActive` | ❌ **Not filtered** — admin shows all |
| **Categories** | `is_active` boolean | `category.isActive` | ❌ **Not filtered** — admin shows all |
| **Profiles** | `is_active` boolean | `profile.isActive` | ❌ **Not filtered** — admin shows all |

### Detailed Findings

#### ✅ Expenses — Clean single-point filtration
- **Repository** (`expense_repository.dart` L18): `.isFilter('soft_deleted_at', null)` — excludes soft-deleted rows at query level
- **Provider**: No additional filtering — relies on repository
- **Widget** (`expense_tab.dart`): No widget-level filtering — relies on provider data

#### ✅ Documents — Clean single-point filtration
- **Repository** (`document_repository.dart` L16): `.isFilter('soft_deleted_at', null)` — excludes soft-deleted rows
- **Provider**: No additional filtering
- **Widget** (`documents_tab.dart`): No widget-level filtering

#### ⚠ Sites — No `soft_deleted_at` column, uses status string instead
- **Model** (`site.dart`): **No `softDeletedAt` field exists.** Status is a raw `String`.
- **Repository** (`site_repository.dart`): Filters by `status` param, not by `soft_deleted_at`. Deleted sites show when status filter = `'deleted'` or `null`.
- **Widget**: No widget-level filtering — relies entirely on status-based query filtering.

> [!NOTE]
> The inconsistency between expenses/documents (which use `soft_deleted_at` timestamps) and sites (which use a `status = 'deleted'` string) creates a dual-strategy soft-delete architecture. This is not a bug — sites intentionally surface "deleted" entries via the status filter — but it means the soft-delete pattern is not uniform.

#### ✅ Admin entities (Vendors, Categories, Profiles) — Intentionally unfiltered
- **Repository** (`admin_repository.dart`): No `soft_deleted_at` or `is_active` filter in queries — returns ALL records.
- **Admin screen**: Shows all records with `StatusBadge` indicating active/inactive. This is intentional — admins need to see and manage deactivated entities.

#### ⚠ `Expense.toJson()` includes `soft_deleted_at`
- `expense.dart` L273: `'soft_deleted_at': softDeletedAt?.toIso8601String()`
- On update operations, this serializes `softDeletedAt` (usually `null` for active records). If a soft-deleted expense were ever edited, this could **unintentionally clear the deletion timestamp**, resurrecting the record.

---

## Cross-Cutting Summary

| # | Audit Parameter | Severity | Key Finding |
|---|-----------------|----------|-------------|
| 1 | Input Collection | ⚠ Medium | `_descriptionController` in ExpenseFormSheet is orphaned — declared but never rendered as a widget (L49) |
| 2 | DTO Instantiation | ⚠ Medium | 3 forms construct full model DTOs in UI layer (Expense L259, Document L162, EditDocDialog L382) with dead `createdAt`/`updatedAt` values |
| 3 | Form Validation | ⚠ Medium | `SettingsTab` has zero form validators — name can be empty until controller catches it |
| 3 | Form Validation | ℹ Low | `double.parse()` in expense submit (L259) has no try-catch — relies on pre-validation |
| 3 | Form Validation | ℹ Low | Email validation is weak (`!val.contains('@')`) — no proper format check |
| 4 | Enum Leakage | 🔴 High | **22+ hardcoded `'active'`/`'completed'`/`'deleted'` strings** across 10 files — no `SiteStatus` enum exists |
| 4 | Enum Leakage | ⚠ Medium | `'staff'`/`'admin'` role strings hardcoded in UI dropdown with raw DB values shown as labels |
| 4 | Enum Leakage | ✅ Good | `PaymentMode` enum is properly encapsulated with `fromString()`/`toDbString()`/`toDisplayLabel()` |
| 5 | Soft-Delete | ℹ Info | Dual strategy: expenses/documents use `soft_deleted_at` timestamp, sites use `status = 'deleted'` string |
| 5 | Soft-Delete | ⚠ Medium | `Expense.toJson()` includes `soft_deleted_at` — could unintentionally clear deletion on update |
