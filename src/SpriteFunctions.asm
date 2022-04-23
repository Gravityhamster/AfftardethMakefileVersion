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
    ; Load YVel data
    ld a, 0
    ld [hli], a
    ld [hli], a
    ; Load XVel data
    ld [hli], a
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

    ; Move and collide
    ld bc, (4.0 >> 12) & $FFFF
    ld a, b
    ld [xOffset1], a
    ld a, c
    ld [xOffset1 + 1], a
    ld bc, (4.0 >> 12) & $FFFF
    ld a, b
    ld [xOffset2], a
    ld a, c
    ld [xOffset2 + 1], a
    ld bc, (4.0 >> 12) & $FFFF
    ld a, b
    ld [xOffset3], a
    ld a, c
    ld [xOffset3 + 1], a
    ld bc, (-1.0 >> 12) & $FFFF
    ld a, b
    ld [yOffset1], a
    ld a, c
    ld [yOffset1 + 1], a
    ld bc, (-7.0 >> 12) & $FFFF
    ld a, b
    ld [yOffset2], a
    ld a, c
    ld [yOffset2 + 1], a
    ld bc, (-15.0 >> 12) & $FFFF
    ld a, b
    ld [yOffset3], a
    ld a, c
    ld [yOffset3 + 1], a
    ld bc, (1.0 >> 12) & $FFFF
    ld a, b
    ld [xamnt], a
    ld a, c
    ld [xamnt + 1], a
    ld bc, (0.0 >> 12) & $FFFF
    ld a, b
    ld [yamnt], a
    ld a, c
    ld [yamnt + 1], a
    ld hl, PlayerSprite
    call ldHLToStructAddress
    call moveCollideThreePoint

.skipRight:

    ; Check joypad left
    ld a, [joypadState]
    and a, %00100000
    jp z, .skipLeft

    ; Move and collide
    ld bc, (-5.0 >> 12) & $FFFF
    ld a, b
    ld [xOffset1], a
    ld a, c
    ld [xOffset1 + 1], a
    ld bc, (-5.0 >> 12) & $FFFF
    ld a, b
    ld [xOffset2], a
    ld a, c
    ld [xOffset2 + 1], a
    ld bc, (-5.0 >> 12) & $FFFF
    ld a, b
    ld [xOffset3], a
    ld a, c
    ld [xOffset3 + 1], a
    ld bc, (-1.0 >> 12) & $FFFF
    ld a, b
    ld [yOffset1], a
    ld a, c
    ld [yOffset1 + 1], a
    ld bc, (-7.0 >> 12) & $FFFF
    ld a, b
    ld [yOffset2], a
    ld a, c
    ld [yOffset2 + 1], a
    ld bc, (-15.0 >> 12) & $FFFF
    ld a, b
    ld [yOffset3], a
    ld a, c
    ld [yOffset3 + 1], a
    ld bc, (-1.0 >> 12) & $FFFF
    ld a, b
    ld [xamnt], a
    ld a, c
    ld [xamnt + 1], a
    ld bc, (0.0 >> 12) & $FFFF
    ld a, b
    ld [yamnt], a
    ld a, c
    ld [yamnt + 1], a
    ld hl, PlayerSprite
    call ldHLToStructAddress
    call moveCollideThreePoint

.skipLeft:

    ; Check joypad down
    ld a, [joypadState]
    and a, %10000000
    jp z, .skipDown    

    ; Move and collide
    ld bc, (-4.0 >> 12) & $FFFF
    ld a, b
    ld [xOffset1], a
    ld a, c
    ld [xOffset1 + 1], a
    ld bc, (3.0 >> 12) & $FFFF
    ld a, b
    ld [xOffset2], a
    ld a, c
    ld [xOffset2 + 1], a
    ld bc, (0.0 >> 12) & $FFFF
    ld a, b
    ld [yOffset1], a
    ld a, c
    ld [yOffset1 + 1], a
    ld bc, (0.0 >> 12) & $FFFF
    ld a, b
    ld [yOffset2], a
    ld a, c
    ld [yOffset2 + 1], a
    ld bc, (0.0 >> 12) & $FFFF
    ld a, b
    ld [xamnt], a
    ld a, c
    ld [xamnt + 1], a
    ld bc, (1.0 >> 12) & $FFFF
    ld a, b
    ld [yamnt], a
    ld a, c
    ld [yamnt + 1], a
    ld hl, PlayerSprite
    call ldHLToStructAddress
    call moveCollideTwoPoint

