import json
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

class ProjectMetadataTests(unittest.TestCase):
    def test_project_target(self):
        data = json.loads((ROOT / "project.json").read_text(encoding="utf-8"))
        self.assertEqual(data["project_type"], "android-webview-provider")
        self.assertTrue(data["not_a_browser"])
        self.assertEqual(data["target_cpu"], "arm64")
        self.assertEqual(data["device"]["model"], "SM-A065M")
        self.assertEqual(data["device"]["android_version"], 16)

    def test_chromium_revision_is_pinned(self):
        data = json.loads((ROOT / "project.json").read_text(encoding="utf-8"))
        self.assertEqual(data["chromium_version"], "158.0.8127.36")
        self.assertRegex(data["chromium_revision"], r"^[0-9a-f]{40}$")
        self.assertEqual(data["chromium_release_channel"], "stable")

    def test_provider_package_separation(self):
        data = json.loads((ROOT / "project.json").read_text(encoding="utf-8"))
        self.assertEqual(data["provider_test_package"], "com.android.webview")
        self.assertEqual(data["production_provider_package"], "io.github.astromg01.a06webcore")
        self.assertNotEqual(data["provider_test_package"], data["production_provider_package"])

if __name__ == "__main__":
    unittest.main()
