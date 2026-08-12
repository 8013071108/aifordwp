<#
.SYNOPSIS
    Cleans temp files safely and audits startup programs on Windows endpoints.

.DESCRIPTION
    This script is intended for DWP engineers and supports two operational areas:
    1) Safe temp-file cleanup with file-age filtering and dry-run mode.
    2) Startup-program inventory with an optional disable operation by program name.

    Safety model:
    - Temp cleanup uses quarantine moves (safe delete), not permanent deletion.
    - Startup disable operations are reversible:
      - Registry entries are moved to a disabled registry location.
      - Startup-folder items are moved to a DisabledStartup folder.

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
    [switch]$Disable,

    [Parameter()]
    [string]$ProgramName,

    [Parameter()]
    [string[]]$TargetPaths = @(
        "$env:TEMP",
        "$env:WINDIR\Temp"
    ),

    [Parameter()]
    [string]$StateRoot = "$env:ProgramData\DWPStartupAudit"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Section 1: Initialize run context and artifact folders.
# Creates unique paths for logs, quarantine, and startup disable backups.
$runTimestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$runId = "${runTimestamp}_$([guid]::NewGuid().ToString('N').Substring(0,8))"
$logsDir = Join-Path -Path $StateRoot -ChildPath 'Logs'
$tempQuarantineRoot = Join-Path -Path $StateRoot -ChildPath 'TempQuarantine'
$tempQuarantineRunDir = Join-Path -Path $tempQuarantineRoot -ChildPath $runId
$startupBackupRoot = Join-Path -Path $StateRoot -ChildPath 'StartupDisabled'
$logPath = Join-Path -Path $logsDir -ChildPath ("TempStartupAudit_{0}.log" -f $runTimestamp)

# Section 2: Logging helper.
# Writes timestamped entries to console and a run-specific log file.
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

# Section 3: Locked-file detection helper.
# Attempts exclusive access and returns true if file is locked.
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

