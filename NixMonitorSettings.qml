import QtQuick
import qs.Common
import qs.Modules.Plugins
import qs.Widgets

PluginSettings {
    id: root
    pluginId: "nixMonitor"

    StyledText {
        width: parent.width
        text: "Nix Monitor Settings"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StyledText {
        width: parent.width
        text: "Configure monitoring and cleanup options for your Nix store and home-manager generations"
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
    }

    StyledText {
        width: parent.width
        text: "Display Options"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.Bold
        color: Theme.surfaceText
        topPadding: Theme.spacingM
    }

    ToggleSetting {
        settingKey: "showGenerations"
        label: "Show Generation Count"
        description: "Display the number of home-manager generations in the bar"
        defaultValue: true
    }

    ToggleSetting {
        settingKey: "showStoreSize"
        label: "Show Store Size"
        description: "Display the Nix store disk usage in the bar"
        defaultValue: true
    }

    StyledText {
        width: parent.width
        text: "Update Settings"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.Bold
        color: Theme.surfaceText
        topPadding: Theme.spacingM
    }

    SliderSetting {
        settingKey: "updateInterval"
        label: "Update Interval"
        description: "How often to refresh the statistics"
        defaultValue: 300
        minimum: 60
        maximum: 3600
        unit: "sec"
    }

    StyledText {
        width: parent.width
        text: "Cleanup Settings"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.Bold
        color: Theme.surfaceText
        topPadding: Theme.spacingM
    }

    SliderSetting {
        settingKey: "gcThresholdGB"
        label: "Warning Threshold"
        description: "Show warning when store size exceeds this value"
        defaultValue: 50
        minimum: 10
        maximum: 200
        unit: "GB"
    }
}
