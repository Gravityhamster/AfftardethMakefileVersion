; ROM start

; -------
; INCLUDE
; -------

; Pre-made hardware interface
INCLUDE "hardware.inc"

; Handle interrupts
SECTION "vblankInterrupt", ROM0[$040]
    jp vblankHandler

; SETUP - Allocates for GB logo (?)
SECTION "Header", ROM0[$100]

    jp main
    ; Write zeros until at address 150
    ds $150 - @, 0

; START
SECTION "Game code", ROM0[$150]

; ----------------
; VBlank Interrupt
; ----------------
vblankHandler:
    ; VBlank interrupt. We only call the OAM DMA routine here.
    ; We need to be careful to preserve the registers that we use, see interrupt example.
    push af
    call hOAMCopyRoutine
    pop  af
    reti

; ---------------------------------------
; Main - This is where the program starts
; ---------------------------------------
main:

    ; Set map x
    ld a, $00
    ld [memX], a
    ld [memX+1], a
    ld [pixX], a
    ld [pixX+1], a

    ; Turn off the LCD
    call disableLCD

    ; Initialize the OAM shadow buffer
    call initOAM

    ; Load the tileset into the registers and move to VRAM
    call copyGrassyTiles

    ; Load the tileset into the registers and move to VRAM
    call copySpriteTiles

    ; Load the tilemap into the registers and move to VRAM
    call copyNewHillExtMap

    ; Load the palette
    call loadPalette

    ; Turn on the LCD
    call enableLCD

    ; Configure sprites in the OAM memory with different positions and palettes.
    ld   a, 20  ; y position
    ld   [wOAMBuffer + 0], a
    ld   a, 20  ; x position
    ld   [wOAMBuffer + 1], a
    ld   a, 0   ; tile number
    ld   [wOAMBuffer + 2], a
    ld   a, 0   ; sprite attributes
    ld   [wOAMBuffer + 3], a

    ; Enable the VBlank interrupt
    ld   a, IEF_VBLANK
    ld   [rIE], a
    ei

    ; Loop the game
    jp gameLoop

; ---------------------------------------------
; gameLoop - This is where the gameLoop happens
; ---------------------------------------------
gameLoop:
    ; Update the joypad
    call updateJoypadState
    ; Move the screen
    call moveViewPortx1y1
    ; Loop
    jp gameLoop
    
; -----------------------------------------
; Function definitions - Viewport Functions
; -----------------------------------------

; Move the viewport
moveViewPortx1y1:    
    ; Wait for VBlank, otherwise screen dies in a fire (glitchiness)
.waitForVBlank:
    ld a, [rLY]
    cp 144
    jr c, .waitForVBlank

    ; $FF43 - Scroll X
    ; $FF42 - Scroll Y
    ; b = x
    ; c = y
    
    ; Check if mapx
    ; Load mapx
    ld a, [maxX]
    ld b, a
    ld a, [maxX + 1]
    ld c, a

    ; loap memx
    ld a, [pixX]
    ld d, a
    ld a, [pixX + 1]
    ld e, a

    ; Check if memx == mapx
    
    ; b - d = ?
    ld a, b
    sub a, d
    ld b, a

    ; c - e = ?
    ld a, c
    sub a, e
    ; Alright, check if this is a zero result:
    or a, b

    jp z, .SkipAllRight

    ; Load $FF43 into a
    ld a, [$FF43] ; [$FF43] is Viewport X
    and a, %00000111
    ; Only load a column and increment memX if the viewport is divisible by 8
    jp nz, .skip1 ; Skip the column drawing code if not zero
    
    ; Check right joypad
    ld a, [joypadState]
    and a, %00010000
    ; Draw column if joypadR
    call nz, getNextColumnRight
    
.skip1:

    ld a, [joypadState]
    and a, %00010000
    jp z, .rOff
    ld a, [$FF43]
    add a, 1
    ld [$FF43], a

    ; increment pixX
    ld a, [pixX]
    ld b, a
    ld a, [pixX+1]
    ld c, a
    inc bc
    ld a, b
    ld [pixX], a
    ld a, c
    ld [pixX+1], a

