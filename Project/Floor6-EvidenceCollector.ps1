<#
.SYNOPSIS
    Floor 6 Incident Evidence Collector

.DESCRIPTION
    Collects read-only evidence from a Floor 6 Windows 11 device to investigate:
    - Slow login or login failure
    - Intune app deployment impact
    - Recent document management app installation
    - Desktop shortcut disappearance
    - User profile / OneDrive Known Folder Move signals

    This script is evidence-only and does not remediate, delete, restart, stop services,
    change registry values, or modify system configuration.

.AUTHOR
    DWP AI Training - Floor 6 Incident Project

.VERSION
    1.0

.HOW TO RUN
    Dry run:
        .\Floor6-EvidenceCollector.ps1 -DryRun

    Actual evidence collection:
        .\Floor6-EvidenceCollector.ps1

    With custom app name:
        .\Floor6-EvidenceCollector.ps1 -AppNamePattern "FinBridge|Document|Legal"

.NOTES
    Recommended to run as Administrator for complete event log and Intune log access.
#>

param(
    [switch]$DryRun,

    [string]$OutputPath = "$env:USERPROFILE\Desktop\Floor6_Evidence",

    [string]$AppNamePattern = "FinBridge|Document|Legal|DMS|Matter",

    [int]$EventHoursBack = 72
)

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-Err {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

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

Write-Info "Starting Floor 6 evidence collection."
Write-Info "Dry Run Mode: $DryRun"
Write-Info "App Name Pattern: $AppNamePattern"
Write-Info "Looking back $EventHoursBack hours."

$StartTime = (Get-Date).AddHours(-$EventHoursBack)

if ($DryRun) {
    Write-Info "DRY RUN: Would create output directory: $OutputPath"
}
else {
    try {
        New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null
        Write-Info "Output directory ready: $OutputPath"
    }
    catch {
        Write-Err "Unable to create output directory. Error: $($_.Exception.Message)"
        exit 1
    }
}

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

Write-Info "Collecting recently installed applications."

try {
    $UninstallPaths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    $InstalledApps = foreach ($Path in $UninstallPaths) {
        Get-ItemProperty $Path -ErrorAction SilentlyContinue |
            Where-Object {
                $_.DisplayName -and (
                    $_.DisplayName -match $AppNamePattern -or
                    $_.Publisher -match $AppNamePattern
                )
            } |
            Select-Object DisplayName, DisplayVersion, Publisher, InstallDate, InstallLocation, PSChildName
    }

    Export-Data -Data $InstalledApps -FilePath "$OutputPath\02_Matching_Installed_Apps.csv"
}
catch {
    Write-Err "Failed to collect installed apps. Error: $($_.Exception.Message)"
}

Write-Info "Collecting Intune Management Extension logs."

$IMEPath = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs"

if ($DryRun) {
    Write-Info "DRY RUN: Would check Intune logs at $IMEPath"
}
else {
    try {
        if (Test-Path $IMEPath) {
            Copy-Item "$IMEPath\*.log" -Destination $OutputPath -Force -ErrorAction SilentlyContinue
            Write-Info "Copied Intune Management Extension logs."
        }
        else {
            Write-Warn "Intune Management Extension log path not found: $IMEPath"
        }
    }
    catch {
        Write-Err "Failed to copy Intune logs. Error: $($_.Exception.Message)"
    }
}

Write-Info "Searching Intune logs for app/deployment indicators."

try {
    if (Test-Path $IMEPath) {
        $IMEFindings = Select-String -Path "$IMEPath\*.log" `
            -Pattern $AppNamePattern, "error", "failed", "retry", "detection", "exit code", "install", "uninstall" `
            -ErrorAction SilentlyContinue |
            Select-Object Path, LineNumber, Line

        Export-Data -Data $IMEFindings -FilePath "$OutputPath\03_Intune_Log_Findings.csv"
    }
    else {
        Write-Warn "IME path not available for log search."
    }
}
catch {
    Write-Err "Failed to search Intune logs. Error: $($_.Exception.Message)"
}

Write-Info "Collecting logon and profile related event logs."

$EventQueries = @(
    @{
        Name = "System_Logon_Profile_GroupPolicy"
        LogName = "System"
        Ids = @(7001, 7002, 7009, 7011, 7016, 5719, 1058, 1030, 1129, 1500, 1501, 1502, 1505, 1511, 1515)
    },
    @{
        Name = "Application_ApplicationErrors"
        LogName = "Application"
        Ids = @(1000, 1001, 1026)
    },
    @{
        Name = "Security_LogonEvents"
        LogName = "Security"
        Ids = @(4624, 4625, 4634, 4647, 4771, 4776, 4740)
    }
)

foreach ($Query in $EventQueries) {
    try {
        $Events = Get-WinEvent -FilterHashtable @{
            LogName   = $Query.LogName
            Id        = $Query.Ids
            StartTime = $StartTime
        } -ErrorAction SilentlyContinue |
            Select-Object TimeCreated, Id, ProviderName, LevelDisplayName, Message

        Export-Data -Data $Events -FilePath "$OutputPath\04_$($Query.Name).csv"
    }
    catch {
        Write-Warn "Could not collect $($Query.Name). Error: $($_.Exception.Message)"
    }
}

Write-Info "Collecting User Profile Service operational events."

try {
    $ProfileLogName = "Microsoft-Windows-User Profile Service/Operational"

    $ProfileEvents = Get-WinEvent -FilterHashtable @{
        LogName   = $ProfileLogName
        StartTime = $StartTime
    } -ErrorAction SilentlyContinue |
        Select-Object TimeCreated, Id, ProviderName, LevelDisplayName, Message

    Export-Data -Data $ProfileEvents -FilePath "$OutputPath\05_User_Profile_Service_Events.csv"
}
catch {
    Write-Warn "User Profile Service operational log unavailable or inaccessible. Error: $($_.Exception.Message)"
}

Write-Info "Collecting startup programs."

try {
    $StartupItems = Get-CimInstance Win32_StartupCommand -ErrorAction SilentlyContinue |
        Select-Object Name, Command, Location, User

    Export-Data -Data $StartupItems -FilePath "$OutputPath\06_Startup_Items.csv"
}
catch {
    Write-Err "Failed to collect startup items. Error: $($_.Exception.Message)"
}

Write-Info "Collecting matching scheduled tasks."

try {
    $ScheduledTasks = Get-ScheduledTask -ErrorAction SilentlyContinue |
        Where-Object {
            $_.TaskName -match $AppNamePattern -or
            $_.TaskPath -match $AppNamePattern
        } |
        Select-Object TaskName, TaskPath, State

    Export-Data -Data $ScheduledTasks -FilePath "$OutputPath\07_Matching_Scheduled_Tasks.csv"
}
catch {
    Write-Warn "Failed to collect scheduled tasks. Error: $($_.Exception.Message)"
}

Write-Info "Collecting desktop shortcut inventory."

try {
    $DesktopPaths = @()

    if ($env:USERPROFILE) {
        $DesktopPaths += "$env:USERPROFILE\Desktop"
        $DesktopPaths += "$env:USERPROFILE\OneDrive - FinBridge\Desktop"
        $DesktopPaths += "$env:USERPROFILE\OneDrive\Desktop"
    }

    $DesktopPaths += "C:\Users\Public\Desktop"

    $ShortcutInventory = foreach ($Path in $DesktopPaths | Select-Object -Unique) {
        if (Test-Path $Path) {
            Get-ChildItem -Path $Path -Filter "*.lnk" -ErrorAction SilentlyContinue |
                Select-Object @{
                    Name = "DesktopPath"
                    Expression = { $Path }
                }, Name, FullName, LastWriteTime, CreationTime
        }
    }

    Export-Data -Data $ShortcutInventory -FilePath "$OutputPath\08_Desktop_Shortcut_Inventory.csv"
}
catch {
    Write-Err "Failed to collect desktop shortcut inventory. Error: $($_.Exception.Message)"
}

Write-Info "Collecting OneDrive and Known Folder Move indicators."

try {
    $OneDriveRegistryPaths = @(
        "HKCU:\Software\Microsoft\OneDrive",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders"
    )

    $OneDriveData = foreach ($Path in $OneDriveRegistryPaths) {
        if (Test-Path $Path) {
            Get-ItemProperty -Path $Path -ErrorAction SilentlyContinue |
                Select-Object * |
                ForEach-Object {
                    [PSCustomObject]@{
                        RegistryPath = $Path
                        Data         = ($_ | Out-String)
                    }
                }
        }
    }

    Export-Data -Data $OneDriveData -FilePath "$OutputPath\09_OneDrive_KFM_Registry.csv"
}
catch {
    Write-Warn "Failed to collect OneDrive/KFM indicators. Error: $($_.Exception.Message)"
}

Write-Info "Collecting recent Desktop file state."

try {
    $RecentDesktopFiles = foreach ($Path in $DesktopPaths | Select-Object -Unique) {
        if (Test-Path $Path) {
            Get-ChildItem -Path $Path -Force -ErrorAction SilentlyContinue |
                Where-Object { $_.LastWriteTime -ge $StartTime -or $_.CreationTime -ge $StartTime } |
                Select-Object @{
                    Name = "DesktopPath"
                    Expression = { $Path }
                }, Name, FullName, Extension, CreationTime, LastWriteTime, Length
        }
    }

    Export-Data -Data $RecentDesktopFiles -FilePath "$OutputPath\10_Recent_Desktop_File_State.csv"
}
catch {
    Write-Warn "Failed to collect recent Desktop file state. Error: $($_.Exception.Message)"
}

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

Write-Info "Creating evidence collection summary."

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

Evidence collected:
1. Device baseline
2. Matching installed applications
3. Intune Management Extension logs
4. Intune log keyword findings
5. System/Application/Security events
6. User Profile Service events
7. Startup items
8. Matching scheduled tasks
9. Desktop shortcut inventory
10. OneDrive Known Folder Move indicators
11. Recent Desktop file state
12. Current performance snapshot

Important:
This script is read-only for investigation purposes.
It does not remediate, delete, restart, disable, or change configuration.
Any root cause must be confirmed using the collected evidence before RCA is written.
"@

Export-Data -Data $SummaryText -FilePath "$OutputPath\00_Evidence_Collection_Summary.txt" -Type "Text"

if ($DryRun) {
    Write-Info "DRY RUN: Would compress evidence folder to ZIP."
}
else {
    try {
        $ZipPath = "$OutputPath.zip"

        if (Test-Path $ZipPath) {
            Remove-Item $ZipPath -Force
        }

        Compress-Archive -Path "$OutputPath\*" -DestinationPath $ZipPath -Force
        Write-Info "Evidence package created: $ZipPath"
    }
    catch {
        Write-Warn "Failed to create ZIP package. Error: $($_.Exception.Message)"
    }
}

Write-Info "Floor 6 evidence collection completed."
