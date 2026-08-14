Subject: Floor 6 Legal desktop shortcuts incident - operational escalation update

Issue Summary
A Floor 6 Legal user reported that desktop shortcuts disappeared after the recent Windows 11 migration and Intune enrolment activities. The issue is currently under investigation and the exact failure mode is not yet confirmed.

Business Impact
Floor 6 Legal has 45 users. One user has confirmed missing desktop shortcuts so far. This is causing user disruption and may slow work, but actual data loss has not been verified.

Investigation Findings
The verified facts show a post-migration shortcut visibility issue on at least one Floor 6 device. The evidence currently available does not confirm whether the shortcuts were deleted, hidden, redirected, or failed to recreate. The prompt did not include the underlying Intune configuration data, OneDrive data, user profile data, or endpoint event logs, so those findings remain to confirm.

Verified Root Cause
The root cause is not yet verified. Current evidence confirms the user report but does not confirm the exact technical cause.

Actions Completed
The incident has been triaged and documented. The investigation scope has been defined to review user profile state, desktop folder behavior, OneDrive Known Folder Move state, Intune configuration impact, and any shortcut-related deployment logic.

Current Status
The issue remains open and unresolved. The problem is currently being treated as a desktop-state or profile-related issue pending evidence review.

Remaining Risks
Additional users may be affected if the issue is tied to a shared profile, desktop redirection, or configuration change. There is currently no verified evidence of actual data loss.

Preventive Measures
Preventive action is not yet finalized because the root cause remains to confirm. Current planned controls are to validate desktop folder and profile behavior before and after migration, review Intune configuration and shortcut-related deployment logic, and confirm shortcut behavior in pilot groups before wider rollout.