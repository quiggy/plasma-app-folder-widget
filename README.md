# Plasma App Folder Widget

A compact Plasma 6 widget that brings smartphone-style app folders to your KDE taskbar. Features fuzzy search, customizable icons, and a clean interface for organizing your favorite applications.

![Plasma 6](https://img.shields.io/badge/Plasma-6-blue)
![License](https://img.shields.io/badge/license-GPL--3.0-green)

## Features

- 🔍 **Fuzzy Search** - Quickly find apps by typing partial names (e.g., "ff" finds Firefox)
- 📁 **Customizable Folders** - Set custom folder names and icons
- 📱 **Smartphone-like Experience** - Compact grid layout similar to mobile launchers
- 🎨 **Visual App Management** - Easy drag-and-drop interface for organizing apps
- ⚡ **Lightweight** - Minimal resource usage
- 🔧 **Easy Configuration** - Built-in settings dialog

## Installation

### Manual Installation

1. Clone this repository:
```bash
git clone https://github.com/alexdoescodes/plasma-app-folder-widget.git
cd plasma-app-folder-widget
```

2. Install the widget:
```bash
kpackagetool6 --type Plasma/Applet --install .
```

3. Add to your panel:
   - Right-click on your panel
   - Select "Add Widgets..."
   - Search for "App Folder"
   - Drag it to your panel

### Updating

After making changes or pulling updates:
```bash
./update.sh
# Then restart plasmashell:
killall plasmashell && kstart plasmashell
```

Or manually:
```bash
kpackagetool6 --type Plasma/Applet --upgrade .
killall plasmashell && kstart plasmashell
```

## Usage

1. **Click the folder icon** in your panel to open the app grid
2. **Configure the folder** by clicking the settings icon at the bottom
3. **Search for apps** using the fuzzy search in settings
4. **Add apps manually** using the Name|Icon|Command format

### Finding Icon Names

Browse available icons:
```bash
ls /usr/share/icons/breeze/apps/48/ | sed 's/\.svg//'
```

Search for specific icons:
```bash
find /usr/share/icons -name '*chrome*.svg' | xargs -n1 basename | sed 's/\.svg//'
```

## Configuration

Access settings by:
- Right-clicking the widget → Configure
- Or clicking the gear icon inside the opened folder

### Settings Options

- **Folder Name** - Display name shown at the bottom
- **Folder Icon** - Icon shown in the panel
- **Apps** - Search and add applications to your folder

## Requirements

- KDE Plasma 6.0 or higher
- Qt 6
- KDE Frameworks 6

## Development

Project structure:
```
plasma-app-folder-widget/
├── contents/
│   ├── config/
│   │   ├── config.qml       # Configuration structure
│   │   └── main.xml          # Configuration schema
│   └── ui/
│       ├── main.qml          # Main widget UI
│       └── configGeneral.qml # Settings dialog
├── metadata.json             # Widget metadata
├── update.sh                 # Quick update script
└── README.md
```

## Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest features
- Submit pull requests

## License

This project is licensed under the GPL-3.0 License - see the LICENSE file for details.

## Author

Created by Alex ([alexdoescodes](https://github.com/alexdoescodes))

## Acknowledgments

- Inspired by smartphone app launchers
- Built for the KDE Plasma desktop environment
