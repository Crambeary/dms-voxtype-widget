# dms-voxtype-widget

DankMaterialShell (DMS) widget that shows [Voxtype](https://github.com/omacom/omarchy) dictation status (idle/recording/transcribing) in the bar and toggles recording on click.

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
