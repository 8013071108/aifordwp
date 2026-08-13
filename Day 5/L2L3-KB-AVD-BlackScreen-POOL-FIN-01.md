# L2/L3 KB - AVD Black Screen Post Login (POOL-FIN-01)

Version: v 1.0  
Date: 07/08/2026  
Status: Draft

## Background
The AVD service delivers user desktops from pooled session hosts. User sign-in must complete shell and desktop rendering for a usable session. If desktop rendering fails on a pool, users can authenticate but cannot work, causing immediate business impact.

## Symptom
Engineer-observed pattern:
- Impact limited to POOL-FIN-01 after overnight update.
- POOL-FIN-02 remains healthy during same period.
- Repeated session reconnect/disconnect loops on affected hosts.

User-reported pattern:
- Black screen immediately after login.
- For some users it clears after about 30 seconds.
- For others it persists or disconnects.

## Root Cause
A regression in the updated POOL-FIN-01 image introduced an unstable graphics stack component. On affected hosts, dwm.exe crashes in igdumd64.dll (access violation), then DWM exits and user sessions disconnect.

Evidence that confirms root cause:
- Affected host SHFIN-01-A: Application Event 1000 with faulting app dwm.exe and module igdumd64.dll; exception 0xc0000005.
- Affected host SHFIN-01-A: Desktop Window Manager Event 9009 after crash.
- Affected host SHFIN-01-A: TerminalServices-LocalSessionManager Event 40 disconnect after Event 21 logon success.
- Control host SHFIN-02-A (POOL-FIN-02): DWM Event 9011 success and no matching Application Event 1000 in same window.

## Detection
Target time: under 3 minutes for initial confirmation.

### A. Fast host selection (portal or command)
1. Identify one affected host in POOL-FIN-01 and one healthy control host in POOL-FIN-02.
- Portal path: Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts, and POOL-FIN-02 > Session hosts.
- Field(s): session host name, session count, allow new sessions.

2. (Optional fast command) list hosts from PowerShell instead of clicking through portal.
```powershell
# Requires Az.DesktopVirtualization module and signed-in Azure context
Get-AzWvdSessionHost -ResourceGroupName <RG_NAME> -HostPoolName POOL-FIN-01 |
	Select-Object Name,AllowNewSession,Status

Get-AzWvdSessionHost -ResourceGroupName <RG_NAME> -HostPoolName POOL-FIN-02 |
	Select-Object Name,AllowNewSession,Status
```
- Field(s): Name, AllowNewSession, Status.

### B. Exact event confirmation on affected host (required)
3. Open the affected host and query Application log for Event 1000.
- Exact log location: Event Viewer > Windows Logs > Application.
- Required Event ID: 1000.
- Required fields in event message/details: Faulting application name, Faulting module name, Exception code.
- Required match: Faulting application name = dwm.exe; Faulting module name = igdumd64.dll.

4. Run this PowerShell command on the affected host to extract Event 1000 details quickly.
```powershell
Get-WinEvent -FilterHashtable @{LogName='Application'; Id=1000; StartTime=(Get-Date).AddHours(-4)} |
	Where-Object { $_.Message -match 'dwm.exe' -and $_.Message -match 'igdumd64.dll' } |
	Select-Object -First 5 TimeCreated, Id, LevelDisplayName, Message
```
- Confirming pattern: at least one Event 1000 shows dwm.exe and igdumd64.dll.

5. Query System log for DWM exit event.
- Exact log location: Event Viewer > Windows Logs > System.
- Required Event ID: 9009.
- Field(s): TimeCreated, Event ID, Message.

6. Run this PowerShell command on the affected host to extract Event 9009 quickly.
```powershell
Get-WinEvent -FilterHashtable @{LogName='System'; Id=9009; StartTime=(Get-Date).AddHours(-4)} |
	Select-Object -First 10 TimeCreated, Id, LevelDisplayName, Message
```
- Confirming pattern: Event 9009 occurs in same symptom window as Event 1000.

7. Query logon/disconnect sequence.
- Exact log location: Event Viewer > Applications and Services Logs > Microsoft > Windows > TerminalServices-LocalSessionManager > Operational.
- Required Event IDs: 21 and 40.
- Field(s): TimeCreated, ID, User, Session ID.

