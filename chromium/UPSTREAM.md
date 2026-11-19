# Chromium upstream pins

## Active source line

| Field | Value |
|---|---|
| Product | Android System WebView |
| Active channel | Canary |
| Version / tag | `160.0.8171.0` |
| Full source commit | `96c4a2734b92dc38701c139d3e5a720c44528e91` |
| Branch position | `refs/branch-heads/8171@{#1}` |
| Initial target | `system_webview_apk` |
| ABI target | `arm64` |
| Pin checked | 19 November 2026 |

Canary is the active development line because this project is exploring and validating a custom Chromium engine. Canary is released frequently and receives the newest changes, but it is less tested and may contain regressions. The repository pins an exact commit; it does **not** follow a moving branch during a build.

## Available release channels

The project can build any of the four WebView release lines. All entries below are exact source tags and full commit hashes, not floating labels.

| Channel | Android System WebView version | Chromium source SHA | Branch position |
|---|---|---|---|
| Stable | `158.0.8127.36` | `14d6f648e8cd7ad750a4044200ce94d3321be260` | `refs/branch-heads/8127@{#1691}` |
| Beta | `159.0.8154.4` | `477da85e3d730af58ab676ea7aa02dab256eeb34` | `refs/branch-heads/8154@{#11}` |
| Dev | `160.0.8157.3` | `dd97a920c7852ad9708d9d4b5e784efbc9c6f83e` | `refs/branch-heads/8157@{#6}` |
| Canary | `160.0.8171.0` | `96c4a2734b92dc38701c139d3e5a720c44528e91` | `refs/branch-heads/8171@{#1}` |

The default is selected by `chromium_release_channel` in `project.json`. Override it per command with `CHROMIUM_CHANNEL=stable|beta|dev|canary`. The synchronization and build scripts resolve the corresponding version and SHA from the channel matrix and reject unknown channels.

## Source of truth

- Chromium source: https://chromium.googlesource.com/chromium/src.git
- WebView release channels: https://chromium.googlesource.com/chromium/src/+/main/android_webview/docs/prerelease.md
- WebView build instructions: https://chromium.googlesource.com/chromium/src/+/main/android_webview/docs/build-instructions.md
- WebView provider requirements: https://chromium.googlesource.com/chromium/src/+/main/android_webview/docs/webview-providers.md
- Canary WebView release: https://www.apkmirror.com/apk/google-inc/android-system-webview-canary/android-system-webview-canary-160-0-8171-0-release/
- Beta WebView release: https://www.apkmirror.com/apk/google-inc/android-system-webview-beta/android-system-webview-beta-159-0-8154-4-release/
- Dev WebView release: https://www.apkmirror.com/apk/google-inc/android-system-webview-dev/android-system-webview-dev-160-0-8157-3-release/

## Reproducibility rules

1. Select a channel explicitly or use the configured active channel.
2. Sync the Chromium checkout to the full SHA for that channel, not a moving branch.
3. Sync DEPS and run hooks using the pinned checkout.
4. Record depot_tools, Python, Java, Android SDK/NDK and host OS versions.
5. Build the untouched `system_webview_apk` before applying any optimization patch.
6. Store logs, GN args (redacting secrets), output APK SHA-256 and build flavor as artifacts.
7. Advance a channel pin only after verifying the corresponding WebView release and exact source commit.

This is source selection metadata, **not evidence that Chromium has compiled**. No custom provider APK has been produced yet.
