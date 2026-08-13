# User Login Incident Communications - Three Audiences

## Audience 1 - Non-technical executive
Your access and data are safe. This morning, one user could not sign in from about 08:40 after repeated incorrect sign-in attempts locked the account, with additional incorrect attempts coming from a second source. Service desk restored access, and the user signed in successfully at 09:09 with no further issues reported. You do not need to do anything.

## Audience 2 - Affected end-user team (non-technical)
Your access and data are safe. This morning, one user could not sign in from about 08:40 because repeated incorrect sign-in attempts locked the account and extra attempts from a second source kept the issue active until service desk restored access; the user signed in successfully at 09:09 and no further issues were reported. If you see the same issue, contact the DWP Service Desk.

## Audience 3 - Engineer-to-engineer internal note
Access/data status: safe; no data-loss indicator in incident record.

Root cause:
- Repeated bad-password attempts for FINBRIDGE\cthompson triggered lockout (Event 4740 at 08:44:56 on DESKTOP-FB022).
- Continued wrong-password Kerberos pre-auth attempts from secondary source 10.10.8.112 (Event 4771 at 08:45:44, 08:46:01, 08:46:33) sustained failure condition.

Exact action taken:
- Applied lockout recovery path and stale-credential loop containment.
- Service-desk account action re-enabled user (Event 4722 at 09:08:14 by FINBRIDGE\helpdesk-admin).

Config/detail evidence:
- Primary endpoint/source: DESKTOP-FB022.
- Wrong-password sequence: Event 4776 (0xC000006A) at 08:44:01; Event 4625 bad-password at 08:44:03, 08:44:28, 08:44:55; Event 4625 locked-out at 08:45:10.
- Secondary source: 10.10.8.112 wrong-password pre-auth (Event 4771, failure code 0x18).

Verification step:
- Successful interactive login for FINBRIDGE\cthompson on DESKTOP-FB022 (Event 4624 at 09:09:01).
- Incident resolved at 09:09; no further issues reported.

Preventive action needed:
- In lockout triage, correlate Event 4740 with preceding Event 4776/4625 and concurrent Event 4771 source IPs.
- Identify/isolate all bad-credential sources before closure.
- Run post-recovery monitoring for recurrence window and clear stale credential stores on implicated sources.
