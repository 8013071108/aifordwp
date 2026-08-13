# L2/L3 KB - Autopilot Enrolment Failure (0x80180014)

Version: v 1.0
Date: 07/08/2026
Status: Draft

## Background
Autopilot enrolment creates the managed device relationship required for policy, compliance, and enterprise app delivery. If enrolment cannot complete, downstream profile and compliance processing will fail.

## Symptom
- User cannot complete Autopilot setup.
- Enrolment report shows failed state.
- Profiles do not apply and compliance cannot evaluate.

## Root Cause
The device already had a legacy manual MDM enrolment record, which conflicted with Autopilot enrolment.

Confirmed evidence:
- EnrollmentState: Failed
- ErrorCode: 0x80180014
- ErrorDescription: The device is already enrolled in MDM
- MDMEnrolled: Yes (legacy manual enrolment from 2023-11-04)
- ProfilesApplied: 0 of 4

## Detection
1. Open Intune admin center > Devices > Monitor > Enrollment failures and locate the affected device.
Expected result: Device failure entry is visible.

2. Open the failure details and confirm ErrorCode = 0x80180014 and message indicates existing MDM enrolment.
Expected result: Primary conflict signature confirmed.

3. Open Intune admin center > Devices > Windows > Windows devices > affected device > Device compliance and policy status.
Expected result: Profiles are not fully applied, aligned with incomplete enrolment.

4. Open Microsoft Entra admin center > Devices > All devices and check for stale/duplicate device object condition.
Expected result: Legacy or conflicting object state is identified if present.

5. Confirm elimination checks from diagnostics: licensing present and network endpoints reachable.
Expected result: License/network are not primary blockers.

## Resolution
1. In Intune admin center, locate affected device under Devices > Windows > Windows devices and Retire/Delete stale managed record per org standard.
Expected result: Old MDM relationship is removed.

2. In Entra admin center, remove stale/duplicate device object if conflict is present and approved by process.
Expected result: Directory-side conflict is removed.

3. In Intune admin center > Devices > Enroll devices > Windows enrollment > Devices, confirm device is assigned correct Autopilot profile.
Expected result: Device has valid profile targeting.

4. On device, remove legacy work/school management binding and reprovision to clean OOBE path.
Expected result: Device is ready for clean Autopilot re-enrolment.

5. Rerun Autopilot setup with target user.
Expected result: Enrolment completes without 0x80180014.

## Verification
1. Intune enrolment state for device shows Success.
2. No recurrence of 0x80180014 in enrollment failure monitoring.
3. Policy application progresses from 0/4 to applied state.
4. Compliance evaluation completes.

## Rollback
1. If re-enrolment fails repeatedly, stop further attempts and hold device in support queue.
2. Restore last known stable managed state path per enterprise endpoint recovery process.
3. Escalate with exported diagnostics, including enrolment failure details and object history.

## Preventive
1. Add pre-Autopilot gate: block deployment if legacy MDM enrolment exists.
2. Run pre-wave cleanup campaign for stale Intune/Entra device records.
3. Add service desk triage rule for immediate legacy-conflict path when 0x80180014 appears.

## Related
- RCA: RCA-Autopilot-EnrolmentFailure-DESKTOP-FB099-2024-03-15.md
- Analysis/Remediation: Autopilot-EnrolmentFailure-0x80180014-Analysis-Remediation.md
- KER: KER-Autopilot-EnrolmentFailure-0x80180014.md
