# Intune Windows App Onboarding Guide (Day 7)
## Worked Example: FinBridge Connect v3.1

Purpose: This guide shows a DWP engineer, step by step, how to add a Windows app to the Intune app catalog before any phased rollout begins.

Important: Intune UI labels can vary between tenant versions and Microsoft UI updates. At every step below, verify the live label in your tenant rather than relying only on this guide text.

---

## 1. Prerequisites (complete before you start)

1. Confirm you have the correct Intune role permissions to create and assign apps.
2. Confirm you have the packaged app file for the Win32 deployment:
	- `FinBridgeConnect-v3.1.intunewin`
3. Confirm deployment command lines:
	- Install command: `FinBridgeConnect_Setup.exe /silent`
	- Uninstall command: `FinBridgeConnect_Setup.exe /uninstall /silent`
4. Confirm detection rule target:
	- Registry path: `HKLM\SOFTWARE\FinBridge\Connect`
	- Value name: `Version`
	- Expected value: `3.1`
5. Confirm your pilot Azure AD group exists (small controlled set of test devices/users, not full fleet).

---

## 2. Where to add an app in Intune (navigation path)

1. Open Microsoft Intune admin center in your browser.
2. Navigate to:
	- `Apps` -> `All apps` -> `Add`
3. UI label warning: In some tenants this may appear as `Apps` -> `Windows` -> `Add`, or with slightly different wording. Verify against your live tenant menu.

Outcome: You are on the app creation flow where app type is selected.

---

## 3. Choose the correct app type

At the `Add app` or `Select app type` step, choose based on app source:

1. For FinBridge Connect v3.1 packaged as `.intunewin`:
	- Select `Windows app (Win32)` (commonly used for `.intunewin` packages).
	- Do not select `Line-of-business app` for this package type.
	- UI label warning: Some tenants or docs may refer to this as Windows LOB/Win32 flow. Verify the option that accepts `.intunewin` upload.
2. For Microsoft Store apps:
	- Select `Microsoft Store app (new)` (label may vary slightly).
3. For a web shortcut/link:
	- Select `Web link`.

Outcome: Correct type selected for packaging and deployment model.

---

## 4. Create the Win32 app (FinBridge Connect v3.1)

1. In app type selection, choose the option that supports `.intunewin` and continue.
2. Confirm the selected type is `Windows app (Win32)` before upload.
3. Upload package file:
	- `FinBridgeConnect-v3.1.intunewin`
4. Complete required app fields under `App information` (label can vary):
	- Name: `FinBridge Connect`
	- Description: `FinBridge Connect desktop client version 3.1`
	- Publisher: `FinBridge`
	- Version: `3.1`
5. Optional but recommended:
	- Category, icon, and information URL for catalog clarity.
6. Select `Next` to move to Program settings.

UI label warning: This section may appear as `App information`, `Information`, or split across tabs. Verify live labels and required-field markers in your tenant.

---

## 5. Configure Program settings (required)

1. In `Program` (or equivalent section), enter:
	- Install command: `FinBridgeConnect_Setup.exe /silent`
	- Uninstall command: `FinBridgeConnect_Setup.exe /uninstall /silent`
2. Set install behavior/context:
	- Use `System` context for device-level deployment unless a user-context app is explicitly required.
3. Keep restart behavior aligned to packaging guidance (for pilot, suppress forced reboot unless mandatory).
4. Select `Next`.

UI label warning: `Install behavior` can appear as `System` vs `User`, sometimes under expanded options. Verify the context carefully; wrong context is a common failure cause.

---

## 6. Configure Requirements (required)

1. Set OS architecture requirement:
	- Choose architecture(s) supported by app package (typically `64-bit` for modern Windows endpoints).
2. Set minimum OS:
	- Choose minimum Windows version supported by FinBridge Connect v3.1 and your endpoint baseline.
3. Keep requirements strict enough to prevent incompatible installs.
4. Select `Next`.

UI label warning: Architecture and OS selectors may be in `Requirements`, `Minimum operating system`, or advanced filters. Verify actual field names in your tenant.

---

## 7. Configure Detection rules (required)

Goal: Tell Intune how to confirm installation succeeded.

