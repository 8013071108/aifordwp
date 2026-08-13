# User Logon Incident Analysis - cthompson (Scope-Based)

Date: 2026-08-13  
Analyst role: DWP Engineer  
Method: Scope-facts-only ranking (no root cause commitment)

## Scope Facts Used
- Symptom: User `cthompson` is not able to log in.
- Who: `cthompson` only (single-user impact).
- Since: ~08:40 this morning.
- Change: Nil.

## Ranked Hypotheses (Most Probable First)

### 1) User account lockout from repeated bad credentials
**Why this fits the scope facts**
- Single-user impact strongly points to an account-specific condition rather than platform-wide failure.
- Sudden start time with no known change is consistent with lockout triggered by stale saved credentials on one of the user endpoints/apps.

**Single fastest check**
- Check identity directory/account status for `cthompson` lockout state and recent failed sign-in attempts around 08:40.

### 2) Password expired or recently changed with stale cached credentials
**Why this fits the scope facts**
- A one-user login failure with no infrastructure change commonly maps to password lifecycle issues.
- Time-specific onset fits a policy threshold being reached (for example, expiry window) or stale credential usage beginning in the morning.

**Single fastest check**
- Verify `cthompson` password expiry/reset timestamp and correlate it with failed sign-in timestamps.

### 3) Conditional Access or MFA challenge failure for this user
**Why this fits the scope facts**
- Per-user policy state or MFA method issues can block only one user while everyone else remains unaffected.
- No environment change is needed for this to occur if user/device risk or method state changed.

**Single fastest check**
- Review sign-in logs for `cthompson` and read the explicit failure reason (MFA failed, MFA denied, policy blocked).

### 4) User profile corruption or local credential cache issue on the primary device
**Why this fits the scope facts**
- Single-user symptom can be caused by local profile or credential cache corruption without any global change.
- Start time this morning fits first login attempt on that device/session context.

**Single fastest check**
- Attempt sign-in with `cthompson` on a known-good alternate device/session path; if successful there, local device/profile is implicated.

### 5) Account disabled or restricted by admin/security control
**Why this fits the scope facts**
- One-user-only failure with no broader impact is compatible with an account-level administrative/security action.
- A precise onset time can align with an automated enforcement or manual action.

**Single fastest check**
- Check account attributes/status (enabled/disabled, sign-in blocked, restriction flags) for `cthompson` in identity admin console.

## Note
This ranking is intentionally scope-limited and does not assert a final cause. Evidence from sign-in logs and account state is required before diagnosis is confirmed.

---

## Addendum - Event Evidence Review (2024-03-15 08:44-09:12)

### Evidence Ingested (Security Log: DESKTOP-FB022)
- 08:44:01 - Event 4776 (Audit Failure): credential validation failed, error `0xC000006A` (wrong password), account `FINBRIDGE\cthompson`, source workstation `DESKTOP-FB022`
- 08:44:03 - Event 4625 (Audit Failure): unknown user name or bad password, logon type 2, source `DESKTOP-FB022`
- 08:44:28 - Event 4625 (Audit Failure): unknown user name or bad password, logon type 2, source `DESKTOP-FB022`
- 08:44:55 - Event 4625 (Audit Failure): unknown user name or bad password, logon type 2, source `DESKTOP-FB022`
- 08:44:56 - Event 4740 (Audit Failure): account locked out, account `FINBRIDGE\cthompson`, caller computer `DESKTOP-FB022`
- 08:45:10 - Event 4625 (Audit Failure): failure reason account locked out, logon type 7, source `DESKTOP-FB022`
- 08:45:44 - Event 4771 (Audit Failure): Kerberos pre-authentication failed, failure code `0x18` (wrong password), source IP `10.10.8.112`
- 08:46:01 - Event 4771 (Audit Failure): Kerberos pre-authentication failed, failure code `0x18`, source IP `10.10.8.112`
- 08:46:33 - Event 4771 (Audit Failure): Kerberos pre-authentication failed, failure code `0x18`, source IP `10.10.8.112`

### Reviewed Hypotheses Against Evidence

#### 1) User account lockout from repeated bad credentials
**Judgment:** Supported.

**Determining events:**
- 08:44:01 Event 4776 (`0xC000006A` wrong password)
- 08:44:03 / 08:44:28 / 08:44:55 Event 4625 (bad password)
- 08:44:56 Event 4740 (account locked out)
- 08:45:10 Event 4625 (account locked out)

#### 2) Password expired or recently changed with stale cached credentials
**Judgment:** Neutral (to confirm).

**Determining events:**
- 08:44:01 Event 4776 (wrong password)
- 08:45:44 / 08:46:01 / 08:46:33 Event 4771 (`0x18` wrong password)
- No explicit expiry/reset event is present in supplied evidence

#### 3) Conditional Access or MFA challenge failure for this user
**Judgment:** Contradicted by supplied evidence.

**Determining events:**
- 08:44:01 Event 4776 (credential validation wrong password)
- 08:44:56 Event 4740 (lockout)
- 08:45:10 Event 4625 (account locked out)

#### 4) User profile corruption or local credential cache issue on primary device
**Judgment:** Neutral (to confirm).

**Determining events:**
- 08:44:03 / 08:44:28 / 08:44:55 Event 4625 logon type 2 from `DESKTOP-FB022`
- 08:44:56 Event 4740 caller `DESKTOP-FB022`
- 08:45:44 / 08:46:01 / 08:46:33 Event 4771 from source `10.10.8.112` indicates additional credential source

#### 5) Account disabled or restricted by admin/security control
**Judgment:** Contradicted by supplied evidence.

**Determining events:**
- 08:44:56 Event 4740 confirms lockout trigger
- 08:45:10 Event 4625 failure reason is account locked out
- No supplied event indicates account disabled as primary trigger

### Surviving Hypothesis (Post-Elimination)

Account lockout caused by repeated bad credentials, with continued bad password attempts from more than one source (`DESKTOP-FB022` and `10.10.8.112`) sustaining failure.

---

## Resolution Steps (Detailed)

### 1. Contain the lockout loop
1. Temporarily isolate `DESKTOP-FB022` from network to stop further bad attempts.
2. Identify and isolate the secondary bad-attempt source `10.10.8.112`.
3. Keep account unlock on hold until both sources are contained.

### 2. Reset and unlock account safely
1. Reset password for `FINBRIDGE\cthompson`.
2. Unlock account after reset.
3. Confirm lockout status is cleared in identity admin view.

### 3. Clear stale credential sources
1. On `DESKTOP-FB022`, remove saved credentials for AD/M365/VPN/file shares from Credential Manager.
2. Sign out of credential-caching apps and restart device.
3. On source `10.10.8.112`, update or remove stale stored credentials tied to `cthompson`.

### 4. Controlled validation
1. Reconnect `DESKTOP-FB022` and perform one interactive login with updated credentials.
2. Confirm successful login and no immediate failure events.

### 5. Stability verification and closure
1. Monitor for recurrence of Event 4740 and wrong-password Events 4776/4771 for at least 15-30 minutes.
2. If no recurrence is observed, close incident with root-cause note: stale credential retries causing user lockout.
