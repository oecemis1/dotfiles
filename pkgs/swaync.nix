{ swaynotificationcenter }:
swaynotificationcenter.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [
    ./swaync-glass.patch
    ./swaync-text-layout.patch
    ./swaync-toast-fade.patch
    ./swaync-keep-on-close.patch
  ];
})
