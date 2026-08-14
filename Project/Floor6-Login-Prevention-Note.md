# Floor 6 Login Prevention Note

## Control Name
Post-Deployment Login Health Validation Gate

## Purpose
Prevent a Friday Intune application deployment from remaining in active scope into Monday business hours when Floor 6 users show login failure, slow login, or related desktop-state issues.

## Owner
DWP Endpoint Engineering (Intune) Duty Engineer

## When It Runs
- Trigger: Any Friday afternoon Intune app deployment to a floor-level business cohort.
- Execution window: Before 08:30 Monday local time (to confirm exact cut-off in local CAB/operations standard).

## Scope
- Target cohort of the Friday deployment (for this incident pattern: Floor 6 Legal).
- Any emergency exclusion group or rollback cohort created for containment.
- Validation sample: at least 1 previously affected user and at least 1 unaffected user from the same cohort.

## Validation Checks
1. Verify current app assignment state for the deployed app and confirm whether affected devices are still targeted.
2. Verify emergency exclusion or rollback cohort membership for known affected devices.
3. Validate sign-in outcome for the two-user sample (affected and unaffected):
- Can user reach desktop successfully (yes/no).
- Is sign-in duration still reported as unusually slow (yes/no).
4. Validate desktop shortcut state for the same two-user sample (present/missing/to confirm).
5. Check whether new Floor 6 incidents of login failure/slow login continue during the validation window.

## Pass Criteria
- 0 known affected devices remain unintentionally targeted by the active deployment assignment.
- The sampled previously affected user can sign in successfully.
- The sampled previously affected user does not report ongoing extreme sign-in delay.
- No new Floor 6 login-failure or slow-login incidents are reported during the validation window.
- Shortcut state in the sample is stable or any uncertainty is explicitly recorded as to confirm.

## Fail Criteria
- 1 or more known affected devices remain in active target scope when containment says they should be excluded or rolled back.
- The sampled previously affected user still cannot sign in.
- The sampled previously affected user still reports extreme sign-in delay.
- New Floor 6 login-failure or slow-login incidents continue during the validation window.

## Required Action if Failed
- Immediately hold further progression of the active app deployment for the affected cohort.
- Keep or place affected devices in emergency exclusion and/or previous known-good rollback path per the rollback runbook.
- Trigger Intune sync on sampled affected endpoints and collect endpoint evidence.
- Escalate to Incident Manager and DWP Endpoint Engineering lead, and keep the incident open.
- Do not return cohort to normal active deployment scope until all pass criteria are met.

## Evidence Produced
- App assignment evidence (export/screenshot) showing active scope and exclusion/rollback state.
- Affected-device list with exclusion/rollback membership status.
- Validation log for the two-user sample:
- Sign-in success/failure.
- Reported sign-in duration status.
- Shortcut state.
- Incident update record for the validation window showing whether new related incidents occurred.
- Endpoint evidence package references (IME logs/event logs) where collected, to confirm availability per device.

## How This Would Have Prevented the Floor 6 Login Incident
This gate would have forced a mandatory pre-business validation checkpoint before Monday start-of-day. For this incident pattern, it would have required explicit proof that sign-in behavior was stable in the deployment cohort, and it would have blocked continued active targeting when failure criteria were present. That would have reduced or prevented Monday-morning broad user impact by keeping affected devices in containment until login health was verified. The exact technical root cause remains to confirm in the RCA, so this control is designed as an operational stop/go safeguard rather than a root-cause-specific fix.
