# Repetitive Code Audit — KK Group Site Vault

Scanned all 20 Dart files. Patterns are ranked by **number of duplicated lines eliminated** if extracted.

---

## 🔴 Critical — Large, verbatim copy-paste blocks

### 1. Bottom Sheet Shell — `BackdropFilter → ConstrainedBox → Material → SafeArea → Form` [RESOLVED]

**Status**: Resolved. Refactored into a reusable `AppBottomSheet` widget.

The entire structural wrapper of every bottom sheet is copy-pasted **6 times**. The only variation is the title string and the form fields inside.

**Shared skeleton (verbatim in all 6 sheets):**

```dart
BackdropFilter(
  filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
  child: ConstrainedBox(
    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
    child: Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: AppRadius.verticalMd,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Sticky header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('<title>', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20)),
                    IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
                  ]),
                ),
                const Divider(height: 24, indent: 24, endIndent: 24),
                // Scrollable body
                Flexible(child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Column(...),
                )),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
)
```

| Sheet                 | File                       | Shell starts at |
| --------------------- | -------------------------- | --------------- |
| `_VendorFormSheet`    | admin_screen.dart          | L713            |
| `_CategoryFormSheet`  | admin_screen.dart          | L909            |
| `_UserFormSheet`      | admin_screen.dart          | L1100           |
| `_SiteFormSheet`      | site_search_screen.dart    | L879            |
| `ExpenseFormSheet`    | expense_form_sheet.dart    | L372            |
| `DocumentUploadSheet` | document_upload_sheet.dart | L254            |

**Extraction:** `AppBottomSheet` widget — accepts `title`, `isLoading`, and `child` (the scrollable body).

---

### 2. `_loadSitesForFirm()` — Entire Method + 5 State Variables Duplicated

The full method body AND 5 state variables are **copy-pasted verbatim** in both `ExpenseFormSheet` and `DocumentUploadSheet`.

**Duplicated state variables (in both files):**

```dart
bool _isContextLocked = false;
bool _isLoadingSites = false;
List<Site>? _activeSites;
String? _selectedFirmId;
String? _selectedSiteId;
```

**Duplicated method (expense_form_sheet.dart L117–148 ≡ document_upload_sheet.dart L82–111):**

```dart
Future<void> _loadSitesForFirm(String firmId) async {
  if (!mounted) return;
  setState(() { _isLoadingSites = true; _activeSites = null; });
  try {
    final sitesList = await ref.read(activeSitesByFirmProvider(firmId).future);
    if (!mounted) return;
    setState(() {
      _activeSites = sitesList;
      _isLoadingSites = false;
      if (_selectedSiteId != null && !_activeSites!.any((s) => s.id == _selectedSiteId)) {
        _selectedSiteId = null;
      }
    });
  } catch (e) {
    if (!mounted) return;
    setState(() { _activeSites = []; _isLoadingSites = false; _selectedSiteId = null; });
  }
}
```

Also duplicated: the entire **Firm + Site cascading dropdown UI block** — expense_form_sheet.dart L426–512 ≡ document_upload_sheet.dart L302–374.

**Extraction:** `SiteScopeSelectorMixin` — mixin containing all 5 state vars + `_loadSitesForFirm()` + a `buildScopeSelector()` UI method.

---

### 3. `_handleSignOut()` — Identical Method in 3 Screens

**admin_screen.dart L51–69 ≡ site_search_screen.dart L227–245 ≡ home_screen.dart L23–46**

```dart
Future<void> _handleSignOut() async {
  final confirmed = await ConfirmationDialogs.confirm(context,
    title: 'Sign Out',
    message: 'Are you sure you want to sign out of KK Group Site Vault?',
    confirmLabel: 'SIGN OUT',
    isDestructive: true,
  );
  if (confirmed && mounted) {
    try {
      await ref.read(authActionsProvider).signOut();
    } catch (e) {
      if (mounted) AppSnackBar.showError(context, 'Error signing out: $e');
    }
  }
}
```

The `PopupMenuButton` that triggers this (account icon → Sign Out row) is also copy-pasted identically in **4 screens**:

