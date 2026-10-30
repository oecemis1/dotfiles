{ swaynotificationcenter }:
swaynotificationcenter.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [ ./swaync-glass.patch ];
})