.rOff
.SkipAllRight:
    
    ; Check if zero
    ; Load memx
    ld a, [memX]
    ld b, a
    ld a, [memX + 1]
    ld c, a
    ld a, [$FF43]
    or a, b
    or a, c
    jp z, .SkipAllLeft

    ; Move the viewport left
    ld a, [joypadState]
    and a, %00100000
    jp z, .lOff
    ld a, [$FF43]
    sub a, 1
    ld [$FF43], a

    ; decrement pixX
    ld a, [pixX]
    ld b, a
    ld a, [pixX+1]
    ld c, a
    dec bc
    ld a, b
    ld [pixX], a
    ld a, c
    ld [pixX+1], a

.lOff

    ; Load $FF43 into a
    ld a, [$FF43] ; [$FF43] is Viewport X
    and a, %00000111
    ; Only load a column and increment memX if the viewport is divisible by 8
    jp nz, .skip2 ; Skip the column drawing code if not zero

    ; Check left joypad
    ld a, [joypadState]
    and a, %00100000
    ; Draw column if joypadL
    call nz, getNextColumnLeft

.skip2:

.SkipAllLeft:

    ; Vertical  
    ; Working vertical movement
    ld a, [joypadState]
    and a, %10000000
    jp z, .dskip  ; Input
    ld a, [$FF42]
    cp a, $70 ; clamp
    jp nc, .dskip  ; clamp
    add a, 1
    ld [$FF42], a
.dskip:  ; clamp

    ld a, [joypadState]
    and a, %01000000
    jp z, .uskip  ; Input
    ld a, [$FF42]
    cp a, $01 ; clamp
    jp c, .uskip ; clamp
    sub a, 1
    ld [$FF42], a
.uskip: ; clamp

    ; Return to code
    ret

; Get top and to the right
getNextColumnRight:

    ; Load memX into BC
    ld a, [memX]
    ld b, a
    ld a, [memX + 1]
    ld c, a

    ; Check if the viewport is 0 
    ld a, [$FF43]
    or b
    or c
    
    jp z, .skipInc

    ; Increment BC
    inc bc

    ; Reading back BC to memX
    ld a, b
    ld [memX], a
    ld a, c
    ld [memX + 1], a
    
.skipInc:

    ; Setting DE

    ; Load the location into DE
    ld de, HillsMapTilemap + $14

    ; add bc to de
    ld h, b
    ld l, c
    add hl, de
    ld d, h
    ld e, l

.loopSkip:

    ; Setting HL

    ; Get screen position
    ld a, [$FF43]
    ; Divide by 8
    sra a
    sra a
    sra a
    ; Clear bad sign bits
    and a, %00011111

    ; Set BC to the screen offset: floor ( Screen position / 8 )
    ld b, 0
    ld c, a
    
    ; Set hl to the VRAM address plus the number of tiles across the screen
    ld hl, $9800 + 20
    ; Add the screen offset to the VRAM position
    add hl, bc

    ; Load the current number into A
    ld a, l
    ; Subtract the offset from HL to see if it must be shifted
    sub a, $20

    ; If the subtraction causes overflow, then we know the register is < 32, and we do not need to subtract from it, in which case we jump.
    ; If the subtraction does not cause overflow, then we know the register is >= 32, and we need to subtract from it.
    jp c, .c
    ; HL minus 20 hex
    ld a, l
    sub a, $20
    ld l, a

.c:

    ; Draw the entire column
    jp drawColumn

; Get top and to the Left
getNextColumnLeft:

    ; Load memX into BC
    ld a, [memX]
    ld b, a
    ld a, [memX + 1]
    ld c, a
    or a, b
    jp z, .zz

    ; Decrement BC
    dec bc
    
    ; Reading back BC to memX
    ld a, b
    ld [memX], a
    ld a, c
    ld [memX + 1], a

