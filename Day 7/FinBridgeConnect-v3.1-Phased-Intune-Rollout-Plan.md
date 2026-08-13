# FinBridge Connect v3.1 - Phased Intune Rollout Plan (10,000 Win11 Endpoints)

Date: 2026-08-13  
Owner role: DWP engineer  
Scope: Intune Win32 app rollout for FinBridge Connect v3.1 with v3.0 rollback path

## 1) RING STRUCTURE

### Ring 1 (Pilot)
- Size: 300 devices (3% of fleet).
- Duration: 3 calendar days minimum.
- Include:
  - IT/DWP pilot users (150)
  - Non-critical business users across departments (100)
  - At-risk hardware sample (50 devices from 4GB RAM cohort)
- Purpose:
  - Validate install command behavior, detection rule accuracy, return code handling, and baseline app stability.
  - Detect early incompatibility on low-spec hardware before business-priority cohorts.
- Intune assignment group type:
  - Microsoft Entra security group (Assigned, static membership) named `APP-FinBridgeConnect-v3.1-Ring1-Pilot`.

### Ring 2 (Early)
- Size: 2,200 devices total.
- Duration: 4 calendar days minimum.
- Include:
  - Finance priority users (500, must complete by end of week 1)
  - Additional non-critical users (1,700) from mixed business units
- Purpose:
  - Confirm business workflow fit in a real production cohort and scale-check deployment at 20%+ volume.
  - Validate support load and incident trend under wider exposure.
- Intune assignment group type:
  - Microsoft Entra security groups (Assigned, static membership for Finance + dynamic/assigned for general early cohort):
    - `APP-FinBridgeConnect-v3.1-Ring2-Finance500`
    - `APP-FinBridgeConnect-v3.1-Ring2-Early1700`

### Ring 3 (Broad)
- Size: 7,500 devices (remaining fleet after Ring 1 and Ring 2).
- Duration: 14 calendar days maximum (split into controlled waves inside Ring 3).
- Include:
  - Remaining business units excluding any active hold/isolation groups.
- Purpose:
  - Complete fleet rollout within 3-week deadline while preserving rollback control points.
- Intune assignment group type:
  - Microsoft Entra dynamic device group plus exclusion groups:
    - Include: `APP-FinBridgeConnect-v3.1-Ring3-Broad`
    - Exclude: `APP-FinBridgeConnect-v3.1-Hold`, `APP-FinBridgeConnect-v3.1-4GB-Isolation`

## 2) ADVANCE CRITERIA

All criteria must be met at ring end before advancing.
Data sources: Intune app install status reports + service desk ticket dashboard tagged `FinBridge Connect v3.1`.

### Ring 1 -> Ring 2 advance criteria
- Install success rate: >= 96% of targeted Ring 1 devices.
- Error rate threshold: <= 4% combined `Failed` + `Install pending timeout` statuses.
- User-reported issues: <= 1.5 tickets per 100 deployed users in Ring 1, with no unresolved Sev1 tickets.
- Monitoring period: minimum 24 continuous hours after last Ring 1 assignment completes.

### Ring 2 -> Ring 3 advance criteria
- Install success rate: >= 97% of targeted Ring 2 devices.
- Error rate threshold: <= 3% combined `Failed` + `Install pending timeout` statuses.
- User-reported issues: <= 1.0 ticket per 100 deployed users in Ring 2; Sev2 trend stable or declining over final 12-hour window.
- Monitoring period: minimum 36 continuous hours after last Ring 2 assignment completes.

### Hold condition (pause without full rollback)
- Trigger: Any single department cohort within active ring shows > 6% `Failed` status for 6 consecutive hours while overall ring remains within global thresholds.
- Action: Pause expansion to next cohort, move affected cohort to `APP-FinBridgeConnect-v3.1-Hold`, continue remediation and targeted redeploy.
- Example: Finance sub-team A has 8.2% failures due to local prerequisite gap while total Ring 2 failure remains 2.4%.

## 3) ROLLBACK TRIGGERS

### Trigger A: Install failure rate (automatic halt condition)
- Threshold: > 8% `Failed` status in current active ring within any rolling 6-hour window.
- Decision owner: DWP engineer (execution) + change manager (approval checkpoint).
- Decision window: 30 minutes from threshold breach alert.
- Intune rollback action:
  1. Remove v3.1 Required assignment from active ring group.
  2. Add same ring group to v3.0 Required assignment.
  3. Add ring group to `APP-FinBridgeConnect-v3.1-Hold` exclusion for further v3.1 pushes.

### Trigger B: Application crash rate (rollback consideration)
- Threshold: >= 3 crashes per 100 active users in 12 hours attributable to v3.1 process signatures.
- Decision owner: DWP engineer with service desk lead validation.
- Decision window: 60 minutes from confirmed trend.
- Intune rollback action:
  1. Freeze new v3.1 assignments for current ring.
  2. If threshold persists after one remediation cycle (max 2 hours), reassign ring to v3.0 Required and hold v3.1.

### Trigger C: Business-critical failure (immediate rollback regardless of %)
- Specific scenario: Finance users cannot complete end-of-day payment release workflow due to v3.1 defect.
- Decision owner: Service desk lead can declare emergency; DWP engineer executes immediately; change manager informed post-action.
- Decision window: Immediate (<= 15 minutes from confirmed business impact).
- Intune rollback action:
  1. Remove v3.1 Required assignment from `APP-FinBridgeConnect-v3.1-Ring2-Finance500`.
  2. Assign v3.0 Required to `APP-FinBridgeConnect-v3.1-Ring2-Finance500`.
  3. Place Finance group in hold exclusion until fix validation.

### Trigger D: 4GB RAM device failure isolation
- Threshold: >= 10% install failure OR >= 5% severe performance degradation tickets in 4GB cohort over 24 hours.
- Decision owner: DWP engineer.
- Decision window: 45 minutes after threshold confirmation.
- Intune rollback/isolation action:
  1. Move affected low-spec devices to `APP-FinBridgeConnect-v3.1-4GB-Isolation`.
  2. Remove v3.1 Required assignment for this isolation group.
  3. Assign v3.0 Required for isolation group only.
  4. Continue v3.1 rollout for non-isolated cohorts if other thresholds are healthy.

## 4) FINANCE DEADLINE RESOLUTION

### Option A - Compress pilot timeline and move Finance into Ring 2 by end of week 1
- Minimum safe pilot duration: 72 hours with at least one business-day cycle and one overnight monitoring cycle.
- Risk introduced: reduced soak time may miss slower-burn stability issues that appear after day 3.
- Compensating control: mandatory 24-hour freeze between pilot completion and Finance deployment start, with enhanced monitoring and on-call rollback bridge.

### Option B - Finance as separate Ring 0 before main pilot
- Ring 0 structure: 500 Finance users first, then general pilot.
- Risk: places highest-priority business users on first exposure path, increasing business risk if defect exists.
- Ring 0 rollback: immediate group-level rollback to v3.0 for all Finance users on first critical signal.

### Recommendation (single clear choice)
- Recommended: Option A.
- Justification:
  1. Keeps first exposure in controlled pilot instead of high-impact Finance cohort.
  2. Still meets Finance deadline by starting Ring 2 on day 4 with pre-defined go/no-go criteria.
  3. Preserves safer risk posture while honoring end-of-week-1 business commitment.

### Operational schedule to meet 3-week deadline with Finance by week 1
- Day 1-3: Ring 1 pilot (300)
- Day 4-7: Ring 2 Finance 500 + early cohort start (remaining 1,700 can continue into week 2 if needed)
- Week 2-3: Ring 3 broad completion in controlled waves
