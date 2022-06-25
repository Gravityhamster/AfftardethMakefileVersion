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
    ; Load maxyY
    ld a, [maxY]
    ld b, a
    ld a, [maxY + 1]
    ld c, a

    ; load memy but in pixels
    ld a, [pixY]
    ld d, a
    ld a, [pixY + 1]
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

    jp z, .dskip

    ; Load SCY into a
    ld a, [SCY] ; [SCY] is Viewport Y
    and a, %00000111
    ; Only load a row and increment memY if the viewport is divisible by 8
    jp nz, .skip1 ; Skip the column drawing code if not zero
    
    call getNextRowDown

    ld a, [SCY]
    ld [prevY], a

.skip1:

    ; Increment view
    ld a, [SCY]
    add a, 1
    ld [SCY], a

    ; increment pixY
    ld a, [pixY]
    ld b, a
    ld a, [pixY+1]
    ld c, a
    inc bc
    ld a, b
    ld [pixY], a
    ld a, c
    ld [pixY+1], a

    ; increment YOffset
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
   /* ld a, [memY]
    ld b, a
    ld a, [memY + 1]
    ld c, a
    ld a, [SCY]
    or a, b
    or a, c
    ;jp z, .uskip */

    ; decrement pixY
    ld a, [pixY]
    ld b, a
    ld a, [pixY+1]
    ld c, a
    dec bc
    ld a, b
    ld [pixY], a
    ld a, c
    ld [pixY+1], a

    ; Decrement view
    ld a, [SCY]
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
    
    ld a, [rSCX]
    ; Divide by 8
    sra a
    sra a
    sra a
    ; Clear bad sign bits
    and a, %00011111
    ld [SCXS], a
    
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
    
    ld a, [rSCX]
    ; Divide by 8
    sra a
    sra a
    sra a
    ; Clear bad sign bits
    and a, %00011111
    dec a
    ld [SCXS], a
    sub a, $FF
    jp nz, .zz
    ld a, $1F
    ld [SCXS], a

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

; Get bottom and to the left
getNextRowDown::

    /*; Get the current tilemap and put in HL
    ld a, [currentTileMap]
    ld h, a
    ld a, [currentTileMap + 1]
    ld l, a
    ld bc, $240
    add hl, bc*/

    ; Load memY into BC
    ld a, [memY]
    ld b, a
    ld a, [memY + 1]
    ld c, a

    ; Check if the viewport is 0 
    ld a, [SCY]
    or b
    or c
    
    jp z, .skipInc

    ; Increment BC
    inc bc

    ; Reading back BC to memY
    ld a, b
    ld [memY], a
    ld a, c
    ld [memY + 1], a
    
.skipInc:

    ; Setting DE - Source Tile

    ; Load the location into DE
    ld de, HillsMapTilemap
    ; de += mapX * 18 
    ld h, d
    ld l, e
    ld a, [mapX]
    ld d, a
    ld a, [mapX + 1]
    ld e, a
    ld a, 18
.loopShiftDown:
    add hl, de
    dec a
    jp nz, .loopShiftDown
    ld d, h
    ld e, l

    ; Load memY into BC
    ld a, [memY]
    ld b, a
    ld a, [memY + 1]
    ld c, a
    
    ;or b
    ;jp z, .loopSkip

    ; add the width of the map to the source location 
    ; de += mapX * memY + memX    
    ld h, d
    ld l, e
    ld a, [mapX]
    ld d, a
    ld a, [mapX + 1]
    ld e, a
.addLoop:
    ; Check zero
    ld a, b
    or c
    jp z, .loopSkip
    add hl, de
    dec bc
    jp .addLoop

.loopSkip:
    ld a, [memX]
    ld d, a
    ld a, [memX + 1]
    ld e, a
    add hl, de
    ld d, h
    ld e, l

    ; Setting HL - Destination Location

    ; Get screen position
    ld a, [SCY]
    ; Divide by 8
    sra a
    sra a
    sra a
    ; Clear bad sign bits
    and a, %00011111

    ; Set BC to the screen offset: floor ( Screen position / 8 )
    ; Multiply a by 32

    ld b, 0
    ld c, a

    ; BC times 32
    sla c
    rl b
    sla c
    rl b
    sla c
    rl b
    sla c
    rl b
    sla c
    rl b

    inc bc

    ; Set hl to the VRAM address plus the number of tiles across the screen
    ld hl, $9800 + $240

    ; Add the screen offset to the VRAM position
    add hl, bc
    ;ld a, [memX]
    ;ld b, a
    ;ld a, [memX + 1]
    ;ld c, a
    ld a, [SCXS]
    ld b, 0
    ld c, a
    add hl, bc

    ; Only do a wrap if h >= 9C
    ld a, $9C
    sub a, h
    jp z, .doWrap
    jp nc, .skipWrap