- admin_screen.dart L180–204
- site_search_screen.dart L303–332
- home_screen.dart L116–140
- site_detail_screen.dart L214–242

**Extraction:** `SignOutMenuButton` widget — self-contained, handles confirmation + auth + error display.

---

### 4. `_submit()` / `_submitForm()` Skeleton — Identical in All 6 Form Sheets

The async submit lifecycle (loading guard → try → `ref.read` → `Navigator.pop` → `AppSnackBar.showSuccess` → catch → `SupabaseErrorInterceptor` → finally) is repeated **6 times**. Only the provider call changes.

```dart
setState(() => _isSaving = true);
try {
  await ref.read(someProvider.notifier).someMethod(...);
  if (mounted) {
    Navigator.pop(context);
    AppSnackBar.showSuccess(context, '... successfully!');
  }
} catch (e) {
  if (mounted) {
    final cleanMessage = SupabaseErrorInterceptor.handle(e, ref);
    AppSnackBar.showError(context, cleanMessage);
  }
} finally {
  if (mounted) setState(() => _isSaving = false);
}
```

| File                                          | Method        | Loading flag   | Lines      |
| --------------------------------------------- | ------------- | -------------- | ---------- |
| admin_screen.dart `_VendorFormSheetState`     | `_submit`     | `_isSaving`    | L673–709   |
| admin_screen.dart `_CategoryFormSheetState`   | `_submit`     | `_isSaving`    | L871–905   |
| admin_screen.dart `_UserFormSheetState`       | `_submit`     | `_isSaving`    | L1053–1096 |
| site_search_screen.dart `_SiteFormSheetState` | `_submit`     | `_isSaving`    | L847–875   |
| expense_form_sheet.dart                       | `_submitForm` | `_isUploading` | L271–364   |
| document_upload_sheet.dart                    | `_submitForm` | `_isUploading` | L155–248   |

**Extraction:** `runWithLoading(Future<void> Function() action)` utility method in a base mixin.

---

## 🟠 High — Small but extremely frequent repetition

### 5. Bottom Action Row — `[Cancel] [Submit with spinner]` — 6 Times

```dart
Row(
  mainAxisAlignment: MainAxisAlignment.end,
  children: [
    OutlinedButton(
      onPressed: _isSaving ? null : () => Navigator.pop(context),
      child: const Text('Cancel'),
    ),
    const SizedBox(width: 12),
    FilledButton(
      onPressed: _isSaving ? null : _submit,
      child: _isSaving
          ? const SizedBox(width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
          : const Text('Save ...'),
    ),
  ],
)
```

| File                           | Lines       |
| ------------------------------ | ----------- |
| admin_screen.dart (Vendor)     | L798–L824   |
| admin_screen.dart (Category)   | L985–L1011  |
| admin_screen.dart (User)       | L1235–L1257 |
| site_search_screen.dart (Site) | L980–L1002  |
| expense_form_sheet.dart        | L852–L882   |
| document_upload_sheet.dart     | L490–L512   |

**Extraction:** `SheetActionRow` widget — accepts `isSaving`, `onSubmit`, `submitLabel`.

---

### 6. `showModalBottomSheet(...)` — 8 Identical Call Sites [RESOLVED]

**Status**: Resolved. Refactored into a reusable `showAppBottomSheet` helper function.

The same 4-parameter call is repeated wherever a sheet is opened:

```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  backgroundColor: Colors.transparent,
  builder: (_) => SomeSheet(...),
);
```

| File                     | Method                     | Lines |
| ------------------------ | -------------------------- | ----- |
| admin_screen.dart        | `_openVendorForm`          | L73   |
| admin_screen.dart        | `_openCategoryForm`        | L84   |
| admin_screen.dart        | `_openUserForm`            | L95   |
| home_screen.dart         | `_openExpenseFormSheet`    | L50   |
| home_screen.dart         | `_openDocumentUploadSheet` | L64   |
| site_search_screen.dart  | `_openSiteForm`            | L217  |
| site_detail_dialogs.dart | `showExpenseSheet`         | L298  |
| site_detail_dialogs.dart | `showDocumentSheet`        | L436  |

