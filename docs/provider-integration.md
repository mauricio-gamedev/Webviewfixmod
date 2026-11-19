# WebView provider integration

Android's WebView Update Service selects an installed, enabled and eligible provider based on platform configuration, package identity, version/target compatibility and signing certificate.

## Stock Samsung production firmware
The retail Galaxy A06 firmware is a GMS image. Its provider configuration and signing trust are controlled by the platform vendor and Google certification requirements. A locally signed APK cannot impersonate Google or Samsung and cannot simply replace the system provider on the locked stock image.

## Local development
Use the Chromium local-test flavor with package `com.android.webview` on an AOSP userdebug/eng emulator or compatible test image. Local-test configuration relaxes checks for development; this is not a production signing model.

## Custom AOSP image
A system integrator can include `io.github.astromg01.a06webcore` in an AOSP-derived image and configure the framework WebView provider allowlist with the certificate matching the release APK. The APK, allowlist and release key must belong to the image's trusted build/release process.

## Non-goals
- No signature spoofing, Package Manager bypass, root exploit or bootloader bypass.
- No Google/Samsung private keys.
- No disabling the WebView Update Service or removing a fallback provider.
- No claim that this project replaces the original Samsung provider without firmware integration.
