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
  // Follow the theme's selection highlight (Akira's blue), rather than the
  // first stop of its menu-border gradient (Akira's red).
  readonly property color highlightColor: Commons.Color.menu.selectedText
  // Match menu/control styling live. A contrast floor keeps highly translucent
  // themes readable over app text; the frosted board uses the theme's scrim.
  readonly property color keySurfaceColor: Util.alpha(Commons.Color.menu.background,
    Math.max(0.88, Commons.Color.menu.background.a))
  readonly property var normalKeyBorder: Border.controlSpec("normal",
    Commons.Color.menu.text, highlightColor)
  readonly property var heldKeyBorder: Border.flat(highlightColor,
    Math.max(1, Style.selectedBorderWidth || Style.normalBorderWidth + 1))
  readonly property var unusedKeyBorder: Border.flat(
    Util.alpha(Commons.Color.menu.text, Style.normalBorderAlpha * 0.2), Style.normalBorderWidth)
  readonly property var deck: KeyboardModel.keyboard(catalog, modifierMask, hardware.profile)
  readonly property real unit: width / 15
  readonly property real rowHeight: Math.max(48, Math.min(74, unit * 0.94))
  readonly property real gap: Math.max(3, unit * 0.055)
  readonly property real boardHeight: rowHeight * 5.72
  readonly property real extraHeight: extraFlow.visible ? extraFlow.height + 12 : 0
  readonly property real backdropPadding: 8
  readonly property real paintedBottom: height + backdropPadding
  implicitHeight: boardHeight + extraHeight + 49

  // The theme's scrim gives layer blur a continuous, bounded surface.
  // Window shapes remain visible while sharp background text is softened.
  BorderSurface {
    x: -root.backdropPadding; y: -root.backdropPadding
    width: parent.width + root.backdropPadding * 2
    height: root.height + root.backdropPadding * 2
    radius: Style.cornerRadius
    color: Commons.Color.menu.scrim
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
      x: modelData.x * root.unit + root.gap / 2
      y: modelData.y * root.rowHeight + root.gap / 2
      width: modelData.w * root.unit - root.gap
      height: modelData.h * root.rowHeight - root.gap
      radius: Style.cornerRadius
      color: selected || bound ? root.keySurfaceColor : "transparent"
      borderSpec: selected ? root.heldKeyBorder : bound ? root.normalKeyBorder : root.unusedKeyBorder
      Behavior on color { ColorAnimation { duration: 80 } }

      Text {
        id: legend
        x: 7; y: keycap.modelData.h < 0.7 ? 3 : 5
        width: parent.width - 14
        height: keycap.modelData.h < 0.7 ? parent.height - 6 : 17
        text: keycap.modelData.label
        visible: keycap.bound || keycap.selected
        textFormat: Text.PlainText
        color: keycap.bound || keycap.selected ? root.highlightColor : Commons.Color.menu.text
        style: keycap.bound || keycap.selected ? Text.Outline : Text.Normal
        styleColor: Commons.Color.menu.background
        opacity: keycap.bound || keycap.selected ? 1 : 0.16
        font.family: Style.font.family
        font.pixelSize: keycap.modelData.h < 0.7 ? 10 : 13
        font.bold: true
        verticalAlignment: Text.AlignVCenter
        fontSizeMode: Text.HorizontalFit
        minimumPixelSize: 8
      }

      Text {
        x: 6; y: legend.y + legend.height + 1
        width: parent.width - 12
        height: Math.max(0, parent.height - y - 5)
        visible: keycap.modelData.h >= 0.7 && keycap.bound
        text: keycap.modelData.action
        textFormat: Text.PlainText
        color: Commons.Color.menu.text
        style: Text.Outline
        styleColor: Commons.Color.menu.background
        font.family: Style.font.family
        font.pixelSize: root.unit >= 65 ? 10 : 9
        fontSizeMode: Text.Fit
        minimumPixelSize: 9
        wrapMode: Text.WordWrap
        elide: Text.ElideRight
        maximumLineCount: 3
      }

      HoverHandler {
        onHoveredChanged: {
          if (hovered) root.hoverDetail = keycap.modelData.detail || keycap.modelData.label
          else root.hoverDetail = ""
        }
      }
    }
  }

  // Half-height arrows and Fn-only keys need room for readable descriptions.
  Flow {
    id: extraFlow
    y: root.boardHeight + 16
    width: parent.width
    spacing: 5
    readonly property var entries: root.deck.extras.concat(root.deck.keys
      .filter(function(key) { return key.h < 0.7 && key.bindings.length > 0 })
      .reduce(function(result, key) { return result.concat(key.bindings) }, []))
    visible: entries.length > 0
    Repeater {
      model: extraFlow.entries
      delegate: BorderSurface {
        required property var modelData
        width: extraLabel.implicitWidth + 16
        height: 25
        radius: Style.cornerRadius
        color: root.keySurfaceColor
        borderSpec: root.normalKeyBorder
        Text {
          id: extraLabel
          anchors.centerIn: parent
          text: KeyboardModel.extraLabel(parent.modelData) + " · "
            + KeyboardModel.shortDescription(parent.modelData.description)
          textFormat: Text.PlainText
          font.family: Style.font.family
          font.pixelSize: 10
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
      font.family: Style.font.family
      font.pixelSize: 11
      verticalAlignment: Text.AlignVCenter
      elide: Text.ElideRight
    }
  }
}
