# Floor 6 Login / Slow Login Triage

## Summary
Floor 6 Legal has a sign-in problem after the recent Windows 11 migration and Intune enrolment. At least a dozen users cannot log in or report that login is taking forever.

## Impact (who/how many/business urgency)
- Who: Floor 6 Legal department
- How many: 45 users total; at least a dozen already reported issues
- Business urgency: High, because users cannot get to their desktop or are delayed at sign-in

## Known Facts
- Floor 6 Legal has 45 users.
- The floor was recently migrated to Windows 11 and enrolled into Intune.
- On Monday morning, IT Ops reported that at least a dozen people cannot log in or are experiencing very slow login.
- A Friday document management app rollout is mentioned in the incident context, but its relationship to the login issue is to confirm.

## Missing Information to Gather
- Exact usernames and device names affected, to confirm.
- Whether the problem affects all Floor 6 users or only a subset, to confirm.
- Exact error messages, if any, during sign-in, to confirm.
- Whether the issue is a lockout, credential failure, profile delay, or general desktop startup delay, to confirm.
- Whether the issue occurs on every device or only certain device types, to confirm.
- Whether any recent policy or app deployment changed on Friday affected these devices, to confirm.

## Likely Category
Identity / profile load / endpoint startup delay, to confirm.

## Evidence to Collect
Check these first:
- Entra ID sign-in logs for affected users and devices
- Device event logs on affected endpoints
- Intune device status and last check-in
- Windows user profile events
- Network/domain connectivity status
- Any recent policy or app deployment affecting Floor 6

## Suggest First Diagnostic Step
Pick one affected user and one unaffected Floor 6 user, then compare Entra ID sign-in logs and endpoint event logs side by side to see whether the failure is at authentication, profile load, or device startup.
