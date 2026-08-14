# Floor 6 Copilot Access Concern - Ranked Hypotheses

## 1) The user already had valid access to the client matter through direct or inherited permissions
- Why this cause fits the scope facts:
  - User perception and actual access are not always the same, especially in complex Legal content structures.
  - With no audit logs, permission review, or source validation yet completed, the most likely explanation is an existing but unrecognized permission path.
  - This fits the default rule to prefer access-boundary explanations before assuming a product defect.
- The single fastest check to confirm or eliminate it:
  - Check whether the user currently has direct or inherited permission to the client matter location.
- Evidence that would strengthen the hypothesis:
  - The user is found in a site, library, matter, or security group with read access.
  - Access is inherited from a parent SharePoint site, M365 group, or document library.
  - The source cited by Copilot maps to a location the user can already open manually.
- Evidence that would weaken the hypothesis:
  - Permission review shows the user has no direct or inherited access at all.
  - Manual access to the source location is denied.
- Whether this would indicate:
  - Permissions issue

## 2) Oversharing or unintended sharing granted access to the matter
- Why this cause fits the scope facts:
  - In M365 environments, content is often exposed by sharing links, broad site permissions, or group membership that users do not realize they have.
  - A Legal user seeing an unexpected matter can fit a sharing problem more readily than a Copilot malfunction.
  - No sharing history or permission audit has yet been reviewed, so this remains a strong early hypothesis.
- The single fastest check to confirm or eliminate it:
  - Review the document or matter location sharing settings and effective access for the user.
- Evidence that would strengthen the hypothesis:
  - An organization-wide, team-wide, or matter-level share includes the user.
  - A link-based share or broad group assignment exposes the content.
  - Other unintended recipients also appear in access lists.
- Evidence that would weaken the hypothesis:
  - No share links, broad access groups, or expanded site permissions are present.
  - Access lists are tightly scoped and exclude the user.
- Whether this would indicate:
  - Oversharing issue

## 3) Recent document management application rollout changed content location, sharing, or surfaced content to searchable sources
- Why this cause fits the scope facts:
  - The Friday application rollout is the only named recent change besides Win11 migration and Intune enrolment.
  - If the new document management application altered where content is stored, synchronized, exposed, or permissioned, it could change what Copilot can surface.
  - This is still to confirm and should not outrank basic permission explanations without evidence.
- The single fastest check to confirm or eliminate it:
  - Determine whether the reported client matter is stored in or linked through the newly deployed document management application and whether rollout changed its access path.
- Evidence that would strengthen the hypothesis:
  - The client matter source is managed by the new application.
  - Access behavior changed only after Friday’s rollout.
  - The rollout introduced a new sync, connector, or sharing path affecting matter visibility.
- Evidence that would weaken the hypothesis:
  - The reported matter has no connection to the new application.
  - Access state and source location are unchanged from before rollout.
- Whether this would indicate:
  - Permissions issue, to confirm
  - Oversharing issue, to confirm
  - Copilot indexing issue, to confirm

## 4) Copilot surfaced content from a source the user could technically access, but indexing/search context made the result appear unexpected
- Why this cause fits the scope facts:
  - Copilot can only act on accessible content, but surfaced results may feel surprising if indexing, naming, or context makes the source unclear.
  - With no Copilot traces, prompt transcript, source citation, or audit review yet, a search/indexing interpretation issue remains plausible.
  - This ranks below direct permission and oversharing because accessible-content explanations are more likely than a pure indexing problem.
- The single fastest check to confirm or eliminate it:
  - Capture the exact Copilot response and source citation, then confirm whether that source is already accessible to the user.
- Evidence that would strengthen the hypothesis:
  - Copilot cites a valid accessible source but the matter name/context is ambiguous or unexpected.
  - The user can open the cited source manually once shown the exact location.
  - Search/indexing returns the same content outside Copilot.
- Evidence that would weaken the hypothesis:
  - Copilot provides no valid source path.
  - The cited source is not accessible to the user.
- Whether this would indicate:
  - Copilot indexing issue, to confirm

## 5) Genuine Copilot product defect causing content to surface outside the user’s effective access boundary
- Why this cause fits the scope facts:
  - This remains possible in theory, but it should rank last because no permissions review, audit evidence, source validation, or Copilot trace has yet been completed.
  - The current scope facts do not yet support bypass of an actual access boundary.
  - By default, permissions, inherited access, oversharing, or content-source explanations are more likely.
- The single fastest check to confirm or eliminate it:
  - Prove that the user has no direct, inherited, or shared access to the cited source and that Copilot still surfaced it with reproducible evidence.
- Evidence that would strengthen the hypothesis:
  - Permissions and sharing checks conclusively show no access path for the user.
  - Audit evidence shows no legitimate access route to the source.
  - Copilot reproducibly returns the same protected content despite denied access.
- Evidence that would weaken the hypothesis:
  - Any valid permission, inherited access, or share is found.
  - The result is explained by normal accessible content behavior.
- Whether this would indicate:
  - Genuine Copilot defect
