# Incident RCA: User Lockout (jsmith)

## Document Control
- Incident type: Account lockout
- User: `jsmith`
- Review window: 30 minutes (events provided)
- Analyst role: DWP analyst
- Systems involved: `DESKTOP-FB001`, domain helpdesk account `FINBRIDGE\helpdesk-admin`
- Date authored: 2026-08-11

## Source Events
1. `08:02:14` Security `4625` Audit Failure, Account `jsmith`
   - Failure reason: Unknown username or bad password
   - Source: `DESKTOP-FB001`
   - Logon type: `2` (Interactive)

2. `08:04:22` Security `4625` Audit Failure, Account `jsmith`
   - Failure reason: Unknown username or bad password
   - Source: `DESKTOP-FB001`
   - Logon type: `2` (Interactive)

3. `08:06:01` Security `4740` Audit Failure, Account `jsmith`
   - Account locked out
   - Called from: `DESKTOP-FB001`

4. `08:07:45` Security `4625` Audit Failure, Account `jsmith`
   - Failure reason: Account locked out
   - Source: `DESKTOP-FB001`
   - Logon type: `7` (Unlock)

5. `08:22:10` Security `4722` Audit Success, Account `jsmith`
   - Account enabled
   - Done by: `FINBRIDGE\helpdesk-admin`

6. `08:23:44` Security `4624` Audit Success, Account `jsmith`
   - Successful logon
   - Logon type: `2` (Interactive)

## Event ID Meaning

### Event ID 4625 (An account failed to log on)
- Records a failed authentication attempt.
- In this incident it shows failed local/interactive sign-ins from `DESKTOP-FB001`.
- Failure reason details distinguish wrong credentials vs locked-account condition.

### Event ID 4740 (A user account was locked out)
- Records that an account lockout threshold was reached and lockout was enforced.
- The "Called from" field identifies the originating computer of the lockout-triggering attempts.

### Event ID 4722 (A user account was enabled)
- Records an administrative action enabling an account.
- Here it was performed by `FINBRIDGE\helpdesk-admin`, indicating service desk intervention.

### Event ID 4624 (An account was successfully logged on)
- Records successful authentication/logon.
- In this incident it confirms user access was restored after admin action.

## Timeline Reconstruction (Plain English)
1. At `08:02:14`, user `jsmith` attempted an interactive logon at `DESKTOP-FB001` and entered incorrect credentials.
2. At `08:04:22`, another interactive attempt from the same machine also failed for bad username/password.
3. At `08:06:01`, account lockout event `4740` was generated, meaning the failed-attempt threshold had been reached and the account was locked.
4. At `08:07:45`, another sign-in related to workstation unlock (`logon type 7`) failed specifically because the account was already locked.
5. At `08:22:10`, `FINBRIDGE\helpdesk-admin` performed an administrative enable/unlock-related action (`4722`).
6. At `08:23:44`, `jsmith` successfully logged on interactively (`4624`), showing restoration of access.

## Most Likely Lockout Cause
Most likely cause: repeated bad credential entry on `DESKTOP-FB001` during interactive sign-in/unlock attempts, which reached account lockout policy threshold.

### Evidence
- Multiple `4625` events before lockout with reason: "Unknown username or bad password".
- `4740` confirms lockout was triggered and identifies the same origin host: `DESKTOP-FB001`.
- Post-lockout `4625` reason changes to "Account locked out", confirming state transition.
- Access only returns after helpdesk administrative intervention (`4722`) and then successful logon (`4624`).

## 5-Why Analysis

### Problem Statement
User `jsmith` was locked out and unable to access workstation during the incident window.

### Why 1: Why was the user locked out?
Because account lockout policy was triggered after repeated failed authentication attempts.
- Evidence: `4740` at `08:06:01`.

### Why 2: Why were there repeated failed authentication attempts?
Because credentials entered for `jsmith` were invalid during interactive sign-in attempts.
- Evidence: `4625` at `08:02:14` and `08:04:22` with bad username/password reason.

### Why 3: Why did attempts continue after lockout?
Because an additional unlock attempt was made while account was still locked.
- Evidence: `4625` at `08:07:45`, logon type `7`, reason "Account locked out".

### Why 4: Why could the user not self-recover quickly?
Because lockout required administrative action under domain policy/process.
- Evidence: `4722` performed by `FINBRIDGE\helpdesk-admin` before successful access.

### Why 5: Why did this become an incident instead of a short user error?
Because there was no immediate corrective path preventing repeated invalid attempts before lockout (for example, user guidance, credential check, or cached credential mismatch handling at sign-in).
- Evidence: repeated failed attempts from same endpoint immediately preceding lockout.

## Root Cause and Contributing Factors

### Primary Root Cause
Repeated invalid password submissions for `jsmith` from `DESKTOP-FB001` caused policy-driven account lockout.

### Contributing Factors
- Interactive logon retries from the same endpoint in a short timeframe.
- Unlock attempt after lockout state, extending access outage.
- Dependence on service desk action for recovery.

## Remediation and Prevention Actions
1. Confirm lockout threshold and observation window policy are appropriate for user behavior and risk profile.
2. Provide user-facing lock screen guidance after first bad attempt (verify username format/domain and keyboard layout).
3. Add service desk runbook step to validate potential stale cached credentials or saved credentials on endpoint.
4. Capture and review additional related security fields in future incidents (Status/SubStatus, Workstation, Caller Process Name, Authentication Package).
5. Monitor for repeated `4625` patterns per user/device and trigger early alert before `4740` is reached.

## Validation Checks for Closure
1. Verify no new `4625` failures for `jsmith` from `DESKTOP-FB001` after `08:23:44`.
2. Verify successful interactive logons (`4624`) continue normally.
3. Confirm user can lock/unlock workstation without further failures.
4. Confirm helpdesk ticket includes user education and any credential reset confirmation.

## Confidence and Limitations
- Confidence: High on immediate lockout mechanism based on event sequence.
- Limitation: Provided events are a subset; without full event XML (Status/SubStatus) and DC correlation, exact credential failure subtype cannot be narrowed further.
