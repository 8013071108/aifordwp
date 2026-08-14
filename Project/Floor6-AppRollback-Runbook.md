# Title: Floor 6 Legal - Document Management App Rollback / Exclusion Runbook
Version: 1.0
Date: 14/08/2026
Author: Shuvrojit Barua
Reviewed By: Self
Status: Draft
Change: Initial version created from Floor 6 incident immediate fix

## 1. Purpose
This runbook is for urgent containment of the Floor 6 Legal incident where users reported slow login, login failure, and missing desktop shortcuts after the Friday Intune deployment of a new document management application.

## 2. Scope
Floor 6 Legal devices affected by slow login, login failure, or missing desktop shortcuts after the Friday app deployment.

## 3. Prerequisites
Use this checklist before making any change.

### Required access
- [ ] Microsoft Graph PowerShell access with rights to read and update groups, devices, and Intune app assignments [ELEVATED]
- [ ] Access to the Intune admin center for app assignment verification [ELEVATED]
- [ ] Device access to at least one affected endpoint for sync and log collection [ELEVATED]

### Required portals/tools
- [ ] Microsoft Graph PowerShell SDK
- [ ] Intune admin center
- [ ] PowerShell on an affected endpoint
- [ ] Ticket/update channel for Service Desk and incident management

### Required device/user information
- [ ] Floor 6 deployment group name or Group ID
- [ ] Affected device IDs or device names
- [ ] Current document management app ID (`<DocumentAppCurrentId>`)
- [ ] Previous known-good app ID (`<DocumentAppPreviousVersionId>`)
- [ ] At least one affected user available to verify login and shortcut state

### Required approval or escalation
- [ ] Incident manager approval for containment change [ELEVATED]
- [ ] Desktop engineering contact informed if rollback assignment is needed

### Required evidence before action
- [ ] Confirm Friday app deployment occurred to Floor 6 Legal
- [ ] Confirm at least one affected device is in the active deployment scope
- [ ] Confirm login issue and/or shortcut issue is current, not historical only

### What must be confirmed before rollback or exclusion
- [ ] Whether exclusion alone is sufficient or rollback to previous version is required
- [ ] Whether current app assignment supports exclusions or requires assignment redesign
- [ ] Whether affected devices have completed recent Intune check-in

## 4. Procedure

### Step 1
- Action: Connect to Microsoft Graph.
- Exact command or portal path:
```powershell
Connect-MgGraph -TenantId "<TenantId>" -Scopes "Group.ReadWrite.All","DeviceManagementApps.ReadWrite.All","DeviceManagementManagedDevices.ReadWrite.All","Directory.ReadWrite.All"
Select-MgProfile -Name "beta"
```
- Expected result: Graph session connects successfully and beta profile is active.
- Type: Read-only
- Elevated permission required: Yes

### Step 2
- Action: Identify the Floor 6 Legal deployment group.
- Exact command or portal path:
```powershell
Get-MgGroup -Filter "displayName eq 'Floor6-Legal'" | Format-List Id,DisplayName
Get-MgGroup -Filter "startswith(displayName,'Floor6')" | Select-Object Id,DisplayName
```
- Expected result: Floor 6 Legal deployment group is identified and Group ID is recorded.
- Type: Read-only
- Elevated permission required: Yes

### Step 3
- Action: Find the current document app object and its assignments.
- Exact command or portal path:
```powershell
Get-MgDeviceAppManagementMobileApp -MobileAppId "<DocumentAppCurrentId>" | Format-List Id,DisplayName
Get-MgDeviceAppManagementMobileAppAssignment -MobileAppId "<DocumentAppCurrentId>" | Format-List
```
- Expected result: Current app object and all assignment targets are visible.
- Type: Read-only
- Elevated permission required: Yes

### Step 4
- Action: Create the emergency exclusion group if it does not already exist.
- Exact command or portal path:
```powershell
$ExclusionGroup = New-MgGroup -DisplayName "Floor6-Legal-DocumentApp-Emergency-Exclude" `
  -MailEnabled:$false `
  -MailNickname "floor6legaldocexclude" `
  -SecurityEnabled:$true `
  -Description "Emergency exclusion group for Floor 6 Legal document app containment"

$ExclusionGroup.Id
```
- Expected result: New exclusion group is created and the Group ID is returned.
- Type: Change-making
- Elevated permission required: Yes

