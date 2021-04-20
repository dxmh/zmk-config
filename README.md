# zmk-config

My personal [ZMK firmware][3] configuration for my 34-key [Hypergolic][1] wireless keyboard.

## Keymap

See [`config/cradio.keymap`](config/cradio.keymap) for a visualisation of the current keymap layout.

* [Colemak Mod-DH][8] layout on the base layer
* Simple thumb-activated layers for a numpad and navigation cluster
* Dual function keys for [home-row modifiers][9] and the thumb-activated layers
* Symbols on base layer via one-handed combos (in [`combos.dtsi`](config/combos.dtsi))
* Macro-combos for symbol n-grams such as `()`, `--` and `` ``` `` (in [`macros.dtsi`](config/macros.dtsi))

The keymap is continuously evolving and I'm still slowly porting across some features from [my QMK keymap][7] (like the [steno-lite][11] functionality).

I currently use the [`Makefile`](Makefile) to install a local ZMK environment via the [ZMK Docker images][10], apply my required patches/PRs, and then build my `uf2` binaries ready to flash to the nice!nano microcontrollers. All that by running a single `make` command! I then flash the uf2s with `make flash-left` or `make flash-right`.

## Keyboard

![Hypergolic wireless split keyboard](data/hypergolic.jpg)

* [Hypergolic][1] split keyboard PCB by @davidphilipbarr
* [nice!nano][2] wireless BLE microcontrollers
* [ZMK keyboard firmware][3]
* [Kailh Choc low profile key switches][6]
  * gChoc on pinky columns (20g, linear)
  * Red Pro everywhere else (35g, linear)
* [Chicago Stenographer keycaps][4] by @pseudoku on the thumb keys
* [MBK choc keycaps][5] everywhere else

[1]: https://github.com/davidphilipbarr/hypergolic
[2]: https://nicekeyboards.com/nice-nano/
[3]: https://github.com/zmkfirmware/zmk
[4]: https://github.com/pseudoku/PseudoMakeMeKeyCapProfiles#chicago-stenographer
[5]: https://www.reddit.com/r/MechanicalKeyboards/comments/eq6vzs/gb_mbk_choc_lowprofile_keycaps_preorder_now/
[6]: http://www.kailh.com/en/Products/Ks/CS/
[7]: https://github.com/dxmh/34keymap
[8]: https://colemakmods.github.io/mod-dh/
[9]: https://precondition.github.io/home-row-mods
[10]: https://github.com/zmkfirmware/zmk-docker
[11]: https://noahfrederick.com/log/colemak-steno-hybrid-in-qmk
