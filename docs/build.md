# Chromium WebView build

## Requirements
Build on a capable Linux x86_64 host with Chromium's documented depot_tools workflow, Android SDK/NDK dependencies, compiler packages and substantial free disk/RAM. A Galaxy A06 is a test target, not a practical Chromium compilation host.

## Source checkout
Use the official Chromium repository:
`https://chromium.googlesource.com/chromium/src.git`

Do not pin an arbitrary revision. Select a current stable Chromium revision, verify Android 16/API 36 build compatibility, record its full commit SHA in chromium/UPSTREAM.md, then build the unmodified baseline.

## Target
The WebView APK GN target is `system_webview_apk`, with:
- `target_os = "android"`
- `target_cpu = "arm64"`
- `is_component_build = false`

## Build
Example:
```bash
fetch android
cd src
gn gen out/A06WebCore --args='target_os="android" target_cpu="arm64" is_component_build=false is_debug=false'
autoninja -C out/A06WebCore system_webview_apk
```

Use the repository args files only after checking them against the selected Chromium revision. Upstream GN args can change.

## Evidence required
Record source SHA, GN args, toolchain versions, build logs, output APK SHA-256 and build flavor. A successful scaffold CI is not a successful Chromium build.
