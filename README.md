Run App with local supabase
flutter run --dart-define-from-file=config/local.json

Run DB test file
supabase db query --local --file supabase\tests\database_behavior.sql
powershell -ExecutionPolicy Bypass -File .\supabase\tests\run_database_behavior.ps1