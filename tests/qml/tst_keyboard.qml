import QtQuick
import QtTest
import "../../KeyboardModel.js" as KeyboardModel

TestCase {
  name: "KeyBindzKeyboard"
  function binding(id, key, codes, description, modifiers) {
    return { id: id, key: key, xkbCodes: codes, combo: "SUPER + " + key,
      description: description, modifiers: modifiers || ["SUPER"],
      trackable: true, guideEligible: true }
  }
  function test_physicalCodesAndNamedBindings() {
    var source = { bindings: [
      binding("workspace", "code:10", [10], "Switch to workspace 1"),
      binding("terminal", "RETURN", [36], "Terminal"),
      binding("layout", "L", [37, 46, 50, 64, 133], "Layout"),
      binding("home", "HOME", [79, 110], "Restore window width"),
      binding("shift", "RETURN", [36], "Alternate terminal", ["SUPER", "SHIFT"])
    ] }
    var deck = KeyboardModel.keyboard(source, "SUPER", "asus-ux3405ca-us")
    compare(deck.total, 4)
    compare(deck.keys.filter(function(k) { return k.name === "1" })[0].action, "Workspace 1")
    compare(deck.keys.filter(function(k) { return k.name === "RETURN" })[0].action, "Terminal")
    compare(deck.keys.filter(function(k) { return k.name === "L" })[0].bindings[0].id, "layout")
    compare(deck.keys.filter(function(k) { return k.name === "CONTROL_L" })[0].bindings.length, 0)
    compare(deck.keys.filter(function(k) { return k.name === "SUPER_L" })[0].held, true)
    compare(deck.extras.length, 1)
    compare(deck.extras[0].key, "HOME")
    compare(KeyboardModel.keyboard(source, "SUPER_SHIFT", "asus-ux3405ca-us").total, 1)
    compare(KeyboardModel.keyboard(source, "CTRL", "asus-ux3405ca-us").total, 0)
    compare(KeyboardModel.keyboard(source, "SUPER", "unknown").keys.length, 0)
  }
  function test_duplicateBindingsAndFiltering() {
    var first = binding("press", "K", [45], "First")
    var second = binding("release", "K", [45], "Second")
    var hidden = binding("hidden", "J", [44], "Hidden")
    hidden.guideEligible = false
    var mouse = binding("mouse", "mouse:272", [], "Move")
    mouse.trackable = false
    var deck = KeyboardModel.keyboard({ bindings: [first, second, hidden, mouse] }, "SUPER", "asus-ux3405ca-us")
    compare(deck.total, 2)
    var k = deck.keys.filter(function(key) { return key.name === "K" })[0]
    compare(k.bindings.length, 2)
    verify(k.detail.indexOf("First") !== -1 && k.detail.indexOf("Second") !== -1)
  }
  function test_geometryDoesNotOverlapOrEscape() {
    var keys = KeyboardModel.zenbookKeys()
    for (var i = 0; i < keys.length; i++) {
      var a = keys[i]
      verify(a.x >= 0 && a.y >= 0 && a.x + a.w <= 15 && a.y + a.h <= 5.72 + 0.0001)
      for (var j = i + 1; j < keys.length; j++) {
        var b = keys[j]
        verify(!(a.x < b.x + b.w - 0.001 && a.x + a.w > b.x + 0.001
          && a.y < b.y + b.h - 0.001 && a.y + a.h > b.y + 0.001), a.name + " overlaps " + b.name)
      }
    }
  }
}
