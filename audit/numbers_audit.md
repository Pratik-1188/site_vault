# Numbers Audit

Scope: this audit covers where the app **displays numbers** and where it **collects numbers from users**. I am intentionally ignoring chip/status badges and other non-numeric presentation unless they are part of a numeric flow.

## High-Level Summary

- The app has a clear money-centric UI. Most numeric values revolve around `Expense.amount`, dashboard totals, analytics splits, and site-level expense summaries.
- Numeric input is much narrower than numeric display. The main free-form numeric entry is the **expense amount** field. A secondary numeric-ish entry exists for **vendor contact / phone info** in the admin panel.
- The biggest inconsistency is formatting: the same currency is shown with different precision and presentation styles across screens.
- There is also a mild separation issue: display formatting is spread across multiple screens instead of being standardized through one shared formatter.

## Where Numbers Are Displayed

### Home Screen

- File: [home_screen.dart](/D:/Projects/KK%20Group/site_vault/lib/feature/home/screen/home_screen.dart)
- The current financial year total expense is displayed as currency with comma grouping and zero decimals:
  - [`home_screen.dart:217`](D:/Projects/KK%20Group/site_vault/lib/feature/home/screen/home_screen.dart#L217)
- Active site count is displayed as a plain integer:
  - [`home_screen.dart:280`](D:/Projects/KK%20Group/site_vault/lib/feature/home/screen/home_screen.dart#L280)
- Missing bill amount is displayed as currency with comma grouping and zero decimals:
  - [`home_screen.dart:340`](D:/Projects/KK%20Group/site_vault/lib/feature/home/screen/home_screen.dart#L340)
- Recent audit logs show:
  - expense amount as `₹...` with 2 decimals
  - site status as text
  - [`home_screen.dart:534`](D:/Projects/KK%20Group/site_vault/lib/feature/home/screen/home_screen.dart#L534)
  - [`home_screen.dart:537`](D:/Projects/KK%20Group/site_vault/lib/feature/home/screen/home_screen.dart#L537)

### Analytics Dashboard

- File: [analytics_dashboard_screen.dart](/D:/Projects/KK%20Group/site_vault/lib/feature/analytics/screen/analytics_dashboard_screen.dart)
- KPI grid shows:
  - total spend as `₹...` with 2 decimals
  - transaction count as `"$count logs"`
  - [`analytics_dashboard_screen.dart:236`](D:/Projects/KK%20Group/site_vault/lib/feature/analytics/screen/analytics_dashboard_screen.dart#L236)
  - [`analytics_dashboard_screen.dart:237`](D:/Projects/KK%20Group/site_vault/lib/feature/analytics/screen/analytics_dashboard_screen.dart#L237)
- Firm spend split rows show currency with 2 decimals and percentage as an integer percentage:
  - [`analytics_dashboard_screen.dart:321`](D:/Projects/KK%20Group/site_vault/lib/feature/analytics/screen/analytics_dashboard_screen.dart#L321)
- Category spend rows also show currency with 2 decimals and percentage as an integer percentage:
  - [`analytics_dashboard_screen.dart:399`](D:/Projects/KK%20Group/site_vault/lib/feature/analytics/screen/analytics_dashboard_screen.dart#L399)
  - [`analytics_dashboard_screen.dart:409`](D:/Projects/KK%20Group/site_vault/lib/feature/analytics/screen/analytics_dashboard_screen.dart#L409)
- Monthly spend trend rows show currency with 2 decimals:
  - [`analytics_dashboard_screen.dart:495`](D:/Projects/KK%20Group/site_vault/lib/feature/analytics/screen/analytics_dashboard_screen.dart#L495)

### Site Detail Expense Tab

- File: [expense_tab.dart](/D:/Projects/KK%20Group/site_vault/lib/feature/site/widgets/expense_tab.dart)
- The site-level total expenses card displays currency with 2 decimals:
  - [`expense_tab.dart:85`](D:/Projects/KK%20Group/site_vault/lib/feature/site/widgets/expense_tab.dart#L85)
- Each expense card displays the individual expense amount with 2 decimals:
  - [`expense_tab.dart:259`](D:/Projects/KK%20Group/site_vault/lib/feature/site/widgets/expense_tab.dart#L259)
- This means the same “money” concept is shown differently here compared with the Home screen, which uses zero-decimal totals and comma grouping.

### Site Detail Dialog

- File: [site_detail_dialogs.dart](/D:/Projects/KK%20Group/site_vault/lib/feature/site/screen/site_detail_dialogs.dart)
- Expense detail dialog shows the selected expense amount with 2 decimals:
  - [`site_detail_dialogs.dart:145`](D:/Projects/KK%20Group/site_vault/lib/feature/site/screen/site_detail_dialogs.dart#L145)

### Site Search Screen

- File: [site_search_screen.dart](/D:/Projects/KK%20Group/site_vault/lib/feature/site/screen/site_search_screen.dart)
- The screen uses a date range picker for filtering:
  - [`site_search_screen.dart:185`](D:/Projects/KK%20Group/site_vault/lib/feature/site/screen/site_search_screen.dart#L185)
- The site creation form includes a start date field and displays it as a readable date, not as a number:
  - [`site_search_screen.dart:833`](D:/Projects/KK%20Group/site_vault/lib/feature/site/screen/site_search_screen.dart#L833)
  - [`site_search_screen.dart:963`](D:/Projects/KK%20Group/site_vault/lib/feature/site/screen/site_search_screen.dart#L963)
- Site creation itself does not expose a free-form numeric field in this screen.

## Where Numbers Are Collected From Users

### Expense Amount

- File: [expense_form_sheet.dart](/D:/Projects/KK%20Group/site_vault/lib/feature/expense/screen/expense_form_sheet.dart)
- This is the main numeric input in the app.
- The form stores and parses `amount` as a `double`:
  - [`expense_form_sheet.dart:47`](D:/Projects/KK%20Group/site_vault/lib/feature/expense/screen/expense_form_sheet.dart#L47)
  - [`expense_form_sheet.dart:308`](D:/Projects/KK%20Group/site_vault/lib/feature/expense/screen/expense_form_sheet.dart#L308)
- The amount field uses a decimal-capable numeric keyboard:
  - [`expense_form_sheet.dart:536`](D:/Projects/KK%20Group/site_vault/lib/feature/expense/screen/expense_form_sheet.dart#L536)
- Validation enforces:
  - required
  - parsable as a number
  - strictly positive
  - [`expense_form_sheet.dart:544`](D:/Projects/KK%20Group/site_vault/lib/feature/expense/screen/expense_form_sheet.dart#L544)
  - [`expense_form_sheet.dart:550`](D:/Projects/KK%20Group/site_vault/lib/feature/expense/screen/expense_form_sheet.dart#L550)

### Vendor Contact / Phone Info

- File: [admin_screen.dart](/D:/Projects/KK%20Group/site_vault/lib/feature/admin/screen/admin_screen.dart)
- The vendor form collects contact information using a phone keyboard:
  - [`admin_screen.dart:776`](D:/Projects/KK%20Group/site_vault/lib/feature/admin/screen/admin_screen.dart#L776)
  - [`admin_screen.dart:778`](D:/Projects/KK%20Group/site_vault/lib/feature/admin/screen/admin_screen.dart#L778)
- This is the only other obvious user-entered numeric-style field I found in the main app flows.
- There is no strong numeric validation pattern here comparable to the expense amount field.

## Supporting Data Models

- File: [expense.dart](/D:/Projects/KK%20Group/site_vault/lib/feature/expense/model/expense.dart)
- Expense amount is modeled as a `double`:
  - [`expense.dart:53`](D:/Projects/KK%20Group/site_vault/lib/feature/expense/model/expense.dart#L53)
  - [`expense.dart:91`](D:/Projects/KK%20Group/site_vault/lib/feature/expense/model/expense.dart#L91)
- This matches the UI behavior, which assumes amounts are decimal values.

### Analytics Models

- File: [analytics_models.dart](/D:/Projects/KK%20Group/site_vault/lib/feature/analytics/model/analytics_models.dart)
- Analytics summaries use numeric fields such as `totalSpend`, `expenseCount`, and `percentage`.
- This is the source of the values shown in the dashboard cards and charts.

## Inconsistencies

### Currency Formatting Is Not Standardized

- Home totals use comma grouping and zero decimals.
- Expense cards, expense detail dialogs, analytics totals, and monthly/category/firms splits use 2 decimals.
- Some screens show `₹--` on error, while others show raw error text or generic placeholders.
- This makes the same concept feel inconsistent across the app.

### Different Screens Format the Same Money Differently

- Home:
  - `₹12,34,567`
- Expense tab / expense detail:
  - `₹123456.78`
- Analytics:
  - `₹123456.78`
- That is functionally acceptable, but visually inconsistent.

### Numeric Presentation Is Mixed With Raw UI Logic

- Formatting logic is repeated in:
  - home dashboard
  - expense tab
  - site detail dialogs
  - analytics dashboard
- The app would be easier to maintain if a single money/number formatter were used everywhere.

### User Input Rules Are Asymmetric

- Expense amount has strict validation.
- Vendor contact uses a phone keyboard but does not show similarly strict numeric validation in the screen code I inspected.
- Site creation uses dates and text, but no free-form number input.

## What Looks Good

- Expense amount validation is sensible:
  - it accepts decimals
  - it rejects empty/invalid values
  - it rejects zero or negative values
- The app consistently treats financial values as `double`.
- Dashboard analytics use clear derived metrics:
  - totals
  - counts
  - percentages
- The site detail dialog presents the amount cleanly and the relevant summary details in one place.

## Risks

- Inconsistent money formatting can make the same amount look different depending on screen.
- Raw parsing with `double.parse(...)` in the expense form can still throw if validation is bypassed or form state becomes inconsistent.
- Phone/contact fields may end up being entered in many formats unless a normalization rule exists elsewhere.

## Recommendations

- Standardize all currency display through one helper:
  - same currency symbol
  - same decimal rule
  - same grouping rule
- Standardize number display separately from currency display:
  - counts as plain integers
  - percentages as whole numbers
  - totals as formatted money
- Keep user-entered numeric validation strict:
  - required
  - parseable
  - positive
- Decide whether phone/contact input should be treated as a true numeric field or as free-form contact text.
- If the app will keep growing, move number formatting into a shared utility so the formatting is not duplicated in each screen.

## Bottom Line

- **Main display hotspots:** home dashboard, analytics dashboard, site expense tab, and expense detail dialog.
- **Main numeric input hotspot:** expense amount in the expense form.
- **Secondary numeric-ish input hotspot:** vendor contact / phone field in admin.
- **Biggest issue:** currency/number formatting is repeated and inconsistent, not the data model itself.
