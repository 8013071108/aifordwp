Title: Floor 6 Legal - Login Failure / Slow Login Investigation Guide
Version: 1.0
Date: 14/08/2026
Status: Draft

## Background
Floor 6 Legal experienced login failure and slow login after recent Windows 11 migration and Intune enrolment. At least a dozen users were reported as affected on Monday morning. A Friday document management app rollout is a related change to inspect, to confirm causality.

## Symptoms
- Users cannot sign in.
- Users can sign in, but login takes unusually long.
- Multi-user impact in Floor 6 Legal rather than one isolated device.

## Scope
- Department: Floor 6 Legal.
- Known population: 45 users.
- Known impacted users: at least a dozen, to confirm exact count.

## Verified Root Cause
To confirm.

The RCA confirms impact and timing correlation, but not a single proven technical cause.

## Detection
Read-only actions:
- Confirm incident pattern from Service Desk reports: login failure and slow login.
- Correlate first symptom timing with recent migration/enrolment and Friday app change window.

Expected result:
- A clear incident pattern and timeline correlation are established for investigation.

## Evidence Collection
Read-only actions:
- Collect Entra sign-in evidence.
- Collect endpoint event evidence.
- Collect Intune device status evidence.
- Record first symptom timestamps against migration/app-change timeline.

Exact log locations: to confirm (not provided in the RCA).
Event IDs: to confirm (not provided in the RCA).
Intune portal paths: to confirm (not provided in the RCA).
PowerShell commands used: to confirm (not provided in the RCA).

Expected result:
- Evidence set is sufficient to separate identity, profile, device startup, and app/policy-change hypotheses.

## Technical Resolution
Change-making actions:
- Resolution steps are to confirm because no final implemented fix is documented in the RCA.

Expected result after each step:
- To confirm from the missing runbook and actual change record.

## Verification
Read-only actions:
- Confirm affected users can sign in normally.
- Confirm slow-login behavior no longer reproduces.
- Confirm no related new user reports in the validation window, to confirm window definition.

Expected result:
- Stable sign-in behavior for affected cohort.

## Rollback
Change-making actions:
- To confirm from runbook (not available in provided sources).

Expected result:
- To confirm.

## Preventive Actions
- Collect sign-in, endpoint, and device-status evidence before closure.
- Record exact change and symptom timings.
- Validate changes on a pilot group before wider rollout.
- If new app changes are involved, validate sign-in impact before broad deployment.

## Escalation Criteria
Escalate when:
- Multi-user login impact is confirmed.
- Root cause remains unproven after initial evidence collection.
- Security, access-boundary, or wider business-impact concerns emerge, to confirm exact threshold.

## Related Articles
- Floor6-Login-RCA.md
- Floor6-Login-Runbook.md (to confirm availability)