.doWrap:
    ; Wrap around screen
    push de
    ld d, $9C
    ld e, $00

    ; Execute hl - $9C00
    ld a, h
    xor a, d
    ld d, a
    ld a, l
    xor a, e
    ld e, a

    ; de is now the remainder of hl - $9C00
    ; So now we can take that remainder add it to $9800
    ld hl, $9800
    add hl, de

    pop de
    ; End wrap
.skipWrap:

    /*ld b, b
    ; Load the current number into A
    ld a, l
    ; Subtract the offset from HL to see if it must be shifted
    sub a, $1

    ; If the subtraction causes overflow, then we know the register is < 32, and we do not need to subtract from it, in which case we jump.
    ; If the subtraction does not cause overflow, then we know the register is >= 32, and we need to subtract from it.
    jp c, .c

    ; Align correctly
    ld a, l
    sub a, $1
    ld l, a

.c:*/

    dec hl

    ; Draw the entire column
    jp drawRow

; Draw row
drawRow:

    ld a, l
    sra a
    sra a
    sra a
    sra a
    ld [lastSecondHex], a

    call setTileForRow
    ; If SCXS - $0C == $14, then HL -= $20
    ld a, [SCXS]
    sub a, $0C
    ; Change this value 
    ;       v
    sub a, $13
    ; And this value
    ;            v
    jp nz, .skip_14
    ld a, $20
    ; Add 256 - A to HL
    cpl
    scf
    adc   a, l
    ld    l, a
    ld    a, -1 ; And subtract 256 here
    adc   a, h
    ld    h, a
    ; And this value
    ; v
.skip_14:
    call setTileForRow
    ; If SCXS - $0C == $13, then HL -= $20
    ld a, [SCXS]
    sub a, $0C
    ; Change this value 
    ;       v
    sub a, $12
    ; And this value
    ;            v
    jp nz, .skip_13
    ld a, $20
    ; Add 256 - A to HL
    cpl
    scf
    adc   a, l
    ld    l, a
    ld    a, -1 ; And subtract 256 here
    adc   a, h
    ld    h, a
    ; And this value
    ; v
.skip_13:
    call setTileForRow
    ; If SCXS - $0C == $12, then HL -= $20
    ld a, [SCXS]
    sub a, $0C
    ; Change this value 
    ;       v
    sub a, $11
    ; And this value
    ;            v
    jp nz, .skip_12
    ld a, $20
    ; Add 256 - A to HL
    cpl
    scf
    adc   a, l
    ld    l, a
    ld    a, -1 ; And subtract 256 here
    adc   a, h
    ld    h, a
    ; And this value
    ; v
.skip_12:
    call setTileForRow
    ; If SCXS - $0C == $11, then HL -= $20
    ld a, [SCXS]
    sub a, $0C
    ; Change this value 
    ;       v
    sub a, $10
    ; And this value
    ;            v
    jp nz, .skip_11
    ld a, $20
    ; Add 256 - A to HL
    cpl
    scf
    adc   a, l
    ld    l, a
    ld    a, -1 ; And subtract 256 here
    adc   a, h
    ld    h, a
    ; And this value
    ; v
.skip_11:
    call setTileForRow
    ; If SCXS - $0C == $10, then HL -= $20
    ld a, [SCXS]
    sub a, $0C
    ; Change this value 
    ;       v
    sub a, $0F
    ; And this value
    ;            v
    jp nz, .skip_10
    ld a, $20
    ; Add 256 - A to HL
    cpl
    scf
    adc   a, l
    ld    l, a
    ld    a, -1 ; And subtract 256 here
    adc   a, h
    ld    h, a
    ; And this value
    ; v
.skip_10:
    call setTileForRow
    ; If SCXS - $0C == $0F, then HL -= $20
    ld a, [SCXS]
    sub a, $0C
    ; Change this value 
    ;       v
    sub a, $0E
    ; And this value
    ;            v
    jp nz, .skip_F
    ld a, $20
    ; Add 256 - A to HL
    cpl
    scf
    adc   a, l
    ld    l, a
    ld    a, -1 ; And subtract 256 here
    adc   a, h
    ld    h, a
    ; And this value
    ; v
.skip_F:
    call setTileForRow
    ; If SCXS - $0C == $0E, then HL -= $20
    ld a, [SCXS]
    sub a, $0C
    ; Change this value 
    ;       v
    sub a, $0D
    ; And this value
    ;            v
    jp nz, .skip_E
    ld a, $20
    ; Add 256 - A to HL
    cpl
    scf
    adc   a, l
    ld    l, a
    ld    a, -1 ; And subtract 256 here
    adc   a, h
    ld    h, a
    ; And this value
    ; v
