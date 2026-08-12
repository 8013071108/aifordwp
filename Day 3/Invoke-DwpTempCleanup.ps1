<#
.SYNOPSIS
    Cleans temp files safely on Windows endpoints with dry run and rollback support.

.DESCRIPTION
    This script targets temp file locations, filters by age, skips locked files,
    logs every action, and provides a summary. Instead of hard deleting files, it
    moves them into a quarantine folder so they can be restored later via rollback.

.NOTES
    Designed for Windows PowerShell 5.1.
#>

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [Parameter()]
    [switch]$DryRun,

    [Parameter()]
    [ValidateRange(0, 36500)]
    [int]$OlderThanDays = 0,

    [Parameter()]
    [switch]$Rollback,

    [Parameter()]
    [string]$RollbackManifestPath,

    [Parameter()]
    [string[]]$TargetPaths = @(
        "$env:TEMP",
        "$env:WINDIR\Temp"
    ),

    [Parameter()]
    [string]$StateRoot = "$env:ProgramData\DWPTempCleanup"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Section 1: Initialize run context and folders.
# Creates a unique run ID and folder structure for logs, quarantine, and manifests.
$runTimestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$runId = "${runTimestamp}_$([guid]::NewGuid().ToString('N').Substring(0,8))"
$logsDir = Join-Path -Path $StateRoot -ChildPath 'Logs'
$manifestsDir = Join-Path -Path $StateRoot -ChildPath 'Manifests'
$quarantineRoot = Join-Path -Path $StateRoot -ChildPath 'Quarantine'
$quarantineRunDir = Join-Path -Path $quarantineRoot -ChildPath $runId
$logPath = Join-Path -Path $logsDir -ChildPath ("TempCleanup_{0}.log" -f $runTimestamp)

# Section 2: Logging helper.
# Writes every action to both console and a timestamped log file.
function Write-Log {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,

        [Parameter()]
        [ValidateSet('INFO','WARN','ERROR')]
        [string]$Level = 'INFO'
    )

    $line = "{0} [{1}] {2}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Level, $Message
    Add-Content -Path $script:logPath -Value $line
    Write-Host $line
}

# Section 3: Helper to detect locked files.
# Tries exclusive access; if that fails, the file is treated as locked and skipped.
function Test-FileLocked {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    $stream = $null
    try {
        $stream = [System.IO.File]::Open($Path, 'Open', 'ReadWrite', 'None')
        return $false
    } catch {
        return $true
    } finally {
        if ($null -ne $stream) {
            $stream.Dispose()
        }
    }
}

# Section 4: Ensure state directories exist.
# Prepares folders used by logging and quarantine tracking.
New-Item -Path $logsDir -ItemType Directory -Force | Out-Null
New-Item -Path $manifestsDir -ItemType Directory -Force | Out-Null
if (-not $Rollback) {
    New-Item -Path $quarantineRunDir -ItemType Directory -Force | Out-Null
}

Write-Log -Message "Script started. DryRun=$DryRun OlderThanDays=$OlderThanDays Rollback=$Rollback"
Write-Log -Message "Log file: $logPath"
Write-Log -Message "State root: $StateRoot"
Write-Log -Message "Ensured logs directory: $logsDir"
Write-Log -Message "Ensured manifests directory: $manifestsDir"
if (-not $Rollback) {
    Write-Log -Message "Ensured quarantine directory for run: $quarantineRunDir"
}
Write-Log -Message 'Cleanup mode uses quarantine move (safe delete) to support rollback.'

# Section 5: Rollback mode.
# Restores files from a prior manifest back to original paths, skipping conflicts safely.
if ($Rollback) {
    try {
        $manifestPath = $RollbackManifestPath
        if ([string]::IsNullOrWhiteSpace($manifestPath)) {
            $latestManifest = Get-ChildItem -Path $manifestsDir -Filter 'Manifest_*.csv' -File |
                Sort-Object -Property LastWriteTime -Descending |
                Select-Object -First 1
            if ($null -eq $latestManifest) {
                Write-Log -Level 'WARN' -Message 'No manifest found for rollback. Exiting.'
                return
            }
            $manifestPath = $latestManifest.FullName
        }

        if (-not (Test-Path -LiteralPath $manifestPath)) {
            Write-Log -Level 'ERROR' -Message "Rollback manifest not found: $manifestPath"
            return
        }

        Write-Log -Message "Using rollback manifest: $manifestPath"
        $entries = Import-Csv -Path $manifestPath

        $restoreTotal = 0
        $restoreOk = 0
        $restoreSkipped = 0
        $restoreFailed = 0

        foreach ($entry in $entries) {
            $restoreTotal++
            $originalPath = $entry.OriginalPath
            $stagedPath = $entry.QuarantinePath

            try {
                if (-not (Test-Path -LiteralPath $stagedPath)) {
                    Write-Log -Level 'WARN' -Message "Rollback skip (already restored or missing staged file): $stagedPath"
                    $restoreSkipped++
                    continue
                }

                if (Test-Path -LiteralPath $originalPath) {
                    Write-Log -Level 'WARN' -Message "Rollback skip (target path already exists): $originalPath"
                    $restoreSkipped++
                    continue
                }

                $parent = Split-Path -Path $originalPath -Parent
                if (-not (Test-Path -LiteralPath $parent)) {
                    New-Item -Path $parent -ItemType Directory -Force | Out-Null
                }

                if ($PSCmdlet.ShouldProcess($originalPath, 'Restore file from quarantine')) {
                    Move-Item -LiteralPath $stagedPath -Destination $originalPath -Force -ErrorAction Stop
                    Write-Log -Message "Rollback restored: $originalPath"
                    $restoreOk++
                }
            } catch {
                Write-Log -Level 'ERROR' -Message ("Rollback failed: {0} | {1}" -f $originalPath, $_.Exception.Message)
                $restoreFailed++
                continue
            }
        }

        Write-Log -Message ('Rollback summary: Total={0} Restored={1} Skipped={2} Failed={3}' -f $restoreTotal, $restoreOk, $restoreSkipped, $restoreFailed)
        return
    } catch {
        Write-Log -Level 'ERROR' -Message "Rollback fatal error: $($_.Exception.Message)"
        return
    }
}

