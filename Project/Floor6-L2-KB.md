# Title: Floor 6 Legal - Intune App Deployment Rollback and Exclusion Technical KB
Version: 1.0
Date: 14/08/2026
Author: Shuvrojit Barua
Reviewed By: Self
Status: Draft
Source: Floor6-AppRollback-Runbook.md

Source of truth note: This article is derived from Floor6-AppRollback-Runbook.md. If process steps, commands, or containment logic change, update the runbook first and then refresh this article from it.

## 1. Background
This article supports engineers handling a repeat of the Floor 6 Legal incident where users reported slow login, login failure, and missing desktop shortcuts after the Friday deployment of a new document management application. The runbook source treats the app deployment as the most likely cause based on timing and affected population, but not as a confirmed RCA until verification is complete.

## 2. Symptoms
- Users report slow login or login failure.
- One or more users report missing desktop shortcuts.
- The symptoms appear after the Friday deployment of the document management application.

## 3. Scope
- Floor 6 Legal devices affected by slow login, login failure, or missing desktop shortcuts.
- This article is limited to the app deployment containment and rollback workstream.
- The Copilot access concern is separate and must be handled as an M365 permissions and audit workstream.

## 4. Most Likely Cause
The most likely cause is that the Friday Intune deployment of the new document management app introduced a startup, logon, or desktop-state impact that is affecting sign-in performance and shortcut visibility.

Confirmed from source runbook:
- Floor 6 Legal has 45 users.
- At least a dozen users reported login failure or very slow login on Monday morning.
- One user reported missing desktop shortcuts.
- A new document management app was deployed to Floor 6 on Friday afternoon through Intune.

To confirm:
- Whether the app deployment directly caused the login issue.
- Whether the shortcut issue is the same cause or a separate profile/desktop issue.

## 5. Detection
### Read-only checks
1. Identify the Floor 6 Legal deployment group.
- Entra admin center > Groups
- Intune admin center > Groups
- Microsoft Graph PowerShell:
```powershell
Get-MgGroup -Filter "displayName eq 'Floor6-Legal'" | Format-List Id,DisplayName
Get-MgGroup -Filter "startswith(displayName,'Floor6')" | Select-Object Id,DisplayName
```

2. Review current app object and assignments.
- Intune admin center > Apps > Windows apps > <Current Document App>
- Microsoft Graph PowerShell:
```powershell
Get-MgDeviceAppManagementMobileApp -MobileAppId "<DocumentAppCurrentId>" | Format-List Id,DisplayName
Get-MgDeviceAppManagementMobileAppAssignment -MobileAppId "<DocumentAppCurrentId>" | Format-List
```

3. Check affected device presence and management state.
- Intune admin center > Devices > Windows

4. Confirm affected device app presence locally.
- Device-side read-only command:
```powershell
Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*","HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" |
Where-Object { $_.DisplayName -match "Document|Legal|Matter|FinBridge" } |
Select-Object DisplayName,DisplayVersion,Publisher,InstallDate
```

## 6. Evidence to Collect
### Read-only evidence collection
- Intune admin center > Apps > Windows apps > <Current Document App> > Assignments
- Intune admin center > Devices > Windows > <Affected Device>
- Intune admin center > Groups
- Entra admin center > Groups
- Device-side Intune Management Extension logs:
```powershell
$Out = "$env:USERPROFILE\Desktop\IME-Logs"
New-Item -Path $Out -ItemType Directory -Force | Out-Null
Copy-Item "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\*.log" -Destination $Out -Force
```
- Device-side sync trigger evidence:
```powershell
Get-ScheduledTask -TaskPath "\Microsoft\Windows\EnterpriseMgmt\" | Start-ScheduledTask
```
- User-reported login result and shortcut status after containment

## 7. Immediate Containment
### Read-only commands
```powershell
Connect-MgGraph -TenantId "<TenantId>" -Scopes "Group.ReadWrite.All","DeviceManagementApps.ReadWrite.All","DeviceManagementManagedDevices.ReadWrite.All","Directory.ReadWrite.All"
Select-MgProfile -Name "beta"

Get-MgGroup -Filter "displayName eq 'Floor6-Legal'" | Format-List Id,DisplayName
Get-MgDeviceAppManagementMobileApp -MobileAppId "<DocumentAppCurrentId>" | Format-List Id,DisplayName
Get-MgDeviceAppManagementMobileAppAssignment -MobileAppId "<DocumentAppCurrentId>" | Select-Object Id,Intent,Target
```

