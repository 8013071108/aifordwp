# FinBridge Connect v3.1 - Intune 3-Week Phased Deployment Plan
Date: 2026-08-13
Deadline: 2026-09-03 (3 weeks)
Target: 10,000 Windows 11 endpoints

## 1. RING STRUCTURE

Planned deployment model (Ring 1-3) for the full fleet, with Finance handled in Section 4.

1. Ring 1 (Pilot)
- Size: 1,000 endpoints (10% of fleet)
- Duration: 4 days rollout + 2 days monitoring (6 days total)
- Include: IT engineering devices, service desk devices, digitally confident business users, mixed hardware models, and at least 100 devices from the 4GB RAM cohort
- Purpose: Validate packaging, install/uninstall behavior, detection accuracy, and early user impact under controlled conditions
- Intune assignment group type: Static Entra ID device security group
- Intune assignment intent: Required

2. Ring 2 (Early)
- Size: 3,000 endpoints (30% of fleet)
- Duration: 5 days rollout + 2 days monitoring (7 days total)
- Include: Business units with medium operational criticality, representative geographic/device-model spread, and additional 4GB RAM sample
- Purpose: Validate scale behavior, support load, and policy interaction before broad rollout
- Intune assignment group type: Dynamic Entra ID device security group (rule-based inclusion)
- Intune assignment intent: Required

3. Ring 3 (Broad)
- Size: 6,000 endpoints (60% of fleet)
- Duration: 6 days rollout + 2 days monitoring (8 days total)
- Include: Remaining eligible Win11 managed endpoints
- Purpose: Complete fleet rollout after risk is reduced by prior rings
- Intune assignment group type: Dynamic Entra ID device security group with explicit exclusions for hold/rollback groups
- Intune assignment intent: Required

4. Common ring controls
- Exclusion group: SG-Intune-FinBridge-Hold (devices paused, not rolled back)
- At-risk group: SG-Intune-FinBridge-4GBRAM (tracked separately in reporting)
- Reporting source: Intune App install status (Installed, Failed, Not applicable) by assignment group

## 2. ADVANCE CRITERIA

Use the same gate logic at both transitions (Ring 1 -> Ring 2, Ring 2 -> Ring 3), evaluated only after minimum monitoring windows.

1. Ring 1 -> Ring 2 gate (evaluate after minimum 48 hours monitoring from last Ring 1 assignment)
- Install success rate: >= 97.0% in Intune Device install status for Ring 1 group
- Error rate: <= 2.0% Failed status in Intune for Ring 1 group
- User-reported issue rate: <= 1.5 tickets per 100 installed endpoints within the 48-hour window (denominator from Intune Installed count; numerator from service desk tickets tagged FinBridge v3.1)
- Not applicable rate: <= 1.0% unless explained by known requirement mismatch and approved by EUC lead

2. Ring 2 -> Ring 3 gate (evaluate after minimum 72 hours monitoring from last Ring 2 assignment)
- Install success rate: >= 98.0% in Intune Device install status for Ring 2 group
- Error rate: <= 1.5% Failed status in Intune for Ring 2 group
- User-reported issue rate: <= 1.0 ticket per 100 installed endpoints within the 72-hour window
- Not applicable rate: <= 0.8% unless mapped to documented exceptions

3. Hold condition (pause, no full rollback)
- Trigger: Any ring shows Failed between 2.0% and 4.0% for 8 continuous hours, while Installed remains >= 95%
- Action: Pause promotion to next ring, move affected devices into SG-Intune-FinBridge-Hold, keep current ring live for investigation
- Specific example: Ring 2 failed rate rises to 2.8% after a policy conflict on one hardware model; rollout pauses while remediation package is tested

## 3. ROLLBACK TRIGGERS

If any trigger below is met, halt expansion immediately. Decision and Intune actions are pre-defined to avoid delays.

1. Trigger: Install failure rate automatic halt
- Threshold/timeframe: Failed > 4.0% for 4 consecutive hours in the active ring
- Decision owner: EUC Service Owner + Change Manager
- Decision window: 60 minutes from threshold breach alert
- Exact Intune action:
  1. Remove Required assignment for v3.1 from active and pending ring groups
  2. Add affected devices to SG-Intune-FinBridge-Rollback
  3. Assign v3.1 as Uninstall to SG-Intune-FinBridge-Rollback
  4. Assign v3.0 as Required to SG-Intune-FinBridge-Rollback

