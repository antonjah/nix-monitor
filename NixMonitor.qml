import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    property int updateInterval: 300
    property bool showGenerations: pluginData.showGenerations !== undefined ? pluginData.showGenerations : true
    property bool showStoreSize: pluginData.showStoreSize !== undefined ? pluginData.showStoreSize : true
    property int gcThresholdGB: pluginData.gcThresholdGB || 50

    property int generationCount: 0
    property string storeSize: "..."
    property real storeSizeGB: 0
    property bool isLoading: true
    property string lastUpdate: ""
    property bool operationRunning: false
    property string consoleOutput: ""
    property bool showConsole: false
    property string runningOperation: ""

    property var config: null
    property var generationsCommand: ["sh", "-c", "echo 0"]
    property var storeSizeCommand: ["sh", "-c", "echo ..."]
    property var rebuildCommand: ["sh", "-c", "echo 'No rebuild command configured'"]
    property var gcCommand: ["sh", "-c", "echo 'No GC command configured'"]

    property string configJsonContent: ""

    Process {
        id: configLoader
        command: ["cat", Quickshell.env("HOME") + "/.config/DankMaterialShell/plugins/NixMonitor/config.json"]
        running: false

        stdout: SplitParser {
            onRead: function(line) {
                root.configJsonContent += line
            }
        }

        onExited: function(exitCode, exitStatus) {
            if (exitCode === 0 && root.configJsonContent) {
                try {
                    var configData = JSON.parse(root.configJsonContent)
                    if (configData.generationsCommand) {
                        root.generationsCommand = configData.generationsCommand
                    }
                    if (configData.storeSizeCommand) {
                        root.storeSizeCommand = configData.storeSizeCommand
                    }
                    if (configData.rebuildCommand) {
                        root.rebuildCommand = configData.rebuildCommand
                    }
                    if (configData.gcCommand) {
                        root.gcCommand = configData.gcCommand
                    }
                    if (configData.updateInterval) {
                        root.updateInterval = configData.updateInterval
                        updateTimer.interval = configData.updateInterval * 1000
                    }
                    console.info("Loaded custom config:", JSON.stringify(configData))
                } catch (e) {
                    console.warn("Failed to parse config.json:", e)
                }
            } else if (exitCode !== 0) {
                console.warn("Failed to load config.json, using defaults")
            }
            root.refreshData()
        }
    }

    Component.onCompleted: {
        console.info("Nix Monitor plugin loaded")
        configLoader.running = true
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingXS

            DankIcon {
                name: "inventory_2"
                size: root.iconSize
                color: root.storeSizeGB > root.gcThresholdGB ? Theme.error : Theme.primary
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: root.isLoading ? "..." : root.generationCount.toString()
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Medium
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
                visible: root.showGenerations
            }

            StyledText {
                text: "gen"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
                anchors.verticalCenter: parent.verticalCenter
                visible: root.showGenerations
            }

            Rectangle {
                width: 1
                height: Theme.iconSize
                color: Theme.outlineVariant
                anchors.verticalCenter: parent.verticalCenter
                visible: root.showGenerations && root.showStoreSize
            }

            StyledText {
                text: root.storeSize
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Medium
                color: root.storeSizeGB > root.gcThresholdGB ? Theme.error : Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
                visible: root.showStoreSize
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: Theme.spacingXS

            DankIcon {
                name: "inventory_2"
                size: root.iconSize
                color: root.storeSizeGB > root.gcThresholdGB ? Theme.error : Theme.primary
                anchors.horizontalCenter: parent.horizontalCenter
            }

            StyledText {
                text: root.isLoading ? "..." : root.generationCount.toString()
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceText
                anchors.horizontalCenter: parent.horizontalCenter
                visible: root.showGenerations
            }

            StyledText {
                text: root.storeSize
                font.pixelSize: Theme.fontSizeSmall
                color: root.storeSizeGB > root.gcThresholdGB ? Theme.error : Theme.surfaceText
                anchors.horizontalCenter: parent.horizontalCenter
                visible: root.showStoreSize
            }
        }
    }

    popoutContent: Component {
        PopoutComponent {
            id: popout
            headerText: "Nix Store Monitor"
            detailsText: root.lastUpdate ? "Updated: " + root.lastUpdate : "Loading..."
            showCloseButton: true

            Item {
                width: parent.width
                implicitHeight: mainColumn.implicitHeight + Theme.spacingL

                Column {
                    id: mainColumn
                    width: parent.width
                    spacing: Theme.spacingM

                    Row {
                        width: parent.width
                        spacing: Theme.spacingM

                        StyledRect {
                            width: (parent.width - Theme.spacingM) / 2
                            height: 100
                            radius: Theme.cornerRadius
                            color: Theme.surfaceContainerHigh

                            Column {
                                anchors.centerIn: parent
                                spacing: Theme.spacingXS

                                DankIcon {
                                    name: "history"
                                    size: 32
                                    color: Theme.primary
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                StyledText {
                                    text: root.generationCount.toString()
                                    font.pixelSize: Theme.fontSizeXLarge
                                    font.weight: Font.Bold
                                    color: Theme.surfaceText
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                StyledText {
                                    text: "Generations"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }

                        StyledRect {
                            width: (parent.width - Theme.spacingM) / 2
                            height: 100
                            radius: Theme.cornerRadius
                            color: Theme.surfaceContainerHigh

                            Column {
                                anchors.centerIn: parent
                                spacing: Theme.spacingXS

                                DankIcon {
                                    name: "storage"
                                    size: 32
                                    color: root.storeSizeGB > root.gcThresholdGB ? Theme.error : Theme.primary
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                StyledText {
                                    text: root.storeSize
                                    font.pixelSize: Theme.fontSizeXLarge
                                    font.weight: Font.Bold
                                    color: root.storeSizeGB > root.gcThresholdGB ? Theme.error : Theme.surfaceText
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                StyledText {
                                    text: "Store Size"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }
                    }

                    StyledRect {
                        width: parent.width
                        height: warningContent.implicitHeight + Theme.spacingM * 2
                        radius: Theme.cornerRadius
                        color: Theme.errorContainer
                        visible: root.storeSizeGB > root.gcThresholdGB

                        Row {
                            id: warningContent
                            width: parent.width - Theme.spacingM * 2
                            anchors.centerIn: parent
                            spacing: Theme.spacingS

                            DankIcon {
                                name: "warning"
                                size: Theme.iconSize
                                color: Theme.onErrorContainer
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            StyledText {
                                text: "Store size exceeds " + root.gcThresholdGB + " GB threshold"
                                font.pixelSize: Theme.fontSizeMedium
                                color: Theme.onErrorContainer
                                wrapMode: Text.WordWrap
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS

                        StyledText {
                            text: "Actions"
                            font.pixelSize: Theme.fontSizeMedium
                            font.weight: Font.Bold
                            color: Theme.surfaceText
                        }

                        Column {
                            width: parent.width
                            spacing: Theme.spacingS

                            Row {
                                width: parent.width
                                spacing: Theme.spacingS

                                DankButton {
                                    width: (parent.width - Theme.spacingS * 2) / 3
                                    text: "Refresh"
                                    iconName: "refresh"
                                    enabled: !root.isLoading && !root.operationRunning
                                    onClicked: {
                                        root.refreshData()
                                    }
                                }

                                DankButton {
                                    width: (parent.width - Theme.spacingS * 2) / 3
                                    text: root.operationRunning && root.runningOperation === "rebuild" ? "Building..." : "Rebuild"
                                    iconName: "build"
                                    backgroundColor: Theme.secondary
                                    textColor: Theme.onSecondary
                                    enabled: !root.operationRunning
                                    onClicked: {
                                        root.rebuildSystem()
                                    }
                                }

                                DankButton {
                                    width: (parent.width - Theme.spacingS * 2) / 3
                                    text: root.operationRunning && root.runningOperation === "gc" ? "Running..." : "GC"
                                    iconName: "cleaning_services"
                                    backgroundColor: Theme.error
                                    textColor: Theme.onError
                                    enabled: !root.operationRunning
                                    onClicked: {
                                        root.runGarbageCollect()
                                    }
                                }
                            }


                        }
                    }

                    Column {
                        width: parent.width
                        spacing: Theme.spacingS
                        visible: root.showConsole

                        StyledText {
                            text: "Console Output"
                            font.pixelSize: Theme.fontSizeMedium
                            font.weight: Font.Bold
                            color: Theme.surfaceText
                        }

                        StyledRect {
                            width: parent.width
                            height: 200
                            radius: Theme.cornerRadius
                            color: Theme.surfaceContainerLow

                            Flickable {
                                anchors.fill: parent
                                anchors.margins: Theme.spacingS
                                contentHeight: outputText.implicitHeight
                                clip: true

                                StyledText {
                                    id: outputText
                                    width: parent.width
                                    text: root.consoleOutput || "Waiting for output..."
                                    font.pixelSize: Theme.fontSizeSmall
                                    font.family: "monospace"
                                    color: Theme.surfaceText
                                    wrapMode: Text.Wrap
                                }

                                onContentHeightChanged: {
                                    if (contentHeight > height) {
                                        contentY = contentHeight - height
                                    }
                                }
                            }
                        }

                        Row {
                            width: parent.width
                            spacing: Theme.spacingS

                            Item {
                                width: parent.width - clearButton.width - cancelButton.width - Theme.spacingS * 2
                                height: 1
                            }

                            DankButton {
                                id: cancelButton
                                text: "Cancel"
                                iconName: "cancel"
                                buttonHeight: 30
                                backgroundColor: Theme.error
                                textColor: Theme.onError
                                visible: root.operationRunning
                                onClicked: {
                                    root.cancelOperation()
                                }
                            }

                            DankButton {
                                id: clearButton
                                text: "Clear"
                                iconName: "close"
                                buttonHeight: 30
                                enabled: !root.operationRunning
                                onClicked: {
                                    root.showConsole = false
                                    root.consoleOutput = ""
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    popoutWidth: 450
    popoutHeight: 500

    Timer {
        id: updateTimer
        interval: root.updateInterval * 1000
        running: true
        repeat: true
        onTriggered: root.refreshData()
    }

    Process {
        id: generationCountProcess
        command: root.generationsCommand
        running: false

        stdout: SplitParser {
            onRead: function(line) {
                var count = parseInt(line.trim())
                if (!isNaN(count)) {
                    root.generationCount = count
                }
            }
        }

        onExited: function(exitCode, exitStatus) {
            root.isLoading = false
        }
    }

    Process {
        id: storeSizeProcess
        command: root.storeSizeCommand
        running: false

        stdout: SplitParser {
            onRead: function(line) {
                var output = line.trim()
                if (output) {
                    root.storeSize = output
                    var match = output.match(/([0-9.]+)G/)
                    if (match) {
                        root.storeSizeGB = parseFloat(match[1])
                    }
                }
            }
        }

        onExited: function(exitCode, exitStatus) {
            root.isLoading = false
            var now = new Date()
            root.lastUpdate = Qt.formatTime(now, "HH:mm:ss")
        }
    }

    Process {
        id: rebuildProcess
        command: root.rebuildCommand
        running: false

        stdout: SplitParser {
            onRead: function(line) {
                root.consoleOutput += line + "\n"
            }
        }

        stderr: SplitParser {
            onRead: function(line) {
                root.consoleOutput += line + "\n"
            }
        }

        onExited: function(exitCode, exitStatus) {
            root.operationRunning = false
            root.runningOperation = ""
            if (exitCode === 0) {
                root.consoleOutput += "\n✓ System rebuilt successfully\n"
                ToastService.showInfo("System rebuilt successfully")
                root.refreshData()
            } else if (exitCode === 143 || exitCode === 130) {
                root.consoleOutput += "\n✗ Rebuild cancelled by user\n"
                ToastService.showInfo("Rebuild cancelled")
            } else {
                root.consoleOutput += "\n✗ Rebuild failed (exit code: " + exitCode + ")\n"
                ToastService.showError("Rebuild failed")
            }
        }
    }

    Process {
        id: garbageCollectProcess
        command: root.gcCommand
        running: false

        stdout: SplitParser {
            onRead: function(line) {
                root.consoleOutput += line + "\n"
            }
        }

        stderr: SplitParser {
            onRead: function(line) {
                root.consoleOutput += line + "\n"
            }
        }

        onExited: function(exitCode, exitStatus) {
            root.operationRunning = false
            root.runningOperation = ""
            if (exitCode === 0) {
                root.consoleOutput += "\n✓ Garbage collection completed\n"
                ToastService.showInfo("Garbage collection completed")
                root.refreshData()
            } else if (exitCode === 143 || exitCode === 130) {
                root.consoleOutput += "\n✗ GC cancelled by user\n"
                ToastService.showInfo("GC cancelled")
            } else {
                root.consoleOutput += "\n✗ GC failed (exit code: " + exitCode + ")\n"
                ToastService.showError("GC failed")
            }
        }
    }



    function refreshData() {
        root.isLoading = true
        generationCountProcess.running = true
        storeSizeProcess.running = true
    }

    function rebuildSystem() {
        root.operationRunning = true
        root.runningOperation = "rebuild"
        root.showConsole = true
        root.consoleOutput = "Starting system rebuild...\n"
        ToastService.showInfo("Starting system rebuild...")
        rebuildProcess.running = true
    }

    function runGarbageCollect() {
        root.operationRunning = true
        root.runningOperation = "gc"
        root.showConsole = true
        root.consoleOutput = "Starting garbage collection...\n"
        ToastService.showInfo("Starting garbage collection...")
        garbageCollectProcess.running = true
    }

    function cancelOperation() {
        if (root.runningOperation === "rebuild" && rebuildProcess.running) {
            rebuildProcess.running = false
            root.consoleOutput += "\n✗ Cancelling rebuild...\n"
        } else if (root.runningOperation === "gc" && garbageCollectProcess.running) {
            garbageCollectProcess.running = false
            root.consoleOutput += "\n✗ Cancelling garbage collection...\n"
        }
        ToastService.showInfo("Cancelling operation...")
    }
}
