# Autopilot Enrolment Failure Analysis and Remediation - DESKTOP-FB099

Version: v1.0  
Date: 2026-08-13  
Status: Finalized

## 1. Incident Summary
- Device: DESKTOP-FB099
- User: FINBRIDGE\rthomas
- Incident time: 2024-03-15 09:22
- Enrolment type: Autopilot
- Outcome at failure point: Enrolment failed

## 2. Scope Facts (Collected)
- EnrollmentState: Failed
- ErrorCode: 0x80180014
- ErrorDescription: The device is already enrolled in MDM
- AzureADJoined: Yes
- MDMEnrolled: Yes (previous enrolment, legacy manual enrolment from 2023-11-04)
- ProfilesApplied: 0 of 4
- LastError: 0x80070005 (Access denied)
- Licensing: M365 Yes, Intune P1 Yes, Autopilot Yes
- Network: Required endpoints reachable, no proxy

## 3. Confirmed Root Cause
Confirmed root cause: the device already had a legacy manual MDM enrolment record (from 2023-11-04), creating a conflicting enrolment state that blocked Autopilot completion.

Evidence used for confirmation:
- 0x80180014 with explicit description "device is already enrolled in MDM"
- DeviceInfo showing existing legacy manual enrolment
- Policy/Compliance failure is downstream (0 of 4 profiles, compliance could not evaluate because enrolment not complete)

## 4. Remediation - Exact Steps

### Access Type Key
- [ADMIN CENTER ONLY] = No endpoint session needed
- [DEVICE ACCESS REQUIRED] = Physical or remote endpoint access needed

### Phase A - Clean stale cloud-side management objects first
1. Open Intune admin center and navigate to Devices > Windows > Windows devices, then search for DESKTOP-FB099. [ADMIN CENTER ONLY]
Expected result: Device record is found in Intune.

2. Open the device record and capture audit details (device name, user, last check-in, compliance state) in ticket notes. [ADMIN CENTER ONLY]
Expected result: Pre-remediation evidence snapshot saved.

3. From the Intune device record, run Retire (or Delete if retire is not viable for this stale state) to remove existing MDM management relationship. [ADMIN CENTER ONLY]
Expected result: Stale Intune-managed enrolment state is removed/pending removal.

4. Open Microsoft Entra admin center and navigate to Devices > All devices, then locate DESKTOP-FB099. [ADMIN CENTER ONLY]
Expected result: Corresponding Entra device object is identified.

5. If duplicate/stale object state exists, remove the stale object per your org standard (keep only the object required for new Autopilot flow). [ADMIN CENTER ONLY]
Expected result: No conflicting stale device object remains.

6. In Intune admin center, navigate to Devices > Enroll devices > Windows enrollment > Devices (Autopilot devices) and verify DESKTOP-FB099 is present and assigned to the correct Autopilot profile (FinBridge-Autopilot-Standard). [ADMIN CENTER ONLY]
Expected result: Autopilot registration/profile assignment is correct before reprovision.

### Phase B - Clear local stale enrolment state on device
7. Sign in to DESKTOP-FB099 with local admin/support access and disconnect user session activity. [DEVICE ACCESS REQUIRED]
Expected result: Support session is active on endpoint.

8. Remove legacy MDM work/school connection from Settings > Accounts > Access work or school (disconnect old managed account entry). [DEVICE ACCESS REQUIRED]
Expected result: Legacy MDM account binding is removed from endpoint UI.

9. Trigger full reprovision path to OOBE for Autopilot (company-approved method: Autopilot Reset or Fresh Start/Wipe as per operational standard). [DEVICE ACCESS REQUIRED]
Expected result: Device returns to clean enrolment start state.

10. Reconnect device to network and start Autopilot sign-in with target user FINBRIDGE\rthomas. [DEVICE ACCESS REQUIRED]
Expected result: Device begins new Autopilot-driven enrolment sequence.

### Phase C - Re-enrol and policy application
11. Monitor enrolment progress in Intune admin center under Devices > Monitor > Enrollment failures and the specific device record timeline. [ADMIN CENTER ONLY]
Expected result: No new 0x80180014 failure is logged.

12. After first check-in, open device compliance and configuration status for DESKTOP-FB099 and confirm profiles are now applying. [ADMIN CENTER ONLY]
Expected result: ProfilesApplied progresses from 0/4 toward expected applied state.

## 5. Correct Order of Operations (Do Not Reorder)
1. Remove stale Intune MDM relationship
2. Remove stale/duplicate Entra device object as needed
3. Confirm Autopilot registration/profile assignment
4. Clear local legacy management binding on device
5. Reprovision to clean OOBE state
6. Re-run Autopilot enrolment
7. Validate policy/compliance completion

Reason for this order:
- Cloud-side stale objects must be cleaned before device re-enrolment to avoid immediate re-collision.
- Device-side cleanup/reprovision must occur before Autopilot retry to ensure no residual legacy channel remains.

## 6. Verification Checks (Success Criteria)

### Primary success checks
1. Enrolment state shows Success for DESKTOP-FB099 in Intune. [ADMIN CENTER ONLY]
2. No recurrence of error 0x80180014 in enrolment failure reports. [ADMIN CENTER ONLY]
3. Device shows MDM managed under current enrolment (not legacy source). [ADMIN CENTER ONLY]

### Secondary success checks
4. Policy profile application is successful (not 0 of 4). [ADMIN CENTER ONLY]
5. Compliance engine evaluates successfully after enrolment completion. [ADMIN CENTER ONLY]
6. User can complete sign-in and reach managed desktop state without enrolment error prompts. [DEVICE ACCESS REQUIRED]

## 7. Preventive Action (Fleet-Level)

### Control to prevent recurrence on legacy-enrolled devices
1. Build and run a pre-Autopilot readiness check list for target devices that includes:
- Existing MDM enrolment present?
- Legacy enrolment source?
- Duplicate/stale Intune/Entra device object?
[ADMIN CENTER ONLY]

2. Create a pre-migration cleanup campaign for devices with legacy manual enrolment:
- Retire/remove stale enrolment records in Intune
- Resolve duplicate stale Entra objects
- Only then schedule Autopilot deployment
[ADMIN CENTER ONLY]

3. Add a release gate in migration runbook:
- "Autopilot start is blocked if pre-existing legacy MDM enrolment is detected"
- Require explicit gate pass recorded in ticket/change before device wave proceeds
[ADMIN CENTER ONLY]

4. Service desk script update:
- If 0x80180014 appears, use "legacy enrolment conflict" triage path immediately (skip generic network/licensing troubleshooting when those are already healthy)
[ADMIN CENTER ONLY]

## 8. Operational Notes
- 0x80070005 in this incident is treated as downstream/secondary during incomplete enrolment, not the primary blocker.
- Licensing and network were healthy; remediation focused on enrolment state conflict only.
- Keep evidence snapshots before and after cleanup for audit traceability.
