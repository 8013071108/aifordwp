# Runbook - FAULT-B Finance Shared Drives Unavailable

## Version Header
- Title: Runbook - FAULT-B Finance Shared Drives Unavailable
- Version: 1.0
- Date: 07/08/2026
- Author: Sathishbabu
- Reviewed: self
- Status: draft
- Change: initial version from RCA

## 1. Prerequisites
### Access
- Azure Intune admin portal access to run and monitor endpoint scripts [ELEVATED]
- Local admin access to at least one affected endpoint for log collection [ELEVATED]
- Access to endpoint event logs and Intune Management Extension logs [ELEVATED]
- Change approval to modify script execution context and redeploy [ELEVATED]

### Tools
- Intune admin center (web)
- Remote desktop support tool
- Event Viewer (`eventvwr.msc`)
- File Explorer access to Intune log path
- Ticketing/incident system

### Mandatory Inputs
- One affected device name (example: DESKTOP-FB041)
- Failing script name: Map-FinBridgeDrives.ps1
- Failing path: \\finbridge-fs01\Finance
- Affected user group: Finance users (DESKTOP-FB* / OU=Finance)
- Confirmation that issue started after migration change window

## 2. Procedure
1. Open Intune admin center and go to Devices > Scripts to locate Map-FinBridgeDrives.ps1 [ELEVATED].
Expected result: The mapped-drive script policy is visible.

2. Open the script assignment and confirm the current execution context is SYSTEM [ELEVATED].
Expected result: You confirm the context mismatch described in RCA.

3. Open the same script policy and change execution to user context (or move assignment to user-context method) [ELEVATED].
Expected result: Script is configured to run as signed-in user.

4. Save the updated script policy [ELEVATED].
Expected result: Intune policy change is committed.

5. Trigger Intune sync on one pilot affected device from Intune admin center > Devices > target device > Sync [ELEVATED].
Expected result: Device receives latest script policy.

6. On the pilot device, open File Explorer and browse to C:\ProgramData\Microsoft\IntuneManagementExtension\Logs.
Expected result: Intune Management Extension logs are accessible.

7. Open IntuneManagementExtension.log and confirm Map-FinBridgeDrives.ps1 ran in user context.
Expected result: Log shows user-context execution for the script.

8. In the same log, confirm there is no new exit code 1 entry for Map-FinBridgeDrives.ps1.
Expected result: Script failure signature is absent.

9. Ask the pilot user to sign out and sign in once.
Expected result: User session refreshes with latest mapping state.

10. Ask the pilot user to open File Explorer and check drive S:.
Expected result: Drive S: appears and opens successfully.

11. Open Event Viewer on the pilot device and go to Windows Logs > System.
Expected result: System log is visible.

12. Filter System log for Event ID 98 in the last 30 minutes.
Expected result: No new NTFS Event 98 for S: mapping failure.

13. Trigger Intune sync for remaining affected Finance devices in batches [ELEVATED].
Expected result: Updated script policy propagates across affected estate.

14. Confirm success count in Intune script/device status report [ELEVATED].
Expected result: Majority of targeted devices report successful script execution.

15. Update the incident ticket with evidence from Intune log and pilot verification.
Expected result: Remediation trail is documented.

## 3. Verification
1. In Intune admin center, open script deployment status for Map-FinBridgeDrives.ps1.
Pass condition: Targeted devices show successful run status.

2. On two remediated devices, check IntuneManagementExtension.log for user-context run and no exit code 1.
Pass condition: Both devices match expected healthy pattern.

3. On the same devices, check Event Viewer > Windows Logs > System for no new Event 98 related to S: mapping.
Pass condition: No fresh mapping-failure events after remediation.

4. Validate with at least two Finance users that S: opens correctly.
Pass condition: Users can access shared drive path without error.

## 4. Rollback
1. Open Intune admin center > Devices > Scripts > Map-FinBridgeDrives.ps1 and disable the changed assignment immediately [ELEVATED].
Expected result: New faulty script runs stop.

2. Restore the previously known-good mapping method (prior approved user-logon mapping configuration) [ELEVATED].
Expected result: Clients return to last stable mapping path.

3. Trigger Intune sync on pilot devices [ELEVATED].
Expected result: Rollback policy reaches devices.

4. Ask pilot user to sign out/sign in and confirm S: availability.
Expected result: Shared drive access is restored.

5. Record rollback start time, changed object name, and verification proof in the incident ticket.
Expected result: Rollback is fully auditable.

## 5. Notes
- This incident is not caused by Group Policy failure; Event 1500 success confirms GP processing was healthy.
- Main fault signature is script running in SYSTEM context with network path failure and exit code 1.
- If only a subset fails post-fix, check assignment targeting and sync completion per device.
- Related incident family: post-migration context mismatch for scripts moved from user logon methods to device/system methods.