# Section 4: Startup inventory collector.
# Reads startup entries from registry Run keys and Startup folders.
function Get-StartupPrograms {
    $items = New-Object System.Collections.Generic.List[object]

    $registrySources = @(
        @{ Path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'; Scope = 'CurrentUser' },
        @{ Path = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run'; Scope = 'AllUsers' },
        @{ Path = 'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Run'; Scope = 'AllUsers32' }
    )

    foreach ($source in $registrySources) {
        try {
            if (-not (Test-Path -LiteralPath $source.Path)) {
                continue
            }

            $props = Get-ItemProperty -Path $source.Path
            foreach ($p in $props.PSObject.Properties) {
                if ($p.Name -in @('PSPath','PSParentPath','PSChildName','PSDrive','PSProvider')) {
                    continue
                }

                $items.Add([PSCustomObject]@{
                    Name       = [string]$p.Name
                    Command    = [string]$p.Value
                    EntryType  = 'RegistryRun'
                    Scope      = $source.Scope
                    SourcePath = $source.Path
                    ItemPath   = $null
                }) | Out-Null
            }
        } catch {
            Write-Log -Level 'ERROR' -Message ("Failed reading startup registry source {0}: {1}" -f $source.Path, $_.Exception.Message)
        }
    }

    $startupFolders = @(
        @{ Path = [Environment]::GetFolderPath('Startup'); Scope = 'CurrentUser' },
        @{ Path = [Environment]::GetFolderPath('CommonStartup'); Scope = 'AllUsers' }
    )

    foreach ($folder in $startupFolders) {
        try {
            if (-not (Test-Path -LiteralPath $folder.Path)) {
                continue
            }

            Get-ChildItem -LiteralPath $folder.Path -File -Force -ErrorAction SilentlyContinue | ForEach-Object {
                $items.Add([PSCustomObject]@{
                    Name       = $_.BaseName
                    Command    = $_.FullName
                    EntryType  = 'StartupFolder'
                    Scope      = $folder.Scope
                    SourcePath = $folder.Path
                    ItemPath   = $_.FullName
                }) | Out-Null
            }
        } catch {
            Write-Log -Level 'ERROR' -Message ("Failed reading startup folder {0}: {1}" -f $folder.Path, $_.Exception.Message)
        }
    }

    return $items
}

# Section 5: Disable startup registry entry helper.
# Moves a Run value to a disabled Run key to avoid deletion and preserve rollback capability.
function Disable-StartupRegistryEntry {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourcePath,

        [Parameter(Mandatory = $true)]
        [string]$Name,

        [Parameter(Mandatory = $true)]
        [string]$Value,

        [Parameter(Mandatory = $true)]
        [switch]$DryRun
    )

    $disabledPath = "$SourcePath-DWPDisabled"

    if ($DryRun) {
        Write-Log -Message ("DryRun would disable registry startup: {0} :: {1}" -f $SourcePath, $Name)
        return $true
    }

    try {
        if (-not (Test-Path -LiteralPath $SourcePath)) {
            Write-Log -Level 'WARN' -Message ("Registry source no longer exists, skipping: {0}" -f $SourcePath)
            return $false
        }

        if (-not (Test-Path -LiteralPath $disabledPath)) {
            New-Item -Path $disabledPath -Force | Out-Null
        }

        $sourceProps = Get-ItemProperty -Path $SourcePath
        if ($sourceProps.PSObject.Properties.Name -notcontains $Name) {
            Write-Log -Level 'WARN' -Message ("Registry startup already disabled or missing: {0} :: {1}" -f $SourcePath, $Name)
            return $false
        }

        if ($PSCmdlet.ShouldProcess("$SourcePath::$Name", 'Disable startup registry value')) {
            Set-ItemProperty -Path $disabledPath -Name $Name -Value $Value -Type String -Force
            Remove-ItemProperty -Path $SourcePath -Name $Name -Force
            Write-Log -Message ("Disabled registry startup: {0} :: {1}" -f $SourcePath, $Name)
            return $true
        }

        return $false
    } catch {
        Write-Log -Level 'ERROR' -Message ("Failed disabling registry startup {0} :: {1} | {2}" -f $SourcePath, $Name, $_.Exception.Message)
        return $false
    }
}

# Section 6: Disable startup-folder item helper.
# Moves Startup folder files into a disabled backup location to prevent execution.
function Disable-StartupFolderEntry {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ItemPath,

        [Parameter(Mandatory = $true)]
        [string]$Scope,

        [Parameter(Mandatory = $true)]
        [switch]$DryRun
    )

    if (-not (Test-Path -LiteralPath $ItemPath)) {
        Write-Log -Level 'WARN' -Message ("Startup item already missing, skipping: {0}" -f $ItemPath)
        return $false
    }

    $scopeBackupDir = Join-Path -Path $startupBackupRoot -ChildPath $Scope
    $destination = Join-Path -Path $scopeBackupDir -ChildPath ([System.IO.Path]::GetFileName($ItemPath))

    if ($DryRun) {
        Write-Log -Message ("DryRun would disable startup folder item: {0}" -f $ItemPath)
        return $true
    }

    try {
        if (-not (Test-Path -LiteralPath $scopeBackupDir)) {
            New-Item -Path $scopeBackupDir -ItemType Directory -Force | Out-Null
        }

        if (Test-Path -LiteralPath $destination) {
            Write-Log -Level 'WARN' -Message ("Disable skip, backup target already exists: {0}" -f $destination)
            return $false
        }

        if ($PSCmdlet.ShouldProcess($ItemPath, 'Disable startup folder entry')) {
            Move-Item -LiteralPath $ItemPath -Destination $destination -Force -ErrorAction Stop
            Write-Log -Message ("Disabled startup folder item: {0}" -f $ItemPath)
            return $true
        }

        return $false
    } catch {
        Write-Log -Level 'ERROR' -Message ("Failed disabling startup folder item {0} | {1}" -f $ItemPath, $_.Exception.Message)
        return $false
    }
}

