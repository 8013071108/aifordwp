# FinBridge Connect v3.1 Deployment Runbook

Version: v1.0  
Date: 2026-08-13  
Status: Draft

## 1. Objective
Deploy FinBridge Connect v3.1 (.intunewin) to 10,000 Win11 endpoints in 3 weeks, with Finance (500 users) completed by end of week 1.

## 2. Scope and Constraints
- Total target: 10,000 Win11 endpoints
- Priority cohort: Finance (500 users) by day 7
- Constraint: ~5% endpoints have 4GB RAM and may struggle with v3.1
- Rollback package available: FinBridge Connect v3.0 in Intune app catalog
- Existing detection baseline: registry version string check

## 3. Pre-Deployment Checklist
1. Confirm v3.1 package is uploaded and install/uninstall commands are validated.
2. Confirm v3.0 package is active and assignable for rollback.
3. Create deployment groups:
- Ring0-Pilot-MixedHardware
- Ring1-Finance-500
- Ring2-General-3000
- Ring3-General-6400
- Exclusion-LowSpec-4GB
4. Confirm detection rule includes version verification for v3.1.
5. Confirm support team escalation channel and monitoring dashboard are active.

## 4. Ring Plan and Timeline
- Week 1 (2026-08-13 to 2026-08-20)
  - Ring 0: 100 users (include at least 20 low-spec devices) on day 1 to day 2
  - Ring 1: Finance 500 users on day 3 to day 7
- Week 2 (2026-08-21 to 2026-08-27)
  - Ring 2: 3,000 users
- Week 3 (2026-08-28 to 2026-09-03)
  - Ring 3A: 3,200 users
  - Ring 3B: 3,200 users

## 5. Deployment Procedure
1. Assign v3.1 as Required to Ring0-Pilot-MixedHardware.
Expected result: Pilot devices begin install within policy cycle.

2. Exclude Exclusion-LowSpec-4GB from all broad v3.1 required assignments.
Expected result: Known low-spec risk devices are protected from early forced rollout.

3. Monitor pilot success for 24 hours.
Expected result: Stability and install reliability data available.

4. If pilot meets go criteria, assign v3.1 as Required to Ring1-Finance-500.
Expected result: Finance rollout starts by day 3 and completes by day 7.

5. Monitor Finance ring every 4 hours during business day.
Expected result: Early detection of impact before broad rollout.

6. If Finance meets go criteria, assign Ring2-General-3000.
Expected result: Mid-scale rollout proceeds.

7. If Ring2 meets go criteria, assign Ring3A then Ring3B with 24-hour gap.
Expected result: Full fleet rollout finishes within 3 weeks.

## 6. Go/No-Go Criteria
### Go Criteria (advance to next ring)
- Install success >= 95% (pilot), >= 97% (Finance and later rings)
- Launch success >= 98%
- Sev1 incidents = 0
- Sev2 incidents <= 2% of ring population

### No-Go Criteria (hold ring)
- Install failure > 8%
- Crash or unusable app > 3%
- Any sustained Finance workflow blocker > 30 minutes

## 7. Monitoring Metrics
- Install success rate by ring
- Detection success rate by ring
- App launch failure count
- Helpdesk ticket volume tagged FinBridge Connect v3.1
- Metrics split by low-spec vs standard endpoints

## 8. Rollback Procedure
1. Stop current ring progression and pause new assignments.
2. Unassign v3.1 Required from impacted ring.
3. Assign v3.0 Required to impacted ring.
4. Trigger device sync for priority users (Finance first).
5. Validate app launch on minimum 20 sample devices in impacted ring.
6. Send user communication and status update every 30 minutes until stable.

## 9. Post-Deployment Closure
1. Confirm 10,000/10,000 target reached or document approved exceptions.
2. Confirm low-spec cohort disposition (upgraded, excluded, or deferred).
3. Publish incident-free completion report with ring metrics.
4. Archive rollback evidence and final CAB close notes.
