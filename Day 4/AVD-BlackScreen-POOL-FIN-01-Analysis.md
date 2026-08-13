# AVD Incident Analysis — Black Screen Post Login (POOL-FIN-01)

## Scope Facts

| Factor | Detail |
|--------|--------|
| **Symptom** | Blank screen post login — clears after ~30s for some users, persists for others |
| **Affected pool** | POOL-FIN-01 (~40% of users affected) |
| **Unaffected pool** | POOL-FIN-02 — completely unaffected, was NOT updated |
| **Since** | ~07:00 this morning |
| **Change** | Overnight image update to POOL-FIN-01 at 02:00 |

---

## Discriminator Rule

> POOL-FIN-02 shares the same users, network, storage, and AD/GP environment as POOL-FIN-01 but runs the **old image** and is completely unaffected.
> Any cause that would also affect POOL-FIN-02 is eliminated or demoted. Only causes **contained within the image boundary** are credible at the top of the ranking.

---

## Ranked Hypotheses (Most Probable First)

### 1. Shell / Explorer Launch Failure in the New Image
**Why it fits the scope:**
A broken `userinit.exe` path, corrupted `explorer.exe`, or a registry key misconfigured in the new image would prevent Explorer from launching — presenting as a black screen. The 30s self-resolution matches a delayed shell retry. This cause is **fully image-contained**: POOL-FIN-02 runs the old image, has the old shell config, and is unaffected — the fault boundary maps cleanly onto the image boundary.

**Fastest check:**
```
tasklist /fi "imagename eq explorer.exe"
```
Run on an affected POOL-FIN-01 host during an active black screen. If Explorer is absent, the shell is not launching from the new image.

---

### 2. Logon Script Hang Introduced by the Image Update
**Why it fits the scope:**
If the new image introduced or modified a logon script baked into the image (not GPO-delivered), POOL-FIN-02 would not have it and would be unaffected. The two-cohort behaviour — 30s self-resolve vs. persistent — maps to script completion vs. hang. Cause is **image-contained** provided the script is image-side.

**Fastest check:**
```
tasklist /v | findstr /i "wscript cscript cmd powershell"
```
Run during an active black screen on POOL-FIN-01. A running script process at logon time confirms this.

---

### 3. FSLogix Misconfiguration in the New Image
**Why it fits the scope:**
FSLogix registry settings live in the image. A misconfigured FSLogix version or registry key in the new image would cause profile containers to fail or time out on mount — users whose profiles attach slowly get the 30s delay; persistent cases have a full mount failure. **Mostly image-contained**, with a minor caveat: FSLogix also depends on shared storage (same VHD store for both pools), so a storage-side issue would affect both pools. POOL-FIN-02 being clean argues this is image-registry-side, not storage-side.

**Fastest check:**
```powershell
Get-Content "C:\ProgramData\FSLogix\Logs\Profile\*.log" -Tail 50
```
Look for `ERROR` or `VHD attach failed` entries timestamped at login on a POOL-FIN-01 host.

---

### 4. Display Driver / GPU Adapter Issue in the New Image
**Why it fits the scope:**
Driver packages are image-contained. If the update changed the virtual display adapter driver, only POOL-FIN-01 sessions would be affected — the POOL-FIN-02 discriminator fits cleanly. Ranked lower because black screens from driver issues typically do not self-resolve after 30s, which weakens the fit against the two-cohort symptom pattern.

**Fastest check:**
```powershell
Get-WinEvent -LogName System |
  Where-Object {$_.Message -match "display|video|GPU" -and $_.Level -le 3} |
  Select-Object TimeCreated, Message -First 10
```
Run on a POOL-FIN-01 host post-incident.

---

### 5. Group Policy Processing Delay
**Why it fits the scope:**
A slow or broken GP extension (e.g., logon script, Drive Maps, AppLocker) could block the desktop from rendering. **However, this is the weakest hypothesis against the discriminator.** GPO is delivered from AD, not from the image — POOL-FIN-02 users hit the same policies at logon. The fact that POOL-FIN-02 is completely clean strongly argues against a GPO root cause, unless a specific policy is scoped exclusively to POOL-FIN-01 hosts (possible but unconfirmed).

**Fastest check:**
```
gpresult /h gpresult-pool-fin-01.html
```
Compare output between a POOL-FIN-01 and POOL-FIN-02 session to identify any policies that differ.

---

## Ranking Summary

| Rank | Cause | Image-Contained? | POOL-FIN-02 Discriminator Fit |
|------|-------|-----------------|-------------------------------|
| 1 | Shell/Explorer failure | ✅ Fully | Perfect — clean image boundary |
| 2 | Logon script hang (image-side) | ✅ Fully | Strong — if script is image-baked |
| 3 | FSLogix misconfiguration | ✅ Mostly | Good — minor shared-storage caveat |
| 4 | Display driver/GPU issue | ✅ Fully | Clean fit, but 30s self-resolve is atypical |
| 5 | GP processing delay | ❌ Not image-contained | Contradicted by POOL-FIN-02 being clean |

---

## Status

> Analysis in progress — no root cause committed. Check hypotheses #1 and #2 in parallel first; they are fastest to confirm and cover the highest-probability causes. The 40/60 user split on POOL-FIN-01 suggests a per-user or per-profile condition rather than a universal image-level shell break.

---

## Addendum — Event Evidence Review (2024-03-15 07:00-07:30)

### Evidence Ingested

Affected host: **SHFIN-01-A** (POOL-FIN-01)

