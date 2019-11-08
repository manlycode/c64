.debuginfo +

.include "c64.inc"                      ; c64 constants
.include "colors.inc"                      ; c64 constants
.include "c64/clrscr.s"
.include "cbm.mac"
.include "vic.inc"

; 1000 possible location on the c64 screen
;       - starts at location $0400
SCREEN_RAM := $0400
PTR_SPR0 := SCREEN_RAM+$3f8
; Color memory $D800
COLOR_MEMORY := $D800
SID_INIT := music
SID_PLAY := music+6

; VIC-II can only see 16k at a time
; so there's a BANK_SELECT register
;

; Screen memory control register $d018


.ZEROPAGE
delay_counter:          .byte 0
delay_animation_pointer:
        .byte 0
        .byte 0
animation_frame:        .byte 16
raster_bar_start:       .byte 1
raster_bar_next:       .byte 1
raster_bar_direction:  .byte 0
raster_bar_color_ptr: .byte 0
.CODE
mainLoop:
        sei
        lda #60
        sta raster_bar_start
        sta raster_bar_next

        ; lda #rasterBarColors
        ; sta raster_bar_color_ptr

        lda #0
        sta raster_bar_direction

        jsr initScreen
        jsr initText
        jsr SID_INIT
        .include "config_sprites.asm"

        lda #$00
        sta delay_animation_pointer
        lda #$01
        sta delay_counter

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
        dec VIC_IRR     ; Acknowledge IRQ
        jsr colorwash
        jsr play_music
        jsr update_ship
        jsr check_keyboard

        ; Open top and bottom borders
        lda #$00        ; clean garbage in $3ff
        sta $3fff

        
start_raster_bars:
        ldx #0
        stx VIC_BG_COLOR0

        lda raster_bar_start
        ldx rasterBarColors
:       cmp VIC_HLINE
        bne :-
        stx VIC_BG_COLOR0
        adc rasterBarWidths

:       cmp VIC_HLINE
        bne :-
        ldx rasterBarColors+1
        stx VIC_BG_COLOR0
        adc rasterBarWidths+1

:       cmp VIC_HLINE
        bne :-
        ldx rasterBarColors+2
        stx VIC_BG_COLOR0
        adc rasterBarWidths+2

:       cmp VIC_HLINE
        bne :-
        ldx rasterBarColors+3
        stx VIC_BG_COLOR0
        adc rasterBarWidths+3

:       cmp VIC_HLINE
        bne :-
        stx VIC_BG_COLOR0
        ldx rasterBarColors+4
        adc rasterBarWidths+4

:       cmp VIC_HLINE
        bne :-
        ldx rasterBarColors+3
        stx VIC_BG_COLOR0
        adc rasterBarWidths+3

:       cmp VIC_HLINE
        bne :-
        ldx rasterBarColors+2
        stx VIC_BG_COLOR0
        adc rasterBarWidths+2

:       cmp VIC_HLINE
        bne :-
        ldx rasterBarColors+1
        stx VIC_BG_COLOR0
        adc rasterBarWidths+1

:       cmp VIC_HLINE
        bne :-
        ldx rasterBarColors
        stx VIC_BG_COLOR0
        adc rasterBarWidths

        ldx #0
:       cmp VIC_HLINE
        bne :-

        stx VIC_BG_COLOR0
        stx raster_bar_next

end_raster_bars:
        lda raster_bar_direction
        bne :+
        inc raster_bar_start
        jmp :++
:       dec raster_bar_start
        
:       lda raster_bar_start
        cmp #60
        bne :+
        lda raster_bar_direction
        eor %00000001
        sta raster_bar_direction

:       cmp #150
        bne :+
        lda raster_bar_direction
        eor %00000001
        sta raster_bar_direction

:       lda #$f9        ; wait for scanline 249
        cmp VIC_HLINE        
        bne :-

        lda VIC_CTRL1       ; trick the VIC and open the border
        and #$f7
        sta VIC_CTRL1

:       lda #$ff        ; wait for scanline 255
        cmp VIC_HLINE        
        bne :-

        lda VIC_CTRL1       ; Reset bit 3 for next refresh
        ora #$08
        sta VIC_CTRL1

        jmp $ea81       ; jump back to kernel interrupt routine

; swapColors:
;         lda #raster_bar_color_ptr
;         cmp rasterBarColors
;         bne :+
; :       lda #rasterBarColors2
;         sta raster_bar_color_ptr
;         jmp :++
; :       lda #rasterBarColors
;         sta raster_bar_color_ptr
; :       rts

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
        jsr SID_PLAY
        rts

update_ship:
        dec VIC_SPR0_X
        bne animate_ship

        lda $d010       ; handle the hi bit
        eor #$01
        sta $d010

animate_ship:
        lda delay_animation_pointer
        eor #$01
        sta delay_animation_pointer
        beq delay_animation

        lda animation_frame
        bne dec_ship_frame

reset_ship_frames:
        lda #14
        sta animation_frame
        lda #sprite_pointer_ship
        sta PTR_SPR0

dec_ship_frame:
        inc PTR_SPR0
        dec animation_frame
        beq reset_ship_frames

delay_animation:
        rts

check_keyboard:
        rts

initScreen:
        ldx #$00
        stx VIC+Vic::bgColor0
        stx VIC+Vic::borderColor

blackScreen:
        lda #$20        ; $20 is the space character
        sta SCREEN_RAM,x     ; fill four areas w/ spacebar chars
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

;line1:  scrcode "           hello     1234               "
line1:   scrcode "             cracked by                  "
line2:   scrcode "             manlyco.de                  "
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


rasterBarWidths:
        .byte 1,2,3,8,16
rasterBarColors:
        .byte 11,7,13,3,14
rasterBarColors2:
        .byte 1,7,13,3,14



.segment "SIDDATA"
music: 
        .incbin "../resources/jeff_donald.sid", $7e

.segment "SPRITEDATA"
sprites:
        .incbin "../resources/sprites.spr", 3,1024

.segment "CHARDATA"
        .incbin "../resources/rambo_font.ctm",24,384
.DATA
        .byte $ED, $Ed, $ED, $ED
