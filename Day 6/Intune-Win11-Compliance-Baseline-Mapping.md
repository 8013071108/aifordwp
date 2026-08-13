# Intune Windows 11 Compliance Policy Mapping

Version: v1.0  
Date: 2026-08-13

## Policy Scope Assumption
- Platform: Windows 10 and later (applies to Windows 11 devices)
- Policy type: Compliance policy
- Noncompliance action grace period: 7 days

## Global Noncompliance Action (Grace Period)
- Setting name: Actions for noncompliance > Mark device noncompliant
- Value: Schedule = Immediately, then add notification/escalation actions with 7-day schedule as required by operations model
- Effect: Device is evaluated right away; operational grace is handled by scheduled notifications/remediation workflows before enforcement actions are applied
- False-positive risk: If you delay only notifications but enforce Conditional Access immediately, users can be blocked before helpdesk remediation completes
- Recommendation: Pair compliance with CA policy design so user impact aligns with the intended 7-day remediation window
- UI path (best-known): Intune admin center > Endpoint security > Device compliance > Policies > Create policy > Windows 10 and later > Actions for noncompliance  [UI MAY DIFFER]

## Requirement Mapping

### 1) BitLocker must be enabled on the OS drive
- Setting name: Device Health > BitLocker
- Value: Require
- Effect: Flags devices noncompliant if OS drive encryption is not enabled
- False-positive risk: New/rebuilt devices can report transient noncompliance before encryption state sync completes; suspended protection states can also appear noncompliant
- Recommendation: Keep enforcement but allow operational remediation window; ensure provisioning sequence enables BitLocker before compliance check cadence
- UI path (best-known): Intune admin center > Endpoint security > Device compliance > Policies > Windows 10 and later > Device Health > BitLocker  [UI MAY DIFFER]

### 2) Secure Boot must be enabled
- Setting name: Device Health > Secure Boot
- Value: Require
- Effect: Ensures device boots with trusted signed boot components
- False-positive risk: Legacy BIOS/unsupported firmware mode devices cannot report Secure Boot enabled even if otherwise healthy for basic use
- Recommendation: Scope policy to supported hardware groups; keep requirement strict for managed Win11 fleet
- UI path (best-known): Intune admin center > Endpoint security > Device compliance > Policies > Windows 10 and later > Device Health > Secure Boot  [UI MAY DIFFER]

### 3) Minimum OS build: N-1 (22621.2861)
- Setting name: Device Properties > Minimum OS version
- Value: 10.0.22621.2861
- Effect: Blocks compliance for devices below approved minimum security/quality baseline
- False-positive risk: Devices in staged update rings may remain on older patch levels temporarily; reporting lag after update install/reboot can briefly show noncompliance
- Recommendation: Keep hard floor at N-1; align update ring deadlines so most devices reach baseline before compliance review cutoff
- UI path (best-known): Intune admin center > Endpoint security > Device compliance > Policies > Windows 10 and later > Device Properties > Minimum OS version  [UI MAY DIFFER]

### 4) Windows Defender real-time protection must be on
- Setting name: System Security > Real-time protection
- Value: Require
- Effect: Requires real-time malware scanning to be active
- False-positive risk: Third-party endpoint security products can register differently and cause intermittent state mismatches if Defender transitions between passive/active modes
- Recommendation: Standardize AV stack per device group; if using third-party AV, validate compliance telemetry behavior before broad assignment
- UI path (best-known): Intune admin center > Endpoint security > Device compliance > Policies > Windows 10 and later > System Security > Real-time protection  [UI MAY DIFFER]

### 5) Firewall must be enabled for all profiles
- Setting name: System Security > Firewall
- Value: Require
- Effect: Requires host firewall active for domain/private/public profiles
- False-positive risk: Local troubleshooting tools or endpoint agents may temporarily toggle profile state and trigger short-lived noncompliance
- Recommendation: Keep strict requirement; reduce noise by documenting approved temporary exceptions with timed rollback
- UI path (best-known): Intune admin center > Endpoint security > Device compliance > Policies > Windows 10 and later > System Security > Firewall  [UI MAY DIFFER]

