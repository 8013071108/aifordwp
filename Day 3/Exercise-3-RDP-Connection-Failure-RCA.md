# Exercise 3: RDP Connection Failure Analysis and RCA (System + Security Logs)

## Incident Summary
- Incident type: RDP authentication failure and account lockout
- Affected account: `FINBRIDGE\bwalker`
- Source client: `10.10.5.44`
- Protocol path: Remote Desktop (Logon type 10 / RemoteInteractive)
- Incident window observed: 2024-03-15 14:01:02 to 14:22:09

## Events Reviewed
1. System / TermDD / Event 56 / Error / 14:01:02
   - Terminal Server security layer detected protocol stream error and disconnected client
   - Client IP: `10.10.5.44`

2. System / RemoteDesktopServices-RdpCoreTS / Event 140 / Warning / 14:01:02
   - Connection failed because username or password is not correct
   - Client IP: `10.10.5.44`

3. Security / Event 4625 / Audit Failure / 14:01:04
   - Account: `FINBRIDGE\bwalker`
   - Failure reason: Unknown username or bad password
   - Logon type: 10 (RemoteInteractive)
   - Source IP: `10.10.5.44`

4. Security / Event 4625 / Audit Failure / 14:03:18
   - Same account, reason, logon type, and source IP

5. Security / Event 4625 / Audit Failure / 14:05:33
   - Same account, reason, logon type, and source IP

6. Security / Event 4740 / Audit Failure / 14:05:34
   - Account: `FINBRIDGE\bwalker`
   - Caller computer/IP: `10.10.5.44`
   - Account locked out

7. System / RemoteDesktopServices-RdpCoreTS / Event 131 / Info / 14:22:07
   - Server accepted new TCP connection from `10.10.5.44`

8. Security / Event 4624 / Audit Success / 14:22:09
   - Account: `FINBRIDGE\bwalker`
   - Logon type: 10 (RemoteInteractive)
   - Source IP: `10.10.5.44`

## What Each Event ID Records

### Event 56 (TermDD)
- Records an RDP transport/security-layer disconnect due to protocol stream/security negotiation error.
- In this timeline it occurs at the same moment as explicit bad credential indication (Event 140).
- Note: Event 56 can have multiple causes; do not treat it as standalone proof of network failure without corroboration.

### Event 140 (RdpCoreTS)
- Records RDP connection failure due to incorrect username or password.
- Strongly indicates authentication failure in this incident.

### Event 4625 (Security)
- Records failed logon attempt.
- Here: repeated RemoteInteractive failures for same account from same source IP with bad password/username reason.

### Event 4740 (Security)
- Records that account lockout threshold was reached and account was locked.
- Caller field ties lockout-triggering activity to `10.10.5.44`.

### Event 131 (RdpCoreTS)
- Records successful TCP-level RDP connection acceptance by server.
- Indicates transport connectivity was available at that point.

### Event 4624 (Security)
- Records successful authentication/logon.
- Here confirms RDP access was eventually successful for same user/source.

## Timeline Reconstruction (Plain English)
1. At 14:01:02, the RDP stack reports a security/protocol disconnect from `10.10.5.44` (Event 56), and simultaneously RDP core logs that username/password were incorrect (Event 140).
2. At 14:01:04, first Security failed RemoteInteractive logon occurs for `FINBRIDGE\bwalker` from `10.10.5.44` (Event 4625).
3. Additional failed RDP logons occur at 14:03:18 and 14:05:33 with the same bad password/username reason.
4. At 14:05:34, account lockout is triggered (Event 4740), with caller `10.10.5.44`.
5. At 14:22:07, server accepts a new TCP connection from the same client (Event 131).
6. At 14:22:09, successful RDP sign-in occurs for the same account/source (Event 4624), indicating issue resolution.

## Most Likely Cause of the RDP Failure
Most likely cause: repeated incorrect credentials (or stale saved credentials) entered/sent by client `10.10.5.44`, causing authentication failures and account lockout policy enforcement.

## Evidence for Most Likely Cause
1. Event 140 explicitly states bad username/password.
2. Three consecutive Event 4625 failures for same account, same source, same logon type (10).
3. Event 4740 immediately after third failure confirms lockout threshold reached.
4. Later Event 4624 success from same source indicates connectivity and account path were valid once credentials/lockout state were corrected.
5. Event 131 + 4624 sequence weakens hypothesis of persistent network outage.

## RCA (Root Cause Analysis)

### Problem Statement
User `FINBRIDGE\bwalker` could not complete RDP sign-in and experienced lockout during the incident window.

### Root Cause
Account lockout due to repeated bad credential submissions over RDP from client `10.10.5.44`.

### Contributing Factors
- Consecutive failed RemoteInteractive attempts within lockout policy window.
- Potential stale cached/saved credential in RDP client profile (requires verification).
- Lockout policy threshold reached before corrective action.

## 5-Why Analysis
1. Why did the user fail to connect by RDP?
- Authentication attempts failed (bad username/password).
- Evidence: Event 140 and Event 4625 entries.

2. Why did authentication fail repeatedly?
- Same account/source produced multiple failed attempts in short succession.
- Evidence: 4625 at 14:01:04, 14:03:18, 14:05:33.

3. Why did the issue escalate from failure to outage?
- Account lockout policy triggered after threshold was reached.
- Evidence: Event 4740 at 14:05:34.

4. Why could user not recover immediately?
- Once locked out, valid authentication cannot proceed until lockout condition is cleared/expired.
- Evidence: failure sequence ends only after later successful login.

5. Why did service appear to recover later?
- A subsequent connection used valid authentication after lockout state was resolved.
- Evidence: Event 131 followed by Event 4624 at 14:22.

## Uncertainty and Verification Notes
- Event 56 can represent several protocol/security disconnect causes; in this incident it correlates with credential failures, but exact low-level protocol detail should be verified against Microsoft documentation.
- Confirm whether failures were manual typing errors vs saved credential replay from MSTSC/Credential Manager.
- Confirm domain lockout policy values (threshold, duration, reset window) for precise threshold mapping.

## Recommended Remediation Plan (Ranked)
1. Immediate: clear stale RDP saved credentials on client `10.10.5.44`, then retest with known-correct username format and password.
2. Confirm account lockout status and unlock workflow in AD; document timestamp and operator action if unlock was manual.
3. Review effective lockout policy and ensure user guidance after first failed attempt (to avoid threshold hit).
4. Enable/maintain monitoring for repeated 4625 (logon type 10) and alert before 4740 threshold is reached.
5. If Event 56 continues even with successful credentials, run deeper RDP protocol/TLS diagnostics.

## Items to Verify Against Microsoft Documentation
1. Official diagnostic interpretation hierarchy for TermDD Event 56 when paired with RdpCoreTS 140 and Security 4625.
2. Recommended Microsoft troubleshooting sequence for repeated 4625/4740 on RDP.
3. Any build-specific RDP authentication known issues relevant to incident date.

## Closure Criteria
1. No new 4625 failures for `FINBRIDGE\bwalker` from `10.10.5.44` during agreed monitoring period.
2. No new 4740 lockout events for the user.
3. Successful repeat RDP logons (4624, logon type 10).
4. User confirms stable access and no recurring prompts/failures.
