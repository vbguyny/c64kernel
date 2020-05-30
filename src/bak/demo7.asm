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

        cmp #'2'
        bne @not2
        jsr Do2
@not2

        cmp #'3'
        bne @not3
        jsr Do3
@not3

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

align $100

Do1

        jsr console.clear$

        lda #<key
        sta console.writestr.straddress$
        lda #>key
        sta console.writestr.straddress$+1
        jsr console.writestr$

        lda #<shift1
        sta console.writestr.straddress$
        lda #>shift1
        sta console.writestr.straddress$+1
        jsr console.writestr$

        lda #<shift2
        sta console.writestr.straddress$
        lda #>shift2
        sta console.writestr.straddress$+1
        jsr console.writestr$

        lda #<space
        sta console.writestr.straddress$
        lda #>space
        sta console.writestr.straddress$+1
        jsr console.writestr$

@loop
        jsr console.readkey$

        lda #0
        sta console.setrow.row$
        jsr console.setrow$
        lda #13
        sta console.setcolumn.column$
        jsr console.setcolumn$

        ; Get the key pressed
        ldx #' '
        lda console.readkey.state$
        cmp #console.readkey.state.ok$
        bne @print_key
        ldx console.readkey.char$
        cpx #' '
        bne @print_key
        jmp @done
@print_key
        cpx #console.readkey.char.invalid$
        beq @skip_print_key
        stx console.writechr.char$
        jsr console.writechr$
@skip_print_key

        lda #2
        sta console.setrow.row$
        jsr console.setrow$
        lda #9
        sta console.setcolumn.column$
        jsr console.setcolumn$

        ; Get the shift1 keys
        lda #console.readkey.shift1.f1$
        ldx #<f1
        ldy #>f1
        jsr PrintShift1Info
        lda #console.readkey.shift1.f3$
        ldx #<f3
        ldy #>f3
        jsr PrintShift1Info
        lda #console.readkey.shift1.f5$
        ldx #<f5
        ldy #>f5
        jsr PrintShift1Info
        lda #console.readkey.shift1.f7$
        ldx #<f7
        ldy #>f7
        jsr PrintShift1Info
        lda #console.readkey.shift1.insert_delete$
        ldx #<insert_delete
        ldy #>insert_delete
        jsr PrintShift1Info
        lda #console.readkey.shift1.left_right$
        ldx #<left_right
        ldy #>left_right
        jsr PrintShift1Info
        lda #console.readkey.shift1.return$
        ldx #<return
        ldy #>return
        jsr PrintShift1Info
        lda #console.readkey.shift1.up_down$
        ldx #<up_down
        ldy #>up_down
        jsr PrintShift1Info
        
        lda #<keybuf
        sta console.writestr.straddress$
        lda #>keybuf
        sta console.writestr.straddress$+1
        jsr console.writestr$

        lda #4
        sta console.setrow.row$
        jsr console.setrow$
        lda #9
        sta console.setcolumn.column$
        jsr console.setcolumn$

        ; Get the shift2 keys
        lda #console.readkey.shift2.clear_home$
        ldx #<clear_home
        ldy #>clear_home
        jsr PrintShift2Info
        lda #console.readkey.shift2.commodore$
        ldx #<commodore
        ldy #>commodore
        jsr PrintShift2Info
        lda #console.readkey.shift2.control$
        ldx #<control
        ldy #>control
        jsr PrintShift2Info
        lda #console.readkey.shift2.left_shift$
        ldx #<left_shift
        ldy #>left_shift
        jsr PrintShift2Info
        lda #console.readkey.shift2.right_shift$
        ldx #<right_shift
        ldy #>right_shift
        jsr PrintShift2Info
        lda #console.readkey.shift2.run_stop$
        ldx #<run_stop
        ldy #>run_stop
        jsr PrintShift2Info
        
        lda #<keybuf
        sta console.writestr.straddress$
        lda #>keybuf
        sta console.writestr.straddress$+1
        jsr console.writestr$
        
        jmp @loop

