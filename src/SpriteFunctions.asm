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
    ld hl, PlayerMetaspritePrime
    ld a, h
    ld [altMetaSprite], a
    ld a, l
    ld [altMetaSprite + 1], a
    ld hl, PlayerMetasprite
    ld bc, (0.0 >> 12) & $FFFF
    ld de, (0.0 >> 12) & $FFFF
    call InitSpriteStruct

    /*ld hl, EnemySprite1
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
    call InitSpriteStruct*/
    
    ret

; Init player struct
; @param StructAddress - sprite struct
; @param hl - meta sprite
; @param bc - ypos
; @param de - xpos
; @param altMetaSprite - meta sprite prime
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
    ; Load Dir data
    ld a, 1
    ld [hli], a
    ; Load sprite data
    ld a, [altMetaSprite]
    ld [hli], a
    ld a, [altMetaSprite + 1]
    ld [hli], a

    ret

; Render all sprite structs
RenderStructs::
    ; Player sprite
    ld hl, PlayerSprite
    call ldHLToStructAddress
    call RenderSprite
    /*; Enemy sprite 1
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
    call RenderSprite*/
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
    ; Get the sprite address ----

    ; Get the direction
    inc hl
    inc hl
    inc hl
    inc hl
    inc hl
    inc hl
    inc hl
    inc hl
    inc hl
    inc hl
    ld a, [hl] ; read direction
    dec hl
    dec hl
    dec hl
    dec hl
    dec hl
    dec hl
    dec hl
    dec hl
    dec hl
    dec hl

    ; Check if a is 1 or 0
    ; 0 - Sprite left (Prime)
    ; 1 - Sprite right
    dec a
    jp z, .reg
    
    ; Go to metasprite prime if the dir is 0
    inc hl
    inc hl
    inc hl
    inc hl
    inc hl
    inc hl
    inc hl
    inc hl
    inc hl
    inc hl
    inc hl
    ld a, [hli]
    ld b, a
    ld a, [hli]
    ld c, a
    or a, b
    jp z, .skip
    ; Go back to where we should be
    dec hl
    dec hl
    dec hl
    dec hl
    dec hl
    dec hl
    dec hl
    dec hl
    dec hl
    dec hl
    dec hl
    jp .skipReg

.reg:

    ; Read regular
    ld a, [hli]
    ld b, a
    ld a, [hli]
    ld c, a
    or a, b
    jp z, .skip

.skipReg:

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
applyPlayerVelocity::

    ; Check if velocity is > 0

    ;;; From Eievui:
    ;;; ; position in hl
    ;;; bit 7, h ; bit 15 of hl
    ;;; jr nz, .lessThan0
    ;;; ld a, h
    ;;; or a, l
    ;;; jr nz, .greaterThan0    

    ; Check if the velocity is greater than 0
    ld a, [PlayerSprite_XVel]
    ld h, a
    bit 7, h
    jp nz, .skipRight
    ; If the negative bit is not set, then check if the value is not zero
    ld a, [PlayerSprite_XVel + 1] ; Also, get the rest of the velocity
    ld l, a    
    ; Check if zero
    ld a, h
    or a, l
    jp z, .skipRight

    ; If not zero, then ceiling
    ld a, l
    and a, %00001111
    jp z, .contRight
    ld bc, (1.0 >> 12) & $FFFF
    add hl, bc
    ; Now clear the decimals
    ld a, l
    and a, %11110000
    ld l, a
.contRight:

    ; Save hl
    push hl

    ; Move and collide
    ld a, 0
    ld [cancelYVelocity], a
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
    ; Repeat until velocity is zero in this direction
.loopRight:
    call moveCollideThreePoint
    pop hl
    ld bc, (-1.0 >> 12) & $FFFF
    add hl, bc
    push hl
    ld a, h
    or a, l
    jp nz, .loopRight
    pop hl