### 6) A PIN or password must be configured
- Setting name: System Security > Require a password to unlock mobile devices
- Value: Require
- Effect: Requires local unlock credential at sign-in/unlock
- False-positive risk: Label includes "mobile devices" and can confuse desktop policy intent; tenant-specific UI wording can vary
- Recommendation: Keep this compliance check and enforce detailed PIN/password rules in Endpoint security Account protection policies for consistency
- UI path (best-known): Intune admin center > Endpoint security > Device compliance > Policies > Windows 10 and later > System Security (or Password category, tenant-dependent) > Require a password to unlock mobile devices  [UI MAY DIFFER]

### 7) Device must not be jailbroken or rooted
- Setting name: Not directly available as Windows jailbreak/root check in Windows compliance policy
- Value: Use Device Health + Defender for Endpoint risk signal alternative (for example, require device risk level at or below allowed threshold)
- Effect: Uses endpoint risk posture to block devices showing compromise indicators
- False-positive risk: If Defender for Endpoint integration is not enabled or onboarding is incomplete, healthy devices can appear unknown/noncompliant
- Recommendation: Enable and validate Intune-MDE connector first; phase in risk-based compliance in pilot before enforcing broadly
- UI path (best-known): Intune admin center > Endpoint security > Device compliance > Policies > Windows 10 and later > Microsoft Defender for Endpoint integration settings / Device risk (tenant-dependent)  [UI MAY DIFFER]

## Notes on UI/Label Variance
- Microsoft has moved some Intune navigation labels over time (for example, Compliance under Devices vs Endpoint security views).
- If a setting label is not visible exactly as named, search within the policy creation pane for the setting keyword (BitLocker, Secure Boot, Minimum OS version, Real-time protection, Firewall).
- For requirement 7, treat "jailbroken/rooted" as platform language from mobile OS; for Windows 11 use compromise/risk signal controls instead.

## Post-Assignment Validation Steps (Device Just Synced)

### A) Where to check this device for this specific policy
1. Policy-first view (fastest for policy troubleshooting):
- Intune admin center > Endpoint security > Device compliance > Policies > select your Windows compliance policy > Device status.
- Find the device and open it to see per-setting state (Compliant/Not compliant/In grace period), including BitLocker row details.

2. Device-first view (fastest for endpoint troubleshooting):
- Intune admin center > Devices > Windows > Windows devices > select device > Device compliance.
- Open the same policy name to see that device's policy result and each setting-level evaluation.

3. Cross-check last evaluation timing:
- Intune admin center > Devices > Windows > Windows devices > select device > Overview.
- Check Last check-in time and compare it with policy assignment time.

### B) Meaning of compliance states and Conditional Access impact
- Compliant: Device passed required checks; CA policies that require compliant device allow access (assuming no other CA block condition).
- Not compliant: Device failed one or more required checks; CA policies requiring compliant device block access.
- In grace period: Device currently fails required check(s), but noncompliance action is delayed by grace configuration; CA impact depends on when device is marked noncompliant in the policy action schedule.

Important behavior note:
- If "Mark device noncompliant" is Immediate, practical CA impact is immediate once evaluated.
- If noncompliance marking is delayed, user access can continue until grace expires and state changes to Not compliant.

### C) BitLocker false positive triage (BitLocker enabled but shown noncompliant)

1) Cause: Compliance state is stale after recent encryption/sync.
- Common signal: Local device shows protection enabled, but Intune still shows old status.
- Fastest check: Compare local encryption state and Intune "Last check-in"; trigger device sync and recheck policy result after next check-in cycle.

2) Cause: BitLocker is enabled but protection is suspended or not actively protecting at evaluation time.
- Common signal: Device was patched/serviced and protection temporarily suspended.
- Fastest check: On device, run `manage-bde -status C:` and confirm C: shows Protection Status = Protection On.

3) Cause: Wrong drive/state interpretation (OS drive not protected as expected even if another volume is encrypted).
- Common signal: Non-OS volume encrypted, but OS volume C: does not meet requirement.
- Fastest check: On device, run `manage-bde -status` and verify OS drive C: has Conversion Status = Fully Encrypted and Protection Status = Protection On.

### D) First-day monitoring after policy assignment
1. In policy Device status, track counts for Compliant / Not compliant / In grace period at 1h, 4h, and 24h.
2. In setting-level report, watch BitLocker noncompliant count trend; confirm it declines after sync cycles.
3. Open Noncompliant devices list and sample 10 devices marked BitLocker-fail to verify if failures are true or stale-reporting cases.
4. If stale-reporting dominates, keep security settings unchanged and adjust operational handling (sync/remediation flow), not the security requirement.
