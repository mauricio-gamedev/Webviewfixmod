# Roadmap

## M0 — Foundation
- [x] Project identity and engineering rules.
- [x] ARM64 target and device profile.
- [x] Provider integration constraints and scaffold CI.

## M1 — Reproducible upstream baseline
- [x] Select Android System WebView Stable 158.0.8127.36.
- [x] Resolve and record the full Chromium commit.
- [x] Add pinned source synchronization script.
- [x] Separate local-test and custom-AOSP release build flavors.
- [ ] Execute a clean ARM64 Chromium checkout and build on capable Linux infrastructure.
- [ ] Preserve build logs, toolchain versions and APK SHA-256.

## M2 — Device-side baseline and provider validation
- [x] Implement offline A06 WebView Diagnostics app.
- [x] Add provider, device, RAM/PSS, Web API, graphics and media capability reporting.
- [x] Add Android build, lint and artifact workflow.
- [x] Build and publish the diagnostics debug APK (GitHub Actions run 44591340334).
- [ ] Install diagnostics APK on Galaxy A06 and capture stock provider baseline.
- [ ] Repeat baseline three times and store JSON reports.
- [ ] Validate provider selection and host-app compatibility on AOSP userdebug/eng.

## M3 — Optimization
- [ ] Profile actual bottlenecks using the device-side baseline.
- [ ] Introduce one isolated Chromium patch at a time.
- [ ] Require benchmarks, compatibility tests, stability checks and rollback notes.

## M4 — AOSP integration
- [ ] Prepare provider allowlist and release certificate for a controlled AOSP image.
- [ ] Validate installation, updates and rollback behavior.
