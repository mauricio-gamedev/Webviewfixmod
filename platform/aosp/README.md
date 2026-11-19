# AOSP provider integration

This directory is a template for a firmware maintainer building an AOSP-derived image. It does not modify the stock Samsung firmware.

1. Build the custom provider APK with package `io.github.astromg01.a06webcore`.
2. Sign it with a project-controlled release key stored outside source control.
3. Extract the certificate from that exact release APK and replace the template placeholder.
4. Integrate the APK and provider configuration into the product/system image.
5. Keep a working fallback provider and verify WebView Update Service behavior.
6. Test provider selection, upgrades, rollback and host-app compatibility on the target image.

The package name and release certificate must match exactly. Never copy Google/Samsung private keys or bypass framework verification. This requires control of the AOSP image and release signing pipeline; it is not a way to replace the provider on the original locked Samsung retail image.