8. Run this PowerShell command on the affected host for Event 21/40 sequence.
```powershell
Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-TerminalServices-LocalSessionManager/Operational'; Id=21,40; StartTime=(Get-Date).AddHours(-4)} |
	Select-Object -First 20 TimeCreated, Id, Message
```
- Confirming pattern: Event 21 (logon success) followed shortly by Event 40 (disconnect).

### C. Healthy baseline comparison on POOL-FIN-02 (required)
9. On one control host in POOL-FIN-02, query System log for healthy DWM startup.
- Exact log location: Event Viewer > Windows Logs > System.
- Required baseline Event ID: 9011.
- Field(s): TimeCreated, Event ID, Message.

10. Run this PowerShell command on the control host.
```powershell
Get-WinEvent -FilterHashtable @{LogName='System'; Id=9011; StartTime=(Get-Date).AddHours(-4)} |
	Select-Object -First 10 TimeCreated, Id, LevelDisplayName, Message
```
- Required baseline confirmation: Event 9011 present on POOL-FIN-02 and no matching Application Event 1000 containing dwm.exe + igdumd64.dll in same window.

### D. Issue confirmation decision
11. Confirm this incident only if all four conditions are true.
- Condition 1: Application Event 1000 exists on affected host with Faulting module igdumd64.dll.
- Condition 2: System Event 9009 exists on affected host in same window.
- Condition 3: LocalSessionManager shows 21 then 40 pattern on affected host.
- Condition 4: POOL-FIN-02 control host shows System Event 9011 healthy baseline and no matching Event 1000 crash signature.

## Resolution
Execute in order. Target execution time: 5 to 10 minutes for containment and rollback-to-stable path.

0. Set command variables in Azure PowerShell.
```powershell
$rg = "<AVD_RESOURCE_GROUP>"
$hpFin01 = "POOL-FIN-01"
$hpFin02 = "POOL-FIN-02"
```
Expected result: Command scope is set for all following actions.

1. Open `Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts` and turn **Allow new sessions** to **No** for impacted hosts.
Expected result: New users stop landing on unstable FIN-01 hosts.

2. Run command to enforce the same setting quickly for all FIN-01 hosts.
```powershell
$fin01Hosts = Get-AzWvdSessionHost -ResourceGroupName $rg -HostPoolName $hpFin01
foreach ($h in $fin01Hosts) {
	$name = ($h.Name -split "/")[-1]
	Update-AzWvdSessionHost -ResourceGroupName $rg -HostPoolName $hpFin01 -Name $name -AllowNewSession:$false | Out-Null
}
```
Expected result: All FIN-01 hosts are blocked for new sessions.

3. Open `Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-02 > Session hosts` and confirm **Allow new sessions** is **Yes**.
Expected result: New user sessions can be routed to healthy FIN-02 hosts.

4. Run command to verify FIN-02 is open for intake.
```powershell
Get-AzWvdSessionHost -ResourceGroupName $rg -HostPoolName $hpFin02 |
	Select-Object Name,AllowNewSession,Status
```
Expected result: FIN-02 hosts show `AllowNewSession=True` and healthy status.

5. Open `Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Properties > Session host configuration` and record the current image/template value.
Expected result: Current FIN-01 deployment template is captured for audit.

6. Run command to capture VM template values from FIN-01 and FIN-02.
```powershell
$fin01Template = (Get-AzWvdHostPool -ResourceGroupName $rg -Name $hpFin01).VMTemplate
$fin02Template = (Get-AzWvdHostPool -ResourceGroupName $rg -Name $hpFin02).VMTemplate
$fin01Template | Out-File .\fin01-template.json
$fin02Template | Out-File .\fin02-template.json
```
Expected result: Known-good and affected template values are saved locally.

7. Open `Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Properties > Session host configuration` and set image/template to the known-good FIN-02 value.
Expected result: New/replacement FIN-01 hosts will use stable baseline.

8. Run command to set FIN-01 VM template to FIN-02 template.
```powershell
Update-AzWvdHostPool -ResourceGroupName $rg -Name $hpFin01 -VMTemplate $fin02Template | Out-Null
```
Expected result: FIN-01 host pool template now matches known-good configuration.

