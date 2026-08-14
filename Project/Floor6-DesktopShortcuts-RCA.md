# Floor 6 Desktop Shortcuts RCA

## Incident Summary
A Floor 6 Legal user reported that desktop shortcuts disappeared after recent Windows 11 migration and Intune enrolment activities. The report indicates a change in the user experience, but the prompt does not provide evidence of actual file loss.

## Business Impact
- Affected area: Floor 6 Legal.
- Known population: 45 users.
- Confirmed impact: 1 user reported missing desktop shortcuts.
- Business urgency: Medium to high, because missing shortcuts can slow work and reduce productivity.
- Actual data loss: to confirm.

## Timeline of Events
- Floor 6 Legal was recently migrated to Windows 11 and enrolled into Intune.
- A new document management app was rolled out to the floor on Friday afternoon.
- After those changes, one user reported that desktop shortcuts vanished.
- Exact timestamps, affected device count, and first-occurrence timing are to confirm because they were not provided in the prompt.

## Evidence Reviewed
- Floor 6 missing shortcuts triage summary.
- Known facts from the incident prompt: recent Windows 11 migration, Intune enrolment, and a Friday document management app rollout.
- The prompt states that evidence should come from Intune configuration data, OneDrive data, user profile data, and event logs, but the actual logs and extracts were not provided.
- Because those source records were not included, any specific event or setting conclusion remains to confirm.

## Technical Analysis
The facts show a post-migration shortcut visibility issue on at least one Floor 6 device. The most likely technical areas to inspect are user profile state, desktop folder redirection, OneDrive Known Folder Move behavior, Intune configuration profile impact, and any deployment script that creates or removes shortcuts.

At this stage, there is no verified evidence that the shortcuts were deleted. They may have been hidden, redirected, not recreated, or affected by profile synchronization; all of those possibilities remain to confirm.

The Friday document management app rollout is a possible related change, but the prompt does not prove that it caused the issue. It should be treated as a change to inspect, not a confirmed root cause.

## Verified Root Cause
To confirm.

The provided facts confirm a shortcut disappearance report after migration, but they do not confirm whether the shortcuts were deleted, hidden, redirected, or failed to recreate.

## Contributing Factors
- Recent Windows 11 migration.
- Recent Intune enrolment.
- Possible profile or desktop-state change, to confirm.
- Possible OneDrive Known Folder Move behavior, to confirm.
- Possible Intune configuration or shortcut-creation script change, to confirm.
- Friday document management app rollout, relationship to the issue to confirm.

## Resolution Implemented
To confirm.

No implemented fix details were included in the prompt. The final resolution should only be recorded after the actual remediation steps are verified from support records or device logs.

## Verification Performed
To confirm.

Verification evidence was not provided in the prompt. Before closure, confirm whether shortcuts reappear as expected, whether the desktop path and profile are correct, and whether the issue reproduces on the affected device or user profile.

## 5 Why Analysis
1. Why did the user say desktop shortcuts vanished?
- To confirm from user report and endpoint evidence.

2. Why were the shortcuts missing after migration?
- To confirm whether they were deleted, hidden, redirected, or not recreated.

3. Why would that happen after Intune enrolment or migration?
- To confirm whether a profile, desktop, OneDrive, or deployment change caused it.

4. Why is the Friday app rollout relevant?
- To confirm whether a deployment or script changed shortcut behavior.

5. Why is the root cause not yet proven?
- Because the prompt did not include the required Intune, OneDrive, profile, or event-log evidence.

## Preventive Actions
- Validate desktop folder, profile, and OneDrive settings before and after migration.
- Review Intune configuration profiles and any app deployment scripts that create or remove shortcuts.
- Confirm shortcut behavior on a pilot device before broad rollout.
- Capture evidence early when users report missing shortcuts so the actual state can be proven, not inferred.

## Lessons Learned
- A report of missing shortcuts is not the same as confirmed deletion.
- Post-migration issues can be caused by visibility, redirection, profile sync, or deployment logic, so each must be checked separately.
- Without actual logs and configuration data, the RCA must stay at the level of verified facts and to-confirm findings.
