Symptom: User FINBRIDGE\cthompson could not log in on DESKTOP-FB022. The incident began around 08:40.

Cause: Repeated bad-password attempts triggered account lockout for FINBRIDGE\cthompson (Event 4740 at 08:44:56). Continued wrong-password Kerberos pre-auth attempts from source IP 10.10.8.112 sustained the failure condition (Event 4771).

Scope: Impact in this incident was one user account (FINBRIDGE\cthompson) and the observed endpoint DESKTOP-FB022. No broader outage is recorded in the RCA.

Workaround: Apply lockout recovery and contain stale credential retry sources so bad-password attempts stop. Re-enable the account and validate interactive sign-in.

Permanent fix: Identify and clear stale credentials on all implicated sources, including the endpoint and secondary source generating wrong-password attempts. Standardize triage to correlate lockout and wrong-password events before closure.

How to spot it: Look for Event 4776 with error 0xC000006A and repeated Event 4625 bad-password failures, followed by Event 4740 account lockout. Persistent recurrence is indicated by Event 4771 with failure code 0x18 from another source IP (10.10.8.112 in this incident), and recovery is confirmed by Event 4722 then Event 4624 success.
