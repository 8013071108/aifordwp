# Runbook - AVD Black Screen Post Login (POOL-FIN-01)

## Version Header
- Title: Runbook - AVD Black Screen Post Login (POOL-FIN-01)
- Version: 1.0
- Date: 07/08/2026
- Author: Sathishbabu
- Reviewed: self
- Status: draft
- Change: initial version from RCA

## 1. Prerequisites
Use this checklist before running any remediation.

### Access Checklist
- [ ] Azure Portal access to `Azure Virtual Desktop > Host pools > POOL-FIN-01` and `POOL-FIN-02` [ELEVATED]
- [ ] Permission to change host pool assignment/drain mode and session host availability [ELEVATED]
- [ ] Permission to rebuild/reimage session hosts (or permission to execute approved host replacement runbook) [ELEVATED]
- [ ] Local Administrator access on at least one affected session host and one control host [ELEVATED]
- [ ] Permission to view Event Viewer logs on both hosts [ELEVATED]

### Tools Checklist
- [ ] Azure Portal (web)
- [ ] Remote Desktop client to connect to session hosts
- [ ] Event Viewer (`eventvwr.msc`) on session hosts
- [ ] PowerShell (for optional quick log queries)
- [ ] Incident ticketing tool access

### Mandatory End-User / Service Desk Intake Checklist
- [ ] First failure time (local time zone)
- [ ] User UPN(s) and at least one affected username
- [ ] Affected host pool name shown to user (must confirm `POOL-FIN-01`)
- [ ] Exact symptom wording: black screen post-login, whether it clears in ~30 seconds or persists
- [ ] Count/percentage of impacted users and whether `POOL-FIN-02` users are unaffected
- [ ] One screenshot or timestamped user report during active symptom

### Mandatory Technical Inputs Checklist
- [ ] Known-good image reference used by `POOL-FIN-02`
- [ ] Current image reference configured for `POOL-FIN-01`
- [ ] Approved graphics driver baseline/version reference for AVD image governance
- [ ] Change approval for containment and rollback actions [ELEVATED]

## 2. Procedure
1. Open Azure Portal and browse to `Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts`.
Expected result: You can see all POOL-FIN-01 session hosts and their current session counts.

2. Select one host with active black-screen reports and record its hostname in the ticket.
Expected result: One affected host is identified for evidence capture.

3. Open Azure Portal and browse to `Azure Virtual Desktop > Host pools > POOL-FIN-02 > Session hosts`.
Expected result: You can see POOL-FIN-02 session hosts for control comparison.

4. Select one healthy POOL-FIN-02 host and record its hostname in the ticket.
Expected result: One control host is identified for baseline comparison.

5. Connect by RDP to the affected host using an admin account [ELEVATED].
Expected result: You have an interactive admin session on the affected host.

6. Open `Event Viewer > Windows Logs > Application` on the affected host.
Expected result: Application log is visible for filtering.

7. Filter the Application log to `Event ID = 1000` and incident time window.
Expected result: Matching application crash events are listed.

8. Open the latest Event 1000 entry and record `Faulting application name`, `Faulting module name`, and `Exception code`.
Expected result: Crash signature fields are captured in the ticket.

9. Open `Event Viewer > Windows Logs > System` on the affected host.
Expected result: System log is visible for filtering.

10. Filter the System log to `Event ID = 9009` and incident time window.
Expected result: DWM exit events are listed or explicitly absent.

11. Open `Event Viewer > Applications and Services Logs > Microsoft > Windows > TerminalServices-LocalSessionManager > Operational`.
Expected result: LocalSessionManager operational log is visible.

12. Filter this log to `Event IDs = 21, 40` in the incident window.
Expected result: Logon success and disconnect sequence is visible or explicitly absent.

13. Connect by RDP to the control host using an admin account [ELEVATED].
Expected result: You have an interactive admin session on the control host.

14. Open `Event Viewer > Windows Logs > System` on the control host.
Expected result: Control host System log is visible.

15. Filter System log to `Event ID = 9011` in the same time window.
Expected result: Normal DWM start event is confirmed on control host.

16. In Azure Portal, set `Allow new sessions = No` for each impacted POOL-FIN-01 session host [ELEVATED].
Expected result: New user connections stop landing on impacted hosts.

17. In Azure Portal, confirm `Allow new sessions = Yes` on healthy POOL-FIN-02 hosts [ELEVATED].
Expected result: New user sessions can be routed to healthy pool.

18. Send standard impact message to service desk: route new incidents to POOL-FIN-02 path.
Expected result: Frontline routing aligns with containment action.

19. In Azure Portal, capture and store POOL-FIN-01 image reference from host deployment configuration [ELEVATED].
Expected result: Current affected image reference is documented.

20. Capture and store known-good image reference currently used by POOL-FIN-02 [ELEVATED].
Expected result: Rollback target image reference is documented.

21. Update POOL-FIN-01 deployment configuration to the known-good image reference [ELEVATED].
Expected result: Any replacement hosts for POOL-FIN-01 will deploy from stable image.

