SECTION "Globals", WRAM0

; -------------------------------------------------------------------------------
; Work variables
; -------------------------------------------------------------------------------

; 1-byte
SCX::
    ds 1

SCY::
    ds 1

; 8-bit X position
wSimplePosition::
    ds 1

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

/*; 1-bit - A
joypadA::
    ds %1
    
; 1-bit - B
joypadB::
    ds %1
    
; 1-bit - Strt
joypadStrt::
    ds %1
    
; 1-bit - Slct
joypadSlct::
    ds %1
    
; 1-bit - U
joypadU::
    ds %1
    
; 1-bit - D
joypadD::
    ds %1
    
; 1-bit - L
joypadL::
    ds %1
    
; 1-bit - R
joypadR::
    ds %1
*/