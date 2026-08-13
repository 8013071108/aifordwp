# Exercise Output - Theme Clustering, Top 2 Actions, Proactive Notice

Date: 2026-08-13

## 1) Cluster Comments to Themes

### Theme A: Test VM remote access failure
- Count: 2
- Comments:
  - "Can’t remote into any of my test VMs since the update, blocking my whole day."
  - "My test VM access is still down, can’t do my job today either."
- Severity: Blocker

### Theme B: Admin console lockouts
- Count: 2
- Comments:
  - "Second engineer this week locked out of the admin console entirely."
  - "Admin console lockouts happening across the whole team now, not just one person."
- Severity: Blocker

### Theme C: Shared credentials vault inaccessible
- Count: 3
- Comments:
  - "Shared credentials vault is completely inaccessible, whole team blocked."
  - "Third day now I can’t access the credentials vault, this is urgent."
  - "Vault access still broken, escalated to my manager now."
- Severity: Blocker

### Theme D: UI/visual preference and readability changes
- Count: 5
- Comments:
  - "New ticketing system dashboard is a nicer colour scheme, small win."
  - "Font in the new portal is slightly smaller, hard to read for some of us."
  - "Notification sounds changed, mildly annoying but not a big deal."
  - "Nice that the new theme supports dark mode properly now."
  - "Small UI icon changes, took a second to adjust but fine."
- Severity: Minor / Positive mixed

### Theme E: Minor performance perception
- Count: 1
- Comment:
  - "Dashboard refresh is a bit slower than before, barely noticeable."
- Severity: Minor

### Theme F: Positive rollout sentiment
- Count: 2
- Comments:
  - "Overall the rollout felt smoother than last time, appreciate it."
  - "No issues at all for me, everything’s working fine."
- Severity: Positive

## 2) Rank Top 2 Themes to Act on Today

### Top 1: Shared credentials vault inaccessible (Theme C, count 3)
Why ranked #1:
- Highest blocker count in this dataset.
- Explicit language indicates sustained outage and escalation.
- Team-level dependency impact ("whole team blocked") makes this highest business risk.

### Top 2: Admin console lockouts (Theme B, count 2)
Why ranked #2:
- Cross-team spread is increasing ("across the whole team now").
- Directly blocks admin operations and incident handling capability.
- Higher operational risk than isolated VM-access reports due to control-plane impact.

## 3) Proactive Notification for Top Theme 1

We are aware of an active issue affecting access to the shared credentials vault and we are treating it as a priority incident. Some teams are currently unable to access stored credentials, and engineering is working on restoration now.

As an interim step, please avoid repeated login retries and use your approved fallback process for any critical credentials you already have documented locally in line with policy. If you are blocked on urgent work, contact the service desk and mark the request as "Vault Access Incident".

When contacting support, include your username, team name, the time access failed, and a screenshot of the error message. We will provide the next all-staff update within 60 minutes.
