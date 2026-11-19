# Contributor instructions

## Project identity
A06 WebCore is a Chromium-based Android WebView provider, **not a browser**. Do not add tabs, address bars, bookmarks or browsing history.

## Target
- Samsung Galaxy A06 SM-A065M
- Android 16, API 36
- ARM64 / `target_cpu = "arm64"`
- No root; initial device profile reports a locked bootloader
- Do not claim a custom APK can replace the provider on stock Samsung production firmware.

## Workflow
1. Read README, docs/SESSION_CHECKPOINT.md and relevant technical docs.
2. Work on feature branches; do not push directly to main.
3. Keep Chromium patches small, isolated and tied to an exact upstream revision.
4. Build an unmodified upstream baseline before optimization.
5. Every optimization requires a hypothesis, reproducible benchmark, compatibility tests, results and rollback path.
6. Preserve sandboxing, site isolation, certificate validation and security updates.
7. Run `python3 tools/validate_project.py` and relevant tests.
8. Update docs/SESSION_CHECKPOINT.md with verified evidence.

## Signing and integration
- Never commit private keys, keystores, passwords or credentials.
- Never impersonate Google or Samsung signing identities.
- Never bypass Android provider signature checks or bootloader restrictions.
- Use compatible AOSP userdebug/eng images for locally signed provider tests.
- A production custom provider requires firmware integration and a matching framework allowlist/certificate.

## Reporting
Distinguish scaffold validation, Chromium compilation, APK installation, provider selection and physical-device validation. Never report a later stage as complete when only an earlier stage passed.
