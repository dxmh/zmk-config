#define XXX &none
#define ___ &trans

#define BASE 0
#define NAV 1
#define SYM 2
#define ADJ 3
#define BASE_IOS 4
#define NAV_IOS 5

#define NEXT LC(PG_DN)
#define PREV LC(PG_UP)
#define SW_APP LG(TAB)
#define WORD_BS LC(BSPC)
#define WORD_L LC(LEFT)
#define WORD_R LC(RIGHT)

#define iEND LG(RIGHT)
#define iHOME LG(LEFT)
#define iNEXT LC(TAB)
#define iPREV LS(LC(TAB))
#define iWORD_BS LA(BSPC)
#define iWORD_L LA(LEFT)
#define iWORD_R LA(RIGHT)

// Apple's "Globe key" is mapped to Caps Lock at the operating system level
// https://github.com/zmkfirmware/zmk/issues/947
#define GLOBE CAPSLOCK
