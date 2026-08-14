# Floor 6 Copilot Access Boundary RCA

## Incident Summary
A Legal user on Floor 6 reported that Microsoft 365 Copilot surfaced a client matter they believed they had never had access to. The report was treated as a security signal and a potential access-boundary and data exposure concern.

## Business Impact
- Who: One paralegal reported the issue so far.
- How many: 1 confirmed report; wider impact is to confirm.
- Business urgency: High, because a Legal user reported possible exposure of client matter content.

## Timeline of Events
- Floor 6 Legal was recently migrated to Windows 11 and enrolled into Intune.
- A new document management app was rolled out to Floor 6 on Friday afternoon.
- A user subsequently reported that Copilot surfaced a client matter they believed they had never had access to.
- Exact timestamps for the Copilot interaction, audit records, and any permission changes are to confirm because they were not provided in the prompt.

## Evidence Reviewed
- Floor 6 triage summary.
- Reported user perception that Copilot surfaced a client matter they believed they should not have seen.
- Known Floor 6 context: 45 Legal users, recent Windows 11 migration, Intune enrolment, and Friday app rollout.
- No audit log entries, SharePoint permission records, Purview records, or Copilot investigation output were provided in the prompt, so those items remain to confirm.

## Permission Analysis
- User perception: The user believed they had never had access to the client matter.
- Actual permissions: to confirm.
- Access path: direct access, inherited access, group membership, or sharing link are all to confirm.
- Whether the user had valid permission to the matter location: to confirm.
- Whether the content source was SharePoint, OneDrive, Teams, or another location: to confirm.

## Copilot Access Boundary Review
- Copilot behavior: Copilot surfaced content the user believed was outside their access boundary.
- Whether this was due to correct but unexpected permissions, inherited sharing, search/indexing scope, sensitivity label handling, or a Copilot product defect: to confirm.
- Whether the response included a source citation that matched a permitted location: to confirm.
- Whether other users with approved access could reproduce the same result: to confirm.

## Technical Findings
- The available facts confirm a potential access-boundary concern, but not a final technical cause.
- A Friday document management app rollout is a change to review, but there is no evidence in the prompt proving it caused the issue.
- The most defensible position from the provided facts is that actual permissions and Copilot grounding behavior must be verified before any product-defect conclusion is made.

## Verified Root Cause
To confirm.

The provided evidence does not confirm whether the issue was caused by a permission mismatch, inherited access, sharing behavior, indexing/search scope, sensitivity label handling, or a Copilot defect.

## Security Risk Assessment
- Potential risk level: High until access evidence proves otherwise.
- Reason: A Legal user reported seeing client matter content they believed they should not have seen.
- Confirmed exposure scope: to confirm.
- Confirmed unauthorized access: to confirm.

Operational classification:
- This incident is classified as a security signal pending completion of permissions, audit, and source-access review.

## Resolution Implemented
To confirm.

No final implemented fix details were provided in the prompt. The resolution should only be recorded after the exact permission or access-boundary issue is verified and corrected.

## Verification Performed
To confirm.

Verification evidence was not included in the prompt. Before closure, confirm whether the Copilot result still reproduces after correcting any verified permissions, access paths, sharing, or label issues.

## 5 Why Analysis
1. Why did the user believe Copilot surfaced a matter they should not have seen?
- To confirm from the exact Copilot response and source citation.

2. Why would Copilot have shown that matter?
- To confirm whether the user actually had access, inherited access, or unexpected share-based access.

3. Why was that access boundary not expected by the user?
- To confirm whether permissions, sharing, or labels differed from user expectation.

4. Why is the issue not yet assigned as a Copilot defect?
- Because access evidence, audit records, and Copilot investigation results were not provided in the prompt.

5. Why does this matter operationally?
- Because Legal data exposure must be ruled out before closing the incident.

## Preventive Actions
- Verify SharePoint/OneDrive permissions before investigating Copilot output as a product issue.
- Review Microsoft 365 audit logs and Purview records for any report of surfaced content.
- Confirm sensitivity labels and inherited access paths on client matter locations.
- Require a documented access-boundary check for any future Copilot content concern in Legal.
- If a new app rollout changes content access or indexing, validate that change in a pilot group first.

## Lessons Learned
- User perception and actual permission state are not the same and must be checked independently.
- Copilot incidents involving Legal content should be treated as security signals and access-risk events until permissions and audit evidence prove otherwise.
- A nearby migration or app rollout may be relevant, but it should not be treated as root cause without supporting evidence.