.skipRight:

    ; Check if the velocity is less than 0
    ld a, [PlayerSprite_XVel]
    ld h, a
    bit 7, h
    jp z, .skipLeft

    ; Get the rest of the velocity
    ld a, [PlayerSprite_XVel + 1]
    ld l, a

    ; Clear the decimals
    ld a, l
    and a, %11110000
    ld l, a

    ; Save hl
    push hl

    ; Move and collide
    ld a, 0
    ld [cancelYVelocity], a
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
    ; Repeat until velocity is zero in this direction
.loopLeft:
    call moveCollideThreePoint
    pop hl
    ld bc, (1.0 >> 12) & $FFFF
    add hl, bc
    push hl
    ld a, h
    or a, l
    jp nz, .loopLeft
    pop hl

.skipLeft:

    ; Check if the velocity is greater than 0
    ld a, [PlayerSprite_YVel]
    ld h, a
    bit 7, h
    jp nz, .skipDown
    ; If the negative bit is not set, then check if the value is not zero
    ld a, [PlayerSprite_YVel + 1] ; Also, get the rest of the velocity
    ld l, a
    ; Check if zero
    ld a, h
    or a, l
    jp z, .skipDown

    ; If not zero, then ceiling
    ld a, l
    and a, %00001111
    jp z, .contDown
    ld bc, (1.0 >> 12) & $FFFF
    add hl, bc
    ; Now clear the decimals
    ld a, l
    and a, %11110000
    ld l, a
.contDown:

    ; Save hl
    push hl

    ; Move and collide
    ld a, 0
    ld [cancelYVelocity], a
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
    ; Repeat until velocity is zero in this direction
.loopDown:
    call moveCollideTwoPoint
    pop hl
    ld bc, (-1.0 >> 12) & $FFFF
    add hl, bc
    push hl
    ld a, h
    or a, l
    jp nz, .loopDown
    pop hl

.skipDown:

    ; Check if the velocity is less than 0
    ld a, [PlayerSprite_YVel]
    ld h, a
    bit 7, h
    jp z, .skipUp

    ; Get the rest of the velocity
    ld a, [PlayerSprite_YVel + 1]
    ld l, a
    
    ; Clear the decimals
    ld a, l
    and a, %11110000
    ld l, a

    ; Save hl
    push hl

    ; Move and collide
    ld a, 1
    ld [cancelYVelocity], a
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
    ld bc, (-16.0 >> 12) & $FFFF
    ld a, b
    ld [yOffset1], a
    ld a, c
    ld [yOffset1 + 1], a
    ld bc, (-16.0 >> 12) & $FFFF
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
    ; Repeat until velocity is zero in this direction
.loopUp:
    call moveCollideTwoPoint
    pop hl
    ld bc, (1.0 >> 12) & $FFFF
    add hl, bc
    push hl
    ld a, h
    or a, l
    jp nz, .loopUp
    pop hl

.skipUp:
    
    ; Set the focal point of the camera
    call getPlayerFocusPointY
    call getPlayerFocusPointX

    ret
    
; Set velocities based on certain properties - With physics
setPlayerVelocities::

    ; Check joypad right
    ld a, [joypadState]
    and a, %00010000
    jp z, .skipRight

    ld a, 1
    ld [PlayerSprite_Dir], a
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

    ld a, 0
    ld [PlayerSprite_Dir], a
    ; Set velocity to negative one
    ld bc, (-1.0 >> 12) & $FFFF
    ld a, b
    ld [PlayerSprite_XVel], a
    ld a, c
    ld [PlayerSprite_XVel + 1], a

.skipLeft:

    ; Check joypad down
    ;ld a, [joypadState]
    ;and a, %10000000
    ;jp z, .skipDown

    ; Set velocity to positive one
    ld bc, (0.2 >> 12) & $FFFF
    
    ; Test if an addition should happen
    ld a, [PlayerSprite_YVel]
    ld h, a
    ld a, [PlayerSprite_YVel + 1]
    ld l, a
    ; If the subtraction is already negative, we know that hl is under 3 and we can do another sub
    bit 7, h
    jp nz, .doGrav
    ; Do test
    ld de, (-3.0 >> 12) & $FFFF
    add hl, de
    ; If the subtraction went negative, we know that hl is under 3 and we can do another sub
    bit 7, h
    jp z, .skipDown

    ld a, [PlayerSprite_YVel]
    ld h, a
    ld a, [PlayerSprite_YVel + 1]
    ld l, a
