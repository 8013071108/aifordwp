# Project Reasoning Standard

All conclusion-bearing documents in the Project directory must show the reasoning behind the conclusion, not only the answer.

Required rule:
- If a document states a conclusion, likely category, urgency ranking, likely cause, or status judgment, it must also state the basis for that judgment.

Minimum acceptable forms of reasoning:
- Evidence-based explanation
- Scope-fact explanation
- Comparison against an unaffected user/device/group
- Explicit `to confirm` statement where evidence is incomplete

Examples:
- Not acceptable: `Likely Category: Profile issue.`
- Acceptable: `Likely Category: Profile issue, to confirm. Reasoning: Multiple users show the same post-sign-in delay after migration, which fits a shared profile-load problem more than a single app failure.`

Use this rule for:
- Triage summaries
- Hypothesis lists
- RCA documents
- Escalation notes
- Knowledge articles where a technical conclusion is stated

Do not use this rule to add technical detail to plain-language end-user communications unless that reasoning is necessary for clarity.