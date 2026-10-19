#!/usr/bin/env python3
import importlib.machinery
from pathlib import Path
import unittest
import sys

sys.dont_write_bytecode = True

module = importlib.machinery.SourceFileLoader("detect_keyboard", str(Path(__file__).resolve().parents[1] / "scripts/detect-keyboard")).load_module()


class Detection(unittest.TestCase):
    def setUp(self):
        self.physical = [{"name": "AT Translated Set 2 keyboard", "hyprName": "at-translated-set-2-keyboard", "internal": True}]
        self.devices = {"keyboards": [
            {"name": "hl-virtual-keyboard-fcitx5", "main": True, "layout": "us"},
            {"name": "at-translated-set-2-keyboard", "main": False, "layout": "us", "variant": "", "active_layout_index": 0}]}

    def detect(self, vendor="ASUSTeK COMPUTER INC.", product="ASUS Zenbook 14 UX3405CA_UX3405CA"):
        return module.detect(vendor, product, self.physical, self.devices)

    def test_virtual_main_does_not_override_laptop(self):
        self.assertEqual(self.detect()["profile"], "asus-ux3405ca-us")

    def test_hyprland_bare_none_is_handled_without_rewriting_strings(self):
        parsed = module.parse_devices('{"keyboards":[{"name":"none", "active_layout_index":none}]}')
        self.assertEqual(parsed["keyboards"][0]["name"], "none")
        self.assertIsNone(parsed["keyboards"][0]["active_layout_index"])

    def test_unknown_hardware_or_missing_compositor_falls_back(self):
        self.assertEqual(self.detect(product="Different laptop")["profile"], "")
        self.devices = {}
        self.assertEqual(self.detect()["profile"], "")

    def test_active_layout_and_variant_are_respected(self):
        self.devices["keyboards"][1].update(layout="us,de", variant=",", active_layout_index=1)
        self.assertEqual(self.detect()["profile"], "")
        self.devices["keyboards"][1].update(active_layout_index=0, variant="dvorak,")
        self.assertEqual(self.detect()["profile"], "")

    def test_physical_external_main_does_not_use_laptop_outline(self):
        self.physical.append({"name": "USB Keyboard", "hyprName": "usb-keyboard", "internal": False})
        self.devices["keyboards"].append({"name": "usb-keyboard", "main": True, "layout": "us"})
        self.assertEqual(self.detect()["profile"], "")


if __name__ == "__main__":
    unittest.main()