.doGrav:
    add hl, bc
    ld a, h
    ld [PlayerSprite_YVel], a
    ld a, l
    ld [PlayerSprite_YVel + 1], a

.skipDown:

    ; Check joypad up
    ld a, [joypadPressed]
    and a, %00000001
    jp z, .skipUp

    ; Check if there is a collision
    ld a, [PlayerSprite + 5]
    ld c, a
    ld a, [PlayerSprite + 4]
    ld b, a
    ld a, [PlayerSprite + 3]
    ld e, a
    ld a, [PlayerSprite + 2]
    ld d, a
    ;ld hl, (1.0 >> 12) & $FFFF
    ;add hl, de
    ;ld e, l
    ;ld d, h
    ; Bit shift BC right - This is a 16 bit number 1st digit - (0000 0000 0000) . (0000) 
    ; So in order to cut off the decimal, we have to bit shift four places to the right
    sra b
    rr c
    sra b
    rr c
    sra b
    rr c
    sra b
    rr c
    ; Bit shift DE right
    sra d
    rr e   
    sra d
    rr e   
    sra d
    rr e   
    sra d
    rr e   
    ; Call collision code
    call CheckCollision
    dec a
    jp z, .doIt

    ; Check if there is a collision
    ld a, [PlayerSprite + 5]
    ld c, a
    ld a, [PlayerSprite + 4]
    ld b, a
    ld a, [PlayerSprite + 3]
    ld e, a
    ld a, [PlayerSprite + 2]
    ld d, a
    ;ld hl, (1.0 >> 12) & $FFFF
    ;add hl, de
    ;ld e, l
    ;ld d, h
    ; Bit shift BC right - This is a 16 bit number 1st digit - (0000 0000 0000) . (0000) 
    ; So in order to cut off the decimal, we have to bit shift four places to the right
    sra b
    rr c
    sra b
    rr c
    sra b
    rr c
    sra b
    rr c
    ; Bit shift DE right
    sra d
    rr e   
    sra d
    rr e   
    sra d
    rr e   
    sra d
    rr e   
    ; Add to get the bottom right corner
    inc bc
    inc bc
    inc bc
    ; Call collision code
    call CheckCollision
    dec a
    jp z, .doIt

    ; Check if there is a collision
    ld a, [PlayerSprite + 5]
    ld c, a
    ld a, [PlayerSprite + 4]
    ld b, a
    ld a, [PlayerSprite + 3]
    ld e, a
    ld a, [PlayerSprite + 2]
    ld d, a
    ;ld hl, (1.0 >> 12) & $FFFF
    ;add hl, de
    ;ld e, l
    ;ld d, h
    ; Bit shift BC right - This is a 16 bit number 1st digit - (0000 0000 0000) . (0000) 
    ; So in order to cut off the decimal, we have to bit shift four places to the right
    sra b
    rr c
    sra b
    rr c
    sra b
    rr c
    sra b
    rr c
    ; Bit shift DE right
    sra d
    rr e   
    sra d
    rr e   
    sra d
    rr e   
    sra d
    rr e   
    ; Add to get the bottom right corner
    dec bc
    dec bc
    dec bc
    dec bc
    ; Call collision code
    call CheckCollision
    dec a
    jp z, .doIt
    
    ; If no collision, skip
    jp .skipUp

.doIt:
    ; Set velocity to negative one
    ld bc, (-3.0 >> 12) & $FFFF
    ld a, b
    ld [PlayerSprite_YVel], a
    ld a, c
    ld [PlayerSprite_YVel + 1], a

