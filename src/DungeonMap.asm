; Sample tile map data
SECTION "Dungeonmap", ROMX
        
; Copy grassy tiles into registers to be loaded
copyDungeonTiles::
    ld de, DungeonTiles
    ld hl, $9000
    ld bc, DungeonTiles.end - DungeonTiles ; We set bc to the amount of bytes to copy
    ; Push copied tileset to VRAM
    jp memcpy

; Copy HillsMapTilemap into registers to be loaded
copyDungeonTilemapExtMap::
    call copyDungeonTiles
    ld de, HillsMapCollisionMap
    ld a, d
    ld [currentCollisionMap], a
    ld a, e
    ld [currentCollisionMap + 1], a
    ld de, DungeonTilemap
    ld a, d
    ld [currentTileMap], a
    ld a, e
    ld [currentTileMap + 1], a
    ld hl, $9800
    ; Define map dims
    ld a, $00
    ld [mapX], a ; Units
    ld a, $40
    ld [mapX+1], a
    ; To calculate pixel width do : (mapX * 8) - ($14 * 8)
    ld a, $01
    ld [maxX], a ; Pixels
    ld a, $60
    ld [maxX+1], a

    ld a, $00
    ld [mapY], a ; Units
    ld a, $40
    ld [mapY+1], a
    ; To calculate pixel width do : (mapX * 8) - ($12 * 8)
    ld a, $01
    ld [maxY], a ; Pixels
    ld a, $70
    ld [maxY+1], a
    ; Push copied tilemap to VRAM
    ret
    ;jp pLoadExtendedMap