### Change-making actions
1. Create or locate the emergency exclusion group.
- Entra admin center > Groups
- Intune admin center > Groups
- Microsoft Graph PowerShell:
```powershell
$ExclusionGroup = New-MgGroup -DisplayName "Floor6-Legal-DocumentApp-Emergency-Exclude" `
  -MailEnabled:$false `
  -MailNickname "floor6legaldocexclude" `
  -SecurityEnabled:$true `
  -Description "Emergency exclusion group for Floor 6 Legal document app containment"

$ExclusionGroup.Id
```

2. Add affected devices to the exclusion group.
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

3. Exclude affected devices from the current app deployment if supported, or replace the assignment model with a narrower target.
- Intune admin center > Apps > Windows apps > <Current Document App> > Assignments
- Microsoft Graph PowerShell pattern:
```powershell
Update-MgDeviceAppManagementMobileApp -MobileAppId "<DocumentAppCurrentId>" -BodyParameter @{
    "assignments" = @(
        # Existing assignments retained
        # Add exclusion target for <EmergencyExclusionGroupId>
    )
}
```

## 8. Technical Resolution
If exclusion is not sufficient, assign the previous known-good app version to the rollback cohort.

### Change-making action
- Intune admin center > Apps > Windows apps > <Previous Known-Good App>
- Microsoft Graph PowerShell:
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

## 9. Verification
- Intune admin center > Apps > Windows apps > <Current Document App>
- Intune admin center > Devices > Windows

Verify all of the following:
1. Affected devices show excluded, not targeted, or reassigned as intended.
2. Affected devices complete check-in after the change.
3. Previously affected users can sign in successfully.
4. Login duration improves against the complaint pattern.
5. Desktop shortcuts are visible again or no longer disappearing.
6. At least one affected user confirms improvement.
7. No new Floor 6 login or missing-shortcut incidents are reported after containment.

## 10. Rollback
Use if the exclusion or rollback action makes the situation worse.

### Read-only / session restore
```powershell
Connect-MgGraph -TenantId "<TenantId>" -Scopes "Group.ReadWrite.All","DeviceManagementApps.ReadWrite.All","DeviceManagementManagedDevices.ReadWrite.All","Directory.ReadWrite.All"
Select-MgProfile -Name "beta"
```

### Change-making actions
1. Remove affected devices from the emergency exclusion group if they were excluded incorrectly.
```powershell
$AffectedDeviceIds = @("<DeviceId1>","<DeviceId2>","<DeviceId3>")
foreach ($DeviceId in $AffectedDeviceIds) {
    Remove-MgGroupMemberByRef -GroupId "<EmergencyExclusionGroupId>" -DirectoryObjectId $DeviceId
}
```

2. Restore the previous active assignment model for the current app.
```powershell
Update-MgDeviceAppManagementMobileApp -MobileAppId "<DocumentAppCurrentId>" -BodyParameter @{
    "assignments" = @(
        # Restore last known-good assignment JSON/body
    )
}
```

3. Remove the previous-version rollback assignment if it was added incorrectly.
```powershell
Update-MgDeviceAppManagementMobileApp -MobileAppId "<DocumentAppPreviousVersionId>" -BodyParameter @{
    "assignments" = @(
        # Remove emergency rollback target from assignment body
    )
}
```

4. Trigger a fresh device sync.
```powershell
Get-ScheduledTask -TaskPath "\Microsoft\Windows\EnterpriseMgmt\" | Start-ScheduledTask
```

## 11. Escalation Criteria
Escalate if any of the following apply:
- Exclusion cannot be applied because the current assignment design is not safely understood.
- Previous known-good app assignment details are unavailable.
- Affected devices do not check in after sync trigger.
- Login or shortcut issues continue after containment.
- Scope expands beyond the original affected cohort.
- Any request is made to combine this workstream with the Copilot concern without permissions or audit evidence.

## 12. Related Notes
- The Copilot access concern is a separate M365 permissions and audit workstream.
- Do not declare unauthorized access unless proven.
- Do not declare final RCA until verification is complete.
- Do not add new root causes beyond the runbook source.
