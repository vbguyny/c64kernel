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

        ; If the char pressed is greater than or equal to 0
        ; and is less than or equal to 9, load the next program.
        cmp #'0'
        bcs @GteZero
        jmp @CheckForX
@GteZero
        cmp #':'
        bcc @LteNine
        jmp @CheckForX
@LteNine
        jsr DoLoad
        jmp @loop

        ; If the char pressed is 'x', exit the program.
@CheckForX
        cmp #'x'
        bne @notexit
        jsr DoExit

@notexit

        jmp @loop

        rts

DoExit
        jsr kernel.reset$
        rts

DoLoad
        sta filename+4 ; Modify the string value directly

        lda #<filename
        sta disk.loadfile.filename$
        lda #>filename
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

        lda #<filename
        sta console.writestr.straddress$
        lda #>filename
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr console.readchr$
        lda #$00

        rts

title   text 'Welcome to the C64 Kernel by VBGuyNY', console.newline$, console.newline$
        text 'Please select one of the options below:', console.newline$, console.null$

options text '1. Console', console.newline$
        text '2. Fonts', console.newline$
        text '3. Time', console.newline$
        text '4. Strings', console.newline$
        text '5. Graphics', console.newline$
        text '6. Audio', console.newline$
        text '7. Input', console.newline$
        text '8. Disk', console.newline$
        text '9. Printer', console.newline$
        text '0. Serial', console.newline$
        text 'x. Exit', console.newline$
        text console.null$

;filename text 'DEMOX', console.null$
filename text 'DEMO0', console.null$
failed  text 'Failed to load ', console.null$
