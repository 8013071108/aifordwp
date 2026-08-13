Symptom: Autopilot enrolment fails for the device and user cannot complete managed setup. In this incident, enrolment failed on DESKTOP-FB099 with profiles not applying.

Cause: A pre-existing legacy manual MDM enrolment (dated 2023-11-04) conflicted with new Autopilot enrolment. Failure was recorded as 0x80180014 with description that the device is already enrolled in MDM.

Scope: Applies to Windows devices entering Autopilot that still have stale/legacy MDM enrolment state. In this case, confirmed on DESKTOP-FB099 for FINBRIDGE\rthomas.

Workaround: Remove stale MDM management relationship in Intune and clear conflicting legacy enrolment state before rerunning Autopilot. Ensure the device is correctly assigned to the Autopilot profile before retry.

Permanent fix: Enforce a pre-Autopilot cleanup gate that blocks deployment when existing legacy MDM enrolment is present. Add mandatory stale-object cleanup (Intune and directory) before device enters Autopilot wave.

How to spot it: Check enrolment status for 0x80180014 with message that the device is already enrolled in MDM. Supporting pattern includes DeviceInfo showing MDMEnrolled = Yes (legacy source), ProfilesApplied = 0 of 4, and compliance engine unable to evaluate because enrolment is incomplete.
