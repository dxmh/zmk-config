#define XXX &none
#define ___ &trans

#define BASE_MAC 0
#define BASE_LINUX 1
#define NAV_MAC 2
#define NAV_LINUX 3
#define NUM 4

#define BASE BASE_MAC BASE_LINUX
#define NAV NAV_MAC NAV_LINUX

#define SK(KEY) &nk KEY KEY
#define MO(LAYER) &mo_tap LAYER &mm_esc

// Apple's "Globe key" is mapped to Caps Lock at the operating system level
// https://github.com/zmkfirmware/zmk/issues/947
#define GLOBE CAPSLOCK

// Keep sticky keys active for a long time so they effectively do not time out
#define STICKY_KEY_TIMEOUT 60000