@done

        rts

PrintShift1Info
        sta keyinfo
        lda console.readkey.shift1$
        and keyinfo
        cmp keyinfo
        beq @print
        rts
@print
        stx console.writestr.straddress$
        sty console.writestr.straddress$+1
        jsr console.writestr$
        rts

PrintShift2Info
        sta keyinfo
        lda console.readkey.shift2$
        and keyinfo
        cmp keyinfo
        beq @print
        rts
@print
        stx console.writestr.straddress$
        sty console.writestr.straddress$+1
        jsr console.writestr$
        rts

;align $100

Do2

        ;jsr console.clear$
        jsr graphics.enter$

        ;jsr time.halt$
        ;jsr time.halt$

        lda #2
        sta console.setrow.row$
        jsr console.setrow$
        lda #<joys
        sta console.writestr.straddress$
        lda #>joys
        sta console.writestr.straddress$+1
        jsr console.writestr$

        lda #$1f
        sta graphics.drawbox.x1$
        lda #$00
        sta graphics.drawbox.x1$+1
        lda #$1f
        sta graphics.drawbox.y1$
        lda #$00
        sta graphics.drawbox.y1$+1
        lda #$68
        sta graphics.drawbox.x2$
        lda #$00
        sta graphics.drawbox.x2$+1
        lda #$68
        sta graphics.drawbox.y2$
        lda #$00
        sta graphics.drawbox.y2$+1
        lda #$01
        sta graphics.drawbox.color$
        jsr graphics.drawbox$

        lda #$9f
        sta graphics.drawbox.x1$
        lda #$00
        sta graphics.drawbox.x1$+1
        lda #$1f
        sta graphics.drawbox.y1$
        lda #$00
        sta graphics.drawbox.y1$+1
        lda #$e8
        sta graphics.drawbox.x2$
        lda #$00
        sta graphics.drawbox.x2$+1
        lda #$68
        sta graphics.drawbox.y2$
        lda #$00
        sta graphics.drawbox.y2$+1
        lda #$01
        sta graphics.drawbox.color$
        jsr graphics.drawbox$

        lda #20
        sta console.setrow.row$
        jsr console.setrow$
        lda #0
        sta console.setcolumn.column$
        jsr console.setcolumn$
        lda #<anykey
        sta console.writestr.straddress$
        lda #>anykey
        sta console.writestr.straddress$+1
        jsr console.writestr$

@loop

        lda #joystick.port1$
        ldx #0
        jsr DrawJoystickTarget

        lda #joystick.port2$
        ldx #16
        jsr DrawJoystickTarget

        ; Detect key press
        jsr console.readkey$
        lda console.readkey.state$
        cmp #console.readkey.state.ok$
        beq @done

        jmp @loop

@done

        jsr graphics.leave$

        rts

DrawJoystickTarget

        stx joyos

        ; Get the joystick state
        ;lda #joystick.port1$
        sta joystick.getstate.port$
        jsr joystick.getstate$

        ; Clear the joychr grid
        lda #' '
        ldx #8
@clr
        sta joychr,x
        beq @clrdone
        dex
        jmp @clr
@clrdone

        ; Possible values: $ff, $00, $01

        ; X = 1,2,3
        lda joystick.getstate.deltax$
        clc
        adc #2
        sta joyxos

        ; Y = 0,3,6
        lda joystick.getstate.deltay$
        clc
        adc #1
        sta math.multiply8.factor1$
        lda #3
        sta math.multiply8.factor2$
        jsr math.multiply8$
        lda math.multiply8.product$
        sta joyyos

        ; Final location = X+Y-1
        lda joyyos
        clc
        adc joyxos
        tax
        dex

        ; Set the char
        lda #'+'
        sta joychr,x

        ; Determine the color based on whether or not fire is pressed
        lda joystick.getstate.fire$
        beq @no_fire
        lda #color.red$
        jmp @set_fire
