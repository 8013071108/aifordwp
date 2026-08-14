# Floor 6 Prevention Note

## Control Name
Monday Morning Readiness Gate for Targeted Intune App Deployments

## Purpose
Prevent a Friday application rollout from remaining in full scope through Monday morning if it is causing sign-in delay, sign-in failure, or desktop-state impact for the targeted business group.

## Owner
DWP engineer

## When It Runs
After a Friday application deployment to a targeted user/device group and before 08:30 on the next business day.

## Scope
All targeted devices and users in the deployment cohort for the newly deployed application. For this incident pattern, that means the Floor 6 Legal app deployment group and any emergency exclusion or rollback cohort created during containment.

## Validation Checks
1. Confirm whether any targeted devices are already in the emergency exclusion or rollback cohort.
2. Check current app assignment state for the deployed application and verify whether affected devices are still targeted.
3. Confirm sign-in outcome with at least one affected user and one unaffected user in the target group.
4. Confirm desktop shortcut status with at least one affected user and one unaffected user in the target group.
5. Confirm whether new Floor 6 incidents are still being reported after the first containment window.

## Pass Criteria
- No affected devices remain unintentionally targeted by the current deployment after containment review.
- At least one previously affected user confirms successful sign-in and improved login time.
- No continuing report of shortcut disappearance is confirmed in the validation sample.
- No new related incidents are reported during the agreed validation window.

## Fail Criteria
- Any affected device remains in the active deployment scope when it should be excluded or rolled back.
- A validation user still cannot sign in or still experiences unusually slow sign-in.
- Desktop shortcuts are still missing or continue to disappear in the validation sample.
- New related incidents continue after containment action.

## Required Action if Failed
Immediately stop progression of the active application deployment for the affected cohort, keep affected devices in the emergency exclusion or rollback path, and do not return the cohort to the active deployment scope until the validation checks pass.

## Evidence Produced
- Export or screenshot of the current app assignment state for the affected deployment group.
- List of affected devices placed in exclusion or rollback cohort.
- User validation record for one affected and one unaffected user covering sign-in result, login duration, and shortcut status.
- Incident count/update record for the validation window.

## How This Would Have Prevented the Floor 6 Incident
This control would have forced a formal Monday morning checkpoint on the Friday document application rollout before normal business usage resumed. It would either have confirmed that Floor 6 Legal users were signing in normally with no ongoing shortcut impact, or it would have kept the affected devices out of the active deployment scope before the issue continued into the business day.
