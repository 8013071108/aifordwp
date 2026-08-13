# Microsoft 365 Copilot Readiness - Tiered Priorities (Finance)
Date: 2026-08-13
Scope: Finance department (~200 users), high-sensitivity data

## 1) MUST complete before rollout (blocking)

- Permissions and oversharing hard gate for SharePoint and OneDrive
  - Complete full access audit of Finance sites/libraries/folders and OneDrive sharing defaults
  - Remove broad legacy/inherited access from 2019 migration
  - Validate least-privilege access on payroll, board packs, M&A, and client financial data
  - Run discoverability/oversharing tests across role-based test accounts
  - Obtain Security + Compliance + Finance data-owner sign-off

- Identity and access control baseline
  - MFA enforced for all pilot users
  - Conditional Access controls validated for compliant device and access conditions

- Sensitivity protection baseline
  - Finance labels in place and enforced where required
  - High-confidential classes protected with correct restrictions

- Core technical viability checks
  - Copilot add-on licenses assigned to pilot cohort
  - Supported Microsoft 365 Apps client versions confirmed on pilot devices

## 2) SHOULD complete before rollout (high risk if skipped)

- Full department-wide client update compliance (beyond pilot)
- Residual-risk register for access exceptions with named owners/due dates
- End-to-end protected-document behavior tests across typical Finance collaboration flows
- Support model readiness (service desk routing, triage scripts, escalation paths)

## 3) CAN complete during/after rollout (lower risk)

- Extended enablement content beyond baseline training (advanced prompt clinics, role-specific playbooks)
- Broader communications refinements after first-week feedback
- Long-tail cleanup of low-impact library metadata and information architecture improvements

## Why permissions and oversharing are MUST in this Finance context

Permissions/oversharing belongs in MUST because this is the control that determines what Copilot can surface to users at all. In this Finance environment, the main business risk is not whether Copilot launches, but whether payroll, board, M&A, or client financial content is unintentionally exposed to the wrong audience through legacy inherited access that has not been audited since 2019.

Licensing and client version checks are technically simpler and necessary, but they mainly confirm service availability, not data boundary correctness. If licensing or client versions are wrong, rollout is delayed or users see feature issues; if permissions are wrong, sensitive information may be exposed immediately at first use. That impact profile makes permissions/oversharing a blocking prerequisite ahead of simpler technical validation.
