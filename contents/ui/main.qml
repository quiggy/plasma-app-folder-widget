import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasma5support as P5Support

     PlasmoidItem {
         id: root

         property var apps: []

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

         compactRepresentation: PlasmaComponents.ToolButton {
             icon.name: plasmoid.configuration.folderIcon
             onClicked: root.expanded = !root.expanded
         }

         fullRepresentation: ColumnLayout {
             spacing: Kirigami.Units.smallSpacing
             Layout.margins: Kirigami.Units.smallSpacing

             GridLayout {
                 id: grid
                 columns: Math.min(root.apps.length, 3)
                 rowSpacing: Kirigami.Units.smallSpacing
                 columnSpacing: Kirigami.Units.smallSpacing

                 Repeater {
                     model: root.apps
                     delegate: PlasmaComponents.ToolButton {
                         icon.name: modelData.icon
                         text: modelData.name
                         display: PlasmaComponents.ToolButton.TextUnderIcon
                         Layout.preferredWidth: Kirigami.Units.gridUnit * 5
                         Layout.preferredHeight: Kirigami.Units.gridUnit * 5
                         onClicked: {
                             executable.exec(modelData.cmd)
                             root.expanded = false
                         }
                     }
                 }
             }

             RowLayout {
                 Layout.alignment: Qt.AlignHCenter
                 spacing: Kirigami.Units.smallSpacing
                 
                 PlasmaComponents.Label {
                     text: plasmoid.configuration.folderName
                     font.bold: true
                 }

                 PlasmaComponents.ToolButton {
                     icon.name: "configure"
                     implicitWidth: Kirigami.Units.iconSizes.smallMedium
                     implicitHeight: Kirigami.Units.iconSizes.smallMedium
                     onClicked: plasmoid.internalAction("configure").trigger()
                     PlasmaComponents.ToolTip {
                         text: "Configure folder"
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
