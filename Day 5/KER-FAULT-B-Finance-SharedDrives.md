Symptom: Finance users cannot access shared drives because drive letter S: is not mapped after sign-in. On affected devices, users see missing drive mapping and related access failure.

Cause: Map-FinBridgeDrives.ps1 was moved from GPO USER logon execution to Intune SYSTEM execution during migration and was not updated for context handling. The script failed with exit code 1 because \\finbridge-fs01\Finance was not accessible in SYSTEM context at execution time.

Scope: Affected users were Finance users on DESKTOP-FB* devices in OU=Finance, with approximately 45 users impacted. This incident is tied to the migration change window documented at 2024-03-14 23:30.

Workaround: Restore service by using user-context drive mapping execution instead of SYSTEM execution for this script path. Redeploy and re-run mapping for affected endpoints/users.

Permanent fix: Keep drive mapping in user context (or equivalent user-context delivery method) and update script logic for dependency checks and retry behavior. Add migration controls requiring context-compatibility validation before promotion.

How to spot it: Intune log shows ScriptRunner executing Map-FinBridgeDrives.ps1 in SYSTEM context, then warning that \\finbridge-fs01\Finance is not accessible, followed by exit code 1 and no retry. System log shows Event 1500 (GP success) and Event 98 (could not map S:), confirming mapping failure is script-context related rather than GP failure.
