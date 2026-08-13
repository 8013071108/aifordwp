# DEX Analysis - Ranked Likely Causes of Startup Performance Drop (Finance-Win11)
Date: 2026-08-13
Scope basis: Finance-Win11 degraded immediately after 2026-08-04 02:00 config deployment; IT-Win11 (not targeted) remained stable.

## Ranked Top 3 Likely Causes

1. Added startup compliance logging script in the new Finance-only baseline profile
- Why it fits the evidence:
  - The degradation begins exactly on 2026-08-04, the same date/time window as the new profile deployment.
  - The affected metric is login-to-usable-desktop startup time, which directly includes startup script execution impact.
  - IT-Win11 had no config change and stayed stable, which strongly isolates the effect to the Finance-targeted change set.
- Fastest check to confirm or eliminate:
  - Temporarily exclude a small Finance subset from the startup script portion of the profile (keep other settings unchanged) and compare next-login median startup time within 24 hours.

2. Additional Defender scan policy introduced in the same baseline causing heavier startup-time overhead
- Why it fits the evidence:
  - The policy was deployed at the same time as the score drop and is targeted only to Finance-Win11.
  - Startup time increased sharply and then stayed elevated, consistent with a persistent startup-time tax from endpoint policy behavior.
  - The unaffected IT group had no such policy change and did not show any parallel increase.
- Fastest check to confirm or eliminate:
  - On a controlled Finance pilot subset, remove only the new Defender scan component, force policy refresh, then compare startup medians against unchanged Finance devices over the next business day.

3. Combined cumulative effect of both new controls in one release (script + Defender) without phasing
- Why it fits the evidence:
  - Two startup-relevant controls were introduced together at 02:00; the immediate step-change and sustained plateau suggest additive overhead.
  - Clean comparison group behavior (no change in IT-Win11) supports a release-scoped cause rather than fleet-wide noise.
  - The post-change values stay consistently high, matching a steady-state added cost from multiple controls.
- Fastest check to confirm or eliminate:
  - Run an A/B split inside Finance: Group A with script only, Group B with Defender change only, Group C with both; compare median startup and score after one working day to isolate single vs combined impact.
