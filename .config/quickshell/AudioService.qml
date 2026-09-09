import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Scope {
    id: root

    property var sink: Pipewire.defaultAudioSink

    readonly property bool available: sink !== null && sink.ready && sink.audio !== null
    readonly property int volume: available
        ? Math.round(Math.max(0, Math.min(1, sink.audio.volume)) * 100)
        : 0
    readonly property bool muted: available ? sink.audio.muted : false

    function setVolume(requested: int): bool {
        if (!available)
            return false;

        sink.audio.volume = Math.max(0, Math.min(100, requested)) / 100;
        return true;
    }

    function toggleMute(): bool {
        if (!available)
            return false;

        sink.audio.muted = !sink.audio.muted;
        return true;
    }

    PwObjectTracker {
        objects: [root.sink]
    }
}
