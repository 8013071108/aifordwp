# CAB Change Plan - FinBridge Connect v3.1 Rollout

Version: v1.0  
Date: 2026-08-13  
Status: Draft

## 1. Change Summary
- Change title: Deploy FinBridge Connect v3.1 to Win11 managed fleet
- Package type: .intunewin
- Target population: 10,000 endpoints
- Delivery platform: Microsoft Intune (Required app assignment by deployment rings)
- Business driver: Finance dependency by end of week 1 and fleet modernization

## 2. Business Impact and Priority
- Critical dependency: Finance team (500 users) must receive v3.1 by end of week 1
- Expected benefit: Standardized app baseline on Win11 fleet
- Risk area: 5% low-spec devices (4GB RAM) may have performance issues

## 3. Risk Assessment
### Key Risks
1. Performance degradation on low-spec devices
2. Detection-rule mismatch causing false install status
3. Business disruption if Finance ring experiences instability

### Risk Controls
1. Ringed rollout with 24-hour hold points
2. Low-spec exclusion from early forced deployment
3. Immediate rollback to v3.0 via existing Intune catalog package

## 4. Implementation Plan
### Ring Schedule
- Ring 0 pilot (100 mixed hardware): 2026-08-13 to 2026-08-14
- Ring 1 Finance (500 users): 2026-08-15 to 2026-08-20
- Ring 2 general (3,000 users): 2026-08-21 to 2026-08-27
- Ring 3A general (3,200 users): 2026-08-28 to 2026-08-31
- Ring 3B general (3,200 users): 2026-09-01 to 2026-09-03

### Assignment Model
- v3.1 Required to active ring
- Exclusion group for low-spec 4GB endpoints during early phases
- v3.0 retained as rollback assignment package

## 5. Validation and Gate Criteria
### Pre-Go (before each ring)
- Intune assignment health check complete
- Detection rule returns expected v3.1 registry version on pilot samples
- Support desk notified and runbook active

### Go Criteria
- Install success >= 95% (pilot), >= 97% (Finance+)
- Sev1 incidents = 0
- Sev2 user-impact <= 2%
- No unresolved Finance blocker

### No-Go Criteria
- Install failure > 8%
- Crash/unusable rate > 3%
- Any high-impact Finance outage sustained > 30 minutes

## 6. Rollback Plan
1. Freeze ring advancement immediately.
2. Remove v3.1 required assignment from impacted ring.
3. Assign v3.0 required assignment to impacted ring.
4. Trigger policy sync for priority users.
5. Verify v3.0 launch success on representative sample.
6. Continue status communications every 30 minutes until stabilized.

## 7. Communications Plan
- Pre-change notice: service desk, Finance stakeholders, IT operations
- During rollout: ring start/stop updates and metrics snapshots
- Incident communications: immediate notification on No-Go triggers
- Post-change: completion report and exception list

## 8. Success Criteria
- Finance 500 users completed by end of week 1
- Full fleet rollout completed by 2026-09-03
- Rollout stability thresholds maintained
- No unresolved major incidents at closure

## 9. Owners
- Change owner: DWP engineer
- Release execution: Endpoint management team
- User comms: Service desk lead
- CAB governance: Change manager
