.pragma library

// Key units follow the UX3405CA US deck, including its half-height arrows.
// The diagram is schematic: key spacing is enlarged to fit action labels.
// Reference: ASUS E23648, front view (p.17).
function zenbookKeys() {
  var keys = []
  function key(label, name, code, x, y, w, h, modifier) {
    keys.push({ label: label, name: name, code: code, x: x, y: y,
      w: w || 1, h: h || 1, modifier: modifier || "" })
  }
  key("Esc", "ESCAPE", 9, 0, 0, 0.9375, 0.62)
  for (var f = 1; f <= 12; f++)
    key("F" + f, "F" + f, f <= 10 ? 66 + f : 84 + f, f * 0.9375, 0, 0.9375, 0.62)
  key("PrtSc", "PRINT", 107, 12.1875, 0, 0.9375, 0.62)
  key("Power", "POWER", 124, 13.125, 0, 0.9375, 0.62)
  key("Delete", "DELETE", 119, 14.0625, 0, 0.9375, 0.62)
  var labels = ["`", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "−", "="]
  var names = ["GRAVE", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "MINUS", "EQUAL"]
  for (var n = 0; n < labels.length; n++) key(labels[n], names[n], n === 0 ? 49 : 9 + n, n, 0.72)
  key("Backspace", "BACKSPACE", 22, 13, 0.72, 2)
  key("Tab", "TAB", 23, 0, 1.72, 1.5)
  var qwerty = "QWERTYUIOP"
  for (var q = 0; q < qwerty.length; q++) key(qwerty[q], qwerty[q], 24 + q, 1.5 + q, 1.72)
  key("[", "BRACKETLEFT", 34, 11.5, 1.72)
  key("]", "BRACKETRIGHT", 35, 12.5, 1.72)
  key("\\", "BACKSLASH", 51, 13.5, 1.72, 1.5)
  key("Caps", "CAPS_LOCK", 66, 0, 2.72, 1.75)
  var home = "ASDFGHJKL"
  for (var a = 0; a < home.length; a++) key(home[a], home[a], 38 + a, 1.75 + a, 2.72)
  key(";", "SEMICOLON", 47, 10.75, 2.72)
  key("'", "APOSTROPHE", 48, 11.75, 2.72)
  key("Enter", "RETURN", 36, 12.75, 2.72, 2.25)
  key("Shift", "SHIFT_L", 50, 0, 3.72, 2.25, 1, "SHIFT")
  var bottom = "ZXCVBNM"
  for (var z = 0; z < bottom.length; z++) key(bottom[z], bottom[z], 52 + z, 2.25 + z, 3.72)
  key(",", "COMMA", 59, 9.25, 3.72)
  key(".", "PERIOD", 60, 10.25, 3.72)
  key("/", "SLASH", 61, 11.25, 3.72)
  key("Shift", "SHIFT_R", 62, 12.25, 3.72, 2.75, 1, "SHIFT")
  key("Ctrl", "CONTROL_L", 37, 0, 4.72, 1.25, 1, "CTRL")
  key("Fn", "FN", 0, 1.25, 4.72)
  key("Super", "SUPER_L", 133, 2.25, 4.72, 1, 1, "SUPER")
  key("Alt", "ALT_L", 64, 3.25, 4.72, 1, 1, "ALT")
  key("Space", "SPACE", 65, 4.25, 4.72, 5)
  key("Alt", "ALT_R", 108, 9.25, 4.72, 1, 1, "ALT")
  // The Copilot key emits a chord, not a unique keycode. Do not invent one.
  key("Copilot", "COPILOT", 0, 10.25, 4.72)
  key("←  Home", "LEFT", 113, 11.25, 5.22, 1.25, 0.5)
  key("↑  PgUp", "UP", 111, 12.5, 4.72, 1.25, 0.5)
  key("↓  PgDn", "DOWN", 116, 12.5, 5.22, 1.25, 0.5)
  key("→  End", "RIGHT", 114, 13.75, 5.22, 1.25, 0.5)
  return keys
}

function aliases(name) {
  var value = String(name || "").toUpperCase()
  var lookup = { ENTER: "RETURN", ESC: "ESCAPE", SPACEBAR: "SPACE", PRINTSCREEN: "PRINT",
    QUOTELEFT: "GRAVE", QUOTERIGHT: "APOSTROPHE", CAPSLOCK: "CAPS_LOCK" }
  return lookup[value] || value
}

function sameModifiers(binding, mask) {
  var expected = String(mask || "SUPER").split("_")
  if (!binding || !Array.isArray(binding.modifiers) || expected.length !== binding.modifiers.length) return false
  return expected.every(function(modifier) { return binding.modifiers.indexOf(modifier) !== -1 })
}

function shortDescription(description) {
  // Full text is always retained for the hover detail. Only common, repetitive
  // phrases are shortened on the small keycaps.
  return String(description || "")
    .replace(/^Switch to workspace (\d+)$/i, "Workspace $1")
    .replace(/^Move window to workspace (\d+)$/i, "Move to $1")
    .replace(/^Focus on (.*) window$/i, "Focus $1")
    .replace(/^Toggle window floating\/tiling$/i, "Float / tile")
    .replace(/^Toggle window /i, "")
    .replace(/^Toggle /i, "")
    .replace(/^Keybindings$/i, "Shortcuts")
}

function extraLabel(binding) {
  var name = aliases(binding.key)
  var fn = { HOME: "Fn + ←", END: "Fn + →", PRIOR: "Fn + ↑", PAGE_UP: "Fn + ↑",
    NEXT: "Fn + ↓", PAGE_DOWN: "Fn + ↓" }
  return fn[name] || String(binding.key).replace(/^code:/i, "Key ")
}

function keyboard(catalog, mask, profile) {
  if (profile !== "asus-ux3405ca-us") return { keys: [], extras: [], total: 0 }
  var keys = zenbookKeys()
  var modifiers = String(mask || "SUPER").split("_")
  keys.forEach(function(key) { key.bindings = []; key.held = modifiers.indexOf(key.modifier) !== -1 })
  var source = catalog && Array.isArray(catalog.bindings) ? catalog.bindings : []
  var extras = []
  var total = 0
  source.forEach(function(binding) {
    if (!binding || binding.trackable !== true || binding.guideEligible !== true || !sameModifiers(binding, mask)) return
    total++
    var name = aliases(binding.key)
    // Prefer the exact keysym. A catalog can contain several possible codes
    // for a symbol; those must not put an L binding on a modifier key.
    var named = keys.filter(function(key) { return key.name === name })
    var code = /^CODE:(\d+)$/.exec(name)
    var matches = code ? keys.filter(function(key) { return key.code > 0 && key.code === Number(code[1]) }) : named
    if (matches.length === 0) { extras.push(binding); return }
    matches.forEach(function(key) { key.bindings.push(binding) })
  })
  keys.forEach(function(key) {
    key.action = key.bindings.map(function(binding) { return shortDescription(binding.description) }).join(" · ")
    key.detail = key.bindings.map(function(binding) { return binding.combo + " — " + binding.description }).join("  /  ")
  })
  return { keys: keys, extras: extras, total: total }
}
