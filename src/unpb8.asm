SECTION "Decompress PB8", ROM0
DecompressDungeonTiles::

	ld b,b
	ld hl, DungeonBinaryMap
	ld de, $9800
INCLUDE "res/DungeonBinary.bin.pb8.size"
	ld bc, NB_PB8_BLOCKS
	ld a, b
	ld [PB8Size], a
	ld a, c
	ld [PB8Size + 1], a
	PURGE NB_PB8_BLOCKS
.pb8BlockLoop:
	; Register map for PB8 decompression
	; HL: source address in boot ROM
	; DE: destination address in VRAM
	; A: Current literal value
	; B: Repeat bits, terminated by 1000...
	; C: Number of 8-byte blocks left in this block
	; Source address in HL lets the repeat bits go straight to B,
	; bypassing A and avoiding spilling registers to the stack.
	ld b, [hl]
	inc hl

	; Shift a 1 into lower bit of shift value.  Once this bit
	; reaches the carry, B becomes 0 and the byte is over
	scf
	rl b

.pb8BitLoop:
	; If not a repeat, load a literal byte
	jr c,.pb8Repeat
	ld a, [hli]
.pb8Repeat:
	; Decompressed data uses colors 0 and 3, so write twice
	ld [de], a
	inc e ; inc de
	ld [de], a
	inc de
	sla b
	jr nz, .pb8BitLoop

	; dec c	
	push bc
	ld a, [PB8Size]
	ld b, a
	ld a, [PB8Size + 1]
	ld c, a
	dec bc
	ld a, b
	ld [PB8Size], a
	ld a, c
	ld [PB8Size + 1], a
	; Check value for 0
	ld a, b
	or c
	pop bc
	jr nz, .pb8BlockLoop
	ret