incasm "kernel.asm"

main

        jsr console.clear$

        lda #<frames
        sta irq.install.address$
        lda #>frames
        sta irq.install.address$+1
        jsr irq.install$

        jsr samples

        jsr audio.digiend$

        jsr irq.uninstall$

        jsr graphics.leave$

        jsr PressAnyKey

        rts

PressAnyKey

        jsr console.writeln$
        jsr console.writeln$

        lda #<info
        sta console.writestr.straddress$
        lda #>info
        sta console.writestr.straddress$+1
        jsr console.writestr$

        lda #<anykey
        sta console.writestr.straddress$
        lda #>anykey
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr console.readchr$
        lda #$00

        rts

samples
        lda #<digisamplerate
        sta audio.digisamplerate$
        lda #>digisamplerate
        sta audio.digisamplerate$+1

        lda #<digistartaddress
        sta audio.digistartaddress$
        lda #>digistartaddress
        sta audio.digistartaddress$+1

        lda #<digiendaddress
        sta audio.digiendaddress$
        lda #>digiendaddress
        sta audio.digiendaddress$+1

@load
        lda #$00
        sta audio.digifinished$

        lda #$00
        sta audio.digipoint
        sta audio.digipoint+1
        sta audio.digistoplo+1
        sta audio.digistophi+1

        lda #<digistartaddress
        sta reu.loaddata.c64address$
        lda #>digistartaddress
        sta reu.loaddata.c64address$+1
        lda reuamem
        sta reu.loaddata.reuaddress$
        lda reuamem+1
        sta reu.loaddata.reuaddress$+1
        lda reuamem+2
        sta reu.loaddata.reuaddress$+2
        lda #<digilength
        sta reu.loaddata.length$
        lda #>digilength
        sta reu.loaddata.length$+1
        jsr reu.loaddata$

        lda digistarted
        beq @digistart

        ldy #<audio.digitable
        ldx #>audio.digitable
        jsr audio.digiplay$

        jmp @loop
@digistart
        jsr audio.digistart$
        lda #$01
        sta digistarted
        jsr audio.digistart$

        jsr irq.enable$ ; !!!

@loop
        lda mvdone
        bne @done

        lda audio.digifinished$
        cmp #$01
        bne @loop

        lda reuamem
        sta math.add24.addend1$
        lda reuamem+1
        sta math.add24.addend1$+1
        lda reuamem+2
        sta math.add24.addend1$+2
        lda #<digilength
        sta math.add24.addend2$
        lda #>digilength
        sta math.add24.addend2$+1
        lda #0
        sta math.add24.addend2$+2
        jsr math.add24$
        lda math.add24.sum$
        sta reuamem
        lda math.add24.sum$+1
        sta reuamem+1
        lda math.add24.sum$+2
        sta reuamem+2

        jmp @load
@done
        rts

frames
        inc wcounter
        lda wcounter
        cmp #maxwcount
        beq @ok
        jmp @done
