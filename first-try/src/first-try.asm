.debuginfo +

.include "c64.inc"                      ; c64 constants
.include "colors.inc"                      ; c64 constants
.include "c64/clrscr.s"
.include "cbm.mac"

; 1000 possible location on the c64 screen
;       - starts at location $0400
SCREEN_MEMORY := $0400

; Color memory $D800
COLOR_MEMORY := $D800

; VIC-II can only see 16k at a time
; so there's a BANK_SELECT register
;

; Screen memory control register $d018


.ZEROPAGE
xPos:       .byte xPos, 0
yPos:       .byte yPos, 0


.CODE

mainLoop:
        jsr CLRSCR

init_screen:
        ldx #$05
        stx $d021
        stx $d020

blackScreen:
        lda #$20        ; $20 is the space character
        sta $0400,x     ; fill four areas w/ spacebar chars
        sta $0500,x
        sta $0600,x
        sta $06e8,x

        lda #$00
        sta $d800,x
        sta $d900,x
        sta $da00,x
        sta $dae8,x
        inx
        bne blackScreen

initText:
        ldx #$00
initTextLoop:
        lda line1,x
        sta $0590,x
        lda line2,x
        sta $05e0,x
        inx
        cpx #$28
        bne initTextLoop
        rts

.DATA
line1:  scrcode "           hello                        "
line2:  scrcode "           hello                        "
