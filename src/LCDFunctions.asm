; Pre-made hardware interface
INCLUDE "hardware.inc"

SECTION "LCD Functions", ROM0

; -------------------------------------
; Functions definitions - LCD Functions 
; -------------------------------------

; Turn off the LCD 
disableLCD::

    ; Make sure to wait for VBlank before we turn off the screen to avoid destroying it
    .waitForVBlank:
        ld a, [rLY]
        cp 144
        jr c, .waitForVBlank
    
    ; Set rLCDC to 0 in order to shut it off
        ld a, 0
        ld [rLCDC], a ; disable the LCD by writing zero to the LCDC
        ; Return to code
        ret

; Turn on the LCD
enableLCD::
    ld a, LCDCF_BGON | LCDCF_BG8800 | LCDCF_ON | LCDCF_OBJON | LCDCF_OBJ16
    ldh [rLCDC], a
    ; Return to code
    ret
    
; Set color palette - Sets the palette of the screen to %11100100
loadPalette::
    ld a, %11100100
    ; ld a, %11010010
    ld [rBGP], a
    ld [rOBP0], a
    ; Return to code
    ret 
        
; Copy grassy tiles into registers to be loaded
copyGrassyTiles::
    ld de, GrassyTiles
    ld hl, $9000
    ld bc, GrassyTiles.end - GrassyTiles ; We set bc to the amount of bytes to copy
    ; Push copied tileset to VRAM
    jp memcpy
  
; Copy sprite tiles into registers to be loaded
copySpriteTiles::
    ld de, SpriteTiles
    ld hl, $8000
    ld bc, SpriteTiles.end - SpriteTiles ; We set bc to the amount of bytes to copy
    ; Push copied tileset to VRAM
    jp memcpy

    /*
; Copy HillSide tile map into registers to be loaded
copyHillSideMap::
    ld de, HillSideTilemap
    ld hl, $9800
    ld bc, HillSideTilemap.end - HillSideTilemap ; We set bc to the amount of bytes to copy
    ; Push copied tilemap to VRAM
    jp memcpy

; Copy HillMiddle tile map into registers to be loaded
copyHillMiddleMap::
    ld de, HillMiddleTilemap
    ld hl, $9800
    ld bc, HillMiddleTilemap.end - HillMiddleTilemap ; We set bc to the amount of bytes to copy
    ; Push copied tilemap to VRAM
    jp memcpy 
    */

; Copy HillsMapTilemap into registers to be loaded
copyNewHillExtMap::
    ld de, HillsMapCollisionMap
    ld a, d
    ld [currentCollisionMap], a
    ld a, e
    ld [currentCollisionMap + 1], a
    ld de, HillsMapTilemap
    ld a, d
    ld [currentTileMap], a
    ld a, e
    ld [currentTileMap + 1], a
    ld hl, $9800
    ; Define map dims
    ld a, $00
    ld [mapX], a ; Units
    ld a, $40
    ld [mapX+1], a
    ; To calculate pixel width do : (mapX * 8) - ($14 * 8)
    ld a, $01
    ld [maxX], a ; Pixels
    ld a, $60
    ld [maxX+1], a

    ld a, $00
    ld [mapY], a ; Units
    ld a, $40
    ld [mapY+1], a
    ; To calculate pixel width do : (mapX * 8) - ($12 * 8)
    ld a, $01
    ld [maxY], a ; Pixels
    ld a, $70
    ld [maxY+1], a
    ; Push copied tilemap to VRAM
    ;ret
    jp pLoadExtendedMap

; Loads the copied ext tilemap into VRAM - Loads the map into the VRAM at $9800
; NEVER CALL THIS FUNCTION DIRECTLY
pLoadExtendedMap::
    
    ; Set drawOffset
    ld a, 0
    ld [drawOffset], a

; Draw the screen
.screenLoop:

    ; Set universalCounter
    ld a, $20
    ld [universalCounter], a

    ; Load some tiles
    .rowLoop:
        
        ; Loop body
        ld a, [de]
        ld [hli], a 

        ; increment de
        inc de

        ; Dec timer
        ld a, [universalCounter]
        dec a
        ld [universalCounter],a
        
        ; Loop?
        jp nz, .rowLoop

    ; Add mapX minus $20 to DE

    ; One row down: 
    ld a, [drawOffset]
    inc a
    ld [drawOffset],a

    ; 32? Is that you?
    cp a, $20

    ; Loop?
    jp z, .end

    ; Save HL
    ;ld b, h
    ;ld c, l
    push hl

    ; Get mapX
    ld a, [mapX]
    ld h, a
    ld a, [mapX+1]
    ld l, a

    ; Sub a to hl
    ld a, $20
    cpl
    scf
    adc   a, l
    ld    l, a
    ld    a, -1 ; And subtract 256 here
    adc   a, h
    ld    h, a

    ; Okay, so now HL = mapX - $14.
    ; Now just take DE and add HL
    add hl, de
    ld d, h
    ld e, l

    ; Restore HL
    ;ld h, b
    ;ld l, c
    pop hl

    ; Loop?
    jp .screenLoop

; Loop end
.end:

    ; Return to code
    ret
