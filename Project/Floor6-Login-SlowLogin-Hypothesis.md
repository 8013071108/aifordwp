# Floor 6 Login / Slow Login - Ranked Hypotheses

## 1) Post-migration user profile load or profile initialization problem
- Why this cause fits the scope facts:
  - Multiple users are affected, which fits a shared post-migration profile-state issue rather than an isolated endpoint fault.
  - The symptoms split between complete login failure and very slow login, which is consistent with profile load or first-sign-in initialization problems after a recent Windows 11 migration.
  - Monday morning timing fits a return-to-work pattern where many users are hitting their first full sign-in cycle after migration-related changes.
- The single fastest check to confirm or eliminate it:
  - Compare one affected user and one unaffected user for profile-load timing and Windows user profile events on their devices.
- Evidence that would strengthen the hypothesis:
  - Repeated profile-load delays or profile-related errors on affected devices.
  - Affected users showing the same sign-in stage delay after credential acceptance.
  - The issue occurring mainly on recently migrated user profiles.
- Evidence that would weaken the hypothesis:
  - Clean profile event data with delays clearly happening before profile load.
  - Users failing before desktop/profile initialization begins.

## 2) Intune policy or compliance processing delay after recent enrolment
- Why this cause fits the scope facts:
  - Multiple users were recently enrolled into Intune, which creates a shared management baseline across the affected group.
  - Very slow login for many users can fit a post-enrolment policy/configuration processing delay.
  - Monday morning timing fits users returning to devices that are completing delayed policy work after the weekend.
- The single fastest check to confirm or eliminate it:
  - Review Intune device status and compare policy/app/configuration timing on one affected versus one unaffected Floor 6 device.
- Evidence that would strengthen the hypothesis:
  - Affected users sharing the same recent configuration or compliance workload timing.
  - Long or repeated policy application around sign-in on affected devices.
  - Unaffected devices showing a different or completed policy state.
- Evidence that would weaken the hypothesis:
  - No meaningful difference in Intune state between affected and unaffected devices.
  - Sign-in failure occurring before any managed policy activity begins.

## 3) Authentication or account-state issue affecting a subset of Legal users
- Why this cause fits the scope facts:
  - At least a dozen users are affected, which could fit a shared identity or account-state issue on Monday morning rather than a single machine problem.
  - The symptom wording includes users who "cannot log in," which may indicate authentication failure for some users while others experience delay.
  - This remains to confirm because the scope facts do not include exact error messages.
- The single fastest check to confirm or eliminate it:
  - Check sign-in logs for affected users to see whether failures occur at credential validation or after successful authentication.
- Evidence that would strengthen the hypothesis:
  - Consistent sign-in failures across multiple Legal users at the same authentication stage.
  - Shared lockout, denial, or failed sign-in pattern in the same time window.
- Evidence that would weaken the hypothesis:
  - Successful authentication followed by long delay on most affected devices.
  - No common sign-in failure pattern across affected users.

## 4) Friday document management application rollout is impacting sign-in or startup timing
- Why this cause fits the scope facts:
  - It is the only explicit recent change in the incident scope beyond migration and Intune enrolment.
  - The timing fits a Monday morning impact if the app or its components load at sign-in, initialize after reboot, or interact with desktop startup.
  - Multiple users affected on the same floor also fits a targeted app deployment, but this remains to confirm and should not be assumed as root cause without evidence.
- The single fastest check to confirm or eliminate it:
  - Check deployment status and app install timing for the Friday document management rollout on affected and unaffected Floor 6 devices.
- Evidence that would strengthen the hypothesis:
  - Affected devices consistently received the app while unaffected devices did not, or installed it differently.
  - Sign-in delay begins only after app installation or first launch activity.
  - App-related events align with login slowdown timing.
- Evidence that would weaken the hypothesis:
  - The app is installed successfully on unaffected devices with no sign-in impact.
  - Affected users show the same login issue regardless of app install state.

## 5) General endpoint startup/resource contention after combined Win11 migration and weekend change activity
- Why this cause fits the scope facts:
  - A recently migrated and newly managed group can experience shared Monday-morning startup contention from background tasks, app registration, syncing, or first-run processing.
  - The slow-login symptom fits device-side resource contention after recent change activity.
  - This ranks lower because it explains slow logins better than complete login failures and is less precise than profile or policy hypotheses.
- The single fastest check to confirm or eliminate it:
  - Compare startup and sign-in resource usage on one affected device during the login window against one unaffected device.
- Evidence that would strengthen the hypothesis:
  - High CPU, disk, or background processing during the login window on affected devices.
  - Consistent delay pattern without authentication failure.
  - Similar issue across devices with the same recent migration/enrolment timeline.
- Evidence that would weaken the hypothesis:
  - Devices are not resource-constrained during sign-in.
  - Login failures occur at authentication rather than after sign-in processing begins.