@ok
        lda #00
        sta wcounter

        ; imageaddress (this takes 888 cycles)
        ; REU transfers at 1 MB/s
        lda #<imageaddress              ; 2 
        sta reu.loaddata.c64address$    ; 3
        lda #>imageaddress              ; 2 
        sta reu.loaddata.c64address$+1  ; 3
        lda reuvmem                      ; 4
        sta reu.loaddata.reuaddress$    ; 3
        lda reuvmem+1                    ; 4
        sta reu.loaddata.reuaddress$+1  ; 3
        lda reuvmem+2                    ; 4
        sta reu.loaddata.reuaddress$+2  ; 3
        lda #<imagelength               ; 2
        sta reu.loaddata.length$        ; 3
        lda #>imagelength               ; 2
        sta reu.loaddata.length$+1      ; 3
        jsr reu.loaddata$               ; 85 = 126

        ; imagelength
        lda reuvmem                      ; 4
        sta math.add24.addend1$         ; 3
        lda reuvmem+1                    ; 4
        sta math.add24.addend1$+1       ; 3
        lda reuvmem+2                    ; 4
        sta math.add24.addend1$+2       ; 3
        lda #<imagelength               ; 2
        sta math.add24.addend2$         ; 3
        lda #>imagelength               ; 2
        sta math.add24.addend2$+1       ; 3
        lda #0                          ; 2
        sta math.add24.addend2$+2       ; 3
        jsr math.add24$                 ; 39
        lda math.add24.sum$             ; 3
        sta reuvmem                      ; 4
        lda math.add24.sum$+1           ; 3
        sta reuvmem+1                    ; 4
        lda math.add24.sum$+2           ; 3
        sta reuvmem+2                    ; 4 = 96


        ; multivideoaddress
        lda #<multivideoaddress
        sta reu.loaddata.c64address$
        lda #>multivideoaddress
        sta reu.loaddata.c64address$+1
        lda reuvmem
        sta reu.loaddata.reuaddress$
        lda reuvmem+1
        sta reu.loaddata.reuaddress$+1
        lda reuvmem+2
        sta reu.loaddata.reuaddress$+2
        lda #<multivideolength
        sta reu.loaddata.length$
        lda #>multivideolength
        sta reu.loaddata.length$+1
        jsr reu.loaddata$

        ; multivideolength
        lda reuvmem
        sta math.add24.addend1$
        lda reuvmem+1
        sta math.add24.addend1$+1
        lda reuvmem+2
        sta math.add24.addend1$+2
        lda #<multivideolength
        sta math.add24.addend2$
        lda #>multivideolength
        sta math.add24.addend2$+1
        lda #0
        sta math.add24.addend2$+2
        jsr math.add24$
        lda math.add24.sum$
        sta reuvmem
        lda math.add24.sum$+1
        sta reuvmem+1
        lda math.add24.sum$+2
        sta reuvmem+2


        ; multicoloraddress
        lda #<multicoloraddress
        sta reu.loaddata.c64address$
        lda #>multicoloraddress
        sta reu.loaddata.c64address$+1
        lda reuvmem
        sta reu.loaddata.reuaddress$
        lda reuvmem+1
        sta reu.loaddata.reuaddress$+1
        lda reuvmem+2
        sta reu.loaddata.reuaddress$+2
        lda #<multicolorlength
        sta reu.loaddata.length$
        lda #>multicolorlength
        sta reu.loaddata.length$+1
        jsr reu.loaddata$

        ; multicolorlength
        lda reuvmem
        sta math.add24.addend1$
        lda reuvmem+1
        sta math.add24.addend1$+1
        lda reuvmem+2
        sta math.add24.addend1$+2
        lda #<multicolorlength
        sta math.add24.addend2$
        lda #>multicolorlength
        sta math.add24.addend2$+1
        lda #0
        sta math.add24.addend2$+2
        jsr math.add24$
        lda math.add24.sum$
        sta reuvmem
        lda math.add24.sum$+1
        sta reuvmem+1
        lda math.add24.sum$+2
        sta reuvmem+2


        ; multibgcoloraddress
        lda #<multibgcoloraddress
        sta reu.loaddata.c64address$
        lda #>multibgcoloraddress
        sta reu.loaddata.c64address$+1
        lda reuvmem
        sta reu.loaddata.reuaddress$
        lda reuvmem+1
        sta reu.loaddata.reuaddress$+1
        lda reuvmem+2
        sta reu.loaddata.reuaddress$+2
        lda #<multibgcolorlength
        sta reu.loaddata.length$
        lda #>multibgcolorlength
        sta reu.loaddata.length$+1
        jsr reu.loaddata$

        ; multibgcolorlength
        lda reuvmem
        sta math.add24.addend1$
        lda reuvmem+1
        sta math.add24.addend1$+1
        lda reuvmem+2
        sta math.add24.addend1$+2
        lda #<multibgcolorlength
        sta math.add24.addend2$
        lda #>multibgcolorlength
        sta math.add24.addend2$+1
        lda #0
        sta math.add24.addend2$+2
        jsr math.add24$
        lda math.add24.sum$
        sta reuvmem
        lda math.add24.sum$+1
        sta reuvmem+1
        lda math.add24.sum$+2
        sta reuvmem+2


        lda graphicsstarted
        bne @skip_startedgraphics
        jsr graphics.setbitmapmode$
        jsr graphics.enablemulticolormode$
        lda #$01
        sta graphicsstarted
@skip_startedgraphics


        lda vcounter
        sta math.add16.addend1$
        lda vcounter+1
        sta math.add16.addend1$+1
        lda #01
        sta math.add16.addend2$
        lda #00
        sta math.add16.addend2$+1
        jsr math.add16$
        lda math.add16.sum$
        sta vcounter
        sta math.cmp16.num1$
        lda math.add16.sum$+1
        sta vcounter+1
        sta math.cmp16.num1$+1

        lda #<maxvcount
        sta math.cmp16.num2$
        lda #>maxvcount
        sta math.cmp16.num2$+1
        jsr math.cmp16$
        bne @done

        lda #01
        sta mvdone

@done
        rts

info    text 'Created by VBGuyNY 2020', console.newline$, console.newline$, console.null$
anykey  text 'Press any key to go back', console.null$

imageaddress            = $6000 ; 8000 bytes
imagelength             = 8000
multivideoaddress       = $4400 ; 1000 bytes
multivideolength        = 1000
multicoloraddress       = $d800 ; 1000 bytes
multicolorlength        = 1000
multibgcoloraddress     = $d021 ; 1 byte
multibgcolorlength      = 1
graphicsstarted         byte $00

digistartaddress  = $9000 ; Digi start address
digilength        = $2c00
digiendaddress    = digistartaddress+digilength ; Digi end address
digisamplerate    = $00e0
digistarted       byte $00

mvdone          byte $00
vcounter        word $0000
maxvcount       = 815 ; The max + 1
wcounter        byte $00
maxwcount       = 8
oldirq          word $0000
reuvmem         byte $00, $00, $04
reuamem         byte $00, $00, $00
