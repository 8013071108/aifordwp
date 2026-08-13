# AVD Incident Hypotheses - POOL-FIN-01 Black Screen

Date: 2026-08-13  
Analyst Role: DWP Engineer  
Scope-limited analysis only (no root cause commitment)

## Scope Facts Used
- Symptom: Blank screen post-login; clears after ~30 seconds for some users, persists for others.
- Who: ~40% of users on POOL-FIN-01. POOL-FIN-02 is unaffected.
- Since: ~07:00 this morning.
- Change: Overnight image update to POOL-FIN-01 at 02:00. POOL-FIN-02 was not updated.

## Ranked Likely Causes (Most Probable First)

### 1) Regression in updated POOL-FIN-01 image (display stack or shell startup)
**Why this fits the scope facts**
- Strongest correlation to timing and scope: only the updated pool is affected.
- Start-of-day onset after overnight image update aligns with first large logon wave.
- Mixed symptom behavior (30-second recovery for some, persistent for others) fits startup race/regression patterns.

**Single fastest check**
- Compare image build/version and key display/shell component versions between one affected POOL-FIN-01 host and one healthy POOL-FIN-02 host.

### 2) FSLogix profile container delay/failure during sign-in
**Why this fits the scope facts**
- Black screen after auth often maps to delayed profile attach and shell initialization.
- ~30-second recovery for some users suggests retry/timeout behavior.
- Persistent black screen for others fits attach failures.
- Could be triggered by image-side change in agent, policy handling, or profile path behavior.

**Single fastest check**
- On one impacted host, inspect a single affected user sign-in for FSLogix attach success/failure and elapsed attach time during symptom window.

### 3) GPO/logon script processing regression tied to new image
**Why this fits the scope facts**
- Partial impact (~40%) can indicate conditional targeting (group, OU, user/device context).
- 30-second behavior is consistent with policy/script wait or timeout effects.
- Pool-specific issue is plausible if updated image changed policy/script execution behavior.

**Single fastest check**
- Run gpresult for one affected session and compare sign-in policy processing events/duration to an unaffected baseline.

### 4) Shell/Appx registration issue introduced by image update
**Why this fits the scope facts**
- Post-login black screen can occur if Explorer/shell dependencies are delayed or fail registration.
- Intermittent recovery is consistent with retries eventually succeeding.
- Pool-specific because only updated image hosts have the changed app registration state.

**Single fastest check**
- During active symptom on an affected host, verify Explorer start state and check shell/AppModel events for registration failures.

### 5) AVD agent/component version mismatch on updated hosts
**Why this fits the scope facts**
- Image update can introduce version skew across AVD-related host components.
- Session initialization delays or failures can present as prolonged post-login blank screen.
- Pool-bound impact fits updated-only host population.

**Single fastest check**
- Compare AVD agent/related component versions and service health on affected POOL-FIN-01 host vs healthy POOL-FIN-02 host.

## Weighting Note
Ranking is weighted heavily by the timing clue and blast radius pattern: overnight image change at 02:00 on only POOL-FIN-01, followed by morning onset and no impact on POOL-FIN-02.

## Current Position
No single cause is confirmed yet. Hypotheses remain intentionally open pending targeted checks.