# Section 7: Validate parameters and prepare directories.
# Checks required inputs and initializes all run-time directories.
if ($Disable -and [string]::IsNullOrWhiteSpace($ProgramName)) {
    throw 'When using -Disable, provide -ProgramName.'
}

New-Item -Path $logsDir -ItemType Directory -Force | Out-Null
New-Item -Path $tempQuarantineRunDir -ItemType Directory -Force | Out-Null
New-Item -Path $startupBackupRoot -ItemType Directory -Force | Out-Null

Write-Log -Message "Script started. DryRun=$DryRun OlderThanDays=$OlderThanDays Disable=$Disable ProgramName=$ProgramName"
Write-Log -Message "Log file: $logPath"
Write-Log -Message "State root: $StateRoot"

# Section 8: Temp cleanup execution.
# Finds temp files older than cutoff, skips locked files, and quarantines cleanable files.
$tempSummary = [ordered]@{
    Scanned         = 0
    DryRunListed    = 0
    Quarantined     = 0
    SkippedLocked   = 0
    SkippedMissing  = 0
    Failed          = 0
}

$cutoff = (Get-Date).AddDays(-$OlderThanDays)
Write-Log -Message ("Temp cleanup cutoff timestamp: {0}" -f $cutoff)

$candidates = New-Object System.Collections.Generic.List[System.IO.FileInfo]
foreach ($targetPath in $TargetPaths) {
    try {
        if (-not (Test-Path -LiteralPath $targetPath)) {
            Write-Log -Level 'WARN' -Message ("Temp path not found, skipping: {0}" -f $targetPath)
            continue
        }

        Write-Log -Message ("Scanning temp path: {0}" -f $targetPath)
        Get-ChildItem -LiteralPath $targetPath -File -Recurse -Force -ErrorAction SilentlyContinue |
            Where-Object { $_.LastWriteTime -lt $cutoff } |
            ForEach-Object { [void]$candidates.Add($_) }
    } catch {
        Write-Log -Level 'ERROR' -Message ("Failed scanning temp path {0}: {1}" -f $targetPath, $_.Exception.Message)
    }
}

$tempSummary.Scanned = $candidates.Count
Write-Log -Message ("Eligible temp files: {0}" -f $tempSummary.Scanned)

foreach ($file in $candidates) {
    try {
        if (-not (Test-Path -LiteralPath $file.FullName)) {
            Write-Log -Level 'WARN' -Message ("Skip missing temp file: {0}" -f $file.FullName)
            $tempSummary.SkippedMissing++
            continue
        }

        if (Test-FileLocked -Path $file.FullName) {
            Write-Log -Level 'WARN' -Message ("Skip locked temp file: {0}" -f $file.FullName)
            $tempSummary.SkippedLocked++
            continue
        }

        if ($DryRun) {
            Write-Output $file.FullName
            Write-Log -Message ("DryRun would clean temp file: {0}" -f $file.FullName)
            $tempSummary.DryRunListed++
            continue
        }

        $destination = Join-Path -Path $tempQuarantineRunDir -ChildPath (([guid]::NewGuid().ToString('N')) + '_' + $file.Name)
        if ($PSCmdlet.ShouldProcess($file.FullName, 'Move temp file to quarantine')) {
            Move-Item -LiteralPath $file.FullName -Destination $destination -Force -ErrorAction Stop
            Write-Log -Message ("Quarantined temp file: {0}" -f $file.FullName)
            $tempSummary.Quarantined++
        }
    } catch {
        Write-Log -Level 'ERROR' -Message ("Failed temp file {0}: {1}" -f $file.FullName, $_.Exception.Message)
        $tempSummary.Failed++
    }
}

