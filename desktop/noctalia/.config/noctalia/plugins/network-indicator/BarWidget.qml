import qs.Commons
import qs.Widgets
import qs.Services.UI
import qs.Services.System
import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    property var pluginApi: null

    property ShellScreen screen
    property string widgetId: ""
    property string section: ""
    property int sectionWidgetIndex: -1
    property int sectionWidgetsCount: 0

    // ── Configuration ──

    property var cfg: pluginApi?.pluginSettings || ({})
    property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

    property string arrowType: cfg.arrowType ?? defaults.arrowType

    property bool useCustomColors: cfg.useCustomColors ?? defaults.useCustomColors
    property bool showNumbers: cfg.showNumbers ?? defaults.showNumbers

    property color colorSilent: root.useCustomColors && cfg.colorSilent || Color.mSurfaceVariant
    property color colorTx: root.useCustomColors && cfg.colorTx || Color.mSecondary
    property color colorRx: root.useCustomColors && cfg.colorRx || Color.mPrimary
    property color colorText: root.useCustomColors && cfg.colorText || Color.mOnSurfaceVariant

    property int byteThresholdActive: cfg.byteThresholdActive ?? defaults.byteThresholdActive
    property real fontSizeModifier: cfg.fontSizeModifier ?? defaults.fontSizeModifier
    property real iconSizeModifier: cfg.iconSizeModifier ?? defaults.iconSizeModifier
    property real spacingInbetween: cfg.spacingInbetween ?? defaults.spacingInbetween
    property real contentMargin: cfg.contentMargin ?? defaults.contentMargin ?? Style.marginS

    property bool useCustomFont: cfg.useCustomFont ?? defaults.useCustomFont
    property string customFontFamily: cfg.customFontFamily ?? defaults.customFontFamily
    property bool customFontBold: cfg.customFontBold ?? defaults.customFontBold
    property bool customFontItalic: cfg.customFontItalic ?? defaults.customFontItalic

    property bool horizontalNumbers: cfg.horizontalLayout ?? defaults.horizontalLayout

    readonly property string resolvedFontFamily: {
        if (root.useCustomFont && root.customFontFamily)
            return root.customFontFamily;
        return Settings.data.ui.fontDefault;
    }

    readonly property int resolvedFontWeight: {
        if (root.useCustomFont && root.customFontBold)
            return Font.Bold;
        return Style.fontWeightMedium;
    }

    readonly property bool resolvedFontItalic: root.useCustomFont && root.customFontItalic

    readonly property bool numbersVisible: root.showNumbers && barIsSpacious && !barIsVertical

    property string barPosition: Settings.data.bar.position || "top"
    property string barDensity: Settings.data.bar.density || "compact"
    property bool barIsSpacious: barDensity != "mini"
    property bool barIsVertical: barPosition === "left" || barPosition === "right"

    readonly property real contentWidth: barIsVertical ? Style.capsuleHeight : contentRow.implicitWidth + root.contentMargin * 2
    readonly property real contentHeight: barIsVertical ? Math.round(contentRow.implicitHeight + Style.marginM * 2) : Style.capsuleHeight

    implicitWidth: contentWidth
    implicitHeight: contentHeight

    // ── Widget ──

    property string txSpeed: (SystemStatService.formatSpeed(SystemStatService.txSpeed).replace(/([0-9.]+)([A-Za-z]+)/, "$1 $2") + "/s").padStart(8, " ")
    property string rxSpeed: (SystemStatService.formatSpeed(SystemStatService.rxSpeed).replace(/([0-9.]+)([A-Za-z]+)/, "$1 $2") + "/s").padStart(8, " ")

    Rectangle {
        id: visualCapsule
        x: Style.pixelAlignCenter(parent.width, width)
        y: Style.pixelAlignCenter(parent.height, height)
        width: root.contentWidth
        height: root.contentHeight
        color: Style.capsuleColor
        radius: Style.radiusM
        border.color: Style.capsuleBorderColor
        border.width: Style.capsuleBorderWidth

        RowLayout {
            id: contentRow
            anchors.centerIn: parent
            spacing: Style.marginS

            // Vertical layout: stacked values to the left
            Column {
                visible: root.numbersVisible && !root.horizontalNumbers
                spacing: root.spacingInbetween

                NText {
                    horizontalAlignment: Text.AlignRight
                    text: root.txSpeed
                    color: root.colorText
                    pointSize: Style.barFontSize * root.fontSizeModifier
                    font.family: root.resolvedFontFamily
                    font.weight: root.resolvedFontWeight
                    font.italic: root.resolvedFontItalic
                }

                NText {
                    horizontalAlignment: Text.AlignRight
                    text: root.rxSpeed
                    color: root.colorText
                    pointSize: Style.barFontSize * root.fontSizeModifier
                    font.family: root.resolvedFontFamily
                    font.weight: root.resolvedFontWeight
                    font.italic: root.resolvedFontItalic
                }
            }

            // Horizontal layout: TX value left
            NText {
                visible: root.numbersVisible && root.horizontalNumbers
                horizontalAlignment: Text.AlignRight
                text: root.rxSpeed
                color: root.colorText
                pointSize: Style.barFontSize * root.fontSizeModifier
                font.family: root.resolvedFontFamily
                font.weight: root.resolvedFontWeight
                font.italic: root.resolvedFontItalic
            }

            // Icons
            Column {
                spacing: -10.0 + root.spacingInbetween

                NIcon {
                    icon: arrowType + "-up"
                    color: SystemStatService.txSpeed >= root.byteThresholdActive ? root.colorTx : root.colorSilent
                    pointSize: Style.fontSizeL * root.iconSizeModifier
                }

                NIcon {
                    icon: arrowType + "-down"
                    color: SystemStatService.rxSpeed >= root.byteThresholdActive ? root.colorRx : root.colorSilent
                    pointSize: Style.fontSizeL * root.iconSizeModifier
                }
            }

            // Horizontal layout: RX value right
            NText {
                visible: root.numbersVisible && root.horizontalNumbers
                horizontalAlignment: Text.AlignLeft
                text: root.txSpeed
                color: root.colorText
                pointSize: Style.barFontSize * root.fontSizeModifier
                font.family: root.resolvedFontFamily
                font.weight: root.resolvedFontWeight
                font.italic: root.resolvedFontItalic
            }
        }
    }

    // ── Interaction ──

    HoverHandler {
        id: hoverHandler
        onHoveredChanged: {
            if (hovered) {
                closeTimer.stop();
                hoverTimer.start();
            } else {
                hoverTimer.stop();
                closeTimer.start();
            }
        }
    }

    Timer {
        id: hoverTimer
        interval: 500
        onTriggered: {
            if (hoverHandler.hovered && root.pluginApi && !pluginApi.panelOpenScreen)
                pluginApi.openPanel(root.screen, root);
        }
    }

    Timer {
        id: closeTimer
        interval: 250
        onTriggered: {
            if (!hoverHandler.hovered && root.pluginApi && pluginApi.panelOpenScreen)
                pluginApi.togglePanel(root.screen, root);
        }
    }

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton

        onPressed: mouse => {
            if (mouse.button == Qt.RightButton)
                PanelService.showContextMenu(contextMenu, root, screen);
        }

        NPopupContextMenu {
            id: contextMenu

            model: [
                {
                    "label": root.pluginApi?.tr("actions.widget-settings"),
                    "action": "widget-settings",
                    "icon": "settings"
                },
            ]

            onTriggered: action => {
                contextMenu.close();
                PanelService.closeContextMenu(screen);

                if (action === "widget-settings") {
                    BarService.openPluginSettings(screen, pluginApi.manifest);
                }
            }
        }
    }
}