### Step 5
- Action: If the exclusion group already exists, retrieve it instead of creating a duplicate.
- Exact command or portal path:
```powershell
Get-MgGroup -Filter "displayName eq 'Floor6-Legal-DocumentApp-Emergency-Exclude'" | Format-List Id,DisplayName
```
- Expected result: Existing exclusion group ID is confirmed.
- Type: Read-only
- Elevated permission required: Yes

### Step 6
- Action: Add affected devices to the emergency exclusion group.
- Exact command or portal path:
```powershell
$AffectedDeviceIds = @(
    "<DeviceId1>",
    "<DeviceId2>",
    "<DeviceId3>"
)

foreach ($DeviceId in $AffectedDeviceIds) {
    New-MgGroupMemberByRef -GroupId "<EmergencyExclusionGroupId>" -BodyParameter @{
        "@odata.id" = "https://graph.microsoft.com/v1.0/devices/$DeviceId"
    }
}
```
- Expected result: Affected devices are members of the exclusion group.
- Type: Change-making
- Elevated permission required: Yes

### Step 7
- Action: Exclude the emergency exclusion group from the active deployment ring if the assignment model supports exclusions.
- Exact command or portal path:
- Intune admin center > Apps > All apps > `<Current Document App>` > Assignments
- or tenant-approved Graph assignment update body using:
```powershell
Update-MgDeviceAppManagementMobileApp -MobileAppId "<DocumentAppCurrentId>" -BodyParameter @{
    "assignments" = @(
        # Existing assignments retained
        # Add exclusion target for <EmergencyExclusionGroupId>
    )
}
```
- Expected result: Affected devices are no longer targeted by the active deployment ring.
- Type: Change-making
- Elevated permission required: Yes

### Step 8
- Action: If direct exclusion is not supported by the current assignment design, remove the Floor 6 target from the current ring and replace it with a narrower include assignment that excludes the affected devices.
- Exact command or portal path:
```powershell
# Review current assignment body first
Get-MgDeviceAppManagementMobileAppAssignment -MobileAppId "<DocumentAppCurrentId>" | Format-List

# Then apply tenant-approved assignment JSON/body
Update-MgDeviceAppManagementMobileApp -MobileAppId "<DocumentAppCurrentId>" -BodyParameter @{
    "assignments" = @(
        # Revised include/exclude model goes here
    )
}
```
- Expected result: Affected devices are removed from the active deployment scope.
- Type: Change-making
- Elevated permission required: Yes

### Step 9
- Action: If rollback is required, assign the previous known-good app version to the rollback group or exclusion cohort.
- Exact command or portal path:
```powershell
Get-MgDeviceAppManagementMobileApp -MobileAppId "<DocumentAppPreviousVersionId>" | Format-List Id,DisplayName

Update-MgDeviceAppManagementMobileApp -MobileAppId "<DocumentAppPreviousVersionId>" -BodyParameter @{
    "assignments" = @(
        @{
            "intent" = "required"
            "target" = @{
                "@odata.type" = "#microsoft.graph.groupAssignmentTarget"
                "groupId" = "<RollbackGroupIdOrEmergencyExclusionGroupId>"
            }
        }
    )
}
```
- Expected result: Previous known-good version is assigned to the selected rollback target.
- Type: Change-making
- Elevated permission required: Yes

### Step 10
- Action: Trigger Intune sync on an affected endpoint.
- Exact command or portal path:
```powershell
Get-ScheduledTask -TaskPath "\Microsoft\Windows\EnterpriseMgmt\" | Start-ScheduledTask
```
- Expected result: Device begins MDM sync cycle.
- Type: Change-making
- Elevated permission required: Yes

### Step 11
- Action: Collect Intune Management Extension logs from the affected endpoint.
- Exact command or portal path:
```powershell
$Out = "$env:USERPROFILE\Desktop\IME-Logs"
New-Item -Path $Out -ItemType Directory -Force | Out-Null
Copy-Item "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\*.log" -Destination $Out -Force
```
- Expected result: IME logs are copied locally for evidence review.
- Type: Read-only evidence collection
- Elevated permission required: Yes

