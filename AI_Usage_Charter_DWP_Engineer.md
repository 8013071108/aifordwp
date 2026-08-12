# Personal AI Usage Charter — DWP Desktop/Endpoint Engineer
**Version 1.0 | Date: 2026-08-03 | Owner: [Your Name]**

---

## Purpose
This charter sets my personal rules for using public AI assistants (e.g. Microsoft Copilot, ChatGPT, Gemini) in my day-to-day engineering work. It supplements, and does not replace, DWP's official AI policy and the Civil Service Code.

---

## 1. Tasks I WILL use a public AI assistant for

| Task | Example |
|---|---|
| Writing and debugging scripts | PowerShell, Python, batch — logic only, no real data |
| Config file syntax | Group Policy ADMX templates, registry keys, SCCM/Intune JSON |
| General documentation | How-to guides, runbooks, KB articles (no system-specific secrets) |
| Learning and research | Understanding a Windows API, CVE explanation, protocol behaviour |
| Code review support | Reviewing logic in a script I have already written |
| Test data generation | Fictional names/addresses for lab/test environments only |
| Regex and query construction | Log parsing patterns, KQL/SQL against generic schemas |

---

## 2. Tasks I will NOT use a public AI assistant for

- **Anything involving real end-user data** — case reference numbers, NI numbers, names, addresses, benefit claim details, or any DWP-held personal data.
- **Live system credentials** — passwords, API keys, service account tokens, certificate private keys, or PAT tokens.
- **Internal network details** — IP ranges, domain names, internal URLs, server names, or firewall/proxy rules that reveal DWP topology.
- **Security tool configuration** — AV exclusions, EDR policies, vulnerability scan results, or SIEM alert logic.
- **Incident response details** — specifics of an active incident, affected asset names, or exploit details on DWP infrastructure.
- **Any document marked OFFICIAL-SENSITIVE or above** — do not paste, summarise, or paraphrase classified content into any public AI chat.

---

## 3. Data-Handling Rule — PII and Credentials

> **Before I send anything to a public AI, I ask: "Could this identify a real person or grant access to a real system?" If yes, I stop.**

**Practical steps:**
1. **Anonymise first.** Replace real values with placeholders (`<USERNAME>`, `<NI_NUMBER>`, `<SERVER_NAME>`) before pasting any config, log excerpt, or script snippet.
2. **Never paste from a live console.** If I need help debugging a live error, I retype the error message manually, omitting hostnames and user identifiers.
3. **Credentials stay in the vault.** Passwords and tokens are never typed into any AI chat, even as examples. Use `<PASSWORD>` as the placeholder.
4. **Assume no session privacy.** Public AI chats may be used for model training. Treat every prompt as potentially permanent and public.

---

## 4. "Generate Then Verify" Rule — Scripts and System Changes

AI-generated scripts and config changes are **drafts, not solutions**. I apply this checklist before any generated code touches a managed endpoint:

- [ ] **Read every line.** I can explain what each line does before I run it.
- [ ] **Check for destructive operations.** Identify any `Remove-`, `Delete`, `Format`, `rm -rf`, registry deletions, or firewall rule removals. Justify each one.
- [ ] **Test in an isolated lab VM first.** No generated script goes directly to production or to a user's machine without a lab run.
- [ ] **Validate against DWP baseline.** Confirm the change does not conflict with Group Policy, Intune compliance policies, or the endpoint hardening baseline.
- [ ] **Peer review for significant changes.** Any script that modifies system-wide settings, scheduled tasks, or security controls gets a second pair of eyes from a colleague.
- [ ] **Log what I deployed and why.** Record the change in the ITSM ticket, noting that AI assistance was used in drafting.

> **The AI generates a starting point. I own the outcome.**

---

## Acknowledgement
By following this charter I acknowledge that I remain fully responsible for any code, configuration, or content I deploy, regardless of how it was produced.

**Signed:** _______________________  **Date:** _______________
