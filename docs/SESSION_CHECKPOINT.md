# Session checkpoint

## Verified repository state
- Repository: `mauricio-gamedev/Webviewfixmod`.
- Project: customized Chromium-based Android WebView provider; explicitly not a browser.
- Target: Samsung Galaxy A06 SM-A065M, Android 16, ARM64, no root.
- M1 has exact source pins for Stable, Beta, Dev and Canary.
- Active development line: WebView Canary 160.0.8171.0.
- Channel-aware synchronization/build scripts are implemented in the current feature branch.
- No Chromium checkout or custom provider APK has been built yet.

## Chromium channel pins
- Stable 158.0.8127.36 — `14d6f648e8cd7ad750a4044200ce94d3321be260`.
- Beta 159.0.8154.4 — `477da85e3d730af58ab676ea7aa02dab256eeb34`.
- Dev 160.0.8157.3 — `dd97a920c7852ad9708d9d4b5e784efbc9c6f83e`.
- Canary 160.0.8171.0 — `96c4a2734b92dc38701c139d3e5a720c44528e91`.
- Exact branch positions and source provenance: `chromium/UPSTREAM.md`.
- Default `CHROMIUM_CHANNEL`: `canary`; all four channel pins are immutable in `project.json`.

## Build contract
- Target: `system_webview_apk`, ARM64.
- Local test package: `com.android.webview`.
- Custom AOSP package: `io.github.astromg01.a06webcore`.
- `tools/sync_chromium.sh` resolves the channel-specific 40-character SHA and verifies the final checkout.
- `tools/build_webview.sh` verifies the channel-specific checkout and injects the selected `android_channel` into GN args.
- The standard GitHub-hosted runner is not suitable for the full Chromium checkout/build; host preflight requires at least 8 GB RAM and 100 GB free disk, with more than 16 GB RAM recommended.

## Optional diagnostics app
- A06 WebCore Diagnostics is a separate benchmark host app, not the provider.
- APK build from GitHub Actions run `44591340334` passed `assembleDebug`, `lintDebug` and artifact upload.
- APK has not been installed or run on the physical Galaxy A06.
- Its stock-provider baseline is useful later for optimization comparisons, but it is not a prerequisite for producing the Chromium provider.

## Next implementation steps
1. Run a clean sync of the pinned Canary M160 source on a qualified Linux x86_64 host.
2. Build the untouched `system_webview_apk` ARM64 baseline and preserve logs, GN args and APK SHA-256.
3. Validate the provider on a compatible AOSP userdebug/eng image.
4. Only after the untouched build is confirmed, start isolated A06-specific Chromium patches and measure them against the baseline.
5. Use the diagnostics app when collecting performance evidence; do not let it block provider development.