.skipDown:

    ; Check joypad up
    ld a, [joypadState]
    and a, %01000000
    jp z, .skipUp

    ; Move and collide
    ld bc, (-4.0 >> 12) & $FFFF
    ld a, b
    ld [xOffset1], a
    ld a, c
    ld [xOffset1 + 1], a
    ld bc, (3.0 >> 12) & $FFFF
    ld a, b
    ld [xOffset2], a
    ld a, c
    ld [xOffset2 + 1], a
    ld bc, (-15.0 >> 12) & $FFFF
    ld a, b
    ld [yOffset1], a
    ld a, c
    ld [yOffset1 + 1], a
    ld bc, (-15.0 >> 12) & $FFFF
    ld a, b
    ld [yOffset2], a
    ld a, c
    ld [yOffset2 + 1], a
    ld bc, (0.0 >> 12) & $FFFF
    ld a, b
    ld [xamnt], a
    ld a, c
    ld [xamnt + 1], a
    ld bc, (-1.0 >> 12) & $FFFF
    ld a, b
    ld [yamnt], a
    ld a, c
    ld [yamnt + 1], a
    ld hl, PlayerSprite
    call ldHLToStructAddress
    call moveCollideTwoPoint

.skipUp:
    
    ; Set the focal point of the camera
    call getPlayerFocusPointY
    call getPlayerFocusPointX

    ret
    
; Set velocities based on certain properties
setPlayerVelocities::

    ; Check joypad right
    ld a, [joypadState]
    and a, %00010000
    jp z, .skipRight

    ; Set velocity to positive one
    ld bc, (1.0 >> 12) & $FFFF
    ld a, b
    ld [PlayerSprite_XVel], a
    ld a, c
    ld [PlayerSprite_XVel + 1], a

.skipRight:

    ; Check joypad left
    ld a, [joypadState]
    and a, %00100000
    jp z, .skipLeft

    ; Set velocity to negative one
    ld bc, (-1.0 >> 12) & $FFFF
    ld a, b
    ld [PlayerSprite_XVel], a
    ld a, c
    ld [PlayerSprite_XVel + 1], a

.skipLeft:

    ; Check joypad down
    ld a, [joypadState]
    and a, %10000000
    jp z, .skipDown

    ; Set velocity to positive one
    ld bc, (1.0 >> 12) & $FFFF
    ld a, b
    ld [PlayerSprite_YVel], a
    ld a, c
    ld [PlayerSprite_YVel + 1], a

.skipDown:

    ; Check joypad up
    ld a, [joypadState]
    and a, %01000000
    jp z, .skipUp

    ; Set velocity to negative one
    ld bc, (-1.0 >> 12) & $FFFF
    ld a, b
    ld [PlayerSprite_YVel], a
    ld a, c
    ld [PlayerSprite_YVel + 1], a

.skipUp:
    
    ;; Set the focal point of the camera
    ;call getPlayerFocusPointY
    ;call getPlayerFocusPointX

    ; Reset velocities
    ld a, 0
    ld [PlayerSprite_XVel], a
    ld [PlayerSprite_XVel + 1], a
    ld [PlayerSprite_YVel], a
    ld [PlayerSprite_YVel + 1], a

    ret

