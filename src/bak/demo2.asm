incasm "kernel.hdr"

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

        cmp #'2'
        bne @not2
        jsr Do2
@not2

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

Do1

        jsr console.clear$

        ; Save the current font to memory
        lda #$00
        sta memory.copy16.source$
        lda #$20
        sta memory.copy16.source$+1
        lda #$00
        sta memory.copy16.destination$
        lda #$a0
        sta memory.copy16.destination$+1
        lda #$00
        sta memory.copy16.length$
        lda #$08
        sta memory.copy16.length$+1
        jsr memory.copy16$

        ; Print out each character to the screen
        lda #$00
        sta char

@printchar
        lda char
        sta console.writechr.char$
        jsr console.writechr$
        inc char
        beq @done
        jmp @printchar
@done


        ; Load custom character set from disk to memory at $2000
        lda #<fnfont
        sta disk.readfile.filename$
        lda #>fnfont
        sta disk.readfile.filename$+1
        lda #$00
        sta disk.readfile.address$
        lda #$20
        sta disk.readfile.address$+1
        jsr disk.readfile$

        jsr PressAnyKey

        ; Restore the current font from memory
        lda #$00
        sta memory.copy16.source$
        lda #$a0
        sta memory.copy16.source$+1
        lda #$00
        sta memory.copy16.destination$
        lda #$20
        sta memory.copy16.destination$+1
        lda #$00
        sta memory.copy16.length$
        lda #$08
        sta memory.copy16.length$+1
        jsr memory.copy16$

        rts

Do2

        jsr console.clear$

        ; Backup the character 'a'
        lda #$08
        sta memory.copy.source$
        lda #$20
        sta memory.copy.source$+1
        lda #<charbu
        sta memory.copy.destination$
        lda #>charbu
        sta memory.copy.destination$+1
        lda #$08
        sta memory.copy.length$
        jsr memory.copy$

        ; Override the character 'a'
        lda #<charhm
        sta memory.copy.source$
        lda #>charhm
        sta memory.copy.source$+1
        lda #$08
        sta memory.copy.destination$
        lda #$20
        sta memory.copy.destination$+1
        lda #$08
        sta memory.copy.length$
        jsr memory.copy$

        ; Print the character 'a'
        lda #'a'
        sta console.writechr.char$
        jsr console.writechr$

        jsr PressAnyKey

        ; Restore the character 'a'
        lda #<charbu
        sta memory.copy.source$
        lda #>charbu
        sta memory.copy.source$+1
        lda #$08
        sta memory.copy.destination$
        lda #$20
        sta memory.copy.destination$+1
        lda #$08
        sta memory.copy.length$
        jsr memory.copy$

        rts

title   text 'Fonts', console.newline$, console.newline$
        text 'Please select one of the options below:', console.newline$, console.null$

options text '1. Custom Charset', console.newline$
        text '2. Override Characters', console.newline$
        text 'x. Exit', console.newline$
        text console.null$

anykey  text 'Press any key to go back', console.null$

filename word $0000
fnnext  text 'DEMO2-X', console.null$
fnback  text 'MAIN', console.null$
failed  text 'Failed to load ', console.null$

fnfont  text 'FONTDEMO', console.null$
char    byte $00

charhm  byte %00111100
        byte %01100011
        byte %01100100
        byte %01111000
        byte %01110000
        byte %01100000
        byte %01100000
        byte %01110000
charbu  byte $00, $00, $00, $00, $00, $00, $00, $00

