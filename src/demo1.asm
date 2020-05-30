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

        ; Prompt user for input
        lda #<chrpmt
        sta console.writestr.straddress$
        lda #>chrpmt
        sta console.writestr.straddress$+1
        jsr console.writestr$

        ; Read the character
        jsr console.readchr$
        lda console.readchr.char$
        sta chr
        
        jsr console.writeln$
        jsr console.writeln$

        lda #<chrtxt
        sta console.writestr.straddress$
        lda #>chrtxt
        sta console.writestr.straddress$+1
        jsr console.writestr$        

        ; Write the character
        lda chr
        sta console.writechr.char$
        jsr console.writechr$

        jsr PressAnyKey

        rts

Do2

        jsr console.clear$

        ; Prompt user for input
        lda #<strpmt
        sta console.writestr.straddress$
        lda #>strpmt
        sta console.writestr.straddress$+1
        jsr console.writestr$

        ; Read the string
        jsr console.readstr$
        lda console.readstr.straddress$
        sta str
        lda console.readstr.straddress$+1
        sta str+1
        
        jsr console.writeln$
        jsr console.writeln$

        lda #<strtxt
        sta console.writestr.straddress$
        lda #>strtxt
        sta console.writestr.straddress$+1
        jsr console.writestr$        

        ; Write the string
        lda str
        sta console.writestr.straddress$
        lda str+1
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr PressAnyKey

        ; Destory the string
        lda str
        sta memory.deallocate.address$
        lda str+1
        sta memory.deallocate.address$+1
        jsr memory.deallocate$

        rts

Do3

        ; Integers are unsigned and negative numbers are not supported

        jsr console.clear$

        ; Prompt user for input
        lda #<intpmt
        sta console.writestr.straddress$
        lda #>intpmt
        sta console.writestr.straddress$+1
        jsr console.writestr$

        ; Read the integer
        jsr console.readint32$
        lda console.readint32.integer$
        sta int
        lda console.readint32.integer$+1
        sta int+1
        lda console.readint32.integer$+2
        sta int+2
        lda console.readint32.integer$+3
        sta int+3
        
        jsr console.writeln$
        jsr console.writeln$

        lda #<inttxt
        sta console.writestr.straddress$
        lda #>inttxt
        sta console.writestr.straddress$+1
        jsr console.writestr$        

        ; Write the integer
        lda int
        sta console.writeint32.integer$
        lda int+1
        sta console.writeint32.integer$+1
        lda int+2
        sta console.writeint32.integer$+2
        lda int+3
        sta console.writeint32.integer$+3
        jsr console.writeint32$

        jsr PressAnyKey

        rts

Do4

        ; Note you can also set the row and column using console.setrow$
        ; and console.setcolumn$

        jsr console.clear$

        ; Prompt user for input
        lda #<enter
        sta console.writestr.straddress$
        lda #>enter
        sta console.writestr.straddress$+1
        jsr console.writestr$

        ; Read the string
        jsr console.readstr$
        lda console.readstr.straddress$
        sta str
        lda console.readstr.straddress$+1
        sta str+1

        ; Get the current row number
        jsr console.getrow$
        lda console.getrow.row$
        sta row
        
        ; Get the current column number
        jsr console.getcolumn$
        lda console.getcolumn.column$
        sta col
        
        jsr console.writeln$
        jsr console.writeln$

        lda #<rowtxt
        sta console.writestr.straddress$
        lda #>rowtxt
        sta console.writestr.straddress$+1
        jsr console.writestr$        

        ; Write the current row number
        lda row
        sta console.writeint8.integer$
        jsr console.writeint8$
        jsr console.writeln$

        lda #<coltxt
        sta console.writestr.straddress$
        lda #>coltxt
        sta console.writestr.straddress$+1
        jsr console.writestr$        

        ; Write the current column number
        lda col
        sta console.writeint8.integer$
        jsr console.writeint8$
        jsr console.writeln$

        jsr PressAnyKey

        ; Destory the string
        lda str
        sta memory.deallocate.address$
        lda str+1
        sta memory.deallocate.address$+1
        jsr memory.deallocate$

        rts

