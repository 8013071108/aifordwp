# Floor 6 Copilot Access Concern Triage

## Summary (one line)
One paralegal on Floor 6 reports that Microsoft 365 Copilot surfaced a client matter she believes she has never had access to, which must be treated as a high-priority access and data exposure concern until confirmed otherwise.

## Impact (who/how many/business urgency)
- Who: One paralegal reported the issue so far.
- How many: 1 confirmed report; wider impact is to confirm.
- Business urgency: Highest priority because this may indicate unintended access to legal client data.

## Known Facts
- Floor 6 has 45 Legal users.
- Floor 6 was recently migrated to Windows 11 and enrolled into Intune.
- A new document management app was rolled out on Friday afternoon.
- One paralegal says Microsoft 365 Copilot pulled up a client matter she believes she has never had access to.
- No proof yet that this is a Copilot bug; permissions, access boundaries, indexing, sharing, and sensitivity label evidence must be checked first.

## Missing Information to Gather
- Exact client matter name and the exact Copilot prompt/response, to confirm.
- Whether the user actually has permission to the client matter location, to confirm.
- Whether the matter is stored in SharePoint, OneDrive, Teams, or another source, to confirm.
- Whether access is direct, inherited, via group membership, or via sharing link, to confirm.
- Whether sensitivity labels or policy rules were applied to the source content, to confirm.
- Whether other authorized users can reproduce the same Copilot result, to confirm.
- Whether recent app rollout or migration changes altered access, indexing, or sharing, to confirm.

## Likely Category
Permissions / access boundary / search-index / sensitivity-label exposure issue, to confirm.

## Evidence to Collect
Check these first:
- SharePoint and OneDrive permissions for the client matter location
- Microsoft 365 audit logs for file access and Copilot-related activity
- Purview audit and search results for the matter and related content
- Sensitivity labels on the source document or site
- Document access history and sharing history
- Copilot response context if available, including source citations
- Group membership and inherited access paths for the paralegal
- Whether the user actually has permission to the client matter location
- Any recent policy or app deployment affecting Floor 6 that could alter access or indexing

## Suggest First Diagnostic Step
Capture the exact Copilot prompt and response, then verify the paralegal's permissions and inherited access path to the client matter location in SharePoint/OneDrive before looking at indexing or app-change hypotheses.
