# Root Cause Analysis (RCA) - FAULT-B Finance Shared Drives Unavailable

## Document Control
- Incident date: 2024-03-15
- RCA created: 2026-08-13
- Service: Finance drive mapping (S:)
- Affected users: 45 (OU=Finance, DESKTOP-FB*)
- Incident type: Post-migration access failure

## 1. Executive Summary
Finance users could not access shared drives after migration changes. The mapping script was moved from GPO logon (USER context) to Intune PowerShell (SYSTEM context) without script updates for context handling. The script failed to reach the UNC path in SYSTEM context, exited with code 1, and had no retry, leading to widespread mapping failure.

## 2. Impact
- 45 Finance users unable to access mapped shared drive resources.
- Affected estate: DESKTOP-FB* endpoints in OU=Finance.
- Business effect: finance workflow interruption due to missing shared drive access.

## 3. Timeline
| Time | Event | Evidence |
|------|-------|----------|
| 2024-03-14 23:30 | Change implemented: drive mapping moved from GPO USER script to Intune SYSTEM script | Migration change log |
| 08:00:01 | Map-FinBridgeDrives.ps1 execution started | ScriptRunner Info |
| 08:00:02 | Script context confirmed as SYSTEM | ScriptRunner Info |
| 08:00:03 | UNC path inaccessible in SYSTEM context | ScriptRunner Warning |
| 08:00:03 | Script failed with exit code 1, network name cannot be found | ScriptRunner Error |
| 08:00:04 | No retry configured | ScriptRunner Info |
| 08:00:05 | Workstation service running | Event 7036 |
| 08:00:06 | Group Policy successful | Event 1500 |
| 08:00:07 | Drive S: mapping failed | NTFS Event 98 |

## 4. Supporting Evidence
Intune Management Extension log:
- Script executed as SYSTEM.
- Script warning/error explicitly states UNC path not accessible in that context.
- Exit code 1 and no retry configured.

System log (DESKTOP-FB041):
- Event 7036 confirms service state transition.
- Event 1500 confirms GP processing success, excluding GP as causal factor.
- Event 98 confirms drive-letter mapping failure.

Change log evidence:
- Script execution model changed from USER context to SYSTEM context during migration, without adapting script behavior.

## 5. Root Cause
The root cause was an execution-context mismatch introduced during migration: Map-FinBridgeDrives.ps1 was moved from USER logon execution to SYSTEM execution in Intune, but the script was not updated for SYSTEM limitations and timing. UNC access and user-mapped credentials required for drive mapping were unavailable in that context, causing mapping failure.

## 6. 5 Whys Analysis
1. Why could Finance users not access shared drives?
- Their mapped drive was not created.

2. Why was the mapped drive not created?
- Map-FinBridgeDrives.ps1 failed during execution.

3. Why did the script fail?
- It ran in SYSTEM context and could not access \\finbridge-fs01\Finance at execution time.

4. Why was it running in SYSTEM context?
- Migration changed delivery from GPO USER logon script to Intune PowerShell SYSTEM execution.

5. Why did this change cause outage?
- Context dependency was not validated, and no retry logic existed to recover from first-fail startup timing.

## 7. Resolution
1. Move drive mapping execution back to USER context (or equivalent user-context Intune method).
2. Update script to include dependency checks and retry behavior.
3. Redeploy and force rerun to affected endpoints.
4. Validate S: mapping across affected users.

## 8. Preventive Actions
1. Add migration control: context-compatibility review mandatory for any script moved between execution models.
2. Add release test: verify mapped drive creation under real user sign-in conditions.
3. Require retry strategy for startup network-dependent scripts.
4. Add change-approval checklist item for context-sensitive authentication and UNC dependency.
5. Add monitoring for ScriptRunner failures on critical mapping scripts.

## 9. Validation Criteria
- Script executes in user context for target users.
- S: appears and is accessible for Finance users.
- No ScriptRunner exit code 1 for mapping script in post-fix logs.
- No recurring NTFS Event 98 mapping failures tied to drive S:.
