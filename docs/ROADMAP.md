# Roadmap

## M0 — Foundation
- [x] Project identity and engineering rules.
- [x] ARM64 target and device profile.
- [x] Provider integration constraints and scaffold CI.
- [ ] Confirm all starter files and CI on the remote branch.

## M1 — Clean upstream build
- [ ] Select and pin a Chromium revision compatible with Android API 36.
- [ ] Build `system_webview_apk` for ARM64 without patches.
- [ ] Preserve build logs, APK hash and exact GN args.

## M2 — Provider validation
- [ ] Install on AOSP userdebug/eng emulator.
- [ ] Select provider and confirm framework reports it as current.
- [ ] Run WebView host test app and compatibility smoke tests.

## M3 — Device baseline
- [ ] Capture stock Samsung WebView version and firmware metadata.
- [ ] Collect permitted workload measurements on the unmodified A06.
- [ ] Establish a reference dataset.

## M4 — Optimization
- [ ] Profile actual bottlenecks.
- [ ] Introduce one isolated patch at a time.
- [ ] Require benchmarks, compatibility tests and rollback notes.

## M5 — AOSP integration
- [ ] Prepare provider allowlist and release certificate for a controlled AOSP image.
- [ ] Validate installation, updates and fallback behavior.
