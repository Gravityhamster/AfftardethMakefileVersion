; ROM start

; -------
; INCLUDE
; -------

; Pre-made hardware interface
INCLUDE "hardware.inc"

; Handle interrupts
SECTION "vblankInterrupt", ROM0[$040]
    push af
    push bc
    push de
    push hl
    jp vblankHandler

; SETUP - Allocates for GB logo (?)
SECTION "Header", ROM0[$100]

    jp main
    ; Write zeros until at address 150
    ds $150 - @, 0

; START
SECTION "Game code", ROM0[$150]

; VBlank Interrupt
vblankHandler:
    
    ; Push sprites to OAM
    ld a, HIGH(wShadowOAM)
    call hOAMDMA

    ; Read SCX into $FF43
    ld a, [SCX]
    ld [rSCX], a

    ; Read SCY into $FF43
    ld a, [SCY]
    ld [rSCY], a

    pop hl
    pop de
    pop bc
    pop af
    reti

; ---------------------------------------
; Main - This is where the program starts
; ---------------------------------------
main:
    ; Set WRAM
    ld a, $00
    ld [YOffset], a
    ld [YOffset+1], a
    ld [XOffset], a
    ld [XOffset+1], a
    ld [mapX], a
    ld [mapX+1], a
    ld [maxX], a
    ld [maxX+1], a
    ld [memX], a
    ld [memX+1], a
    ld [pixX], a
    ld [pixX+1], a
    ld [drawOffset], a
    ld [universalCounter], a
    ld [joypadState], a
    ld [joypadPressed], a
    ld [SCX], a
    ld [SCY], a

    ; Initialize all sprite structs
    call InitStructs

    ; Turn off the LCD
    call disableLCD

    ; Load the tileset into the registers and move to VRAM
    call copyGrassyTiles

    ; Load the sprite tileset into the registers and move to VRAM
    call copySpriteTiles

    ; Load the tilemap into the registers and move to VRAM
    call copyNewHillExtMap

    ; Load the palette
    call loadPalette
    
    ; Initilize Sprite Object Library.
    call InitSprObjLib

    ; Reset shadow OAM
    ld d, 0
    ld hl, wShadowOAM
    ld bc, wShadowOAM.end - wShadowOAM
    call memset
    
    ; Move OAM to DMA
    ld a, HIGH(wShadowOAM)
    call hOAMDMA

    ; Reset sprite positions
    call ResetPositions

    ; Enable VBlank interrupt
    ld a, IEF_VBLANK
    ldh [rIE], a
    
    ; Clear pending interrupts
    xor a, a
    ldh [rIF], a

    ; Turn on the LCD
    call enableLCD

    ; Enable interrupts
    ei

    ; Loop the game
    jp gameLoop

; ---------------------------------------------
; gameLoop - This is where the gameLoop happens
; ---------------------------------------------
gameLoop:    
    ; Reset shadow oam
    call ResetShadowOAM

    ; Draw all structs
    call RenderStructs

    ; Move the sprite
    /*ld a, [PlayerSprite_YPos]
    ld h, a 
    ld a, [PlayerSprite_YPos + 1]
    ld l, a 
    ld bc, (1.0 >> 12) & $FFFF
    add hl, bc
    ld a, h
    ld [PlayerSprite_YPos], a
    ld a, l
    ld [PlayerSprite_YPos+1], a*/

    ; Update the joypad
    call updateJoypadState

    ; Move the screen
    REPT 4
    call moveViewPortx1y1
    ENDR
    
    ; Loop
    halt
    jp gameLoop
    
; -----------------------------------------
; Function definitions - Viewport Functions
; -----------------------------------------

; Move the viewport
moveViewPortx1y1:    
    
    call MoveViewRight
    call MoveViewLeft
    call MoveViewDown
    call MoveViewUp

    ; Return to code
    ret

; Move the viewport to the right
MoveViewRight:
    ; Load maxx
    ld a, [maxX]
    ld b, a
    ld a, [maxX + 1]
    ld c, a

    ; load memx but in pixels
    ld a, [pixX]
    ld d, a
    ld a, [pixX + 1]
    ld e, a

    ; Check if pixx == mapx
    
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

    ; Load SCX into a
    ld a, [SCX] ; [SCX] is Viewport X
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
    ld a, [SCX]
    add a, 1
    ld [SCX], a

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

    ; decrement XOffset
    ld a, [XOffset]
    ld h, a
    ld a, [XOffset+1]
    ld l, a
    ld bc, (-1.0 >> 12) & $FFFF
    add hl, bc
    ld a, h
    ld [XOffset], a
    ld a, l
    ld [XOffset+1], a

