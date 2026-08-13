# Root Cause Analysis (RCA) - User Login Failure (cthompson)

## Document Control
- Incident date: 2024-03-15
- RCA created: 2026-08-13
- Service: Win11 user logon / AD authentication
- Affected user: FINBRIDGE\cthompson
- Affected endpoint: DESKTOP-FB022
- Incident status: Resolved
- Service restoration time: 09:09 AM

## 1. Executive Summary
On 2024-03-15, user FINBRIDGE\cthompson could not log in starting around 08:40. Evidence shows repeated bad-password authentication attempts that triggered account lockout, followed by continued wrong-password Kerberos pre-auth attempts from a second source IP.

The suggested resolution path was applied (account recovery plus stale-credential loop containment), and the user account was re-enabled at 09:08. Successful interactive logon was verified at 09:09 on DESKTOP-FB022, with no further issues reported.

## 2. Impact Assessment
- User impact: Single user unable to log in.
- Scope: No evidence of multi-user or platform-wide outage in this incident record.
- Business impact: Loss of endpoint access for the affected user during incident window.

## 3. Supporting Evidence

### 3.1 Failure Evidence (Security Log, DESKTOP-FB022, 08:44-09:12)
- 08:44:01 - Event 4776 (Audit Failure)
  - DC credential validation failed
  - Account: FINBRIDGE\cthompson
  - Error code: 0xC000006A (wrong password)
  - Source workstation: DESKTOP-FB022

- 08:44:03 - Event 4625 (Audit Failure)
  - Failure reason: Unknown user name or bad password
  - Account: FINBRIDGE\cthompson
  - Logon type: 2 (Interactive)
  - Source: DESKTOP-FB022

- 08:44:28 - Event 4625 (Audit Failure)
  - Failure reason: Unknown user name or bad password
  - Account: FINBRIDGE\cthompson
  - Logon type: 2 (Interactive)
  - Source: DESKTOP-FB022

- 08:44:55 - Event 4625 (Audit Failure)
  - Failure reason: Unknown user name or bad password
  - Account: FINBRIDGE\cthompson
  - Logon type: 2 (Interactive)
  - Source: DESKTOP-FB022

- 08:44:56 - Event 4740 (Audit Failure)
  - A user account was locked out
  - Account: FINBRIDGE\cthompson
  - Caller computer: DESKTOP-FB022

- 08:45:10 - Event 4625 (Audit Failure)
  - Failure reason: Account locked out
  - Account: FINBRIDGE\cthompson
  - Logon type: 7 (Unlock attempt)
  - Source: DESKTOP-FB022

- 08:45:44 - Event 4771 (Audit Failure)
  - Kerberos pre-authentication failed
  - Account: FINBRIDGE\cthompson
  - Failure code: 0x18 (wrong password)
  - Source IP: 10.10.8.112

- 08:46:01 - Event 4771 (Audit Failure)
  - Kerberos pre-authentication failed
  - Account: FINBRIDGE\cthompson
  - Failure code: 0x18 (wrong password)
  - Source IP: 10.10.8.112

- 08:46:33 - Event 4771 (Audit Failure)
  - Kerberos pre-authentication failed
  - Account: FINBRIDGE\cthompson
  - Failure code: 0x18 (wrong password)
  - Source IP: 10.10.8.112

### 3.2 Recovery Verification Evidence
- 09:08:14 - Event 4722 (Audit Success)
  - A user account was enabled
  - Account: FINBRIDGE\cthompson
  - Done by: FINBRIDGE\helpdesk-admin

- 09:09:01 - Event 4624 (Audit Success)
  - An account was successfully logged on
  - Account: FINBRIDGE\cthompson
  - Logon type: 2 (Interactive)
  - Source: DESKTOP-FB022

### 3.3 Evidence Interpretation
- Primary failure pattern: wrong password attempts on DESKTOP-FB022 leading directly to account lockout.
- Secondary persistence signal: continued Kerberos wrong-password attempts from source IP 10.10.8.112 after lockout.
- Recovery confirmation: account re-enabled and immediate successful interactive sign-in.

## 4. Incident Timeline
| Time | Event | Evidence / Notes |
|------|-------|------------------|
| ~08:40 | User reports unable to log in | Scope fact |
| 08:44:01 | Credential validation failed (wrong password) | Event 4776 |
| 08:44:03-08:44:55 | Repeated interactive bad-password attempts | Event 4625 (multiple) |
| 08:44:56 | Account lockout triggered | Event 4740 |
| 08:45:10 | Login fails due to lockout | Event 4625 (locked out) |
| 08:45:44-08:46:33 | Additional wrong-password Kerberos attempts from secondary source | Event 4771 from 10.10.8.112 |
| 09:08:14 | Account enabled by helpdesk-admin | Event 4722 |
| 09:09:01 | Successful interactive login on DESKTOP-FB022 | Event 4624 |
| 09:09 | Incident resolved and user verified working | Operations verification |

## 5. Root Cause Statement
The incident was caused by repeated bad-password authentication attempts for FINBRIDGE\cthompson that resulted in account lockout (Event 4740), with continued wrong-password attempts from an additional source (10.10.8.112) contributing to failure persistence during the incident window.

## 6. 5 Whys Analysis
1. Why could the user not log in?
- The account became locked and interactive logon was denied.

2. Why was the account locked?
- Multiple wrong-password attempts were recorded on the user workstation and the account hit lockout threshold.

3. Why were wrong-password attempts continuing?
- At least one additional source (10.10.8.112) continued sending Kerberos pre-auth attempts with wrong credentials.

4. Why did the issue persist until intervention?
- The account remained in a locked state until service-desk account action was taken.

5. Why was access restored after intervention?
- The account was enabled by helpdesk-admin (Event 4722), followed by successful interactive logon (Event 4624).

## 7. Resolution Actions Applied
- Followed lockout recovery path and contained stale-credential loop behavior.
- Recovered account access through service-desk account action.
- Validated successful user sign-in on DESKTOP-FB022.

## 8. Preventive Actions
1. During lockout incidents, always identify and isolate all credential attempt sources, including non-primary source IPs shown in Event 4771.
2. Add a standard triage step to correlate Event 4740 with preceding Event 4776/4625 and concurrent Event 4771 sources before closure.
3. Require post-recovery monitoring for recurrence of wrong-password events for the affected account for a defined observation window.
4. Document and clear stale credential stores on implicated endpoints/sources before final incident closure.

## 9. Validation and Closure
- Service restoration verified at 09:09 AM.
- Verification evidence: Event 4624 successful interactive logon for FINBRIDGE\cthompson on DESKTOP-FB022.
- User confirmed working; no further issues reported.
