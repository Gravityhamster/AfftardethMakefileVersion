INCLUDE "hardware.inc"

SECTION "Joypad Functions", ROM0

; ---------------------------------------
; Function definitions - Joypad Functions
; ---------------------------------------

; Update Joypad Pressed Buttons 
updateJoypadState::

    ; Get joypad register
    ld hl, rP1

    ; Activate the buttons for the joypad
    ld [hl], P1F_GET_BTN

    ; After the initial enable we need to read
    ; twice to ensure we get the proper hardware
    ; state on real hardware
    ld a, [hl]
    ld a, [hl]

    ; Activate the d-pad for the joypad
    ld [hl], P1F_GET_DPAD

    ; Inputs are active low, so a bit being 0 is a button bressed, so we invert this.
    cpl
    ; Piece together the input constants
    and PADF_A | PADF_B | PADF_SELECT | PADF_START
    ; Store the lower 4 buttons' bits in c
    ld c, a

    ; We need to read the rP1 8 times to ensure the proper
    ; button is available. This is only needed
    ; on real hardware, as it takes a while for the
    ; inputs to change state back from the first set.
    ld b, 8
.dpadDebounceLoop:
    ; Read
    ld a, [hl]
    ; Count down
    dec b
    ; Jump back
    jp nz, .dpadDebounceLoop

    ; Deactivate all
    ld [hl], P1F_GET_NONE

    ; We want the directional keys as upper 4 bits, so swap the nibbles
    swap a
    ; Inputs are active low, so a bit being 0 is a button pressed. So invert
    cpl
    ; Piece together the input constants
    and PADF_RIGHT | PADF_LEFT | PADF_UP | PADF_DOWN
    or c
    ld c, a

    ; Compare the new joypad state with the previous one,
    ; and store the new bits in wJoypadPressed
    ld hl, joypadState
    xor [hl]
    and c
    ld [joypadPressed], a
    ld a, c
    ld [joypadState], a
    
    ret