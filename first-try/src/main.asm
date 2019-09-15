.include "c64.inc"                      ; c64 constants
.include "colors.inc"                      ; c64 constants

.CODE
    jsr $e544
    ; setup the colors
    lda #COLOR_YELLOW
    sta $D020             ; border color
    lda #COLOR_RED
    sta $D021             ; middle color

    rts
