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

        cmp #'4'
        bne @not4
        jsr Do4
@not4

        cmp #'5'
        bne @not5
        jsr Do5
@not5

        cmp #'6'
        bne @not6
        jsr Do6
@not6

        cmp #'7'
        bne @not7
        jsr Do7
@not7

        cmp #'8'
        bne @not8
        jsr Do8
@not8

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

        jsr graphics.enter$

        ;jsr console.clear$
        ;jsr graphics.clear$
        ;jsr graphics.sethiresmode$

        lda #' '
        sta promptx+7
        sta prompty+7

        ; Prompt for X
        lda #<promptx
        sta console.writestr.straddress$
        lda #>promptx
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr console.readint16$
        lda console.readint16.integer$
        sta x1
        lda console.readint16.integer$+1
        sta x1+1

        jsr console.writeln$

        ; Prompt for Y
        lda #<prompty
        sta console.writestr.straddress$
        lda #>prompty
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr console.readint16$
        lda console.readint16.integer$
        sta y1
        lda console.readint16.integer$+1
        sta y1+1

        jsr console.writeln$

        ; Draw the pixel
        lda x1
        sta graphics.setpixel.x$
        lda x1+1
        sta graphics.setpixel.x$+1
        lda y1
        sta graphics.setpixel.y$
        lda y1+1
        sta graphics.setpixel.y$+1
        lda #$01
        sta graphics.setpixel.color$
        jsr graphics.setpixel$

        jsr PressAnyKey

        ;jsr graphics.settextmode$
        jsr graphics.leave$

        rts

PromptForLineBoxFill

        lda #'1'
        sta promptx+7
        sta prompty+7

        ; Prompt for X
        lda #<promptx
        sta console.writestr.straddress$
        lda #>promptx
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr console.readint16$
        lda console.readint16.integer$
        sta x1
        lda console.readint16.integer$+1
        sta x1+1

        jsr console.writeln$

        ; Prompt for Y
        lda #<prompty
        sta console.writestr.straddress$
        lda #>prompty
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr console.readint16$
        lda console.readint16.integer$
        sta y1
        lda console.readint16.integer$+1
        sta y1+1

        jsr console.writeln$

        lda #'2'
        sta promptx+7
        sta prompty+7

        ; Prompt for X
        lda #<promptx
        sta console.writestr.straddress$
        lda #>promptx
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr console.readint16$
        lda console.readint16.integer$
        sta x2
        lda console.readint16.integer$+1
        sta x2+1

        jsr console.writeln$

        ; Prompt for Y
        lda #<prompty
        sta console.writestr.straddress$
        lda #>prompty
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr console.readint16$
        lda console.readint16.integer$
        sta y2
        lda console.readint16.integer$+1
        sta y2+1

        jsr console.writeln$

        rts

Do2

        jsr graphics.enter$

        jsr PromptForLineBoxFill

        ; Draw the pixel
        lda x1
        sta graphics.drawline.x1$
        lda x1+1
        sta graphics.drawline.x1$+1
        lda y1
        sta graphics.drawline.y1$
        lda y1+1
        sta graphics.drawline.y1$+1
        lda x2
        sta graphics.drawline.x2$
        lda x2+1
        sta graphics.drawline.x2$+1
        lda y2
        sta graphics.drawline.y2$
        lda y2+1
        sta graphics.drawline.y2$+1
        lda #$01
        sta graphics.drawline.color$
        jsr graphics.drawline$

        jsr PressAnyKey

        jsr graphics.leave$

        rts

Do3

        jsr graphics.enter$

        jsr PromptForLineBoxFill

        ; Draw the pixel
        lda x1
        sta graphics.drawbox.x1$
        lda x1+1
        sta graphics.drawbox.x1$+1
        lda y1
        sta graphics.drawbox.y1$
        lda y1+1
        sta graphics.drawbox.y1$+1
        lda x2
        sta graphics.drawbox.x2$
        lda x2+1
        sta graphics.drawbox.x2$+1
        lda y2
        sta graphics.drawbox.y2$
        lda y2+1
        sta graphics.drawbox.y2$+1
        lda #$01
        sta graphics.drawbox.color$
        jsr graphics.drawbox$

        jsr PressAnyKey

        jsr graphics.leave$

        rts