.rOff
.SkipAllRight:
    ret

; Move the viewport to the left
MoveViewLeft:
    ; Check if zero
    ; Load memx
    ld a, [memX]
    ld b, a
    ld a, [memX + 1]
    ld c, a
    ld a, [SCX]
    or a, b
    or a, c
    jp z, .SkipAllLeft

    ; Move the viewport left
    ld a, [joypadState]
    and a, %00100000
    jp z, .lOff
    ld a, [SCX]
    sub a, 1
    ld [SCX], a

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

    ; increment XOffset
    ld a, [XOffset]
    ld h, a
    ld a, [XOffset+1]
    ld l, a
    ld bc, (1.0 >> 12) & $FFFF
    add hl, bc
    ld a, h
    ld [XOffset], a
    ld a, l
    ld [XOffset+1], a

.lOff

    ; Load SCX into a
    ld a, [SCX] ; [SCX] is Viewport X
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
    ret

; Move the view down
MoveViewDown:
    ld a, [joypadState]
    and a, %10000000
    jp z, .dskip  ; Input
    ld a, [SCY]
    cp a, $70 ; clamp
    jp nc, .dskip  ; clamp
    add a, 1
    ld [SCY], a

    ; decrement YOffset
    ld a, [YOffset]
    ld h, a
    ld a, [YOffset+1]
    ld l, a
    ld bc, (-1.0 >> 12) & $FFFF
    add hl, bc
    ld a, h
    ld [YOffset], a
    ld a, l
    ld [YOffset+1], a

.dskip:  ; clamp
    ret

; Move the view up
MoveViewUp:
    ld a, [joypadState]
    and a, %01000000
    jp z, .uskip  ; Input
    ld a, [SCY]
    cp a, $01 ; clamp
    jp c, .uskip ; clamp
    sub a, 1
    ld [SCY], a

    ; increment YOffset
    ld a, [YOffset]
    ld h, a
    ld a, [YOffset+1]
    ld l, a
    ld bc, (1.0 >> 12) & $FFFF
    add hl, bc
    ld a, h
    ld [YOffset], a
    ld a, l
    ld [YOffset+1], a
    
.uskip: ; clamp
    ret

; Get top and to the right
getNextColumnRight:

    ; Load memX into BC
    ld a, [memX]
    ld b, a
    ld a, [memX + 1]
    ld c, a

    ; Check if the viewport is 0 
    ld a, [SCX]
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
    ld a, [SCX]
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
    ld a, [SCX]
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
    ;ld b, h
    ;ld c, l
    push hl

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
    ;ld h, b
    ;ld l, c
    pop hl

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
    ld a, LCDCF_BGON | LCDCF_BG8800 | LCDCF_ON | LCDCF_OBJON | LCDCF_OBJ16
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
    jp memcpy
     
; Copy sprite tiles into registers to be loaded
copySpriteTiles:
    ld de, SpriteTiles
    ld hl, $8000
    ld bc, SpriteTiles.end - SpriteTiles ; We set bc to the amount of bytes to copy
    ; Push copied tileset to VRAM
    jp memcpy

; Copy HillSide tile map into registers to be loaded
copyHillSideMap:
    ld de, HillSideTilemap
    ld hl, $9800
    ld bc, HillSideTilemap.end - HillSideTilemap ; We set bc to the amount of bytes to copy
    ; Push copied tilemap to VRAM
    jp memcpy

; Copy HillMiddle tile map into registers to be loaded
copyHillMiddleMap:
    ld de, HillMiddleTilemap
    ld hl, $9800
    ld bc, HillMiddleTilemap.end - HillMiddleTilemap ; We set bc to the amount of bytes to copy
    ; Push copied tilemap to VRAM
    jp memcpy 

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

; ----------------
; Sprite functions
; ----------------

; Reset sprite positions
ResetPositions:
    ; Reset Positions
    ld c, 4
    ld hl, wSimplePosition
    xor a, a
  : ld [hli], a
    dec c
    jr nz, :-
    ret

