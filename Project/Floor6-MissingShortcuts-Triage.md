# Floor 6 Missing Shortcuts Triage

## Summary
Someone on Floor 6 Legal reports that desktop shortcuts vanished after the recent Windows 11 migration and Intune enrolment.

## Impact (who/how many/business urgency)
- Who: One person reported the issue so far.
- How many: 1 confirmed report; whether more users are affected is to confirm.
- Business urgency: Medium to high, depending on whether this is isolated or affecting multiple users.

## Known Facts
- Floor 6 has 45 Legal users.
- Floor 6 was recently migrated to Windows 11 and enrolled into Intune.
- One user says their desktop shortcuts vanished.
- A new document management app was rolled out to that floor on Friday afternoon.
- It is not confirmed that the app rollout caused the issue.

## Missing Information to Gather
- Whether the issue affects one user or multiple users, to confirm.
- Whether the missing shortcuts are only on the desktop or also in Start menu/taskbar, to confirm.
- Whether the shortcuts are actually gone or just not visible after profile/settings changes, to confirm.
- Whether the issue happened immediately after first login or after a later sign-in, to confirm.
- Whether the user has OneDrive Known Folder Move enabled, to confirm.

## Likely Category
User profile / desktop state / Intune configuration, to confirm.

Reasoning: The report is limited to missing desktop shortcuts after recent migration and enrolment activity, and the current facts do not yet prove deletion, only a change in what the user sees on the desktop.

## Evidence to Collect
Check these first:
- Windows user profile status
- OneDrive Known Folder Move sync state
- Desktop folder path
- Intune configuration profiles
- App deployment scripts
- Shortcut creation/removal scripts
- Recent login profile events
- Whether the issue affects one user or multiple users

## Suggest First Diagnostic Step
Compare the affected user's desktop folder and profile events with one unaffected Floor 6 user to confirm whether shortcuts were removed, redirected, or not being restored at sign-in.
