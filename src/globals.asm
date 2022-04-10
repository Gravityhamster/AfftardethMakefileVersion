; Include the struct lib
INCLUDE "structs.inc"

; Define structs
    struct metaSpriteTemplate
        bytes 2, YPos
        bytes 2, XPos
        bytes 2, MetaSprite
    end_struct


SECTION "Hard Globals", ROM0

/*; Meta sprite 8x8:
PlayerMetasprite::
    db 16, 8, 0, 0
    db 16, 16, 1, 0
    db 24, 8, 2, 0
    db 24, 16, 3, 0
    db 128*/

; Meta sprite 8x16:
PlayerMetasprite::
    db 0, 0, 0, 0
    db 0, 8, 2, 0
    db 128

; Tile sets
SECTION "Graphics", ROM0

; Grassy tile data
GrassyTiles::
    INCBIN "res/GrassyTiles.2bpp"
    .end::

; Sprite tile data
SpriteTiles::
    INCBIN "res/SpriteTiles.2bpp"
    .end::

SECTION "Globals", WRAM0

; -------------------------------------------------------------------------------
; Work variables
; -------------------------------------------------------------------------------

; Target location of the view
viewTargetX::
    ds 2
viewTargetY::
    ds 1

; Last view position
prevX::
    ds 1

; Struct references
    dstruct metaSpriteTemplate, PlayerSprite

; Sprite global offset
YOffset::
    ds 2
XOffset::
    ds 2

; Q12.4 fixed-point X posiition
MetaspritePosition::
    dw

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