# Analysis - DEX Startup Performance Drop (Finance-Win11)

Date: 2026-08-13  
Method: Scope-facts-only ranking, weighted heavily to change timing and clean comparison group

## Scope Facts Used
- Affected group: Finance-Win11 (215 devices)
- Metric shift: median startup from ~17.5s baseline to ~41-44s from 2026-08-04 onward
- Score shift: 84 -> 61 on first post-change day (23-point drop), then 59-60
- Change: 2026-08-04 02:00 security baseline profile deployed to Finance-Win11 only
- Included in change: startup script for compliance logging + additional Defender scan policy
- Unaffected comparator: IT-Win11 (40 devices) not in scope of change, remained stable (~17s, scores 84-85)

## Ranked Top 3 Likely Causes

### 1) Startup script added by the new security baseline is adding logon-time delay
**Why it fits the evidence**
- The delay begins exactly on the first day after the baseline change window and persists on subsequent days.
- The script was explicitly introduced in the same change that targeted only Finance-Win11.
- IT-Win11 had no change and no performance shift, supporting a group-specific configuration effect.

**Fastest check to confirm or eliminate**
- On a sample of affected devices, measure per-run startup script execution duration from script logs or endpoint event/task logs during login window and compare with pre-change baseline (or IT group where script is absent).

### 2) Additional Defender scan policy introduced in the same baseline is consuming startup resources
**Why it fits the evidence**
- Defender policy was added in the same change event and can increase CPU/disk contention at login/startup.
- Timing aligns exactly with the profile deployment timestamp and affects only the changed group.
- Comparator group stability strongly argues against fleet-wide causes and toward the Finance-only policy delta.

**Fastest check to confirm or eliminate**
- Check Defender operational logs and endpoint performance counters during first-login startup window on affected devices to verify scan start timing and resource usage overlap with startup delay.

### 3) Combined baseline effect (script + Defender policy overlap) causing additive startup latency
**Why it fits the evidence**
- The large and sustained jump (~2.3x startup time) is consistent with cumulative overhead rather than a brief one-time event.
- Both controls were introduced together in a single profile and targeted to the affected group only.
- The unchanged, stable comparison group reinforces that the additive effect is likely inside the new baseline scope.

**Fastest check to confirm or eliminate**
- Execute controlled A/B test on a small Finance subset: temporarily disable one component at a time (script-only off, then Defender addition off) and compare median startup times over 24 hours to isolate single vs combined impact.

## Weighting Note
Ranking is intentionally weighted to change-correlation evidence: exact deployment timing (2026-08-04 02:00), immediate sustained metric break in Finance group, and clean unaffected control group with no config change.
