incasm "kernel.hdr"
;incasm "kernel.asm"

; NOTE: If you are using an enumator, ensure that the SID is enabled 
; prior to running this demo.

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

        cmp #'3'
        bne @not3
        jsr Do3
@not3

        cmp #'4'
        bne @not4
        jsr Do4
@not4

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

        jsr audio.beep$

        jsr PressAnyKey

        rts

Do2

        jsr console.clear$

        ; Set the volume
        lda #$0f
        sta audio.setvolume.value$
        jsr audio.setvolume$

        ; Set sustain/release
        lda #audio.voice1$
        sta audio.setsustainrelease.voice$
        ;lda #$59
        lda #audio.sustainmedium$
        ora #audio.sustainlowest$
        ora #audio.releasehigh$
        ora #audio.releaselowest$
        sta audio.setsustainrelease.value$
        jsr audio.setsustainrelease$

        ; Set the frequency
        lda #audio.voice1$
        sta audio.setfrequency.voice$
        lda #$4b
        sta audio.setfrequency.frequency$
        lda #$22
        sta audio.setfrequency.frequency$+1
        jsr audio.setfrequency$

        ; Set waveform (on)
        lda #audio.voice1$
        sta audio.setwaveform.voice$
        ;lda #audio.sawtoothon$
        lda #audio.triangleon$
        sta audio.setwaveform.value$
        jsr audio.setwaveform$
        
        ; Add some delay
        ;jsr delay
        lda #$e8
        sta time.wait.milliseconds$
        lda #$03
        sta time.wait.milliseconds$+1
        lda #$00
        sta time.wait.milliseconds$+2
        sta time.wait.milliseconds$+3
        jsr time.wait$ ; time.wait$(1000)

        ; Set waveform (off)
        lda #audio.voice1$
        sta audio.setwaveform.voice$
        ;lda #audio.sawtoothoff$
        lda #audio.triangleoff$
        sta audio.setwaveform.value$
        jsr audio.setwaveform$

        jsr PressAnyKey

        rts

Do3

        jsr console.clear$

        lda #<loading
        sta console.writestr.straddress$
        lda #>loading
        sta console.writestr.straddress$+1
        jsr console.writestr$

        ; Read the SID into memory
        lda #<fnsid
        sta disk.readfile.filename$
        lda #>fnsid
        sta disk.readfile.filename$+1
        lda #<sidinitaddress;-2
        sta disk.readfile.address$
        lda #>sidinitaddress;-1
        sta disk.readfile.address$+1
        jsr disk.readfile$

        lda #<done
        sta console.writestr.straddress$
        lda #>done
        sta console.writestr.straddress$+1
        jsr console.writestr$
        jsr console.writeln$

        lda #<sidinitaddress
        sta audio.sidinitaddress$
        lda #>sidinitaddress
        sta audio.sidinitaddress$+1

        lda #<sidplayaddress
        sta audio.sidplayaddress$
        lda #>sidplayaddress
        sta audio.sidplayaddress$+1

        lda #<sidtimer
        sta audio.sidtimer$
        lda #>sidtimer
        sta audio.sidtimer$+1

        jsr audio.sidstart$

        jsr PressAnyKey

        jsr audio.sidend$

        rts

Do4

        jsr console.clear$

        lda #<loading
        sta console.writestr.straddress$
        lda #>loading
        sta console.writestr.straddress$+1
        jsr console.writestr$

        ; Read the DIGI into memory
        lda #<fndigi
        sta disk.readfile.filename$
        lda #>fndigi
        sta disk.readfile.filename$+1
        lda #<digistartaddress;-2
        sta disk.readfile.address$
        lda #>digistartaddress;-1
        sta disk.readfile.address$+1
        jsr disk.readfile$

        lda #<done
        sta console.writestr.straddress$
        lda #>done
        sta console.writestr.straddress$+1
        jsr console.writestr$
        jsr console.writeln$

        lda #<digisamplerate
        sta audio.digisamplerate$
        lda #>digisamplerate
        sta audio.digisamplerate$+1

        lda #<digiendaddress
        sta audio.digiendaddress$
        lda #>digiendaddress
        sta audio.digiendaddress$+1

@play

        jsr audio.digistart$

@loop
        lda audio.digifinished$
        cmp #$01
        bne @loop

        jsr audio.digiend$

        ;jsr PressAnyKey

        jsr console.writeln$
        jsr console.writeln$

        lda #<digirepeat
        sta console.writestr.straddress$
        lda #>digirepeat
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr console.writeln$
        
        jsr console.readchr$
        lda console.readchr.char$

        cmp #'r'
        bne @notr
        jsr console.clear$
        jmp @play
@notr

        lda #$00

        rts

title   text 'Audio', console.newline$, console.newline$
        text 'Please select one of the options below:', console.newline$, console.null$

options text '1. Play Beep', console.newline$
        text '2. Play Sound', console.newline$
        text '3. Play SID', console.newline$
        text '4. Play Digi', console.newline$
        text 'x. Exit', console.newline$
        text console.null$

anykey  text 'Press any key to go back', console.null$

filename word $0000
fnnext  text 'DEMO6-X', console.null$
fnback  text 'MAIN', console.null$
failed  text 'Failed to load ', console.null$
loading text 'Please wait... ', console.null$
done    text 'Done!', console.null$

fnsid           text 'SIDDEMO', console.null$
sidinitaddress  = $a000
sidplayaddress  = $a003
sidtimer        = $5000

fndigi            text 'DIGIDEMO', console.null$
digistartaddress  = $a000 ; Digi start address
digiendaddress    = $a000+$1c00 ; Digi endi address
digisamplerate    = $0100 ; Sample Rate: 256 for 8 bit mono 8 kHz
digirepeat        text 'Press R to repeat.', console.newline$, 'Any other key to go back.', console.null$

