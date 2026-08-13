# FAULT-B Incident Analysis - Finance Shared Drives Unavailable

Date: 2026-08-13  
Exercise: 2  
Analyst role: DWP Engineer

## Scope Facts
- Symptom: Finance team cannot access shared drives.
- Impact: 45 users (DESKTOP-FB* devices, OU=Finance).
- Evidence source: Intune Management Extension log and System log.
- Key change: 2024-03-14 23:30 drive mapping moved from GPO user logon script to Intune PowerShell script running as SYSTEM.

## Evidence Summary
Intune Management Extension:
- 08:00:01 ScriptRunner: Executing Map-FinBridgeDrives.ps1
- 08:00:02 Script context: SYSTEM account
- 08:00:03 Warning: UNC path \\finbridge-fs01\Finance not accessible from SYSTEM context at execution time
- 08:00:03 Error: script failed, exit code 1, network name cannot be found
- 08:00:04 No retry configured

System log (DESKTOP-FB041):
- 08:00:05 Event 7036: Workstation service entered running state
- 08:00:06 Event 1500: Group Policy processed successfully (GP healthy)
- 08:00:07 Event 98: could not map drive letter S:

## Cause Assessment
Most likely and evidence-supported cause:
- Drive mapping script executed in SYSTEM context after migration, but the script design assumed USER context.
- UNC access and user-mapped credentials were unavailable at execution timing/context, causing script failure and no mapped drive creation.

## Why This Fits the Evidence
1. Script explicitly ran as SYSTEM, not USER.
2. Failure text explicitly states UNC path not accessible in SYSTEM context.
3. GP success event confirms this is not a Group Policy processing failure.
4. Immediate NTFS mapping warning for S: aligns with failed mapping script.
5. No retry configured means a single startup failure created persistent user impact.

## Resolution Steps Applied / Recommended
1. Revert drive mapping execution context to USER logon context, or redesign Intune delivery to run in user context.
2. Update script to validate dependency readiness before mapping:
- Confirm Workstation service state.
- Confirm path reachability for \\finbridge-fs01\Finance.
- Retry mapping with bounded backoff if first attempt fails.
3. Ensure drive mapping uses user security context and avoids SYSTEM-only execution for user drive letters.
4. Add logging of context, network check result, and mapping result per user session.
5. Force script re-run for affected devices/users after fix deployment.

## Verification Steps
1. On pilot and affected endpoints, confirm script runs in USER context.
2. Confirm S: drive appears for Finance users after sign-in.
3. Confirm no recurrence of ScriptRunner exit code 1 for mapping script.
4. Confirm no NTFS Event 98 mapping failure for S: in post-fix window.

## Preventive Improvements
1. Migration gate: any script moved from GPO USER to Intune SYSTEM must include context compatibility review.
2. Add pre-prod test case: user-drive mapping validation on representative Finance endpoint.
3. Add mandatory retry logic for startup-dependent mapping tasks.
4. Add change checklist item for context-sensitive scripts (identity, network, UNC, token availability).
