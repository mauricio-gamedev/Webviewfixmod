# Roadmap

## M0 — Foundation
- [x] Project identity and engineering rules.
- [x] ARM64 target and device profile.
- [x] Provider integration constraints and scaffold CI.

## M1 — Chromium source and provider build
- [x] Pin exact Stable, Beta, Dev and Canary WebView source revisions.
- [x] Select Canary M160 as the active experimental development line.
- [x] Add channel-aware source synchronization with exact SHA verification.
- [x] Add channel-aware GN configuration for both build flavors.
- [x] Preserve local-test and custom-AOSP provider package identities.
- [ ] Execute a clean ARM64 Chromium checkout on capable Linux infrastructure.
- [ ] Build the untouched `system_webview_apk` and preserve APK SHA-256/logs.
- [ ] Validate provider startup on a compatible AOSP userdebug/eng image.

## M2 — Device-side performance evidence
- [x] Implement optional offline A06 WebView Diagnostics app.
- [x] Add Android build, lint and artifact workflow.
- [x] Build and publish the diagnostics debug APK (GitHub Actions run 44591340334).
- [ ] Capture repeated device measurements for later comparison with Chromium builds.
- Note: device diagnostics are not a prerequisite for source sync or building the custom provider.

## M3 — A06 Chromium optimization
- [ ] Profile startup, renderer memory, scrolling and graphics on realistic WebView hosts.
- [ ] Introduce one isolated Chromium patch at a time.
- [ ] Require benchmark deltas, compatibility tests, stability checks and rollback notes.
- [ ] Re-test each patch when moving between Stable/Beta/Dev/Canary pins.

## M4 — AOSP integration
- [ ] Prepare provider allowlist and release certificate for a controlled AOSP image.
- [ ] Validate installation, updates and rollback behavior.
