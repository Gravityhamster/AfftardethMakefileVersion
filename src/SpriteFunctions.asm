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
    ld bc, (0.0 >> 12) & $FFFF
    ld a, b
    ld [hli], a
    ld a, c
    ld [hl], a
    ; Load X position
    ld hl, PlayerSprite_XPos
    ld bc, (0.0 >> 12) & $FFFF
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
    ld a, $0B
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

; Add to memory location
; @param de - memory reference
; @param bc - amount to move by (Q12.4)
; ---
; Move sprite example:
; ld de, PlayerSprite_XPos
; ld bc, (1.0 >> 12) & $FFFF
; call AddToMemory16Bit
AddToMemory16Bit::
    ; Get input variable
    ld a, [de]
    ld h, a
    inc de
    ld a, [de]
    ld l, a
    dec de
    ; Add BC param to HL
    add hl, bc
    ; Load back to input variable
    ld a, h
    ld [de], a
    inc de
    ld a, l
    ld [de], a
    ; Return
    ret

; Control the player
controlPlayer::
    ; Check joypad right
    ld a, [joypadState]
    and a, %00010000
    jp z, .skipRight
    ; Load params and move sprite
    ld de, PlayerSprite_XPos
    ld bc, (1.0 >> 12) & $FFFF
    call AddToMemory16Bit

    ; Move the target right
    ;ld a, [viewTargetX]
    ;ld b, a
    ;ld a, [viewTargetX + 1]
    ;ld c, a
    ;inc bc
    ;ld a, b
    ;ld [viewTargetX], a
    ;ld a, c
    ;ld [viewTargetX + 1], a

.skipRight:

    ; Check joypad left
    ld a, [joypadState]
    and a, %00100000
    jp z, .skipLeft
    ; Load params and move sprite
    ld de, PlayerSprite_XPos
    ld bc, (-1.0 >> 12) & $FFFF
    call AddToMemory16Bit

    ; Move the target left
    ;ld a, [viewTargetX]
    ;ld b, a
    ;ld a, [viewTargetX + 1]
    ;ld c, a
    ;dec bc
    ;ld a, b
    ;ld [viewTargetX], a
    ;ld a, c
    ;ld [viewTargetX + 1], a

.skipLeft:

    ; Check joypad down
    ld a, [joypadState]
    and a, %10000000
    jp z, .skipDown
    ; Load params and move sprite
    ld de, PlayerSprite_YPos
    ld bc, (1.0 >> 12) & $FFFF
    call AddToMemory16Bit

    ;; Move the target down
    ;ld a, [viewTargetY]
    ;inc a
    ;ld [viewTargetY], a

.skipDown:

    ; Check joypad up
    ld a, [joypadState]
    and a, %01000000
    jp z, .skipUp
    ; Load params and move sprite
    ld de, PlayerSprite_YPos
    ld bc, (-1.0 >> 12) & $FFFF
    call AddToMemory16Bit
    
    ;; Move the target down
    ;ld a, [viewTargetY]
    ;dec a
    ;ld [viewTargetY], a

.skipUp:

    ret