### Step 12
- Action: Check whether the document management app is still installed on the affected device.
- Exact command or portal path:
```powershell
Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*","HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" |
Where-Object { $_.DisplayName -match "Document|Legal|Matter|FinBridge" } |
Select-Object DisplayName,DisplayVersion,Publisher,InstallDate
```
- Expected result: Installed state of the target app is visible.
- Type: Read-only
- Elevated permission required: Yes

## 5. Verification
After containment, check all of the following:

1. Intune app install status
- Confirm affected devices now show excluded, not targeted, or reassigned to the previous app version as intended.

2. Device check-in status
- Confirm affected devices complete Intune check-in after the containment change.

3. User login result
- Confirm the previously affected users can sign in successfully.

4. Login duration improved
- Confirm sign-in time is improved compared with the original complaint pattern.

5. Desktop shortcuts visible or recreated
- Confirm whether shortcuts are visible again or no longer disappearing after sign-in.

6. User confirmation
- Obtain direct confirmation from at least one previously affected user.

7. No new incidents after action
- Confirm no new Floor 6 login or missing-shortcut incidents are reported after the containment window.

## 6. Rollback
If the exclusion or rollback action makes the situation worse, perform these steps immediately. Target time: under 3 minutes.

### Step 1
- Action: Reconnect to Microsoft Graph if session is not active.
- Exact command:
```powershell
Connect-MgGraph -TenantId "<TenantId>" -Scopes "Group.ReadWrite.All","DeviceManagementApps.ReadWrite.All","DeviceManagementManagedDevices.ReadWrite.All","Directory.ReadWrite.All"
Select-MgProfile -Name "beta"
```
- Expected result: Graph session restored.

### Step 2
- Action: Remove affected devices from the emergency exclusion group if they were excluded by mistake.
- Exact command:
```powershell
$AffectedDeviceIds = @("<DeviceId1>","<DeviceId2>","<DeviceId3>")
foreach ($DeviceId in $AffectedDeviceIds) {
    Remove-MgGroupMemberByRef -GroupId "<EmergencyExclusionGroupId>" -DirectoryObjectId $DeviceId
}
```
- Expected result: Devices are no longer in the exclusion group.

### Step 3
- Action: Restore the previous active assignment model for the current app.
- Exact command:
```powershell
Update-MgDeviceAppManagementMobileApp -MobileAppId "<DocumentAppCurrentId>" -BodyParameter @{
    "assignments" = @(
        # Restore last known-good assignment JSON/body
    )
}
```
- Expected result: Original assignment scope is restored.

### Step 4
- Action: Remove previous-version rollback assignment if it was added incorrectly.
- Exact command:
```powershell
Update-MgDeviceAppManagementMobileApp -MobileAppId "<DocumentAppPreviousVersionId>" -BodyParameter @{
    "assignments" = @(
        # Remove emergency rollback target from assignment body
    )
}
```
- Expected result: Incorrect rollback assignment is removed.

### Step 5
- Action: Trigger Intune sync on the endpoint again.
- Exact command:
```powershell
Get-ScheduledTask -TaskPath "\Microsoft\Windows\EnterpriseMgmt\" | Start-ScheduledTask
```
- Expected result: Device begins a fresh sync using the corrected assignment state.

## 7. Communication

### Who to update
- Incident manager
- Service Desk
- Desktop engineering contact
- Floor 6 business lead if user impact remains active

### What to say
- State that containment action has been applied to limit further impact from the Friday document management app deployment.
- State whether affected devices were excluded, reassigned, or rolled back.
- State that verification is in progress and user confirmation is still being collected.

### What not to say yet
- Do not say the issue is fully resolved until verification is complete.
- Do not say the Friday app deployment is the confirmed root cause unless evidence proves it.
- Do not link the Copilot concern to the login or shortcut issue unless evidence supports it.

## 8. Known Risks and Notes
- The Copilot access concern must be handled separately through permissions and audit review.
- Do not declare unauthorized access unless it is proven.
- Do not delete user profiles or shortcuts during containment.
- The app deployment remains the most likely cause based on timing and affected population, but this is still to confirm.
