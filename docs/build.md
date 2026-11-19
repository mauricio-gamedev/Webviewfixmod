# Chromium WebView build

## Host requirements

Use a Linux x86_64 machine. Chromium's official Android build guide specifies at least 8 GB RAM and 100 GB free disk; more than 16 GB RAM is highly recommended. The Galaxy A06 is a test target, not a practical Chromium compilation host. `tools/check_build_host.sh` checks architecture, RAM and free disk before source synchronization or compilation.

Official references:
- https://chromium.googlesource.com/chromium/src/+/refs/tags/158.0.8127.36/android_webview/docs/build-instructions.md
- https://chromium.googlesource.com/chromium/src/+/refs/tags/158.0.8127.36/android_webview/docs/quick-start.md
- https://chromium.googlesource.com/chromium/src/+/refs/tags/158.0.8127.36/docs/android_build_instructions.md

## Pinned source

The exact baseline is documented in `chromium/UPSTREAM.md` and `project.json`.

```bash
bash tools/sync_chromium.sh
```

The sync script uses the pinned Chromium commit and synchronizes DEPS/hooks. Do not switch to `main` or `lkgr` for a reproducible baseline.

## GN target and architecture

The initial target is:

```bash
autoninja -C out/A06WebCore system_webview_apk
```

The GN configuration uses:
- `target_os = "android"`
- `target_cpu = "arm64"`
- `is_component_build = false`

Do not force `android_sdk_release`; keep the default SDK selected by the pinned Chromium revision. Confirm the A06's supported ABI list before making claims about 32-bit app compatibility.

Start with the default `system_webview_apk` target. The separate `system_webview_64_32_apk` target is an optional later experiment for devices that run both 64-bit and 32-bit apps; it uses a 64-bit renderer and can increase memory consumption. It must be benchmarked on this low-RAM target before consideration.

## Build flavors

### Local test

```bash
BUILD_FLAVOR=local-test bash tools/build_webview.sh
```

Uses package `com.android.webview` and development signing. This flavor is for a compatible AOSP userdebug/eng image or emulator. Android's documented GMS production provider allowlist does not permit this package as a normal retail provider.

### Custom AOSP release

```bash
A06_WEBVIEW_KEYSTORE_PATH=/secure/path/webview-release.keystore \
A06_WEBVIEW_KEY_ALIAS=webview-release \
A06_WEBVIEW_KEY_PASSWORD='***' \
BUILD_FLAVOR=aosp-custom bash tools/build_webview.sh
```

This flavor sets an official, stable-channel build and signs with a project-controlled keystore. The private keystore must never enter Git or CI logs. The resulting package is `io.github.astromg01.a06webcore`. It still requires integration into an AOSP-derived system image with a matching framework provider configuration and certificate.

Do not use project keys to impersonate Google or Samsung. Do not store passwords in committed GN args or workflow files.

## Output and evidence

The build script checks that the checkout is exactly the pinned commit, generates GN args in the ignored output directory and invokes `system_webview_apk`.

A completed build must preserve:
- exact Chromium SHA and version;
- host OS and toolchain versions;
- complete GN args with secrets redacted;
- build log;
- APK path and SHA-256;
- build flavor and package name.

Scaffold CI is not a Chromium build. No runtime provider selection is claimed until tested on a compatible Android image.

## GitHub Actions capacity

The standard GitHub-hosted runner for public repositories provides 14 GB of SSD storage, below Chromium's 100 GB minimum. A larger Linux runner with 8 vCPU, 32 GB RAM and 300 GB SSD can meet the documented baseline, but managed larger runners require an eligible GitHub Team or Enterprise Cloud plan and billing configuration. Therefore this repository's standard CI deliberately validates metadata, tests and shell syntax only; it does not attempt a doomed full Chromium checkout/build.
