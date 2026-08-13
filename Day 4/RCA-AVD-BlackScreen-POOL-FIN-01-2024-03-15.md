# Root Cause Analysis (RCA) - AVD Black Screen Post Login (POOL-FIN-01)

## Document Control
- Incident date: 2024-03-15
- RCA created: 2026-08-13
- Service: Azure Virtual Desktop (AVD)
- Affected pool: POOL-FIN-01
- Control pool: POOL-FIN-02 (unaffected)
- Incident status: Resolved
- Service restoration time: 10:00 AM

## 1. Executive Summary
On 2024-03-15, users connecting to POOL-FIN-01 experienced a black screen immediately after login. Symptoms began around 07:00 and affected about 40% of users in that pool. POOL-FIN-02 remained fully healthy.

Event log evidence from an affected session host showed repeated Desktop Window Manager (dwm.exe) crashes in igdumd64.dll, followed by session disconnects. The issue aligned with an overnight image update applied only to POOL-FIN-01 at 02:00.

The remediation was applied and service was restored by 10:00 AM. Post-fix verification confirmed users could log in to POOL-FIN-01 hosts without black screen symptoms.

## 2. Impact Assessment
- User impact: Approximately 40% of users routed to POOL-FIN-01.
- Symptom pattern: Blank screen after sign-in, clearing after about 30 seconds for some users and persisting for others.
- Business impact: Delayed or failed access to virtual desktops for impacted finance users.
- Scope boundary: Limited to POOL-FIN-01; POOL-FIN-02 had no reported issues.

## 3. Scope Facts and Change Correlation
- Symptom onset: Around 07:00.
- Infrastructure change: Overnight image update to POOL-FIN-01 at 02:00.
- Non-affected comparator: POOL-FIN-02 did not receive the update and remained stable.
- Host reboot evidence after image change: Kernel-General Event 1 reported boot at 02:03:11.

Conclusion from scope boundary: any credible top cause must be image-contained to explain why only POOL-FIN-01 failed.

## 4. Supporting Evidence

### 4.1 Affected Host Evidence (SHFIN-01-A)
Incident window: 07:00-07:30

- 07:02:10 - TerminalServices-LocalSessionManager Event 21
  - Session logon succeeded for FINBRIDGE\\mlopez (Session 3)
- 07:02:14 - Kernel-General Event 1
  - Boot time 02:03:11 (host restarted after overnight image update)
- 07:02:16 - Application Error Event 1000 (Error)
  - Faulting app: dwm.exe (10.0.22621.2861)
  - Faulting module: igdumd64.dll (31.0.101.4146)
  - Exception code: 0xc0000005
- 07:02:17 - TerminalServices-LocalSessionManager Event 40
  - Session disconnected (FINBRIDGE\\mlopez)
- 07:02:18 - Desktop Window Manager Event 9009 (Error)
  - DWM exited with code 0x40010004
- 07:02:44 - TerminalServices-LocalSessionManager Event 21
  - Reconnect logon succeeded
- 07:02:46 - Application Error Event 1000 (Error)
  - Repeat dwm.exe crash in igdumd64.dll
- 07:02:47 - TerminalServices-LocalSessionManager Event 40
  - Session disconnected
- 07:03:01 - Desktop Window Manager Event 9009 (Error)
  - DWM exited again
- 07:03:10 - TerminalServices-LocalSessionManager Event 21
  - Second reconnect logon succeeded
- 07:08:22 - TerminalServices-LocalSessionManager Event 21
  - Session logon succeeded for FINBRIDGE\\akapoor
- 07:08:24 - Application Error Event 1000 (Error)
  - Repeat dwm.exe crash in igdumd64.dll

### 4.2 Control Evidence (SHFIN-02-A, POOL-FIN-02)
- 07:01:44 - TerminalServices-LocalSessionManager Event 21
  - Session logon succeeded
- 07:01:46 - Desktop Window Manager Event 9011 (Information)
  - DWM started successfully
- No Application Error Event 1000 for dwm.exe in the same window.

### 4.3 Evidence Interpretation
- The crash signature is consistent and repeatable on impacted hosts: dwm.exe -> igdumd64.dll -> access violation.
- Disconnects occur immediately after DWM failures.
- Comparator pool behavior is normal under same user environment but different image state.