**Extraction:** `showAppSheet(context, builder)` helper function.

---

### 7. `SupabaseErrorInterceptor.handle(e, ref)` + `AppSnackBar.showError` — 11 Catch Blocks

```dart
} catch (e) {
  if (mounted) {
    final cleanMessage = SupabaseErrorInterceptor.handle(e, ref);
    AppSnackBar.showError(context, cleanMessage);
  }
}
```

| File                        | Occurrences                  |
| --------------------------- | ---------------------------- |
| admin_screen.dart           | 4× (L143, L703, L899, L1090) |
| site_search_screen.dart     | 1× (L869)                    |
| expense_form_sheet.dart     | 1× (L352)                    |
| document_upload_sheet.dart  | 1× (L238)                    |
| site_detail_controller.dart | 3× (L199, L239, L275)        |
| site_detail_dialogs.dart    | 1× (L418)                    |

> [!WARNING]
> `site_detail_controller.dart` and `site_detail_dialogs.dart` use raw `ScaffoldMessenger.of(context).showSnackBar(...)` in some catch blocks instead of `AppSnackBar.showError` — the same pattern implemented two different ways in the same feature.

**Extraction:** `AppErrorHandler.show(context, e, ref)` — 1-line replacement for all 11 call sites.

---

### 8. Inline Button Spinner — `SizedBox(20×20) + CircularProgressIndicator(strokeWidth:2, white)` — 6 Times

```dart
const SizedBox(
  width: 20, height: 20,
  child: CircularProgressIndicator(
    strokeWidth: 2,
    valueColor: AlwaysStoppedAnimation(Colors.white),
  ),
)
```

| File                       | Count                  |
| -------------------------- | ---------------------- |
| admin_screen.dart          | 3× (L809, L996, L1246) |
| site_search_screen.dart    | 1×                     |
| expense_form_sheet.dart    | 1×                     |
| document_upload_sheet.dart | 1×                     |

**Extraction:** `AppSpinner.button()` — a `const` widget static factory.

---

### 9. NestedScrollView + SliverAppBar.medium + 4-destination NavigationBar — 3 Screens

The same 4 `NavigationDestination`s and the same `onDestinationSelected` route switch are copy-pasted in 3 screens:

```dart
NavigationBar(
  selectedIndex: N,
  onDestinationSelected: (index) {
    if (index == 0) context.go('/');
    else if (index == 1) context.go('/sites');
    else if (index == 2) context.go('/analytics');
    else context.go('/admin');
  },
  destinations: const [
    NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
    NavigationDestination(icon: Icon(Icons.location_on_outlined), selectedIcon: Icon(Icons.location_on_rounded), label: 'Sites'),
    NavigationDestination(icon: Icon(Icons.analytics_outlined), selectedIcon: Icon(Icons.analytics_rounded), label: 'Analytics'),
    NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings_rounded), label: 'Admin'),
  ],
)
```

| File                    | Lines     |
| ----------------------- | --------- |
| admin_screen.dart       | L255–L288 |
| site_search_screen.dart | L432–L465 |
| home_screen.dart        | L605–L638 |

**Extraction:** `AppNavigationBar` widget — accepts `selectedIndex`, handles routing internally.

---

## 🟡 Medium — Repetitive style constants

### 10. Hardcoded EdgeInsets — Sheet Padding Duplicated 6× Each [PARTIALLY RESOLVED]

**Status**: Partially Resolved. Sheet header and body padding are now managed by the central `AppPadding` class. Remaining layouts will be refactored alongside other layout updates.

| Constant          | Value                                                | Occurrences          | Used for             |
| ----------------- | ---------------------------------------------------- | -------------------- | -------------------- |
| Sheet header      | `EdgeInsets.fromLTRB(24, 16, 24, 0)`                 | **6 files**          | Pinned sheet header  |
| Sheet body        | `EdgeInsets.fromLTRB(24, 0, 24, 24)`                 | **6 files**          | Scrollable form area |
| Panel padding     | `EdgeInsets.symmetric(horizontal: 16, vertical: 12)` | 3× admin_screen.dart | Admin panel wrappers |
| Search/filter row | `EdgeInsets.symmetric(horizontal: 16, vertical: 8)`  | 4× across 2 files    | Search + filter rows |

