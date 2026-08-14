# Floor 6 Copilot Prevention Note

## Control Name
Copilot Sensitive Department Access Readiness Gate

## Purpose
Block Microsoft 365 Copilot enablement for a sensitive department until access-boundary checks prove that expected SharePoint/OneDrive permissions, inherited access paths, sharing state, and sensitivity labels are in place.

## Owner
Microsoft 365 Security and Compliance Administrator

## When It Runs
- Before Copilot is enabled for any sensitive department cohort.
- Re-run after any material change affecting content access for that cohort (for example, permission model change, sharing model change, or document management app rollout), to confirm exact trigger list in local change policy.

## Scope
- Department rollout cohort (for this incident pattern: Floor 6 Legal).
- SharePoint sites, libraries, and OneDrive locations used for legal/client matter content in scope for Copilot grounding (to confirm full repository list).
- Effective access paths: direct permission, inherited permission, group membership, and sharing-link access.
- Sensitivity labels applied to in-scope matter content.

## Validation Checks
1. Build and verify the in-scope content source list for the department (site/library/OneDrive paths), to confirm completeness.
2. For each in-scope source, run effective-access checks for sampled users from the rollout cohort:
- At least 1 user who reported concern or equivalent role sample.
- At least 1 expected-authorized user control sample.
3. Enumerate inherited access and group membership paths for sampled users at source level.
4. Enumerate active sharing links and broad sharing grants (for example, org-wide or broad group exposure) on in-scope matter locations.
5. Verify sensitivity label presence/state on sampled matter documents and confirm whether label behavior aligns with department policy (to confirm policy baseline reference).
6. Record a Copilot readiness decision per source: ready / blocked / to confirm.

## Pass Criteria
- 100% of in-scope sources have completed evidence records for effective access, inherited access, sharing state, and label state.
- 0 unresolved oversharing findings on in-scope sensitive matter locations.
- 0 sampled users without a confirmed and policy-valid access path for content they can retrieve.
- 0 sources left in ready status where evidence is missing or marked to confirm.

## Fail Criteria
- Any in-scope source lacks evidence for one or more required checks.
- Any unresolved oversharing or unexpected inherited access path is found.
- Any sampled result shows access behavior that cannot be explained by verified permissions/sharing/labels.
- Any source remains to confirm at planned Copilot enablement time.

## Required Action if Failed
- Do not enable Copilot for the department cohort.
- Open and track remediation actions for each failed source (permission correction, sharing removal, group/inheritance correction, label correction).
- Re-run the gate after remediation and require all pass criteria before enablement.
- Escalate as a security signal if access behavior remains unexplained after permission and sharing validation.

## Evidence Produced
- In-scope source register (site/library/OneDrive list) with owner and review timestamp.
- Effective-access output for sampled users per source.
- Inherited-access and group-membership path records for sampled users.
- Sharing-state evidence per source, including active sharing links and broad grants.
- Sensitivity label state evidence for sampled matter documents.
- Final gate decision log showing pass/fail per source and overall go/no-go for Copilot enablement.

## How This Would Have Prevented the Floor 6 Copilot Concern
This gate would have required proof of the Legal content access boundary before Floor 6 users began Copilot use. If permissions, inherited access, sharing, or label conditions were unclear or unresolved, Copilot enablement would have been blocked until remediation and re-validation completed. This would have reduced the chance of an unexpected content-surfacing concern reaching live user usage. The RCA does not yet prove unauthorized access or a Copilot defect, so this control is designed as a pre-enable access-readiness safeguard and not a defect-based conclusion.
