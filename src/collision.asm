; Pre-made hardware interface
INCLUDE "hardware.inc"

SECTION "Collision Functions", ROM0

; This function receives a point and returns the ID for the collision type
; @param bc - x
; @param de - y
; @param currentCollisionMap
; @returns a - Tile collision type ID
CheckCollision::
    ; Bit shift bc to right 3 times
    ld h, b
    ld l, c
    call BitshiftHL
    call BitshiftHL
    call BitshiftHL
    ld b, h
    ld c, l
    ; Bit shift de to right 3 times
    ld h, d
    ld l, e
    call BitshiftHL
    call BitshiftHL
    call BitshiftHL
    ld d, h
    ld e, l
    ; Check if collision
    ; Get the location in memory of the collision map tile
    ld h, 0
    ld l, 0
    ; The formula performed here is: hl = x + (y * mapx)
    ; hl = x
    add hl, bc
    ; Save HL - We will need it for the next section of code
    push hl
    ; y * mapx = ?
    ; Find de * mapx - mapx is ALWAYS a multiple of 2 
    ; In order to get de * mapx, we need to left-shift de and right-shift mapx until mapx = 0
    ; ld b, b
    ld a, [mapX]
    ld b, a
    ld a, [mapX + 1]
    ld c, a
    call BitshiftBC
.loop:
    call BitshiftLeftDE
    call BitshiftBC
    ; If BC is not zero, loop
    ld a, b
    or c
    jp nz, .loop
    
    ; Load HL
    pop hl
    ; Add de to hl
    add hl, de
    
    ; Get the collision map location
    ld a, [currentCollisionMap]
    ld b, a
    ld a, [currentCollisionMap + 1]
    ld c, a
    ; Add the location to the offset
    add hl, bc

    ; Load the tile into a
    ;ld b, b
    ld a, [hl]

    ;ld a, %11100100
    ;ld [rBGP], a
    ret