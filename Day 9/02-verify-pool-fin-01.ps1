[CmdletBinding()]
param(
    [string]$SubscriptionId = 'b0c21333-37f1-4a78-b696-444e372e201e',
    [string]$ResourceGroup = 'dwp-lab-rg',
    [string]$HostPoolName = 'POOL-FIN-01',
    [string]$DesktopAppGroupName = 'Desktop-POOL-FIN-01',
    [string]$WorkspaceName = 'FinBridge-Workspace',
    [string]$UserUpn = 'p54@zippyops.in'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Get-AzJson {
    param([string[]]$Arguments)
    $output = & az @Arguments -o json
    if ($LASTEXITCODE -ne 0) {
        throw "Azure CLI command failed: az $($Arguments -join ' ')"
    }
    if ([string]::IsNullOrWhiteSpace($output)) {
        return $null
    }
    return $output | ConvertFrom-Json
}

& az account set --subscription $SubscriptionId | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "Failed to switch to subscription $SubscriptionId"
}

Write-Host 'Workspace'
Get-AzJson -Arguments @('desktopvirtualization', 'workspace', 'show', '--resource-group', $ResourceGroup, '--name', $WorkspaceName) |
    Select-Object name, location, friendlyName, description |
    Format-List

Write-Host 'Host Pool'
Get-AzJson -Arguments @('desktopvirtualization', 'hostpool', 'show', '--resource-group', $ResourceGroup, '--name', $HostPoolName) |
    Select-Object name, loadBalancerType, maximumSessionsLimit, preferredAppGroupType |
    Format-List

Write-Host 'Desktop App Group'
Get-AzJson -Arguments @('desktopvirtualization', 'applicationgroup', 'show', '--resource-group', $ResourceGroup, '--name', $DesktopAppGroupName) |
    Select-Object name, type, friendlyName, description |
    Format-List

Write-Host 'User role assignment'
& az role assignment list --assignee $UserUpn --all -o table
