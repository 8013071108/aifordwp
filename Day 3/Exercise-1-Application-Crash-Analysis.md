# Exercise 1: Application Crash Analysis (Event Viewer - Application Log)

## Incident Summary
- Incident type: Repeated application crash
- Affected application: Microsoft Outlook (`OUTLOOK.EXE`)
- First observed crash: 2024-03-15 09:14:22
- Repeat crash: 2024-03-15 09:17:45
- Environment indicators:
  - Outlook version: 16.0.17126.20132
  - OS module involved: `KERNELBASE.dll` version 10.0.22621.3155
  - .NET Framework runtime present: v4.0.30319

## Raw Event Set Reviewed
1. Application Error, Event ID 1000, Error, 09:14:22
2. Application Error, Event ID 1000, Error, 09:17:45
3. Windows Error Reporting, Event ID 1001, Information, 09:18:01
4. .NET Runtime, Event ID 1026, Error, 09:18:05

## What Each Event ID Records

### Event ID 1000 (Source: Application Error)
Records a process crash at the Windows application layer, including:
- faulting executable
- faulting module
- exception code
- offset and process metadata

In this case it records Outlook crashing with:
- Exception code: `0xc0000005` (access violation)
- Faulting module: `KERNELBASE.dll`
- Same exception and fault offset across repeated crashes

### Event ID 1001 (Source: Windows Error Reporting)
Records Windows Error Reporting classification and crash bucketing details for the prior failure.
- Confirms this is treated as `APPCRASH`
- Provides fault bucket ID used for grouping similar failures

### Event ID 1026 (Source: .NET Runtime)
Records unhandled managed runtime exception termination.
- Confirms process termination due to unhandled exception
- In this incident: `System.AccessViolationException`

## Timeline Reconstruction
1. 09:13:44 - Outlook process starts.
2. 09:14:22 - Outlook crashes (Event 1000) with `0xc0000005` in `KERNELBASE.dll`.
3. 09:17:45 - Outlook crashes again with the same signature (Event 1000), indicating repeatability.
4. 09:18:01 - WER logs APPCRASH bucket (Event 1001), indicating crash telemetry captured.
5. 09:18:05 - .NET Runtime logs unhandled `System.AccessViolationException` (Event 1026).

## Technical Interpretation
- `0xc0000005` indicates invalid memory access (read/write/execute violation).
- Repeated identical fault offset strongly suggests a deterministic trigger path rather than random transient failure.
- Presence of Event 1026 with `System.AccessViolationException` indicates managed/unmanaged boundary or native code path issue that bubbles up and terminates Outlook.
- `KERNELBASE.dll` is frequently the faulting module reported for upstream caller issues; this does not by itself prove OS DLL corruption.

## Most Likely Cause (Ranked)

### 1) Outlook add-in or integration component causing invalid memory access (most likely)
Evidence:
- Same crash signature repeats within minutes.
- Access violation pattern is common with problematic COM add-ins or hooks.
- Outlook commonly loads third-party extensions that can trigger native faults surfaced via `KERNELBASE.dll`.

Checks:
- Launch Outlook in safe mode and compare stability.
- Review loaded add-ins and disable all non-essential add-ins.
- Re-enable add-ins one by one to isolate offender.

### 2) Corrupted Outlook profile or data interaction path
Evidence:
- Reproducible crash shortly after launch may correlate with profile initialization or mailbox/provider operations.

Checks:
- Test with a new Outlook profile.
- Start with cached mode adjustments and verify behavior.
- Validate mailbox store and OST/PST consistency.

### 3) Office build defect or incomplete Office patch state
Evidence:
- Specific Outlook build is provided; repeatable crash can map to known build regressions.

Checks:
- Verify Office channel and applied updates.
- Test latest available Office build for that channel.
- Compare against known issue advisories.

### 4) System file integrity issue (lower probability from these logs alone)
Evidence:
- Faulting module is Windows DLL, but no direct evidence of DLL corruption in provided events.

Checks:
- Run system integrity checks.
- Review CBS/DISM results for corruption findings.

## Evidence-Based Conclusion
The strongest current hypothesis is a repeatable Outlook execution path fault, most likely add-in/integration related, resulting in an access violation (`0xc0000005`) and unhandled runtime termination (`System.AccessViolationException`).

## Uncertainty and Verification Flags
The following items should be verified against Microsoft documentation or official support sources before final closure:
1. Exact interpretation guidance of the specific fault bucket ID `1847362910`.
2. Whether Outlook version `16.0.17126.20132` has a known crash issue matching this signature.
3. Recommended Microsoft-supported troubleshooting order for Outlook APPCRASH with Event 1000 + 1026 pattern.

## Recommended Remediation Plan (Practical Sequence)
1. Reproduce in Outlook safe mode to test add-in isolation.
2. Disable all non-Microsoft or non-essential add-ins and re-test.
3. Create a new Outlook profile and re-test.
4. Apply current Office updates for the assigned channel; restart and re-test.
5. Run Office Quick Repair, then Online Repair if needed.
6. If still failing, collect crash dump and correlate module call stack.
7. Run system integrity checks only if application-level steps do not resolve.

## Suggested Commands and Checks for Engineer Runbook
- Outlook safe mode launch:
  - `outlook.exe /safe`
- Office update verification:
  - Check Office Account update status in-app or enterprise software center tooling.
- System file checks (if required):
  - `sfc /scannow`
  - `DISM /Online /Cleanup-Image /RestoreHealth`

## Closure Criteria
1. Outlook launches and remains stable across multiple sessions.
2. No new Event ID 1000 for `OUTLOOK.EXE` in Application log for agreed monitoring window.
3. No new Event ID 1026 tied to Outlook process termination.
4. User confirms normal mail/calendar operations restored.
