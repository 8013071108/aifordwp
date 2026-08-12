# Internal Engineer Note - VPN Win11

## Issue
VPN shows connected on Windows 11, but internal resources are unreachable after Win11 upgrade.

## Environment
- Endpoint OS: Windows 11
- Device management: Intune
- User impact: Remote access blocked despite successful VPN connect

## Confirmed Cause
Win11 upgrade removed legacy VPN client, and Intune did not re-deploy the replacement client due to a detection-rule gap.

## Resolution Applied
1. Removed stale VPN artifacts (including outdated vendor registry entries).
2. Forced Intune sync.
3. Confirmed new VPN client deployment.
4. Confirmed split-tunnel profile applied.

## Verification
- Internal resource connectivity restored.
- Access to required internal subnets confirmed.
- No data loss observed.

## Preventive Action
- Correct Intune detection rules so Win11-upgraded devices reliably trigger VPN client re-deployment.

## Notes
- If recurrence occurs, re-check Intune app detection, assignment scope, and VPN profile delivery status first.