2. Trigger: Application crash rate rollback consideration
- Threshold/timeframe: >= 3.0 crashes per 100 active users in any 24-hour period, sustained for 2 consecutive days
- Decision owner: EUC Service Owner, End User Compute Lead, and App Owner
- Decision window: 4 hours after second-day confirmation
- Exact Intune action:
  1. Freeze new v3.1 assignments immediately
  2. For impacted business groups, switch to rollback group and execute v3.1 Uninstall + v3.0 Required as above

3. Trigger: Business-critical failure immediate rollback
- Scenario: Finance users cannot complete payment batch approval/export workflow in FinBridge Connect due to v3.1 defect
- Threshold/timeframe: Single confirmed Sev1 incident (percentage not required)
- Decision owner: Major Incident Manager + Finance IT Service Owner
- Decision window: 30 minutes from Sev1 confirmation
- Exact Intune action:
  1. Stop all v3.1 Required assignments globally
  2. Apply v3.1 Uninstall + v3.0 Required to Finance groups first, then other impacted groups

4. Trigger: 4GB RAM device failure isolation
- Threshold/timeframe: Failed > 8.0% on SG-Intune-FinBridge-4GBRAM over any 24-hour period
- Decision owner: Endpoint Engineering Lead
- Decision window: 2 hours
- Exact Intune action:
  1. Exclude SG-Intune-FinBridge-4GBRAM from all active v3.1 Required assignments
  2. Keep non-4GB rollout moving if other criteria are green
  3. For failed 4GB devices, assign v3.0 Required until a compatibility fix is validated

## 4. FINANCE DEADLINE RESOLUTION

Finance requires 500 users by end of week 1. Two implementation options were evaluated.

1. Option A: Compress pilot to fit Finance into Ring 2 by week 1 end
- Minimum safe pilot duration: 72 hours monitoring after initial pilot deployment
- Risk introduced: Reduced observation time increases chance of missing day-4 or day-5 defects (especially policy conflicts and device-model issues)
- Compensating control: 2-hourly reporting reviews, dedicated service desk triage queue, and mandatory change freeze before Ring 2 expansion

2. Option B: Create a separate priority Ring 0 for Finance before main Ring 1
- Ring 0 structure:
  - Size: 500 Finance users/devices
  - Timing: Start Day 1, complete deployment by Day 3, monitor through Day 5 (end of week 1)
  - Assignment group: Static Entra ID group SG-Intune-FinBridge-R0-Finance
  - Intent: Required
- Ring 0 advance conditions:
  - Installed >= 98.0%
  - Failed <= 1.5%
  - Ticket rate <= 1.0 per 100 installed users over 48 hours
  - Zero Sev1 Finance workflow incidents
- Ring 0 rollback plan:
  - If Failed > 3.0% for 4 hours, or any confirmed Sev1 Finance workflow outage:
    1. Remove v3.1 Required from SG-Intune-FinBridge-R0-Finance
    2. Assign v3.1 Uninstall to SG-Intune-FinBridge-R0-Finance
    3. Assign v3.0 Required to SG-Intune-FinBridge-R0-Finance
  - Decision owner: Finance IT Service Owner + Change Manager
  - Decision window: 30 minutes for Sev1, 60 minutes for threshold breach

3. Recommendation (single decision)
- Recommend Option B (Finance Ring 0).
- Justification:
  - Meets the non-negotiable Finance end-of-week-1 deadline.
  - Preserves risk discipline for the main pilot and avoids compressing evidence windows for the remaining 9,500 endpoints.
  - Enables targeted rollback for Finance without destabilizing the wider rollout schedule.

4. Delivery timeline summary with recommended Option B
- Week 1: Ring 0 (Finance 500) complete + monitor; Ring 1 starts for non-Finance pilot
- Week 2: Ring 2 expansion after gates pass
- Week 3: Ring 3 broad rollout and closure reporting
- Final checkpoint by 2026-09-03: 10,000 endpoints either on v3.1 or on controlled exception list with approved remediation path
