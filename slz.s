;****************************************************************************
; DecompressSlz
; Decompresses SLZ data into memory
;----------------------------------------------------------------------------
; input a0.l .... Pointer to compressed data
; input a1.l .... Where to store decompressed data
; output a0.l ... Right after input buffer
; output a1.l ... Right after output buffer
; breaks ........ d5, d6, d7
;****************************************************************************

.extern _DecompressSlz

_DecompressSlz:
	movem.l 4(a7),a0-a1
    move.w  d3, -(sp)               ; Save registers
    move.w  d4, -(sp)

    move.b  (a0)+, d7               ; Get uncompressed size
    lsl.w   #8, d7
    move.b  (a0)+, d7

    moveq   #1, d6                  ; Cause code to fetch new token data
                                    ; as soon as it starts
MainLoop:
    tst.w   d7                      ; Did we read all the data?
    beq     End                      ; If so, we're done with it!

    subq.w  #1, d6                  ; Check if we need more tokens
    bne   HasTokens
    move.b  (a0)+, d5
    moveq   #8, d6
HasTokens:

    add.b   d5, d5                  ; Get next token type
    bcc   Uncompressed             ; 0 = uncompressed, 1 = compressed

    move.b  (a0)+, d3               ; Compressed? Read string info
    lsl.w   #8, d3                    ; d3 = distance
    move.b  (a0)+, d3                 ; d4 = length
    move.b  d3, d4
    lsr.w   #4, d3
    and.w   #$0F, d4

    subq.w  #3, d7                  ; Length is offset by 3
    sub.w   d4, d7                  ; Now that we know the string length,
                                      ; discount it from the amount of data
                                      ; to be read

    addq.w  #3, d3                  ; Distance is offset by 3
    neg.w   d3                      ; Make distance go backwards

    add.w   d4, d4                  ; Copy bytes using Duff's device
    add.w   d4, d4                    ; MUCH faster than a loop, due to lack
    eor.w   #$0F<<2, d4               ; of iteration overhead
    jmp     Duff(pc,d4.w)
Duff:
	move.b  0(a1,d3.w), (a1)+
	move.b  0(a1,d3.w), (a1)+
	move.b  0(a1,d3.w), (a1)+
	move.b  0(a1,d3.w), (a1)+
	move.b  0(a1,d3.w), (a1)+
	move.b  0(a1,d3.w), (a1)+
	move.b  0(a1,d3.w), (a1)+
	move.b  0(a1,d3.w), (a1)+
	move.b  0(a1,d3.w), (a1)+
	move.b  0(a1,d3.w), (a1)+
	move.b  0(a1,d3.w), (a1)+
	move.b  0(a1,d3.w), (a1)+
	move.b  0(a1,d3.w), (a1)+
	move.b  0(a1,d3.w), (a1)+
	move.b  0(a1,d3.w), (a1)+
	move.b  0(a1,d3.w), (a1)+
	move.b  0(a1,d3.w), (a1)+
	move.b  0(a1,d3.w), (a1)+

    bra     MainLoop               ; Keep processing data

Uncompressed:
    move.b  (a0)+, (a1)+            ; Uncompressed? Read as is
    subq.w  #1, d7                  ; It's always one byte long
    bra     MainLoop               ; Keep processing data

End:
    move.w  (sp)+, d4               ; Restore registers
    move.w  (sp)+, d3
    rts                             ; End of subroutine
