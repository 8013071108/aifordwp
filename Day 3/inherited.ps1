<#
.SYNOPSIS
	Displays quick endpoint health indicators for troubleshooting.

.DESCRIPTION
	Collects and prints machine identity, RAM size, free C: drive space,
	top memory-consuming processes, recent system error events, and stale
	local user profile count.

.AUTHOR
	DWP Engineer

.HOW TO RUN
	powershell -NoProfile -ExecutionPolicy Bypass -File ".\inherited.ps1"

.NOTES
	Read-only diagnostics script. No system settings are modified.
#>

# Read basic computer system details (for example, device name and total RAM).
$computerSystemInfo = Get-CimInstance Win32_ComputerSystem

# Read free space in bytes from the C: drive.
$freeBytesOnCDrive = Get-PSDrive C | Select-Object -ExpandProperty Free

# Read all running processes, sort by memory usage, and keep the top five.
$topMemoryProcesses = Get-Process | Sort-Object WS -Descending | Select-Object -First 5

# Read the most recent 10 System log events, then keep only error-level events.
$recentSystemErrorEvents = Get-WinEvent -LogName System -MaxEvents 10 | Where-Object { $_.Level -eq 2 }

# Read all user profiles and keep only non-special profiles unused for more than 90 days.
$staleUserProfiles = Get-CimInstance Win32_UserProfile | Where-Object {
	# Filter condition: profile is not special and was last used before 90 days ago.
	-not $_.Special -and $_.LastUseTime -lt (Get-Date).AddDays(-90)
# End profile filter block.
}

# Print the computer name and total physical memory value.
Write-Host $computerSystemInfo.Name $computerSystemInfo.TotalPhysicalMemory

# Print free C: drive space in gigabytes, rounded to 2 decimal places.
Write-Host ([math]::Round($freeBytesOnCDrive / 1GB, 2)) 'GB free'

# Print each top process with its name and working set memory.
$topMemoryProcesses | ForEach-Object { Write-Host $_.Name $_.WS }

# Print each recent system error event with timestamp and message.
$recentSystemErrorEvents | ForEach-Object { Write-Host $_.TimeCreated $_.Message }

# Check whether stale user profiles were found.
if ($staleUserProfiles.Count -gt 0) {
	# Print the count only when one or more stale profiles exist.
	Write-Host 'Stale profiles:' $staleUserProfiles.Count
# End stale profile count block.
}
