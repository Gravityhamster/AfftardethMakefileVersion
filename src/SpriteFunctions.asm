INCLUDE "hardware.inc"

SECTION "Sprite Functions", ROM0
; ----------------
; Sprite functions
; ----------------

; Reset sprite positions
ResetPositions::
    ; Reset Positions
    ld c, 4
    ld hl, wSimplePosition
    xor a, a
  : ld [hli], a
    dec c
    jr nz, :-
    ret

; Initiailize structs
InitStructs::
    ; Init structs
    call InitPlayerStruct
    ret

; Init player struct
InitPlayerStruct::
    ; Load Y position
    ld hl, PlayerSprite_YPos
    ld bc, (40.0 >> 12) & $FFFF
    ld a, b
    ld [hli], a
    ld a, c
    ld [hl], a
    ; Load X position
    ld hl, PlayerSprite_XPos
    ld bc, (40.0 >> 12) & $FFFF
    ld a, b
    ld [hli], a
    ld a, c
    ld [hl], a
    ; Load sprite
    ld hl, PlayerSprite_MetaSprite
    ld bc, PlayerMetasprite
    ld a, b
    ld [hli], a
    ld a, c
    ld [hl], a

    ret

; Render all sprite structs
RenderStructs::
    call RenderPlayer
    ret

; Render player sprite
; Render Metasprite
RenderPlayer::
    ; Get the sprite address
    ld a, [PlayerSprite_MetaSprite]
    ld b, a
    ld a, [PlayerSprite_MetaSprite + 1]
    ld c, a
    or a, b
    jp z, .skip
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