Symptom: Users on POOL-FIN-01 saw a black screen after login. For some users it cleared after about 30 seconds; for others, sessions disconnected and remained unusable.

Cause: The verified root cause was a graphics stack regression introduced by the updated POOL-FIN-01 image. This caused repeated dwm.exe crashes in igdumd64.dll during session initialization.

Scope: Impact was limited to POOL-FIN-01 after its overnight image update. About 40% of users in that pool were affected, while POOL-FIN-02 was unaffected.

Workaround: Route users to POOL-FIN-02 where capacity allows to restore access. Stop further rollout of the affected POOL-FIN-01 image during active service recovery.

Permanent fix: Roll back and correct POOL-FIN-01 to a stable image baseline, removing exposure to the unstable graphics component. Enforce image canary validation and pinned approved graphics driver versions before broad deployment.

How to spot it: On affected hosts, check for Application Error Event 1000 showing dwm.exe faulting in igdumd64.dll with exception 0xc0000005. This is followed by Desktop Window Manager Event 9009 and TerminalServices-LocalSessionManager Event 40 disconnects after Event 21 logon success; unaffected comparator hosts show DWM Event 9011 and no matching Event 1000 in the same window.
