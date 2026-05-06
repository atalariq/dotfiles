import qs.Commons
import qs.Widgets
import qs.Services.System
import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root

    readonly property var iconNames: ["arrow", "arrow-bar", "arrow-big", "arrow-narrow", "caret", "chevron", "chevron-compact", "fold"]

    property var pluginApi: null

    property var cfg: pluginApi?.pluginSettings || ({})
    property var defaults: pluginApi?.manifest?.metadata?.defaultSettings || ({})

    property string editArrowType: cfg.arrowType ?? defaults.arrowType
    property int editByteThresholdActive: cfg.byteThresholdActive ?? defaults.byteThresholdActive
    property real editFontSizeModifier: cfg.fontSizeModifier ?? defaults.fontSizeModifier
    property bool editHorizontalLayout: cfg.horizontalLayout ?? defaults.horizontalLayout ?? false
    property real editIconSizeModifier: cfg.iconSizeModifier ?? defaults.iconSizeModifier
    property bool editShowNumbers: cfg.showNumbers ?? defaults.showNumbers
    property real editSpacingInbetween: cfg.spacingInbetween ?? defaults.spacingInbetween
    property real editContentMargin: cfg.contentMargin ?? defaults.contentMargin ?? Style.marginS

    property bool editUseCustomFont: cfg.useCustomFont ?? defaults.useCustomFont ?? false
    property string editCustomFontFamily: cfg.customFontFamily ?? defaults.customFontFamily ?? ""
    property bool editCustomFontBold: cfg.customFontBold ?? defaults.customFontBold ?? false
    property bool editCustomFontItalic: cfg.customFontItalic ?? defaults.customFontItalic ?? false

    property bool editUseCustomColors: cfg.useCustomColors ?? defaults.useCustomColors ?? false
    property color editColorBackground: editUseCustomColors && cfg.colorBackground || Style.capsuleColor
    property color editColorFont: editUseCustomColors && cfg.colorFont || Color.mOnSurface
    property color editColorRx: editUseCustomColors && cfg.colorRx || Color.mPrimary
    property color editColorSilent: editUseCustomColors && cfg.colorSilent || Color.mSurfaceVariant
    property color editColorText: editUseCustomColors && cfg.colorText || Qt.alpha(Color.mOnSurfaceVariant, 0.3)
    property color editColorTx: editUseCustomColors && cfg.colorTx || Color.mSecondary

    property string barPosition: Settings.data.bar.position || "top"
    property string barDensity: Settings.data.bar.density || "compact"
    property bool barIsSpacious: barDensity !== "mini"
    property bool barIsVertical: barPosition === "left" || barPosition === "right"

    function toIntOr(defaultValue, text) {
        const v = parseInt(String(text).trim(), 10);
        return isNaN(v) ? defaultValue : v;
    }

    function saveSettings() {
        if (!pluginApi || !pluginApi.pluginSettings) {
            Logger.e("NetworkIndicator", "Cannot save: pluginApi or pluginSettings is null");
            return;
        }

        pluginApi.pluginSettings.arrowType = root.editArrowType;
        pluginApi.pluginSettings.byteThresholdActive = root.editByteThresholdActive;
        pluginApi.pluginSettings.showNumbers = root.editShowNumbers;
        pluginApi.pluginSettings.horizontalLayout = root.editHorizontalLayout;
        pluginApi.pluginSettings.fontSizeModifier = root.editFontSizeModifier;
        pluginApi.pluginSettings.iconSizeModifier = root.editIconSizeModifier;
        pluginApi.pluginSettings.spacingInbetween = root.editSpacingInbetween;
        pluginApi.pluginSettings.contentMargin = root.editContentMargin;

        pluginApi.pluginSettings.useCustomFont = root.editUseCustomFont;
        pluginApi.pluginSettings.customFontFamily = root.editCustomFontFamily;
        pluginApi.pluginSettings.customFontBold = root.editCustomFontBold;
        pluginApi.pluginSettings.customFontItalic = root.editCustomFontItalic;

        pluginApi.pluginSettings.useCustomColors = root.editUseCustomColors;
        if (root.editUseCustomColors) {
            pluginApi.pluginSettings.colorSilent = root.editColorSilent.toString();
            pluginApi.pluginSettings.colorTx = root.editColorTx.toString();
            pluginApi.pluginSettings.colorRx = root.editColorRx.toString();
            pluginApi.pluginSettings.colorText = root.editColorText.toString();
            pluginApi.pluginSettings.colorFont = root.editColorFont.toString();
            pluginApi.pluginSettings.colorBackground = root.editColorBackground.toString();
        }

        pluginApi.saveSettings();
        Logger.i("NetworkIndicator", "Settings saved");
    }

    Layout.rightMargin: Style.marginL
    spacing: Style.marginL

    // ── Icon ──

    NComboBox {
        currentKey: root.editArrowType
        description: root.pluginApi?.tr("settings.iconType.desc")
        label: root.pluginApi?.tr("settings.iconType.label")
        model: root.iconNames.map(n => ({
                    key: n,
                    name: n
                }))

        onSelected: key => root.editArrowType = key
    }

    NDivider {
        Layout.fillWidth: true
    }

    // ── General ──

    NToggle {
        checked: root.editShowNumbers
        defaultValue: defaults.showNumbers ?? true
        description: root.pluginApi?.tr("settings.showNumbers.desc")
        label: root.pluginApi?.tr("settings.showNumbers.label")
        visible: root.barIsSpacious && !root.barIsVertical

        onToggled: c => root.editShowNumbers = c
    }

    NToggle {
        checked: root.editHorizontalLayout
        defaultValue: defaults.horizontalLayout ?? false
        description: root.pluginApi?.tr("settings.horizontalLayout.desc")
        label: root.pluginApi?.tr("settings.horizontalLayout.label")
        visible: root.barIsSpacious && !root.barIsVertical

        onToggled: c => root.editHorizontalLayout = c
    }

    NDivider {
        Layout.fillWidth: true
    }

    // ── Layout ──

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.marginXXS

        NLabel {
            description: root.pluginApi?.tr("settings.contentMargin.desc")
            label: root.pluginApi?.tr("settings.contentMargin.label")
        }

        NValueSlider {
            Layout.fillWidth: true
            from: 0
            stepSize: 1
            text: root.editContentMargin + "px"
            to: 20
            value: root.editContentMargin

            onMoved: value => root.editContentMargin = value
        }
    }

    NTextInput {
        label: pluginApi?.tr("settings.byteThresholdActive.label")
        description: pluginApi?.tr("settings.byteThresholdActive.desc")
        placeholderText: root.editByteThresholdActive + " bytes"
        text: String(root.editByteThresholdActive)
        onTextChanged: root.editByteThresholdActive = root.toIntOr(0, text)
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.marginXXS

        NLabel {
            description: root.pluginApi?.tr("settings.spacingInbetween.desc")
            label: root.pluginApi?.tr("settings.spacingInbetween.label")
        }

        NValueSlider {
            Layout.fillWidth: true
            from: -5
            stepSize: 1
            text: root.editSpacingInbetween.toFixed(0)
            to: 5
            value: root.editSpacingInbetween

            onMoved: value => root.editSpacingInbetween = value
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.marginXXS

        NLabel {
            description: root.pluginApi?.tr("settings.fontSizeModifier.desc")
            label: root.pluginApi?.tr("settings.fontSizeModifier.label")
        }

        NValueSlider {
            Layout.fillWidth: true
            from: 0.5
            stepSize: 0.05
            text: root.editFontSizeModifier.toFixed(2)
            to: 1.5
            value: root.editFontSizeModifier

            onMoved: value => root.editFontSizeModifier = value
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Style.marginXXS

        NLabel {
            description: root.pluginApi?.tr("settings.iconSizeModifier.desc")
            label: root.pluginApi?.tr("settings.iconSizeModifier.label")
        }

        NValueSlider {
            Layout.fillWidth: true
            from: 0.5
            stepSize: 0.05
            text: root.editIconSizeModifier.toFixed(2)
            to: 1.5
            value: root.editIconSizeModifier

            onMoved: value => root.editIconSizeModifier = value
        }
    }

    NDivider {
        Layout.fillWidth: true
    }

    // ── Font ──

    NToggle {
        checked: root.editUseCustomFont
        defaultValue: defaults.useCustomFont ?? false
        description: root.pluginApi?.tr("settings.useCustomFont.desc")
        label: root.pluginApi?.tr("settings.useCustomFont.label")

        onToggled: c => root.editUseCustomFont = c
    }

    ColumnLayout {
        visible: root.editUseCustomFont
        Layout.fillWidth: true
        spacing: Style.marginL

        NSearchableComboBox {
            label: root.pluginApi?.tr("settings.customFontFamily.label")
            description: root.pluginApi?.tr("settings.customFontFamily.desc")
            model: FontService.availableFonts
            currentKey: root.editCustomFontFamily || Qt.application.font.family
            placeholder: root.pluginApi?.tr("settings.customFontFamily.placeholder")
            searchPlaceholder: root.pluginApi?.tr("settings.customFontFamily.searchPlaceholder")
            popupHeight: 420

            onSelected: key => {
                root.editCustomFontFamily = (key === Qt.application.font.family) ? "" : key;
            }
        }

        NToggle {
            checked: root.editCustomFontBold
            defaultValue: defaults.customFontBold ?? false
            description: root.pluginApi?.tr("settings.customFontBold.desc")
            label: root.pluginApi?.tr("settings.customFontBold.label")

            onToggled: c => root.editCustomFontBold = c
        }

        NToggle {
            checked: root.editCustomFontItalic
            defaultValue: defaults.customFontItalic ?? false
            description: root.pluginApi?.tr("settings.customFontItalic.desc")
            label: root.pluginApi?.tr("settings.customFontItalic.label")

            onToggled: c => root.editCustomFontItalic = c
        }
    }

    NDivider {
        Layout.fillWidth: true
    }

    // ── Colors ──

    NToggle {
        checked: root.editUseCustomColors
        defaultValue: defaults.useCustomColors ?? false
        description: root.pluginApi?.tr("settings.useCustomColors.desc")
        label: root.pluginApi?.tr("settings.useCustomColors.label")

        onToggled: c => root.editUseCustomColors = c
    }

    ColumnLayout {
        visible: root.editUseCustomColors

        RowLayout {
            NLabel {
                Layout.alignment: Qt.AlignTop
                description: root.pluginApi?.tr("settings.colorTx.desc")
                label: root.pluginApi?.tr("settings.colorTx.label")
            }

            NColorPicker {
                selectedColor: root.editColorTx

                onColorSelected: color => root.editColorTx = color
            }
        }

        RowLayout {
            NLabel {
                Layout.alignment: Qt.AlignTop
                description: root.pluginApi?.tr("settings.colorRx.desc")
                label: root.pluginApi?.tr("settings.colorRx.label")
            }

            NColorPicker {
                selectedColor: root.editColorRx

                onColorSelected: color => root.editColorRx = color
            }
        }

        RowLayout {
            NLabel {
                Layout.alignment: Qt.AlignTop
                description: root.pluginApi?.tr("settings.colorSilent.desc")
                label: root.pluginApi?.tr("settings.colorSilent.label")
            }

            NColorPicker {
                selectedColor: root.editColorSilent

                onColorSelected: color => root.editColorSilent = color
            }
        }

        RowLayout {
            NLabel {
                Layout.alignment: Qt.AlignTop
                description: root.pluginApi?.tr("settings.colorText.desc")
                label: root.pluginApi?.tr("settings.colorText.label")
            }

            NColorPicker {
                selectedColor: root.editColorText

                onColorSelected: color => root.editColorText = color
            }
        }
    }
}