; Check collision and move left
; @param xamnt -    16-bit floating point
; @param yamnt -    16-bit floating point
; @param xOffset1 - 16-bit floating point
; @param yOffset1 - 16-bit floating point
; @param xOffset2 - 16-bit floating point
; @param yOffset2 - 16-bit floating point
; @param xOffset3 - 16-bit floating point
; @param yOffset3 - 16-bit floating point
; @param structAddress
moveCollideThreePoint:

    ; Get the address of the current structure
    ; Load the StructAddress into HL
    ; StructAddress + 0 - MetaSprite Byte 1
    ; StructAddress + 1 - MetaSprite Byte 2
    ; StructAddress + 2 - YPos Byte 1
    ; StructAddress + 3 - YPos Byte 2
    ; StructAddress + 4 - XPos Byte 1
    ; StructAddress + 5 - XPos Byte 2
    call ldStructAddressToHL
    ; When we first load the struct address it points to the first byte of the metasprite. Incrementing it *should* go through the different parts of the struct
    inc hl
    inc hl
    inc hl
    inc hl ; Since StructAddress + 0 = MetaSprite Byte 1, this should be the first byte of the XPos because it is StructAddress (HL) + 4

    ; Check a collision point to the right
    ld a, [hli] ; We increment to move to the next byte after reading the address value
    ld b, a
    ld a, [hl] ; We don't need to increment this time. 
    ld c, a
    ; Pixel offset for right collision point
    ; ld hl, (-5.0 >> 12) & $FFFF 
    ld a, [xOffset1]
    ld h, a
    ld a, [xOffset1 + 1]
    ld l, a
    add hl, bc
    ld b, h 
    ld c, l
    call BitshiftBC
    call BitshiftBC
    call BitshiftBC
    call BitshiftBC

    ; Every time we access the struct, we need to reload HL if it has been overwritten. Then we need to transform it:
    call ldStructAddressToHL
    ; YPos is at + 2, so we should be able to inc twice
    inc hl
    inc hl ; This should be the YPos

    ld a, [hli] ; We need to increment in order to get to the next byte
    ld d, a
    ld a, [hl] 
    ld e, a
    ; Pixel offset for right collision point
    ; ld hl, (-1.0 >> 12) & $FFFF 
    ld a, [yOffset1]
    ld h, a
    ld a, [yOffset1 + 1]
    ld l, a
    add hl, de
    ld d, h 
    ld e, l
    call BitshiftDE
    call BitshiftDE
    call BitshiftDE
    call BitshiftDE
    
    call CheckCollision

    ; Check if a = 1
    cp a, 1
    jp z, .skip

    ; Every time we access the struct, we need to reload HL if it has been overwritten. Then we need to transform it:
    call ldStructAddressToHL
    ; XPos is at + 4, so we should be able to inc four times
    inc hl
    inc hl
    inc hl
    inc hl ; This should be the XPos

    ; Check a collision point to the left
    ld a, [hli] ; Inc to get second byte
    ld b, a
    ld a, [hl]
    ld c, a
    ; Pixel offset for left collision point
    ; ld hl, (-5.0 >> 12) & $FFFF 
    ld a, [xOffset2]
    ld h, a
    ld a, [xOffset2 + 1]
    ld l, a
    add hl, bc
    ld b, h 
    ld c, l
    call BitshiftBC
    call BitshiftBC
    call BitshiftBC
    call BitshiftBC

    ; Every time we access the struct, we need to reload HL if it has been overwritten. Then we need to transform it:
    call ldStructAddressToHL
    ; YPos is at + 2, so we should be able to inc twice
    inc hl
    inc hl ; This should be the YPos

    ld a, [hli] ; Inc to next byte
    ld d, a
    ld a, [hl]
    ld e, a
    ; Pixel offset for right collision point
    ; ld hl, (-15.0 >> 12) & $FFFF 
    ld a, [yOffset2]
    ld h, a
    ld a, [yOffset2 + 1]
    ld l, a
    add hl, de
    ld d, h 
    ld e, l
    call BitshiftDE
    call BitshiftDE
    call BitshiftDE
    call BitshiftDE
    
    call CheckCollision

    ; Check if a = 1
    cp a, 1
    jp z, .skip

    ; Every time we access the struct, we need to reload HL if it has been overwritten. Then we need to transform it:
    call ldStructAddressToHL
    ; XPos is at + 4, so we should be able to inc four times
    inc hl
    inc hl
    inc hl
    inc hl ; This should be the XPos
    
    ; Check a collision point to the left
    ld a, [hli]
    ld b, a
    ld a, [hl]
    ld c, a
    ; Pixel offset for left collision point
    ; ld hl, (-5.0 >> 12) & $FFFF 
    ld a, [xOffset3]
    ld h, a
    ld a, [xOffset3 + 1]
    ld l, a
    add hl, bc
    ld b, h 
    ld c, l
    call BitshiftBC
    call BitshiftBC
    call BitshiftBC
    call BitshiftBC

    ; Load hl
    ld a, [PlayerSprite_YPos] ; YPos + 1
    ld d, a
    ld a, [PlayerSprite_YPos + 1] ; YPos + 1
    ld e, a
    ; Pixel offset for right collision point
    ; ld hl, (-7.0 >> 12) & $FFFF 
    ld a, [yOffset3]
    ld h, a
    ld a, [yOffset3 + 1]
    ld l, a
    add hl, de
    ld d, h 
    ld e, l
    call BitshiftDE
    call BitshiftDE
    call BitshiftDE
    call BitshiftDE
    
    call CheckCollision

    ; Check if a = 1
    cp a, 1
    jp z, .skip

    ; Every time we access the struct, we need to reload HL if it has been overwritten. Then we need to transform it:
    call ldStructAddressToHL
    ; XPos is at + 4, so we should be able to inc 4 times
    inc hl
    inc hl
    inc hl
    inc hl ; This should be the XPos

    ; Load params and move sprite
    ld d, h
    ld e, l
    ; ld bc, (-1.0 >> 12) & $FFFF
    ld a, [xamnt]
    ld b, a
    ld a, [xamnt + 1]
    ld c, a
    call AddToMemory16Bit

    ; Every time we access the struct, we need to reload HL if it has been overwritten. Then we need to transform it:
    call ldStructAddressToHL
    ; YPos is at + 2, so we should be able to inc twice
    inc hl
    inc hl ; This should be the YPos
    
    ; Load params and move sprite
    ld d, h
    ld e, l
    ; ld bc, (-1.0 >> 12) & $FFFF
    ld a, [yamnt]
    ld b, a
    ld a, [yamnt + 1]
    ld c, a
    call AddToMemory16Bit

