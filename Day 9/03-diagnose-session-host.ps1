[CmdletBinding()]
param(
    [string]$SessionHostName = 'shfin-01-01',
    [string]$ResourceGroup = 'dwp-lab-rg'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "Session host diagnostics for $SessionHostName"
Write-Host 'Check 1 - Azure VM power state'
& az vm get-instance-view --resource-group $ResourceGroup --name $SessionHostName --query "instanceView.statuses[?starts_with(code, 'PowerState/')].displayStatus" -o tsv

Write-Host 'Check 2 - AVD session host registration'
& az desktopvirtualization sessionhost list --resource-group $ResourceGroup --host-pool-name 'POOL-FIN-01' -o table

Write-Host 'Check 3 - VM extension status'
& az vm extension list --resource-group $ResourceGroup --vm-name $SessionHostName -o table

Write-Host 'Check 4 - Relevant log files on the VM'
Write-Host 'Review AVD agent / bootloader logs on the session host itself, including service failures and event viewer entries around logon or registration time.'
