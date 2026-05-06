import qs.Commons
import qs.Modules.MainScreen
import qs.Services.UI
import qs.Services.System
import qs.Widgets
import QtQuick
import QtQuick.Layouts

Item {
    id: root

    readonly property var geometryPlaceholder: panelContent
    readonly property bool allowAttach: true

    property var pluginApi: null
    property var cfg: pluginApi?.pluginSettings || ({})
    property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})
    property string arrowType: cfg.arrowType ?? defaults.arrowType

    property real contentPreferredWidth: 440 * Style.uiScaleRatio
    property real contentPreferredHeight: panelContent.implicitHeight + Style.marginL * 2

    anchors.fill: parent

    Component.onCompleted: {
        if (pluginApi) {
            Logger.i("NetworkIndicator", "Panel initialized");
        }
    }

    ColumnLayout {
        id: panelContent

        anchors.fill: parent
        anchors.margins: Style.marginL

        NBox {
            Layout.fillWidth: true
            Layout.preferredHeight: 90 * Style.uiScaleRatio

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: Style.marginS
                anchors.bottomMargin: Style.radiusM * 0.5
                spacing: Style.marginXS

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Style.marginXS

                    NIcon {
                        icon: arrowType + "-down"
                        pointSize: Style.fontSizeXS
                        color: Color.mPrimary
                    }

                    NText {
                        text: (SystemStatService.formatSpeed(SystemStatService.rxSpeed).replace(/([0-9.]+)([A-Za-z]+)/, "$1 $2") + "/s").padStart(8, " ")
                        pointSize: Style.fontSizeXS
                        color: Color.mPrimary
                        font.family: Settings.data.ui.fontFixed
                        Layout.rightMargin: Style.marginS
                    }

                    NIcon {
                        icon: arrowType + "-up"
                        pointSize: Style.fontSizeXS
                        color: Color.mSecondary
                    }

                    NText {
                        text: (SystemStatService.formatSpeed(SystemStatService.txSpeed).replace(/([0-9.]+)([A-Za-z]+)/, "$1 $2") + "/s").padStart(8, " ")
                        pointSize: Style.fontSizeXS
                        color: Color.mSecondary
                        font.family: Settings.data.ui.fontFixed
                    }

                    Item {
                        Layout.fillWidth: true
                    }
                }

                NGraph {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    values: SystemStatService.rxSpeedHistory
                    values2: SystemStatService.txSpeedHistory
                    minValue: 0
                    maxValue: SystemStatService.rxMaxSpeed
                    minValue2: 0
                    maxValue2: SystemStatService.txMaxSpeed
                    color: Color.mPrimary
                    color2: Color.mSecondary
                    strokeWidth: Math.max(1, Style.uiScaleRatio)
                    fill: true
                    fillOpacity: 0.15
                    updateInterval: SystemStatService.networkIntervalMs
                    animateScale: true
                }
            }
        }
    }
}