Do5

        ; See the color type for all of the available colors

        jsr console.clear$

        ; Prompt and set the border color
        ldx #<brtxt
        ldy #>brtxt
        jsr ColorPrompt
        lda color
        sta console.setbordercolor.color$
        jsr console.setbordercolor$

        ; Prompt and set the background color
        ldx #<bktxt
        ldy #>bktxt
        jsr ColorPrompt
        lda color
        sta bkcolor
        sta console.setbackgroundcolor.color$
        jsr console.setbackgroundcolor$
       
        ; Prompt and set the foreground color
        ldx #<frtxt
        ldy #>frtxt
        jsr ColorPrompt
        lda color
        sta console.setforegroundcolor.color$
        jsr console.setforegroundcolor$

        ; Make the character color different from the back color
        lda bkcolor
        clc
        adc #1
        sta console.setcharactercolor.color$
        jsr console.setcharactercolor$

        jsr PressAnyKey

        ; Reset the colors
        lda #color.black$
        sta console.setbordercolor.color$
        jsr console.setbordercolor$

        lda #color.black$
        sta console.setbackgroundcolor.color$
        jsr console.setbackgroundcolor$

        lda #color.white$
        sta console.setforegroundcolor.color$
        jsr console.setforegroundcolor$

        lda #color.white$
        sta console.setcharactercolor.color$
        jsr console.setcharactercolor$

        rts

ColorPrompt

        stx console.writestr.straddress$
        sty console.writestr.straddress$+1
        jsr console.writestr$

        lda #<clrtxt
        sta console.writestr.straddress$
        lda #>clrtxt
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr console.readint8$
        lda console.readint8.integer$
        sta color

        jsr console.writeln$

        rts

Do6

        ; Inverting colors uese the inverted character set (range 128-255)
        ; The back and fore colors are effectly switched

        jsr console.clear$

        lda #$01
        sta console.setcharactercolor.color$
        jsr console.setcharacterinverted$

        jsr PressAnyKey

        lda #$00
        sta console.setcharactercolor.color$
        jsr console.setcharacterinverted$

        rts


title   text 'Console', console.newline$, console.newline$
        text 'Please select one of the options below:', console.newline$, console.null$

options text '1. Read/Write Characters', console.newline$
        text '2. Read/Write Strings', console.newline$
        text '3. Read/Write Integers', console.newline$
        text '4. Row/Column Numbers', console.newline$
        text '5. Set Colors', console.newline$
        text '6. Invert Characters', console.newline$
        text 'x. Exit', console.newline$
        text console.null$

anykey  text 'Press any key to go back', console.null$

filename word $0000
fnnext  text 'DEMO1-X', console.null$
fnback  text 'MAIN', console.null$
failed  text 'Failed to load ', console.null$

chrpmt  text 'Press a key: ', console.null$
chrtxt  text 'You pressed: ', console.null$
chr     byte $00

strpmt  text 'Enter some text: ', console.null$
strtxt  text 'You entered: ', console.null$
str     word $0000

intpmt  text 'Enter an integer: ', console.null$
inttxt  text 'You entered: ', console.null$
int     byte $00, $00, $00, $00 ; int8 - 1 byte
                                ; int16 - 2 bytes (1 word)
                                ; int32 - 4 bytes (2 words)

enter   text 'Enter some text: ', console.null$
rowtxt  text 'Current Row: ', console.null$
coltxt  text 'Current Column: ', console.null$
row     byte $00
col     byte $00

bktxt   text 'Enter back', console.null$
brtxt   text 'Enter border', console.null$
frtxt   text 'Enter fore', console.null$
clrtxt  text ' color (0-15): ', console.null$
color   byte $00
bkcolor byte $00

