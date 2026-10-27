# Fonts

## RobotoMono-Regular.ttf, RobotoMono-Medium.ttf

Roboto Mono, Copyright 2015 The Roboto Mono Project Authors, licensed under the
Apache License, Version 2.0. Source: https://fonts.google.com/specimen/Roboto+Mono

The files are the copies shipped inside the Dart SDK DevTools bundle that comes
with the Flutter toolchain this project pins, so the build does not reach the
network.

Used for equation blocks and other fixed-width figures. Bundling it rather than
relying on the platform `monospace` alias keeps the on-device render and the
documentation screenshots identical.
