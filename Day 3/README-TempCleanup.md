# DWP Temp Cleanup Script (PowerShell 5.1)

This folder contains a safe temp cleanup script for Windows endpoints:
- `Invoke-DwpTempCleanup.ps1`

The script is designed to be operationally safe:
- Supports dry run mode
- Skips locked files and continues
- Uses per-file try/catch handling
- Logs every action to a timestamped log file
- Produces a summary report
- Implements rollback by moving files to quarantine (safe delete instead of permanent delete)
- Behaves idempotently on repeat runs

## Script Options

- `-DryRun`
  - Prints the list of files that would be deleted (safe delete via quarantine move).
  - Does not move/delete files.

- `-OlderThanDays <int>`
  - Only targets files with `LastWriteTime` older than this value.
  - Default is `0` (all files older than now).

- `-TargetPaths <string[]>`
  - Temp paths to scan.
  - Default:
    - `$env:TEMP`
    - `$env:WINDIR\Temp`

- `-StateRoot <string>`
  - Root location for logs, manifests, and quarantine.
  - Default: `$env:ProgramData\DWPTempCleanup`

- `-Rollback`
  - Restores files from a previous cleanup manifest.

- `-RollbackManifestPath <string>`
  - Optional manifest CSV path for rollback.
  - If omitted, the latest manifest in `Manifests` is used.

## Usage Examples

### 1) Dry run only
```powershell
powershell -ExecutionPolicy Bypass -File .\Invoke-DwpTempCleanup.ps1 -DryRun
```

### 2) Clean files older than 7 days
```powershell
powershell -ExecutionPolicy Bypass -File .\Invoke-DwpTempCleanup.ps1 -OlderThanDays 7
```

### 3) Clean custom paths
```powershell
powershell -ExecutionPolicy Bypass -File .\Invoke-DwpTempCleanup.ps1 -OlderThanDays 3 -TargetPaths @('C:\Temp', 'C:\Windows\Temp')
```

### 4) Rollback latest cleanup
```powershell
powershell -ExecutionPolicy Bypass -File .\Invoke-DwpTempCleanup.ps1 -Rollback
```

### 5) Rollback from specific manifest
```powershell
powershell -ExecutionPolicy Bypass -File .\Invoke-DwpTempCleanup.ps1 -Rollback -RollbackManifestPath 'C:\ProgramData\DWPTempCleanup\Manifests\Manifest_20260806_101500_ab12cd34.csv'
```

## Log and Rollback Artifacts

By default, artifacts are written under:
- `C:\ProgramData\DWPTempCleanup\Logs`
- `C:\ProgramData\DWPTempCleanup\Manifests`
- `C:\ProgramData\DWPTempCleanup\Quarantine`

Each execution creates:
- A timestamped log file
- A manifest CSV (only when cleanup actually moved files)

## Idempotency Notes

- Running cleanup repeatedly is safe because moved files are no longer in source temp paths.
- Rollback is safe to re-run:
  - Already restored/missing staged files are skipped.
  - Existing destination files are skipped to avoid overwrite.

## Operational Note

Rollback is possible because files are moved to quarantine instead of being permanently deleted.
If permanent deletion is required by policy, perform it only after an explicit retention period and after validating rollback is no longer needed.