.skipUp:
    
    call applyPlayerVelocity

    ; Reset velocities
    ld a, 0
    ld [PlayerSprite_XVel], a
    ld [PlayerSprite_XVel + 1], a

    ; Reset gravity    
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
    call resetGravityYVel

    ret


    ; Check collision and if there is collision, then reset YVel



/*
; DELETE FROM THIS POINT -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

; Set velocities based on certain properties - Without physics
setPlayerVelocities::

    ; Check joypad right
    ld a, [joypadState]
    and a, %00010000
    jp z, .skipRight

    ld a, 1
    ld [PlayerSprite_Dir], a
    ;ld de, PlayerSprite_XVel
    ld bc, (1.0 >> 12) & $FFFF
    ld a, b
    ld [PlayerSprite_XVel], a
    ld a, c
    ld [PlayerSprite_XVel + 1], a
    ;call AddToMemory16Bit

.skipRight:

    ; Check joypad left
    ld a, [joypadState]
    and a, %00100000
    jp z, .skipLeft

    ld a, 0
    ld [PlayerSprite_Dir], a
    ;ld de, PlayerSprite_XPos
    ld bc, (-1.0 >> 12) & $FFFF
    ld a, b
    ld [PlayerSprite_XVel], a
    ld a, c
    ld [PlayerSprite_XVel + 1], a
    ;call AddToMemory16Bit

.skipLeft:

    ; Check joypad down
    ld a, [joypadState]
    and a, %10000000
    jp z, .skipDown

    ;ld de, PlayerSprite_YPos
    ld bc, (1.0 >> 12) & $FFFF
    ld a, b
    ld [PlayerSprite_YVel], a
    ld a, c
    ld [PlayerSprite_YVel + 1], a
    ;call AddToMemory16Bit

.skipDown:

    ; Check joypad up
    ld a, [joypadState]
    and a, %01000000
    jp z, .skipUp

    ;ld de, PlayerSprite_YPos
    ld bc, (-1.0 >> 12) & $FFFF
    ld a, b
    ld [PlayerSprite_YVel], a
    ld a, c
    ld [PlayerSprite_YVel + 1], a
    ;call AddToMemory16Bit

.skipUp:

    call applyPlayerVelocity

    ; Reset velocities
    ld a, 0
    ld [PlayerSprite_XVel], a
    ld [PlayerSprite_XVel + 1], a
    ld [PlayerSprite_YVel], a
    ld [PlayerSprite_YVel + 1], a

    call getPlayerFocusPointX
    call getPlayerFocusPointY

    ret


; DELETE TO THIS POINT -----------------------------------------------------------------------------------------------------------------------------------------------------------------------
*/

; Check collision and if there is collision, then reset YVel
; @param xamnt -    16-bit floating point
; @param yamnt -    16-bit floating point
; @param xOffset1 - 16-bit floating point
; @param yOffset1 - 16-bit floating point
; @param xOffset2 - 16-bit floating point
; @param yOffset2 - 16-bit floating point
resetGravityYVel:
    

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
    sra b
    rr c
    sra b
    rr c
    sra b
    rr c
    sra b
    rr c

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
    sra d
    rr e
    sra d
    rr e
    sra d
    rr e
    sra d
    rr e
    
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
    sra b
    rr c
    sra b
    rr c
    sra b
    rr c
    sra b
    rr c

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
    sra d
    rr e
    sra d
    rr e
    sra d
    rr e
    sra d
    rr e
    
    call CheckCollision

    ; Check if a = 1
    cp a, 1
    jp z, .skip

    ; If no collisions occured, then no need to do anything
    jp .end

.skip:
    ; Reset YVel
    ; Every time we access the struct, we need to reload HL if it has been overwritten. Then we need to transform it:
    call ldStructAddressToHL
    ; YVel is at + 6, so we should be able to inc 6 times
    inc hl
    inc hl
    inc hl
    inc hl
    inc hl
    inc hl ; This should be the YVel
    ld a, 0
    ld [hli], a
    ld a, 0
    ld [hl], a

