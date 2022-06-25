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

    ;; Draw all structs
    ;call RenderStructs
    
    ; Push sprites to OAM
    ld a, HIGH(wShadowOAM)
    call hOAMDMA

    ; Read SCX into $FF43
    ld a, [SCX]
    ld [rSCX], a

    ; Read SCY into $FF43
    ld a, [SCY]
    ld [rSCY], a

    ; Load saved registers
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
    ld [prevX], a
    ld [prevY], a
    ld [YOffset], a
    ld [YOffset+1], a
    ld [XOffset], a
    ld [XOffset+1], a
    ld [mapX], a
    ld [mapX+1], a
    ld [mapY], a
    ld [mapY+1], a
    ld [maxX], a
    ld [maxX+1], a
    ld [maxY], a
    ld [maxY+1], a
    ld [memX], a
    ld [memX+1], a
    ld [memY], a
    ld [memY+1], a    
    ld [pixX], a
    ld [pixX+1], a
    ld [pixY], a
    ld [pixY+1], a
    ld [drawOffset], a
    ld [universalCounter], a
    ld [joypadState], a
    ld [joypadPressed], a
    ld [SCX], a
    ld [SCY], a
    ld a, $00
    ld [viewTargetX], a
    ld [viewTargetX+1], a
    ld [viewTargetY], a
    ld [viewTargetY+1], a

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

    ; Update the joypad
    call updateJoypadState

    ; Control the player
    call setPlayerVelocities

    ; Move the screen
    REPT 5
    call moveViewToFocusPoint
    ENDR

    ; Draw all structs
    call RenderStructs

    ; Loop
    halt
    jp gameLoop