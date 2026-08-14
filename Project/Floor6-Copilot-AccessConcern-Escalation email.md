Subject: Floor 6 Legal Copilot access concern - escalation update

Incident Summary
A Floor 6 Legal user reported that Microsoft 365 Copilot surfaced a client matter she believed she had never had access to. The report is being handled as a potential access-boundary and data exposure concern.

Business Risk
This is a high-priority Legal information risk because the report involves client matter content. The key risk is whether Copilot surfaced content outside the user’s actual permissions or whether the user already had a valid access path.

What Was Reported
The user said Copilot returned a client matter she believed she had never accessed before. The report came from Floor 6 Legal after the recent Windows 11 migration and Intune enrolment.

What Investigation Confirmed
Current review confirms the issue is a valid escalation and must be treated as a high-risk access concern until permissions and audit evidence are fully verified. At this stage, unauthorized access has not been confirmed, and the user’s actual permission path remains to confirm.

What Investigation Ruled Out
We have not confirmed a Copilot product defect. We have also not confirmed that the Friday document management app rollout caused the issue. No final evidence currently proves unauthorized access, and no conclusion should be drawn until permissions, audit logs, and content access paths are fully verified.

Current Status
The investigation is incomplete and remains open. The incident is still being treated as a potential access-boundary concern with high business sensitivity.

Containment Actions
The incident is being handled as high risk while the team reviews SharePoint/OneDrive permissions, Microsoft 365 audit records, Purview records, and the exact Copilot response context.

Recommended Next Steps
Confirm the user’s actual permissions to the client matter location, including direct, inherited, and group-based access. Review audit and Purview evidence, then compare the Copilot response with the permitted content source and labels before deciding whether any remediation is needed.

Next Update
Next update will be provided after the permission and audit evidence review is completed.