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

Do1

        ; Ticks are the number of milliseconds that the computer has been on.
        ; They reset when the computer is turned off/on and after 24 hours.
        ; Ticks are updated every "jiffy" which is 1/50 of a second for PAL
        ; and 1/60 of a second for NTSC.

        jsr console.clear$

        lda #<ticks
        sta console.writestr.straddress$
        lda #>ticks
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr time.getticks$
        lda time.getticks.result$
        sta console.writeint32.integer$
        lda time.getticks.result$+1
        sta console.writeint32.integer$+1
        lda time.getticks.result$+2
        sta console.writeint32.integer$+2
        lda time.getticks.result$+3
        sta console.writeint32.integer$+3
        jsr console.writeint32$

        jsr PressAnyKey

        rts


title   text 'Time', console.newline$, console.newline$
        text 'Please select one of the options below:', console.newline$, console.null$

options text '1. Get Ticks', console.newline$
        text 'x. Exit', console.newline$
        text console.null$

anykey  text 'Press any key to go back', console.null$

filename word $0000
fnnext  text 'DEMO3-X', console.null$
fnback  text 'MAIN', console.null$
failed  text 'Failed to load ', console.null$

ticks   text 'Ticks: ', console.null$

