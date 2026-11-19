# Architecture

## Product definition
A06 WebCore is a customized **Android WebView provider** built from Chromium's `android_webview` implementation. It supplies the rendering/runtime component consumed by apps through `android.webkit.WebView`. It is not a standalone browser.

## Upstream components
- Blink: DOM, HTML, CSS and layout.
- V8: JavaScript and WebAssembly runtime.
- Skia/compositor: drawing, rasterization and compositing.
- Chromium networking and storage: requests, cookies, cache and web storage.
- Android WebView glue: framework-facing provider and Android lifecycle integration.

We inherit Chromium's multiprocess architecture and security model; we do not write a replacement HTML engine.

## Layers
1. `upstream/`: exact Chromium revision and build provenance (documented, not vendored).
2. `patches/`: small, reviewable Chromium patches.
3. `chromium/args/`: reproducible ARM64 GN configurations.
4. `platform/aosp/`: future AOSP image integration and provider allowlist.
5. `benchmarks/`: repeatable tests, traces and metadata.

## Performance priorities
1. Preserve security and avoid regressions.
2. Measure startup, page load, scroll jank, crashes and memory in realistic host apps.
3. Profile before modifying V8, Blink, Skia, GPU scheduling or process policy.
4. Optimize the measured bottleneck; do not assume that reducing cache or renderer count is automatically beneficial.

## Runtime contract
Host applications create and configure their own WebView instances. Provider-level changes must honor the WebView API contract and must not arbitrarily override host lifecycle or per-instance settings.
