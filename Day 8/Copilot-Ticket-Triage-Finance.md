# Copilot Ticket Triage - Finance
Date: 2026-08-13

## Ticket 1
Ticket: Finance lead cannot get Copilot to summarise Q3 board pack in SharePoint, but can open the file manually.
- Likely cause (ranked):
  1. Sensitivity label restriction
  2. Data indexing lag
  3. Permissions/access boundary
- Fastest check: Check the board pack file sensitivity label and its Copilot/AI access policy setting.
- Is this actually a Copilot bug?: No. The evidence points first to policy/access controls on sensitive content, not a product defect.

## Ticket 2
Ticket: New hire started yesterday; Copilot in Outlook seems to know nothing about recent emails.
- Likely cause (ranked):
  1. Data indexing lag
  2. License/client prerequisite issue
  3. Permissions/access boundary
- Fastest check: Confirm mailbox/content indexing status and expected indexing delay for a newly provisioned user.
- Is this actually a Copilot bug?: No. New-user timing strongly fits indexing delay or setup prerequisites.

## Ticket 3
Ticket: HR manager asks Copilot in Word to use sensitive salary spreadsheet and receives "I don’t have access to that content."
- Likely cause (ranked):
  1. Sensitivity label restriction
  2. Permissions/access boundary
  3. Data indexing lag
- Fastest check: Check the spreadsheet sensitivity label permissions and whether the HR manager has effective rights under that label.
- Is this actually a Copilot bug?: No. The explicit access-denied message aligns with data access policy/permission controls.

## Ticket 4
Ticket: Sales rep in Teams cannot find a client contract shared through a guest link from another organization.
- Likely cause (ranked):
  1. Guest/external sharing limitation
  2. Permissions/access boundary
  3. Data indexing lag
- Fastest check: Verify whether the document is externally shared via guest link only and whether Copilot can ground on that external source in this tenant setup.
- Is this actually a Copilot bug?: No. This matches an external-sharing boundary scenario.

## Ticket 5
Ticket: IT admin reports Copilot stopped for the whole Finance team this morning, but was fine yesterday.
- Likely cause (ranked):
  1. License/client prerequisite issue
  2. Permissions/access boundary
  3. Genuine Copilot fault
- Fastest check: Check whether Finance users still have active Copilot add-on assignments and enabled service plans.
- Is this actually a Copilot bug?: Unclear. A tenant-wide team impact could be service-side, but license/assignment changes are faster and more probable first checks.

## Ticket 6
Ticket: Manager says Copilot summarized a file they forgot they could access.
- Likely cause (ranked):
  1. Permissions/access boundary
  2. Sensitivity label restriction
  3. Data indexing lag
- Fastest check: Review effective permissions on the source folder/file for that manager account.
- Is this actually a Copilot bug?: No. This indicates overshared access boundaries, not Copilot malfunction.

## Ticket 7
Ticket: Analyst gets generic answers; Copilot appears not to use internal SharePoint content.
- Likely cause (ranked):
  1. License/client prerequisite issue
  2. Permissions/access boundary
  3. Data indexing lag
- Fastest check: Confirm user has the correct Copilot license, is signed into supported Microsoft 365 desktop/web clients, and is using enterprise-grounded Copilot mode.
- Is this actually a Copilot bug?: Unclear. Behavior often matches licensing/client mode or access scope issues before product defect.

## Ticket 8
Ticket: Executive assistant in Outlook cannot see shared mailbox calendar they manage for a director.
- Likely cause (ranked):
  1. Permissions/access boundary
  2. License/client prerequisite issue
  3. Data indexing lag
- Fastest check: Validate delegated/shared mailbox calendar permissions and whether that delegated content is in-scope for Copilot in the current client.
- Is this actually a Copilot bug?: No. This most likely reflects delegated access boundaries rather than a core Copilot failure.