- 07:02:10 — TerminalServices-LocalSessionManager **Event 21**: Session logon succeeded (FINBRIDGE\\mlopez, Session 3)
- 07:02:14 — Kernel-General **Event 1**: Boot time 02:03:11 (post overnight image update restart)
- 07:02:16 — Application Error **Event 1000**: `dwm.exe` crash, faulting module `igdumd64.dll`, exception `0xc0000005`
- 07:02:17 — TerminalServices-LocalSessionManager **Event 40**: Session disconnected (FINBRIDGE\\mlopez, Session 3)
- 07:02:18 — Desktop Window Manager **Event 9009**: DWM exited with code `0x40010004`
- 07:02:44 — TerminalServices-LocalSessionManager **Event 21**: Reconnect logon succeeded (Session 3)
- 07:02:46 — Application Error **Event 1000**: repeat `dwm.exe` crash in `igdumd64.dll`
- 07:02:47 — TerminalServices-LocalSessionManager **Event 40**: Session disconnected
- 07:03:01 — Desktop Window Manager **Event 9009**: DWM exited again
- 07:03:10 — TerminalServices-LocalSessionManager **Event 21**: Second reconnect succeeded (Session 4)
- 07:08:22 — TerminalServices-LocalSessionManager **Event 21**: Logon succeeded (FINBRIDGE\\akapoor, Session 5)
- 07:08:24 — Application Error **Event 1000**: repeat `dwm.exe` crash in `igdumd64.dll`

Comparison host: **SHFIN-02-A** (POOL-FIN-02, unaffected, pre-update image)

- 07:01:44 — TerminalServices-LocalSessionManager **Event 21**: Session logon succeeded
- 07:01:46 — Desktop Window Manager **Event 9011**: DWM started successfully
- No Application Error Event 1000 entries in the same window

### Reviewed Hypotheses Against Evidence

#### 1) Shell / Explorer launch failure in new image
**Judgment:** Contradicted by current evidence.

**Determining events:**
- 07:02:16 Event 1000 (`dwm.exe` fault in `igdumd64.dll`)
- 07:02:18 Event 9009 (DWM exit)
- 07:01:46 Event 9011 on unaffected pool (normal DWM startup)

#### 2) Logon script hang introduced by image update
**Judgment:** Contradicted by current evidence.

**Determining events:**
- 07:02:10 Event 21 (logon succeeded)
- 07:02:16 Event 1000 (immediate DWM crash)
- 07:02:17 Event 40 (disconnect right after crash)

#### 3) FSLogix misconfiguration in new image
**Judgment:** Neutral with this evidence set.

**Determining events:**
- No FSLogix-specific events/log lines supplied in this export window
- Available high-signal events point to DWM/graphics crashes, but do not directly prove/disprove FSLogix

#### 4) Display driver / GPU adapter issue in new image
**Judgment:** Supported by current evidence.

**Determining events:**
- 07:02:16 Event 1000 (`dwm.exe` faulting module `igdumd64.dll`)
- 07:02:46 Event 1000 (repeat same fault)
- 07:08:24 Event 1000 (same fault on another user session)
- 07:02:18 and 07:03:01 Event 9009 (DWM exits)
- 07:01:46 Event 9011 on unaffected pool with no matching Event 1000

#### 5) Group Policy processing delay
**Judgment:** Contradicted by current evidence.

**Determining events:**
- 07:02:10 Event 21 (logon succeeded)
- 07:02:16 Event 1000 (DWM crash signature)
- 07:02:17 Event 40 (disconnect), then repeat crash/disconnect sequence

### Surviving Hypothesis (Post-Elimination)

Display driver or GPU stack regression introduced by the POOL-FIN-01 image update, observed as repeated `dwm.exe` crashes in `igdumd64.dll`.

---

## Resolution Steps (Detailed)

### 1. Immediate Containment
1. Pause new user assignments to POOL-FIN-01.
2. Route user sessions to POOL-FIN-02 where capacity permits.
3. Drain or temporarily disable the most impacted POOL-FIN-01 session hosts.

### 2. Change Freeze and Evidence Preservation
1. Stop further rollout of the current POOL-FIN-01 image.
2. Record exact image build and installed display driver package versions from one impacted host.
3. Preserve event logs and crash metadata for the incident record.

### 3. Fastest Service Restoration
1. Roll back POOL-FIN-01 to the pre-update image baseline (same generation currently stable in POOL-FIN-02).
2. Recreate or reimage affected hosts using rollback image.
3. Validate successful logon and desktop render before reopening assignments.

### 4. Permanent Fix Image
1. Build a new candidate image from known-good baseline.
2. Remove the problematic graphics driver package tied to `igdumd64.dll` crash behavior.
3. Install a validated, approved display driver version for the AVD VM profile.
4. Pin driver version in image pipeline to prevent unintended automatic replacement.

### 5. Validation Gate Before Production
1. Deploy the fixed image to a limited canary ring.
2. Run repeated login and reconnect tests across multiple user profiles.
3. Require all acceptance checks to pass:
- No Application Error Event 1000 with `dwm.exe` + `igdumd64.dll`
- No DWM Event 9009 during logon/reconnect window
- No abnormal post-logon Event 40 disconnect pattern

### 6. Controlled Rollout
1. Roll out by rings (10%, 50%, then 100%) across POOL-FIN-01.
2. Observe at least one peak login window between each ring.
3. Trigger immediate rollback if the DWM crash signature reappears.

### 7. Hardening and Prevention
1. Add image-release gate tests for synthetic AVD login and DWM health.
2. Add monitoring alert correlation:
- Event 1000 (`dwm.exe` + `igdumd64.dll`)
- Event 9009 within 60 seconds of Event 21
- Event 40 disconnect shortly after Event 21
3. Require side-by-side comparison against unchanged control pool before broad rollout.