22. Deallocate one drained POOL-FIN-01 host selected for canary replacement [ELEVATED].
Expected result: Host is removed from active capacity for rebuild.

23. Recreate that host from the updated known-good image configuration using the approved host deployment runbook [ELEVATED].
Expected result: Canary replacement host is created on stable image.

24. Set `Allow new sessions = Yes` on the canary replacement host only [ELEVATED].
Expected result: Only one remediated host is open for controlled validation.

25. Perform one test user sign-in to the canary host.
Expected result: Desktop loads without black screen or immediate disconnect.

26. Re-open `Application` log on canary host and filter for new Event 1000 after test sign-in.
Expected result: No new `dwm.exe` + `igdumd64.dll` crash event appears.

27. Re-open `TerminalServices-LocalSessionManager > Operational` log and confirm no immediate Event 40 after Event 21 for test session.
Expected result: No reconnect/disconnect cascade appears.

28. Repeat host replacement for remaining drained POOL-FIN-01 hosts in small rings [ELEVATED].
Expected result: Pool is restored progressively on stable image.

29. Set `Allow new sessions = Yes` for all remediated POOL-FIN-01 hosts after ring checks pass [ELEVATED].
Expected result: POOL-FIN-01 returns to normal traffic handling.

30. Record restoration timestamp and attach event screenshots/exports to the incident ticket.
Expected result: Ticket is complete with evidence-backed remediation record.

## 3. Verification
1. Open `Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts` and select one remediated host with active sessions.
Expected result: One post-fix host is selected for validation.

2. Connect to the selected host by RDP and sign in with the test user account.
Expected result: Desktop appears with no black screen and no forced reconnect.

3. Open `Event Viewer > Windows Logs > Application` on that host.
Expected result: Application log is available for post-fix filtering.

4. Filter Application log by `Event ID = 1000`, `Time = Last 30 minutes`, and `Task Category = Application Crashing`.
Expected result: No new entry shows `dwm.exe` faulting `igdumd64.dll`.

5. Open `Event Viewer > Windows Logs > System` on the same host.
Expected result: System log is available for post-fix filtering.

6. Filter System log by `Event ID = 9009` and `Time = Last 30 minutes`.
Expected result: No new DWM exit (9009) entries appear after remediation.

7. Open `Event Viewer > Applications and Services Logs > Microsoft > Windows > TerminalServices-LocalSessionManager > Operational`.
Expected result: LocalSessionManager operational log is available.

8. Filter this log by `Event IDs = 21,40` and `Time = Last 30 minutes`.
Expected result: You see normal logon success events (21) without immediate disconnect events (40) for test sessions.

9. Repeat steps 1 to 8 on one second remediated POOL-FIN-01 host.
Expected result: Two hosts pass the same technical checks.

10. Open ticketing console and check for new POOL-FIN-01 black screen incidents since restoration time.
Expected result: No new matching incidents are logged.

11. Update incident ticket with screenshot/export evidence from Application, System, and LocalSessionManager logs.
Expected result: Closure evidence is complete and auditable.

## 4. Rollback
Target execution time: under 3 minutes.

1. Open `Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts` [ELEVATED].
Expected result: You can control connection state for affected hosts.

2. Set `Allow new sessions = No` on every remediated/canary POOL-FIN-01 host showing recurrence [ELEVATED].
Expected result: New users cannot land on unstable hosts.

3. Open `Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-02 > Session hosts` [ELEVATED].
Expected result: Healthy pool host list is visible.

4. Confirm `Allow new sessions = Yes` on healthy POOL-FIN-02 hosts [ELEVATED].
Expected result: New sessions are immediately routed to healthy pool.

5. Open `Azure Portal > Azure Virtual Desktop > Host pools > POOL-FIN-01 > Session hosts` and set impacted hosts to drain mode [ELEVATED].
Expected result: Existing users complete sessions while no new sessions start there.

6. Post service-desk broadcast: "Use POOL-FIN-02 route only until further notice."
Expected result: Frontline routing changes immediately.

7. Capture recurrence proof from one host in `Event Viewer > Windows Logs > Application` with `Event ID 1000` showing `dwm.exe` and `igdumd64.dll`.
Expected result: Rollback trigger evidence is recorded.

8. Record rollback start time and affected hostnames in the incident ticket.
Expected result: Fast rollback is traceable and auditable.

## 5. Notes
- Edge case: If only one host shows the crash signature, still treat as image regression until comparator checks disprove it.
- Edge case: If Event 1000 is absent but users still see black screen, collect fresh logs during symptom window before changing root-cause path.
- Warning: Do not proceed with broad rollout after a single successful test; require canary observation window first.
- Warning: Do not unpause image rollout until driver/version governance controls are confirmed.
- Related incident pattern: AVD black screen where Event 1000 (dwm.exe -> igdumd64.dll), Event 9009, and Event 40 follow Event 21 within short interval.
- Related control from RCA: enforce canary promotion gates and block unapproved graphics driver drift in image pipeline.
