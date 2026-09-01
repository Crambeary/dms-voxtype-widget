# dms-voxtype-widget

DankMaterialShell (DMS) widget that shows [Voxtype](https://github.com/omacom/omarchy) dictation status (idle/recording/transcribing) in the bar.

- **Left click**: open a menu with the current status, Cancel (when recording/transcribing), and Load/Unload Model
- **Right click**: toggle recording
- **Middle click**: toggle the voxtype daemon (load/unload the model — frees ~2GB when unloaded)

The daemon toggle expects a systemd user service named `voxtype` (`systemctl --user start/stop voxtype`).

## Install

Symlink this repo into your DMS plugins directory:

```bash
ln -s /path/to/dms-voxtype-widget ~/.config/DankMaterialShell/plugins/VoxtypeWidget
```

## Reload after edits

DMS plugins are not hot-reloaded automatically. After editing `Voxtype.qml`, run:

```bash
qs -p ~/.config/quickshell/dms ipc call plugins reload VoxtypeWidget
```
