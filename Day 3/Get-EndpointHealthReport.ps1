<#
.SYNOPSIS
    Strictly read-only endpoint health report for DWP engineers (PowerShell 5.1).

.DESCRIPTION
    Collects and prints endpoint health signals without making any changes to system state.
    This script only reads local system information, event logs, services, registry values,
    and optionally performs a network download test to estimate internet speed.
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Helper: Writes a consistent section header.
function Write-Section {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Title
    )

    Write-Host ""
    Write-Host ("=" * 72)
    Write-Host $Title
    Write-Host ("=" * 72)
}

# Helper: Converts bytes to a readable GB string.
function Convert-ToGB {
    param(
        [Parameter(Mandatory = $true)]
        [double]$Bytes
    )

    return ('{0:N2} GB' -f ($Bytes / 1GB))
}

Write-Host "Endpoint Health Report (Read-Only)"
Write-Host "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "Computer : $env:COMPUTERNAME"
Write-Host "User     : $env:USERNAME"

# Section 0: Pre-run verification checklist.
# Flags prerequisites to confirm before running so results are reliable.
Write-Section -Title '0) Verify Before Running'
Write-Host '[VERIFY] Internet speed test uses outbound HTTPS (Cloudflare test URL); confirm policy/proxy allows this.'
Write-Host '[VERIFY] Account context can read HKLM registry keys and System event log entries.'
Write-Host '[VERIFY] quser availability on endpoint; if unavailable, logged-in user count may be limited.'
Write-Host '[VERIFY] WinDefend service may be absent/disabled by design if third-party AV is mandated.'
Write-Host '[VERIFY] Last update section uses Get-HotFix; some feature updates may not appear the same way.'

# Section 1: System uptime.
# Reads OS last boot time and calculates how long the system has been running.
Write-Section -Title '1) System Uptime'
try {
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $lastBoot = $os.LastBootUpTime
    $uptime = (Get-Date) - $lastBoot

    Write-Host ("Last Boot Time : {0}" -f $lastBoot)
    Write-Host ("Uptime         : {0} days, {1} hours, {2} minutes" -f $uptime.Days, $uptime.Hours, $uptime.Minutes)
} catch {
    Write-Host "Unable to retrieve system uptime: $($_.Exception.Message)"
}

# Section 2: Free disk space.
# Reads logical disks and reports total and free space for local fixed drives.
Write-Section -Title '2) Free Disk Space'
try {
    $drives = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType = 3" |
        Sort-Object -Property DeviceID

    if (-not $drives) {
        Write-Host 'No fixed disks found.'
    } else {
        $drives |
            Select-Object @{ Name = 'Drive'; Expression = { $_.DeviceID } },
                @{ Name = 'Size'; Expression = { Convert-ToGB -Bytes $_.Size } },
                @{ Name = 'Free'; Expression = { Convert-ToGB -Bytes $_.FreeSpace } },
                @{ Name = 'Free(%)'; Expression = {
                    if ($_.Size -gt 0) {
                        '{0:N1}%' -f (($_.FreeSpace / $_.Size) * 100)
                    } else {
                        'N/A'
                    }
                } } |
            Format-Table -AutoSize
    }
} catch {
    Write-Host "Unable to retrieve disk space details: $($_.Exception.Message)"
}

# Section 3: Pending reboot check from registry.
# Reads common registry keys that indicate whether a reboot is pending.
Write-Section -Title '3) Pending Reboot (Registry Check)'
try {
    $pendingIndicators = @(
        @{
            Name = 'Component Based Servicing RebootPending'
            Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'
            Type = 'Key'
        },
        @{
            Name = 'Windows Update RebootRequired'
            Path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
            Type = 'Key'
        },
        @{
            Name = 'PendingFileRenameOperations'
            Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager'
            Value = 'PendingFileRenameOperations'
            Type = 'Value'
        }
    )

    $results = foreach ($indicator in $pendingIndicators) {
        if ($indicator.Type -eq 'Key') {
            [PSCustomObject]@{
                Indicator = $indicator.Name
                Present   = Test-Path -Path $indicator.Path
            }
        } else {
            $valueExists = $false
            if (Test-Path -Path $indicator.Path) {
                $prop = Get-ItemProperty -Path $indicator.Path -Name $indicator.Value -ErrorAction SilentlyContinue
                $valueExists = $null -ne $prop
            }

            [PSCustomObject]@{
                Indicator = $indicator.Name
                Present   = $valueExists
            }
        }
    }

    $results | Format-Table -AutoSize

    if ($results.Present -contains $true) {
        Write-Host 'Reboot Pending : Yes'
    } else {
        Write-Host 'Reboot Pending : No'
    }
} catch {
    Write-Host "Unable to evaluate reboot-pending registry indicators: $($_.Exception.Message)"
}

