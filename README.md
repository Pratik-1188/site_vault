Run App with local supabase
flutter run --dart-define-from-file=config/local.json

Run DB test file
supabase db query --local --file supabase\tests\database_behavior.sql
powershell -ExecutionPolicy Bypass -File .\supabase\tests\run_database_behavior.ps1

TODO:
3. "Stringly-Typed" Joins
The Issue: Database relations are joined using raw hardcoded strings, such as select('*, expense_categories(*), vendors(*)').
Why it's a flaw: These queries are not compiler-safe. If a database column or table name changes (e.g., renaming expense_categories to categories), the Dart compiler won't warn you, and the app will crash at runtime.

expense and its attachment addition deletion should happen in ATOMIC way

firm soft deletion should be allowed and when soft deleted all the related expenses must be soft deleted

date filtering for sites and expenses

# Run all repository tests only
flutter test test/repository/

# Run a single repository test file
flutter test test/repository/feature/site_repository_test.dart

# Run with verbose output
flutter test test/repository/ --reporter expanded

# Run with coverage
flutter test --coverage test/repository/
genhtml coverage/lcov.info -o coverage/html