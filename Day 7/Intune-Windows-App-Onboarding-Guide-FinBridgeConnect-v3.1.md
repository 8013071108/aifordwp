# Intune Windows App Onboarding Guide (Pre-Rollout)

Version: v1.0  
Date: 2026-08-13  
Status: Draft

This guide shows how to add a Windows app to Intune before phased rollout begins.
Worked example used throughout: **FinBridge Connect v3.1** packaged as **.intunewin**.

Important: Intune UI labels can vary by tenant version and Microsoft UI updates.  
For every step marked **[UI MAY VARY]**, verify the live label/path in your tenant instead of relying on text here.

## 1. Open the correct Intune location
1. Sign in to Intune admin center.
2. Go to **Apps** > **All apps**. **[UI MAY VARY]**
3. Select **+ Add** to create a new app entry.
Expected result: App creation pane opens.

## 2. Choose the correct app type
1. In the app type picker, select one of the following:
- **Windows app (Win32)** for `.intunewin` package (use this for FinBridge Connect v3.1).
- **Microsoft Store app (new)** for apps sourced from Microsoft Store.
- **Web link** for URL shortcuts only (not installable Win32 software).
2. Click **Select**.
Expected result: App configuration wizard starts for chosen type.

## 3. Add app package and required app information (Win32/.intunewin)
1. On **App information** page, upload `FinBridgeConnect_v3.1.intunewin` package. **[UI MAY VARY]**
2. Enter required fields:
- Name: `FinBridge Connect`
- Description: `FinBridge Connect desktop client v3.1`
- Publisher: `FinBridge`
- App version: `3.1`
3. Save/Next.
Expected result: Intune accepts package metadata and moves to Program settings.

## 4. Configure Program settings
1. In **Program** section, set install command:
- `FinBridgeConnect_Setup.exe /silent`
2. Set uninstall command:
- `FinBridgeConnect_Setup.exe /uninstall /silent`
3. Set **Install behavior** to:
- **System** context (recommended default for managed enterprise deployment unless app explicitly requires user context).
4. Save/Next.
Expected result: Program commands validated by wizard format checks.

## 5. Configure Requirements
1. In **Requirements** section, set OS architecture (for example, `64-bit`).
2. Set minimum operating system version to your Win11 baseline (for example, Windows 11 supported build baseline used by DWP).
3. Save/Next.
Expected result: App will only target devices meeting architecture and OS floor.

## 6. Configure Detection rules (registry-based, worked example)
1. In **Detection rules**, choose **Manually configure detection rules**. **[UI MAY VARY]**
2. Add a **Registry** rule with:
- Key path: `HKLM\SOFTWARE\FinBridge\Connect`
- Value name: `Version`
- Detection method: `String comparison`
- Operator: `Equals`
- Value: `3.1`
3. Save/Next.
Expected result: Intune can mark app installed when this exact registry value exists.

## 7. Configure Return codes
1. Open **Return codes** page. **[UI MAY VARY]**
2. Confirm standard mappings include:
- `0` = Success
- `3010` = Soft reboot
- `1641` = Hard reboot
3. Ensure non-success codes remain classified as Failure unless vendor documentation says otherwise.
4. Save/Next.
Expected result: Intune interprets installer exit behavior correctly.

## 8. Complete app creation
1. Review summary page fields.
2. Select **Create**.
3. Wait for app object to appear under **Apps > All apps**.
Expected result: FinBridge Connect v3.1 exists in Intune app catalog.

## 9. Assignment basics (must be done before rollout)
1. Open newly created app > **Assignments**. **[UI MAY VARY]**
2. Understand assignment types:
- **Required**: Installs automatically on targeted devices/users.
- **Available for enrolled devices**: User can install from Company Portal; not forced.
- **Uninstall**: Removes app from targeted devices/users.
3. Assign first to a small pilot group (for example 25-100 devices), not full fleet.
4. Do **not** assign Required directly to 10,000 devices on first release.
Expected result: Controlled exposure with low blast radius.

## 10. Why pilot first (before full 10,000)
1. A pilot catches packaging, detection, command-line, and compatibility issues early.
2. Pilot limits business impact if install fails or app is unstable.
3. Pilot provides real success/failure metrics for go/no-go decision.
Expected result: Safer and evidence-based progression to phased rollout.

## 11. Verify app appears correctly in catalog
1. Go to **Apps > All apps** and search `FinBridge Connect`.
2. Open app details and verify:
- Version = 3.1
- Commands are correct
- Detection rule matches registry path/value
Expected result: Catalog object is correct before assignment expansion.

## 12. Verify install status on assigned test device
1. Open app > **Monitor** > **Device install status** (or equivalent status blade). **[UI MAY VARY]**
2. Locate assigned pilot device.
3. Interpret status values:
- **Installed**: Detection rule matched; app considered successfully present.
- **Failed**: Install attempted but did not complete successfully (check return code/logs).
- **Not applicable**: Device does not meet requirements, is out of scope, or assignment/detection conditions do not apply.
Expected result: Clear per-device deployment outcome for pilot validation.

## 13. Minimum go-live check before phased rollout
1. Confirm pilot install success rate meets DWP threshold.
2. Confirm no widespread `Failed` pattern with same return code.
3. Confirm detection rule is not producing false install or false failure.
4. Only then expand to next rollout ring.
Expected result: App is ready for phased deployment.

## 14. Fast troubleshooting pointers
1. If many devices show **Failed**, verify install/uninstall command syntax first.
2. If many devices show **Installed** but app not launchable, re-check detection rule accuracy.
3. If many devices show **Not applicable**, re-check requirements (OS/min version/architecture) and assignment target group.
Expected result: Engineer can quickly isolate packaging vs targeting vs detection issue class.
