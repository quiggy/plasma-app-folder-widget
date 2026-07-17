import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as P5Support

PlasmoidItem {
    id: root

    property var apps: []
    readonly property bool translucentPopup: plasmoid.configuration.translucentBackground

    Component.onCompleted: {
        loadApps()
    }

    function loadApps() {
        try {
            apps = JSON.parse(plasmoid.configuration.appList)
        } catch(e) {
            apps = [
                { name: "Dolphin", icon: "system-file-manager", cmd: "dolphin" },
                { name: "Konsole", icon: "utilities-terminal", cmd: "konsole" },
                { name: "Firefox", icon: "firefox", cmd: "firefox" }
            ]
        }
    }

    Connections {
        target: plasmoid.configuration
        function onAppListChanged() {
            root.loadApps()
        }
    }

    preferredRepresentation: compactRepresentation

    // Never shown (we open our own dialog), but the shell needs one to exist
    fullRepresentation: Item {}

    // Plain icon filling the whole panel cell, so it matches the size
    // of the other panel icons (a ToolButton adds padding that shrinks it)
    compactRepresentation: MouseArea {
        hoverEnabled: true
        onClicked: {
            if (popupDialog.visible) {
                popupDialog.visible = false
            } else if (Date.now() - popupDialog.lastHidden > 200) {
                // The dialog may auto-hide on deactivate right before this
                // click lands — don't instantly reopen it in that case
                popupDialog.visible = true
            }
        }

        Kirigami.Icon {
            anchors.fill: parent
            source: plasmoid.configuration.folderIcon
            active: parent.containsMouse
            opacity: popupDialog.visible ? 0 : 1
            Behavior on opacity {
                NumberAnimation { duration: Kirigami.Units.shortDuration }
            }
        }

        // While the folder is open, macOS swaps the dock icon for a grey
        // rounded square with a down arrow — mirror that
        Rectangle {
            id: openBadge
            anchors.fill: parent
            anchors.margins: Math.round(parent.width * 0.08)
            radius: width * 0.24
            gradient: Gradient {
                GradientStop { position: 0.0; color: Qt.rgba(0.82, 0.82, 0.85, 0.75) }
                GradientStop { position: 1.0; color: Qt.rgba(0.58, 0.58, 0.62, 0.75) }
            }
            border.width: 1
            border.color: Qt.rgba(1, 1, 1, 0.25)
            opacity: popupDialog.visible ? 1 : 0
            visible: opacity > 0
            Behavior on opacity {
                NumberAnimation { duration: Kirigami.Units.shortDuration }
            }

            // Liquid-glass reflection: the outline lights up softly towards
            // the bottom-right corner
            Canvas {
                anchors.fill: parent
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                onPaint: {
                    const ctx = getContext("2d")
                    ctx.reset()
                    const grad = ctx.createLinearGradient(0, 0, width, height)
                    grad.addColorStop(0.5, "rgba(255, 255, 255, 0)")
                    grad.addColorStop(0.85, "rgba(255, 255, 255, 0.35)")
                    grad.addColorStop(1.0, "rgba(255, 255, 255, 0.75)")
                    ctx.strokeStyle = grad
                    ctx.lineWidth = 1.5
                    ctx.beginPath()
                    ctx.roundedRect(0.75, 0.75, width - 1.5, height - 1.5,
                                    openBadge.radius, openBadge.radius)
                    ctx.stroke()
                }
            }

            Kirigami.Icon {
                anchors.centerIn: parent
                anchors.verticalCenterOffset: Math.round(parent.height * 0.08)
                width: Math.round(parent.width * 0.62)
                height: width
                source: "go-down-symbolic"
                color: Qt.rgba(0.13, 0.13, 0.15, 1)
            }
        }
    }

    // Own popup window instead of the shell's AppletPopup: the shell popup
    // always paints the themed dialog frame and registers a full-size blur
    // region with KWin, which a plasmoid cannot opt out of. PlasmaCore.Dialog
    // with NoBackground genuinely drops frame, mask, shadow and blur region.
    PlasmaCore.Dialog {
        id: popupDialog

        property double lastHidden: 0

        location: plasmoid.location
        visualParent: root.compactRepresentationItem
        hideOnWindowDeactivate: true
        type: PlasmaCore.Dialog.PopupMenu
        flags: Qt.WindowStaysOnTopHint
        backgroundHints: root.translucentPopup ? PlasmaCore.Dialog.NoBackground
                                               : PlasmaCore.Dialog.StandardBackground

        onVisibleChanged: {
            if (!visible) {
                lastHidden = Date.now()
            }
        }

        mainItem: Item {
            id: fullRep

            readonly property int appIconSize: plasmoid.configuration.iconSize
            readonly property int cellWidth: appIconSize + Kirigami.Units.gridUnit * 3
            readonly property int cellHeight: appIconSize + Kirigami.Units.gridUnit * 2
            readonly property int gridColumns: Math.max(1, Math.min(root.apps.length, plasmoid.configuration.maxColumns))
            readonly property int gridRows: Math.max(1, Math.ceil(root.apps.length / gridColumns))
            readonly property int padding: Kirigami.Units.largeSpacing

            // Cap the popup at ~75% of the screen height like a macOS folder;
            // anything beyond that scrolls
            readonly property int screenHeight: Screen.height > 0 ? Screen.height : 1440
            readonly property int chromeHeight: header.implicitHeight + Kirigami.Units.smallSpacing * 2 + 1 + padding * 2
            readonly property int gridHeight: Math.min(gridRows * cellHeight,
                Math.max(cellHeight, Math.floor(screenHeight * 0.75) - chromeHeight))

            // Apple-like gap between the popup body and the panel, baked into
            // the window as transparent space on the panel side
            readonly property int panelGap: root.translucentPopup ? 16 : 0
            readonly property int gapLeft: plasmoid.location === PlasmaCore.Types.LeftEdge ? panelGap : 0
            readonly property int gapRight: plasmoid.location === PlasmaCore.Types.RightEdge ? panelGap : 0
            readonly property int gapTop: plasmoid.location === PlasmaCore.Types.TopEdge ? panelGap : 0
            readonly property int gapBottom: (gapLeft || gapRight || gapTop) ? 0 : panelGap

            width: gridColumns * cellWidth + padding * 2 + gapLeft + gapRight
            height: chromeHeight + gridHeight + gapTop + gapBottom

            // Glassy tinted panel: subtle vertical sheen and a light top edge
            Rectangle {
                id: bgRect
                visible: root.translucentPopup
                anchors.fill: parent
                anchors.leftMargin: fullRep.gapLeft
                anchors.rightMargin: fullRep.gapRight
                anchors.topMargin: fullRep.gapTop
                anchors.bottomMargin: fullRep.gapBottom
                radius: Kirigami.Units.gridUnit

                readonly property real bgAlpha: plasmoid.configuration.backgroundOpacity / 100
                function glass(lift, a) {
                    const c = Kirigami.Theme.backgroundColor
                    return Qt.rgba(c.r * (1 - lift) + lift,
                                   c.g * (1 - lift) + lift,
                                   c.b * (1 - lift) + lift, a)
                }

                gradient: Gradient {
                    GradientStop { position: 0.0; color: bgRect.glass(0.10, Math.min(1, bgRect.bgAlpha + 0.05)) }
                    GradientStop { position: 0.35; color: bgRect.glass(0.03, bgRect.bgAlpha) }
                    GradientStop { position: 1.0; color: bgRect.glass(0.0, bgRect.bgAlpha) }
                }
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.18)
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: fullRep.padding + fullRep.gapLeft
                anchors.rightMargin: fullRep.padding + fullRep.gapRight
                anchors.topMargin: fullRep.padding + fullRep.gapTop
                anchors.bottomMargin: fullRep.padding + fullRep.gapBottom
                spacing: 0

                // Folder title centered on top, like an Apple folder
                RowLayout {
                    id: header
                    Layout.fillWidth: true
                    spacing: 0

                    Item { Layout.preferredWidth: configButton.implicitWidth }

                    PlasmaComponents.Label {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: plasmoid.configuration.folderName
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 1.15
                        font.bold: true
                        elide: Text.ElideRight
                    }

                    PlasmaComponents.ToolButton {
                        id: configButton
                        icon.name: "configure"
                        opacity: 0.6
                        onClicked: {
                            popupDialog.visible = false
                            plasmoid.internalAction("configure").trigger()
                        }
                        PlasmaComponents.ToolTip {
                            text: "Configure folder"
                        }
                    }
                }

                // Hairline below the header that only shows while the grid is
                // scrolled away from the top, like the macOS folder header
                Kirigami.Separator {
                    Layout.fillWidth: true
                    Layout.topMargin: Kirigami.Units.smallSpacing
                    opacity: gridView.atYBeginning ? 0 : 1
                    Behavior on opacity {
                        NumberAnimation { duration: Kirigami.Units.shortDuration }
                    }
                }

                PlasmaComponents.ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.topMargin: Kirigami.Units.smallSpacing

                    GridView {
                        id: gridView
                        clip: true
                        interactive: fullRep.gridRows * fullRep.cellHeight > fullRep.gridHeight
                        cellWidth: fullRep.cellWidth
                        cellHeight: fullRep.cellHeight
                        model: root.apps

                        delegate: Item {
                            width: gridView.cellWidth
                            height: gridView.cellHeight

                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: Kirigami.Units.smallSpacing / 2
                                radius: Kirigami.Units.smallSpacing * 2
                                color: Kirigami.Theme.highlightColor
                                opacity: mouseArea.pressed ? 0.4 : mouseArea.containsMouse ? 0.25 : 0
                                Behavior on opacity {
                                    NumberAnimation { duration: Kirigami.Units.shortDuration }
                                }
                            }

                            ColumnLayout {
                                anchors.fill: parent
                                anchors.margins: Kirigami.Units.smallSpacing
                                spacing: Kirigami.Units.smallSpacing

                                Kirigami.Icon {
                                    Layout.alignment: Qt.AlignHCenter
                                    Layout.preferredWidth: fullRep.appIconSize
                                    Layout.preferredHeight: fullRep.appIconSize
                                    source: modelData.icon
                                }

                                PlasmaComponents.Label {
                                    Layout.fillWidth: true
                                    horizontalAlignment: Text.AlignHCenter
                                    text: modelData.name
                                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                }
                            }

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    executable.exec(modelData.cmd)
                                    popupDialog.visible = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    P5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: function(sourceName, data) {
            disconnectSource(sourceName)
        }

        function exec(cmd) {
            connectSource(cmd)
        }
    }
}
