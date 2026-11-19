# WebView provider integration

Android's WebView Update Service selects an installed, enabled and eligible provider based on platform configuration, package identity, version/target compatibility and signing certificate.

## Retail Android with GMS

For Android 10 and newer, Chromium's public WebView build documentation lists these GMS provider package names:
- `com.google.android.webview`
- `com.google.android.webview.beta`
- `com.google.android.webview.dev`
- `com.google.android.webview.canary`
- `com.google.android.webview.debug` (userdebug/eng only)
- `com.android.webview` (userdebug/eng only)

Being on the package-name list is not sufficient: the platform also verifies provider signatures. A custom APK signed with our own key cannot impersonate the Google-signed Beta/Dev/Canary packages. We will not copy private Google/Samsung keys or bypass this check.

## Local development

Use Chromium's local-test flavor with package `com.android.webview` on an AOSP userdebug/eng emulator or compatible test image. This is a development route, not a route to replace the provider on the locked stock Samsung firmware.

## Custom AOSP image

A system integrator can include `io.github.astromg01.a06webcore` in an AOSP-derived image and configure the framework WebView provider allowlist with the certificate matching the release APK. The APK, allowlist and release key must belong to the image's trusted build/release process.

## Galaxy A06 stock firmware

The initial target device is the retail Galaxy A06 SM-A065M on Android 16, without root and with a locked bootloader. An independently signed provider cannot be globally selected on this stock firmware unless the firmware's own provider configuration and trust policy authorize it. The project can still be built and tested on AOSP-compatible images; it must not claim stock-device replacement without evidence.

## Non-goals

- No signature spoofing, Package Manager bypass, root exploit or bootloader bypass.
- No Google/Samsung private keys.
- No disabling the WebView Update Service or removing a fallback provider.
- No claim that a custom APK replaces the original Samsung provider without firmware integration.
