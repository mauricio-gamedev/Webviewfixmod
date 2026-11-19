# Chromium WebView build

## Host requirements

Use a Linux x86_64 machine. Chromium's official Android build guide specifies at least 8 GB RAM and 100 GB free disk; more than 16 GB RAM is highly recommended. The Galaxy A06 is a test target, not a practical Chromium compilation host. `tools/check_build_host.sh` checks architecture, RAM and free disk before source synchronization or compilation.

Official references:
- https://chromium.googlesource.com/chromium/src/+/main/android_webview/docs/build-instructions.md
- https://chromium.googlesource.com/chromium/src/+/main/android_webview/docs/quick-start.md
- https://chromium.googlesource.com/chromium/src/+/main/docs/android_build_instructions.md

## Pinned source channels

`project.json` records exact SHA pins for Stable, Beta, Dev and Canary. The default active line is **Canary 160.0.8171.0**. Canary is deliberately used for the experimental development line; its faster cadence also means it can contain regressions. Builds remain reproducible because each channel resolves to a fixed 40-character commit SHA.

To use the configured active channel:

```bash
bash tools/sync_chromium.sh
```

To choose another channel:

```bash
CHROMIUM_CHANNEL=stable bash tools/sync_chromium.sh
CHROMIUM_CHANNEL=beta bash tools/sync_chromium.sh
CHROMIUM_CHANNEL=dev bash tools/sync_chromium.sh
CHROMIUM_CHANNEL=canary bash tools/sync_chromium.sh
```

The build script accepts the same `CHROMIUM_CHANNEL` value and refuses to build if the checkout SHA does not match that channel's pin.

## GN target, architecture and low-end profile

The initial target is:

```bash
autoninja -C out/A06WebCore system_webview_apk
```

The GN configuration uses:
- `target_os = "android"`
- `target_cpu = "arm64"`
- `is_component_build = false`
- `is_high_end_android = false`

Chromium M160 defaults `is_high_end_android` to true on ARM64 and documents that this profile favors speed at the expense of binary size and memory. The A06 is a low-end device, so both build flavors explicitly disable that profile. In Chromium's compiler configuration this enables `optimize_for_size` on Android. This is a deliberate size/memory trade-off, not a claim of proven lower latency; benchmark results must confirm whether it improves the A06 workload.

The selected channel is passed to GN as `android_channel`. Do not force `android_sdk_release`; keep the default SDK selected by the pinned Chromium revision. Confirm the A06's supported ABI list before making claims about 32-bit app compatibility.

Start with the default `system_webview_apk` target. The separate `system_webview_64_32_apk` target is an optional later experiment for devices that run both 64-bit and 32-bit apps; it uses a 64-bit renderer and can increase memory consumption. It must be benchmarked on this low-RAM target before consideration.

## Build flavors

### Local test

```bash
CHROMIUM_CHANNEL=canary BUILD_FLAVOR=local-test bash tools/build_webview.sh
```

Uses package `com.android.webview` and development signing. This flavor is for a compatible AOSP userdebug/eng image or emulator. Android's documented GMS production provider allowlist does not permit this package as a normal retail provider.

### Custom AOSP release

```bash
CHROMIUM_CHANNEL=canary \
A06_WEBVIEW_KEYSTORE_PATH=/secure/path/webview-release.keystore \
A06_WEBVIEW_KEY_ALIAS=webview-release \
A06_WEBVIEW_KEY_PASSWORD='***' \
BUILD_FLAVOR=aosp-custom bash tools/build_webview.sh
```

The script sets the selected channel, builds the project package `io.github.astromg01.a06webcore`, and signs with a project-controlled keystore. The private keystore must never enter Git or CI logs. This flavor still requires integration into an AOSP-derived system image with a matching framework provider configuration and certificate.

Do not use project keys to impersonate Google or Samsung. Do not store passwords in committed GN args or workflow files.

## Output and evidence

A completed build must preserve:
- selected WebView release channel and version;
- exact Chromium SHA;
- host OS and toolchain versions;
- complete GN args with secrets redacted;
- build log;
- APK path and SHA-256;
- build flavor and package name.

A completed scaffold CI run is not a Chromium build. No runtime provider selection is claimed until tested on a compatible Android image.

## GitHub Actions capacity

The standard GitHub-hosted runner for public repositories provides 14 GB of SSD storage, below Chromium's 100 GB minimum. A larger Linux runner with 8 vCPU, 32 GB RAM and 300 GB SSD can meet the documented baseline, but managed larger runners require an eligible GitHub Team or Enterprise Cloud plan and billing configuration. Therefore this repository's standard CI validates metadata, tests and shell syntax; it does not attempt a doomed full Chromium checkout/build.
