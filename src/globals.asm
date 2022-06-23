; Include the struct lib
INCLUDE "hardware.inc"
INCLUDE "structs.inc"

; Define structs
    struct metaSpriteTemplate
        bytes 2, MetaSprite ; 0, 1
        bytes 2, YPos       ; 2, 3
        bytes 2, XPos       ; 4, 5
        bytes 2, YVel       ; 6, 7
        bytes 2, XVel       ; 8, 9
        bytes 1, Dir       ; 10
        bytes 2, MetaSpritePrime ; 11, 12
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
    db 0, 0, 0, %00000000
    db 0, 8, 2, %00000000
    db 128
PlayerMetaspritePrime::
    db 0, 8, 0, %00100000
    db 0, 0, 2, %00100000
    db 128

; Meta sprite 8x16:
EnemyMetasprite::
    db 0, 0, 0, %00000000
    db 0, 8, 2, %00000000
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

; Move collide variables
xamnt::
    ds 2
yamnt::
    ds 2
xOffset1::
    ds 2
yOffset1::
    ds 2
xOffset2::
    ds 2
yOffset2::
    ds 2
xOffset3::
    ds 2
yOffset3::
    ds 2
cancelYVelocity::
    ds 1

; InitStruct variables
altMetaSprite::
    ds 2

; Current Tilemap
currentTileMap::
    ds 2
currentCollisionMap::
    ds 2

; Structure addres
structAddress::
    ds 2

; Target location of the view
viewTargetX::
    ds 2
viewTargetY::
    ds 2

; Last view position
prevX::
    ds 1

; Struct references
dstruct metaSpriteTemplate, PlayerSprite
dstruct metaSpriteTemplate, EnemySprite1
dstruct metaSpriteTemplate, EnemySprite2
dstruct metaSpriteTemplate, EnemySprite3

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
memY::
    ds 2

; 2-byte
mapX::
    ds 2
mapY::
    ds 2

; 2-byte
maxX::
    ds 4
maxY::
    ds 4

; 2-byte
pixX::
    ds 4
pixY::
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