**Extraction:** `AppPadding` constants class alongside `AppRadius`.

---

### 11. Hardcoded Colors

| Color                                 | Occurrences | Files                      | Correct Token                  |
| ------------------------------------- | ----------- | -------------------------- | ------------------------------ |
| `Colors.redAccent`                    | **9 times** | 6 files                    | `colorScheme.error`            |
| `Colors.grey` (fontSize 12/13)        | **6 times** | 4 files                    | `colorScheme.onSurfaceVariant` |
| `Colors.grey[400]` (empty state icon) | 2 times     | expense_tab, documents_tab | `colorScheme.outline`          |

---

### 12. `asyncValue.when(loading: CircularProgressIndicator, error: Text('Error: $e'))` — 10+ Instances

The `.when()` loading/error arms are repeated across all list views. The error string format is also inconsistent:

- `'Error loading vendors: $e'` — admin_screen
- `'Failed to load sites: $error'` — site_search (different phrasing)
- `'Err: $e'` — expense_form (abbreviated, likely accidental)

**Extraction:** `AsyncValueWidget<T>` builder widget — wraps `.when()` with standardized loading/error UI.

---

## Ranked Extraction Plan

| Priority | Extract                                | New Name                        | Copies Eliminated     | Est. Lines Saved          |
| -------- | -------------------------------------- | ------------------------------- | --------------------- | ------------------------- |
| 1        | Full bottom sheet shell                | `AppBottomSheet` widget         | 6 sheets              | **~150 lines**            |
| 2        | Firm+Site selector state + method + UI | `SiteScopeSelectorMixin`        | 2 full duplicates     | **~120 lines**            |
| 3        | Submit try/catch/finally lifecycle     | `runWithLoading()` mixin method | 6 form methods        | **~90 lines**             |
| 4        | Sign-out method + AppBar button        | `SignOutMenuButton` widget      | 4 buttons + 3 methods | **~80 lines**             |
| 5        | Bottom action row                      | `SheetActionRow` widget         | 6 rows                | **~72 lines**             |
| 6        | `showModalBottomSheet` 4-param call    | `showAppSheet()` helper         | 8 call sites          | **~48 lines**             |
| 7        | Error catch + snackbar                 | `AppErrorHandler.show()`        | 11 catch blocks       | **~44 lines**             |
| 8        | Button spinner widget                  | `AppSpinner.button()`           | 6 widgets             | **~42 lines**             |
| 9        | NavigationBar destinations             | `AppNavigationBar` widget       | 3 screens             | **~36 lines**             |
| 10       | `asyncValue.when()` boilerplate        | `AsyncValueWidget<T>`           | 10+ usages            | **~30+ lines**            |
| 11       | Sheet padding constants                | `AppPadding` class              | 12 call sites         | **~0 lines, clarity**     |
| 12       | Hardcoded `Colors.redAccent` etc.      | `colorScheme.error` tokens      | 9+ usages             | **~0 lines, correctness** |

**Total estimated reduction: ~700+ lines of duplicated code.**

---

## Files with the Most Duplication

| File                       | Total Lines | Duplication Level                                           |
| -------------------------- | ----------- | ----------------------------------------------------------- |
| admin_screen.dart          | 1203        | 🔴 Very High — 3 near-identical form sheets inside one file |
| expense_form_sheet.dart    | 851         | 🟠 High — sheet shell + scope selector + submit pattern     |
| document_upload_sheet.dart | 510         | 🟠 High — near-clone of expense form sheet                  |
| site_search_screen.dart    | 964         | 🟡 Medium — 4th form sheet + sign-out + navigation bar      |
| home_screen.dart           | 618         | 🟡 Medium — sign-out + navigation bar duplication           |
