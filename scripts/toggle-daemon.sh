#!/bin/sh
# Starts/stops the voxtype systemd user service. Autostart is disabled
# (systemctl --user disable voxtype) since the Parakeet model holds ~2GB
# resident even when idle, so this is the only thing that brings it up.
# Kept as a real script (not inlined in a .desktop Exec= line, and not
# duplicated inline in Voxtype.qml or the Hyprland keybind) because DMS's
# launcher and QML string interpolation both mis-parse the nested-quote
# shell one-liner this used to be everywhere it lived.
if systemctl --user is-active --quiet voxtype; then
	systemctl --user stop voxtype
	notify-send -a voxtype "Voxtype" "Model unloaded (memory freed)" -i microphone-sensitivity-muted-symbolic
else
	systemctl --user start voxtype
	notify-send -a voxtype "Voxtype" "Model loading…" -i microphone-sensitivity-high-symbolic
fi
