import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import Qt.labs.folderlistmodel

KCM.SimpleKCM {
    property alias cfg_folderName: folderNameField.text
    property alias cfg_folderIcon: folderIconField.text
    property alias cfg_maxColumns: maxColumnsSpin.value
    property alias cfg_iconSize: iconSizeSpin.value
    property alias cfg_translucentBackground: translucentCheck.checked
    property alias cfg_backgroundOpacity: bgOpacitySpin.value
    property string cfg_appList
    property var selectedApps: []

    Component.onCompleted: {
        try {
            selectedApps = JSON.parse(cfg_appList)
        } catch(e) {
            selectedApps = []
        }
        updateAppList()
    }

    function updateAppList() {
        cfg_appList = JSON.stringify(selectedApps)
        appListModel.clear()
        for (var i = 0; i < selectedApps.length; i++) {
            appListModel.append(selectedApps[i])
        }
    }

    function addApp(name, icon, cmd) {
        selectedApps.push({name: name, icon: icon, cmd: cmd})
        updateAppList()
    }

    function removeApp(index) {
        selectedApps.splice(index, 1)
        updateAppList()
    }

    ListModel {
        id: appListModel
    }

    Kirigami.FormLayout {
        anchors.fill: parent

        QQC2.TextField {
            id: folderNameField
            Kirigami.FormData.label: "Folder Name:"
        }

        QQC2.TextField {
            id: folderIconField
            Kirigami.FormData.label: "Folder Icon:"
            placeholderText: "e.g., folder, applications-games"
        }

        QQC2.SpinBox {
            id: maxColumnsSpin
            Kirigami.FormData.label: "Max columns:"
            from: 1
            to: 20
        }

        QQC2.SpinBox {
            id: iconSizeSpin
            Kirigami.FormData.label: "Icon size:"
            from: 32
            to: 128
            stepSize: 16
        }

        QQC2.CheckBox {
            id: translucentCheck
            Kirigami.FormData.label: "Background:"
            text: "Translucent"
        }

        QQC2.SpinBox {
            id: bgOpacitySpin
            Kirigami.FormData.label: "Background opacity (%):"
            from: 0
            to: 100
            stepSize: 5
            enabled: translucentCheck.checked
        }

        RowLayout {
            Layout.fillWidth: true
            Kirigami.FormData.label: "Search Apps:"

            QQC2.TextField {
                id: searchField
                Layout.fillWidth: true
                placeholderText: "Type app name to search..."
                onTextChanged: {
                    searchTimer.restart()
                }
            }
        }

        Timer {
            id: searchTimer
            interval: 300
            repeat: false
            onTriggered: {
                searchResults.clear()
                if (searchField.text.length < 2) return
                
                // Get all available apps
                var allApps = [
                    {name: "Firefox", icon: "firefox", cmd: "firefox"},
                    {name: "Google Chrome", icon: "google-chrome", cmd: "google-chrome-stable"},
                    {name: "Chromium", icon: "chromium", cmd: "chromium"},
                    {name: "Dolphin", icon: "system-file-manager", cmd: "dolphin"},
                    {name: "Konsole", icon: "utilities-terminal", cmd: "konsole"},
                    {name: "Kate", icon: "kate", cmd: "kate"},
                    {name: "KWrite", icon: "kwrite", cmd: "kwrite"},
                    {name: "VS Code", icon: "code", cmd: "code"},
                    {name: "Visual Studio Code", icon: "code", cmd: "code"},
                    {name: "VLC", icon: "vlc", cmd: "vlc"},
                    {name: "GIMP", icon: "gimp", cmd: "gimp"},
                    {name: "Inkscape", icon: "inkscape", cmd: "inkscape"},
                    {name: "Blender", icon: "blender", cmd: "blender"},
                    {name: "LibreOffice Writer", icon: "libreoffice-writer", cmd: "libreoffice --writer"},
                    {name: "LibreOffice Calc", icon: "libreoffice-calc", cmd: "libreoffice --calc"},
                    {name: "Thunderbird", icon: "thunderbird", cmd: "thunderbird"},
                    {name: "Spotify", icon: "spotify", cmd: "spotify"},
                    {name: "Steam", icon: "steam", cmd: "steam"},
                    {name: "Discord", icon: "discord", cmd: "discord"},
                    {name: "Telegram", icon: "telegram", cmd: "telegram-desktop"},
                    {name: "Slack", icon: "slack", cmd: "slack"},
                    {name: "Okular", icon: "okular", cmd: "okular"},
                    {name: "Gwenview", icon: "gwenview", cmd: "gwenview"},
                    {name: "Spectacle", icon: "spectacle", cmd: "spectacle"},
                    {name: "System Settings", icon: "systemsettings", cmd: "systemsettings"},
                    {name: "KCalc", icon: "accessories-calculator", cmd: "kcalc"},
                    {name: "Ark", icon: "ark", cmd: "ark"},
                    {name: "Elisa", icon: "elisa", cmd: "elisa"},
                    {name: "Krita", icon: "krita", cmd: "krita"}
                ]
                
                var searchTerm = searchField.text.toLowerCase()
                var results = []
                
                // Fuzzy search algorithm
                for (var i = 0; i < allApps.length; i++) {
                    var app = allApps[i]
                    var score = fuzzyMatch(searchTerm, app.name.toLowerCase())
                    if (score > 0) {
                        results.push({app: app, score: score})
                    }
                }
                
                // Sort by score (higher is better)
                results.sort(function(a, b) { return b.score - a.score })
                
                // Add top results
                for (var j = 0; j < Math.min(results.length, 10); j++) {
                    searchResults.append(results[j].app)
                }
            }
            
            function fuzzyMatch(pattern, str) {
                var patternIdx = 0
                var score = 0
                var consecutiveBonus = 0
                
                for (var i = 0; i < str.length; i++) {
                    if (patternIdx < pattern.length && str[i] === pattern[patternIdx]) {
                        // Character matches
                        score += 100 + consecutiveBonus
                        consecutiveBonus += 5 // Bonus for consecutive matches
                        patternIdx++
                        
                        // Bonus for match at start
                        if (i === 0) score += 50
                        
                        // Bonus for match after space (word boundary)
                        if (i > 0 && str[i-1] === ' ') score += 30
                    } else {
                        consecutiveBonus = 0
                    }
                }
                
                // All characters must match
                if (patternIdx !== pattern.length) return 0
                
                // Bonus for shorter strings (more specific match)
                score += (100 / str.length) * 10
                
                return score
            }
        }

        QQC2.ScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: 150
            visible: searchResults.count > 0

            ListView {
                id: searchResultsList
                model: ListModel { id: searchResults }
                delegate: QQC2.ItemDelegate {
                    width: ListView.view.width
                    contentItem: RowLayout {
                        Kirigami.Icon {
                            source: model.icon
                            Layout.preferredWidth: 22
                            Layout.preferredHeight: 22
                        }
                        QQC2.Label {
                            text: model.name
                            Layout.fillWidth: true
                        }
                        QQC2.Label {
                            text: model.cmd
                            opacity: 0.5
                            font.pointSize: Kirigami.Theme.smallFont.pointSize
                        }
                    }
                    onClicked: {
                        addApp(model.name, model.icon, model.cmd)
                        searchField.text = ""
                        searchResults.clear()
                    }
                }
            }
        }

        QQC2.Label {
            text: "Or add manually (name|icon|command):"
            Kirigami.FormData.label: " "
        }

        RowLayout {
            Layout.fillWidth: true

            QQC2.TextField {
                id: manualNameField
                Layout.fillWidth: true
                placeholderText: "App Name"
            }

            QQC2.TextField {
                id: manualIconField
                Layout.preferredWidth: 150
                placeholderText: "Icon"
            }

            QQC2.TextField {
                id: manualCmdField
                Layout.preferredWidth: 150
                placeholderText: "Command"
            }

            QQC2.Button {
                text: "Add"
                icon.name: "list-add"
                onClicked: {
                    if (manualNameField.text && manualIconField.text && manualCmdField.text) {
                        addApp(manualNameField.text, manualIconField.text, manualCmdField.text)
                        manualNameField.text = ""
                        manualIconField.text = ""
                        manualCmdField.text = ""
                    }
                }
            }
        }

        QQC2.Label {
            text: "Selected Apps:"
            font.bold: true
            Kirigami.FormData.label: " "
        }

        QQC2.ScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: 200

            ListView {
                id: appList
                model: appListModel
                spacing: 4
                
                delegate: QQC2.ItemDelegate {
                    width: ListView.view.width
                    contentItem: RowLayout {
                        Kirigami.Icon {
                            source: model.icon
                            Layout.preferredWidth: 22
                            Layout.preferredHeight: 22
                        }
                        
                        QQC2.Label {
                            Layout.fillWidth: true
                            text: model.name
                        }
                        
                        QQC2.Label {
                            text: "(" + model.cmd + ")"
                            opacity: 0.6
                            font.pointSize: Kirigami.Theme.smallFont.pointSize
                        }
                        
                        QQC2.ToolButton {
                            icon.name: "list-remove"
                            onClicked: removeApp(index)
                        }
                    }
                }
            }
        }

        QQC2.Label {
            text: "Find icons: ls /usr/share/icons/breeze/apps/48/"
            font.pointSize: Kirigami.Theme.smallFont.pointSize
            opacity: 0.6
        }
    }
}