## 5. Incident Timeline
| Time | Event | Evidence / Notes |
|------|-------|------------------|
| 02:00 | Image update applied to POOL-FIN-01 | Change record / scope fact |
| 02:03:11 | Host rebooted after update | Kernel-General Event 1 (logged at 07:02:14) |
| ~07:00 | User impact begins | Scope fact |
| 07:02:10 | User logon succeeds | Event 21 on SHFIN-01-A |
| 07:02:16 | First observed DWM crash | Event 1000 (dwm.exe fault in igdumd64.dll) |
| 07:02:17 | Session disconnect | Event 40 |
| 07:02:18 | DWM exits with error | Event 9009 |
| 07:02:44-07:03:10 | Reconnect attempts and repeated failure cycle | Event 21, 1000, 40, 9009 |
| 07:08:24 | Same crash pattern on second user | Event 1000 for FINBRIDGE\\akapoor session window |
| 10:00 | Remediation completed, issue resolved | Operations update |
| After 10:00 | Verification passed | Users logging in to POOL-FIN-01 with no reported issues |

## 6. Hypothesis Elimination Summary
1. Shell/Explorer launch failure: Contradicted by direct DWM crash evidence.
2. Logon script hang: Contradicted by immediate crash/disconnect sequence post successful logon.
3. FSLogix misconfiguration: Neutral from provided dataset (no FSLogix-specific events in evidence window).
4. Display driver/GPU stack issue: Supported by repeated Event 1000 dwm.exe crashes in igdumd64.dll and DWM exits.
5. Group Policy delay: Contradicted by pool comparator and crash signature.

Surviving hypothesis after elimination: display driver/GPU stack regression introduced by updated POOL-FIN-01 image.

## 7. Root Cause Statement
The incident was caused by a regression in the updated POOL-FIN-01 host image that introduced an unstable graphics stack component, resulting in repeated dwm.exe crashes in igdumd64.dll during user session initialization. This caused black screen behavior and repeated session disconnects for a subset of users.

## 8. 5 Whys Analysis
1. Why did users see a black screen after login?
- Because Desktop Window Manager (dwm.exe) crashed during session initialization.

2. Why did dwm.exe crash?
- Because the graphics module igdumd64.dll faulted with access violation (0xc0000005), terminating DWM.

3. Why was the faulty graphics module present on impacted hosts?
- Because the overnight image update for POOL-FIN-01 introduced or retained an unstable display driver stack version.

4. Why did this reach production hosts?
- Because pre-production validation did not include a sufficient AVD login graphics stability gate that would detect repeated DWM crash signatures under representative reconnect scenarios.

5. Why was the issue limited to one pool and not caught by pool-level comparison sooner?
- Because rollout occurred on POOL-FIN-01 only without a mandatory canary promotion gate and telemetry-based pass/fail check against a control pool before full user exposure.

## 9. Resolution Applied
- Contained impact by reducing exposure to affected pool and prioritizing healthy pool where possible.
- Halted further rollout of the updated image.
- Applied rollback/corrective image path to remove exposure to unstable graphics component.
- Restored service by 10:00 AM.
- Verified successful user logins on POOL-FIN-01 with no further black screen reports.

## 10. Preventive and Corrective Actions

### 10.1 Immediate Corrective Actions (Completed)
1. Keep POOL-FIN-01 on known-good image baseline until fixed image is validated.
2. Preserve incident evidence (event exports, image and driver versions) in change records.
3. Maintain rollback runbook for rapid reversion if crash signature recurs.

### 10.2 Preventive Actions (Planned)
1. Add image-release quality gate for AVD session stability.
   - Must fail build if Event 1000 shows dwm.exe faulting in graphics modules during test logins.
2. Implement canary rollout policy.
   - Deploy to small host ring first; hold promotion until peak login window passes cleanly.
3. Add automated detection and alerting.
   - Correlate Event 21 followed by Event 1000 (dwm.exe/igdumd64.dll), Event 9009, and Event 40 within short interval.
4. Enforce driver version governance.
   - Pin approved graphics driver version in image pipeline and block unapproved drift.
5. Require control-pool comparator check before broad rollout.
   - Promotion only if updated pool metrics match control pool within defined error budget.

### 10.3 Validation Criteria for Future Image Promotions
1. Zero critical DWM crash events during scripted login/reconnect testing.
2. No abnormal post-logon disconnect spike.
3. Login-to-desktop readiness within SLA percentiles.
4. No materially worse user experience than control pool over one peak usage window.

## 11. Residual Risk
- If image pipeline allows unpinned driver updates, similar regressions may recur.
- If canary telemetry thresholds are too lenient, early warning may be missed.

## 12. Closure Statement
Incident closed as resolved. Service recovery was confirmed at 10:00 AM with successful user login validation on POOL-FIN-01 and no ongoing issue reports.