; 32 x 64
DungeonTilemap::
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $24, $25, $25, $25, $26, $24, $26, $27, $21, $22, $23, $21, $23, $07, $21, $22, $23, $00, $00, $00, $00, $00, $00, $00, $00, $21, $22, $23, $07, $21, $23, $21, $22, $23, $27, $24, $26, 
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $34, $29, $2A, $2B, $36, $44, $46, $37, $31, $32, $33, $31, $33, $18, $31, $32, $33, $00, $00, $00, $00, $00, $00, $00, $00, $31, $65, $33, $18, $31, $33, $31, $32, $33, $37, $44, $46, 
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $34, $39, $35, $3B, $36, $15, $05, $16, $41, $42, $43, $41, $43, $17, $41, $42, $43, $00, $00, $00, $00, $00, $00, $00, $00, $41, $42, $43, $17, $41, $43, $41, $42, $43, $15, $05, $16, 
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $34, $49, $4A, $4B, $36, $21, $23, $15, $16, $15, $16, $15, $16, $15, $16, $00, $2D, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $15, $16, $00, $00, $15, $16, $15, $16, $21, $23, 
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $44, $45, $45, $45, $46, $31, $33, $20, $00, $00, $15, $16, $00, $00, $00, $00, $3D, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $15, $16, $15, $16, $00, $00, $00, $31, $33, 
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $2D, $00, $21, $23, $41, $43, $15, $16, $15, $16, $15, $16, $00, $00, $00, $3D, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $2D, $20, $00, $15, $16, $15, $16, $41, $43, 
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3D, $00, $41, $43, $54, $56, $20, $15, $16, $00, $00, $00, $00, $00, $00, $68, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3D, $00, $15, $16, $15, $16, $20, $54, $56, 
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3D, $00, $00, $30, $74, $76, $00, $00, $15, $16, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3D, $00, $00, $15, $16, $00, $00, $74, $76, 
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3D, $00, $00, $00, $24, $25, $25, $25, $26, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3D, $00, $00, $00, $24, $25, $25, $25, $26, 
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $5D, $5D, $5D, $5D, $5D, $7D, $5D, $00, $00, $00, $00, $00, $00, $3D, $00, $00, $00, $34, $65, $0A, $65, $36, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3D, $00, $00, $00, $34, $0B, $2B, $65, $36, 
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $5D, $5D, $5D, $5D, $7D, $5D, $00, $7D, $5D, $5F, $5D, $7D, $5D, $00, $00, $00, $00, $3D, $00, $00, $00, $34, $0B, $4A, $0C, $36, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $6F, $00, $00, $00, $34, $65, $49, $0C, $36, 
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $5F, $7D, $5D, $5F, $5D, $00, $7D, $5F, $00, $00, $00, $00, $00, $3D, $00, $00, $00, $44, $45, $45, $45, $46, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $5D, $7D, $5D, $5D, $5D, $00, $00, $00, $00, $00, $44, $45, $45, $45, $46, 
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $5D, $5D, $5D, $5F, $5D, $7D, $00, $5D, $5F, $5D, $5D, $5D, $00, $00, $00, $3D, $00, $00, $00, $00, $00, $1C, $00, $00, $00, $00, $00, $00, $5D, $5D, $7D, $00, $00, $00, $00, $00, $00, $5F, $5D, $7D, $5D, $00, $7D, $5D, $00, $00, $00, $00, $1C, $00, $00, 
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $5D, $5F, $5D, $5D, $00, $00, $00, $00, $00, $00, $00, $3D, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $5D, $5D, $5D, $7D, $5F, $5D, $00, $00, $00, $00, $00, $00, $5D, $5F, $5D, $5D, $5F, $7D, $5D, $00, $00, $00, $00, $00, $00, 
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $68, $00, $00, $00, $00, $00, $00, $00, $5D, $5F, $7D, $5D, $00, $7D, $5F, $7D, $00, $00, $00, $00, $00, $00, $00, $7D, $00, $5D, $7D, $5D, $5F, $00, $00, $00, $00, $00, $00, $00, 
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $5D, $00, $7D, $5F, $7D, $5D, $5F, $7D, $5F, $5D, $00, $00, $00, $00, $00, $5D, $5F, $5D, $7D, $5F, $5D, $5D, $7D, $5D, $00, $5D, $00, $00, $00, 
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $7D, $5F, $00, $5F, $7D, $5D, $5F, $5D, $00, $00, $00, $00, $00, $00, $00, $00, $5D, $5F, $5D, $00, $7D, $5F, $00, $00, $00, $00, $00, $00, 
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $0D, $1D, $5E, $0D, $1D, $2E, $00, $00, $00, $00, $00, $5F, $5D, $5D, $00, $00, $00, $00, $00, 
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $2E, $24, $25, $25, $25, $25, $26, $0D, $1D, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, 
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $5E, $00, $00, $00, $00, $00, $1D, $2E, $21, $22, $23, $34, $57, $58, $58, $59, $36, $21, $22, $23, $0D, $00, $00, $1D, $00, $00, $00, $00, $00, $00, 
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $15, $16, $15, $16, $15, $16, $15, $16, $15, $16, $15, $16, $15, $16, $24, $25, $25, $25, $26, $54, $56, $54, $56, $27, $31, $65, $33, $34, $77, $78, $78, $79, $36, $31, $65, $33, $27, $54, $56, $54, $56, $24, $25, $25, $25, $26, 
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $15, $16, $15, $16, $15, $16, $15, $16, $15, $16, $15, $16, $20, $34, $65, $29, $0C, $36, $74, $76, $74, $76, $37, $41, $42, $43, $44, $45, $45, $45, $45, $46, $41, $42, $43, $37, $74, $76, $74, $76, $34, $65, $65, $0A, $36, 
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $2D, $00, $15, $16, $00, $00, $15, $16, $15, $16, $15, $16, $34, $0B, $4B, $65, $36, $27, $54, $56, $54, $56, $54, $56, $54, $56, $54, $56, $54, $56, $54, $56, $54, $56, $54, $56, $54, $56, $27, $34, $0B, $3A, $4B, $36, 
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3D, $00, $00, $15, $16, $00, $00, $15, $16, $15, $16, $20, $44, $45, $45, $45, $46, $37, $74, $76, $74, $76, $74, $76, $74, $76, $74, $76, $74, $76, $74, $76, $74, $76, $74, $76, $74, $76, $37, $44, $45, $45, $45, $46, 
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3D, $00, $00, $00, $00, $00, $00, $00, $15, $16, $20, $21, $22, $22, $22, $22, $22, $22, $22, $22, $23, $24, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25, $25, $26, $21, $22, $22, $22, $22, $22, $22, $22, $23, 
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3D, $00, $00, $00, $00, $00, $00, $15, $16, $15, $16, $41, $42, $42, $42, $42, $42, $42, $42, $42, $43, $34, $01, $38, $38, $38, $38, $38, $38, $38, $38, $38, $38, $02, $36, $41, $42, $42, $42, $42, $42, $42, $42, $43, 
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3D, $00, $00, $00, $00, $00, $15, $16, $15, $16, $15, $16, $24, $25, $25, $25, $25, $26, $51, $52, $53, $44, $45, $45, $45, $45, $45, $45, $45, $45, $45, $45, $45, $45, $46, $51, $52, $53, $24, $25, $25, $25, $25, $26, 
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3D, $00, $00, $00, $00, $00, $00, $15, $16, $00, $00, $20, $34, $65, $4A, $4A, $65, $36, $61, $62, $63, $27, $27, $27, $27, $27, $27, $27, $27, $27, $27, $27, $27, $27, $27, $61, $62, $63, $34, $65, $4A, $4A, $65, $36, 
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3D, $00, $00, $00, $00, $00, $00, $00, $00, $00, $15, $16, $34, $3B, $65, $65, $39, $36, $71, $72, $73, $06, $06, $06, $06, $06, $06, $37, $37, $06, $06, $06, $06, $06, $06, $71, $72, $73, $34, $3B, $65, $65, $39, $36, 
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $3D, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $34, $3B, $65, $65, $39, $36, $20, $30, $27, $06, $06, $06, $37, $37, $37, $03, $04, $37, $37, $37, $06, $06, $06, $27, $30, $20, $34, $3B, $65, $65, $39, $36, 
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $6D, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $34, $65, $2A, $2A, $65, $36, $50, $20, $37, $06, $37, $37, $11, $14, $14, $14, $14, $14, $14, $12, $37, $37, $06, $37, $20, $50, $34, $65, $2A, $2A, $65, $36, 
    db $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $44, $45, $45, $45, $45, $46, $20, $50, $20, $37, $11, $14, $14, $14, $14, $14, $14, $14, $14, $14, $14, $12, $37, $20, $50, $20, $44, $45, $45, $45, $45, $46, 
.end::

/*
DungeonCollisionMap::

.end::
    */