; Initiailize structs
InitStructs:
    ; Init structs
    ld hl, PlayerSprite_YPos
    ld bc, (40.0 >> 12) & $FFFF
    ld a, b
    ld [hli], a
    ld a, c
    ld [hl], a
    ld hl, PlayerSprite_XPos
    ld bc, (40.0 >> 12) & $FFFF
    ld a, b
    ld [hli], a
    ld a, c
    ld [hl], a
    /*ld hl, PlayerSprite_YOffset
    ld bc, (0.0 >> 12) & $FFFF
    ld a, b
    ld [hli], a
    ld a, c
    ld [hl], a
    ld hl, PlayerSprite_XOffset
    ld bc, (0.0 >> 12) & $FFFF
    ld a, b
    ld [hli], a
    ld a, c
    ld [hl], a*/
    ld hl, PlayerSprite_MetaSprite
    ld bc, PlayerMetasprite
    ld a, b
    ld [hli], a
    ld a, c
    ld [hl], a

    ret

; Render all sprite structs
RenderStructs:
    ; Render Metasprite
    ; Get the sprite address
    ld a, [PlayerSprite_MetaSprite]
    ld b, a
    ld a, [PlayerSprite_MetaSprite + 1]
    ld c, a
    ; Load the address into HL
    ld h, b
    ld l, c
    ; Get the YPos of the sprite
    ld a, [PlayerSprite_YPos]
    ld b, a
    ld a, [PlayerSprite_YPos + 1]
    ld c, a
    ; Save hl
    push hl
    ; Get the YOffset and add to YPos
    ld h, b
    ld l, c
    ld a, [YOffset]
    ld b, a
    ld a, [YOffset + 1]
    ld c, a
    ; Add offset
    add hl, bc
    ; Load new YPos
    ld b, h
    ld c, l
    ; Save bc
    push bc
    ; Get the Xposition
    ld a, [PlayerSprite_XPos]
    ld d, a
    ld a, [PlayerSprite_XPos + 1]
    ld e, a
    ; Get the XOffset and add to XPos
    ld h, d
    ld l, e
    ld a, [XOffset]
    ld d, a
    ld a, [XOffset + 1]
    ld e, a
    ; Add offset
    add hl, de
    ; Load new YPos
    ld d, h
    ld e, l
    ; Load hl and bc
    pop bc
    pop hl
    
    ; Check if the sprite is at FF (exception to rule)
    ; Check if the sprite is off-screen on the x-axis
    ld a, $FF
    cp a, d
    ; Draw if zero
    jp z, .CheckY
    ; Check if the sprite is off-screen on the x-axis
    ld a, $0A
    cp a, d
    ; Jump if zero or carry
    jp z, .skip
    jp c, .skip

.CheckY:
    
    ; Check if the sprite is at FF (exception to rule)
    ; Check if the sprite is off-screen on the x-axis
    ld a, $FF
    cp a, b
    ; Draw if zero
    jp z, .GoAndDraw
    ; Check if the sprite is off-screen on the x-axis
    ld a, $0A
    cp a, b
    ; Jump if zero or carry
    jp z, .skip
    jp c, .skip

.GoAndDraw:

    ; Draw the sprite
    call RenderMetasprite

    ; Skip
.skip:

    ret

; Set memory to value
; @param d - value
; @param hl - destination
; @param bc - counter
; @clobbers a
memset::
.loop:
    ; Copy a byte from ROM to VRAM, and increase hl, de to the next location
    ld a, d
    ld [hli], a

    ; Decrease the amount of bytes we still need to copy and check if the amount left is zero
    dec bc
    ld a, b
    or a, c
    jp nz, .loop
    ; Return to code
    ret

; Copy memory from address memory to value
; @param de - source address
; @param hl - destination
; @param bc - counter
; @clobbers a
memcpy::
.loop:
    ; Copy a byte from ROM to VRAM, and increase hl, de to the next location
    ld a, [de]
    ld [hli], a
    inc de
    ; Decrease the amount of bytes we still need to copy and check if the amount left is zero
    dec bc
    ld a, b
    or a, c
    jp nz, .loop
    ; Return to code
    ret 

SECTION "Graphics", ROM0

; Grassy tile data
GrassyTiles::
    INCBIN "res/GrassyTiles.2bpp"
    .end:

; Sprite tile data
SpriteTiles::
    INCBIN "res/SpriteTiles.2bpp"
    .end: