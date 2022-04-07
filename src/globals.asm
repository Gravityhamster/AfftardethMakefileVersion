SECTION "Globals", WRAM0

; -------------------------------------------------------------------------------
; Timer variables
; -------------------------------------------------------------------------------

; 8-bytes
timeSet::
    ds 8

; 8-bytes
timer::
    ds 8

; -------------------------------------------------------------------------------
; Work variables
; -------------------------------------------------------------------------------

; 2-byte
memX::
    ds 2

; 2-byte
mapX::
    ds 2

; 2-byte
maxX::
    ds 4

; 2-byte
pixX::
    ds 4

; 2-byte
tempVar::
    ds 2

; 1-byte offset
drawOffset::
    ds 1

; 1-byte offset
universalCounter::
    ds 1

; -------------------------------------------------------------------------------
; Joypad variables
; -------------------------------------------------------------------------------

; 1-byte - Current joypad state 
joypadState::
    ds 1

; 1-byte - Buttons pressed this clock
joypadPressed::
    ds 1