# Section 6: Build candidate file list.
# Enumerates files in target temp paths and filters by last write age threshold.
$cutoff = (Get-Date).AddDays(-$OlderThanDays)
$candidates = New-Object System.Collections.Generic.List[System.IO.FileInfo]

Write-Log -Message ("Age cutoff timestamp: {0}" -f $cutoff)

foreach ($targetPath in $TargetPaths) {
    try {
        if (-not (Test-Path -LiteralPath $targetPath)) {
            Write-Log -Level 'WARN' -Message "Target path not found, skipping: $targetPath"
            continue
        }

        Write-Log -Message "Scanning target path: $targetPath"
        Get-ChildItem -LiteralPath $targetPath -File -Recurse -Force -ErrorAction SilentlyContinue |
            Where-Object { $_.LastWriteTime -lt $cutoff } |
            ForEach-Object { [void]$candidates.Add($_) }
    } catch {
        Write-Log -Level 'ERROR' -Message ("Failed scanning path: {0} | {1}" -f $targetPath, $_.Exception.Message)
        continue
    }
}

# Section 7: Process each candidate file.
# Performs per-file try/catch, skips locked files, logs all actions, and supports dry run.
$summary = [ordered]@{
    Scanned          = $candidates.Count
    DryRunListed     = 0
    MovedToQuarantine= 0
    SkippedLocked    = 0
    SkippedMissing   = 0
    Failed           = 0
}

$manifestRows = New-Object System.Collections.Generic.List[object]

Write-Log -Message ("Eligible files older than cutoff ({0}): {1}" -f $cutoff, $candidates.Count)

foreach ($file in $candidates) {
    try {
        if (-not (Test-Path -LiteralPath $file.FullName)) {
            Write-Log -Level 'WARN' -Message "Skip missing: $($file.FullName)"
            $summary.SkippedMissing++
            continue
        }

        if (Test-FileLocked -Path $file.FullName) {
            Write-Log -Level 'WARN' -Message "Skip locked: $($file.FullName)"
            $summary.SkippedLocked++
            continue
        }

        if ($DryRun) {
            Write-Output $file.FullName
            Write-Log -Message "DryRun would delete (safe delete via quarantine): $($file.FullName)"
            $summary.DryRunListed++
            continue
        }

        $stagedName = "{0}_{1}" -f ([guid]::NewGuid().ToString('N')), $file.Name
        $quarantinePath = Join-Path -Path $quarantineRunDir -ChildPath $stagedName

        if ($PSCmdlet.ShouldProcess($file.FullName, 'Move file to quarantine')) {
            Move-Item -LiteralPath $file.FullName -Destination $quarantinePath -Force -ErrorAction Stop
            Write-Log -Message "Cleaned (moved to quarantine): $($file.FullName)"
            $summary.MovedToQuarantine++

            $manifestRows.Add([PSCustomObject]@{
                OriginalPath   = $file.FullName
                QuarantinePath = $quarantinePath
                LengthBytes    = $file.Length
                LastWriteTime  = $file.LastWriteTime
                RunId          = $runId
                Timestamp      = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
            }) | Out-Null
        }
    } catch {
        Write-Log -Level 'ERROR' -Message ("Failed file: {0} | {1}" -f $file.FullName, $_.Exception.Message)
        $summary.Failed++
        continue
    }
}

# Section 8: Persist manifest for rollback.
# Stores mappings of original and quarantine paths to support a future restore operation.
if (-not $DryRun -and $manifestRows.Count -gt 0) {
    try {
        $manifestPath = Join-Path -Path $manifestsDir -ChildPath ("Manifest_{0}.csv" -f $runId)
        $manifestRows | Export-Csv -Path $manifestPath -NoTypeInformation -Encoding UTF8
        Write-Log -Message "Rollback manifest saved: $manifestPath"
    } catch {
        Write-Log -Level 'ERROR' -Message "Failed to save rollback manifest: $($_.Exception.Message)"
    }
}

# Section 9: Final summary report.
# Prints end-of-run totals so engineers can quickly assess script results.
Write-Host ''
Write-Host '==================== TEMP CLEANUP SUMMARY ===================='
Write-Host ("Scanned files           : {0}" -f $summary.Scanned)
Write-Host ("Dry run listed          : {0}" -f $summary.DryRunListed)
Write-Host ("Moved to quarantine     : {0}" -f $summary.MovedToQuarantine)
Write-Host ("Skipped locked          : {0}" -f $summary.SkippedLocked)
Write-Host ("Skipped missing         : {0}" -f $summary.SkippedMissing)
Write-Host ("Failed                  : {0}" -f $summary.Failed)
Write-Host ("Log file                : {0}" -f $logPath)
Write-Host '=============================================================='

Write-Log -Message 'Script finished.'
