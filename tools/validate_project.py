#!/usr/bin/env python3
"""Validate repository metadata and source-build scaffolding without building Chromium."""
from __future__ import annotations
import json
import re
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
REQUIRED = [
    "README.md", "AGENTS.md", "project.json",
    "chromium/args/a06-arm64.gn",
    "chromium/args/a06-arm64-aosp-custom.gn",
    "chromium/UPSTREAM.md", "chromium/PATCH_POLICY.md",
    "platform/aosp/config_webview_packages.xml.template",
    "platform/aosp/README.md",
    "docs/architecture.md", "docs/provider-integration.md",
    "docs/build.md", "docs/device-profile.md",
    "docs/benchmark-matrix.md", "docs/ROADMAP.md",
    "docs/SESSION_CHECKPOINT.md", "docs/benchmark-app.md",
    "settings.gradle.kts", "build.gradle.kts", "gradle.properties",
    "app/build.gradle.kts", "app/src/main/AndroidManifest.xml",
    "app/src/main/java/io/github/astromg01/a06webcore/bench/MainActivity.java",
    "app/src/main/assets/bench.html", "app/src/main/res/values/styles.xml",
    "app/src/main/res/values/strings.xml",
    ".github/workflows/build-benchmark-app.yml",
    "tools/build_benchmark_app.sh",
    "tools/sync_chromium.sh", "tools/build_webview.sh", "tools/check_build_host.sh",
    "tests/test_project_metadata.py", "tests/test_build_contract.py",
    "tests/test_webview_app_contract.py",
]

def main() -> int:
    errors = [f"Missing required file: {p}" for p in REQUIRED if not (ROOT / p).is_file()]
    try:
        data = json.loads((ROOT / "project.json").read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as exc:
        data = {}
        errors.append(f"Invalid project.json: {exc}")

    expected = {
        "name": "A06 WebCore",
        "project_type": "android-webview-provider",
        "not_a_browser": True,
        "target_os": "android",
        "target_cpu": "arm64",
        "chromium_version": "158.0.8127.36",
        "chromium_release_channel": "stable",
        "production_provider_package": "io.github.astromg01.a06webcore",
        "provider_test_package": "com.android.webview",
    }
    for key, value in expected.items():
        if data.get(key) != value:
            errors.append(f"project.json: expected {key}={value!r}")

    revision = data.get("chromium_revision", "")
    if not re.fullmatch(r"[0-9a-f]{40}", revision):
        errors.append("project.json: chromium_revision must be a full 40-character SHA")

    device = data.get("device", {})
    if device.get("model") != "SM-A065M" or device.get("android_version") != 16:
        errors.append("Target must remain Galaxy A06 SM-A065M / Android 16")

    readme = (ROOT / "README.md").read_text(encoding="utf-8") if (ROOT / "README.md").exists() else ""
    if "não é um navegador" not in readme.lower():
        errors.append("README must explicitly state that this is not a browser")

    upstream = (ROOT / "chromium/UPSTREAM.md").read_text(encoding="utf-8") if (ROOT / "chromium/UPSTREAM.md").exists() else ""
    if revision and revision not in upstream:
        errors.append("chromium/UPSTREAM.md must contain the exact pinned revision")

    diagnostic = data.get("diagnostic_app", {})
    diagnostic_expected = {
        "application_id": "io.github.astromg01.a06webcore.bench",
        "min_sdk": 26,
        "target_sdk": 36,
        "android_gradle_plugin": "9.4.1",
        "gradle": "9.6.0",
        "java": 17,
        "androidx_webkit": "1.18.0",
    }
    for key, value in diagnostic_expected.items():
        if diagnostic.get(key) != value:
            errors.append(f"project.json diagnostic_app: expected {key}={value!r}")

    if errors:
        print("A06 WebCore scaffold validation: FAILED")
        print("\n".join(f"- {e}" for e in errors))
        return 1
    print(f"A06 WebCore scaffold validation: PASSED ({len(REQUIRED)} required files checked)")
    print("Pinned Chromium revision metadata is consistent.")
    print("This does not sync/compile Chromium or validate runtime provider selection.")
    print("The diagnostics app source is checked, but APK availability depends on its separate Android build workflow.")
    return 0

if __name__ == "__main__":
    sys.exit(main())