.end:
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
    sra b
    rr c
    sra b
    rr c
    sra b
    rr c
    sra b
    rr c

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
    sra d
    rr e
    sra d
    rr e
    sra d
    rr e
    sra d
    rr e
    
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
    sra b
    rr c
    sra b
    rr c
    sra b
    rr c
    sra b
    rr c

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
    sra d
    rr e
    sra d
    rr e
    sra d
    rr e
    sra d
    rr e
    
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
    sra b
    rr c
    sra b
    rr c
    sra b
    rr c
    sra b
    rr c

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
    sra d
    rr e
    sra d
    rr e
    sra d
    rr e
    sra d
    rr e
    
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


; Check collision and move
; @param cancelYVelocity - 8-bit flag to determine whether we cancel velocity or not
; @param xamnt           - 16-bit floating point
; @param yamnt           - 16-bit floating point
; @param xOffset1        - 16-bit floating point
; @param yOffset1        - 16-bit floating point
; @param xOffset2        - 16-bit floating point
; @param yOffset2        - 16-bit floating point
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
    sra b
    rr c
    sra b
    rr c
    sra b
    rr c
    sra b
    rr c

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
    sra d
    rr e
    sra d
    rr e
    sra d
    rr e
    sra d
    rr e
    
    call CheckCollision

    ; Check if a = 1
    cp a, 1
    jp z, .maybeCancel

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
    sra b
    rr c
    sra b
    rr c
    sra b
    rr c
    sra b
    rr c

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
    sra d
    rr e
    sra d
    rr e
    sra d
    rr e
    sra d
    rr e
    
    call CheckCollision

    ; Check if a = 1
    cp a, 1
    jp z, .maybeCancel

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
    jp .skip

.maybeCancel:
    ld a, [cancelYVelocity] ; Get cancel yes or no
    dec a
    ; If zero, stop flag is on. If stop flag is on, then we should reset the yvel, otherwise, skip 
    jp nz, .skip
    
    ; Reset player speed
    ld a, 0
    ld [PlayerSprite_YVel], a 
    ld [PlayerSprite_YVel + 1], a 

.skip:
    ret

/*; Focus on the player
getPlayerFocusPointY:
    
    ld a, [PlayerSprite_YPos]
    ld h, a
    ld a, [PlayerSprite_YPos + 1]
    ld l, a
    sra h
    rr l
    sra h
    rr l
    sra h
    rr l
    sra h
    rr l
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
    sra h
    rr l
    sra h
    rr l
    sra h
    rr l
    sra h
    rr l
    ld a, l
    jp .skip
.setZero:
    ld a, 0
.skip:
    ld [viewTargetY], a

    ret*/

    

; Focus on the player
getPlayerFocusPointY:
    
    ld a, [PlayerSprite_YPos]
    ld h, a
    ld a, [PlayerSprite_YPos + 1]
    ld l, a
    sra h
    rr l
    sra h
    rr l
    sra h
    rr l
    sra h
    rr l
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
    ld a, [PlayerSprite_YPos]
    ld h, a
    ld a, [PlayerSprite_YPos + 1]
    ld l, a
    ld bc, (-80.0 >> 12) & $FFFF
    add hl, bc
    sra h
    rr l
    sra h
    rr l
    sra h
    rr l
    sra h
    rr l
    jp .skip
.setZero:
    ld a, 0
    ld h, a
    ld a, 0
    ld l, a
.skip:
    ld a, h
    ld [viewTargetY], a
    ld a, l
    ld [viewTargetY + 1], a

    ret

; Focus on the player
getPlayerFocusPointX:
    
    ld a, [PlayerSprite_XPos]
    ld h, a
    ld a, [PlayerSprite_XPos + 1]
    ld l, a
    sra h
    rr l
    sra h
    rr l
    sra h
    rr l
    sra h
    rr l
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
    sra h
    rr l
    sra h
    rr l
    sra h
    rr l
    sra h
    rr l
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