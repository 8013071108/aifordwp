[CmdletBinding()]
param(
    [string]$SubscriptionId = 'b0c21333-37f1-4a78-b696-444e372e201e',
    [string]$ResourceGroup = 'dwp-lab-rg',
    [string]$Location = 'centralus',
    [string]$HostPoolName = 'POOL-FIN-01',
    [string]$WorkspaceName = 'FinBridge-Workspace',
    [string]$DesktopAppGroupName = 'Desktop-POOL-FIN-01',
    [string]$VmName = 'shfin-01-01',
    [string]$VmSize = 'Standard_B2ms',
    [string]$UserUpn = 'p54@zippyops.in',
    [string]$RegistrationTokenLifetimeHours = 8
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Assert-CommandSuccess {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message,
        [Parameter(Mandatory = $true)]
        [bool]$Condition
    )

    if (-not $Condition) {
        throw $Message
    }
}

function Invoke-AzJson {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Arguments
    )

    $output = & az @Arguments -o json
    if ($LASTEXITCODE -ne 0) {
        throw "Azure CLI command failed: az $($Arguments -join ' ')"
    }

    if ([string]::IsNullOrWhiteSpace($output)) {
        return $null
    }

    return $output | ConvertFrom-Json
}

Write-Host 'AVD provisioning script - POOL-FIN-01'
Write-Host "Subscription : $SubscriptionId"
Write-Host "ResourceGroup : $ResourceGroup"
Write-Host "Location      : $Location"

Write-Host 'Step 1 - Confirm identity and set subscription'
$identity = Invoke-AzJson -Arguments @('account', 'show')
Assert-CommandSuccess -Message 'Azure CLI is not authenticated.' -Condition ($null -ne $identity)

& az account set --subscription $SubscriptionId | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "Failed to switch to subscription $SubscriptionId"
}

$context = Invoke-AzJson -Arguments @('account', 'show')
Assert-CommandSuccess -Message 'Subscription context did not switch correctly.' -Condition ($context.id -eq $SubscriptionId)

Write-Host 'Step 2 - Ensure resource group exists'
$rg = Invoke-AzJson -Arguments @('group', 'show', '--name', $ResourceGroup)
if ($null -eq $rg) {
    & az group create --name $ResourceGroup --location $Location | Out-Null
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to create resource group $ResourceGroup"
    }
}

Write-Host 'Step 3 - Create workspace'
& az desktopvirtualization workspace create `
    --resource-group $ResourceGroup `
    --name $WorkspaceName `
    --location $Location `
    --friendly-name 'FinBridge Workspace' `
    --description 'Finance migration workspace' | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "Failed to create workspace $WorkspaceName"
}

$workspace = Invoke-AzJson -Arguments @('desktopvirtualization', 'workspace', 'show', '--resource-group', $ResourceGroup, '--name', $WorkspaceName)
Assert-CommandSuccess -Message 'Workspace was not created successfully.' -Condition ($null -ne $workspace)

Write-Host 'Step 4 - Create host pool'
& az desktopvirtualization hostpool create `
    --resource-group $ResourceGroup `
    --name $HostPoolName `
    --location $Location `
    --host-pool-type Pooled `
    --load-balancer-type BreadthFirst `
    --maximum-sessions-limit 5 `
    --preferred-app-group-type Desktop `
    --validation-environment false | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "Failed to create host pool $HostPoolName"
}

$hostPool = Invoke-AzJson -Arguments @('desktopvirtualization', 'hostpool', 'show', '--resource-group', $ResourceGroup, '--name', $HostPoolName)
Assert-CommandSuccess -Message 'Host pool was not created successfully.' -Condition ($null -ne $hostPool)

Write-Host 'Step 5 - Create desktop application group'
& az desktopvirtualization applicationgroup create `
    --resource-group $ResourceGroup `
    --name $DesktopAppGroupName `
    --location $Location `
    --host-pool-name $HostPoolName `
    --type Desktop `
    --friendly-name 'Finance Desktop' `
    --description 'Published desktop for finance migration users' | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "Failed to create desktop app group $DesktopAppGroupName"
}

$appGroup = Invoke-AzJson -Arguments @('desktopvirtualization', 'applicationgroup', 'show', '--resource-group', $ResourceGroup, '--name', $DesktopAppGroupName)
Assert-CommandSuccess -Message 'Desktop application group was not created successfully.' -Condition ($null -ne $appGroup)

Write-Host 'Step 6 - Link the app group to the workspace'
& az desktopvirtualization workspace update `
    --resource-group $ResourceGroup `
    --name $WorkspaceName `
    --add applicationGroupReferences $appGroup.id | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw 'Failed to register the desktop application group with the workspace.'
}

Write-Host 'Step 7 - Grant user access'
& az role assignment create `
    --assignee $UserUpn `
    --role 'Desktop Virtualization User' `
    --scope $appGroup.id | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw "Failed to assign Desktop Virtualization User to $UserUpn"
}

Write-Host 'Step 8 - Create registration token'
$expiry = (Get-Date).ToUniversalTime().AddHours([int]$RegistrationTokenLifetimeHours).ToString('yyyy-MM-ddTHH:mm:ssZ')
& az desktopvirtualization hostpool update `
    --resource-group $ResourceGroup `
    --name $HostPoolName `
    --registration-info expiration-time=$expiry registration-token-operation=Update | Out-Null
if ($LASTEXITCODE -ne 0) {
    throw 'Failed to generate host pool registration token.'
}

$registrationInfo = Invoke-AzJson -Arguments @('desktopvirtualization', 'hostpool', 'show', '--resource-group', $ResourceGroup, '--name', $HostPoolName)
Assert-CommandSuccess -Message 'Host pool registration info is not available.' -Condition ($null -ne $registrationInfo)

Write-Host 'Step 9 - Emit deployment guidance'
Write-Host "Host pool        : $HostPoolName"
Write-Host "Workspace        : $WorkspaceName"
Write-Host "Desktop app group: $DesktopAppGroupName"
Write-Host "Session host VM  : $VmName"
Write-Host 'Next: use the registration token from the host pool with the Windows 11 multi-session image deployment workflow.'
