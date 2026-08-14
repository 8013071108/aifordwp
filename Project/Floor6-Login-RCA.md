# Floor 6 Login / Slow Login RCA

## Incident Summary
Floor 6 Legal experienced a sign-in incident after the recent Windows 11 migration and Intune enrolment. At least a dozen users could not log in or reported that login was taking a long time.

## Business Impact
- Affected area: Floor 6 Legal.
- Known population: 45 users.
- Reported impact: at least a dozen users could not log in or were delayed at sign-in.
- Business urgency: High, because users were blocked from reaching their desktops or were delayed before work could begin.

## Timeline of Events
- Recent state change: Floor 6 Legal was migrated to Windows 11 and enrolled into Intune.
- Friday afternoon: a new document management app was rolled out to that floor; whether this is related is to confirm.
- Monday morning: IT Ops reported that at least a dozen people could not log in or were taking a very long time to log in.

## Evidence Reviewed
- Triage summary for Floor 6 login / slow login.
- Reported user symptoms from Monday morning.
- Floor 6 scope facts: 45 Legal users, recent Windows 11 migration, recent Intune enrolment.
- Mentioned Friday document management app rollout, but its relationship to the issue is to confirm.
- No collected logs, Intune export, Entra sign-in details, or event viewer data were provided in the prompt, so those items remain to confirm.

## Technical Analysis
The information available shows a timing correlation between the Windows 11 migration / Intune enrolment and the start of the login problem. That makes identity, profile load, endpoint startup, or a policy/application change plausible areas to investigate, but the supplied evidence is not enough to verify a single technical cause.

The Friday document management app rollout may be relevant, but there is no evidence in the prompt that proves it caused the issue. It should be treated as a change to inspect, not as the confirmed root cause.

## Verified Root Cause
To confirm.

The current evidence confirms a login / slow-login impact on Floor 6 after migration, but it does not confirm the exact technical root cause.

## Contributing Factors
- Recent Windows 11 migration.
- Recent Intune enrolment.
- A change on Friday afternoon involving a new document management app, to confirm.
- The incident affected at least a dozen users, which suggests a shared dependency rather than a single isolated device issue, to confirm.

## Resolution Implemented
To confirm.

The prompt did not include the final resolution details or the supporting remediation evidence. Those details should be added only after they are verified from the actual change record or support logs.

## Verification Performed
To confirm.

Verification evidence was not provided in the prompt. Before closing the RCA, confirm that affected users can sign in normally and that any related policy, profile, or app issue no longer reproduces.

## 5 Why Analysis
1. Why could users not log in or why was login slow?
- To confirm from logs and sign-in evidence.

2. Why did the issue affect multiple Floor 6 users?
- To confirm from device, policy, or app-deployment evidence.

3. Why did the issue start after the migration window?
- To confirm whether the migration introduced a profile, policy, identity, or app change.

4. Why is the Friday app rollout relevant?
- To confirm whether the rollout changed logon behavior or resource access.

5. Why has the exact root cause not been proven yet?
- Because the prompt did not include the supporting logs, Intune data, sign-in logs, or final resolution details needed to prove it.

## Preventive Actions
- Collect Entra sign-in logs, endpoint event logs, and Intune device status before closing future login incidents.
- Record the exact time of any migration or app rollout against the first user symptom.
- Validate changes on a small pilot group before extending them to a full floor or department.
- If a new app is involved, confirm whether it changes sign-in, profile loading, or desktop items before broad deployment.

## Lessons Learned
- A timing match between a migration and a login problem is not enough to prove root cause.
- For multi-user login issues, the first priority is to separate identity, profile, device, and app-related causes.
- Evidence needs to be captured early; without logs and change records, the RCA remains limited to confirmed scope facts and to-confirm analysis.