Do4

        jsr graphics.enter$

        jsr PromptForLineBoxFill

        ; Draw the pixel
        lda x1
        sta graphics.drawfill.x1$
        lda x1+1
        sta graphics.drawfill.x1$+1
        lda y1
        sta graphics.drawfill.y1$
        lda y1+1
        sta graphics.drawfill.y1$+1
        lda x2
        sta graphics.drawfill.x2$
        lda x2+1
        sta graphics.drawfill.x2$+1
        lda y2
        sta graphics.drawfill.y2$
        lda y2+1
        sta graphics.drawfill.y2$+1
        lda #$01
        sta graphics.drawfill.color$
        jsr graphics.drawfill$

        jsr PressAnyKey

        jsr graphics.leave$

        rts

PromptForCircle

        lda #' '
        sta promptx+7
        sta prompty+7

        ; Prompt for X
        lda #<promptx
        sta console.writestr.straddress$
        lda #>promptx
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr console.readint16$
        lda console.readint16.integer$
        sta x1
        lda console.readint16.integer$+1
        sta x1+1

        jsr console.writeln$

        ; Prompt for Y
        lda #<prompty
        sta console.writestr.straddress$
        lda #>prompty
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr console.readint16$
        lda console.readint16.integer$
        sta y1
        lda console.readint16.integer$+1
        sta y1+1

        jsr console.writeln$

        ; Prompt for Radius
        lda #<promptr
        sta console.writestr.straddress$
        lda #>promptr
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr console.readint8$
        lda console.readint8.integer$
        sta radius

        jsr console.writeln$

        rts

Do5

        jsr graphics.enter$

        jsr PromptForCircle

        ; Draw the pixel
        lda x1
        sta graphics.drawcircle.xcenter$
        lda x1+1
        sta graphics.drawcircle.xcenter$+1
        lda y1
        sta graphics.drawcircle.ycenter$
        lda y1+1
        sta graphics.drawcircle.ycenter$+1
        lda radius
        sta graphics.drawcircle.radius$
        lda #$01
        sta graphics.drawcircle.color$
        jsr graphics.drawcircle$

        jsr PressAnyKey

        jsr graphics.leave$

        rts

Do6

        ; Normally, you'll want to load the image into memory before entering graphics mode.
        ; It is being done this way here for demo purposes.

        jsr graphics.enter$
        jsr graphics.setbitmapmode$

        ; Read the sprites into memory
        lda #<fnsprite
        sta disk.readfile.filename$
        lda #>fnsprite
        sta disk.readfile.filename$+1
        lda #<graphics.sprite1address$ ;-2
        sta disk.readfile.address$
        lda #>graphics.sprite1address$ ;-1
        sta disk.readfile.address$+1
        jsr disk.readfile$

        ; Show the sprite
        lda #graphics.sprite1$
        sta graphics.showsprite.number$
        jsr graphics.showsprite$
       
        ; Set the sprite's location
        lda #graphics.sprite1$
        sta graphics.setspritelocation.number$
        lda #$01
        sta graphics.setspritelocation.x$
        lda #$01
        sta graphics.setspritelocation.x$+1
        lda #$32
        sta graphics.setspritelocation.y$
        lda #$00
        sta graphics.setspritelocation.y$+1
        jsr graphics.setspritelocation$

        ; Set the sprite's color
        lda #graphics.sprite1$
        sta graphics.setspritecolor.number$
        lda #color.white$
        sta graphics.setspritecolor.color$
        jsr graphics.setspritecolor$

        ; Set sprite in HiRes mode
        lda #graphics.sprite1$
        sta graphics.setspritehires.number$
        jsr graphics.setspritehires$

        ; Unstretch the sprite
        lda #graphics.sprite1$
        sta graphics.unstretchspritehorizontally.number$
        jsr graphics.unstretchspritehorizontally$
        lda #graphics.sprite1$
        sta graphics.unstretchspritevertically.number$
        jsr graphics.unstretchspritevertically$

        ; Set Multicolor Sprite
        lda #graphics.sprite2$
        sta graphics.setspritemulticolor.number$
        jsr graphics.setspritemulticolor$

        ; Set the Sprite's color
        lda #graphics.sprite2$
        sta graphics.setspritecolor.number$
        lda #color.white$
        sta graphics.setspritecolor.color$
        jsr graphics.setspritecolor$

        ; Set the multicolor values
        lda #color.lightgrey$
        sta graphics.spritemulticolor1address$
        lda #color.blue$
        sta graphics.spritemulticolor2address$

        ; Set the sprites location
        lda #graphics.sprite2$
        sta graphics.setspritelocation.number$
        lda #$2c
        sta graphics.setspritelocation.x$
        lda #$00
        sta graphics.setspritelocation.x$+1
        lda #150
        sta graphics.setspritelocation.y$
        lda #$00
        sta graphics.setspritelocation.y$+1
        jsr graphics.setspritelocation$

        ; Stretch the sprite
        lda #graphics.sprite2$
        sta graphics.stretchspritehorizontally.number$
        jsr graphics.stretchspritehorizontally$

        ; Stretch the sprite
        lda #graphics.sprite2$
        sta graphics.stretchspritevertically.number$
        jsr graphics.stretchspritevertically$
        
        ; Show the sprite
        lda #graphics.sprite2$
        sta graphics.showsprite.number$
        jsr graphics.showsprite$

        jsr PressAnyKey

        ; Hide the sprite
        lda #graphics.sprite1$
        sta graphics.hidesprite.number$
        jsr graphics.hidesprite$
       
        ; Hide the sprite
        lda #graphics.sprite2$
        sta graphics.hidesprite.number$
        jsr graphics.hidesprite$
       
        jsr graphics.leave$

        rts