.zz:

    ; Setting DE

    ; Load the location into DE
    ld de, HillsMapTilemap

    ; add bc to de
    ld h, b
    ld l, c
    add hl, de
    ld d, h
    ld e, l

    ; Setting HL

    ; Get screen position
    ld a, [$FF43]
    ; Divide by 8
    sra a
    sra a
    sra a
    ; Clear bad sign bits
    and a, %00011111

    ; Set BC to the screen offset: floor ( Screen position / 8 )
    ld b, 0
    ld c, a

    ; Set hl to the VRAM address plus the number of tiles across the screen
    ld hl, $9800 + 31
    ; Add the screen offset to the VRAM position
    add hl, bc

    ; Load the current number into A
    ld a, l
    ; Subtract the offset from HL to see if it must be shifted
    sub a, $20

    ; If the subtraction causes overflow, then we know the register is < 32, and we do not need to subtract from it, in which case we jump.
    ; If the subtraction does not cause overflow, then we know the register is >= 32, and we need to subtract from it.
    jp c, .c
    ; HL minus 20 hex
    ld a, l
    sub a, $20
    ld l, a
.c:

    ; Draw the entire column
    jp drawColumn

; Draw a column at HL
drawColumn:
    ; TODO: Add a proper loop so that this takes up less space in ROM
    call setTileForColumn
    call setTileForColumn
    call setTileForColumn
    call setTileForColumn
    call setTileForColumn
    call setTileForColumn
    call setTileForColumn
    call setTileForColumn
    call setTileForColumn
    call setTileForColumn
    call setTileForColumn
    call setTileForColumn
    call setTileForColumn
    call setTileForColumn
    call setTileForColumn
    call setTileForColumn
    call setTileForColumn
    call setTileForColumn
    call setTileForColumn
    call setTileForColumn
    call setTileForColumn
    call setTileForColumn
    call setTileForColumn
    call setTileForColumn
    call setTileForColumn
    call setTileForColumn
    call setTileForColumn
    call setTileForColumn
    call setTileForColumn
    call setTileForColumn
    call setTileForColumn
    call setTileForColumn
    ; Ret to code
    ret

; One tile and goto next
setTileForColumn:    
    ; Wait for HBlank, otherwise screen dies in a fire (glitchiness)
.waitVRAM
    ldh a, [rSTAT]
    and a, STATF_BUSY
    jr nz, .waitVRAM  

    ; Set to appropriate tile.
    ld a, [de]
    ld [hl], a

    ; Add the map width to DE

    ; Load HL into BC for now.
    ld b, h
    ld c, l

    ; Load the map width into HL
    ld a, [mapX]
    ld h, a
    ld a, [mapX+1]
    ld l, a

    ; Add de to hl
    add hl, de
    ; Load hl into de
    ld d, h
    ld e, l

    ; Load BC back to HL
    ld h, b
    ld l, c
    
    ; Add the 32 to HL 

    ; Add 32 to hl
    ld a, $20
    add a, l
    ld l, a
    adc a, h
    sub l
    ld h, a

    ; Return to code
    ret

; -------------------------------------
; Functions definitions - LCD Functions 
; -------------------------------------

; Turn off the LCD 
disableLCD:

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
enableLCD:
    ld a, LCDCF_BGON | LCDCF_BG8800 | LCDCF_ON | LCDCF_OBJON
    ldh [rLCDC], a
    ; Return to code
    ret
    
; Set color palette - Sets the palette of the screen to %11100100
loadPalette:
    ld a, %11100100
    ld [rBGP], a
    ld a, %11100100
    ld [rOBP0], a
    ; Return to code
    ret 
     
; Copy grassy tiles into registers to be loaded
copyGrassyTiles:
    ld de, GrassyTiles
    ld hl, $9000
    ld bc, GrassyTiles.end - GrassyTiles ; We set bc to the amount of bytes to copy
    ; Push copied tileset to VRAM
    jp pLoadTiles
     
; Copy sprite tiles into registers to be loaded
copySpriteTiles:
    ld de, SpriteTiles
    ld hl, $8000
    ld bc, SpriteTiles.end - SpriteTiles ; We set bc to the amount of bytes to copy
    ; Push copied tileset to VRAM
    jp pLoadTiles

