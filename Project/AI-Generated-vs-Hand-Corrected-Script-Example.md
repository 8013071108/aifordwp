# AI-Generated vs Hand-Corrected Script Example

## Purpose
This document shows one script in both forms:
1. The AI-generated version
2. The hand-corrected version

Example used: `Floor6-EvidenceCollector.ps1`

---

## 1. AI-Generated Version (Original)

```powershell
# -------------------------------
# 1. System and device baseline
# -------------------------------
Write-Info "Collecting system baseline."

try {
    $ComputerInfo = Get-CimInstance Win32_ComputerSystem | Select-Object `
        Name,
        Manufacturer,
        Model,
        Domain,
        UserName,
        TotalPhysicalMemory

    $OSInfo = Get-CimInstance Win32_OperatingSystem | Select-Object `
        Caption,
        Version,
        BuildNumber,
        LastBootUpTime,
        InstallDate

    $DeviceBaseline = [PSCustomObject]@{
        ComputerName        = $ComputerInfo.Name
        Manufacturer        = $ComputerInfo.Manufacturer
        Model               = $ComputerInfo.Model
        Domain              = $ComputerInfo.Domain
        LoggedOnUser        = $ComputerInfo.UserName
        TotalMemoryGB       = :Round($ComputerInfo.TotalPhysicalMemory / 1GB, 2)
        OS                  = $OSInfo.Caption
        OSVersion           = $OSInfo.Version
        OSBuild             = $OSInfo.BuildNumber
        LastBootTime        = $OSInfo.LastBootUpTime
        OSInstallDate       = $OSInfo.InstallDate
        CollectionTime      = Get-Date
    }

    Export-Data -Data $DeviceBaseline -FilePath "$OutputPath\01_Device_Baseline.csv"
}
catch {
    Write-Err "Failed to collect device baseline. Error: $($_.Exception.Message)"
}

# -------------------------------
# Helper: Export safely
# -------------------------------
function Export-Data {
    param(
        [Parameter(Mandatory=$true)] $Data,
        [Parameter(Mandatory=$true)] [string]$FilePath,
        [string]$Type = "Csv"
    )

    try {
        if ($DryRun) {
            Write-Info "DRY RUN: Would export data to $FilePath"
            return
        }

        if ($null -eq $Data) {
            Write-Warn "No data to export for $FilePath"
            return
        }

        if ($Type -eq "Csv") {
            $Data | Export-Csv -Path $FilePath -NoTypeInformation -Encoding UTF8
        }
        elseif ($Type -eq "Text") {
            $Data | Out-File -FilePath $FilePath -Encoding UTF8
        }
        elseif ($Type -eq "Json") {
            $Data | ConvertTo-Json -Depth 5 | Out-File -FilePath $FilePath -Encoding UTF8
        }

        Write-Info "Exported: $FilePath"
    }
    catch {
        Write-Err "Failed to export $FilePath. Error: $($_.Exception.Message)"
    }
}

# -------------------------------
# 11. Performance snapshot
# -------------------------------
Write-Info "Collecting current performance snapshot."

try {
    $Disk = Get-PSDrive C | Select-Object Name, Used, Free

    $TopMemory = Get-Process |
        Sort-Object WorkingSet -Descending |
        Select-Object -First 10 ProcessName, Id, CPU, WorkingSet, StartTime -ErrorAction SilentlyContinue

    $TopCPU = Get-Process |
        Sort-Object CPU -Descending |
        Select-Object -First 10 ProcessName, Id, CPU, WorkingSet, StartTime -ErrorAction SilentlyContinue

    $PerfSummary = [PSCustomObject]@{
        CollectionTime = Get-Date
        CDriveFreeGB   = :Round($Disk.Free / 1GB, 2)
        CDriveUsedGB   = :Round($Disk.Used / 1GB, 2)
    }

    Export-Data -Data $PerfSummary -FilePath "$OutputPath\11_Performance_Summary.csv"
    Export-Data -Data $TopMemory -FilePath "$OutputPath\12_Top_Processes_By_Memory.csv"
    Export-Data -Data $TopCPU -FilePath "$OutputPath\13_Top_Processes_By_CPU.csv"
}
catch {
    Write-Warn "Failed to collect performance snapshot. Error: $($_.Exception.Message)"
}

# -------------------------------
# 12. Create evidence summary
# -------------------------------
$SummaryText = @"
Floor 6 Incident Evidence Collection Summary

Collection Time: $(Get-Date)
Computer Name: $env:COMPUTERNAME
User Context: $env:USERNAME
Dry Run Mode: $DryRun
Hours Reviewed: $EventHoursBack
App Name Pattern: $AppNamePattern

Top-ranked hypothesis being tested:
The Friday Intune-deployed document management app or its related deployment/configuration scripts may have contributed to slow login and/or desktop shortcut changes.
"@
```

### Problems in the AI-Generated Version
- `:Round(...)` is invalid PowerShell syntax and causes script failure.
- `Export-Data` required `Data` even when a command returned nothing, which caused null-binding errors.
- The evidence summary text prematurely implied a preferred root cause before evidence had been reviewed.

