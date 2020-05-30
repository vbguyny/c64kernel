;-------------------------------------------------------------------------------
;Fastloader test with EXOMIZER 3 depacking
;-------------------------------------------------------------------------------

                processor 6502

	org $0326	;DO NOT CHANGE, else the autostart will fail

	dc.w boot	;autostart from charout vector ($f1ca)
	dc.w $f6ed	;$328 kernal stop routine Vector ($f6ed)
	dc.w $f13e	;$32a kernal getin routine ($f13e)
	dc.w $f32f	;$32c kernal clall routine vector ($f32f)
	dc.w $fe66	;$32e user-defined vector ($fe66)
	dc.w $f4a5	;$330 kernal load routine ($f4a5)
	dc.w $f5ed	;$332 kernal save routine ($f5ed)

;* = $334 (cassette buffer)

boot	
	sei
	lda #$ca	;repair charout vector ($f1ca)
	sta $326
	lda #$f1
	sta $327
	cli
	jmp start
	
	org $0400

				include scr_codes.s
	
                ;include buffer256_sp.s
				dc.b P, L, E, A, S, E, " ", W, A, I, T, "...  "
				dc.b "                "
				dc.b "                "
				dc.b "                "
				dc.b "                "
				dc.b "                "
				dc.b "                "
				dc.b "                "
				dc.b "                "
				dc.b "                "
				dc.b "                "
				dc.b "                "
				dc.b "                "
				dc.b "                "
				dc.b "                "
				dc.b "                "
	
                include buffer256_sp.s
                include buffer256_sp.s
                include buffer256_sp.s
	
				; This program starts at $0801 and ends at $0e51 => 1616 bytes
                org $0801

;                dc.b $0b,$08           ;Address of next BASIC instruction
;                dc.w 2019              ;Line number
;                dc.b $9e               ;SYS-token
;                dc.b $32,$30,$36,$31   ;2061 in ASCII - sys (2061)
;;				dc.b $32,$30,$36,$38, $00   ;2068 in ASCII
;;				;dc.b $32,$34,$35,$38,$39, $00   ;24589 in ASCII
;;                dc.b $0b,$08           ;Address of next BASIC instruction
;;				dc.w 2020			   ;Line number
;;				dc.b $a2, $00 		   ;NEW-token
                dc.b $00,$00,$00       ;BASIC program end

; 20 SYS (2068)
; 30 NEW
;        dc.b    $0e, $08, $14, $00, $9e, $20, $28,  $32, $30, $37, $30, $29, $00 ; 20 SYS (2070)
;;        dc.b    $0e, $08, $1e, $00, $a2, $00, $00, $00 ; 30 NEW
;		dc.b    $00, $00, $00, $00, $00, $00, $00, $00 ; Nulls

start:          
				;rts

				lda #%00001011 ; Turn off screen
				sta $d011

				lda #$00 ; Change border color to black
				sta $d020
				lda #$00 ; Change screen color to black
				sta $d021
				
				jsr backupzp
				
				;rts
				
				jsr initloader

				lda #$00 ; Ensure that debug mode is disabled
				sta $0F08 ; Check kernel.asm for kernel.debugmode$

                ldx #<filename
                ldy #>filename
                jsr loadfile_exomizer   ;Load file

				; !!! It appears that if loadfile_exomizer succeeds we do not hit any of the code below !!!
				
                bcc ok
                sta $d020               ;If error, show errorcode in border
exit:           jsr getin
                tax
                beq exit
                jmp $FCE2 ; Kernal reset

ok:

				jsr $e544 ; Clear the screen

				jsr restorezp

				lda #$00 ; Ensure that debug mode is disabled
				sta $0F08 ; Check kernel.asm for kernel.debugmode$
				
				lda #%00011011 ; Turn on screen
				sta $d011

				jsr $0f10 ; Jump to the Kernel
				;rts

;				; Clear the datasette buffer
;				lda #$00
;				sta $73
;				lda #$03
;				sta $74
;				ldy #$34
;				lda #$00
;c_loop:
;				sta ($73),y
;				iny
;				bne c_loop

;				JSR $E453 ; Initialize Vectors 
;				JSR $E3BF ; Initialize BASIC RAM 
;				RTS
				
				jmp $FCE2 ; Kernal reset

backupzp:
        ; Back zero page memory
        ldx #$00
backupzp_loop:
        lda $00,x
        sta $cf00,x
        inx
        cpx #$ff
        bne backupzp_loop
        rts

restorezp:
        ; Back zero page memory
        ldx #$00
restorezp_loop:
        lda $cf00,x
        sta $00,x
        inx
        cpx #$ff
        bne restorezp_loop
        rts


filename:       dc.b "KERNELE",0

                include cfg_exom3.s
                include loader.s
