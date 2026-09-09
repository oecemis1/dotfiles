import QtQuick

QtObject {
    readonly property color accent: "#eba0ac"
    readonly property color text: "#f8f9ff"
    readonly property color secondaryText: "#cdd6f4"
    readonly property color danger: "#f38ba8"

    readonly property color sheet: "#03000000"
    readonly property color sheetBorder: "transparent"
    readonly property color control: "#14eba0ac"
    readonly property color controlBorder: "transparent"
    readonly property color controlHover: "#4011111b"
    readonly property color controlActive: "#7aeba0ac"
    readonly property color controlActiveHover: "#ffeba0ac"
    readonly property color footer: "#0feba0ac"
    readonly property color sliderTrack: "#2effffff"
    readonly property color sliderActive: "#f2f8f9ff"
    readonly property color sliderThumb: "#fff8f9ff"
    readonly property color sliderThumbPressed: "#18ffffff"
    readonly property color sliderThumbEdge: "#70ffffff"

    readonly property int panelWidth: 400
    readonly property int panelHeight: 940
    readonly property int panelTopMargin: 48
    readonly property int panelRightMargin: 16
    readonly property int panelShadowExtent: 8
    readonly property int outerPadding: 12
    readonly property int spacing: 8
    readonly property int sheetRadius: 24
    readonly property int controlRadius: 18
    readonly property int tileHeight: 64
    readonly property int stripHeight: 52
    readonly property int sliderCardHeight: 82
    readonly property int sliderThumbWidth: 24
    readonly property int sliderThumbHeight: 18
    readonly property int pressDuration: 120
    readonly property int thumbHoverDuration: 140
    readonly property int panelDuration: 250
    readonly property int menuDuration: 300
    readonly property int passwordDuration: 200
    readonly property int unmountDelay: 200
    readonly property int hoverDuration: 120

    readonly property string textFont: "SF Pro Text"
    readonly property string iconFont: "MonaspiceNe Nerd Font Mono"
}