1. In `Detection rules`, choose rule type appropriate to installer.
2. For this worked example, use registry-based detection:
	- Rule type: `Registry`
	- Key path: `HKLM\SOFTWARE\FinBridge\Connect`
	- Value name: `Version`
	- Detection method: `String comparison` (or equivalent)
	- Operator: `Equals`
	- Value: `3.1`
3. Validate architecture redirection setting if shown (32-bit vs 64-bit registry view) to match where installer writes the key.
4. Select `Next`.

Alternative detection options (when relevant):
- MSI product code detection (best when MSI product code is known and stable).
- File/Folder detection (specific path and file version/presence).

UI label warning: Detection UI can differ by tenant version; field names such as `Rule format`, `Detection method`, or `Associated with a 32-bit app` may vary.

---

## 8. Configure Return codes (required check)

1. Open `Return codes` section.
2. Confirm defaults and add custom codes only if FinBridge installer uses non-standard exits.
3. Baseline interpretation to verify:
	- `0` = Success
	- `3010` = Soft reboot required (commonly treated as success with restart)
	- `1641` = Hard reboot initiated (commonly treated as success/reboot)
	- Any unspecified non-zero = Failure (unless explicitly mapped)
4. Save and continue.

UI label warning: Return code categories may be shown as `Success`, `Soft reboot`, `Hard reboot`, `Retry`, `Failed`. Verify exact mapping in your tenant.

---

## 9. Review and create app

1. Review all sections: App info, Program, Requirements, Detection rules, Return codes.
2. Select `Create`.
3. Wait for app object creation to complete.

Outcome: FinBridge Connect v3.1 now exists in Intune app catalog.

---

## 10. Assignment basics (Required vs Available vs Uninstall)

1. Open the new app and go to `Assignments`.
2. Understand assignment types:
	- `Required`: Intune installs automatically on targeted devices/users.
	- `Available for enrolled devices` (or similar): App is offered in Company Portal; user initiates install.
	- `Uninstall`: Intune removes the app from targeted devices/users.
3. For first deployment, assign to a small pilot group only.

Why pilot first, not 10,000 devices:
- Limits blast radius if install command, detection, or requirements are wrong.
- Allows validation of user impact, restart behavior, and compatibility.
- Reduces service desk load and incident risk.
- Enables evidence-based go/no-go before wider phased rollout.

Minimum pilot recommendation:
- Start with representative test devices (hardware models, OS versions, business units).
- Confirm success criteria before expanding ring size.

UI label warning: Assignment labels can vary (`Available`, `Available for enrolled devices`, etc.). Verify the live label and target type in your tenant.

---

## 11. Verification after assignment

### 11.1 Confirm app appears in catalog
1. Go to `Apps` -> `All apps`.
2. Search for `FinBridge Connect`.
3. Open app and verify metadata:
	- Name, Publisher, Version, assignment presence.
4. Confirm app type matches `.intunewin` Win32 flow.

### 11.2 Check install status on assigned test device
1. In the app object, open `Device install status` (or equivalent status blade).
2. Filter by pilot group device.
3. Validate reported state and timestamp.
4. On endpoint, validate local evidence:
	- App installed and launches.
	- Registry key present: `HKLM\SOFTWARE\FinBridge\Connect\Version = 3.1`.

### 11.3 Interpret common states
1. `Installed`:
	- Intune detected app successfully according to detection rule.
2. `Failed`:
	- Installation command ran but failed, or detection did not match expected result.
	- Check exit code, install logs, and detection rule path/value.
3. `Not applicable`:
	- Device/user does not meet targeting or requirement criteria (OS version, architecture, assignment scope).

UI label warning: Status blade names differ (`Device status`, `Monitor`, `Managed app status`). Verify equivalent status views in your tenant.

---

## 12. Completion checkpoint before phased rollout

Proceed to phased rollout planning only when all are true:
1. App object is created and visible in catalog.
2. Pilot assignment is configured correctly.
3. Pilot devices show expected status (majority `Installed`, no unexplained `Failed`).
4. Detection rule confirms installed version `3.1` via registry key.
5. Any `Not applicable` devices are explained and accepted.

If these checks are not met, fix packaging/configuration first and re-validate in pilot before expanding scope.
