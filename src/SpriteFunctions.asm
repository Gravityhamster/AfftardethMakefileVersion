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
    ld hl, PlayerSprite
    call ldHLToStructAddress
    ld hl, PlayerMetasprite
    ld bc, (0.0 >> 12) & $FFFF
    ld de, (0.0 >> 12) & $FFFF
    call InitSpriteStruct
    ld hl, EnemySprite1
    call ldHLToStructAddress
    ld hl, EnemyMetasprite
    ld bc, (10.0 >> 12) & $FFFF
    ld de, (10.0 >> 12) & $FFFF
    call InitSpriteStruct
    ld hl, EnemySprite2
    call ldHLToStructAddress
    ld hl, EnemyMetasprite
    ld bc, (20.0 >> 12) & $FFFF
    ld de, (20.0 >> 12) & $FFFF
    call InitSpriteStruct
    ld hl, EnemySprite3
    call ldHLToStructAddress
    ld hl, EnemyMetasprite
    ld bc, (30.0 >> 12) & $FFFF
    ld de, (30.0 >> 12) & $FFFF
    call InitSpriteStruct
    ret

; Init player struct
; @param StructAddress - sprite struct
; @param hl - meta sprite
; @param bc - ypos
; @param de - xpos
InitSpriteStruct::
    ; Save params
    push de ; xpos
    push bc ; ypos
    push hl ; meta sprite
    ; Load sprite
    call ldStructAddressToHL
    ; Get sprite data
    pop bc
    ; Load sprite data
    ld a, b
    ld [hli], a
    ld a, c
    ld [hli], a
    ; Get ypos data
    pop bc
    ; Load ypos data
    ld a, b
    ld [hli], a
    ld a, c
    ld [hli], a
    ; Get xpos data
    pop bc
    ; Load xpos data
    ld a, b
    ld [hli], a
    ld a, c
    ld [hli], a

    ret

; Render all sprite structs
RenderStructs::
    ; Player sprite
    ld hl, PlayerSprite
    call ldHLToStructAddress
    call RenderSprite
    ; Enemy sprite 1
    ld hl, EnemySprite1
    call ldHLToStructAddress
    call RenderSprite
    ; Enemy sprite 2
    ld hl, EnemySprite2
    call ldHLToStructAddress
    call RenderSprite
    ; Enemy sprite 3
    ld hl, EnemySprite3
    call ldHLToStructAddress
    call RenderSprite
    ret

; Load Address into Register HL
ldStructAddressToHL::
    ld a, [structAddress]
    ld h, a
    ld a, [structAddress + 1]
    ld l, a
    ret

; Load Register HL into Address
ldHLToStructAddress::
    ld a, h
    ld [structAddress], a
    ld a, l
    ld [structAddress + 1], a
    ret

; Render sprite
; Render Metasprite
; @param structAddress
RenderSprite::
    ; Get the sprite address
    ld a, [hli]
    ld b, a
    ld a, [hli]
    ld c, a
    or a, b
    jp z, .skip
    ; Load HL back to the struct address
    call ldHLToStructAddress
    ; Load the address into HL
    ld h, b
    ld l, c
    ; Save hl
    push hl
    ; Get the struct address
    call ldStructAddressToHL
    ; Get the YPos of the sprite
    ld a, [hli]
    ld b, a
    ld a, [hli]
    ld c, a
    ; Load HL back to the struct address
    call ldHLToStructAddress
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
    ; Get the struct address
    call ldStructAddressToHL
    ; Get the Xposition
    ld a, [hli]
    ld d, a
    ld a, [hl]
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

.skipRight:

    ; Check joypad left
    ld a, [joypadState]
    and a, %00100000
    jp z, .skipLeft
    ; Load params and move sprite
    ld de, PlayerSprite_XPos
    ld bc, (-1.0 >> 12) & $FFFF
    call AddToMemory16Bit

.skipLeft:

    ; Check joypad down
    ld a, [joypadState]
    and a, %10000000
    jp z, .skipDown
    ; Load params and move sprite
    ld de, PlayerSprite_YPos
    ld bc, (1.0 >> 12) & $FFFF
    call AddToMemory16Bit

.skipDown:

    ; Check joypad up
    ld a, [joypadState]
    and a, %01000000
    jp z, .skipUp
    ; Load params and move sprite
    ld de, PlayerSprite_YPos
    ld bc, (-1.0 >> 12) & $FFFF
    call AddToMemory16Bit

.skipUp:
    
    ; Set the focal point of the camera
    call getPlayerFocusPointY
    call getPlayerFocusPointX

    ret

; Focus on the player
getPlayerFocusPointY:
    
    ld a, [PlayerSprite_YPos]
    ld h, a
    ld a, [PlayerSprite_YPos + 1]
    ld l, a
    call BitshiftHL
    call BitshiftHL
    call BitshiftHL
    call BitshiftHL
    ; If h is 0F and l is FX, then set 0
    ld a, l
    cp a, $F0
    jp c, .doNotTestH
    ld a, h
    cp a, $0F
    jp z, .setZero
.doNotTestH
    ; If h is zero, then we need to test
    ld a, h
    add a, 0
    jp nz, .skipTest
    ; Test if a - 72 is going to cause a negative
    ld a, l
    cp a, 92
    jp c, .setZero
.skipTest:
    ld a, [PlayerSprite_YPos]
    ld h, a
    ld a, [PlayerSprite_YPos + 1]
    ld l, a
    ld bc, (-92.0 >> 12) & $FFFF
    add hl, bc
    call BitshiftHL
    call BitshiftHL
    call BitshiftHL
    call BitshiftHL
    ld a, l
    jp .skip
.setZero:
    ld a, 0
.skip:
    ld [viewTargetY], a

    ret

; Focus on the player
getPlayerFocusPointX:
    
    ld a, [PlayerSprite_XPos]
    ld h, a
    ld a, [PlayerSprite_XPos + 1]
    ld l, a
    call BitshiftHL
    call BitshiftHL
    call BitshiftHL
    call BitshiftHL
    ; If h is 0F and l is FX, then set 0
    ld a, l
    cp a, $F0
    jp c, .doNotTestH
    ld a, h
    cp a, $0F
    jp z, .setZero
.doNotTestH
    ; If h is zero, then we need to test
    ld a, h
    add a, 0
    jp nz, .skipTest
    ; Test if a - 72 is going to cause a negative
    ld a, l
    cp a, 80
    jp c, .setZero
.skipTest:
    ld a, [PlayerSprite_XPos]
    ld h, a
    ld a, [PlayerSprite_XPos + 1]
    ld l, a
    ld bc, (-80.0 >> 12) & $FFFF
    add hl, bc
    call BitshiftHL
    call BitshiftHL
    call BitshiftHL
    call BitshiftHL
    jp .skip
.setZero:
    ld a, 0
    ld h, a
    ld a, 0
    ld l, a
.skip:
    ld a, h
    ld [viewTargetX], a
    ld a, l
    ld [viewTargetX + 1], a

    ret