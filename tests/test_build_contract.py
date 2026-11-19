import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

class BuildContractTests(unittest.TestCase):
    def test_build_script_uses_pinned_channel_and_target(self):
        script = (ROOT / "tools/build_webview.sh").read_text(encoding="utf-8")
        self.assertIn("system_webview_apk", script)
        self.assertIn("rev-parse HEAD", script)
        self.assertIn("A06_WEBVIEW_KEYSTORE_PATH", script)
        self.assertIn("a06-arm64.gn", script)
        self.assertIn("a06-arm64-aosp-custom.gn", script)
        self.assertIn("default_android_keystore_password", script)
        self.assertIn("check_build_host.sh", script)
        self.assertIn("CHROMIUM_CHANNEL", script)
        self.assertIn("chromium_channels", script)
        self.assertIn('android_channel = %s', script)

    def test_sync_script_uses_channel_specific_revision(self):
        script = (ROOT / "tools/sync_chromium.sh").read_text(encoding="utf-8")
        self.assertIn("check_build_host.sh", script)
        self.assertIn("gclient sync", script)
        self.assertIn("CHROMIUM_CHANNEL", script)
        self.assertIn("chromium_channels", script)
        self.assertIn('--revision="src@$EXPECTED_REVISION"', script)

    def test_gn_flavors_are_distinct_and_low_end_tuned(self):
        local = (ROOT / "chromium/args/a06-arm64.gn").read_text(encoding="utf-8")
        custom = (ROOT / "chromium/args/a06-arm64-aosp-custom.gn").read_text(encoding="utf-8")
        self.assertIn('system_webview_package_name = "com.android.webview"', local)
        self.assertIn('system_webview_package_name = "io.github.astromg01.a06webcore"', custom)
        self.assertIn("is_official_build = true", custom)
        self.assertIn("disable_fieldtrial_testing_config = true", custom)
        self.assertIn("is_high_end_android = false", local)
        self.assertIn("is_high_end_android = false", custom)
        self.assertNotIn('android_channel = "stable"', custom)

if __name__ == "__main__":
    unittest.main()
