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