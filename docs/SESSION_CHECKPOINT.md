# Session checkpoint

## Verified repository state
- Repository: `mauricio-gamedev/Webviewfixmod`.
- Project: Chromium-based Android WebView provider; explicitly not a browser.
- Target: Samsung Galaxy A06 SM-A065M, Android 16, ARM64, no root.
- M1 Chromium pin and reproducible source/build tooling are merged into `main`.
- Host-capacity preflight is merged into `main`.
- M2 diagnostic app merged through PR #8 (merge commit `f19e871928191537cf9d7be66f280cbac65bebe2`).

## M1 source pin
- Android System WebView Stable `158.0.8127.36`.
- Chromium commit: `14d6f648e8cd7ad750a4044200ce94d3321be260`.
- Branch position: `refs/branch-heads/8127@{#1691}`.
- Build target: `system_webview_apk`, ARM64.
- No Chromium source sync or provider APK build has yet been executed.

## M2 diagnostic app — APK built
- App: A06 WebCore Diagnostics; a diagnostic host app, not a browser or WebView provider.
- Declared application ID: `io.github.astromg01.a06webcore.bench`; debug build suffix: `.debug`.
- Android API range: minimum 26, target 36.
- Toolchain: AGP 9.4.1, Gradle 9.6.0, JDK 17, AndroidX WebKit 1.18.0 stable.
- Offline local HTML test surface; no INTERNET permission, no JS bridge, network/file/content access blocked.
- Captures provider/version, device metadata, RAM/PSS, JS/DOM/Canvas/WebGL/WebAssembly, web API/media capability declarations and renderer-exit events.
- GitHub Actions run `44591340334` passed `assembleDebug`, `lintDebug` and artifact upload.
- Workflow artifact ID: `14564305113`, name `a06-webcore-diagnostics-debug`, size 1,325,499 bytes.
- Artifact ZIP SHA-256: `68b2c66801a7e3bac6ed66ed178c5f0375a414d9f83e33e448107124790931c0`.
- Extracted debug APK SHA-256: `f15f00f16389f6b7d31a5c9e621388789e11296d9d2957b8d9fc9b9a275dc858`.
- APK has not yet been installed or run on the physical Galaxy A06.

## Current blockers
- Full Chromium build needs a Linux x86-64 machine with at least 8 GB RAM and 100 GB free disk; over 16 GB RAM is recommended.
- Device-side baseline still needs installation and repeated runs on the Galaxy A06.

## Next steps
1. Install the diagnostics debug APK on the Galaxy A06.
2. Confirm the active provider package/version at the top of the app.
3. Run the suite three times under comparable temperature/power conditions.
4. Share/copy all three JSON reports to establish the stock WebView baseline.
5. Continue the clean Chromium M158 build on a sufficiently provisioned Linux host.
6. Do not propose optimization patches until the measured baseline identifies a bottleneck.
