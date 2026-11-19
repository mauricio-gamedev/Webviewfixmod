import json
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

if __name__ == "__main__":
    unittest.main()
