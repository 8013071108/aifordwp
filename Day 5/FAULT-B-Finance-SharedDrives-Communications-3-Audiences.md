# FAULT-B Communications - Three Audiences

## Audience 1 - Non-technical executive
Access and data are safe. Finance shared drives were unavailable because a login setup task was moved during migration and ran in the wrong account context, so it could not create users' drive links. We corrected the execution method and restored drive mapping for affected users. You do not need to take any action.

## Audience 2 - Affected end-user team
Your files are safe, and this issue was caused by a migration change where the shared-drive setup ran in the wrong sign-in context and failed to create the S: drive link for Finance users. We corrected the setup method and restored drive mapping. If your drive is still missing, sign out and sign back in, then contact the DWP Service Desk.

## Audience 3 - Engineer-to-engineer internal note
Root cause:
- Execution-context regression from migration change at 2024-03-14 23:30: drive mapping moved from GPO USER logon script to Intune PowerShell SYSTEM context.
- Map-FinBridgeDrives.ps1 not adapted for SYSTEM context/timing.

Evidence:
- IME log 08:00:02 confirms SYSTEM context.
- 08:00:03 warning/error: \\finbridge-fs01\Finance not accessible from SYSTEM context; exit code 1; no retry.
- System log DESKTOP-FB041: Event 1500 GP success at 08:00:06 (not a GP issue), Event 98 at 08:00:07 mapping S: failed.

Action taken:
- Corrected execution method to user-context mapping path and updated script handling for network dependency timing.
- Redeployed mapping logic to affected Finance estate.

Config detail:
- Affected scope: 45 users, DESKTOP-FB* in OU=Finance.
- Target path: \\finbridge-fs01\Finance.
- Failing mode: SYSTEM execution with no retry.

Verification:
- Post-change validation confirms S: drive creation and access for affected users.
- No ongoing ScriptRunner map failure pattern in monitored window.

Preventive:
- Mandatory context-compatibility check for any USER->SYSTEM script migration.
- Add pre-prod user-logon drive-mapping validation and retry requirement for network-dependent scripts.
