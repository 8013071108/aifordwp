# JAMF macOS Security Baseline Mapping

Version: v1.1  
Date: 2026-08-14

## Policy Scope Assumption
- Platform: macOS managed devices in JAMF Pro
- Fleet: 25-device Design team group
- Enforcement model: configuration profiles plus Smart Group compliance tracking
- Operational rollout: pilot ring first, then full fleet

## Important Label Verification Discipline
- JAMF payload and field labels can differ by JAMF Pro version and by legacy versus new UI views.
- Use the payload names below as best-known guidance and verify the exact labels in your own JAMF instance before production rollout.
- Treat this the same way as Day 6 Intune mapping discipline: verify live console labels, do not trust static wording blindly.

## Requirement Mapping

### 1) FileVault disk encryption must be enabled
- Payload type: Disk Encryption (FileVault)
- Setting name (best-known): Enable FileVault for personal or institutional recovery key workflow; escrow key to JAMF
- Value: Require FileVault enabled and escrow recovery key to JAMF
- Effect: Enforces full-disk encryption at rest and preserves enterprise recovery path for support
- False-positive risk: Newly enrolled devices or recently started encryption can report noncompliant before encryption completion and inventory refresh
- Recommendation: Keep requirement strict; allow provisioning to complete encryption before compliance reporting cutover
- UI path (best-known): Computers > Configuration Profiles > macOS > Security and Privacy or Disk Encryption payload area [UI MAY DIFFER]
- Label drift warning: Verify exact FileVault payload naming and key escrow options in your JAMF version

### 2) Gatekeeper must be enabled (identified developers only)
- Payload type: Restrictions or Security and Privacy (Gatekeeper control location can vary)
- Setting name (best-known): Allow apps from App Store and identified developers
- Value: Enforce identified developers only; do not allow Anywhere
- Effect: Prevents unsigned or untrusted apps from launching while allowing signed developer software
- False-positive risk: Previously user-approved app exceptions and stale inventory snapshots can make healthy devices appear inconsistent
- Recommendation: Pair policy with periodic inventory updates and exception review process
- UI path (best-known): Computers > Configuration Profiles > macOS > Restrictions or Security and Privacy > Gatekeeper [UI MAY DIFFER]
- Label drift warning: Gatekeeper control placement may differ in JAMF UI and by macOS release

### 3) Minimum macOS version must be current stable minus one point release
- Payload type: Not a single direct profile setting; enforce using Smart Group criteria plus update policy (and optional Software Update payload tuning)
- Setting name (best-known): Smart Group criteria on Operating System Version greater than or equal to approved floor
- Value: Set minimum allowed OS version to current stable minus one point release
- Effect: Identifies out-of-baseline devices and drives patch/remediation scope automatically
- False-positive risk: Devices pending reboot after update, delayed check-in, or delayed inventory recon can temporarily appear below baseline
- Recommendation: Maintain one authoritative OS floor value and update it on each Apple stable release cycle
- UI path (best-known): Computers > Smart Computer Groups > Criteria (Operating System Version), plus patch/update policy scope [UI MAY DIFFER]
- Label drift warning: Compliance visualization and Smart Group labels may differ across classic and modern JAMF views

### 4) Firewall must be enabled
- Payload type: Security and Privacy (Firewall)
- Setting name (best-known): Enable macOS Application Firewall
- Value: Require firewall enabled (optional hardening: stealth mode if approved by baseline)
- Effect: Reduces inbound attack surface by blocking unsolicited inbound traffic
- False-positive risk: Third-party endpoint tools or local state transitions can create short-lived inventory mismatch
- Recommendation: Keep firewall requirement strict; document sanctioned exception workflow for temporary troubleshooting
- UI path (best-known): Computers > Configuration Profiles > macOS > Security and Privacy > Firewall [UI MAY DIFFER]
- Label drift warning: Firewall option names and advanced toggles can differ by JAMF/macOS version

### 5) Login password required after sleep or screen saver
- Payload type: Security and Privacy (Password policy behavior)
- Setting name (best-known): Require password after sleep or screen saver begins
- Value: Require immediately (or baseline-defined short timeout)
- Effect: Prevents walk-up access when device wakes from sleep or screen lock
- False-positive risk: Profile applied but user session not yet re-evaluated can cause temporary reporting mismatch
- Recommendation: Validate with functional wake test on pilot devices before broad rollout
- UI path (best-known): Computers > Configuration Profiles > macOS > Security and Privacy > General/password prompt options [UI MAY DIFFER]
- Label drift warning: Password prompt timing labels frequently differ between macOS generations

### 6) Automatic security updates enabled
- Payload type: Software Update
- Setting name (best-known): Automatically install security responses and system data files; enable automatic update checks
- Value: Turn on automatic security update behavior and background checks
- Effect: Reduces exposure window for critical vulnerabilities by minimizing user dependency
- False-positive risk: Update downloaded but reboot pending can appear noncompliant until restart and next inventory cycle
- Recommendation: Pair settings with reboot compliance process and update deferral policy aligned to business tolerance
- UI path (best-known): Computers > Configuration Profiles > macOS > Software Update [UI MAY DIFFER]
- Label drift warning: Software Update payload fields are version-sensitive; verify names in your tenant

## Notes on UI and Payload Variance
- JAMF has both classic and newer workflows; payload names may be grouped differently.
- If an exact setting label is not visible, search by keyword inside profile payload editor (FileVault, Gatekeeper, Firewall, Software Update).
- Minimum OS version is usually operationalized through Smart Groups and policy scope, not a single profile toggle.

## Post-Assignment Validation Steps (Device Just Synced)

### A) Where to validate this baseline in JAMF
1. Profile-first view:
- Open the specific configuration profile and review scoped device install status.
- Check failed/pending profile installs first before interpreting setting drift.
2. Device-first view:
- Open the target Mac record and review installed profiles, FileVault status, and OS version.
- Confirm last inventory update timestamp.
3. Scope-first view:
- Open the Design team Smart Group and confirm expected 25-device membership.
- Confirm patch/remediation policy scope aligns with the same group.

### B) Interpretation of compliance-like states in JAMF operations
- Installed profile plus expected local state: treated as compliant for operations.
- Profile missing or failed: treated as deployment failure first, security state unknown until corrected.
- Profile installed but setting mismatch: treated as drift and escalated for remediation.

Important behavior note:
- JAMF status depends on inventory freshness. A correct local state can appear noncompliant until recon/check-in completes.

### C) Common false-positive triage patterns

1) FileVault appears noncompliant though encryption was recently enabled
- Common signal: encryption in progress or escrow not yet reflected
- Fastest check: verify local FileVault state and recovery key escrow status in device record; trigger inventory update

2) Minimum OS version appears noncompliant right after patching
- Common signal: update installed but reboot pending
- Fastest check: verify reboot state and post-restart OS version on next inventory cycle

3) Firewall mismatch right after profile assignment
- Common signal: transient local state before profile apply completes
- Fastest check: verify profile install success and rerun inventory

### D) First-day monitoring for the 25-device rollout
1. At 1 hour, 4 hours, and 24 hours, track profile install success counts.
2. Monitor Smart Group counts for below-minimum OS devices and verify trend down after remediation.
3. Sample at least 5 devices for local functional checks:
- FileVault active
- Gatekeeper set to identified developers
- Firewall enabled
- Password required on wake
4. Review reboot-pending population after update enforcement and close residual noncompliance only after post-reboot recon.

