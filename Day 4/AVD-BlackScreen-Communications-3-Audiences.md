# AVD Incident Communications - Three Audiences

## Audience 1 - Non-technical executive
Your access and data are safe. This morning, some users in POOL-FIN-01 saw a black screen after sign-in following an overnight update; POOL-FIN-02 was unaffected. The update was stopped, the image was rolled back and corrected, and service was restored by 10:00 AM. Verification confirmed successful sign-ins to POOL-FIN-01 with no further issues reported. You do not need to do anything.

## Audience 2 - Affected end-user team (non-technical)
Your access and data are safe, and the issue is resolved: this morning, some users in POOL-FIN-01 saw a black screen after sign-in because the overnight update for that pool caused sessions to drop, while POOL-FIN-02 was unaffected. We stopped the update, rolled back and corrected the image, and restored service by 10:00 AM, with successful sign-ins and no further issues reported. If you see the same issue, contact the DWP Service Desk.

## Audience 3 - Engineer-to-engineer internal note
Access/data integrity: no data-loss indicators; user access restored.

Incident summary:
- Symptom: post-login black screen in POOL-FIN-01; some sessions recovered after ~30s, others persisted/disconnected.
- Scope: POOL-FIN-01 impacted; POOL-FIN-02 unaffected.
- Timing: issue observed from ~07:00 after 02:00 overnight image update to POOL-FIN-01.

Root cause:
- Image-introduced graphics stack regression on POOL-FIN-01.
- Evidence: repeated Application Error Event 1000 for dwm.exe faulting in igdumd64.dll (v31.0.101.4146), exception 0xc0000005, followed by DWM Event 9009 exits and LSM Event 40 disconnects.
- Control: POOL-FIN-02 showed normal DWM start (Event 9011) and no matching Event 1000 in same window.

Exact action taken:
- Contained impact by shifting user access to healthy pool where capacity allowed.
- Stopped further rollout of updated POOL-FIN-01 image.
- Applied rollback/corrective image path to remove exposure to unstable graphics component.
- Service restored at 10:00 AM.

Config detail:
- Faulting process/module signature on affected host: dwm.exe 10.0.22621.2861 -> igdumd64.dll 31.0.101.4146.
- Affected image boundary: POOL-FIN-01 updated image; comparator POOL-FIN-02 pre-update image remained stable.

Verification step:
- Post-change validation confirmed users logging in to POOL-FIN-01 successfully with no further black screen reports.

Preventive action required:
- Enforce image release gates for login/reconnect graphics stability.
- Canary ring rollout before broad deployment.
- Pin approved graphics driver versions in image pipeline.
- Alert on Event 21 -> Event 1000 (dwm.exe + igdumd64.dll) -> Event 9009/Event 40 correlation pattern.
- Require comparator-pool health check before production promotion.
