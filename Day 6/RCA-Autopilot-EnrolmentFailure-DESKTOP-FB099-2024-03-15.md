# Root Cause Analysis (RCA) - Autopilot Enrolment Failure (DESKTOP-FB099)

## Document Control
- Incident date: 2024-03-15
- RCA created: 2026-08-13
- Service: Windows Autopilot / Intune MDM enrolment
- Device: DESKTOP-FB099
- User: FINBRIDGE\rthomas
- Incident status: Resolved (based on finalized remediation path)

## 1. Executive Summary
Autopilot enrolment failed on DESKTOP-FB099 because the device already had an existing legacy manual MDM enrolment record from 2023-11-04. This created a conflicting enrolment state and blocked Autopilot from completing.

Licensing and network checks were healthy, so the failure was not caused by license assignment or endpoint reachability. Policy and compliance failures were downstream effects of incomplete enrolment.

## 2. Impact Assessment
- Scope: Single known device in this incident record (DESKTOP-FB099).
- User impact: User could not complete Autopilot enrolment and receive policy baseline.
- Service impact: Security baseline/profile application did not complete (`ProfilesApplied: 0 of 4`).

## 3. Supporting Evidence

### 3.1 Enrolment Failure Evidence
- EnrollmentType: Autopilot
- EnrollmentState: Failed
- ErrorCode: 0x80180014
- ErrorDescription: The device is already enrolled in MDM.
- Timestamp: 2024-03-15 09:18:44

### 3.2 Existing Enrolment Evidence
- AzureADJoined: Yes
- MDMEnrolled: Yes (previous enrolment)
- EnrolmentSource: Legacy manual MDM enrolment (2023-11-04)

### 3.3 Policy/Compliance Downstream Evidence
- ProfilesAttempted: 4
- ProfilesApplied: 0
- LastError: 0x80070005 (Access denied)
- FailedProfile: FinBridge-Win11-Security-Baseline
- ComplianceEngine EvaluationResult: Could not evaluate
- ComplianceEngine Reason: Enrolment not complete

### 3.4 License and Network Elimination Evidence
- Licensing:
  - M365LicenseFound: Yes
  - IntuneP1License: Yes
  - AutopilotLicense: Yes
- Network:
  - login.microsoftonline.com: OK
  - enrollment.manage.microsoft.com: OK
  - enterpriseregistration.windows.net: OK
  - ProxyDetected: No

## 4. Timeline
| Time | Event | Evidence |
|------|-------|----------|
| 2023-11-04 | Legacy manual MDM enrolment exists on device | DeviceInfo: EnrolmentSource |
| 2024-03-15 09:18:44 | Autopilot enrolment fails | EnrollmentState Failed, Error 0x80180014 |
| 2024-03-15 09:19:01 | Policy application fails | ProfilesApplied 0/4, LastError 0x80070005 |
| 2024-03-15 09:19:45 | Compliance evaluation cannot complete | Reason: Enrolment not complete |
| 2024-03-15 09:22 | Diagnostic export captured | Incident evidence snapshot |

## 5. Root Cause Statement
The incident was caused by a pre-existing legacy manual MDM enrolment record on DESKTOP-FB099 that conflicted with new Autopilot enrolment. The conflict caused Autopilot enrolment to fail with 0x80180014, preventing policy and compliance processing from completing.

## 6. 5 Whys Analysis
1. Why did Autopilot fail on DESKTOP-FB099?
- Because enrolment returned a failed state with error 0x80180014.

2. Why did 0x80180014 occur?
- Because the device already had an active MDM enrolment state.

3. Why did the device already have an MDM enrolment?
- It retained a legacy manual enrolment from 2023-11-04.

4. Why did this legacy state block operational readiness?
- Autopilot could not create a clean management channel over the conflicting existing enrolment.

5. Why did policy/compliance also fail?
- Because enrolment did not complete, resulting in profile application failure (0/4) and compliance engine inability to evaluate.

## 7. Resolution Applied (Finalized)
1. Remove stale/conflicting MDM enrolment relationship in Intune.
2. Remove stale/duplicate directory device object as required by org standard.
3. Confirm correct Autopilot device registration/profile assignment.
4. Clear legacy enrolment state on device.
5. Reprovision and rerun Autopilot from clean state.
6. Revalidate profile application and compliance evaluation.

## 8. Verification Criteria
- Autopilot enrolment status = Success for DESKTOP-FB099.
- No recurrence of error 0x80180014 in enrolment status/failure logs.
- Device managed under current enrolment channel (not legacy manual record).
- ProfilesApplied progresses from 0/4 to successful application state.
- Compliance engine evaluates successfully after enrolment completion.

## 9. Preventive Actions
1. Add pre-Autopilot readiness gate
- Mandatory check for pre-existing MDM enrolment before Autopilot start.
- If existing enrolment detected, block migration and route to cleanup workflow.

2. Add legacy enrolment cleanup wave before migration
- Identify and retire/remove legacy manual enrolments for target devices prior to Autopilot assignment.
- Resolve duplicate stale device objects before deployment wave starts.

3. Update migration runbook controls
- Add explicit decision node: "0x80180014 + existing MDM enrolment = legacy conflict path."
- Skip generic network/licensing troubleshooting when evidence already confirms healthy license/network state.

4. Add service desk triage standard
- Include a first-line check for `MDMEnrolled: Yes (legacy)` in MDM diagnostic exports.
- Escalate directly to cleanup/re-enrol path to reduce time-to-recovery.

## 10. Residual Risk
- Any device entering Autopilot with unclean legacy enrolment state can reproduce this failure pattern.
- Risk remains until pre-flight cleanup and gate controls are enforced in all migration waves.

## 11. Closure Note
RCA confirms enrolment-state conflict as primary cause. License and network were healthy and are excluded as primary contributors in this incident.