9. Open `Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts > <canary host> > Remove` and remove one drained impacted host.
Expected result: One impacted canary host is removed from service.

10. Recreate one canary host using your approved host deployment runbook/job for FIN-01.
Expected result: Canary host is rebuilt from stable template and registers successfully.

11. Open `Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts > <new canary host>` and set **Allow new sessions** to **Yes**.
Expected result: Only canary host accepts controlled validation traffic.

## Verification
1. Open `Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts` and confirm canary/new hosts show **Status = Available**.
Pass condition: At least one rebuilt FIN-01 host is available and accepting sessions.

2. Run command to verify host state and session intake flags.
```powershell
Get-AzWvdSessionHost -ResourceGroupName $rg -HostPoolName $hpFin01 |
	Select-Object Name,Status,AllowNewSession,Session
```
Pass condition: Rebuilt host has `Status=Available` and `AllowNewSession=True`.

3. On canary host, open `Event Viewer > Windows Logs > Application` and filter `Event ID = 1000` in post-fix window.
Pass condition: No new Event 1000 with `dwm.exe` and `igdumd64.dll`.

4. Run command on canary host to confirm no new crash signature.
```powershell
Get-WinEvent -FilterHashtable @{LogName='Application'; Id=1000; StartTime=(Get-Date).AddMinutes(-30)} |
	Where-Object { $_.Message -match 'dwm.exe' -and $_.Message -match 'igdumd64.dll' } |
	Select-Object TimeCreated, Id, Message
```
Pass condition: Command returns no rows.

5. On canary host, open `Event Viewer > Windows Logs > System` and filter `Event ID = 9009` in post-fix window.
Pass condition: No new DWM exit event after remediation.

6. On canary host, open `Event Viewer > Applications and Services Logs > Microsoft > Windows > TerminalServices-LocalSessionManager > Operational` and filter `Event IDs = 21,40`.
Pass condition: No repeated immediate `21 -> 40` pattern for test sessions.

7. On one POOL-FIN-02 control host, open `Event Viewer > Windows Logs > System` and filter `Event ID = 9011`.
Pass condition: Healthy baseline still present on control pool.

## Rollback
If behavior worsens or crash signature recurs after rollout, execute immediately.

1. Open `Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts` and set **Allow new sessions = No** on all remediated/canary hosts.
Expected result: New users stop landing on hosts showing recurrence.

2. Run command to force-close intake on FIN-01 quickly.
```powershell
Get-AzWvdSessionHost -ResourceGroupName $rg -HostPoolName $hpFin01 |
	ForEach-Object {
		$name = ($_.Name -split "/")[-1]
		Update-AzWvdSessionHost -ResourceGroupName $rg -HostPoolName $hpFin01 -Name $name -AllowNewSession:$false | Out-Null
	}
```
Expected result: All FIN-01 hosts are closed for new sessions.

3. Open `Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-02 > Session hosts` and confirm **Allow new sessions = Yes**.
Expected result: All new connections route through unaffected pool.

4. Open `Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Properties > Session host configuration` and restore last known-good image/template.
Expected result: Future FIN-01 replacements deploy from stable baseline.

5. Run command to restore known-good template saved in `.\fin02-template.json`.
```powershell
$knownGoodTemplate = Get-Content .\fin02-template.json -Raw
Update-AzWvdHostPool -ResourceGroupName $rg -Name $hpFin01 -VMTemplate $knownGoodTemplate | Out-Null
```
Expected result: FIN-01 template is reverted immediately.

6. Remove rebuilt hosts that show recurrence from `Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts` and redeploy from reverted template.
Expected result: Unstable rebuilt hosts are replaced by stable hosts.

7. Capture rollback evidence from exact log paths.
- `Event Viewer > Windows Logs > Application` (Event 1000 with dwm.exe/igdumd64.dll)
- `Event Viewer > Windows Logs > System` (Event 9009)
- `Event Viewer > Applications and Services Logs > Microsoft > Windows > TerminalServices-LocalSessionManager > Operational` (Events 21/40)
Expected result: Ticket contains auditable trigger, action, and proof.

## Preventive
Implement all controls below to prevent recurrence.

