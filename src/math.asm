INCLUDE "hardware.inc"

SECTION "Math Functions", ROM0

; -------------------------------------
; Function definitions - Math Functions
; -------------------------------------

; Multiplay BC times 32
BCTimes32::

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
HLTimes32::

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

; Bit shift HL right
BitshiftHL::

    ; Shift l
    sra l
    ; Get h
    ld a, h
    ; Okay, now we need to set the highest bit of l to the lowest of h
    sla a
    sla a
    sla a
    sla a
    sla a
    sla a
    sla a
    and a, %10000000
    jp nz, .orr
    ld a, %01111111
    and a, l
    jp .lode
.orr:
    or a, l
.lode:
    ld l, a
    ; Shift h   
    sra h
    ld a, %01111111
    and a, h
    ld h, a
    ret

; Bit shift BC right
BitshiftBC::

    ; Shift l
    sra c
    ; Get h
    ld a, b
    ; Okay, now we need to set the highest bit of l to the lowest of h
    sla a
    sla a
    sla a
    sla a
    sla a
    sla a
    sla a
    and a, %10000000
    jp nz, .orr
    ld a, %01111111
    and a, c
    jp .lode
.orr:
    or a, c
.lode:
    ld c, a
    ; Shift h   
    sra b
    ld a, %01111111
    and a, b
    ld b, a
    ret

; Bit shift DE right
BitshiftDE::

    ; Shift l
    sra e
    ; Get h
    ld a, d
    ; Okay, now we need to set the highest bit of l to the lowest of h
    sla a
    sla a
    sla a
    sla a
    sla a
    sla a
    sla a
    and a, %10000000
    jp nz, .orr
    ld a, %01111111
    and a, e
    jp .lode
.orr:
    or a, e
.lode:
    ld e, a
    ; Shift h   
    sra d
    ld a, %01111111
    and a, d
    ld d, a
    ret

; Bit shift DE left
BitshiftLeftDE::

    ; Shift d left
    sla d
    ; Set the highest bit of e to the lowest of d
    ld a, e
    ; Shift the highest bit in to the lowest in d
    sra a
    sra a
    sra a
    sra a
    sra a
    sra a
    sra a
    sra a
    and a, %00000001
    jp nz, .orr
    ld a, %11111110
    and a, d
    jp .lode
.orr:
    or a, d
.lode:
    ld d, a
    ; Shift h   
    sla e
    ld a, %11111110
    and a, e
    ld e, a
    ret