; Loads the copied graphics into VRAM - Loads the tileset into the VRAM at $8000
; NEVER CALL THIS FUNCTION
pLoadTiles:
.copyTilesLoop:
    ; Copy a byte from ROM to VRAM, and increase hl, de to the next location
    ld a, [de]
    ld [hli], a
    inc de
    ; Decrease the amount of bytes we still need to copy and check if the amount left is zero
    dec bc
    ld a, b
    or a, c
    jp nz, .copyTilesLoop
    ; Return to code
    ret

; Copy HillSide tile map into registers to be loaded
copyHillSideMap:
    ld de, HillSideTilemap
    ld hl, $9800
    ld bc, HillSideTilemap.end - HillSideTilemap ; We set bc to the amount of bytes to copy
    ; Push copied tilemap to VRAM
    jp pLoadMap

; Copy HillMiddle tile map into registers to be loaded
copyHillMiddleMap:
    ld de, HillMiddleTilemap
    ld hl, $9800
    ld bc, HillMiddleTilemap.end - HillMiddleTilemap ; We set bc to the amount of bytes to copy
    ; Push copied tilemap to VRAM
    jp pLoadMap

; Loads the copied tilemap into VRAM - Loads the map into the VRAM at $9800
; NEVER CALL THIS FUNCTION
pLoadMap:
.copyTileMapLoop:
    ; Copy a byte from ROM to VRAM, and increase hl, de to the next location
    ld a, [de]
    ld [hli], a
    inc de
    ; Decrease the amount of bytes we still need to copy and check if the amount left is zero
    dec bc
    ld a, b
    or a, c
    jp nz, .copyTileMapLoop
    ; Return to code
    ret 

; Copy HillsMapTilemap into registers to be loaded
copyNewHillExtMap:
    ld de, HillsMapTilemap
    ld hl, $9800
    ; Define map dims
    ld a, $00
    ld [mapX], a
    ld a, $40
    ld [mapX+1], a
    ld a, $01
    ld [maxX], a
    ld a, $60
    ld [maxX+1], a
    ; Push copied tilemap to VRAM
    jp pLoadExtendedMap

; Loads the copied ext tilemap into VRAM - Loads the map into the VRAM at $9800
; NEVER CALL THIS FUNCTION
pLoadExtendedMap:
    
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
    ld b, h
    ld c, l

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
    ld h, b
    ld l, c

    ; Loop?
    jp .screenLoop

; Loop end
.end:

    ; Return to code
    ret

; ---------------------------------------
; Function definitions - Joypad Functions
; ---------------------------------------

; Update Joypad Pressed Buttons 
updateJoypadState:

    ; Get joypad register
    ld hl, rP1

    ; Activate the buttons for the joypad
    ld [hl], P1F_GET_BTN

    ; After the initial enable we need to read
    ; twice to ensure we get the proper hardware
    ; state on real hardware
    ld a, [hl]
    ld a, [hl]

    ; Activate the d-pad for the joypad
    ld [hl], P1F_GET_DPAD

    ; Inputs are active low, so a bit being 0 is a button bressed, so we invert this.
    cpl
    ; Piece together the input constants
    and PADF_A | PADF_B | PADF_SELECT | PADF_START
    ; Store the lower 4 buttons' bits in c
    ld c, a

    ; We need to read the rP1 8 times to ensure the proper
    ; button is available. This is only needed
    ; on real hardware, as it takes a while for the
    ; inputs to change state back from the first set.
    ld b, 8
.dpadDebounceLoop:
    ; Read
    ld a, [hl]
    ; Count down
    dec b
    ; Jump back
    jp nz, .dpadDebounceLoop

    ; Deactivate all
    ld [hl], P1F_GET_NONE

    ; We want the directional keys as upper 4 bits, so swap the nibbles
    swap a
    ; Inputs are active low, so a bit being 0 is a button pressed. So invert
    cpl
    ; Piece together the input constants
    and PADF_RIGHT | PADF_LEFT | PADF_UP | PADF_DOWN
    or c
    ld c, a

    ; Compare the new joypad state with the previous one,
    ; and store the new bits in wJoypadPressed
    ld hl, joypadState
    xor [hl]
    and c
    ld [joypadPressed], a
    ld a, c
    ld [joypadState], a
    
    ret

