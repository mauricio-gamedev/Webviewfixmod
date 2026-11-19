import json
import re
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CHANNELS = {"stable", "beta", "dev", "canary"}

class ProjectMetadataTests(unittest.TestCase):
    def test_project_target(self):
        data = json.loads((ROOT / "project.json").read_text(encoding="utf-8"))
        self.assertEqual(data["project_type"], "android-webview-provider")
        self.assertTrue(data["not_a_browser"])
        self.assertEqual(data["target_cpu"], "arm64")
        self.assertEqual(data["device"]["model"], "SM-A065M")
        self.assertEqual(data["device"]["android_version"], 16)

    def test_all_webview_release_channels_are_pinned(self):
        data = json.loads((ROOT / "project.json").read_text(encoding="utf-8"))
        self.assertEqual(set(data["chromium_channels"]), CHANNELS)
        for channel, pin in data["chromium_channels"].items():
            self.assertRegex(pin["revision"], r"^[0-9a-f]{40}$")
            self.assertEqual(pin["tag"], pin["version"])
            self.assertTrue(pin["branch_position"])

    def test_active_channel_aliases_match_canary_pin(self):
        data = json.loads((ROOT / "project.json").read_text(encoding="utf-8"))
        active = data["chromium_channels"][data["chromium_release_channel"]]
        self.assertEqual(data["chromium_release_channel"], "canary")
        self.assertEqual(data["chromium_version"], active["version"])
        self.assertEqual(data["chromium_revision"], active["revision"])
        self.assertEqual(data["chromium_tag"], active["tag"])
        self.assertEqual(data["chromium_branch_position"], active["branch_position"])

    def test_provider_package_separation(self):
        data = json.loads((ROOT / "project.json").read_text(encoding="utf-8"))
        self.assertEqual(data["provider_test_package"], "com.android.webview")
        self.assertEqual(data["production_provider_package"], "io.github.astromg01.a06webcore")
        self.assertNotEqual(data["provider_test_package"], data["production_provider_package"])

if __name__ == "__main__":
    unittest.main()
