<#
.SYNOPSIS
    Wrapper for Day 3 temp cleanup script.

.DESCRIPTION
    Provides a stable root-level command name and forwards all arguments
    to Day 3\Invoke-DwpTempCleanup.ps1.
#>

[CmdletBinding()]
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
    [string[]]$TargetPaths,

    [Parameter()]
    [string]$StateRoot
)

$scriptPath = Join-Path -Path $PSScriptRoot -ChildPath 'Day 3\Invoke-DwpTempCleanup.ps1'

if (-not (Test-Path -LiteralPath $scriptPath)) {
    throw "Target script not found: $scriptPath"
}

$invokeParams = @{
    DryRun       = $DryRun
    OlderThanDays= $OlderThanDays
    Rollback     = $Rollback
}

if ($PSBoundParameters.ContainsKey('RollbackManifestPath')) {
    $invokeParams.RollbackManifestPath = $RollbackManifestPath
}

if ($PSBoundParameters.ContainsKey('TargetPaths')) {
    $invokeParams.TargetPaths = $TargetPaths
}

if ($PSBoundParameters.ContainsKey('StateRoot')) {
    $invokeParams.StateRoot = $StateRoot
}

& $scriptPath @invokeParams