.skip_E:
    call setTileForRow
    ; If SCXS - $0C == $0D, then HL -= $20
    ld a, [SCXS]
    sub a, $0C
    ; Change this value 
    ;       v
    sub a, $0C
    ; And this value
    ;            v
    jp nz, .skip_D
    ld a, $20
    ; Add 256 - A to HL
    cpl
    scf
    adc   a, l
    ld    l, a
    ld    a, -1 ; And subtract 256 here
    adc   a, h
    ld    h, a
    ; And this value
    ; v
.skip_D:
    call setTileForRow
    ; If SCXS - $0C == $0C, then HL -= $20
    ld a, [SCXS]
    sub a, $0C
    ; Change this value 
    ;       v
    sub a, $0B
    ; And this value
    ;            v
    jp nz, .skip_C
    ld a, $20
    ; Add 256 - A to HL
    cpl
    scf
    adc   a, l
    ld    l, a
    ld    a, -1 ; And subtract 256 here
    adc   a, h
    ld    h, a
    ; And this value
    ; v
.skip_C:
    call setTileForRow
    ; If SCXS - $0C == $0B, then HL -= $20
    ld a, [SCXS]
    sub a, $0C
    ; Change this value 
    ;       v
    sub a, $0A
    ; And this value
    ;            v
    jp nz, .skip_B
    ld a, $20
    ; Add 256 - A to HL
    cpl
    scf
    adc   a, l
    ld    l, a
    ld    a, -1 ; And subtract 256 here
    adc   a, h
    ld    h, a
    ; And this value
    ; v
.skip_B:
    call setTileForRow
    ; If SCXS - $0C == $0A, then HL -= $20
    ld a, [SCXS]
    sub a, $0C
    ; Change this value 
    ;       v
    sub a, $09
    ; And this value
    ;            v
    jp nz, .skip_A
    ld a, $20
    ; Add 256 - A to HL
    cpl
    scf
    adc   a, l
    ld    l, a
    ld    a, -1 ; And subtract 256 here
    adc   a, h
    ld    h, a
    ; And this value
    ; v
.skip_A:
    call setTileForRow
    ; If SCXS - $0C == $09, then HL -= $20
    ld a, [SCXS]
    sub a, $0C
    ; Change this value 
    ;       v
    sub a, $08
    ; And this value
    ;            v
    jp nz, .skip_9
    ld a, $20
    ; Add 256 - A to HL
    cpl
    scf
    adc   a, l
    ld    l, a
    ld    a, -1 ; And subtract 256 here
    adc   a, h
    ld    h, a
    ; And this value
    ; v
.skip_9:
    call setTileForRow
    ; If SCXS - $0C == $08, then HL -= $20
    ld a, [SCXS]
    sub a, $0C
    ; Change this value 
    ;       v
    sub a, $07
    ; And this value
    ;            v
    jp nz, .skip_8
    ld a, $20
    ; Add 256 - A to HL
    cpl
    scf
    adc   a, l
    ld    l, a
    ld    a, -1 ; And subtract 256 here
    adc   a, h
    ld    h, a
    ; And this value
    ; v
.skip_8:
    call setTileForRow
    ; If SCXS - $0C == $07, then HL -= $20
    ld a, [SCXS]
    sub a, $0C
    ; Change this value 
    ;       v
    sub a, $06
    ; And this value
    ;            v
    jp nz, .skip_7
    ld a, $20
    ; Add 256 - A to HL
    cpl
    scf
    adc   a, l
    ld    l, a
    ld    a, -1 ; And subtract 256 here
    adc   a, h
    ld    h, a
    ; And this value
    ; v
.skip_7:
    call setTileForRow
    ; If SCXS - $0C == $06, then HL -= $20
    ld a, [SCXS]
    sub a, $0C
    ; Change this value 
    ;       v
    sub a, $05
    ; And this value
    ;            v
    jp nz, .skip_6
    ld a, $20
    ; Add 256 - A to HL
    cpl
    scf
    adc   a, l
    ld    l, a
    ld    a, -1 ; And subtract 256 here
    adc   a, h
    ld    h, a
    ; And this value
    ; v
.skip_6:
    call setTileForRow
    ; If SCXS - $0C == $05, then HL -= $20
    ld a, [SCXS]
    sub a, $0C
    ; Change this value 
    ;       v
    sub a, $04
    ; And this value
    ;            v
    jp nz, .skip_5
    ld a, $20
    ; Add 256 - A to HL
    cpl
    scf
    adc   a, l
    ld    l, a
    ld    a, -1 ; And subtract 256 here
    adc   a, h
    ld    h, a
    ; And this value
    ; v