; -------------------------------------
; Function definitions - Math Functions
; -------------------------------------

; Multiplay BC times 32
BCTimes32:

    ; BC * 2 - 1
    sla c
    ; If there was an overflow, add that lost bit to b
    jp nc, .c1
    ld a, b
    add a, 1
    ld b, a
.c1
    sla b
    ; BC * 2 - 2
    sla c
    ; If there was an overflow, add that lost bit to b
    jp nc, .c2
    ld a, b
    add a, 1
    ld b, a
.c2
    sla b
    ; BC * 2 - 3
    sla c
    ; If there was an overflow, add that lost bit to b
    jp nc, .c3
    ld a, b
    add a, 1
    ld b, a
.c3
    sla b
    ; BC * 2 - 4
    sla c
    ; If there was an overflow, add that lost bit to b
    jp nc, .c4
    ld a, b
    add a, 1
    ld b, a
.c4
    sla b
    ; BC * 2 - 5
    sla c
    ; If there was an overflow, add that lost bit to b
    jp nc, .c5
    ld a, b
    add a, 1
    ld b, a
.c5
    ;sla b
    ; Return to code
    ret
    
; Multiplay HL times 32
HLTimes32:

    ; BC * 2 - 1
    sla l
    ; If there was an overflow, add that lost bit to b
    jp nc, .c1
    ld a, h
    add a, 1
    ld h, a
.c1
    sla h
    ; BC * 2 - 2
    sla l
    ; If there was an overflow, add that lost bit to b
    jp nc, .c2
    ld a, h
    add a, 1
    ld h, a
.c2
    sla h
    ; BC * 2 - 3
    sla l
    ; If there was an overflow, add that lost bit to b
    jp nc, .c3
    ld a, h
    add a, 1
    ld h, a
.c3
    sla h
    ; BC * 2 - 4
    sla l
    ; If there was an overflow, add that lost bit to b
    jp nc, .c4
    ld a, h
    add a, 1
    ld h, a
.c4
    sla h
    ; BC * 2 - 5
    sla l
    ; If there was an overflow, add that lost bit to b
    jp nc, .c5
    ld a, h
    add a, 1
    ld h, a
.c5
    ;sla b
    ; Return to code
    ret

; --------------------------------------------
; Function definitions - Sprite initialization
; --------------------------------------------

; Initialize the OAM tile buffer
initOAM:
    ; Initialize the OAM shadow buffer, and setup the OAM copy routine in HRAM.
    ld   hl, wOAMBuffer
    ld   c, wOAMBuffer.end - wOAMBuffer
    xor  a
  .clearOAMLoop:
    ld   [hl+], a
    dec  c
    jr   nz, .clearOAMLoop
  
    ld   hl, hOAMCopyRoutine
    ld   de, oamCopyRoutine
    ld   c, hOAMCopyRoutine.end - hOAMCopyRoutine
  .copyOAMRoutineLoop:
    ld   a, [de]
    inc  de
    ld   [hl+], a
    dec  c
    jr   nz, .copyOAMRoutineLoop
    ; We directly copy to clear the initial OAM memory, which else contains garbage.
    call hOAMCopyRoutine
    ret

; Allocate space for the oam copy routine and also place the routine into HRAM
  oamCopyRoutine:
  LOAD "hram", HRAM
  hOAMCopyRoutine:
    ld   a, HIGH(wOAMBuffer)
    ldh  [rDMA], a
    ld   a, $28
  .wait:
    dec  a
    jr   nz, .wait
    ret
  .end:
  ENDL

; Graphics section
SECTION "Graphics", ROM0

; Grassy tile data
GrassyTiles::
    INCBIN "res/GrassyTiles.2bpp"
    .end:

; Sprite tile data
SpriteTiles::
    INCBIN "res/SpriteTiles.2bpp"
    .end:

