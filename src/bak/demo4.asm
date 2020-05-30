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

        ; Prompt user to enter a character
        lda #<crchar
        sta console.writestr.straddress$
        lda #>crchar
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr console.readchr$
        sta crchr

        jsr console.writeln$

        ; Prompt user to enter the length
        lda #<crlen
        sta console.writestr.straddress$
        lda #>crlen
        sta console.writestr.straddress$+1
        jsr console.writestr$
        
        ; For demo purposes, only allow for strings up to 255 characters
        jsr console.readint8$
        lda console.readint8.integer$
        sta crln
        lda #$00
        sta crln+1

        jsr console.writeln$

        ; Create the string
        lda crchr
        sta string.create.character$
        lda crln
        sta string.create.length$
        lda crln+1
        sta string.create.length$+1
        jsr string.create$
        lda string.create.address$
        sta crstr
        lda string.create.address$+1
        sta crstr+1

        ; Print the string
        lda #<crtext
        sta console.writestr.straddress$
        lda #>crtext
        sta console.writestr.straddress$+1
        jsr console.writestr$

        lda crstr
        sta console.writestr.straddress$
        lda crstr+1
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr console.writeln$

        jsr PressAnyKey

        ; Destory the string
        lda crstr
        sta memory.deallocate.address$
        lda crstr+1
        sta memory.deallocate.address$+1
        jsr memory.deallocate$

        rts

Do2

        jsr console.clear$


        ; Prompt user to enter string 1
        lda #<eqtxt
        sta console.writestr.straddress$
        lda #>eqtxt
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr console.readstr$
        lda console.readstr.straddress$
        sta eqstr1
        lda console.readstr.straddress$+1
        sta eqstr1+1

        jsr console.writeln$

        ; Prompt user to enter string 2
        lda #<eqtxt
        sta console.writestr.straddress$
        lda #>eqtxt
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr console.readstr$
        lda console.readstr.straddress$
        sta eqstr2
        lda console.readstr.straddress$+1
        sta eqstr2+1

        jsr console.writeln$

        lda #<eqfnl
        sta console.writestr.straddress$
        lda #>eqfnl
        sta console.writestr.straddress$+1
        jsr console.writestr$

        ; Compare the strings
        lda eqstr1
        sta string.isequal.address1$
        lda eqstr1+1
        sta string.isequal.address1$+1
        lda eqstr2
        sta string.isequal.address2$
        lda eqstr2+1
        sta string.isequal.address2$+1
        jsr string.isequal$

        ldx #<notext
        ldy #>notext

        lda string.isequal.value$
        cmp #$01
        bne @PrintEqual
        ldx #<eqtext
        ldy #>eqtext
@PrintEqual
        stx console.writestr.straddress$
        sty console.writestr.straddress$+1
        jsr console.writestr$

        jsr PressAnyKey

        ; Destory the string
        lda eqstr1
        sta memory.deallocate.address$
        lda eqstr1+1
        sta memory.deallocate.address$+1
        jsr memory.deallocate$

        ; Destory the string
        lda eqstr2
        sta memory.deallocate.address$
        lda eqstr2+1
        sta memory.deallocate.address$+1
        jsr memory.deallocate$

        rts

Do3

        jsr console.clear$

        ; Prompt user to enter a string
        lda #<lntxt
        sta console.writestr.straddress$
        lda #>lntxt
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr console.readstr$
        lda console.readstr.straddress$
        sta lnstr
        lda console.readstr.straddress$+1
        sta lnstr+1

        jsr console.writeln$

        lda #<lntext
        sta console.writestr.straddress$
        lda #>lntext
        sta console.writestr.straddress$+1
        jsr console.writestr$

        ; Find the get lenght of the string
        lda lnstr
        sta string.getlength.address$
        lda lnstr+1
        sta string.getlength.address$+1
        jsr string.getlength$
        lda string.getlength.length$
        sta console.writeint16.integer$
        lda string.getlength.length$+1
        sta console.writeint16.integer$+1
        jsr console.writeint16$

        jsr console.writeln$

        jsr PressAnyKey

        ; Destory the string
        lda lnstr
        sta memory.deallocate.address$
        lda lnstr+1
        sta memory.deallocate.address$+1
        jsr memory.deallocate$

        rts

Do4

        jsr console.clear$

        ; Prompt user to enter a string
        lda #<cptxt
        sta console.writestr.straddress$
        lda #>cptxt
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr console.readstr$
        lda console.readstr.straddress$
        sta cpstr1
        lda console.readstr.straddress$+1
        sta cpstr1+1

        jsr console.writeln$

        lda #<cptext
        sta console.writestr.straddress$
        lda #>cptext
        sta console.writestr.straddress$+1
        jsr console.writestr$

        ; Copy the string
        lda cpstr1
        sta string.copy.srcaddress$
        lda cpstr1+1
        sta string.copy.srcaddress$+1
        jsr string.copy$
        lda string.copy.dstaddress$
        sta cpstr2
        lda string.copy.dstaddress$+1
        sta cpstr2+1

        lda cpstr2
        sta console.writestr.straddress$
        lda cpstr2+1
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr console.writeln$

        jsr PressAnyKey

        ; Destory the string
        lda cpstr1
        sta memory.deallocate.address$
        lda cpstr1+1
        sta memory.deallocate.address$+1
        jsr memory.deallocate$

        ; Destory the string
        lda cpstr2
        sta memory.deallocate.address$
        lda cpstr2+1
        sta memory.deallocate.address$+1
        jsr memory.deallocate$

        rts

Do5

        jsr console.clear$

        ; Prompt user to enter a string
        lda #<cntxt
        sta console.writestr.straddress$
        lda #>cntxt
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr console.readstr$
        lda console.readstr.straddress$
        sta cnstr1
        lda console.readstr.straddress$+1
        sta cnstr1+1

        jsr console.writeln$

        ; Prompt user to enter a string
        lda #<cntxt
        sta console.writestr.straddress$
        lda #>cntxt
        sta console.writestr.straddress$+1
        jsr console.writestr$
        
        jsr console.readstr$
        lda console.readstr.straddress$
        sta cnstr2
        lda console.readstr.straddress$+1
        sta cnstr2+1

        jsr console.writeln$

        lda #<cntext
        sta console.writestr.straddress$
        lda #>cntext
        sta console.writestr.straddress$+1
        jsr console.writestr$

        ; Concatenate the string
        lda cnstr1
        sta string.concat.srcaddress1$
        lda cnstr1+1
        sta string.concat.srcaddress1$+1
        lda cnstr2
        sta string.concat.srcaddress2$
        lda cnstr2+1
        sta string.concat.srcaddress2$+1
        jsr string.concat$
        lda string.concat.dstaddress$
        sta cnstr3
        lda string.concat.dstaddress$+1
        sta cnstr3+1

        lda cnstr3
        sta console.writestr.straddress$
        lda cnstr3+1
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr console.writeln$

        jsr PressAnyKey

        ; Destory the string
        lda cnstr1
        sta memory.deallocate.address$
        lda cnstr1+1
        sta memory.deallocate.address$+1
        jsr memory.deallocate$

        ; Destory the string
        lda cnstr2
        sta memory.deallocate.address$
        lda cnstr2+1
        sta memory.deallocate.address$+1
        jsr memory.deallocate$

        ; Destory the string
        lda cnstr3
        sta memory.deallocate.address$
        lda cnstr3+1
        sta memory.deallocate.address$+1
        jsr memory.deallocate$

        rts

