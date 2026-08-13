# Autopilot Enrolment Incident Communications

## Audience 1 - End User
Your setup issue is identified and your data is safe. Your device could not finish setup because it still had an older management record, which blocked the new setup process. We have a cleanup-and-retry path ready and will complete setup after removing the old record. Please keep the device online and follow the service desk scheduling instructions.

## Audience 2 - Team/Manager Update
Incident summary: Autopilot enrolment failed on DESKTOP-FB099 due to a pre-existing legacy MDM enrolment conflict. Licensing and network checks were healthy, and policy/compliance failures were downstream from incomplete enrolment. Resolution path is to remove stale management records, clear local legacy enrolment state, and rerun Autopilot from clean OOBE state.

## Audience 3 - Internal Engineering Update
Confirmed root cause is enrolment-state conflict: existing manual MDM record (2023-11-04) blocked Autopilot enrolment, producing 0x80180014. Device was Azure AD joined, licensed, and network-reachable; policy failed at 0/4 with 0x80070005 as downstream effect. Remediation is ordered cleanup: Intune stale record cleanup, directory stale-object cleanup as needed, verify Autopilot profile assignment, clear local legacy binding, reprovision, re-enrol, validate profile/compliance completion.
