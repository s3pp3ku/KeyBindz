import QtQuick
import qs.Commons
import qs.Commons as Commons
import qs.Ui
import "KeyboardModel.js" as KeyboardModel

Item {
  id: root
  property var catalog: null
  property string modifierMask: "SUPER"
  property var hardware: ({})
  property string highlightedBindingId: ""
  property string hoverDetail: ""
  function mixColors(from, to, amount) {
    var t = Math.max(0, Math.min(1, Number(amount) || 0))
    return Qt.rgba(from.r + (to.r - from.r) * t,
      from.g + (to.g - from.g) * t,
      from.b + (to.b - from.b) * t, 1)
  }

  // Follow the theme's selection highlight (Akira's blue), rather than the
  // first stop of its menu-border gradient (Akira's red).
  readonly property color highlightColor: Commons.Color.menu.selectedText
  // Dark charcoal chosen for the key surfaces, rather than the theme's
  // near-black menu background.
  readonly property color charcoal: "#141414"
  // Match menu/control styling live. A contrast floor keeps highly translucent
  // themes readable over app text; the frosted board uses the theme's scrim.
  readonly property color keySurfaceColor: Util.alpha(charcoal,
    Math.max(0.92, Commons.Color.menu.background.a))
  readonly property var normalKeyBorder: Border.controlSpec("normal",
    Commons.Color.menu.text, highlightColor)
  readonly property var heldKeyBorder: Border.flat(highlightColor,
    Math.max(1, Style.selectedBorderWidth || Style.normalBorderWidth + 1))
  // Missing keys stay fully transparent so the frosted desktop shows through;
  // their soft outline is all that defines the shape.
  readonly property color unusedOutlineColor: Util.alpha(Commons.Color.menu.text,
    Style.normalBorderAlpha)
  readonly property var unusedKeyBorder: Border.flat(unusedOutlineColor, Style.normalBorderWidth)
  readonly property var deck: KeyboardModel.keyboard(catalog, modifierMask, hardware.profile)
  // JetBrains Mono keeps key legends keyboard-like; a proportional face makes
  // wrapped command names easier to read at small sizes.
  readonly property string commandFont: "Noto Sans"
  readonly property real unit: width / 15
  // Keys get their own small radius: enough to read as keycaps, not the much
  // larger rounded-panel radius the theme uses for windows and menus.
  readonly property real keyRadius: Math.max(2, Math.min(4, root.unit * 0.04))
  readonly property real rowHeight: Math.max(48, Math.min(74, unit * 0.94))
  readonly property real gap: Math.max(3, unit * 0.055)
  readonly property real boardHeight: rowHeight * 5.72
  readonly property real extraHeight: extraFlow.visible ? extraFlow.height + 12 : 0
  readonly property real backdropPadding: 8
  readonly property real paintedBottom: height + backdropPadding
  implicitHeight: boardHeight + extraHeight + 49

  // The theme's scrim gives layer blur a continuous, bounded surface.
  // Window shapes remain visible while sharp background text is softened.
  // A lighter, slightly warm scrim keeps that blur but lets unused areas show
  // more of the desktop; bound keys keep their opaque charcoal surfaces.
  readonly property color backdropTint: Util.alpha(mixColors(Commons.Color.menu.scrim,
    Commons.Color.menu.text, 0.1), Commons.Color.menu.scrim.a * 0.6)
  BorderSurface {
    x: -root.backdropPadding; y: -root.backdropPadding
    width: parent.width + root.backdropPadding * 2
    height: root.height + root.backdropPadding * 2
    radius: Style.cornerRadius
    color: root.backdropTint
    borderSpec: Border.surfaceSpec("menu", "border", Commons.Color.menu.border, Style.normalBorderWidth)
  }

  Repeater {
    model: root.deck.keys
    delegate: BorderSurface {
      id: keycap
      required property var modelData
      readonly property bool bound: modelData.bindings.length > 0
      readonly property bool highlighted: modelData.bindings.some(function(binding) {
        return binding.id === root.highlightedBindingId
      })
      readonly property bool selected: modelData.held || highlighted
      readonly property bool wideSpace: modelData.name === "SPACE"
      readonly property bool compactTopRow: modelData.h >= 0.6 && modelData.h < 0.7
      readonly property bool showAction: bound && (modelData.h >= 0.7 || compactTopRow)
      readonly property real legendBand: wideSpace ? 22 : 17
      x: modelData.x * root.unit + root.gap / 2
      y: modelData.y * root.rowHeight + root.gap / 2
      width: modelData.w * root.unit - root.gap
      height: modelData.h * root.rowHeight - root.gap
      radius: root.keyRadius
      color: selected || bound ? root.keySurfaceColor : "transparent"
      borderSpec: selected ? root.heldKeyBorder : bound ? root.normalKeyBorder : root.unusedKeyBorder
      Behavior on color { ColorAnimation { duration: 80 } }

      Text {
        id: legend
        x: 7; y: keycap.compactTopRow ? 2 : keycap.modelData.h < 0.7 ? 3 : 5
        width: parent.width - 14
        height: keycap.compactTopRow && keycap.bound ? 14
          : keycap.modelData.h < 0.7 ? parent.height - 6 : keycap.legendBand
        text: keycap.modelData.label
        visible: keycap.bound || keycap.selected
        textFormat: Text.PlainText
        color: root.highlightColor
        font.family: Style.font.family
        font.pixelSize: keycap.modelData.h < 0.7 ? 11 : keycap.wideSpace ? 18 : 14
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        fontSizeMode: Text.HorizontalFit
        minimumPixelSize: 8
      }

      // A hairline separates the physical key label from its command, keeping
      // both readable without the command shrinking into the legend.
      Rectangle {
        id: legendRule
        x: 7
        y: legend.y + legend.height + 1
        width: parent.width - 14
        height: 1
        visible: keycap.modelData.h >= 0.7 && keycap.bound
        color: Util.alpha(Commons.Color.menu.text, 0.1)
      }

      Text {
        x: 7
        y: legendRule.visible ? legendRule.y + 2 : legend.y + legend.height + 1
        width: parent.width - 14
        height: Math.max(0, parent.height - y - (keycap.compactTopRow ? 3 : 5))
        visible: keycap.showAction
        text: keycap.modelData.action
        textFormat: Text.PlainText
        color: Commons.Color.menu.text
        font.family: root.commandFont
        font.pixelSize: keycap.modelData.h < 0.7 ? 9 : keycap.wideSpace ? 14 : root.unit >= 65 ? 11 : 10
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: keycap.compactTopRow ? Text.AlignVCenter : Text.AlignTop
        fontSizeMode: Text.Fit
        minimumPixelSize: keycap.modelData.h < 0.7 ? 6 : 9
        wrapMode: keycap.modelData.h < 0.7 ? Text.NoWrap : Text.WordWrap
        elide: Text.ElideRight
        maximumLineCount: keycap.modelData.h < 0.7 ? 1 : 3
      }

      HoverHandler {
        onHoveredChanged: {
          if (hovered) root.hoverDetail = keycap.modelData.detail || keycap.modelData.label
          else root.hoverDetail = ""
        }
      }
    }
  }

  // Top-row keys are half height but wide enough for a compact action line.
  // The shorter arrow keys keep their descriptions in this footer instead.
  Flow {
    id: extraFlow
    y: root.boardHeight + 16
    width: parent.width
    spacing: 5
    readonly property var entries: root.deck.extras.concat(root.deck.keys
      .filter(function(key) { return key.h < 0.6 && key.bindings.length > 0 })
      .reduce(function(result, key) { return result.concat(key.bindings) }, []))
    visible: entries.length > 0
    Repeater {
      model: extraFlow.entries
      delegate: BorderSurface {
        required property var modelData
        width: extraLabel.implicitWidth + 16
        height: 25
        radius: root.keyRadius
        color: root.keySurfaceColor
        borderSpec: root.normalKeyBorder
        Text {
          id: extraLabel
          anchors.centerIn: parent
          text: KeyboardModel.extraLabel(parent.modelData) + " · "
            + KeyboardModel.shortDescription(parent.modelData.description)
          textFormat: Text.PlainText
          font.family: root.commandFont
          font.pixelSize: 11
          color: Commons.Color.menu.text
        }
        HoverHandler {
          onHoveredChanged: root.hoverDetail = hovered
            ? parent.modelData.combo + " — " + parent.modelData.description : ""
        }
      }
    }
  }

  Rectangle {
    y: root.boardHeight + root.extraHeight + 17
    width: parent.width
    height: 24
    radius: Style.cornerRadius
    color: root.keySurfaceColor
    Text {
      anchors.fill: parent
      anchors.leftMargin: 8; anchors.rightMargin: 8
      text: root.hoverDetail || (root.deck.total === 0
        ? "No registered shortcuts for " + root.modifierMask.split("_").join(" + ")
        : root.deck.total + " shortcuts · Add modifiers to change the guide · Hover a key for its full description")
      textFormat: Text.PlainText
      color: Commons.Color.menu.text
      font.family: root.commandFont
      font.pixelSize: 11
      verticalAlignment: Text.AlignVCenter
      elide: Text.ElideRight
    }
  }
}
