.debuginfo +

.include "c64.inc"                      ; c64 constants
.include "colors.inc"                      ; c64 constants
.include "c64/clrscr.s"

.ZEROPAGE
xPos:       .byte xPos, 0
yPos:       .byte yPos, 0


.CODE

        

initText:
        ldx #$00
looptext:
        lda greeting
        sta $0590,x
        inx
        cpx #$28
        bne looptext
        rts

mainLoop:
        jsr CLRSCR
        ; setup the colors
        ; lda #COLOR_BLUE
        ; sta $D020             ; border color
        ; lda #COLOR_RED
        ; sta $D021             ; middle color
        jsr initText
        rts


.DATA
greeting:    .byte "      hello world             "          