.skip:
    ret


; Check collision and move left
; @param xamnt -    16-bit floating point
; @param yamnt -    16-bit floating point
; @param xOffset1 - 16-bit floating point
; @param yOffset1 - 16-bit floating point
; @param xOffset2 - 16-bit floating point
; @param yOffset2 - 16-bit floating point
moveCollideTwoPoint:

    ; Get the address of the current structure
    ; Load the StructAddress into HL
    ; StructAddress + 0 - MetaSprite Byte 1
    ; StructAddress + 1 - MetaSprite Byte 2
    ; StructAddress + 2 - YPos Byte 1
    ; StructAddress + 3 - YPos Byte 2
    ; StructAddress + 4 - XPos Byte 1
    ; StructAddress + 5 - XPos Byte 2
    call ldStructAddressToHL
    ; When we first load the struct address it points to the first byte of the metasprite. Incrementing it *should* go through the different parts of the struct
    inc hl
    inc hl
    inc hl
    inc hl ; Since StructAddress + 0 = MetaSprite Byte 1, this should be the first byte of the XPos because it is StructAddress (HL) + 4

    ; Check a collision point to the right
    ld a, [hli] ; We increment to move to the next byte after reading the address value
    ld b, a
    ld a, [hl] ; We don't need to increment this time. 
    ld c, a
    ; Pixel offset for right collision point
    ; ld hl, (-5.0 >> 12) & $FFFF 
    ld a, [xOffset1]
    ld h, a
    ld a, [xOffset1 + 1]
    ld l, a
    add hl, bc
    ld b, h 
    ld c, l
    call BitshiftBC
    call BitshiftBC
    call BitshiftBC
    call BitshiftBC

    ; Every time we access the struct, we need to reload HL if it has been overwritten. Then we need to transform it:
    call ldStructAddressToHL
    ; YPos is at + 2, so we should be able to inc twice
    inc hl
    inc hl ; This should be the YPos

    ld a, [hli] ; We need to increment in order to get to the next byte
    ld d, a
    ld a, [hl] 
    ld e, a
    ; Pixel offset for right collision point
    ; ld hl, (-1.0 >> 12) & $FFFF 
    ld a, [yOffset1]
    ld h, a
    ld a, [yOffset1 + 1]
    ld l, a
    add hl, de
    ld d, h 
    ld e, l
    call BitshiftDE
    call BitshiftDE
    call BitshiftDE
    call BitshiftDE
    
    call CheckCollision

    ; Check if a = 1
    cp a, 1
    jp z, .skip

    ; Every time we access the struct, we need to reload HL if it has been overwritten. Then we need to transform it:
    call ldStructAddressToHL
    ; XPos is at + 4, so we should be able to inc four times
    inc hl
    inc hl
    inc hl
    inc hl ; This should be the XPos

    ; Check a collision point to the left
    ld a, [hli] ; Inc to get second byte
    ld b, a
    ld a, [hl]
    ld c, a
    ; Pixel offset for left collision point
    ; ld hl, (-5.0 >> 12) & $FFFF 
    ld a, [xOffset2]
    ld h, a
    ld a, [xOffset2 + 1]
    ld l, a
    add hl, bc
    ld b, h 
    ld c, l
    call BitshiftBC
    call BitshiftBC
    call BitshiftBC
    call BitshiftBC

    ; Every time we access the struct, we need to reload HL if it has been overwritten. Then we need to transform it:
    call ldStructAddressToHL
    ; YPos is at + 2, so we should be able to inc twice
    inc hl
    inc hl ; This should be the YPos

    ld a, [hli] ; Inc to next byte
    ld d, a
    ld a, [hl]
    ld e, a
    ; Pixel offset for right collision point
    ; ld hl, (-15.0 >> 12) & $FFFF 
    ld a, [yOffset2]
    ld h, a
    ld a, [yOffset2 + 1]
    ld l, a
    add hl, de
    ld d, h 
    ld e, l
    call BitshiftDE
    call BitshiftDE
    call BitshiftDE
    call BitshiftDE
    
    call CheckCollision

    ; Check if a = 1
    cp a, 1
    jp z, .skip

    ; Every time we access the struct, we need to reload HL if it has been overwritten. Then we need to transform it:
    call ldStructAddressToHL
    ; XPos is at + 4, so we should be able to inc 4 times
    inc hl
    inc hl
    inc hl
    inc hl ; This should be the XPos

    ; Load params and move sprite
    ld d, h
    ld e, l
    ; ld bc, (-1.0 >> 12) & $FFFF
    ld a, [xamnt]
    ld b, a
    ld a, [xamnt + 1]
    ld c, a
    call AddToMemory16Bit

    ; Every time we access the struct, we need to reload HL if it has been overwritten. Then we need to transform it:
    call ldStructAddressToHL
    ; YPos is at + 2, so we should be able to inc twice
    inc hl
    inc hl ; This should be the YPos
    
    ; Load params and move sprite
    ld d, h
    ld e, l
    ; ld bc, (-1.0 >> 12) & $FFFF
    ld a, [yamnt]
    ld b, a
    ld a, [yamnt + 1]
    ld c, a
    call AddToMemory16Bit

.skip:
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