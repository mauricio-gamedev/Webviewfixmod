#!/usr/bin/env python3
"""Validate repository scaffold without Chromium build dependencies."""
from __future__ import annotations
import json
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
REQUIRED = [
    "README.md", "AGENTS.md", "project.json",
    "chromium/args/a06-arm64.gn",
    "chromium/args/a06-arm64-aosp-custom.gn",
    "platform/aosp/config_webview_packages.xml.template",
    "platform/aosp/README.md",
    "chromium/UPSTREAM.md", "chromium/PATCH_POLICY.md",
    "docs/architecture.md", "docs/provider-integration.md",
    "docs/build.md", "docs/device-profile.md",
    "docs/benchmark-matrix.md", "docs/ROADMAP.md",
    "docs/SESSION_CHECKPOINT.md",
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
        "production_provider_package": "io.github.astromg01.a06webcore",
    }
    for key, value in expected.items():
        if data.get(key) != value:
            errors.append(f"project.json: expected {key}={value!r}")

    device = data.get("device", {})
    if device.get("model") != "SM-A065M" or device.get("android_version") != 16:
        errors.append("Target must remain Galaxy A06 SM-A065M / Android 16")

    readme = (ROOT / "README.md").read_text(encoding="utf-8") if (ROOT / "README.md").exists() else ""
    if "não é um navegador" not in readme.lower():
        errors.append("README must explicitly state that this is not a browser")

    if errors:
        print("A06 WebCore scaffold validation: FAILED")
        print("\n".join(f"- {e}" for e in errors))
        return 1
    print(f"A06 WebCore scaffold validation: PASSED ({len(REQUIRED)} required files checked)")
    print("This does not compile Chromium or validate runtime provider selection.")
    return 0

if __name__ == "__main__":
    sys.exit(main())
