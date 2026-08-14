Title: Copilot Access Boundary Investigation Guide
Version: 1.0
Date: 14/08/2026
Status: Draft

## Background
A Floor 6 Legal user reported that Copilot surfaced a client matter they did not expect to see. The incident is classified as a security signal until evidence confirms the true cause.

## Symptoms
- User reports unexpected matter content in Copilot output.
- User belief: "I never had access to that matter."
- No confirmed product defect at initial report stage.

## Scope
- Known report count: 1 confirmed user report; wider impact to confirm.
- Priority: High due to potential Legal data exposure risk.
- Source systems to review: SharePoint and OneDrive matter locations (exact locations to confirm).

## Likely Causes
1. Valid but unexpected user access.
2. Oversharing or unintended sharing.
3. Access-path change related to recent environment/app changes, to confirm.
4. Copilot behavior interpreted as unexpected due to unclear source context.
5. Product defect only after access-path causes are ruled out.

## Detection
Read-only actions:
- Capture the exact user report and Copilot prompt/response context.
- Identify the cited or suspected content source.
- Classify as security signal pending evidence.

Expected findings:
- Clear distinction between reported perception and testable facts.

## Evidence Collection
Read-only actions:
- Record user statement and exact time window.
- Capture Copilot response details and source citation, to confirm availability.
- Collect source-location details for the matter content.
- Collect M365 audit review outputs for the same time window.

Expected findings:
- Evidence package sufficient to validate access path and exposure scope.

## Permission Review Process
Read-only actions:
1. SharePoint checks: validate direct access, group-based access, inherited access, and sharing state for the matter location.
2. OneDrive checks: validate file/folder sharing and effective user access for any related content.
3. Access validation: test whether the reporting user can access the cited source directly.

Expected findings:
- User perception: what user believed.
- Actual permissions: proven effective access path.
- Verified exposure: to confirm only if evidence shows access outside approved boundary.
- Copilot behavior: output mapped to source and access state.

## Audit Review Process
Read-only actions:
- Review M365 audit evidence for content access and related user activity in incident window.
- Correlate audit evidence with reported Copilot interaction timing.

Expected findings:
- Whether activity supports expected access or indicates a mismatch requiring remediation.

## Resolution
Change-making actions (only after read-only confirmation):
- Correct confirmed access-boundary issues (sharing/access/label state) based on evidence.
- Do not classify as product defect unless permission and access-path causes are ruled out.

Expected result:
- Access boundary aligned to approved Legal access model.

## Verification
Read-only actions:
- Re-test reporting scenario after remediation.
- Confirm whether unexpected result reproduces.
- Confirm exposure scope and closure evidence.

Expected result:
- No unexplained unexpected content for remediated scope.

## Rollback
Change-making actions:
- If remediation introduces wider access impact, revert the last access-model change using approved change control (exact rollback steps to confirm from runbook).

Expected result:
- Prior known-good access state restored.

## Preventive Controls
- Require documented SharePoint/OneDrive access-boundary validation before Copilot rollout in sensitive departments.
- Require sensitivity label checks on in-scope matter content.
- Require formal go/no-go gate when any access-path uncertainty remains.

## Escalation Criteria
Escalate immediately when:
- Evidence suggests possible verified exposure.
- Access path cannot be explained from approved model.
- Multiple users report similar unexpected content.
- Product defect is suspected only after permission/access causes are excluded.
