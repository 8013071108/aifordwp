# Floor 6 Desktop Shortcuts - Ranked Hypotheses

## 1) User profile or desktop-state change after Windows 11 migration
- Why this cause fits the scope facts:
  - The issue appeared in an environment that was recently migrated to Windows 11, making profile-state changes a strong first hypothesis.
  - The reported symptom is specifically about desktop shortcuts vanishing, which often aligns with post-migration desktop-state or profile-behavior changes rather than application failure alone.
  - Scope does not yet show that files are missing, only that the shortcuts are gone.
- The single fastest check to confirm or eliminate it:
  - Compare the affected user’s desktop folder and profile state against a known-good migrated user.
- Evidence that would strengthen the hypothesis:
  - The desktop path or profile behavior differs from a working migrated user.
  - The shortcuts still exist in profile storage but are not appearing on the desktop.
  - The issue began immediately after first post-migration sign-in.
- Evidence that would weaken the hypothesis:
  - The user profile and desktop path match unaffected users exactly.
  - The shortcuts are actually removed from storage rather than hidden or redirected.

## 2) OneDrive Known Folder Move or desktop redirection behavior changed visibility of shortcuts
- Why this cause fits the scope facts:
  - In recently migrated Windows 11 environments, desktop folders are often redirected or synchronized, which can make icons appear to vanish even when files are still present.
  - The scope facts do not confirm deletion, only disappearance, which fits redirection or sync visibility issues.
  - This is compatible with both Windows 11 migration and recent management changes.
- The single fastest check to confirm or eliminate it:
  - Check the desktop folder path and OneDrive desktop sync state for the affected user.
- Evidence that would strengthen the hypothesis:
  - Desktop content exists in a redirected or synced path but is not visible on the local desktop view.
  - OneDrive desktop sync or folder-move state differs from a working user.
  - The issue affects icons only, not underlying documents.
- Evidence that would weaken the hypothesis:
  - OneDrive/folder redirection is not in use or is healthy and consistent across affected and unaffected users.
  - Shortcuts are missing from all possible desktop locations.

## 3) Intune configuration or policy changed desktop layout or shortcut behavior
- Why this cause fits the scope facts:
  - The devices were recently enrolled into Intune, which makes configuration change a shared control point.
  - A desktop-shortcut issue can be caused by newly applied device or user configuration after enrolment.
  - This fits the timing without requiring the Friday app rollout to be the cause.
- The single fastest check to confirm or eliminate it:
  - Compare Intune configuration profiles and recent applied settings between the affected user/device and an unaffected one.
- Evidence that would strengthen the hypothesis:
  - A recent configuration affecting desktop experience or user shell behavior is present only on the affected cohort.
  - The issue correlates with recent Intune check-in or profile application timing.
- Evidence that would weaken the hypothesis:
  - No relevant configuration differences exist between affected and unaffected users.
  - The issue can be reproduced without any recent policy application.

## 4) Friday document management application rollout changed or replaced shortcuts
- Why this cause fits the scope facts:
  - It is the only named recent application change and could plausibly create, remove, or replace desktop shortcuts.
  - Application rollouts sometimes alter shortcut sets or shell items, especially if an old shortcut is replaced by a new app path.
  - This remains lower than migration/profile causes because the scope facts do not yet show the missing shortcut is related to that app.
- The single fastest check to confirm or eliminate it:
  - Check whether the missing shortcuts belong to the newly rolled out document management application or whether install scripts altered desktop shortcut state.
- Evidence that would strengthen the hypothesis:
  - The missing shortcut is for the new app or was changed as part of its deployment.
  - A deployment script or installer action modified desktop shortcuts on Friday afternoon.
  - Unaffected users are those who did not receive the rollout or received it differently.
- Evidence that would weaken the hypothesis:
  - The missing shortcuts are unrelated to the document management application.
  - The app rollout did not touch desktop icons or shell items.

## 5) Shortcuts were actually deleted rather than hidden or redirected
- Why this cause fits the scope facts:
  - The user reported that shortcuts vanished, and deletion remains possible until checked.
  - It ranks lowest because the current scope facts do not confirm actual file loss, and migration/profile/visibility issues are more likely early explanations.
  - The prompt explicitly leaves open whether files are missing or only icons.
- The single fastest check to confirm or eliminate it:
  - Inspect the desktop folder contents directly to see whether the shortcut files still exist.
- Evidence that would strengthen the hypothesis:
  - The shortcut files are absent from all expected desktop locations.
  - Deletion timing lines up with a user, script, or deployment action.
- Evidence that would weaken the hypothesis:
  - The shortcuts still exist but are not being displayed.
  - The issue is resolved by restoring visibility or correct pathing rather than recreating files.
