incasm "kernel.asm"

main


        lda #$0f
        sta audio.setvolume.value$
        jsr audio.setvolume$

        lda #$00
        sta audio.sidinitaddress$
        lda #$90
        sta audio.sidinitaddress$+1
        lda #$03
        sta audio.sidplayaddress$
        lda #$90
        sta audio.sidplayaddress$+1

        lda #$00
        sta audio.sidtimer$
        lda #$50
        sta audio.sidtimer$+1

        jsr audio.sidstart$

        jsr graphics.setmulticolormode$

        lda #7
        sta console.setcolumn.column$
        jsr console.setcolumn$

        lda #24
        sta console.setrow.row$
        jsr console.setrow$

        lda #<return
        sta console.writestr.straddress$
        lda #>return
        sta console.writestr.straddress$+1
        jsr console.writestr$

        ;jsr kernel.halt$

@loop
        lda bordercolor
        sta console.setbordercolor.color$
        jsr console.setbordercolor$
        inc bordercolor

;        lda #$f4
;        sta time.wait.milliseconds$
;        lda #$01
;        sta time.wait.milliseconds$+1
;        lda #$00
;        sta time.wait.milliseconds$+2
;        lda #$00
;        sta time.wait.milliseconds$+3
;        jsr time.wait$

        lda #10
        sta keycounter
@checkkey
        jsr console.readkey$
        lda console.readkey.shift1$
        cmp #console.readkey.shift1.return$
        beq @done
        jsr time.halt$
        dec keycounter
        bne @checkkey

        jmp @loop

@done

        lda #color.black$
        sta console.setbordercolor.color$
        jsr console.setbordercolor$

        jsr audio.sidend$

        jsr graphics.settextmode$

        jsr console.clear$

        lda #<filename
        sta disk.loadfile.filename$
        lda #>filename
        sta disk.loadfile.filename$+1
        jsr disk.loadfile$

        jsr audio.beep$

        ; If we get here, we couldn't load the next program
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
        jsr console.writeln$

        lda #<anykey
        sta console.writestr.straddress$
        lda #>anykey
        sta console.writestr.straddress$+1
        jsr console.writestr$
        ;jsr console.writeln$
        jsr console.readchr$

@checkkey2
;        jsr console.readkey$
;        lda console.readkey.shift1$
;        cmp #console.readkey.shift1.return$
;        beq @done2
;        jmp @checkkey2
;@done2

        jsr kernel.reset$

        rts

bordercolor     byte $00
keycounter      byte $00
filename        text 'MAIN', console.null$
return          text 'Press "Return" to continue.', console.null$
failed          text 'Failed to load ', console.null$
;return          text 'Bella is coooooooooooool :)', console.null$
anykey          text 'Press any key to continue', console.null$

*=$6000
;incbin "logo1-2.kla",2 ; skip the first two bytes
incbin "logo1-3.kla",2 ; skip the first two bytes

*=$9000
;incbin "logo1.dat",2 ; skip the first two bytes
incbin "logo1-2.dat",2 ; skip the first two bytes

