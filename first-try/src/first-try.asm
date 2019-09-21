.debuginfo +

.include "c64.inc"                      ; c64 constants
.include "colors.inc"                      ; c64 constants
.include "c64/clrscr.s"
.include "cbm.mac"
.include "vic.inc"

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
        sei
        jsr CLRSCR
        jsr initScreen
        jsr initText

        ldy #%01111111 ; Bit 7 = 0 (clear all other bits according to mask)
        sty CIA1_ICR    ; Turn off CIA interrupts
        sty CIA2_ICR
        lda CIA1_ICR    ; cancel all cia irqs
        lda CIA2_ICR

        lda #$01        ; set interrupt mask for Vic-II
        sta VIC_IMR     ; IRQ by raster beam


                        ; Point IRQ vector to custom irq routine
        lda #<irq
        ldx #>irq
        sta IRQVec
        stx IRQVec+1

        lda #$00        ; trigger first interrupt at row zero
        sta VIC_HLINE

        lda VIC_CTRL1   ; Bit#0 of VIC_CTRL1 is basically
        and #%01111111  ; the 9th bit for VIC_HILINE
        sta VIC_CTRL1   ; we need to make sure it's set to zero

        cli
        jmp *

irq:
        inc xPos
        dec VIC_IRR     ; Acknowledge IRQ
        jsr colorwash
        jsr play_music
        jmp $ea81       ; jump back to kernel interrupt routine

colorwash:
        ldx #$27
        lda color+39
cycle1:
        ldy color-1,x
        sta color-1,x
        sta $d990,x     ;put current color into color ram
        tya
        dex
        bne cycle1      ; is x zero?
        sta color+39
        sta $d990

colwash2:
        ldx #$00
        lda color2+39

cycle2:
        ldy color2,x
        sta color2,x
        sta $d9e0,x
        tya
        inx
        cpx #$26
        bne cycle2
        sta color2+39
        sta $d9e0+40

        rts


play_music:
        rts

initScreen:
        ldx #$00
        stx VIC+Vic::bgColor0
        stx VIC+Vic::borderColor

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
        rts

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
color:
        .byte $09,$09,$02,$02,$08 
        .byte $08,$0a,$0a,$0f,$0f 
        .byte $07,$07,$01,$01,$01 
        .byte $01,$01,$01,$01,$01 
        .byte $01,$01,$01,$01,$01 
        .byte $01,$01,$01,$07,$07 
        .byte $0f,$0f,$0a,$0a,$08 
        .byte $08,$02,$02,$09,$09 

color2:
        .byte $09,$09,$02,$02,$08 
        .byte $08,$0a,$0a,$0f,$0f 
        .byte $07,$07,$01,$01,$01 
        .byte $01,$01,$01,$01,$01 
        .byte $01,$01,$01,$01,$01 
        .byte $01,$01,$01,$07,$07 
        .byte $0f,$0f,$0a,$0a,$08 
        .byte $08,$02,$02,$09,$09 