# Section 9: Startup program audit.
# Lists startup programs from known registry keys and startup folders.
Write-Log -Message 'Collecting startup program inventory.'
$startupItems = Get-StartupPrograms

Write-Host ''
Write-Host '==================== STARTUP PROGRAMS ===================='
if ($startupItems.Count -eq 0) {
    Write-Host 'No startup entries found.'
} else {
    $startupItems |
        Sort-Object -Property Name, EntryType, Scope |
        Select-Object Name, EntryType, Scope, Command |
        Format-Table -AutoSize
}
Write-Host '=========================================================='

# Section 10: Optional startup disable operation.
# Disables startup entries matching ProgramName via registry move or file move.
$disableSummary = [ordered]@{
    Requested       = [bool]$Disable
    MatchesFound    = 0
    Disabled        = 0
    SkippedOrNoOp   = 0
    Failed          = 0
}

if ($Disable) {
    Write-Log -Message ("Disable requested for startup program name: {0}" -f $ProgramName)

    $selectedEntries = @($startupItems | Where-Object { $_.Name -ieq $ProgramName })
    if ($selectedEntries.Count -eq 0) {
        $selectedEntries = @($startupItems | Where-Object { $_.Name -like "*$ProgramName*" })
    }

    $disableSummary.MatchesFound = $selectedEntries.Count

    if ($selectedEntries.Count -eq 0) {
        Write-Log -Level 'WARN' -Message ("No startup entries matched: {0}" -f $ProgramName)
    } else {
        foreach ($entry in $selectedEntries) {
            try {
                $ok = $false

                if ($entry.EntryType -eq 'RegistryRun') {
                    $ok = Disable-StartupRegistryEntry -SourcePath $entry.SourcePath -Name $entry.Name -Value $entry.Command -DryRun:$DryRun
                } elseif ($entry.EntryType -eq 'StartupFolder') {
                    $ok = Disable-StartupFolderEntry -ItemPath $entry.ItemPath -Scope $entry.Scope -DryRun:$DryRun
                } else {
                    Write-Log -Level 'WARN' -Message ("Unknown startup entry type, skipping: {0}" -f $entry.EntryType)
                }

                if ($ok) {
                    $disableSummary.Disabled++
                } else {
                    $disableSummary.SkippedOrNoOp++
                }
            } catch {
                Write-Log -Level 'ERROR' -Message ("Disable failed for {0}: {1}" -f $entry.Name, $_.Exception.Message)
                $disableSummary.Failed++
            }
        }
    }
}

# Section 11: Final summary.
# Reports consolidated temp-cleanup and startup-disable outcomes.
Write-Host ''
Write-Host '======================== RUN SUMMARY ======================='
Write-Host ("Temp Scanned             : {0}" -f $tempSummary.Scanned)
Write-Host ("Temp DryRun Listed       : {0}" -f $tempSummary.DryRunListed)
Write-Host ("Temp Quarantined         : {0}" -f $tempSummary.Quarantined)
Write-Host ("Temp Skipped Locked      : {0}" -f $tempSummary.SkippedLocked)
Write-Host ("Temp Skipped Missing     : {0}" -f $tempSummary.SkippedMissing)
Write-Host ("Temp Failed              : {0}" -f $tempSummary.Failed)
Write-Host ("Startup Disable Requested: {0}" -f $disableSummary.Requested)
Write-Host ("Startup Matches Found    : {0}" -f $disableSummary.MatchesFound)
Write-Host ("Startup Disabled         : {0}" -f $disableSummary.Disabled)
Write-Host ("Startup Skipped/No-Op    : {0}" -f $disableSummary.SkippedOrNoOp)
Write-Host ("Startup Disable Failed   : {0}" -f $disableSummary.Failed)
Write-Host ("Log File                 : {0}" -f $logPath)
Write-Host '============================================================'

Write-Log -Message 'Script finished.'
