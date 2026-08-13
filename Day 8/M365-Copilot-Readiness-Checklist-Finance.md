# Microsoft 365 Copilot Readiness Checklist - Finance Department (~200 users)
Date: 2026-08-13
Owner: DWP Engineering / M365 Service Owner

Purpose: Practical pre-rollout checklist for Copilot readiness in a high-sensitivity Finance environment.

Scope context:
- Department size: ~200 users
- Licensing baseline: M365 E5 in place
- Copilot add-on: Not yet assigned
- Data sensitivity: Payroll, board packs, M&A documents, client financial data
- Known risk: SharePoint permissions inherited from 2019 migration and never fully audited

## Release Rule (Read First)
- [ ] Do not assign any Copilot licenses to Finance users until Section 1 (Permissions/Oversharing) is completed and signed off.

---

## 1) Highest Priority - Permissions and Oversharing Controls (Hard Gate)

### 1.1 SharePoint and OneDrive access audit
- [ ] Run a current permissions inventory for all Finance SharePoint sites, libraries, and key folders.
- [ ] Identify and remove broad legacy access groups (for example, Everyone except external users, old project-wide groups, inherited broad visitors).
- [ ] Confirm site owners for each Finance site and record named accountability.
- [ ] Verify OneDrive sharing defaults for Finance users (internal/external sharing policy, link types, expiration settings).

### 1.2 High-risk content validation (must be explicit)
- [ ] Create a list of high-risk repositories: payroll, board papers, M&A, client financials.
- [ ] For each repository, confirm access is least-privilege and business-justified.
- [ ] Remove stale access from ex-team members, old migration groups, and non-finance users without current business need.
- [ ] Confirm confidential document libraries are not inheriting permissions from overly broad parent sites.

### 1.3 Oversharing checks (practical tests)
- [ ] Run test queries with pilot test accounts from different roles to check what content is discoverable.
- [ ] Check anonymous/company-wide links and revoke any not required.
- [ ] Review "shared with" links on a sample of sensitive files and close unnecessary access paths.
- [ ] Confirm external sharing on finance-sensitive sites is disabled or tightly controlled per policy.

### 1.4 Approval gate before Copilot enablement
- [ ] Security, Compliance, and Finance data owner sign off that oversharing risks are remediated to accepted level.
- [ ] Document residual risks and exceptions with named owners and due dates.

---

## 2) Licensing Prerequisites
- [ ] Confirm all target users have eligible base licenses (M365 E5 already confirmed).
- [ ] Procure and assign Microsoft 365 Copilot add-on licenses to approved pilot users first (not all 200 at once).
- [ ] Validate license assignment group membership and synchronization status.
- [ ] Confirm service plans required for Copilot experiences are enabled in assigned licenses.

---

## 3) Microsoft 365 Apps Client Readiness
- [ ] Confirm Office apps are on Microsoft 365 Apps for enterprise (supported update channel).
- [ ] Verify Word, Excel, PowerPoint, Outlook, and Teams client versions meet current Copilot support requirements.
- [ ] Ensure automatic updates are enabled and update compliance is monitored.
- [ ] Remediate out-of-date devices before user enablement.

---

## 4) Identity and MFA Readiness
- [ ] Confirm all target users are cloud-authenticated and can access core M365 apps without sign-in issues.
- [ ] Enforce MFA for all pilot and production users (no exceptions without formal approval).
- [ ] Review Conditional Access policies for Finance users to ensure compliant device and location controls are active.
- [ ] Validate break-glass/admin accounts are excluded only where formally approved and documented.

---

## 5) Sensitivity Labelling and Information Protection
- [ ] Confirm sensitivity labels exist for Finance classifications (for example: Public, Internal, Confidential, Highly Confidential Finance).
- [ ] Apply mandatory labeling policy for key Finance SharePoint libraries and document templates where required.
- [ ] Validate encryption and access restrictions on Highly Confidential classes (board, payroll, M&A, client financials).
- [ ] Test that protected documents behave as expected in collaboration and search scenarios.

---

## 6) End-User Comms and Enablement
- [ ] Publish a Finance-specific Copilot usage note: what Copilot can help with, what data users must not expose, and how to report concerns.
- [ ] Deliver a short enablement session before activation (safe prompting, handling sensitive data, verifying output).
- [ ] Provide a one-page "Generate then verify" reminder for financial analysis and client-facing content.
- [ ] Set a named support path (service desk queue + Finance IT contact) for first 2 weeks after go-live.

---

## 7) Pilot and Go-Live Control
- [ ] Start with a controlled pilot group (for example 20-30 Finance users across payroll, FP&A, and leadership support).
- [ ] Run 2-week pilot with weekly risk review focused on permissions exposure and policy drift.
- [ ] Only expand to full ~200 users after pilot sign-off from Security + Compliance + Finance owner.

## Completion Sign-Off
- [ ] DWP Engineering Lead sign-off
- [ ] Security sign-off
- [ ] Compliance sign-off
- [ ] Finance Data Owner sign-off
- [ ] Date approved for phased Copilot enablement: __________
