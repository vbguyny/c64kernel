incasm "kernel.hdr"
;incasm "kernel.asm"

main

@loop
        jsr console.clear$

        lda #color.white$
        sta console.setcharactercolor.color$
        jsr console.setcharactercolor$

        lda #<title
        sta console.writestr.straddress$
        lda #>title
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr console.writeln$

        lda #<options
        sta console.writestr.straddress$
        lda #>options
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr console.writeln$
        
        jsr console.readchr$
        lda console.readchr.char$

        cmp #'1'
        bne @not1
        jsr Do1
@not1

        cmp #'x'
        bne @notexit
        jsr GoBack
@notexit

        jmp @loop

        rts

GoBack
        lda #<fnback
        sta filename
        lda #>fnback
        sta filename+1
        jsr DoLoad

        rts

NextPrg
        sta fnnext+6 ; Modify the string value directly

        lda #<fnnext
        sta filename
        lda #>fnnext
        sta filename+1
        jsr DoLoad

        rts

DoLoad
        lda filename
        sta disk.loadfile.filename$
        lda filename+1
        sta disk.loadfile.filename$+1
        jsr disk.loadfile$

        jsr audio.beep$

        jsr console.writeln$
        jsr console.writeln$

        lda #color.red$
        sta console.setcharactercolor.color$
        jsr console.setcharactercolor$

        lda #<failed
        sta console.writestr.straddress$
        lda #>failed
        sta console.writestr.straddress$+1
        jsr console.writestr$

        lda filename
        sta console.writestr.straddress$
        lda filename+1
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr console.readchr$
        lda #$00

        rts

PressAnyKey

        jsr console.writeln$
        jsr console.writeln$

        lda #<anykey
        sta console.writestr.straddress$
        lda #>anykey
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr console.readchr$
        lda #$00

        rts

ErrorMsg
        ; A contains the disk error.
        ; See printererror for list of possible errors.
        sta perror

        jsr audio.beep$

        lda #color.red$
        sta console.setcharactercolor.color$
        jsr console.setcharactercolor$

        lda #<error
        sta console.writestr.straddress$
        lda #>error
        sta console.writestr.straddress$+1
        jsr console.writestr$

        lda perror
        sta console.writeint8.integer$
        jsr console.writeint8$

        jsr console.readchr$
        lda #$00

        rts

PleaseWait

        lda #<wait
        sta console.writestr.straddress$
        lda #>wait
        sta console.writestr.straddress$+1
        jsr console.writestr$

        rts

DoneMsg

        lda #<done
        sta console.writestr.straddress$
        lda #>done
        sta console.writestr.straddress$+1
        jsr console.writestr$

        rts

Do1

        ; Since the printer uses ASCII characters, lower-cased characters 
        ; don't work natively. You need to prepend the output string
        ; with a printer.lower_case$

        ; If running from an emulator, need to ensure that Printer is enabled
        ; on device #4 and Driver is ASCII and output mode is Text.
        ; You may need to enable this has a IEC device.
        ; You might not see the output in file until the emulator is closed.

        jsr console.clear$

        ; Prompt user to enter some text
        lda #<ptxt
        sta console.writestr.straddress$
        lda #>ptxt
        sta console.writestr.straddress$+1
        jsr console.writestr$
        
        ; Get the text from the console
        jsr console.readstr$
        lda console.readstr.straddress$
        sta pstr
        lda console.readstr.straddress$+1
        sta pstr+1

        jsr console.writeln$

        jsr PleaseWait

;        lda pstr
;        sta convert.str2ascii.str$
;        lda pstr+1
;        sta convert.str2ascii.str$+1
;        jsr convert.str2ascii$

        ; Printer the text to the printer
        lda pstr
        ;lda #<chr
        sta printer.printstr.address$
        lda pstr+1
        ;lda #>chr
        sta printer.printstr.address$+1
        jsr printer.printstr$

        ; Print a carriage return and line feed
        lda #<cr_lf
        sta printer.printstr.address$
        lda #>cr_lf
        sta printer.printstr.address$+1
        jsr printer.printstr$        

        ; Check for errors
        lda printer.error$
        cmp #printererror.ok$
        beq @Ok
        jmp ErrorMsg
@Ok

        jsr DoneMsg

        jsr PressAnyKey

        lda pstr
        sta memory.deallocate.address$
        lda pstr+1
        sta memory.deallocate.address$+1
        jsr memory.deallocate$

        rts

title   text 'Printer', console.newline$, console.newline$
        text 'Please select one of the options below:', console.newline$, console.null$

options text '1. Print Text', console.newline$
        text 'x. Exit', console.newline$
        text console.null$

anykey  text 'Press any key to go back', console.null$

filename word $0000
fnnext  text 'DEMO9-X', console.null$
fnback  text 'MAIN', console.null$
failed  text 'Failed to load ', console.null$

error   text 'Error ', console.null$
perror  byte $00
wait    text console.newline$, 'Please wait... ', console.null$
done    text 'Done!', console.newline$, console.newline$, console.null$
ptxt    text 'Enter some text:', console.newline$, console.null$
pstr    word $0000
cr_lf   text printer.carriage_return$, printer.line_feed$, printer.null$

;chr
;        text $00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0a, $0b, $0c, $0d, $0e, $0f
;        text $11, $11, $12, $13, $14, $15, $16, $17, $18, $19, $1a, $1b, $1c, $1d, $1e, $1f
;        text $20, $21, $22, $23, $24, $25, $26, $27, $28, $29, $2a, $2b, $2c, $2d, $2e, $2f
;        text $30, $31, $32, $33, $34, $35, $36, $37, $38, $39, $3a, $3b, $3c, $3d, $3e, $3f
;        text $40, $41, $42, $43, $44, $45, $46, $47, $48, $49, $4a, $4b, $4c, $4d, $4e, $4f
;        text $50, $51, $52, $53, $54, $55, $56, $57, $58, $59, $5a, $5b, $5c, $5d, $5e, $5f
;        text $60, $61, $62, $63, $64, $65, $66, $67, $68, $69, $6a, $6b, $6c, $6d, $6e, $6f
;        text $70, $71, $72, $73, $74, $75, $76, $77, $78, $79, $7a, $7b, $7c, $7d, $7e, $7f
;        text $80, $81, $82, $83, $84, $85, $86, $87, $88, $89, $8a, $8b, $8c, $8d, $8e, $8f
;        text $90, $91, $92, $93, $94, $95, $96, $97, $98, $99, $9a, $9b, $9c, $9d, $9e, $9f
;        text $a0, $a1, $a2, $a3, $a4, $a5, $a6, $a7, $a8, $a9, $aa, $ab, $ac, $ad, $ae, $af
;        text $b0, $b1, $b2, $b3, $b4, $b5, $b6, $b7, $b8, $b9, $ba, $bb, $bc, $bd, $be, $bf
;        text $c0, $c1, $c2, $c3, $c4, $c5, $c6, $c7, $c8, $c9, $ca, $cb, $cc, $cd, $ce, $cf
;        text $d0, $d1, $d2, $d3, $d4, $d5, $d6, $d7, $d8, $d9, $da, $db, $dc, $dd, $de, $df
;        text $e0, $e1, $e2, $e3, $e4, $e5, $e6, $e7, $e8, $e9, $ea, $eb, $ec, $ed, $ee, $ef
;        text $f0, $f1, $f2, $f3, $f4, $f5, $f6, $f7, $f8, $f9, $fa, $fb, $fc, $fd, $fe, $ff