Do7

        ; Normally, you'll want to load the image into memory before entering graphics mode.
        ; It is being done this way here for demo purposes.

        jsr graphics.enter$

        ; Read the image into memory
        lda #<fnhires
        sta disk.readfile.filename$
        lda #>fnhires
        sta disk.readfile.filename$+1
        lda #<graphics.imageaddress$ ;-2
        sta disk.readfile.address$
        lda #>graphics.imageaddress$ ;-1
        sta disk.readfile.address$+1
        jsr disk.readfile$

        jsr graphics.sethiresmode$

        jsr PressAnyKey

        jsr graphics.leave$

        rts
        
Do8

        ; Normally, you'll want to load the image into memory before entering graphics mode.
        ; It is being done this way here for demo purposes.

        jsr graphics.enter$

        ; Read the image into memory
        lda #<fnmcolor
        sta disk.readfile.filename$
        lda #>fnmcolor
        sta disk.readfile.filename$+1
        lda #<graphics.imageaddress$ ;-2
        sta disk.readfile.address$
        lda #>graphics.imageaddress$ ;-1
        sta disk.readfile.address$+1
        jsr disk.readfile$

        jsr graphics.setmulticolormode$

        jsr PressAnyKey

        jsr graphics.leave$

        rts
        


title   text 'Graphics', console.newline$, console.newline$
        text 'Please select one of the options below:', console.newline$, console.null$

options text '1. Draw Pixel', console.newline$
        text '2. Draw Line', console.newline$
        text '3. Draw Box', console.newline$
        text '4. Draw Fill', console.newline$
        text '5. Draw Circle', console.newline$
        text '6. Sprites', console.newline$
        text '7. HiRes Image', console.newline$
        text '8. Multicolor Image', console.newline$
        text 'x. Exit', console.newline$
        text console.null$

anykey  text 'Press any key to go back', console.null$

filename word $0000
fnnext  text 'DEMO5-X', console.null$
fnback  text 'MAIN', console.null$
failed  text 'Failed to load ', console.null$

promptx text 'Enter X  ', console.null$
prompty text 'Enter Y  ', console.null$
promptr text 'Enter Radius  ', console.null$
x1      word $0000
x2      word $0000
y1      word $0000
y2      word $0000
radius  byte $00

fnsprite  text 'SPRITEDEMO', console.null$
fnmcolor  text 'MCOLORDEMO', console.null$
fnhires   text 'HIRESDEMO', console.null$


