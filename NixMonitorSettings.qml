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

    StyledText {
        width: parent.width
        text: "NixOS Update Checking"
        font.pixelSize: Theme.fontSizeMedium
        font.weight: Font.Bold
        color: Theme.surfaceText
        topPadding: Theme.spacingM
    }

    ToggleSetting {
        settingKey: "checkUpdates"
        label: "Check for Updates"
        description: "Monitor nixpkgs for available updates"
        defaultValue: true
    }

    SelectionSetting {
        settingKey: "nixpkgsChannel"
        label: "NixOS Channel"
        description: "Which channel to check for updates"
        defaultValue: "nixos-unstable"
        options: [
            { value: "nixos-unstable", label: "nixos-unstable" },
            { value: "nixos-25.11", label: "nixos-25.11" },
            { value: "nixos-25.05", label: "nixos-25.05" },
            { value: "nixos-24.11", label: "nixos-24.11" }
        ]
    }

    SliderSetting {
        settingKey: "updateCheckInterval"
        label: "Update Check Interval"
        description: "How often to check for nixpkgs updates"
        defaultValue: 3600
        minimum: 300
        maximum: 86400
        unit: "sec"
    }
}
