#!/bin/bash
cd "$(dirname "$0")"
kpackagetool6 --type Plasma/Applet --upgrade .
echo ""
echo "Widget updated! Restart Plasma with:"
echo "killall plasmashell && kstart plasmashell"
