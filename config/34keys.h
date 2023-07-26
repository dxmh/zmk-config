#define XXX &none
#define ___ &trans

#define BASE 0
#define NAV 1
#define NUM 2

#define SK(KEY) &nk KEY KEY
#define MO(LAYER) &mo_tap LAYER F24

// Use CONTROL+OPTION+COMMAND, so I still have a chance to use keybindings on a
// default macOS keyboard (unlike hyper key which also includes SHIFT)
#define MEH LC(LA(LGUI))

// Keep sticky keys active for a long time so they effectively do not time out
#define STICKY_KEY_TIMEOUT 60000

// Apple "Globe" key
// https://github.com/zmkfirmware/zmk/issues/947
#define GLOBE CAPSLOCK
