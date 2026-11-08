# Screenshot provenance and remaining gap

`model-unloaded.png` was captured on 2026-11-07 from the actual DMS v2.1.0
bar on Marc's Linux/Hyprland desktop. The `VoxtypeWidget` plugin was loaded
and `systemctl --user is-active voxtype` reported `inactive`. The capture
shows the muted microphone icon in its real model-unloaded state. It was
captured directly with `grim -g "310,0 45x38"`; no UI or status was fabricated.
Coordinates are specific to this desktop's bar layout.

A status/control popout and recording/transcribing captures are still
missing. DMS reported `WIDGET_NO_POPOUT` through widget IPC for this plugin,
and the available native accessibility bridge listed no apps and no
screenshot support. A bar crop was feasible; a new popout capture was not
available through those controls. No dictation was started for this image.

To complete: on a DMS session, left-click the real Voxtype icon and capture
only the popout and icon, excluding other apps and notifications. Capture
recording/transcribing only during a deliberate non-private dictation test.
