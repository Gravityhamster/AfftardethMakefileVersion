; Pre-made hardware interface
INCLUDE "hardware.inc"

SECTION "Viewport Functions", ROM0

; -----------------------------------------
; Function definitions - Viewport Functions
; -----------------------------------------

; Move the viewport
moveViewPortx1y1::
    
    call MoveViewRight
    call MoveViewLeft
    call MoveViewDown
    call MoveViewUp

    ; Return to code
    ret

; Move the viewport to the right
MoveViewRight::
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
    
;    ; Check right joypad
;    ld a, [joypadState]
;    and a, %00010000
    ; Draw column if joypadR
;    call nz, getNextColumnRight
    call getNextColumnRight

    ld a, [SCX]
    ld [prevX], a

.skip1:

;    ld a, [joypadState]
;    and a, %00010000
;    jp z, .rOff
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

;.rOff
.SkipAllRight:
    ret

; Move the viewport to the left
MoveViewLeft::
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
;    ld a, [joypadState]
;    and a, %00100000
;    jp z, .lOff
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

;.lOff

    ; Load SCX into a
    ld a, [SCX] ; [SCX] is Viewport X
    and a, %00000111
    ; Only load a column and increment memX if the viewport is divisible by 8
    jp nz, .skip2 ; Skip the column drawing code if not zero

    ; Check left joypad
;    ld a, [joypadState]
;    and a, %00100000
    ; Draw column if joypadL
    ;call nz, getNextColumnLeft
    call getNextColumnLeft

.skip2:

.SkipAllLeft:
    ret

; Move the view down
MoveViewDown::
;    ld a, [joypadState]
;    and a, %10000000
;    jp z, .dskip  ; Input
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
MoveViewUp::
;    ld a, [joypadState]
;    and a, %01000000
;    jp z, .uskip  ; Input
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
getNextColumnRight::

    ; Get the current tilemap and put in HL
    ld a, [currentTileMap]
    ld h, a
    ld a, [currentTileMap + 1]
    ld l, a
    ld bc, $14
    add hl, bc

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
    ; ld de, HillsMapTilemap + $14
    ld d, h
    ld e, l

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
getNextColumnLeft::

    ; Get the current tilemap and put in HL
    ld a, [currentTileMap]
    ld h, a
    ld a, [currentTileMap + 1]
    ld l, a

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
    ;ld de, HillsMapTilemap
    ld d, h
    ld e, l

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
drawColumn::
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
setTileForColumn::
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
    
; Move to the 
moveViewToFocusPoint::
    ; SCX
    ; SCY

    ; Check if the pixX is greater than the focus point
    ld a, [pixX]
    ld b, a
    ld a, [pixX+1]
    ld c, a
    ld a, [viewTargetX]
    ld h, a
    ld a, [viewTargetX+1]
    ld l, a

    ; Test
    ; bc = current
    ; hl = target
    ; target - current = ?
    ; If the result is 0, skipall
    ; If the result is Carry, then target is left of current and we need to move left
    ; If the result is Not Carry, then the target is right of current and we need to move right
    
    ; First we need to test the higher bits
    ; h - b = ?
    ld a, h
    cp a, b
    ; If the result is zero, then they are equal, but we need to check the lower bits
    jp z, .checkLowerBits
    ; If the result is Carry, then target is left of the current
    jp c, .moveLeft
.moveRight
    call MoveViewRight
    jp .endH
.moveLeft:
    call MoveViewLeft
    jp .endH
.checkLowerBits:
    ; Now we need to test the lower bits
    ; l - c = ?
    ld a, l
    cp a, c
    ; If the result is zero, they are equal and we are done
    jp z, .endH
    ; If the result is Carry, then the target is left of the current
    jp c, .moveLeft
    ; Else, move right
    jp .moveRight
.endH:

    ; Check if the SCX is greater than the focus point
    ld a, [SCY]
    ld b, a
    ld a, [viewTargetY]
    cp a, b
    ; If this is zero, we don't need to do anything
    jp z, .endV
    jp c, .goUp ; If carry, move up
; Go down
    call MoveViewDown
    jp .endV
.goUp:
; Go up
    call MoveViewUp
.endV:
; Do not go

    ret