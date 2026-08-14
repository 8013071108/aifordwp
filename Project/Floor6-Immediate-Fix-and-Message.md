# Section 4: Immediate Fix and Message to Floor

## 1. Most Likely Cause
The most likely cause is that the Friday Intune deployment of the new document management app to Floor 6 Legal introduced a startup, logon, or desktop-state impact that is affecting sign-in performance and shortcut visibility.

Confirmed:
- Floor 6 Legal has 45 users.
- At least a dozen users reported login failure or very slow login on Monday morning.
- One user reported missing desktop shortcuts.
- A new document management app was deployed to Floor 6 on Friday afternoon through Intune.

To confirm:
- Whether the app deployment directly caused the login issue.
- Whether the shortcut issue is part of the same cause or a separate desktop/profile issue.
- Whether the app changed startup behavior, installed background components, or altered shortcut state.

## 2. Immediate Technical Containment

### a. Connect to Microsoft Graph
Safe discovery command:
```powershell
Connect-MgGraph -TenantId "<TenantId>" -Scopes "Group.ReadWrite.All","DeviceManagementApps.ReadWrite.All","DeviceManagementManagedDevices.ReadWrite.All","Directory.ReadWrite.All"
Select-MgProfile -Name "beta"
```

### b. Identify the Floor 6 Legal app deployment group
Safe discovery command:
```powershell
Get-MgGroup -Filter "displayName eq 'Floor6-Legal'" | Format-List Id,DisplayName
Get-MgGroup -Filter "startswith(displayName,'Floor6')" | Select-Object Id,DisplayName
```

### c. Create an emergency exclusion group if needed
Change command:
```powershell
$ExclusionGroup = New-MgGroup -DisplayName "Floor6-Legal-DocumentApp-Emergency-Exclude" `
  -MailEnabled:$false `
  -MailNickname "floor6legaldocexclude" `
  -SecurityEnabled:$true `
  -Description "Emergency exclusion group for Floor 6 Legal document app containment"

$ExclusionGroup.Id
```

### d. Add affected devices to the exclusion group
Change command:
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

### e. Remove or exclude the affected devices from the active deployment ring
Safe discovery command:
```powershell
Get-MgDeviceAppManagementMobileAppAssignment -MobileAppId "<DocumentAppCurrentId>" |
    Select-Object Id,Intent,Target
```

Change action note:
- If the current app assignment already supports exclusions, add `<EmergencyExclusionGroupId>` as an exclusion target to the active assignment.
- If the current app assignment does not support direct exclusion in its present design, remove the Floor 6 deployment target from the active ring and replace it with a narrower include group that excludes the affected devices.

Change command pattern (assignment replacement requires tenant-specific assignment body):
```powershell
# Review current app object and assignments first
Get-MgDeviceAppManagementMobileApp -MobileAppId "<DocumentAppCurrentId>" | Format-List Id,DisplayName
Get-MgDeviceAppManagementMobileAppAssignment -MobileAppId "<DocumentAppCurrentId>" | Format-List

# Then update assignments using the tenant-approved assignment JSON/body
# Placeholder only - tenant-specific assignment structure must be confirmed before execution
Update-MgDeviceAppManagementMobileApp -MobileAppId "<DocumentAppCurrentId>" -BodyParameter @{
    "assignments" = @(
        # Existing safe assignments retained
        # Affected Floor 6 group removed or exclusion target added here
    )
}
```

### f. Assign the previous known-good app version if rollback is required
Safe discovery command:
```powershell
Get-MgDeviceAppManagementMobileApp -MobileAppId "<DocumentAppPreviousVersionId>" | Format-List Id,DisplayName
```

Change command pattern:
```powershell
# Assign previous known-good version to a rollback group or directly to the emergency containment cohort
# Placeholder body - exact assignment JSON depends on tenant assignment design
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

## 3. Device-Side Immediate Action

### Trigger Intune sync on an affected device
Command:
```powershell
Get-ScheduledTask -TaskPath "\Microsoft\Windows\EnterpriseMgmt\" | Start-ScheduledTask
```

### Collect Intune Management Extension logs
Command:
```powershell
$Out = "$env:USERPROFILE\Desktop\IME-Logs"
New-Item -Path $Out -ItemType Directory -Force | Out-Null
Copy-Item "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs\*.log" -Destination $Out -Force
```

### Check whether the app is still installed
Command:
```powershell
Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*","HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" |
Where-Object { $_.DisplayName -match "Document|Legal|Matter|FinBridge" } |
Select-Object DisplayName,DisplayVersion,Publisher,InstallDate
```

## 4. Verification
After containment, verify all of the following:

1. Login success
- Confirm affected users can sign in successfully.

2. Login duration
- Compare post-containment sign-in time on affected devices against the pre-containment complaint pattern.

3. Desktop shortcut status
- Confirm whether shortcuts reappear, remain unchanged, or still vanish after sign-in.

4. Intune app status
- Confirm the affected devices are excluded from the active deployment ring or reassigned to the rollback version as intended.
- Confirm the target app state on affected devices matches the containment decision.

5. User confirmation
- Obtain direct confirmation from at least one previously affected user that login behavior improved and whether desktop shortcut behavior changed.

## 5. Plain-Language Note to Floor 6
We are aware that some Floor 6 users are having trouble signing in, and some people may also be seeing changes to their desktop shortcuts. IT is taking action now to limit any further impact while we check the recent changes made to this group.

If you are affected, please restart your device once and try signing in again. If your desktop looks different after sign-in, do not delete or recreate anything yet unless you need to continue urgent work.

Please contact the Service Desk if you still cannot sign in, if sign-in is taking an unusually long time, or if important shortcuts are still missing after restart. When you contact us, share your device name, the time the issue happened, and a screenshot if possible.

The separate Copilot matter is being reviewed on its own as a high-priority access check.