1. Hard release gate for AVD sign-in stability. [Owner: release engineer] [Timing: before deployment] [Automated] [REQUIRES: CI test runner + event collection]
- Pass if 0 occurrences of Application Event 1000 with `dwm.exe` + `igdumd64.dll` and 0 System Event 9009 during scripted login/reconnect test set.
- Fail action: block artifact promotion and open defect ticket to image owner with exported event evidence.

2. Mandatory canary promotion with comparator check. [Owner: change manager] [Timing: during deployment] [Manual now; automateable]
- Pass if canary ring has 0 `21 -> 40` immediate disconnect cascades and no Event 9009 rate above control pool in same window.
- Fail action: stop rollout at current ring, set `Allow new sessions = No` on canary hosts, route intake to POOL-FIN-02.
- Automation note: compute event-rate delta from canary vs control and auto-block promotion on threshold breach. [REQUIRES: rollout gate job]

3. Graphics driver governance in image pipeline. [Owner: image owner] [Timing: before deployment] [Automated]
- Pass if image manifest driver version matches approved allow-list exactly; fail if drift detected in build manifest.
- Signal: approved version hash/version string equals manifest value; mismatch count must be 0.
- Fail action: fail build and require approved driver baseline re-apply before rebuild. [REQUIRES: driver allow-list repository]

4. Signature-based in-flight alert correlation. [Owner: DWP engineer] [Timing: during deployment] [Automated] [REQUIRES: SIEM/event rule]
- Trigger if same host shows Event 21 then Event 1000 (`dwm.exe` + `igdumd64.dll`) and Event 9009 or Event 40 within 5 minutes.
- Pass signal: zero correlated alerts during rollout window; fail signal: one or more correlated alerts.
- Fail action: freeze rollout immediately and execute rollback section from this KB.

5. Change-management dependency gate. [Owner: change manager] [Timing: before deployment] [Manual now; automateable]
- Pass only if change record includes rollback image reference, canary plan, and control-pool parity checklist attachment.
- Fail action: reject CAB approval and return change to release engineer for completion.
- Automation note: enforce required fields/attachments in change form workflow. [REQUIRES: ITSM workflow rule]

6. Pre-deployment smoke test gate (missing layer). [Owner: DWP engineer] [Timing: before deployment] [Automated preferred]
- Pass if 2 test users complete login on test pool with zero Event 1000 (`dwm.exe`/`igdumd64.dll`) and zero Event 9009 in 15 minutes.
- Fail action: cancel rollout start and keep production pool unchanged.
- Automation note: scheduled pre-release script runs login probes and event queries. [REQUIRES: test pool + probe account]

7. Post-deployment validation hold point (missing layer). [Owner: service desk lead] [Timing: after deployment] [Manual]
- Pass if first 30 minutes show no new black-screen tickets and event queries show zero new signature events on remediated hosts.
- Signal: incident count = 0 for symptom tag; Event 1000 signature count = 0.
- Fail action: keep change in "monitoring" state and invoke rollback threshold review.

8. Explicit rollback trigger threshold (missing layer). [Owner: DWP engineer] [Timing: during deployment] [Manual now; automateable]
- Trigger rollback if any one host records 2+ matching Event 1000 (`dwm.exe` + `igdumd64.dll`) within 10 minutes, or 3+ users report black screen in 15 minutes.
- Pass signal: thresholds not met; fail signal: threshold met/exceeded.
- Fail action: execute rollback steps 1-7 immediately and document trigger timestamp.

9. Knowledge/update control (missing layer). [Owner: image owner] [Timing: after deployment] [Manual]
- Pass if runbook, L1 KB, and L2/L3 KB are updated within 2 business days and linked in change closure record.
- Signal: document version/date updated and ticket link present.
- Fail action: do not close problem record until documentation evidence is attached.

## Related
- Day 4 analysis: AVD-BlackScreen-POOL-FIN-01-Analysis.md
- Day 4 RCA: RCA-AVD-BlackScreen-POOL-FIN-01-2024-03-15.md
- Day 5 runbook: Runbook-AVD-BlackScreen-POOL-FIN-01.md
- Day 5 L1 article: L1-SelfService-Login-BlackScreen.md
- Similar symptom family: login succeeds (Event 21) but desktop never becomes stable due to post-auth rendering crash signature.