.skip_5:
    call setTileForRow
    ; If SCXS - $0C == $04, then HL -= $20
    ld a, [SCXS]
    sub a, $0C
    ; Change this value 
    ;       v
    sub a, $03
    ; And this value
    ;            v
    jp nz, .skip_4
    ld a, $20
    ; Add 256 - A to HL
    cpl
    scf
    adc   a, l
    ld    l, a
    ld    a, -1 ; And subtract 256 here
    adc   a, h
    ld    h, a
    ; And this value
    ; v
.skip_4:
    call setTileForRow
    ; If SCXS - $0C == $03, then HL -= $20
    ld a, [SCXS]
    sub a, $0C
    ; Change this value 
    ;       v
    sub a, $02
    ; And this value
    ;            v
    jp nz, .skip_3
    ld a, $20
    ; Add 256 - A to HL
    cpl
    scf
    adc   a, l
    ld    l, a
    ld    a, -1 ; And subtract 256 here
    adc   a, h
    ld    h, a
    ; And this value
    ; v
.skip_3:
    call setTileForRow
    ; If SCXS - $0C == $02, then HL -= $20
    ld a, [SCXS]
    sub a, $0C
    ; Change this value 
    ;       v
    sub a, $01
    ; And this value
    ;            v
    jp nz, .skip_2
    ld a, $20
    ; Add 256 - A to HL
    cpl
    scf
    adc   a, l
    ld    l, a
    ld    a, -1 ; And subtract 256 here
    adc   a, h
    ld    h, a
    ; And this value
    ; v
.skip_2:
    call setTileForRow
    ; If SCXS - $0C == $01, then HL -= $20
    ld a, [SCXS]
    sub a, $0C
    ; Change this value 
    ;       v
    sub a, $00
    ; And this value
    ;            v
    jp nz, .skip_1
    ld a, $20
    ; Add 256 - A to HL
    cpl
    scf
    adc   a, l
    ld    l, a
    ld    a, -1 ; And subtract 256 here
    adc   a, h
    ld    h, a
    ; And this value
    ; v
.skip_1:
    call setTileForRow
    ; Ret to code
    ret

; One tile and goto next
setTileForRow::
    ; Wait for HBlank, otherwise screen dies in a fire (glitchiness)
.waitVRAM
    ldh a, [rSTAT]
    and a, STATF_BUSY
    jr nz, .waitVRAM  

    ; Set to appropriate tile.
    ld a, [de]
    ld [hl], a

    ; Move to next tile
    inc de

    ; Add 1 to hl
    ld a, $1
    add a, l
    ld l, a
    adc a, h
    sub l
    ld h, a    

    ; Okay, so here's the deal, when the viewport extends beyond the right side, it causes it to draw to the next row.
    ; If we can determine if an extension around the edge of the screen occured, we can then subtract $20 to HL
    ; in order to shift the row back up to where it needs to be.
    ; In order to do this however, we need to determine if the 2 order Hex has shifted from odd to even. i.e. 997F -> 9980
    ; At the center of the screen the number goes from even to odd 996F -> 9970. This is okay. But at the end of the screen
    ; It goes from odd to even. Once we know this has occured, all we have to do is subtract $20 from HL.
    
    ; In order to determine if we need to do something, then we need to check if l is even and lastSecondHex is odd.
    ; To check if l is even, first load into a.
    ; Then just sub 2 until either overflow occurs or z occurs.
    ; If overflow, then odd. If z, then even.
    ; If odd, goto skipCheck.
    ; If even, continue the checking.
    
    ; To check if lastSecondHex is even, first load into a.
    ; Then just sub 2 until either overflow occurs or z occurs.
    ; If overflow, then odd. If z, then even.
    ; If odd, then subtract $20 from hl.
    ; If even, goto skipCheck.

    ; Alright, now we need to subtract $20 from HL


.skipCheck:
    ; Save $00X0 into lastSecondHex
    ; This should be l bit shifted right four times
    ld a, l
    sra a
    sra a
    sra a
    sra a
    ld [lastSecondHex], a

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

    ; Check if the pixX is greater than the focus point
    ld a, [pixY]
    ld b, a
    ld a, [pixY+1]
    ld c, a
    ld a, [viewTargetY]
    ld h, a
    ld a, [viewTargetY+1]
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
    jp z, .checkLowerBitsV
    ; If the result is Carry, then target is left of the current
    jp c, .moveUp
.moveDown:
    call MoveViewDown
    jp .endV
.moveUp:
    call MoveViewUp
    jp .endV
.checkLowerBitsV:
    ; Now we need to test the lower bits
    ; l - c = ?
    ld a, l
    cp a, c
    ; If the result is zero, they are equal and we are done
    jp z, .endV
    ; If the result is Carry, then the target is left of the current
    jp c, .moveUp
    ; Else, move right
    jp .moveDown
.endV:



/*
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
*/



    ret