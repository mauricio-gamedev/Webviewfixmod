# Chromium upstream pin

## Selected baseline

| Field | Value |
|---|---|
| Product | Android System WebView |
| Version | `158.0.8127.36` |
| Release line | Stable M158 |
| Chromium tag | `158.0.8127.36` |
| Full source commit | `14d6f648e8cd7ad750a4044200ce94d3321be260` |
| Branch position | `refs/branch-heads/8127@{#1691}` |
| Initial target | `system_webview_apk` |
| ABI target | `arm64` |

The Android System WebView 158.0.8127.36 package was published on 16 November 2026. The Chromium source tag resolves to the exact commit above. The Chrome 158 Android stable train was announced on 17 November 2026. See the references below.

## Source of truth

- Chromium source: https://chromium.googlesource.com/chromium/src.git
- Tag: https://github.com/chromium/chromium/tree/158.0.8127.36
- Exact commit: https://github.com/chromium/chromium/commit/14d6f648e8cd7ad750a4044200ce94d3321be260
- WebView release history: https://www.apkmirror.com/apk/google-inc/android-system-webview/
- Chrome release notes: https://chromereleases.googleblog.com/2026/11/

## Reproducibility rules

1. Sync the Chromium checkout to this full commit SHA, not a moving branch.
2. Sync DEPS and run hooks using the pinned checkout.
3. Record depot_tools, Python, Java, Android SDK/NDK and host OS versions.
4. Build the untouched `system_webview_apk` before applying any patch.
5. Store logs, GN args (redacting secrets), output APK SHA-256 and build flavor as CI artifacts.
6. Do not silently advance the pin. Update this file and `project.json` together after checking a newer stable WebView release.

This is a source baseline selection, **not evidence that Chromium has compiled**. No APK is produced by pinning a revision alone.
