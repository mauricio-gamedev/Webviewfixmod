import unittest
import xml.etree.ElementTree as ET
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ANDROID_NS = "{http://schemas.android.com/apk/res/android}"

class WebViewHarnessContractTests(unittest.TestCase):
    def test_manifest_does_not_request_network_or_storage_permissions(self):
        tree = ET.parse(ROOT / "app/src/main/AndroidManifest.xml")
        root = tree.getroot()
        permissions = {
            node.attrib.get(ANDROID_NS + "name")
            for node in root.findall("uses-permission")
        }
        self.assertNotIn("android.permission.INTERNET", permissions)
        self.assertNotIn("android.permission.READ_EXTERNAL_STORAGE", permissions)
        self.assertNotIn("android.permission.WRITE_EXTERNAL_STORAGE", permissions)

    def test_harness_blocks_network_and_file_access(self):
        source = (ROOT / "app/src/main/java/io/github/astromg01/a06webcore/bench/MainActivity.java").read_text(encoding="utf-8")
        self.assertIn("setBlockNetworkLoads(true)", source)
        self.assertIn("setAllowFileAccess(false)", source)
        self.assertIn("setAllowContentAccess(false)", source)
        self.assertIn("MIXED_CONTENT_NEVER_ALLOW", source)
        self.assertIn("setSafeBrowsingEnabled(true)", source)
        self.assertIn("onRenderProcessGone", source)

    def test_harness_does_not_expose_javascript_bridge(self):
        source = (ROOT / "app/src/main/java/io/github/astromg01/a06webcore/bench/MainActivity.java").read_text(encoding="utf-8")
        self.assertNotIn("addJavascriptInterface", source)
        self.assertIn("setWebContentsDebuggingEnabled(false)", source)

    def test_test_page_is_local_and_has_no_remote_connectivity(self):
        page = (ROOT / "app/src/main/assets/bench.html").read_text(encoding="utf-8")
        self.assertIn("connect-src 'none'", page)
        self.assertIn("window.__a06WebCoreBench", page)
        self.assertIn("WebAssembly.Module", page)
        self.assertIn('getContext("webgl2")', page)

if __name__ == "__main__":
    unittest.main()
