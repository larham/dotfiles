#!/bin/bash
set -euo pipefail

sudo cp ./timemachine-mount-run-unmount.sh /usr/local/bin/
cp ./timemachine-mount-run-unmount.plist "$HOME/Library/LaunchAgents/timemachine-mount-run-unmount.plist"
#sudo chown root:wheel "$HOME/Library/LaunchAgents/timemachine-mount-run-unmount.plist"
#sudo chmod 600 /Users/lhamel/Library/LaunchAgents/timemachine-mount-run-unmount.plist

launchctl load "$HOME/Library/LaunchAgents/timemachine-mount-run-unmount.plist"