Do6

        jsr console.clear$

        ; Prompt user to enter a string
        lda #<ixtxt1
        sta console.writestr.straddress$
        lda #>ixtxt1
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr console.readstr$
        lda console.readstr.straddress$
        sta ixstr1
        lda console.readstr.straddress$+1
        sta ixstr1+1

        jsr console.writeln$

        ; Prompt user to enter a string
        lda #<ixtxt2
        sta console.writestr.straddress$
        lda #>ixtxt2
        sta console.writestr.straddress$+1
        jsr console.writestr$
        
        jsr console.readstr$
        lda console.readstr.straddress$
        sta ixstr2
        lda console.readstr.straddress$+1
        sta ixstr2+1

        jsr console.writeln$

        ; Get the index of the string
        lda ixstr1
        sta string.indexof.address1$
        lda ixstr1+1
        sta string.indexof.address1$+1
        lda ixstr2
        sta string.indexof.address2$
        lda ixstr2+1
        sta string.indexof.address2$+1
        lda #$00
        sta string.indexof.index$
        sta string.indexof.index$+1
        jsr string.indexof$
        lda string.indexof.index$
        sta ixindex
        lda string.indexof.index$+1
        sta ixindex+1

        ; Check to see if the string was not found (index = $ffff)
        lda ixindex
        sta math.cmp16.num1$
        lda ixindex+1
        sta math.cmp16.num1$+1
        lda #$ff
        sta math.cmp16.num2$
        sta math.cmp16.num2$+1
        jsr math.cmp16$
        bne @Found
        jmp @NotFound
@Found

        lda #<ixtext
        sta console.writestr.straddress$
        lda #>ixtext
        sta console.writestr.straddress$+1
        jsr console.writestr$

        lda ixindex
        sta console.writeint16.integer$
        lda ixindex+1
        sta console.writeint16.integer$+1
        jsr console.writeint16$

        jsr console.writeln$

        jmp @Done

@NotFound

        lda #<ixno
        sta console.writestr.straddress$
        lda #>ixno
        sta console.writestr.straddress$+1
        jsr console.writestr$

@Done
        jsr PressAnyKey

        ; Destory the string
        lda ixstr1
        sta memory.deallocate.address$
        lda ixstr1+1
        sta memory.deallocate.address$+1
        jsr memory.deallocate$

        ; Destory the string
        lda ixstr2
        sta memory.deallocate.address$
        lda ixstr2+1
        sta memory.deallocate.address$+1
        jsr memory.deallocate$

        rts

title   text 'Strings', console.newline$, console.newline$
        text 'Please select one of the options below:', console.newline$, console.null$

options text '1. Create', console.newline$
        text '2. Is Equal', console.newline$
        text '3. Get Length', console.newline$
        text '4. Copy', console.newline$
        text '5. Concatenate', console.newline$
        text '6. Index Of String', console.newline$
        text 'x. Exit', console.newline$
        text console.null$

anykey  text 'Press any key to go back', console.null$

filename word $0000
fnnext  text 'DEMO4-X', console.null$
fnback  text 'MAIN', console.null$
failed  text 'Failed to load ', console.null$

crchar  text 'Enter a character: ', console.null$
crlen   text 'Enter the length: ', console.null$
crtext  text 'Created string: ', console.null$
crstr   word $0000
crchr   byte $00
crln    word $0000

eqtxt   text 'Enter some text: ', console.null$
eqstr1  word $0000
eqstr2  word $0000
eqfnl   text 'The two strings are ', console.null$
eqtext  text 'equal', console.null$
notext  text 'NOT equal', console.null$

lntxt   text 'Enter some text: ', console.null$
lnstr   word $0000
lntext  text 'The string has a length of: ', console.null$

cptxt   text 'Enter some text: ', console.null$
cpstr1  word $0000
cpstr2  word $0000
cptext  text 'Copied string: ', console.null$

cntxt   text 'Enter some text: ', console.null$
cnstr1  word $0000
cnstr2  word $0000
cnstr3  word $0000
cntext  text 'Concatenated string: ', console.null$

ixtxt1  text 'Enter some text: ', console.null$
ixtxt2  text 'Enter text to find: ', console.null$
ixstr1  word $0000
ixstr2  word $0000
ixindex word $0000
ixtext  text 'Index of string: ', console.null$
ixno    text 'String not found', console.newline$, console.null$