@no_fire
        lda #color.white$
@set_fire
        sta console.setcharactercolor.color$
        jsr console.setcharactercolor$

        ; Draw the grid
        ldx #8
        stx joyctr
@draw
        ldx joyctr
        lda joyrow,x
        sta console.setrow.row$
        jsr console.setrow$
        ldx joyctr
        lda joycol,x
        clc
        adc joyos
        sta console.setcolumn.column$
        jsr console.setcolumn$
        ldx joyctr
        lda joychr,x
        sta console.writechr.char$
        jsr console.writechr$

        ldx joyctr
        beq @drawdone
        dec joyctr
        jmp @draw
@drawdone

        rts

Do3

        ; If running from an emulator, need to ensure that Mouse (1351) is
        ; defined as the first control port and enable mouse grab (Ctrl+M).

        jsr graphics.enter$
        jsr graphics.setbitmapmode$

        ; Copy the mouse pointer data to the sprite memory
        lda #<mouseptr
        sta memory.copy.source$
        lda #>mouseptr
        sta memory.copy.source$+1
        lda #<graphics.sprite1address$
        sta memory.copy.destination$
        lda #>graphics.sprite1address$
        sta memory.copy.destination$+1
        lda #63
        sta memory.copy.length$
        jsr memory.copy$

        ; Set Multicolor Sprite
        lda #graphics.sprite1$
        sta graphics.setspritemulticolor.number$
        jsr graphics.setspritemulticolor$

        ; Set the Sprite's color
        lda #graphics.sprite1$
        sta graphics.setspritecolor.number$
        lda #color.black$
        sta graphics.setspritecolor.color$
        jsr graphics.setspritecolor$

        ; Set the multicolor values
        lda #color.white$
        sta graphics.spritemulticolor1address$
        lda #color.lightgrey$
        sta graphics.spritemulticolor2address$

;        ; Set the sprites location (SEE BELOW)
;        lda #graphics.sprite1$
;        sta graphics.setspritelocation.number$
;        lda mousex
;        sta graphics.setspritelocation.x$
;        lda mousex+1
;        sta graphics.setspritelocation.x$+1
;        lda mousey
;        sta graphics.setspritelocation.y$
;        lda mousey+1
;        sta graphics.setspritelocation.y$+1
;        jsr graphics.setspritelocation$

        ; Unstretch the sprite
        lda #graphics.sprite1$
        sta graphics.unstretchspritehorizontally.number$
        jsr graphics.unstretchspritehorizontally$

        ; Unstretch the sprite
        lda #graphics.sprite1$
        sta graphics.unstretchspritevertically.number$
        jsr graphics.unstretchspritevertically$
        
        ; Show the sprite
        lda #graphics.sprite1$
        sta graphics.showsprite.number$
        jsr graphics.showsprite$        

        lda #<mxinfo
        sta console.writestr.straddress$
        lda #>mxinfo
        sta console.writestr.straddress$+1
        jsr console.writestr$

        lda #<myinfo
        sta console.writestr.straddress$
        lda #>myinfo
        sta console.writestr.straddress$+1
        jsr console.writestr$

        lda #<mlbinfo
        sta console.writestr.straddress$
        lda #>mlbinfo
        sta console.writestr.straddress$+1
        jsr console.writestr$

        lda #<mrbinfo
        sta console.writestr.straddress$
        lda #>mrbinfo
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr console.writeln$
        lda #<anykey
        sta console.writestr.straddress$
        lda #>anykey
        sta console.writestr.straddress$+1
        jsr console.writestr$


