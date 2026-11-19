# A06 WebCore Diagnostics

## Purpose

The diagnostics APK is a test harness for the Android WebView provider currently installed on the device. It is **not a browser** and does not install, replace, update or modify the system WebView provider.

The APK is useful before the custom Chromium build exists: it records a reproducible baseline from the Samsung Galaxy A06 SM-A065M. Later, the same test suite can be run against a custom provider in a compatible AOSP image.

## Runtime behavior

- Loads one bundled HTML test page under the fixed local HTTPS origin `https://a06webcore.local/`.
- Performs no remote requests. The manifest intentionally has no `INTERNET` permission and WebView network loading is blocked.
- JavaScript is enabled only for this bundled benchmark page.
- No JavaScript bridge is exposed to page content.
- File and content access are disabled.
- Mixed content is blocked, Safe Browsing is enabled, popup creation is disabled and WebView debugging is disabled.
- External navigation is rejected.

## Measurements

The report contains:
- device model, Android release/API, security patch and supported ABIs;
- total/available RAM, low-memory state and app memory class;
- active WebView provider package/version and user agent;
- JavaScript loop time and throughput;
- DOM creation time;
- Canvas 2D drawing time and output sample;
- WebGL/WebGL2 availability and maximum texture size;
- WebAssembly module execution;
- CSS and browser API feature availability;
- media codec capability strings returned by `canPlayType`;
- process PSS before/after and page initialization time;
- renderer process exits observed by the harness;
- security settings applied by the harness and AndroidX WebKit feature support.

The media fields are capability declarations, not proof of successful end-to-end playback. WebGL availability does not establish that a particular GPU driver is bug-free. Microbenchmark times are device-, temperature- and load-dependent.

## Build

The app uses Android Gradle Plugin 9.4.1, Gradle 9.6.0, compile/target SDK 36, Java 17 and stable AndroidX WebKit 1.18.0.

On a Linux x86-64 host with Android SDK platform 36 and Gradle 9.6.0:

```bash
gradle --no-daemon :app:assembleDebug :app:lintDebug
```

GitHub Actions builds the debug APK and publishes it as the `a06-webcore-diagnostics-debug` artifact. Download that APK from the successful `Build diagnostics APK` workflow run and install it on the A06.

## Test procedure

1. Close heavy apps and leave the phone idle for a short settling period.
2. Install and open A06 WebCore Diagnostics.
3. Confirm the active provider package/version shown at the top.
4. Run the test suite three times under similar conditions.
5. Copy or share each JSON report.
6. Keep all three reports. Compare medians and note device temperature, power mode and available RAM.

The current test result measures the provider selected by Android at the time of execution. On stock Samsung firmware that is still the original system provider.

## Interpretation

Never compare a single run. Compare the same phone, page, viewport, power mode and thermal state. A candidate provider is only considered better when it improves relevant measurements without regressions in compatibility, stability, security or real host-app behavior.

The app does not expose private renderer internals and does not attempt to force GPU, process-count or cache policy changes.
