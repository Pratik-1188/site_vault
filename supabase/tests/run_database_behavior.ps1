$ErrorActionPreference = 'Stop'

$sqlPath = Join-Path $PSScriptRoot 'database_behavior.sql'

if (-not (Get-Command supabase -ErrorAction SilentlyContinue)) {
  throw "Supabase CLI is not installed or not on PATH."
}

& supabase db query --local --file $sqlPath
