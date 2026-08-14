Title: Missing Desktop Shortcuts Investigation Guide
Version: 1.0
Date: 14/08/2026
Status: Draft

## Background
A Floor 6 Legal user reported missing desktop shortcuts after recent Windows 11 migration and Intune enrolment. A Friday document management app rollout is a related change to inspect, but not a confirmed cause.

## Symptoms
- User reports desktop shortcuts are missing.
- At least one affected user confirmed.
- User productivity impact due to missing quick access.

## Scope
- Department: Floor 6 Legal.
- Known user population: 45.
- Known affected count: 1 confirmed; wider impact to confirm.

## Verified Root Cause
To confirm.

Current evidence does not prove whether the issue is:
- Deleted shortcuts
- Hidden shortcuts
- Redirected desktop
- Profile loading issue
- Shortcut recreation failure

## Detection
Read-only actions:
1. Confirm user report details and first occurrence timing.
2. Correlate timing with migration, enrolment, and Friday app rollout.
3. Check whether issue is single-user or multi-user.

Expected findings:
- Incident pattern is confirmed and time-bounded.

## Evidence Collection
Read-only actions:
1. OneDrive Known Folder Move checks: confirm desktop sync state and recent behavior.
2. User profile checks: confirm profile state and sign-in behavior on affected vs unaffected user.
3. Desktop folder validation: confirm whether shortcut files exist and whether desktop view matches file presence.
4. Intune policy checks: review configuration profile impact on desktop/user experience.
5. App deployment checks: review whether Friday deployment or related script changed shortcut state.

Exact paths and locations reviewed:
- User desktop folder path: to confirm from runbook.
- OneDrive desktop path/state location: to confirm from runbook.
- Intune configuration location/path: to confirm from runbook.
- Deployment/script location/path: to confirm from runbook.
- Event/log locations referenced by runbook: to confirm.

PowerShell checks used in runbook:
- To confirm (runbook file not available in provided sources).

## Technical Resolution
Change-making actions:
1. If deleted: restore/recreate shortcuts.
Expected result: expected shortcuts return and open correctly.
2. If hidden: restore visibility.
Expected result: shortcuts are visible without recreation.
3. If redirected desktop: correct/align desktop path behavior.
Expected result: desktop view matches expected location.
4. If profile loading issue: remediate profile state per approved process.
Expected result: shortcuts load normally after sign-in.
5. If recreation failure: fix deployment/recreation logic.
Expected result: shortcuts are recreated consistently.

## Verification
Read-only actions:
- Recheck shortcut visibility for affected user.
- Confirm file presence and open behavior.
- Compare with unaffected user baseline.
- Confirm issue no longer reproduces.

## Rollback
Change-making actions:
- Revert last shortcut-impacting change if remediation worsens user state.
- Restore last known-good desktop behavior per approved change control.

## Preventive Controls
- Validate profile, desktop path, and OneDrive behavior before/after migration.
- Validate Intune configuration and app deployment shortcut impact in pilot users before wider rollout.
- Require evidence capture at first report to distinguish deletion vs visibility/path issues.

## Escalation Criteria
Escalate when:
- Multiple users report missing shortcuts.
- Evidence cannot distinguish deletion/hidden/redirected/profile/recreation cases.
- Issue persists after first remediation.
- Change impact from rollout/configuration is suspected but unproven.