---

## 2. Hand-Corrected Version (Implemented)

```powershell
# -------------------------------
# 1. System and device baseline
# -------------------------------
Write-Info "Collecting system baseline."

try {
    $ComputerInfo = Get-CimInstance Win32_ComputerSystem | Select-Object `
        Name,
        Manufacturer,
        Model,
        Domain,
        UserName,
        TotalPhysicalMemory

    $OSInfo = Get-CimInstance Win32_OperatingSystem | Select-Object `
        Caption,
        Version,
        BuildNumber,
        LastBootUpTime,
        InstallDate

    $DeviceBaseline = [PSCustomObject]@{
        ComputerName   = $ComputerInfo.Name
        Manufacturer   = $ComputerInfo.Manufacturer
        Model          = $ComputerInfo.Model
        Domain         = $ComputerInfo.Domain
        LoggedOnUser   = $ComputerInfo.UserName
        TotalMemoryGB  = [math]::Round($ComputerInfo.TotalPhysicalMemory / 1GB, 2)
        OS             = $OSInfo.Caption
        OSVersion      = $OSInfo.Version
        OSBuild        = $OSInfo.BuildNumber
        LastBootTime   = $OSInfo.LastBootUpTime
        OSInstallDate  = $OSInfo.InstallDate
        CollectionTime = Get-Date
    }

    Export-Data -Data $DeviceBaseline -FilePath "$OutputPath\01_Device_Baseline.csv"
}
catch {
    Write-Err "Failed to collect device baseline. Error: $($_.Exception.Message)"
}

# -------------------------------
# Helper: Export safely
# -------------------------------
function Export-Data {
    param(
        [AllowNull()] $Data,
        [Parameter(Mandatory = $true)] [string]$FilePath,
        [string]$Type = "Csv"
    )

    try {
        if ($DryRun) {
            Write-Info "DRY RUN: Would export data to $FilePath"
            return
        }

        if ($null -eq $Data) {
            Write-Warn "No data to export for $FilePath"
            return
        }

        if ($Type -eq "Csv") {
            $Data | Export-Csv -Path $FilePath -NoTypeInformation -Encoding UTF8
        }
        elseif ($Type -eq "Text") {
            $Data | Out-File -FilePath $FilePath -Encoding UTF8
        }
        elseif ($Type -eq "Json") {
            $Data | ConvertTo-Json -Depth 5 | Out-File -FilePath $FilePath -Encoding UTF8
        }

        Write-Info "Exported: $FilePath"
    }
    catch {
        Write-Err "Failed to export $FilePath. Error: $($_.Exception.Message)"
    }
}

# -------------------------------
# 11. Performance snapshot
# -------------------------------
Write-Info "Collecting current performance snapshot."

try {
    $Disk = Get-PSDrive C | Select-Object Name, Used, Free

    $TopMemory = Get-Process |
        Sort-Object WorkingSet -Descending |
        Select-Object -First 10 ProcessName, Id, CPU, WorkingSet, StartTime -ErrorAction SilentlyContinue

    $TopCPU = Get-Process |
        Sort-Object CPU -Descending |
        Select-Object -First 10 ProcessName, Id, CPU, WorkingSet, StartTime -ErrorAction SilentlyContinue

    $PerfSummary = [PSCustomObject]@{
        CollectionTime = Get-Date
        CDriveFreeGB   = [math]::Round($Disk.Free / 1GB, 2)
        CDriveUsedGB   = [math]::Round($Disk.Used / 1GB, 2)
    }

    Export-Data -Data $PerfSummary -FilePath "$OutputPath\11_Performance_Summary.csv"
    Export-Data -Data $TopMemory -FilePath "$OutputPath\12_Top_Processes_By_Memory.csv"
    Export-Data -Data $TopCPU -FilePath "$OutputPath\13_Top_Processes_By_CPU.csv"
}
catch {
    Write-Warn "Failed to collect performance snapshot. Error: $($_.Exception.Message)"
}

# -------------------------------
# 12. Create evidence summary
# -------------------------------
$SummaryText = @"
Floor 6 Incident Evidence Collection Summary

Collection Time: $(Get-Date)
Computer Name: $env:COMPUTERNAME
User Context: $env:USERNAME
Dry Run Mode: $DryRun
Hours Reviewed: $EventHoursBack
App Name Pattern: $AppNamePattern

Evidence collection focus:
- Slow login or login failure indicators
- Recent application deployment indicators
- Desktop shortcut state
- OneDrive / Known Folder Move indicators
- Profile and startup behavior
"@
```

### What Was Corrected by Hand
- Replaced invalid `:Round(...)` with valid `[math]::Round(...)`.
- Changed the export helper to tolerate empty results safely.
- Removed premature bias from the evidence summary so the script remains evidence-led.
- Re-tested the script in both dry-run and normal execution mode.

---

## 3. Outcome
The corrected script was saved as:
- `Project/Floor6-EvidenceCollector.ps1`

The corrected version:
- Parses correctly
- Runs in dry-run mode without binding errors
- Runs in live mode and produces an evidence package successfully
