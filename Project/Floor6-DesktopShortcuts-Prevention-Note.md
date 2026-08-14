# Floor 6 Desktop Shortcuts Prevention Note

## Control Name
Post-Migration User Profile and Shortcut Validation Control

## Purpose
Prevent a desktop-shortcut visibility incident from reaching Monday business hours after Windows 11 migration, Intune enrolment, and Friday app deployment changes.

## Owner
DWP Endpoint Engineering (Windows and Intune) Duty Engineer

## When It Runs
- After Friday change activity affecting the cohort (Windows 11 migration wave completion, Intune configuration change, OneDrive Known Folder Move state change, or app deployment).
- Must complete before 08:30 Monday local time (to confirm exact operational cut-off).

## Scope
- Floor 6 Legal cohort targeted by the recent migration/enrolment/change window.
- Validation sample:
- At least 1 reported affected user (if available).
- At least 1 unaffected user from the same cohort.
- Checks cover desktop path/profile state, OneDrive Known Folder Move state, Intune configuration state, and deployment/shortcut-script impact for in-scope devices.

## Validation Checks
1. Confirm desktop path and profile state on sampled devices and compare affected vs unaffected user state.
2. Confirm OneDrive Known Folder Move desktop sync state on sampled devices (enabled/disabled/status) and note mismatches.
3. Confirm Intune configuration profile application state and recent check-in status on sampled devices.
4. Confirm whether the Friday app deployment or related script modified, recreated, or removed desktop shortcuts (to confirm from deployment/script evidence).
5. Confirm whether shortcut files are present in expected desktop locations on sampled devices and whether visibility differs from file presence.

## Pass Criteria
- 100% of sampled devices have completed evidence for all five validation checks.
- 0 unexplained mismatch between desktop visibility and underlying shortcut file presence in the sample.
- 0 unresolved Intune/OneDrive/profile state anomaly linked to missing shortcut symptom in the sample.
- 0 unresolved deployment/script action that could alter shortcut state without an approved expectation.
- Any unknowns are resolved; no required item remains to confirm before Monday start-of-day.

## Fail Criteria
- Any sampled device is missing required evidence for one or more validation checks.
- Any sampled user still shows missing desktop shortcuts with no confirmed and accepted explanation.
- Any unresolved mismatch exists between desktop path/profile/OneDrive/Intune/deployment evidence.
- Any required item remains to confirm at go/no-go time.

## Required Action if Failed
- Hold progression of the related rollout/change for the Floor 6 cohort.
- Keep affected devices/users in containment path and do not declare normal state.
- Execute targeted remediation based on the failed check category (profile/desktop path, OneDrive KFM, Intune configuration, or deployment script/app assignment).
- Re-run this control after remediation and require full pass criteria before returning cohort to normal rollout status.
- Keep incident communication active and escalate to Incident Manager if failure remains unresolved.

## Evidence Produced
- Sample validation worksheet with affected/unaffected user/device identifiers and timestamps.
- Desktop path and profile-state outputs/screenshots for sampled devices.
- OneDrive KFM state evidence for sampled devices.
- Intune configuration and check-in status evidence for sampled devices.
- Deployment/app-assignment/script evidence showing whether shortcut state was modified (or to confirm if not yet proven).
- Shortcut presence/visibility evidence from sampled devices.
- Final gate decision record: pass/fail, unresolved items, and remediation status.

## How This Would Have Prevented the Floor 6 Desktop Shortcut Incident
This control would have required a mandatory pre-business validation of profile pathing, OneDrive desktop behavior, Intune state, and deployment/script effects before Monday usage. If any shortcut-state risk remained unresolved, the cohort would have stayed in containment and remediation instead of entering normal business start. The RCA does not yet verify whether the symptom was deletion, hiding, redirection, or recreation failure, so this control is intentionally evidence-led and blocks go-live when that distinction is still to confirm.
