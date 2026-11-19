# Roadmap

## M0 — Foundation
- [x] Project identity and engineering rules.
- [x] ARM64 target and device profile.
- [x] Provider integration constraints and scaffold CI.

## M1 — Reproducible upstream baseline
- [x] Select the current stable Android System WebView source tag 158.0.8127.36.
- [x] Resolve and record the full 40-character Chromium commit.
- [x] Add pinned source synchronization script.
- [x] Separate local-test and custom-AOSP release build flavors.
- [ ] Execute a clean ARM64 Chromium checkout and build on capable Linux infrastructure.
- [ ] Preserve build logs, toolchain versions and APK SHA-256.

## M2 — Provider validation
- [ ] Install on AOSP userdebug/eng emulator.
- [ ] Select provider and confirm framework reports it as current.
- [ ] Run WebView Shell and host-app compatibility smoke tests.

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
- [ ] Validate installation, updates and rollback behavior.