@loop
        jsr mouse.getstate$

        lda mouse.getstate.deltax$
        sta math.add16.addend1$
        jsr CheckNeg
        sta math.add16.addend1$+1
        lda mousex
        sta math.add16.addend2$
        lda mousex+1
        sta math.add16.addend2$+1
        jsr math.add16$
        lda math.add16.sum$
        sta mousex
        lda math.add16.sum$+1
        sta mousex+1

        lda #$ff
        cmp mousex+1 ; If X(hi) != $ff the mousexminok
        bne @mousexminok
        lda #$00
        sta mousex
        sta mousex+1
@mousexminok

        lda #$01
        cmp mousex+1
        bne @mousexmaxok
        lda #$3f
        cmp mousex ; If #$3f <= X(lo) then mousexmaxok
        bcs @mousexmaxok
        sta mousex
@mousexmaxok

        lda mouse.getstate.deltay$
        sta math.add16.addend1$
        jsr CheckNeg
        sta math.add16.addend1$+1
        lda mousey
        sta math.add16.addend2$
        lda mousey+1
        sta math.add16.addend2$+1
        jsr math.add16$
        lda math.add16.sum$
        sta mousey
        lda math.add16.sum$+1
        sta mousey+1
        
        lda #$00
        cmp mousey+1 ; If Y(hi) = 0 the mouseyminok
        beq @mouseyminok
        sta mousey
        sta mousey+1
@mouseyminok

        lda #199 ; If 199 <= Y then mouseymaxok
        cmp mousey
        bcs @mouseymaxok
        sta mousey
@mouseymaxok

        ; Display X
        lda #0
        sta console.setrow.row$
        jsr console.setrow$
        lda #3
        sta console.setcolumn.column$
        jsr console.setcolumn$
        lda mousex
        sta console.writeint16.integer$
        lda mousex+1
        sta console.writeint16.integer$+1
        jsr console.writeint16$
        lda #' '
        sta console.writechr.char$
        jsr console.writechr$

        ; Display Y
        lda #1
        sta console.setrow.row$
        jsr console.setrow$
        lda #3
        sta console.setcolumn.column$
        jsr console.setcolumn$
        lda mousey
        sta console.writeint16.integer$
        lda mousey+1
        sta console.writeint16.integer$+1
        jsr console.writeint16$
        lda #' '
        sta console.writechr.char$
        jsr console.writechr$

        ; Add 24
        lda mousex
        sta math.add16.addend1$
        lda mousex+1
        sta math.add16.addend1$+1
        lda #24
        sta math.add16.addend2$
        lda #0
        sta math.add16.addend2$+1
        jsr math.add16$
        lda math.add16.sum$
        sta mousex2
        lda math.add16.sum$+1
        sta mousex2+1

        ; Add 50
        lda mousey
        sta math.add16.addend1$
        lda mousey+1
        sta math.add16.addend1$+1
        lda #50
        sta math.add16.addend2$
        lda #0
        sta math.add16.addend2$+1
        jsr math.add16$
        lda math.add16.sum$
        sta mousey2
        lda math.add16.sum$+1
        sta mousey2+1

        ; Set the sprites location
        lda #graphics.sprite1$
        sta graphics.setspritelocation.number$
        lda mousex2
        sta graphics.setspritelocation.x$
        lda mousex2+1
        sta graphics.setspritelocation.x$+1
        lda mousey2
        sta graphics.setspritelocation.y$
        lda mousey2+1
        sta graphics.setspritelocation.y$+1
        jsr graphics.setspritelocation$

        ; Display Left Button
        lda #2
        sta console.setrow.row$
        jsr console.setrow$
        lda #13
        sta console.setcolumn.column$
        jsr console.setcolumn$
        lda mouse.getstate.leftbutton$
        sta console.writeint8.integer$
        jsr console.writeint8$

        ; Display Right Button
        lda #3
        sta console.setrow.row$
        jsr console.setrow$
        lda #14
        sta console.setcolumn.column$
        jsr console.setcolumn$
        lda mouse.getstate.rightbutton$
        sta console.writeint8.integer$
        jsr console.writeint8$

        ; Detect key press
        jsr console.readkey$
        lda console.readkey.state$
        cmp #console.readkey.state.ok$
        beq @done

        jsr time.halt$  ; For some reason readkey$ was preventing 
                        ; mouse.getstate$ from reporting changes in deltaX/Y.
                        ; Calling halt worked around the issue.

        jmp @loop