# Section 4: Top 5 processes by memory (working set).
# Reads current process list and sorts by working set usage.
Write-Section -Title '4) Top 5 Processes by Memory (Working Set)'
try {
    Get-Process |
        Sort-Object -Property WS -Descending |
        Select-Object -First 5 ProcessName,
            Id,
            @{ Name = 'WorkingSetMB'; Expression = { '{0:N2}' -f ($_.WS / 1MB) } } |
        Format-Table -AutoSize
} catch {
    Write-Host "Unable to retrieve top memory processes: $($_.Exception.Message)"
}

# Section 5: Top 5 processes by CPU.
# Reads cumulative CPU seconds per process and sorts highest first.
Write-Section -Title '5) Top 5 Processes by CPU'
try {
    Get-Process |
        Where-Object { $null -ne $_.CPU } |
        Sort-Object -Property CPU -Descending |
        Select-Object -First 5 ProcessName,
            Id,
            @{ Name = 'CPUSeconds'; Expression = { '{0:N2}' -f $_.CPU } } |
        Format-Table -AutoSize
} catch {
    Write-Host "Unable to retrieve top CPU processes: $($_.Exception.Message)"
}

# Section 6: Last 5 system log errors.
# Reads recent System event log entries and returns the latest 5 errors.
Write-Section -Title '6) Last 5 System Log Errors'
try {
    $errors = Get-WinEvent -LogName System -MaxEvents 300 |
        Where-Object { $_.LevelDisplayName -eq 'Error' } |
        Select-Object -First 5 TimeCreated, Id, ProviderName, Message

    if (-not $errors) {
        Write-Host 'No recent System log errors found in sampled events.'
    } else {
        $errors | Format-List
    }
} catch {
    Write-Host "Unable to read System event log errors: $($_.Exception.Message)"
}

# Section 7: Internet speed estimate.
# Performs a timed HTTPS download to estimate current download throughput in Mbps.
# This is read-only but depends on outbound network access and may be blocked by policy/proxy.
Write-Section -Title '7) Internet Speed (Estimated Download Mbps)'
try {
    $testUrl = 'https://speed.cloudflare.com/__down?bytes=10000000'
    $webClient = New-Object System.Net.WebClient
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $data = $webClient.DownloadData($testUrl)
    $sw.Stop()

    $bytes = [double]$data.Length
    $seconds = [double]$sw.Elapsed.TotalSeconds

    if ($seconds -gt 0) {
        $mbps = (($bytes * 8) / 1MB) / $seconds
        Write-Host ("Downloaded : {0:N2} MB in {1:N2} seconds" -f ($bytes / 1MB), $seconds)
        Write-Host ("Speed      : {0:N2} Mbps" -f $mbps)
    } else {
        Write-Host 'Speed test duration too short to calculate reliably.'
    }
} catch {
    Write-Host "Unable to estimate internet speed: $($_.Exception.Message)"
}

# Section 8: Microsoft Defender service status.
# Reads service state to confirm whether Microsoft Defender is running.
Write-Section -Title '8) Microsoft Defender Service Status'
try {
    $defender = Get-Service -Name WinDefend -ErrorAction Stop
    Write-Host ("Service Name : {0}" -f $defender.Name)
    Write-Host ("Display Name : {0}" -f $defender.DisplayName)
    Write-Host ("Status       : {0}" -f $defender.Status)
    Write-Host ("Running      : {0}" -f ($defender.Status -eq 'Running'))
} catch {
    Write-Host "Unable to read Microsoft Defender service status: $($_.Exception.Message)"
}

# Section 9: Number of logged-in users.
# Uses quser output to count current user sessions (interactive and remote desktop sessions).
Write-Section -Title '9) Logged-In User Count'
try {
    $quserOutput = & quser 2>$null
    if ($LASTEXITCODE -eq 0 -and $quserOutput) {
        $sessionLines = @($quserOutput | Select-Object -Skip 1 | Where-Object { $_.Trim() -ne '' })
        $userCount = $sessionLines.Count

        Write-Host ("Logged-in sessions: {0}" -f $userCount)
        Write-Host 'Session details:'
        $sessionLines | ForEach-Object { Write-Host $_ }
    } else {
        Write-Host 'Unable to query logged-in sessions using quser on this endpoint.'
    }
} catch {
    Write-Host "Unable to determine logged-in users: $($_.Exception.Message)"
}

# Section 10: Last Windows update time.
# Reads installed hotfix history to identify the most recent update installation date.
Write-Section -Title '10) Last Windows Update Installed'
try {
    $lastHotfix = Get-HotFix |
        Where-Object { $_.InstalledOn } |
        Sort-Object -Property InstalledOn -Descending |
        Select-Object -First 1

    if ($lastHotfix) {
        Write-Host ("HotFix ID    : {0}" -f $lastHotfix.HotFixID)
        Write-Host ("Installed On : {0}" -f $lastHotfix.InstalledOn)
        Write-Host ("Description  : {0}" -f $lastHotfix.Description)
    } else {
        Write-Host 'No hotfix installation date found via Get-HotFix.'
    }
} catch {
    Write-Host "Unable to retrieve last Windows update information: $($_.Exception.Message)"
}

Write-Host ""
Write-Host 'Report complete. Script performed read-only checks only.'
