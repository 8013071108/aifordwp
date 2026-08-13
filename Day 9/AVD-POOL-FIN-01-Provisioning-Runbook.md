# AVD Provisioning Runbook - POOL-FIN-01

## Purpose
Document the end-to-end provisioning workflow used to stand up the Azure Virtual Desktop environment for the Finance migration lab.

## Target Build
- Subscription: `b0c21333-37f1-4a78-b696-444e372e201e`
- Resource group: `dwp-lab-rg`
- Region: `Central US`
- Microsoft 365 tenant: `zippyops.in`
- User: `p54@zippyops.in`
- Host pool: `POOL-FIN-01`
- Workspace: `FinBridge-Workspace`

## Provisioning Sequence

1. Confirm the signed-in Azure identity and RBAC scope.
   - Verify the current CLI account.
   - Check the role assignment on the target subscription and resource group.
   - Stop immediately if role assignment permissions are not available.

2. Set the working subscription.
   - Target subscription: `b0c21333-37f1-4a78-b696-444e372e201e`
   - Confirm the CLI context switched successfully before creating any resources.

3. Verify the resource group exists in the target region.
   - Resource group: `dwp-lab-rg`
   - Region: `Central US`

4. Create the AVD workspace.
   - Name: `FinBridge-Workspace`
   - Purpose: publish the desktop application group to end users.

5. Create the pooled host pool.
   - Name: `POOL-FIN-01`
   - Load balancing: breadth-first
   - Max sessions per host: `5`

6. Create the desktop application group and register it to the workspace.
   - Application group type: Desktop
   - Link the desktop app group to `FinBridge-Workspace`
   - Assign the target user to the app group so the published desktop appears in the AVD client.

7. Create the session host VM.
   - Image: Windows 11 multi-session, AVD-optimised gallery image
   - Size: `Standard_B2ms`
   - Security type: Trusted Launch
   - Secure Boot: enabled
   - vTPM: enabled
   - Join type: Microsoft Entra ID joined only

8. Register the VM as an AVD session host.
   - Install or register the AVD agent and bootloader as required.
   - Confirm the session host appears in the host pool.

9. Assign user access for both access paths.
   - For the published desktop: assign `Desktop Virtualization User` on the desktop application group.
   - For direct Entra ID RDP to the VM: assign `Virtual Machine User Login` on the VM or resource group.
   - Use `Virtual Machine Administrator Login` instead if elevated admin access is required for troubleshooting.

10. Validate the session host state.
    - Confirm the host reports `Available` in the host pool.
    - If the host does not become healthy, inspect the VM-side logs and AVD services before retrying deployment commands.

## Verification Points
- Azure CLI identity confirmed before any deployment.
- Subscription context switched successfully.
- Resource group and region matched the target design.
- Workspace and desktop app group were linked.
- Session host was created with Trusted Launch and Entra ID join settings.
- User role assignments were in place for AVD client access and direct VM sign-in.
- Session host status was checked at the end and confirmed from the host pool.

## Scripts
- [01-provision-pool-fin-01.ps1](01-provision-pool-fin-01.ps1) provisions the host pool, workspace, desktop app group, and user role assignment flow.
- [02-verify-pool-fin-01.ps1](02-verify-pool-fin-01.ps1) validates the deployed workspace, host pool, app group, and user RBAC.
- [03-diagnose-session-host.ps1](03-diagnose-session-host.ps1) captures the first-pass checks for a session host that does not become available.

## Notes
- If the session host fails to reach `Available`, use the VM's event logs, AVD agent health, and service state to isolate the failure instead of repeating the same create command.
- Keep this document aligned with the final deployed resource names if any naming changes are introduced later.