@done

        ; Hide the sprite
        lda #graphics.sprite1$
        sta graphics.hidesprite.number$
        jsr graphics.hidesprite$
        
        jsr graphics.leave$

        rts

CheckNeg
        ; If A is neg set sign = $ff, otherwise, $00
        bmi @neg
        lda #$00
        jmp @set
@neg
        lda #$ff
@set
        rts

title   text 'Input', console.newline$, console.newline$
        text 'Please select one of the options below:', console.newline$, console.null$

options text '1. Keyboard', console.newline$
        text '2. Joysticks', console.newline$
        text '3. Mouse', console.newline$
        text 'x. Exit', console.newline$
        text console.null$

anykey  text 'Press any key to go back', console.null$

filename word $0000
fnnext  text 'DEMO7-X', console.null$
fnback  text 'MAIN', console.null$
failed  text 'Failed to load ', console.null$

mouseptr byte $a0,$00,$00,$98,$00,$00,$96
         byte $00,$00,$95,$80,$00,$95,$60
         byte $00,$95,$58,$00,$95,$56,$00
         byte $95,$55,$80,$95,$55,$60,$95
         byte $55,$58,$95,$55,$60,$95,$55
         byte $b0,$95,$56,$c0,$95,$5b,$00
         byte $95,$56,$00,$96,$96,$00,$9b
         byte $95,$80,$ac,$e5,$80,$f0,$25
         byte $80,$00,$3a,$c0,$00,$0f,$00
mousex   word $00a2
mousey   word $0063
mousex2  word $0000
mousey2  word $0000
mxinfo   text 'X: ', console.newline$, console.null$
myinfo   text 'Y: ', console.newline$, console.null$
mlbinfo  text 'Left Button: ', console.newline$, console.null$
mrbinfo  text 'Right Button: ', console.newline$, console.null$

joys    text '    Joystick1       Joystick2', console.null$
joyos   byte $00
joyctr  byte $00
joyxos  byte $00
joyyos  byte $00
;joycol  byte 3, 6, 9
;        byte 3, 6, 9
;        byte 3, 6, 9
;joyrow  byte 3, 3, 3
;        byte 6, 6, 6
;        byte 9, 9, 9
joycol  byte 4, 8, 12
        byte 4, 8, 12
        byte 4, 8, 12
joyrow  byte 4, 4, 4
        byte 8, 8, 8
        byte 12, 12, 12
joychr  text ' ', ' ', ' '
        text ' ', ' ', ' '
        text ' ', ' ', ' '

space   text 'Press space to go back', console.null$
key     text 'Key Pressed: ', console.newline$, console.newline$, console.null$
shift1  text 'Shift 1: ', console.newline$, console.newline$, console.null$
shift2  text 'Shift 2: ', console.newline$, console.newline$, console.null$
keybuf  text '                                        ', console.null$
keyinfo byte $00
f1      text 'F1 ', console.null$
f3      text 'F3 ', console.null$
f5      text 'F5 ', console.null$
f7      text 'F7 ', console.null$
insert_delete   text 'INST/DEL ', console.null$
left_right      text 'LFT/RGHT ', console.null$
up_down         text 'UP/DWN ', console.null$
return          text 'RETURN ', console.null$
clear_home      text 'CLR/HOME ', console.null$
commodore       text 'C', 61,' ', console.null$
control         text 'CTRL ', console.null$
left_shift      text 'LSHIFT ', console.null$
right_shift     text 'RSHIFT ', console.null$
run_stop        text 'RUN/STOP ', console.null$
