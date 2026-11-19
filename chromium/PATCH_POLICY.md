# Chromium patch policy

- Keep patches minimal and isolated.
- Each patch must name the exact Chromium SHA it applies to.
- Include rationale, measured hypothesis, affected subsystem and potential regressions.
- Include benchmark commands/results, compatibility coverage and rollback procedure.
- Never disable sandboxing, site isolation, certificate validation, origin checks or security updates as a performance shortcut.
- Rebase onto a newer upstream revision promptly and rerun regression tests.
