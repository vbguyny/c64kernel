; Kernel for the C64
; ZP Address that are safe to use: $02; $2A; $52; $73-$90; $FB-$FE; 

CharSet 2 ; Upper/lower cased characters
        
;; sys 3840
;;#region BASIC start up code
;;; ; 10 POKE 2303, 1
;;; 20 SYS (2304)
;;; 30 NEW
;;*=$0801
;;        ;byte    $0e, $08, $0a, $00, $97, $20, $32, $33, $30, $33, $2c, $20, $31, $00 ; 10 POKE 2303, 1
;;        ;byte    $0e, $08, $0a, $00, $9e, $20, $28,  $32, $30, $38, $30, $29, $00 ; 10 SYS (2080)
;;        byte    $0e, $08, $14, $00, $9e, $20, $28,  $32, $33, $30, $34, $29, $00 ; 20 SYS (2304)
;;        byte    $0e, $08, $1e, $00, $a2, $00 ; 30 NEW
;;#endregion


;; sys 3856
;*=$0801
;        byte    $0e, $08, $14, $00, $9e, $20, $28,  $33, $38, $35, $36, $29, $00 ; 20 SYS (3856)
;        byte    $00, $00, $00
;        ;byte    $0e, $08, $1e, $00, $a2, $00, $00, $00 ; 30 NEW

;; sys 3849
;*=$0801
;        byte    $0e, $08, $14, $00, $9e, $20, $28,  $33, $38, $34, $39, $29, $00 ; 20 SYS (3849)
;        byte    $00, $00, $00

; sys 3840
*=$0801
        byte    $0e, $08, $14, $00, $9e, $20, $28,  $33, $38, $34, $30, $29, $00 ; 20 SYS (3840)
        byte    $00, $00, $00

#region Console Buffer ; 256 bytes
;*=$1a00
;console.readstr.bufaddress = *
;incasm "buffer256.asm"
console.readstr.bufaddress = $0900
#endregion

#region Graphic Tables ; 1024 bytes
;*=$1b00
;graphics.Y_Table_Lo_address = *
;incasm "buffer256.asm"
graphics.Y_Table_Lo_address = $0a00
;*=$1c00
;graphics.Y_Table_Hi_address = *
;incasm "buffer256.asm"
graphics.Y_Table_Hi_address = $0b00
;*=$1d00
;graphics.X_Table_address = *
;incasm "buffer256.asm"
graphics.X_Table_address = $0c00
;*=$1e00
;graphics.BitMask_address = *
;incasm "buffer256.asm"
graphics.BitMask_address = $0d00
#endregion

#region ZP Backup ; 256 bytes
;*=$1f00
;*=$0d00
;memory.backupzpaddress
;incasm "buffer256.asm"
memory.backupzpaddress = $0e00
#region

#region Font ; 512 bytes
*=$2000
font.memoryaddress = *
incasm "font.asm"
#endregion



;#region Reserved addresses
;*=$0400 ; Characters
;        nop
;;*=$2000 ; Charactermap (declared above)
;;        nop
;*=$4200 ; Sprite memory
;*=$4400 ; Bitmap color memory
;        nop
;*=$6000 ; Bitmap data memory (-$8fff)
;        nop
;*=$a000 ; Heap (-$bfff)
;*=$d400 ; Sound memory
;*=$c000 ; User code (-$cfff) *** Need to relocate the ZP Backup and the Graphics calc tables! ***
;#endregion

; up9600
*=$4800
incasm "up9600.asm"

;; t2400
;*=$4e00
; There appears to be bug in this routine where it adds $90 to each character
; Also this changes the 1200 baud setting to be able go at 2400 baud, so the 
; command to open the file is the same as it running at 1200 baud.
;incasm "t2400.asm"

#region Assembly start-up code
; Kernel entry point
;*=$2000

;*=$08f0
;*=$0ff0
*=$0f00
        ;lda #$01 ; If debugging in CBM prg Studio, unremark this line
        lda #$00 ; If running from depacker, unremark this line
        sta kernel.debugmode$
        ;jmp kernel.begin
        jsr kernel.begin
        jsr kernel.reset$

kernel.debugmode$       byte $00

        ;lda #$00
        ;sta kernel.debugmode$
        ;nop
        ;nop
        nop
        nop
        nop

;*=$0900
*=$0f10
kernel.begin
        jsr kernel.start
        ;jsr main
        jsr $c000
        jsr kernel.end
        rts
        ;brk

#endregion

#region Constants
color.black$            = $00
color.white$            = $01
color.red$              = $02
color.cyan$             = $03
color.purple$           = $04
color.green$            = $05
color.blue$             = $06
color.yellow$           = $07
color.orange$           = $08
color.brown$            = $09
color.lightred$         = $0a
color.darkgrey$         = $0b
color.grey$             = $0c
color.lightgreen$       = $0d
color.lightblue$        = $0e
color.lightgrey$        = $0f
#endregion

#region Kernel
;*=$c000 ; sys 49152
;*=$a000 ; sys 40960

;align $100

kernel.start

        ; http://codebase64.org/doku.php?id=base:memory_management
        lda #$36 ; Bank switch BASIC ROM into RAM
        sta $01

        ; Disables C= (Commodore Key) + SHIFT which switches the characters
        ; and messes with the characters on the screen.
        lda #$08
        jsr $ffd2

        jsr memory.start

        ;$DD00 = %xxxxxx11 -> bank0: $0000-$3fff
        ;$DD00 = %xxxxxx10 -> bank1: $4000-$7fff
        ;$DD00 = %xxxxxx01 -> bank2: $8000-$bfff
        ;$DD00 = %xxxxxx00 -> bank3: $c000-$ffff
        ; Default: 10010111
        lda $DD00
        and #%11111100
        ;ora #%00000010 ;<- your desired VIC bank value, see above
        ora #%00000011 ;<- your desired VIC bank value, see above
        sta $DD00

        jsr console.start

        ;; http://codebase64.org/doku.php?id=base:memory_management
;        lda #$36 ; Bank switch BASIC ROM into RAM
;        sta $01 

;CharSet 2 ; Upper/lower cased characters
;           lda $d018
;           ora #$0e       ; set chars location to $3800 for displaying the custom font
;           sta $d018      ; Bits 1-3 ($400+512bytes * low nibble value) of $d018 sets char location
;                          ; $400 + $200*$0E = $3800

        ;jsr main
        

        ;; http://codebase64.org/doku.php?id=base:memory_management
;        lda #$37 ; Bank switch RAM back into BASIC ROM
;        sta $01 
        
        ;jsr kernel.reset

        rts
        ;brk

kernel.end
        jsr console.end

        ;$DD00 = %xxxxxx11 -> bank0: $0000-$3fff
        ;$DD00 = %xxxxxx10 -> bank1: $4000-$7fff
        ;$DD00 = %xxxxxx01 -> bank2: $8000-$bfff
        ;$DD00 = %xxxxxx00 -> bank3: $c000-$ffff
        lda $DD00
        and #%11111100
        ora #%00000011 ;<- your desired VIC bank value, see above
        sta $DD00

        jsr memory.end

        ; http://codebase64.org/doku.php?id=base:memory_management
        lda #$37 ; Bank switch RAM back into BASIC ROM
        sta $01

;        ; Reset the computer.
;        ; In order to prevent the debugger from crashing just return.
;        lda kernel.debugmode$
;        cmp #$01
;        bne @Reset
;        rts
;@Reset
;        jsr kernel.reset$

        rts

;kernel.reset$
;        jmp ($FFFC)

kernel.halt$
;        jmp kernel.halt$

        lda kernel.debugmode$
        cmp #$00
        beq @Halt
        jmp $0000

@Halt
        jmp @Halt

#endregion

#region Memory
;align $100

memory.start
        jsr memory.backupzp
        ;jsr memory.startheap
        rts

memory.end
        jsr memory.endheap$
        jsr memory.restorezp
        rts

memory.backupzp
        ; Back zero page memory
        ldx #$00
@loop
        lda $00,x
        ;sta $e3a2,x
        ;sta $cf00,x
        sta memory.backupzpaddress,x
        inx
        cpx #$ff
        bne @loop
        rts

memory.restorezp
        ; Do not restore the RTC variables so that the ticks do not reset
        lda $a0
        sta memory.backupzpaddress+$a0
        lda $a1
        sta memory.backupzpaddress+$a1
        lda $a2
        sta memory.backupzpaddress+$a2

        ; Back zero page memory
        ldx #$00
@loop
        ;lda $cf00,x
        lda memory.backupzpaddress,x
        sta $00,x
        inx
        cpx #$ff
        bne @loop
        rts


memory.copy.source$ = $73 ; 2 bytes
memory.copy.destination$ = $75 ; 2 bytes
memory.copy.length$ = $77 ; 1 byte

memory.copy$
        lda memory.copy.length$
        cmp #$00
        beq @end

        ldy #$00
@loop
        lda (memory.copy.source$),y
        sta (memory.copy.destination$),y
        iny
        cpy memory.copy.length$
        bne @loop
@end
        rts

memory.copy16.source$ = $73 ; 2 bytes
memory.copy16.destination$ = $75 ; 2 bytes
memory.copy16.length$ = $78 ; 2 bytes

memory.copy16$
@loop
        lda memory.copy16.length$+1
        cmp #$00
        beq @copylow

        lda #$ff
        sta memory.copy.length$
        jsr memory.copy$        

        ldy #$ff
        lda (memory.copy16.source$),y
        sta (memory.copy16.destination$),y

        inc memory.copy16.source$+1
        inc memory.copy16.destination$+1
        dec memory.copy16.length$+1

        jmp @loop

@copylow
        lda memory.copy16.length$
        sta memory.copy.length$
        jsr memory.copy$

        rts

memory.swap.address1$ = $73 ; 2 bytes
memory.swap.address2$ = $75 ; 2 bytes
memory.swap.length$ = $77 ; 1 byte
memory.swap.temp = $79 ; 1 byte
memory.swap$
        ldy #$00
@again
        cpy memory.swap.length$
        bne @cont
        rts
@cont
        lda (memory.swap.address1$),y
        sta memory.swap.temp
        lda (memory.swap.address2$),y
        sta (memory.swap.address1$),y
        lda memory.swap.temp
        sta (memory.swap.address2$),y
        iny
        jmp @again

memory.swap16.address1$ = $73 ; 2 bytes
memory.swap16.address2$ = $75 ; 2 bytes
memory.swap16.length$ = $77 ; 2 bytes
memory.swap16.temp = $79 ; 1 byte
memory.swap16$
@loop
        lda memory.swap16.length$+1
        cmp #$00
        beq @swaplow

        lda #$ff
        sta memory.swap.length$
        jsr memory.swap$        

        ldy #$ff
        lda (memory.swap16.address1$),y
        sta memory.swap16.temp
        lda (memory.swap16.address2$),y
        sta (memory.swap16.address1$),y
        lda memory.swap16.temp
        sta (memory.swap16.address2$),y

        inc memory.swap16.address1$+1
        inc memory.swap16.address2$+1
        dec memory.swap16.length$+1

        jmp @loop

@swaplow
        lda memory.swap16.length$
        sta memory.swap.length$
        jsr memory.swap$

        rts

;align $100

memory.fill.address$ = $73 ; 2 bytes
memory.fill.value$ = $75 ; 1 byte
memory.fill.length$ = $76 ; 1 byte

memory.fill$
        lda memory.fill.length$
        cmp #$00
        beq @end

        lda memory.fill.value$
        ldy #$00
@loop
        sta (memory.fill.address$),y
        iny
        cpy memory.fill.length$
        bne @loop
@end
        rts

memory.fill16.address$ = $73 ; 2 bytes
memory.fill16.value$ = $75 ; 1 byte
memory.fill16.length$ = $77 ; 2 bytes

memory.fill16$
@loop
        lda memory.fill16.length$+1
        cmp #$00
        beq @filllow

        lda #$ff
        sta memory.fill.length$
        jsr memory.fill$        

        ldy #$ff
        lda memory.fill16.value$
        sta (memory.fill16.address$),y

        inc memory.fill16.address$+1
        dec memory.fill16.length$+1

        jmp @loop

@filllow
        lda memory.fill16.length$
        sta memory.fill.length$
        jsr memory.fill$

        rts

memory.pushregs$
        sta $fc ; Put  the A regsiter into memory since we need it to do work in this routine.

        ; The stack is pointing to the return address.        
        ; Get the return address
        pla
        sta $fd
        inc $fd
        pla
        sta $fe

        ; Push the A, X, and Y registers onto the stack.
        lda $fc
        pha
        txa
        pha
        tya
        pha
        
        lda $fc ; Restore the A register.

        ; Implicit return.        
        jmp ($00fd)

memory.pullregs$
        ; The stack is pointing to the return address.        
        ; Get the return address
        pla
        sta $fd
        inc $fd
        pla
        sta $fe

        ; Pull the A, X, and Y registers from the stack.
        pla
        tay
        pla
        tax
        pla
        
        ; Implicit return.        
        jmp ($00fd)

;align $100

memory.heapadress       word $a000
memory.heapadress_lr    word $bfff
memory.total$           word $2000 ; 8,192 bytes
memory.free$            word $2000 ; 8,192 bytes
memory.used$            word $0000 ; 0 bytes
memory.heapstarted      byte $00

memory.startheap$

        ; Check to see if the heap has already been started
        lda memory.heapstarted
        cmp #$01
        bne @OkToStart
        rts
@OkToStart

        lda #$01
        sta memory.heapstarted

        jsr memory.pushzp$

        lda memory.heapadress
        sta memory.fill16.address$
        lda memory.heapadress+1
        sta memory.fill16.address$+1

        lda memory.total$
        sta memory.fill16.length$
        lda memory.total$+1
        sta memory.fill16.length$+1

        lda #$ff
        sta memory.fill16.value$

        jsr memory.fill16$

        jsr memory.pullzp$

        rts

memory.endheap$
        lda #$00
        sta memory.heapstarted
        rts

; New method: (n + 2 bytes)
;       Look for 2 null$ bytes and then start counting as long as there isn't any non-null$ bytes.  Return the address after the size bytes.
;       2 bytes before the allocated block is the size of the block.
;       Dealloction will insert null$ bytes for the size of the block including the 2 bytes before the address

; Old method: (n + 1 bytes) [see kernel.18.asm]
;       Each block of allocated memory must end with a null$ byte.
;       The size of the block is determine how many bytes before it reaches the next null$ byte.
;       Deallocation will insert null$ bytes until it encounters the next null$ byte.

memory.allocate.address$ = $7a ; 2 bytes
memory.allocate.length$ = $75 ; 2 bytes
memory.allocate.counter = $77 ; 2 bytes
memory.allocate.found = $79 ; 1 byte
memory.allocate$

        jsr memory.startheap$ ; Sanity check

        ; Clear address ($0000 means nothing was allocated)
        lda #$00
        sta memory.allocate.address$
        sta memory.allocate.address$+1

        jsr memory.allocate.inc_length ; length = length + 2

        lda math.add16.sum$
        sta memory.allocate.length$
        lda math.add16.sum$+1
        sta memory.allocate.length$+1

        ; Ensure that we are not allocating more memory than want is free
        lda memory.free$
        sta math.cmp16.num1$
        lda memory.free$+1
        sta math.cmp16.num1$+1

        lda memory.allocate.length$
        sta math.cmp16.num2$
        lda memory.allocate.length$+1
        sta math.cmp16.num2$+1
        
        jsr math.cmp16$ ; If free$ < length$ (carry is cleared) then exit
        ;bcc @end
        bcs @find
        rts

@find
        ;jsr memory.allocate.dec_length ; length = length - 2

        jsr memory.allocate.find ; Locate memory that can be used.

        ; Confirm that we found a spot of memory that can be used.
        lda memory.allocate.found
        cmp #$01
        beq @init_mem

        ; If nothing was found, reset the return value and exit.
        lda #$00
        sta memory.allocate.address$
        sta memory.allocate.address$+1
        jmp @end

@init_mem
        ;jsr memory.allocate.inc_length ; length = length + 2

        ; Need to recalculate the memory free/used.
        lda memory.used$
        sta math.add16.addend1$
        lda memory.used$+1
        sta math.add16.addend1$+1

        lda memory.allocate.length$
        sta math.add16.addend2$
        lda memory.allocate.length$+1
        sta math.add16.addend2$+1

        jsr math.add16$ ; memory.used$ = memory.used$ + length

        lda math.add16.sum$
        sta memory.used$
        lda math.add16.sum$+1
        sta memory.used$+1

        jsr memory.calculate_free ; memory.free$ = memory.total$ - memory.used$

        ; Store the length of the block at address - 2
        ldy #$00
        lda memory.allocate.length$
        sta (memory.allocate.address$),y
        iny
        lda memory.allocate.length$+1
        sta (memory.allocate.address$),y

        ; Add 2 to the address value.
        lda memory.allocate.address$
        sta math.add16.addend1$
        lda memory.allocate.address$+1
        sta math.add16.addend1$+1
        
        lda #$02
        sta math.add16.addend2$
        lda #$00
        sta math.add16.addend2$+1
        
        jsr math.add16$ ; address = address + 2

        lda math.add16.sum$
        sta memory.allocate.address$
        lda math.add16.sum$+1
        sta memory.allocate.address$+1

        jsr memory.allocate.dec_length ; length = length - 2

        ; Initailize the memory with non-null$ characters.
        lda memory.allocate.address$
        sta memory.fill16.address$
        lda memory.allocate.address$+1
        sta memory.fill16.address$+1

        lda memory.allocate.length$
        sta memory.fill16.length$
        lda memory.allocate.length$+1
        sta memory.fill16.length$+1

        lda #$00
        sta memory.fill.value$
        jsr memory.fill16$

@end

        rts

memory.allocate.inc_length
        ; Add 2 to the length of the memory
        lda memory.allocate.length$
        sta math.add16.addend1$
        lda memory.allocate.length$+1
        sta math.add16.addend1$+1

        lda #$02
        sta math.add16.addend2$
        lda #$00
        sta math.add16.addend2$+1

        jsr math.add16$ ; length = length + 2

        lda math.add16.sum$
        sta memory.allocate.length$
        lda math.add16.sum$+1
        sta memory.allocate.length$+1

        rts

memory.allocate.dec_length
        ; Subtract 2 to the length of the memory
        lda memory.allocate.length$
        sta math.subtract16.menuend$
        lda memory.allocate.length$+1
        sta math.subtract16.menuend$+1

        lda #$02
        sta math.subtract16.subtrahend$
        lda #$00
        sta math.subtract16.subtrahend$+1

        jsr math.subtract16$ ; length = length - 2

        lda math.subtract16.difference$
        sta memory.allocate.length$
        lda math.subtract16.difference$+1
        sta memory.allocate.length$+1

        rts


;align $100

memory.allocate.find
        ; Default to the start of the heap
        lda memory.heapadress
        sta memory.allocate.address$
        lda memory.heapadress+1
        sta memory.allocate.address$+1

        ; Locate the first spot that contains null$
        ldy #$00
        ldx #$00
        stx memory.allocate.counter
        stx memory.allocate.counter+1
@loop
        lda (memory.allocate.address$),y
@check_mem
        cmp #$ff
        ;beq @inc_counter
        bne @reset_counter
        jmp @inc_counter

@reset_counter
        ; Get the size of the memory block
        ldy #$00
        lda (memory.allocate.address$),y
        sta memory.sizeof.length$
        iny
        lda (memory.allocate.address$),y
        sta memory.sizeof.length$+1

        ; Inc the address by the size of the memory block
        lda memory.allocate.address$
        sta math.add16.addend1$
        lda memory.allocate.address$+1
        sta math.add16.addend1$+1

        lda memory.sizeof.length$
        sta math.add16.addend2$
        lda memory.sizeof.length$+1
        sta math.add16.addend2$+1

        jsr math.add16$ ; address = address + length

        lda math.add16.sum$
        sta memory.allocate.address$
        lda math.add16.sum$+1
        sta memory.allocate.address$+1

        ldy #$00
        ldx #$00
        stx memory.allocate.counter
        stx memory.allocate.counter+1

        jmp @check_size

@next_mem
        ; Increase the memory address
        jsr memory.allocate.inc_address

@check_size
        ; If the address is greater than the last heap address then exit
        lda memory.allocate.address$
        sta math.cmp16.num1$
        lda memory.allocate.address$+1
        sta math.cmp16.num1$+1

        lda memory.heapadress_lr
        sta math.cmp16.num2$
        lda memory.heapadress_lr+1
        sta math.cmp16.num2$+1

        jsr math.cmp16$ ; If the address$ >= heapadress_lr then exit
        ;bcs @end

        bcc @ok
        jmp @end
@ok

        ldy #$00
        jmp @loop

align $100

@inc_counter
        inx
        stx memory.allocate.counter
        cpx #$00
        bne @check_counter
        inc memory.allocate.counter+1
@check_counter

        ; If the counter is equal to the length then exit
        lda memory.allocate.counter
        sta math.cmp16.num1$
        lda memory.allocate.counter+1
        sta math.cmp16.num1$+1

        lda memory.allocate.length$
        sta math.cmp16.num2$
        lda memory.allocate.length$+1
        sta math.cmp16.num2$+1

        jsr math.cmp16$ ; If counter = length then exit

;align $100

        ;beq @found
        bcs @found

        jmp @next_mem

@found
        jsr memory.allocate.inc_address

        ; Decrease by the length to get the starting location
        lda memory.allocate.address$
        sta math.subtract16.menuend$
        lda memory.allocate.address$+1
        sta math.subtract16.menuend$+1

        lda memory.allocate.length$
        sta math.subtract16.subtrahend$
        lda memory.allocate.length$+1
        sta math.subtract16.subtrahend$+1

        jsr math.subtract16$ ; address = address - length

        lda math.subtract16.difference$
        sta memory.allocate.address$
        lda math.subtract16.difference$+1
        sta memory.allocate.address$+1

        lda #$01
        sta memory.allocate.found

@end
        rts

memory.allocate.inc_address

        lda memory.allocate.address$
        sta math.add16.addend1$
        lda memory.allocate.address$+1
        sta math.add16.addend1$+1

        lda #$01
        sta math.add16.addend2$
        lda #$00
        sta math.add16.addend2$+1
        
        jsr math.add16$ ; address = address + 1

        lda math.add16.sum$
        sta memory.allocate.address$
        lda math.add16.sum$+1
        sta memory.allocate.address$+1

        rts

memory.sizeof.address$ = $7a ; 2 bytes
memory.sizeof.length$ = $7c ; 2 bytes
memory.sizeof$
        ; The size of the block of memory is store in the previous 2 bytes.

        ; Subtract the 2 bytes at the beginning of the address.
        
        lda memory.sizeof.address$
        sta math.subtract16.menuend$
        lda memory.sizeof.address$+1
        sta math.subtract16.menuend$+1

        lda #$02
        sta math.subtract16.subtrahend$
        lda #$00
        sta math.subtract16.subtrahend$+1

        jsr math.subtract16$ ; address = address - 2

        lda math.subtract16.difference$
        sta memory.sizeof.address$
        lda math.subtract16.difference$+1
        sta memory.sizeof.address$+1

        ; Get the value stored at address - 2 and put into length
        ldy #$00
        lda (memory.sizeof.address$),y
        sta memory.sizeof.length$
        iny
        lda (memory.sizeof.address$),y
        sta memory.sizeof.length$+1

        rts

memory.deallocate.address$ = $7a ; 2 bytes
memory.deallocate$
        ; Free up the memory.

        ; Get the size of the memory block.
        lda memory.deallocate.address$
        sta memory.sizeof.address$
        lda memory.deallocate.address$+1
        sta memory.sizeof.address$+1

        jsr memory.sizeof$ ; length = sizeof(address)

        ; Decrease memory.used$
        lda memory.used$
        sta math.subtract16.menuend$
        lda memory.used$+1
        sta math.subtract16.menuend$+1

        lda memory.sizeof.length$
        sta math.subtract16.subtrahend$
        lda memory.sizeof.length$+1
        sta math.subtract16.subtrahend$+1

        jsr math.subtract16$ ; memory.used$ = memory.used$ - length

        lda math.subtract16.difference$
        sta memory.used$
        lda math.subtract16.difference$+1
        sta memory.used$+1

        jsr memory.calculate_free ; memory.free$ = memory.total$ - memory.used$

        ; Set the memory for re-use
        lda memory.deallocate.address$
        sta memory.fill16.address$
        lda memory.deallocate.address$+1
        sta memory.fill16.address$+1

        lda memory.sizeof.length$
        sta memory.fill16.length$
        lda memory.sizeof.length$+1
        sta memory.fill16.length$+1

        lda #$ff
        sta memory.fill16.value$

        jsr memory.fill16$

        rts

memory.calculate_free
        lda memory.total$
        sta math.subtract16.menuend$
        lda memory.total$+1
        sta math.subtract16.menuend$+1

        lda memory.used$
        sta math.subtract16.subtrahend$
        lda memory.used$+1
        sta math.subtract16.subtrahend$+1

        jsr math.subtract16$ ; memory.free$ = memory.total$ - memory.used$

        lda math.subtract16.difference$
        sta memory.free$
        lda math.subtract16.difference$+1
        sta memory.free$+1

        rts

;align $100
;memory.heapmanadr = *
;incasm "buffer1024.asm"

;;align $100

#endregion

#region Console

;align $100

console.charmapaddress          = $2000
console.memoryaddress           = $0400 ; first position
console.memoryaddress_lr        = $07c0 ; last row
console.currentaddress          word console.memoryaddress
console.currentcolumn           byte $00 ; 40 columns
console.currentrow              byte $00 ; 25 rows
console.coloraddress            = $d800
console.coloraddress_lr         = $dbc0 ; last row
console.currentcoloraddr        word console.coloraddress
console.charactercolor          byte color.white$
console.charactersinverted      byte $00

console.start
        
        lda #<console.memoryaddress
        sta console.currentaddress
        lda #<console.memoryaddress+1
        sta console.currentaddress+1

        lda #<console.coloraddress
        sta console.currentcoloraddr
        lda #<console.coloraddress+1
        sta console.currentcoloraddr+1

        lda #$00
        sta console.currentcolumn
        sta console.currentrow

        jsr console.clear$

        lda #color.black$
        sta console.setbackgroundcolor.color$
        jsr console.setbackgroundcolor$

        lda #color.black$
        sta console.setbordercolor.color$
        jsr console.setbordercolor$

        ;lda #color.white$
        ;sta console.setforegroundcolor.color$
        ;jsr console.setforegroundcolor$
        ;;sta $0286

        lda #0
        sta console.setcharacterinverted.value$
        jsr console.setcharacterinverted$

;        ; Copy the font to $<console.charmapaddress
;        lda #<FontAddress
;        sta memory.copy16.source$
;        lda #>FontAddress
;        sta memory.copy16.source$+1
;        lda #<console.charmapaddress
;        sta memory.copy16.destination$
;        lda #>console.charmapaddress
;        sta memory.copy16.destination$+1
;        lda #$00
;        sta memory.copy16.length$
;        lda #$08
;        sta memory.copy16.length$+1
;        jsr memory.copy16$

        ; Set to custom character set
        ; http://codebase64.org/doku.php?id=base:vicii_memory_organizing
        ;$D018 = %xxxx010x -> charmem is at $1000
        ; Default value = %00010101
        lda $d018
        and #%11110001
        ;ora #%00000000 ; $0000
        ;ora #%00000010 ; $0800
        ;ora #%00000100 ; $1000
        ;ora #%00000110 ; $1800
        ora #%00001000 ; $2000
        ;ora #%00001010 ; $2800
        ;ora #%00001100 ; $3000
        ;ora #%00001110 ; $3800
        sta $d018

        rts

console.end

        ; Copy the font to $<console.charmapaddress
        lda #<console.charmapaddress
        sta memory.copy16.source$
        lda #>console.charmapaddress
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

        ; Copy the screen characters
        lda #<console.memoryaddress
        sta memory.copy16.source$
        lda #>console.memoryaddress
        sta memory.copy16.source$+1
        lda #$00
        sta memory.copy16.destination$
        lda #$04
        sta memory.copy16.destination$+1
        lda #$c0
        sta memory.copy16.length$
        lda #$03
        sta memory.copy16.length$+1
        jsr memory.copy16$

        ; Set to custom character set
        ; http://codebase64.org/doku.php?id=base:vicii_memory_organizing
        ;$D018 = %xxxx010x -> charmem is at $1000
        ; Default value = %00010101
        lda $d018
        and #%11110001
        ;ora #%00000000 ; $0000
        ;ora #%00000010 ; $0800
        ;ora #%00000100 ; $1000
        ;ora #%00000110 ; $1800
        ora #%00001000 ; $2000
        ;ora #%00001010 ; $2800
        ;ora #%00001100 ; $3000
        ;ora #%00001110 ; $3800
        sta $d018

        ;jsr console.clear$

        rts

;align $100

console.clear$
        ldx #$00
        lda #$20
@loop
        sta console.memoryaddress,x
        sta console.memoryaddress+$100,x
        sta console.memoryaddress+$200,x
        sta console.memoryaddress+$300,x
        dex
        bne @loop

        lda #<console.memoryaddress
        sta console.currentaddress
        lda #>console.memoryaddress
        sta console.currentaddress+1

        lda #<console.coloraddress
        sta console.currentcoloraddr
        lda #>console.coloraddress
        sta console.currentcoloraddr+1

        lda #$00
        sta console.currentrow
        sta console.currentcolumn

        rts

console.getrow.row$ = $73 ; 1 byte
console.getrow$
        lda console.currentrow
        sta console.getrow.row$
        rts

console.setrow.row$ = $73 ; 1 byte
console.setrow$
        lda console.setrow.row$
        sta console.currentrow
        jsr console.calc_currentaddress
        rts

console.getcolumn.column$ = $73 ; 1 byte
console.getcolumn$
        lda console.currentcolumn
        sta console.getcolumn.column$
        rts

console.setcolumn.column$ = $73 ; 1 byte
console.setcolumn$
        lda console.setcolumn.column$
        sta console.currentcolumn
        jsr console.calc_currentaddress
        rts

console.calc_currentaddress.sum = $74 ; 2 bytes
console.calc_currentaddress
        ; Caculate console.currentaddress by the updated row and column values.

        ; console.currentaddress = console.memoryaddress + ((column) + (row * 40))
        ; console.currentcoloraddr = console.coloraddress + ((column) + (row * 40))

        lda console.currentrow
        sta math.multiply16.factor1$
        lda #40
        sta math.multiply16.factor2$
        lda #$00
        sta math.multiply16.factor1$+1
        sta math.multiply16.factor2$+1
        jsr math.multiply16$ ; product = currentrow * 40
        
        lda math.multiply16.product$  
        sta math.add16.addend1$
        lda math.multiply16.product$+1
        sta math.add16.addend1$+1
        lda console.currentcolumn
        sta math.add16.addend2$
        lda #$00
        sta math.add16.addend2$+1
        jsr math.add16$ ; sum = column + product
        lda math.add16.sum$
        sta console.calc_currentaddress.sum
        lda math.add16.sum$+1
        sta console.calc_currentaddress.sum+1
        
        lda console.calc_currentaddress.sum
        sta math.add16.addend1$
        lda console.calc_currentaddress.sum+1
        sta math.add16.addend1$+1
        lda #<console.memoryaddress
        sta math.add16.addend2$
        lda #>console.memoryaddress
        sta math.add16.addend2$+1
        jsr math.add16$ ; currentaddress = memoryaddress + sum
        lda math.add16.sum$
        sta console.currentaddress
        lda math.add16.sum$+1
        sta console.currentaddress+1

        ; console.currentcoloraddr = console.coloraddress + sum
        lda console.calc_currentaddress.sum
        sta math.add16.addend1$
        lda console.calc_currentaddress.sum+1
        sta math.add16.addend1$+1
        lda #<console.coloraddress
        sta math.add16.addend2$
        lda #>console.coloraddress
        sta math.add16.addend2$+1
        jsr math.add16$ ; currentaddress = memoryaddress + sum
        lda math.add16.sum$
        sta console.currentcoloraddr
        lda math.add16.sum$+1
        sta console.currentcoloraddr+1

        rts

;console.scrollup$
;        ; Copy the characters from the 2nd row and override the first row.
;        ; Clear out the text on the last row.

;        ;ldx #$28
;        ldy #$00
;@loop
;        lda $0428,y
;        sta $0400,y
;        lda $0518,y
;        sta $04F0,y
;        iny
;        ;cpy #215 ;(255-40)
;        ;cpy #$ff
;        cpy #240
;        bne @loop

;;        lda $0500,x
;;        sta $0500,y
;;        lda $0600,x
;;        sta $0600,y
;;        lda $0700,x
;;        sta $0700,y

;        rts

;align $100

console.scrollup$
        ; Copy the characters from the 2nd row and override the first row.
        ; Clear out the text on the last row.

;        lda #$00
;        sta $fb
;        lda #$04
;        sta $fc
;        lda #$28
;        sta $fd
;        lda #$04
;        sta $fe
        lda #<console.memoryaddress
        sta $fb
        lda #>console.memoryaddress
        sta $fc
        lda #<console.memoryaddress+$28
        sta $fd
        lda #>console.memoryaddress
        sta $fe
        jsr console.scrollupchrs

        ; Need to "scroll" up the character colors as well
        lda #<console.coloraddress
        sta $fb
        lda #>console.coloraddress
        sta $fc
        lda #<console.coloraddress+$28
        sta $fd
        lda #>console.coloraddress
        sta $fe
        jsr console.scrollupchrs

        ; Clear the last line
        lda #$20
        ldy #$00
@loop_lr
        sta console.memoryaddress_lr,y
        iny
        cpy #$28
        bne @loop_lr

        jsr graphics.scrollup

        rts

console.scrollupchrs
        ldx #$00
@loop1 ; Do process 4 times (6*4 = 24)
        ldy #$00
@loop2 ; Move up 6 lines
        lda ($fd),y
        sta ($fb),y
        iny
        cpy #240 ; (40*6)
        bne @loop2

        inx
        cpx #4
        beq @clear_lr

        ; Need to increase the value of the address that $fb and $fd are pointing to.
        lda $fb
        sta math.add16.addend1$
        lda $fc
        sta math.add16.addend1$+1

        lda #240
        sta math.add16.addend2$
        lda #0
        sta math.add16.addend2$+1

        jsr math.add16$ ; ($fb+$fc) = ($fb+$fc) + $28

        lda math.add16.sum$
        sta $fb
        lda math.add16.sum$+1
        sta $fc

        lda $fd
        sta math.add16.addend1$
        lda $fe
        sta math.add16.addend1$+1

        lda #240
        sta math.add16.addend2$
        lda #0
        sta math.add16.addend2$+1

        jsr math.add16$ ; ($fd+$fe) = ($fd+$fe) + $28

        lda math.add16.sum$
        sta $fd
        lda math.add16.sum$+1
        sta $fe

        jmp @loop1

@clear_lr
;        lda #$20
;        ldy #$00
;@loop_lr
;        sta console.memoryaddress_lr,y
;        iny
;        cpy #$28
;        bne @loop_lr

        rts


console.writeln$
        lda #console.newline$
        sta console.writechr.char$
        jsr console.writechr$
        rts

console.writestr.straddress$ = $e0 ; 2 bytes

console.writestr$
        ; Print each character to the screen
        ldy #$00
@loop
        lda (console.writestr.straddress$),y
        ;cmp #$00
        cmp #console.null$
        beq @end
        sta console.writechr.char$
        jsr console.writechr$
        iny
        cpy #$00
        bne @loop
        inc console.writestr.straddress$+1
        jmp @loop
@end
        rts

;align $100

console.writeint8.integer$ = $e0 ; 1 byte
console.writeint8$
        jsr convert.hex2dec8
        ldx #2 ; max. length - 1
        jmp console.writeint

console.writeint16.integer$ = $e0 ; 2 bytes
console.writeint16$
        jsr convert.hex2dec16
        ldx #4 ; max. length - 1
        jmp console.writeint

console.writeint32.integer$ = $e0 ; 4 bytes
console.writeint32$
        jsr convert.hex2dec32
        ldx #9 ; max. length - 1
        jmp console.writeint

align $100 

console.writeint
@l1      
        lda convert.hex2dec.result,x
        bne @l2
        dex             ; skip leading zeros
        bne @l1

@l2
        ldy #$00
@loop
        lda convert.hex2dec.result,x
        ORA #$30  ;(convert to ASCII)
        ;sta console.memoryaddress,y
        sta console.writechr.char$
        jsr console.writechr$
        iny
        dex
        bpl @loop
        rts

;align $100 

console.newline$        = $fe
console.null$           = $ff
console.backspace$      = $fd
console.quote$          = $27

console.writechr.char$ = $02 ; 1 byte
console.writechr.address = $fb ; 2 bytes
console.writechr.offset word $0000
console.writechr$
        ; Prints an individual character to the screen.
        ; The character to print is stored in A.

        ;sta console.writechr.char$

;        pha ; Save A onto stack.
;        txa
;        pha ; Save X onto stack.
;        tya
;        pha ; Save Y onto stack.
        jsr memory.pushregs$

        ; Set the color of this character.
        ldy #$00
        lda console.currentcoloraddr
        sta console.writechr.address
        lda console.currentcoloraddr+1
        sta console.writechr.address+1

        lda console.charactercolor
        sta (console.writechr.address),y

        ; Write the character to the screen memory.
        ldy #$00
        lda console.currentaddress
        sta console.writechr.address
        lda console.currentaddress+1
        sta console.writechr.address+1

        ; If {return} detected then we need to start at the beginning of the next row.
        lda console.writechr.char$
        cmp #console.newline$
        beq @do_newline

        ; If {delete} detected then we need to perform a backspace operation.
        lda console.writechr.char$
        cmp #console.backspace$
        beq @do_backspace

        ; Invert the character as needed.
        clc
        adc console.charactersinverted

;        lda graphics.isactive$
;        cmp #$01
;        beq @DrawChr
;        sta (console.writechr.address),y
;        jmp @SkipDrawChr
;@DrawChr
;        jsr graphics.drawchr
;@SkipDrawChr
        sta (console.writechr.address),y
        jsr graphics.drawchr

        ;ldy #$01
        lda #$01
        sta console.writechr.offset
        lda #$00
        sta console.writechr.offset+1

        jmp console.inc_memaddress

;@inc_memaddress
;        ; Update console.currentaddress
;        lda console.writechr.address
;        sta math.add16.addend1$
;        lda console.writechr.address+1
;        sta math.add16.addend1$+1

;        ;lda #$01
;        ;tya
;        lda console.writechr.offset
;        sta math.add16.addend2$
;        lda console.writechr.offset+1
;        sta math.add16.addend2$+1

;        jsr math.add16$ ; console.currentaddress = console.currentaddress + 1
;        
;        lda math.add16.sum$
;        sta console.currentaddress
;        lda math.add16.sum$+1
;        sta console.currentaddress+1
;        
;        ; Update console.currentcoloraddr
;        lda console.currentcoloraddr
;        sta math.add16.addend1$
;        lda console.currentcoloraddr+1
;        sta math.add16.addend1$+1

;        lda console.writechr.offset
;        sta math.add16.addend2$
;        lda console.writechr.offset+1
;        sta math.add16.addend2$+1

;        jsr math.add16$ ; console.currentaddress = console.currentaddress + 1
;        
;        lda math.add16.sum$
;        sta console.currentcoloraddr
;        lda math.add16.sum$+1
;        sta console.currentcoloraddr+1
;        
;        ; Increase the current column number
;        lda console.currentcolumn
;        cmp #39
;        bne @inc_currentcolumn

;@reset_lr        
;        ; Reset the current column
;        lda #$ff
;        sta console.currentcolumn

;        ; Increase the current row number
;        lda console.currentrow
;        cmp #24
;        bne @inc_currentrow
;        
;        ; Scroll all text up one row
;        lda #23
;        sta console.currentrow

;        ; Need to scroll the charcters up one row.
;        jsr console.scrollup$

;        ; Update the address
;        lda #<console.memoryaddress_lr
;        sta console.currentaddress
;        lda #>console.memoryaddress_lr
;        sta console.currentaddress+1

;@inc_currentrow
;        inc console.currentrow

;@inc_currentcolumn
;        inc console.currentcolumn

;        jmp @end

@do_newline        
        ; We need to increase the current address by the difference of the number of columns remaining

        lda console.currentrow
        cmp #24
        beq @reset_lr
        ;beq console.inc_memaddress.reset_lr

        lda #40
        sec
        sbc console.currentcolumn
        ;tay ; Store the number of columns we need to add to get the next row
        sta console.writechr.offset
        lda #0
        sta console.writechr.offset+1

        ; Reset console.currentcolumn
        lda #39
        sta console.currentcolumn

        jmp console.inc_memaddress

@reset_lr
        jmp console.inc_memaddress.reset_lr

@do_backspace
        ; We need to decrease the current address by 1 and clear the current text.
        ; If we are at the starting memory address then cannot go back any futher.

        lda #$01
        sta console.writechr.offset
        lda #$00
        sta console.writechr.offset+1
        
        ; Do not move backwards of the location is at the beginning of the caret starting address.
        lda console.currentaddress
        sta math.cmp16.num1$
        lda console.currentaddress+1
        sta math.cmp16.num1$+1

        lda console.caretstartaddress
        sta math.cmp16.num2$
        lda console.caretstartaddress+1
        sta math.cmp16.num2$+1

        jsr math.cmp16$ ; If console.currentaddress = console.caretstartaddress then exit
        beq @end

;        lda console.currentrow
;        cmp #0
;        bne @dec_memaddress

;        lda console.currentcolumn
;        cmp #0
;        bne @dec_memaddress

;        jmp @end

;@dec_memaddress
        jmp console.dec_memaddress

@end
;        pla ; Save Y onto stack.
;        tay
;        pla ; Save X onto stack.
;        tax
;        pla ; Save A onto stack.
        jsr memory.pullregs$

        rts

console.inc_memaddress

        ; Update console.currentaddress
        lda console.currentaddress
        sta math.add16.addend1$
        lda console.currentaddress+1
        sta math.add16.addend1$+1

        ;lda #$01
        ;tya
        lda console.writechr.offset
        sta math.add16.addend2$
        lda console.writechr.offset+1
        sta math.add16.addend2$+1

        jsr math.add16$ ; console.currentaddress = console.currentaddress + 1
        
        lda math.add16.sum$
        sta console.currentaddress
        lda math.add16.sum$+1
        sta console.currentaddress+1
        
        ; Update console.currentcoloraddr
        lda console.currentcoloraddr
        sta math.add16.addend1$
        lda console.currentcoloraddr+1
        sta math.add16.addend1$+1

        lda console.writechr.offset
        sta math.add16.addend2$
        lda console.writechr.offset+1
        sta math.add16.addend2$+1

        jsr math.add16$ ; console.currentaddress = console.currentaddress + 1
        
        lda math.add16.sum$
        sta console.currentcoloraddr
        lda math.add16.sum$+1
        sta console.currentcoloraddr+1
        
        ; Increase the current column number
        lda console.currentcolumn
        cmp #39
        ;bne console.inc_memaddress.inc_currentcolumn
        beq console.inc_memaddress.reset_lr
        jmp console.inc_memaddress.inc_currentcolumn
        

;@reset_lr        
console.inc_memaddress.reset_lr
        ; Reset the current column
        lda #$ff
        sta console.currentcolumn

        ; Increase the current row number
        lda console.currentrow
        cmp #24
        ;bne console.inc_memaddress.inc_currentrow
        beq console.inc_memaddress.inc_currentrow_skip
        jmp console.inc_memaddress.inc_currentrow
console.inc_memaddress.inc_currentrow_skip
        
        ; Scroll all text up one row
        lda #23
        sta console.currentrow

        ; Need to scroll the charcters up one row.
        jsr console.scrollup$

        ; Update the address
        lda #<console.memoryaddress_lr
        sta console.currentaddress
        lda #>console.memoryaddress_lr
        sta console.currentaddress+1

        ; Update the address
        lda #<console.coloraddress_lr
        sta console.currentcoloraddr
        lda #>console.coloraddress_lr
        sta console.currentcoloraddr+1

console.inc_memaddress.inc_currentrow
        inc console.currentrow

console.inc_memaddress.inc_currentcolumn
        inc console.currentcolumn

        ;jmp console.inc_memaddress.end

console.inc_memaddress.end
        jsr memory.pullregs$
        rts

;align $100

console.dec_memaddress

        ; Update console.currentaddress
        lda console.currentaddress
        sta math.subtract16.menuend$
        lda console.currentaddress+1
        sta math.subtract16.menuend$+1

        lda console.writechr.offset
        sta math.subtract16.subtrahend$
        lda console.writechr.offset+1
        sta math.subtract16.subtrahend$+1

        jsr math.subtract16$ ; console.currentaddress = console.currentaddress - 1
        
        lda math.subtract16.difference$
        sta console.currentaddress
        lda math.subtract16.difference$+1
        sta console.currentaddress+1
        
        ; Update console.currentcoloraddr
        lda console.currentcoloraddr
        sta math.subtract16.menuend$
        lda console.currentcoloraddr+1
        sta math.subtract16.menuend$+1

        lda console.writechr.offset
        sta math.subtract16.subtrahend$
        lda console.writechr.offset+1
        sta math.subtract16.subtrahend$+1

        jsr math.subtract16$ ; console.currentaddress = console.currentaddress - 1
        
        lda math.subtract16.difference$
        sta console.currentcoloraddr
        lda math.subtract16.difference$+1
        sta console.currentcoloraddr+1
        
        ; Decrease the current column number
        lda console.currentcolumn
        cmp #0
        bne console.dec_memaddress.dec_currentcolumn

console.dec_memaddress.reset_lr
        ; Reset the current column
        ;lda #$39
        lda #$28
        sta console.currentcolumn

        ; Descrease the current row number
        lda console.currentrow
        cmp #0
        bne console.dec_memaddress.dec_currentrow

        lda #0
        sta console.currentcolumn

        ; Update the address
        lda #<console.memoryaddress
        sta console.currentaddress
        lda #>console.memoryaddress
        sta console.currentaddress+1
        
        jmp console.dec_memaddress.end

console.dec_memaddress.dec_currentrow
        dec console.currentrow

console.dec_memaddress.dec_currentcolumn
        dec console.currentcolumn

console.dec_memaddress.end

        jsr memory.pullregs$
        rts

;align $100

console.setbackgroundcolor.color$ = $73 ; 1 byte
console.setbackgroundcolor$
        lda console.setbackgroundcolor.color$
        sta $d021
        rts

console.setbordercolor.color$ = $73 ; 1 byte
console.setbordercolor$
        lda console.setbordercolor.color$
        sta $d020
        rts

console.setforegroundcolor.color$ = $73 ; 1 byte
console.setforegroundcolor$
        lda console.setforegroundcolor.color$
        ldx #$00
@loop
        sta console.coloraddress,x
        sta console.coloraddress+$100,x
        sta console.coloraddress+$200,x
        sta console.coloraddress+$300,x
        dex
        bne @loop
        rts

;console.setchrforecolor.color$ = $73 ; 1 bytes
;console.setchrforecolor$
;        ; Get the color at the console's current memory address.
;        ; AND the forecolor with zeros.
;        ; OR the forecolor with the new color.
;        ; Put the new color at the console's current memory address.

;        lda console.coloraddress
;        and #%11110000 ; clear the low bits
;        ora console.setchrforecolor.color$ ; set the low bits
;        sta console.coloraddress

;        rts

; This is not possible using the VIC chip!
;console.setchrbackcolor.color$ = $73 ; 1 bytes
;console.setchrbackcolor$
;        ; Need to shift the backcolor to the left 4 bits.
;        ; Get the color at the console's current memory address.
;        ; AND the backcolor with zeros.
;        ; OR the backcolor with the new color.
;        ; Put the new color at the console's current memory address.

;        ; Shift the bits to the left 4 times (lo->hi)
;        asl console.setchrbackcolor.color$
;        asl console.setchrbackcolor.color$
;        asl console.setchrbackcolor.color$
;        asl console.setchrbackcolor.color$

;        lda console.coloraddress
;        and #%00001111 ; clear the high bits
;        ora console.setchrbackcolor.color$ ; set the high bits
;        sta console.coloraddress

;        rts

console.setcharactercolor.color$ = $73 ; 1 byte
console.setcharactercolor$
        lda console.setcharactercolor.color$
        sta console.charactercolor
        rts

console.setcharacterinverted.value$ = $73 ; 1 byte
console.setcharacterinverted$
        lda console.setcharacterinverted.value$
        cmp #1
        beq @set
@unset
        lda #$00
        jmp @end
@set
        lda #$80
@end
        sta console.charactersinverted
        rts


console.readchr.caret ; Separate routine because branches weren't working
        ; Get the current ticks
        jsr time.getticks$

        lda time.getticks.result$
        sta math.cmp32.num1$
        lda time.getticks.result$+1
        sta math.cmp32.num1$+1
        lda time.getticks.result$+2
        sta math.cmp32.num1$+2
        lda time.getticks.result$+3
        sta math.cmp32.num1$+3

        lda console.readchr.milliseconds
        sta math.cmp32.num2$
        lda console.readchr.milliseconds+1
        sta math.cmp32.num2$+1
        lda console.readchr.milliseconds+2
        sta math.cmp32.num2$+2
        lda console.readchr.milliseconds+3
        sta math.cmp32.num2$+3

        jsr math.cmp32$ ; If ticks > (milliseconds + ticks) then carry flag should be set.

        ;bcc @ReadKey ; Goto @ReadKey if ticks < (milliseconds + ticks).
        bcs @ReadKey_skip ; Goto @ReadKey if ticks < (milliseconds + ticks).
        jmp @ReadKey
@ReadKey_skip

        ; Get the current time and store
        jsr time.getticks$

        ; 500 = $01f4
        ; 400 = $0190
        lda #$90
        sta math.add32.addend1$
        lda #$01
        sta math.add32.addend1$+1
        lda #$00
        sta math.add32.addend1$+2
        lda #$00
        sta math.add32.addend1$+3

        lda time.getticks.result$
        sta math.add32.addend2$
        lda time.getticks.result$+1
        sta math.add32.addend2$+1
        lda time.getticks.result$+2
        sta math.add32.addend2$+2
        lda time.getticks.result$+3
        sta math.add32.addend2$+3

        jsr math.add32$
        
        ; Store the sum 
        lda math.add32.sum$
        sta console.readchr.milliseconds
        lda math.add32.sum$+1
        sta console.readchr.milliseconds+1
        lda math.add32.sum$+2
        sta console.readchr.milliseconds+2
        lda math.add32.sum$+3
        sta console.readchr.milliseconds+3

;        ; Delay added to slow down the quick backspace characters.
;        ; 100 = $64
;        ; 50 = $32
;        lda #$64
;        sta time.wait.milliseconds$
;        lda #$00
;        sta time.wait.milliseconds$+1
;        lda #$00
;        sta time.wait.milliseconds$+2
;        lda #$00
;        sta time.wait.milliseconds$+3
;        jsr time.wait$

        ; Toggle the caret
        ldy #$00
        lda console.readchr.togglecaret
        cmp #$01
        beq @ClearCarret
@ShowCarret
        ; Render the caret at the current memory location
        lda console.caretchar$
        sta (console.readchr.caretaddress),y
        jsr graphics.drawchr
        lda #$01
        sta console.readchr.togglecaret
        jmp @ReadKey
@ClearCarret
        ; Render the caret at the current memory location
        lda #$20
        sta (console.readchr.caretaddress),y
        jsr graphics.drawchr
        lda #$00
        sta console.readchr.togglecaret

@ReadKey
        rts

console.readint.allowedchrs text '1234567890', console.backspace$, console.null$

console.readint8.integer$ = $7a ; 1 byte
console.readint8$
        ; Read characters from the console.
        lda #$03
        sta console.readgen.maxlen

        lda #<console.readint.allowedchrs
        sta console.readgen.allowedchrs
        lda #>console.readint.allowedchrs
        sta console.readgen.allowedchrs+1

        jsr console.readgen

        ; Convert the decimal characters to hexidecimal.
        jsr console.readint.copymem

        jsr convert.dec2hex8

        lda convert.dec2hex8.result
        sta console.readint8.integer$
        rts

console.readint16.integer$ = $7a ; 2 bytes
console.readint16$
        ; Read characters from the console.
        lda #$05
        sta console.readgen.maxlen

        lda #<console.readint.allowedchrs
        sta console.readgen.allowedchrs
        lda #>console.readint.allowedchrs
        sta console.readgen.allowedchrs+1

        jsr console.readgen

        ; Convert the decimal characters to hexidecimal.
        jsr console.readint.copymem

        jsr convert.dec2hex16

        lda convert.dec2hex16.result
        sta console.readint16.integer$
        lda convert.dec2hex16.result+1
        sta console.readint16.integer$+1

        rts

console.readint32.integer$ = $7a ; 4 bytes
console.readint32$
        ; Read characters from the console.
        lda #$0a ; 10
        sta console.readgen.maxlen

        lda #<console.readint.allowedchrs
        sta console.readgen.allowedchrs
        lda #>console.readint.allowedchrs
        sta console.readgen.allowedchrs+1

        jsr console.readgen

        ; Convert the decimal characters to hexidecimal.
        jsr console.readint.copymem

        jsr convert.dec2hex32

        lda convert.dec2hex32.result
        sta console.readint32.integer$
        lda convert.dec2hex32.result+1
        sta console.readint32.integer$+1
        lda convert.dec2hex32.result+2
        sta console.readint32.integer$+2
        lda convert.dec2hex32.result+3
        sta console.readint32.integer$+3

        rts

console.readint.copymem
        ; Get the length of the string
        lda #<console.readstr.bufaddress
        sta string.getlength.address$
        lda #>console.readstr.bufaddress
        sta string.getlength.address$+1

        jsr string.getlength$

        lda string.getlength.length$
        cmp #$00
        beq @End
        sta convert.dec2hex.len

        ldx #$00
@Loop
        lda console.readstr.bufaddress,x
        sta convert.dec2hex.value,x
        inx
        cpx convert.dec2hex.len
        bne @Loop

@End
        rts

math.subtract24.menuend$ = $80 ; 3 bytes
math.subtract24.subtrahend$ = $83 ; 3 bytes
math.subtract24.difference$ = $86 ; 4 bytes

math.subtract24$
        sec                             ; set carry for borrow purpose
        lda math.subtract24.menuend$
        sbc math.subtract24.subtrahend$                      ; perform subtraction on the LSBs
        sta math.subtract24.difference$
        lda math.subtract24.menuend$+1                      ; do the same for the MSBs, with carry
        sbc math.subtract24.subtrahend$+1                      ; set according to the previous result
        sta math.subtract24.difference$+1
        lda math.subtract24.menuend$+2
        sbc math.subtract24.subtrahend$+2                      ; perform subtraction on the LSBs
        sta math.subtract24.difference$+2
        rts

align $100

console.getkey.BufferOld  byte $ff, $ff, $ff

console.getkey.Buffer  byte $ff, $ff, $ff, $ff

console.getkey.BufferQuantity byte $ff

console.getkey.SimultaneousAlphanumericKeysFlag  byte $00

console.getkey.KeyTableShift$
    byte $ff, $41, $42, $43, $44, $45, $46, $47  ; "@", "A", "B", "C", "D", "E", "F", "G"
    byte $48, $49, $4a, $4b, $4c, $4d, $4e, $4f  ; "H", "I", "J", "K", "L", "M", "N", "O"
    byte $50, $51, $52, $53, $54, $55, $56, $57  ; "P", "Q", "R", "S", "T", "U", "V", "W"
    byte $58, $59, $5a, $ff, $ff, $ff, $ff, $ff  ; "X", "Y", "Z", "[", (POUND), "]", UP-ARROW, "<-"
    byte $20, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ; " " (SPC), "!", (DBL QTE), "#", "$", "%", "&", "`"
    byte $ff, $ff, $ff, $ff, $3c, $ff, $3e, $3f  ; "(", ")", "*", "+", ",", "-", ".", "/"
    byte $ff, $21, $22, $23, $24, $25, $26, $27  ; "0", "1", "2", "3", "4", "5", "6", "7"
    byte $28, $29, $1b, $1d, $ff, $ff, $ff, $ff  ; "8", "9", ":", ";", "<", "=", ">", "?"

console.readkey.char.invalid$ = $ff
console.readkey.char$ = $d0 ; 1 byte

console.readkey.shift1.up_down$         = %10000000
console.readkey.shift1.f5$              = %01000000
console.readkey.shift1.f3$              = %00100000
console.readkey.shift1.f1$              = %00010000
console.readkey.shift1.f7$              = %00001000
console.readkey.shift1.left_right$      = %00000100
console.readkey.shift1.return$          = %00000010
console.readkey.shift1.insert_delete$   = %00000001
console.readkey.shift1$ = $d1 ; 1 byte

console.readkey.shift2.run_stop$        = %10000000
console.readkey.shift2.left_shift$      = %01000000
console.readkey.shift2.commodore$       = %00100000
console.readkey.shift2.right_shift$     = %00010000
console.readkey.shift2.clear_home$      = %00001000
console.readkey.shift2.control$         = %00000100
console.readkey.shift2$ = $d2 ; 1 byte

console.readkey.state.ok$                       = $00
console.readkey.state.no_activity$              = $01
console.readkey.state.control_port_1$           = $02
console.readkey.state.shadowing$                = $03
console.readkey.state.multiplekeys$             = $04
console.readkey.state.awaiting_no_activity$     = $05
console.readkey.state$  = $d3 ; 1 byte
console.readkey.processorstate = $db ; 1 byte
console.readkey$
        ; http://codebase64.org/doku.php?id=base:scanning_the_keyboard_the_correct_and_non_kernal_way

        ;The routine uses "2 Key rollower" or up to 3 if the key-combination doesen't induce shadowing.
        ;If 2 or 3 keys are pressed simultaneously (within 1 scan) a "No Activity" state has to occur before new valid keys are returned.
        ;RESTORE is not detectable and must be handled by NMI IRQ.
        ;SHIFT LOCK is not detected due to unreliability.
        
        lda #$00
        sta console.readkey.char$
        sta console.readkey.shift1$
        sta console.readkey.shift2$
        sta console.readkey.state$

        php ; Push the processor state onto the stack
        pla ; Pull the processor state into A
        sta console.readkey.processorstate ; Save in variable

        sei ; Need to disable interrupts otherwise pressing RUN-STOP (TAB) causes
            ; random alpha-numeric key stroke to be returned when non is pressed
        jsr console.getkey
        bcs @NoValidInput ; If carry is set, no valid character pressed

        sta console.readchr.char$
        stx console.readkey.shift1$ 
        sty console.readkey.shift2$

        jmp @End

@NoValidInput  ; This may be substituted for an errorhandler if needed. 
        sta console.readkey.state$

@End

        ; Check to see if interrupts were previously disabled
        ; If so, do not re-enable them
        lda console.readkey.processorstate
        and #%00000100
        cmp #%00000100
        beq @SkipCLI
        cli ; Re-enable interrupts
@SkipCLI

        rts


;console.readchr.char$ = $83
;console.readchr.yreg = $fb

;console.readchr$
;        ; http://codebase64.org/doku.php?id=base:scanning_the_keyboard_the_correct_and_non_kernal_way

;;        jsr console.getkey
;        
;        sei ; Need to disable interupts otherwise pressing RUN-STOP (TAB) causes
;            ; random alpha-numeric key stroke to be returned when non is pressed
;@Loop
;        jsr console.getkey 
;        bcs @NoValidInput ; If carry is set, no valid character pressed

;        ;stx TempX 
;        ;sty TempY
;        cmp #$ff
;        beq @NoNewAphanumericKey
;            ;; Check A for Alphanumeric keys 
;            ;sta $0400 

;        sta console.readchr.char$

;        tya
;        and #%01000000 ; Left shift
;        cmp #%01000000
;        beq @ShiftPressed
;        tya
;        and #%00010000 ; Right shift
;        cmp #%00010000
;        beq @ShiftPressed

;        jmp @End

;@ShiftPressed
;        ;lda console.readchr.char$
;        ;adc #63
;        ;sta console.readchr.char$

;        ldx console.readchr.char$
;        lda console.getkey.KeyTableShift,x
;        cmp #$ff
;        beq @Loop
;        sta console.readchr.char$

;        jmp @End

;@NoNewAphanumericKey 
;            ;; Check X & Y for Non-Alphanumeric Keys 
;            ;ldx TempX 
;            ;ldy TempY 
;            ;stx $0401 
;            ;sty $0402
;        jmp @Loop

;@NoValidInput  ; This may be substituted for an errorhandler if needed. 
;        jmp @Loop

;@End
;        rts

;align $100

console.caretchar$              byte $64 ; Made public so it can be overridden
console.caretstartaddress       word $0000
console.readchr.prev_chr        byte $00

console.readchr.char$ = $d0 ; 1 byte
console.readchr.milliseconds = $d4 ; 4 bytes
console.readchr.togglecaret = $d8 ; 1 byte
console.readchr.caretaddress = $d9 ; 2 bytes

console.readchr$
        lda console.currentaddress
        sta console.caretstartaddress
        lda console.currentaddress+1
        sta console.caretstartaddress+1

console.readchr

        ;; Check for debugmode
        ;lda kernel.debugmode$
        ;cmp #$00
        ;beq @not_debugmode$
        ;rts
;@not_debugmode$

        ; Prevent quick returns from being pressed
        ;jsr time.halt$
        ;jsr time.halt$

        ; Set the color of the caret
        ldy #$00
        lda console.currentcoloraddr
        sta console.readchr.caretaddress
        lda console.currentcoloraddr+1
        sta console.readchr.caretaddress+1
        lda console.charactercolor
        sta (console.readchr.caretaddress),y

        ; Get the location of the caret
        lda console.currentaddress
        sta console.readchr.caretaddress
        lda console.currentaddress+1
        sta console.readchr.caretaddress+1

        ; Show the caret
        lda #$00
        sta console.readchr.togglecaret

        ; Reset the milliseconds
        lda #$00
        sta console.readchr.milliseconds
        sta console.readchr.milliseconds+1
        sta console.readchr.milliseconds+2
        sta console.readchr.milliseconds+3

@Loop
        jsr console.readchr.caret ; Separate routine because branches weren't working

@ReadKey
        ; Read the key from the keyboard
        jsr console.readkey$

        ; Determine if anything was pressed
        lda console.readkey.state$
        cmp #console.readkey.state.ok$
        ;bne @Loop
        beq @ReadKeyOk
        lda #$00
        sta console.readchr.prev_chr
        jmp @Loop
@ReadKeyOk

        ; Confirm that we have a valid character
        lda console.readkey.char$
        cmp #console.readkey.char.invalid$
        beq @CheckSpecial

        ; Check if the shift key was pressed
        lda console.readkey.shift2$
        and #console.readkey.shift2.left_shift$
        cmp #console.readkey.shift2.left_shift$
        beq @ShiftPressed

        lda console.readkey.shift2$
        and #console.readkey.shift2.right_shift$
        cmp #console.readkey.shift2.right_shift$
        beq @ShiftPressed
        
        jmp @End

@ShiftPressed
        ; If a valid character was pressed while the shift key was pressed,
        ; return the upper-cased version of the character
        ldx console.readkey.char$
        lda console.getkey.KeyTableShift$,x
        cmp #console.readkey.char.invalid$
        beq @Loop
        sta console.readchr.char$

        jmp @End2

;@CheckReturn
;        ; If the return key is pressed, return null
;        lda console.readkey.shift1$
;        cmp #console.readkey.shift1.return$
;        bne @Loop
;        lda #console.null$
;        ;lda #console.newline$
;        sta console.readkey.char$

@CheckSpecial
        ; If the return key is pressed, return null
        lda console.readkey.shift1$
        cmp #console.readkey.shift1.return$
        beq @ReturnNull
        cmp #console.readkey.shift1.insert_delete$
        beq @ReturnBackSpace
        
        jmp @Loop

@ReturnNull
        lda #console.null$
        sta console.readkey.char$
        jmp @HideCaret

@ReturnBackSpace
        lda #console.backspace$
        sta console.readkey.char$
        jmp @HideCaret

@HideCaret

        ; Compare last character
        ;lda console.readchr.char$
        cmp console.readchr.prev_chr
        bne @CharOk
        jmp @Loop
@CharOk
        sta console.readchr.prev_chr

        ; Hide the caret
        lda #$20
        sta (console.readchr.caretaddress),y
        jsr graphics.drawchr
        ;jmp @SkipWriteChr

        ;lda console.readchr.char$
        ;pha
        ;jmp @t1

;        ; Delay added to slow down the quick backspace characters.
;        ; 100 = $64
;        ; 50 = $32
;        lda #$64
;        sta time.wait.milliseconds$
;        lda #$00
;        sta time.wait.milliseconds$+1
;        lda #$00
;        sta time.wait.milliseconds$+2
;        lda #$00
;        sta time.wait.milliseconds$+3
;        jsr time.wait$

        ;jsr time.halt2
        ;jsr time.halt2

;@t1
        ;pla
        ;sta console.readchr.char$

@End

@End2

        ; Write the character to the screen
        lda console.readchr.char$
        cmp #console.null$
        beq @SkipWriteChr
        pha
        sta console.writechr.char$
        jsr console.writechr$
        pla
        sta console.readchr.char$
@SkipWriteChr

        rts

;align $100


; Strings will have a max length of 255 characters.
console.readstr.straddress$ = $7a ; 2 bytes
console.readstr.length = $fb ; 2 bytes
console.readstr$

        lda #$ff
        sta console.readgen.maxlen
        lda #$00
        sta console.readgen.allowedchrs
        sta console.readgen.allowedchrs+1
        jsr console.readgen

        ; Store the length
        stx console.readstr.length
        ldx #$00
        stx console.readstr.length+1

        ; Need to copy the contents of the buffer to an instance of a new string.
        lda console.readstr.length
        sta string.create.length$
        lda console.readstr.length+1
        sta string.create.length$+1

        lda #$00 ; Optimization - default to character $00
        sta string.create.character$

        jsr string.create$ ; straddress = string.create$(length)

        lda string.create.address$
        sta console.readstr.straddress$
        lda string.create.address$+1
        sta console.readstr.straddress$+1

        lda #<console.readstr.bufaddress
        sta memory.copy16.source$
        lda #>console.readstr.bufaddress
        sta memory.copy16.source$+1

        lda console.readstr.straddress$
        sta memory.copy16.destination$
        lda console.readstr.straddress$+1
        sta memory.copy16.destination$+1

        lda console.readstr.length
        sta memory.copy16.length$
        lda #$00
        sta memory.copy16.length$+1

        jsr memory.copy16$ ; memory.copy16(bufaddress, straddress)

        rts

;align $100

console.readgen.maxlen = $ea ; 1 byte
console.readgen.allowedchrs = $eb ; 2 bytes
console.readgen.skipchr = $ed ; 1 byte
console.readgen.char = $ee ; 1 byte
console.readgen
        ; When the ability to allocate string exists,
        ; the new string needs to be the exact size of 
        ; the characters entered + 1 (null$).

;        ; Fill the straddress with nulls
;        lda #<console.readstr.bufaddress
;        sta memory.fill.address$
;        lda #>console.readstr.bufaddress
;        sta memory.fill.address$+1
;        lda #console.null$
;        sta memory.fill.value$
;        ldx console.readgen.maxlen
;        inx ; length = maxlen+1
;        stx memory.fill.length$
;        jsr memory.fill$
        jsr console.resetbufaddress

        ; Set the current address as the starting caret's location.
        lda console.currentaddress
        sta console.caretstartaddress
        lda console.currentaddress+1
        sta console.caretstartaddress+1

        ldx #0
@Loop
        ; Store the string offset in the stack.
        txa
        pha

        ; Read a character from the console.
        jsr console.readchr
        lda console.readchr.char$
        sta console.readgen.char

        ; Get the current string offset.
        pla
        tax

        ; Exit if return was pressed.
        lda console.readgen.char
        cmp #console.null$
        beq @End

        ; Check whether or not the character is allowed.
        jsr console.readgen.SkipAllowChr
        lda console.readgen.skipchr
        cmp #$01
        beq @AtMax

        ; If delete was pressed, insert a null character at the current offset
        ; and decrease the ofsset
        lda console.readgen.char
        cmp #console.backspace$
        beq @BackSpaced

        cpx console.readgen.maxlen ; Sanity check
        beq @AtMax

        ; Store the character in memory.
        lda console.readgen.char
        sta console.readstr.bufaddress,x
        inx ; Increase the offset

        jmp @Loop

@BackSpaced
        cpx #0 ; Sanity check
        beq @Loop

        dex ; Increase the offset
        lda #console.null$
        sta console.readstr.bufaddress,x

        jmp @Loop
        
@AtMax
        lda #console.backspace$
        sta console.writechr.char$
        jsr console.writechr$

        jmp @Loop

@End
        rts

console.readgen.SkipAllowChr
        ;jmp @CharOK

        ; If allowedchrs is zero then skip check
        lda console.readgen.allowedchrs
        sta math.cmp16.num1$
        lda console.readgen.allowedchrs+1
        sta math.cmp16.num1$+1

        lda #$00
        lda math.cmp16.num2$
        lda math.cmp16.num2$+1

        jsr math.cmp16$ ; If allowchrs = 0 then return
        ;beq @CharOK
        bne @DoCheck
        jmp @CharOK
        ;;jmp @CharOK

@DoCheck
        ; Confirm that the character typed is one of the characters allowed
        ldy #$00
@Loop
        lda (console.readgen.allowedchrs),y
        cmp console.readgen.char
        beq @CharOK
        cmp #$ff
        beq @SkipChar
        iny
        jmp @Loop
@CharOK
        lda #$00
        jmp @Done
@SkipChar
        lda #$01
@Done
        sta console.readgen.skipchr
        rts

console.resetbufaddress

        ; Fill the straddress with nulls
        lda #<console.readstr.bufaddress
        sta memory.fill.address$
        lda #>console.readstr.bufaddress
        sta memory.fill.address$+1
        lda #console.null$
        sta memory.fill.value$
        ldx console.readgen.maxlen
        inx ; length = maxlen+1
        stx memory.fill.length$
        jsr memory.fill$

        rts


;align $100
;align $100

; ZERO PAGE Varibles
console.getkey.ScanResult       = $73  ; 8 bytes
console.getkey.BufferNew        = $7b  ; 3 bytes
console.getkey.KeyQuantity      = $7e  ; 1 byte
console.getkey.NonAlphaFlagX    = $7f  ; 1 byte
console.getkey.NonAlphaFlagY    = $80  ; 1 byte
console.getkey.TempZP           = $81  ; 1 byte
console.getkey.SimultaneousKeys = $82  ; 1 byte

; Operational Variables
console.getkey.MaxKeyRollover = 3

;console.getkey.Keyboard
;    jmp console.getkey.Main


    ; Routine for Scanning a Matrix Row

console.getkey.KeyInRow
    asl
    bcs *+5
        jsr console.getkey.KeyFound
;repeat 1, 7
;        inx
;        asl
;        bcs *+5
;            jsr console.getkey.KeyFound
;endrepeat
        inx
        asl
        bcs *+5
            jsr console.getkey.KeyFound
        inx
        asl
        bcs *+5
            jsr console.getkey.KeyFound
        inx
        asl
        bcs *+5
            jsr console.getkey.KeyFound
        inx
        asl
        bcs *+5
            jsr console.getkey.KeyFound
        inx
        asl
        bcs *+5
            jsr console.getkey.KeyFound
        inx
        asl
        bcs *+5
            jsr console.getkey.KeyFound
        inx
        asl
        bcs *+5
            jsr console.getkey.KeyFound
    rts


    ; Routine for handling: Key Found

console.getkey.KeyFound
    stx console.getkey.TempZP
    dec console.getkey.KeyQuantity
    bmi console.getkey.OverFlow
    ldy console.getkey.KeyTable,x
    ldx console.getkey.KeyQuantity
    sty console.getkey.BufferNew,x
    ldx console.getkey.TempZP
    rts

    ; Routine for handling: Overflow

console.getkey.OverFlow
    pla  ; Dirty hack to handle 2 layers of JSR
    pla
    pla
    pla
    ; Don't manipulate last legal buffer as the routine will fix itself once it gets valid input again.
    lda #$03
    sec
    rts


    ; Exit Routine for: No Activity

console.getkey.NoActivityDetected
    ; Exit With A = #$01, Carry Set & Reset BufferOld.
    lda #$00
    sta console.getkey.SimultaneousAlphanumericKeysFlag  ; Clear the too many keys flag once a "no activity" state is detected.
    stx console.getkey.BufferOld
    stx console.getkey.BufferOld+1
    stx console.getkey.BufferOld+2
    sec
    lda #$01
    rts


    ; Exit Routine for Control Port Activity

console.getkey.ControlPort
    ; Exit with A = #$02, Carry Set. Keep BufferOld to verify input after Control Port activity ceases
    sec
    lda #$02
    rts


    ; Configure Data Direction Registers
;console.getkey.Main
console.getkey
    ldx #$ff
    stx $dc02       ; Port A - Output
    ldy #$00
    sty $dc03       ; Port B - Input
    clc

    ; Check for Port Activity

    sty $dc00       ; Connect all Keyboard Rows
    cpx $dc01
    beq console.getkey.NoActivityDetected

    lda console.getkey.SimultaneousAlphanumericKeysFlag
    ;beq !+
    beq console.getkey.loop1
        ; Waiting for all keys to be released before accepting new input.
        lda #$05
        sec
        rts
;!:
console.getkey.loop1

    ; Check for Control Port #1 Activity

    stx $dc00       ; Disconnect all Keyboard Rows
    cpx $dc01       ; Only Control Port activity will be detected
    bne console.getkey.ControlPort


    ; Scan Keyboard Matrix

    lda #%11111110
    sta $dc00
    ldy $dc01
    sty console.getkey.ScanResult+7
    sec
;repeat 1, 7, i
;ri = 7 - i
;        rol
;        sta $dc00
;        ldy $dc01
;        sty console.getkey.ScanResult+ri
;endrepeat
        rol
        sta $dc00
        ldy $dc01
        sty console.getkey.ScanResult+6
        rol
        sta $dc00
        ldy $dc01
        sty console.getkey.ScanResult+5
        rol
        sta $dc00
        ldy $dc01
        sty console.getkey.ScanResult+4
        rol
        sta $dc00
        ldy $dc01
        sty console.getkey.ScanResult+3
        rol
        sta $dc00
        ldy $dc01
        sty console.getkey.ScanResult+2
        rol
        sta $dc00
        ldy $dc01
        sty console.getkey.ScanResult+1
        rol
        sta $dc00
        ldy $dc01
        sty console.getkey.ScanResult+0

    ; Check for Control Port #1 Activity (again)

    stx $dc00       ; Disconnect all Keyboard Rows
    cpx $dc01       ; Only Control Port activity will be detected
    bne console.getkey.ControlPort


    ; Initialize Buffer, Flags and Max Keys

    ; Reset current read buffer
    stx console.getkey.BufferNew
    stx console.getkey.BufferNew+1
    stx console.getkey.BufferNew+2

    ; Reset Non-AlphaNumeric Flag
    inx
    stx console.getkey.NonAlphaFlagY

    ; Set max keys allowed before ignoring result
    lda #console.getkey.MaxKeyRollover
    sta console.getkey.KeyQuantity

    ; Counter to check for simultaneous alphanumeric key-presses
    lda #$fe
    sta console.getkey.SimultaneousKeys


    ; Check and flag Non Alphanumeric Keys

    lda console.getkey.ScanResult+6
    eor #$ff
    and #%10000000     ; Left Shift
    lsr
    sta console.getkey.NonAlphaFlagY
    lda console.getkey.ScanResult+0
    eor #$ff
    and #%10100100     ; RUN STOP - C= - CTRL
    ora console.getkey.NonAlphaFlagY
    sta console.getkey.NonAlphaFlagY
    lda console.getkey.ScanResult+1
    eor #$ff
    and #%00011000     ; Right SHIFT - CLR HOME
    ora console.getkey.NonAlphaFlagY
    sta console.getkey.NonAlphaFlagY

    lda console.getkey.ScanResult+7  ; The rest
    eor #$ff
    sta console.getkey.NonAlphaFlagX


    ; Check for pressed key(s)

    lda console.getkey.ScanResult+7
    cmp #$ff
    beq *+5
        jsr console.getkey.KeyInRow
;repeat 1,7,i
;ri = 7 - i
;        ldx #i*8
;        lda console.getkey.ScanResult+ri
;        beq *+5
;            jsr console.getkey.KeyInRow
;endrepeat
        ldx #8
        lda console.getkey.ScanResult+6
        beq *+5
            jsr console.getkey.KeyInRow
        ldx #16
        lda console.getkey.ScanResult+5
        beq *+5
            jsr console.getkey.KeyInRow
        ldx #24
        lda console.getkey.ScanResult+4
        beq *+5
            jsr console.getkey.KeyInRow
        ldx #32
        lda console.getkey.ScanResult+3
        beq *+5
            jsr console.getkey.KeyInRow
        ldx #40
        lda console.getkey.ScanResult+2
        beq *+5
            jsr console.getkey.KeyInRow
        ldx #48
        lda console.getkey.ScanResult+1
        beq *+5
            jsr console.getkey.KeyInRow
        ldx #56
        lda console.getkey.ScanResult+0
        beq *+5
            jsr console.getkey.KeyInRow

    ; Key Scan Completed

    ; Put any new key (not in old scan) into buffer
    ldx #console.getkey.MaxKeyRollover-1
    ;!:
console.getkey.loop2
        lda console.getkey.BufferNew,x
        cmp #$ff
        beq console.getkey.Exist        ; Handle 'null' values
        cmp console.getkey.BufferOld
        beq console.getkey.Exist
        cmp console.getkey.BufferOld+1
        beq console.getkey.Exist
        cmp console.getkey.BufferOld+2
        beq console.getkey.Exist
            ; New Key Detected
            inc console.getkey.BufferQuantity
            ldy console.getkey.BufferQuantity
            sta console.getkey.Buffer,y
            ; Keep track of how many new Alphanumeric keys are detected
            inc console.getkey.SimultaneousKeys
            beq console.getkey.TooManyNewKeys
console.getkey.Exist
        dex
        ;bpl !-
        bpl console.getkey.loop2

    ; Anything in Buffer?
    ldy console.getkey.BufferQuantity
    bmi console.getkey.BufferEmpty
        ; Yes: Then return it and tidy up the buffer
        dec console.getkey.BufferQuantity
        lda console.getkey.Buffer
        ldx console.getkey.Buffer+1
        stx console.getkey.Buffer
        ldx console.getkey.Buffer+2
        stx console.getkey.Buffer+1
        jmp console.getkey.Return

console.getkey.BufferEmpty  ; No new Alphanumeric keys to handle.
    lda #$ff

console.getkey.Return  ; A is preset
    clc
    ; Copy BufferNew to BufferOld
    ldx console.getkey.BufferNew
    stx console.getkey.BufferOld
    ldx console.getkey.BufferNew+1
    stx console.getkey.BufferOld+1
    ldx console.getkey.BufferNew+2
    stx console.getkey.BufferOld+2
    ; Handle Non Alphanumeric Keys
    ldx console.getkey.NonAlphaFlagX
    ldy console.getkey.NonAlphaFlagY
    rts

console.getkey.TooManyNewKeys
    sec
    lda #$ff
    sta console.getkey.BufferQuantity
    sta console.getkey.SimultaneousAlphanumericKeysFlag
    lda #$04
    rts

console.getkey.KeyTable
    byte $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff  ; CRSR DOWN, F5, F3, F1, F7, CRSR RIGHT, RETURN, INST DEL
    byte $ff, $05, $13, $1a, $34, $01, $17, $33  ; LEFT SHIFT, "E", "S", "Z", "4", "A", "W", "3"
    byte $18, $14, $06, $03, $36, $04, $12, $35  ; "X", "T", "F", "C", "6", "D", "R", "5"
    byte $16, $15, $08, $02, $38, $07, $19, $37  ; "V", "U", "H", "B", "8", "G", "Y", "7"
    byte $0e, $0f, $0b, $0d, $30, $0a, $09, $39  ; "N", "O" (Oscar), "K", "M", "0" (Zero), "J", "I", "9"
    byte $2c, $00, $3a, $2e, $2d, $0c, $10, $2b  ; ",", "@", ":", ".", "-", "L", "P", "+"
    byte $2f, $1e, $3d, $ff, $ff, $3b, $2a, $1c  ; "/", "^", "=", RIGHT SHIFT, HOME, ";", "*", "£"
    byte $ff, $11, $ff, $20, $32, $ff, $1f, $31  ; RUN STOP, "Q", "C=" (CMD), " " (SPC), "2", "CTRL", "<-", "1"

#endregion


#region Conversion

align $100

convert.hex2dec.result = $e4

convert.hex2dec8.value = $e0 ; 1 byte
convert.hex2dec8.result = $e4 ; 3 bytes

convert.hex2dec8
        ; converts 3 digits (8 bit values have max. 3 decimal digits)
        ldx #0
@l3
        jsr @div10_8
        sta convert.hex2dec8.result,x
        inx
        cpx #10
        bne @l3
        rts

        ; divides a 8 bit value by 10
        ; remainder is returned in akku
@div10_8
        ldy #8         ; 8 bits
        lda #0
        clc
@l4      
        rol
        cmp #10
        bcc @skip
        sbc #10
@skip    
        rol convert.hex2dec8.value
        dey
        bpl @l4
        rts

convert.hex2dec16.value = $e0 ; 2 bytes
convert.hex2dec16.result = $e4 ; 5 bytes

convert.hex2dec16
        ; converts 5 digits (16 bit values have max. 5 decimal digits)
        ldx #0
@l3
        jsr @div10_16
        sta convert.hex2dec16.result,x
        inx
        cpx #10
        bne @l3
        rts

        ; divides a 16 bit value by 10
        ; remainder is returned in akku
@div10_16
        ldy #16         ; 16 bits
        lda #0
        clc
@l4      
        rol
        cmp #10
        bcc @skip
        sbc #10
@skip    
        rol convert.hex2dec16.value
        rol convert.hex2dec16.value+1
        dey
        bpl @l4
        rts

convert.hex2dec32.value = $e0 ; 4 bytes
convert.hex2dec32.result = $e4 ; 10 bytes

convert.hex2dec32
        ; converts 10 digits (32 bit values have max. 10 decimal digits)
        ldx #0
@l3
        jsr @div10_32
        sta convert.hex2dec32.result,x
        inx
        cpx #10
        bne @l3
        rts

        ; divides a 32 bit value by 10
        ; remainder is returned in akku
@div10_32
        ldy #32         ; 32 bits
        lda #0
        clc
@l4      
        rol
        cmp #10
        bcc @skip
        sbc #10
@skip    
        rol convert.hex2dec32.value
        rol convert.hex2dec32.value+1
        rol convert.hex2dec32.value+2
        rol convert.hex2dec32.value+3
        dey
        bpl @l4
        rts

;convert.dec2hex8
;  lda A
;  jsr MULT10
;  jsr MULT10   ;x100
;  sta TMP0
;  lda B
;  jsr MULT10   ;x10
;  sta TMP1
;  lda C
;  sta TMP2     ;x1
;  
;  clc
;  lda #$00
;  adc TMP0
;  adc TMP1
;  adc TMP2
;  rts     ;Carry will be set if result was > 255


;MULT10  ASL         ;multiply by 2
;        STA TEMP10  ;temp store in TEMP
;        ASL         ;again multiply by 2 (*4)
;        ASL         ;again multiply by 2 (*8)
;        CLC
;        ADC TEMP10  ;as result, A = x*8 + x*2
;        RTS


convert.dec2hex.value = $e4
convert.dec2hex.len = $2a

convert.dec2hex8.value = $e4 ; 3 bytes
convert.dec2hex8.result = $e0 ; 1 byte
convert.dec2hex8.int = $fb ; 1 byte
convert.dec2hex8.len = $2a ; 1 byte
convert.dec2hex8.offset = $52 ; 1 byte
convert.dec2hex8
        ; Need to set convert.dec2hex8.value AND convert.dec2hex8.len
        
        ; Set the default value
        lda #$00
        sta convert.dec2hex8.result
        sta convert.dec2hex8.result+1

        ; Check the length
        lda convert.dec2hex8.len
        cmp #$00
        bne @LenOk
        rts
@LenOk
        ; Multiply each character by 10^(digit-1) and add to the result

        ldx #$00
@Loop
        lda convert.dec2hex8.value,x
        cmp #$30 ; Skip if the character = '0'
        bne @DigitOk
        jmp @NextDigit
@DigitOk
        sec ; Do not subtract any additional 1s
        sbc #$30 ; Get the number value of the character (char - #30)

        sta convert.dec2hex8.int

        ; y = len - offset - 1
        stx convert.dec2hex8.offset
        lda convert.dec2hex8.len
        clc ; Subtract an additional 1
        sbc convert.dec2hex8.offset
        tay

        ; Multiply affects X and Y
        txa
        pha

@Factor
        cpy #$00
        beq @SkipFactor

        lda convert.dec2hex8.int
        sta math.multiply8.factor1$

        lda #$0a
        sta math.multiply8.factor2$

        tya
        pha
        jsr math.multiply8$
        pla
        tay

        lda math.multiply8.product$
        sta convert.dec2hex8.int

        dey ; y = y - 1
        jmp @Factor

@SkipFactor

        ; Restore X and Y
        pla
        tax

        lda convert.dec2hex8.result
        clc
        adc convert.dec2hex8.int
        sta convert.dec2hex8.result

@NextDigit
        inx ; x = x + 1
        cpx convert.dec2hex8.len
        beq @End
        jmp @Loop

@End

        rts

;align $100

convert.dec2hex16.value = $e4 ; 5 bytes
convert.dec2hex16.result = $e0 ; 2 bytes
convert.dec2hex16.int = $fb ; 2 bytes
convert.dec2hex16.len = $2a ; 1 byte
convert.dec2hex16.offset = $52 ; 1 byte
convert.dec2hex16
        ; Need to set convert.dec2hex16.value AND convert.dec2hex16.len
        
        ; Set the default value
        lda #$00
        sta convert.dec2hex16.result
        sta convert.dec2hex16.result+1

        ; Check the length
        lda convert.dec2hex16.len
        cmp #$00
        bne @LenOk
        rts
@LenOk

        ;lda #$05
        ;sta convert.dec2hex16.len

        ; Multiply each character by 10^(digit-1) and add to the result

        ldx #$00
@Loop
        lda convert.dec2hex16.value,x
        cmp #$30 ; Skip if the character = '0'
        bne @DigitOk
        jmp @NextDigit
@DigitOk
        sec ; Do not subtract any additional 1s
        sbc #$30 ; Get the number value of the character (char - #30)

        sta convert.dec2hex16.int
        lda #$00
        sta convert.dec2hex16.int+1

        ; y = len - offset - 1
        stx convert.dec2hex16.offset
        lda convert.dec2hex16.len
        clc ; Subtract an additional 1
        sbc convert.dec2hex16.offset
        tay

        ; Multiply affects X
        txa
        pha

@Factor
        cpy #$00
        beq @SkipFactor

        lda convert.dec2hex16.int
        sta math.multiply16.factor1$
        lda convert.dec2hex16.int+1
        sta math.multiply16.factor1$+1

        lda #$0a
        sta math.multiply16.factor2$
        lda #$00
        sta math.multiply16.factor2$+1

        jsr math.multiply16$

        lda math.multiply16.product$
        sta convert.dec2hex16.int
        lda math.multiply16.product$+1
        sta convert.dec2hex16.int+1

        dey ; y = y - 1
        jmp @Factor

@SkipFactor

        ; Restore X
        pla
        tax

        lda convert.dec2hex16.result
        sta math.add16.addend1$
        lda convert.dec2hex16.result+1
        sta math.add16.addend1$+1

        lda convert.dec2hex16.int
        sta math.add16.addend2$
        lda convert.dec2hex16.int+1
        sta math.add16.addend2$+1

        jsr math.add16$ ; result = result + int

        lda math.add16.sum$
        sta convert.dec2hex16.result
        lda math.add16.sum$+1
        sta convert.dec2hex16.result+1

@NextDigit
        inx ; x = x + 1
        cpx convert.dec2hex16.len
        beq @End
        jmp @Loop

@End

        rts

convert.dec2hex32.value = $e4 ; 10 bytes
convert.dec2hex32.result = $e0 ; 4 bytes
convert.dec2hex32.int = $fb ; 4 bytes
convert.dec2hex32.len = $2a ; 1 byte
convert.dec2hex32.offset = $52 ; 1 byte
convert.dec2hex32
        ; Need to set convert.dec2hex32.value AND convert.dec2hex32.len
        
        ; Set the default value
        lda #$00
        sta convert.dec2hex32.result
        sta convert.dec2hex32.result+1
        sta convert.dec2hex32.result+2
        sta convert.dec2hex32.result+3

        ; Check the length
        lda convert.dec2hex32.len
        cmp #$00
        bne @LenOk
        rts
@LenOk

        ; Multiply each character by 10^(digit-1) and add to the result

        ldx #$00
@Loop
        lda convert.dec2hex32.value,x ; Get the current character
        cmp #$30 ; Skip if the character = '0'
        bne @DigitOk
        jmp @NextDigit
@DigitOk
        sec ; Do not subtract any additional 1s
        sbc #$30 ; Get the number value of the character (char - #30)

        sta convert.dec2hex32.int
        lda #$00
        sta convert.dec2hex32.int+1
        sta convert.dec2hex32.int+2
        sta convert.dec2hex32.int+3

        ; y = len - offset - 1
        stx convert.dec2hex32.offset
        lda convert.dec2hex32.len
        clc ; Subtract an additional 1
        sbc convert.dec2hex32.offset
        tay

        ; Multiply affects X
        txa
        pha

@Factor
        cpy #$00
        beq @SkipFactor

        lda convert.dec2hex32.int
        sta math.multiply32.factor1$
        lda convert.dec2hex32.int+1
        sta math.multiply32.factor1$+1
        lda convert.dec2hex32.int+2
        sta math.multiply32.factor1$+2
        lda convert.dec2hex32.int+3
        sta math.multiply32.factor1$+3

        lda #$0a
        sta math.multiply32.factor2$
        lda #$00
        sta math.multiply32.factor2$+1
        sta math.multiply32.factor2$+2
        sta math.multiply32.factor2$+3

        jsr math.multiply32$

        lda math.multiply32.product$
        sta convert.dec2hex32.int
        lda math.multiply32.product$+1
        sta convert.dec2hex32.int+1
        lda math.multiply32.product$+2
        sta convert.dec2hex32.int+2
        lda math.multiply32.product$+3
        sta convert.dec2hex32.int+3

        dey ; y = y - 1
        jmp @Factor

@SkipFactor

        ; Restore X
        pla
        tax

        lda convert.dec2hex32.result
        sta math.add32.addend1$
        lda convert.dec2hex32.result+1
        sta math.add32.addend1$+1
        lda convert.dec2hex32.result+2
        sta math.add32.addend1$+2
        lda convert.dec2hex32.result+3
        sta math.add32.addend1$+3

        lda convert.dec2hex32.int
        sta math.add32.addend2$
        lda convert.dec2hex32.int+1
        sta math.add32.addend2$+1
        lda convert.dec2hex32.int+2
        sta math.add32.addend2$+2
        lda convert.dec2hex32.int+3
        sta math.add32.addend2$+3

        jsr math.add32$ ; result = result + int

        lda math.add32.sum$
        sta convert.dec2hex32.result
        lda math.add32.sum$+1
        sta convert.dec2hex32.result+1
        lda math.add32.sum$+2
        sta convert.dec2hex32.result+2
        lda math.add32.sum$+3
        sta convert.dec2hex32.result+3

@NextDigit
        inx ; x = x + 1
        cpx convert.dec2hex32.len
        beq @End
        jmp @Loop

@End

        rts

#endregion


#region Time
;align $100

time.getticks.result$ = $73 ; 4 bytes

time.getticks$
        ;cli ; Re-enable interrupts

        ;jsr $FFEA ; call UDTIM

        lda $a2
        sta math.divide32.dividend$
        lda $a1
        sta math.divide32.dividend$+1
        lda $a0
        sta math.divide32.dividend$+2
        lda #$00
        sta math.divide32.dividend$+3

        lda #$3c
        sta math.divide32.divisor$
        lda #$00
        sta math.divide32.divisor$+1
        lda #$00
        sta math.divide32.divisor$+2
        lda #$00
        sta math.divide32.divisor$+3

        jsr math.divide32$ ; quotient = (time / 60)

        lda math.divide32.quotient$
        sta math.multiply32.factor1$
        lda math.divide32.quotient$+1
        sta math.multiply32.factor1$+1
        lda math.divide32.quotient$+2
        sta math.multiply32.factor1$+2
        lda math.divide32.quotient$+3
        sta math.multiply32.factor1$+3

        lda #$e8
        sta math.multiply32.factor2$
        lda #$03
        sta math.multiply32.factor2$+1
        lda #$00
        sta math.multiply32.factor2$+2
        lda #$00
        sta math.multiply32.factor2$+3

        jsr math.multiply32$ ; ticks = quotient * 1000

        lda math.multiply32.product$
        sta time.getticks.result$
        lda math.multiply32.product$+1
        sta time.getticks.result$+1
        lda math.multiply32.product$+2
        sta time.getticks.result$+2
        lda math.multiply32.product$+3
        sta time.getticks.result$+3

        ; At this point we have the ticks to the second (rounded down).        
        ; We need to add the decimal (remainder) to get the milliseconds.

        lda math.divide32.remainder$
        sta math.multiply32.factor1$
        lda math.divide32.remainder$+1
        sta math.multiply32.factor1$+1
        lda math.divide32.remainder$+2
        sta math.multiply32.factor1$+2
        lda math.divide32.remainder$+3
        sta math.multiply32.factor1$+3

        lda #$e8
        sta math.multiply32.factor2$
        lda #$03
        sta math.multiply32.factor2$+1
        lda #$00
        sta math.multiply32.factor2$+2
        lda #$00
        sta math.multiply32.factor2$+3

        jsr math.multiply32$ ; y = remainder * 1000

        lda math.multiply32.product$
        sta math.divide32.dividend$
        lda math.multiply32.product$+1
        sta math.divide32.dividend$+1
        lda math.multiply32.product$+2
        sta math.divide32.dividend$+2
        lda math.multiply32.product$+3
        sta math.divide32.dividend$+3

        lda #$3c
        sta math.divide32.divisor$
        lda #$00
        sta math.divide32.divisor$+1
        lda #$00
        sta math.divide32.divisor$+2
        lda #$00
        sta math.divide32.divisor$+3

        jsr math.divide32$ ; x = (y / 60)

        ; Add to ticks
        lda math.divide32.quotient$
        sta math.add32.addend1$
        lda math.divide32.quotient$+1
        sta math.add32.addend1$+1
        lda math.divide32.quotient$+2
        sta math.add32.addend1$+2
        lda math.divide32.quotient$+3
        sta math.add32.addend1$+3

        lda time.getticks.result$
        sta math.add32.addend2$
        lda time.getticks.result$+1
        sta math.add32.addend2$+1
        lda time.getticks.result$+2
        sta math.add32.addend2$+2
        lda time.getticks.result$+3
        sta math.add32.addend2$+3

        jsr math.add32$ ; ticks = ticks + x

        lda math.add32.sum$
        sta time.getticks.result$
        lda math.add32.sum$+1
        sta time.getticks.result$+1
        lda math.add32.sum$+2
        sta time.getticks.result$+2
        lda math.add32.sum$+3
        sta time.getticks.result$+3

        rts


time.halt$
        ; Delay added to slow down the quick backspace characters.
        ; 100 = $64
        ; 50 = $32
        lda #$32
        sta time.wait.milliseconds$
        lda #$00
        sta time.wait.milliseconds$+1
        lda #$00
        sta time.wait.milliseconds$+2
        lda #$00
        sta time.wait.milliseconds$+3
        jsr time.wait$

        rts


time.wait.milliseconds$ = $77 ; 4 bytes

time.wait$
        jsr time.getticks$

        lda time.wait.milliseconds$
        sta math.add32.addend1$
        lda time.wait.milliseconds$+1
        sta math.add32.addend1$+1
        lda time.wait.milliseconds$+2
        sta math.add32.addend1$+2
        lda time.wait.milliseconds$+3
        sta math.add32.addend1$+3

        lda time.getticks.result$
        sta math.add32.addend2$
        lda time.getticks.result$+1
        sta math.add32.addend2$+1
        lda time.getticks.result$+2
        sta math.add32.addend2$+2
        lda time.getticks.result$+3
        sta math.add32.addend2$+3

        jsr math.add32$
        
        ; Store the find 
        lda math.add32.sum$
        sta time.wait.milliseconds$
        lda math.add32.sum$+1
        sta time.wait.milliseconds$+1
        lda math.add32.sum$+2
        sta time.wait.milliseconds$+2
        lda math.add32.sum$+3
        sta time.wait.milliseconds$+3
        
@loop
        jsr time.getticks$

        lda time.getticks.result$
        sta math.cmp32.num1$
        lda time.getticks.result$+1
        sta math.cmp32.num1$+1
        lda time.getticks.result$+2
        sta math.cmp32.num1$+2
        lda time.getticks.result$+3
        sta math.cmp32.num1$+3

        lda time.wait.milliseconds$
        sta math.cmp32.num2$
        lda time.wait.milliseconds$+1
        sta math.cmp32.num2$+1
        lda time.wait.milliseconds$+2
        sta math.cmp32.num2$+2
        lda time.wait.milliseconds$+3
        sta math.cmp32.num2$+3

        jsr math.cmp32$ ; If ticks > (milliseconds + ticks) then carry flag should be set.

;        lda time.getticks.result$
;        sta console.writeint32.integer$
;        lda time.getticks.result$+1
;        sta console.writeint32.integer$+1
;        lda time.getticks.result$+2
;        sta console.writeint32.integer$+2
;        lda time.getticks.result$+3
;        sta console.writeint32.integer$+3
;        jsr console.writeint32$

        ;bcc @loop ; Goto @loop if ticks < (milliseconds + ticks).
        bcs @end
        jmp @loop
@end
        rts

#endregion


memory.pushzp$

        ; The stack is pointing to the return address.        
        ; Get the return address
        pla
        sta $20
        inc $20
        pla
        sta $21

        ; Back up values $73-$8f
        ldx #0
@backup
        lda $73,x
        pha
        inx
        cpx #29
        bne @backup

        ; Implicit return.
        jmp ($0020)

        rts

memory.pullzp$

        ; The stack is pointing to the return address.        
        ; Get the return address
        pla
        sta $20
        inc $20
        pla
        sta $21

        ; Restore values $73-$79
        ldx #29
@restore
        dex
        pla
        sta $73,x
        cpx #0
        bne @restore

        ; Implicit return.
        jmp ($0020)

string.isequal.address1$ = $7a ; 2 bytes
string.isequal.address2$ = $7c ; 2 bytes
string.isequal.char = $7d ; 1 bytes
string.isequal.value$ = $7e ; 1 byte
string.isequal$
        ; Compares the values of address1 and address2 and determines if they are equal

        lda #$00
        sta string.isequal.value$
        
        lda string.isequal.address1$
        sta $fb
        lda string.isequal.address1$+1
        sta $fc

        lda string.isequal.address2$
        sta $fd
        lda string.isequal.address2$+1
        sta $fe

        ldy #$00
@loop
        lda ($fb),y
        sta string.isequal.char
        lda ($fd),y
        cmp string.isequal.char
        beq @cont
        jmp @done
@cont

        cmp #console.null$
        bne @skip0
        jmp @isequal
@skip0

        inc $fb
        bne @skip1
        inc $fc
@skip1

        inc $fd
        bne @skip2
        inc $fe
@skip2
        jmp @loop

@isequal
        lda #$01
        sta string.isequal.value$
        
@done
        rts

;time.halt2
;        jsr time.halt$
;        jsr time.halt$
;        rts

kernel.reset$
        jsr disk.reset$
        jmp ($FFFC)


disk.checkerror

        lda disk.error$
        cmp #diskerror.file_scratched$
        beq @FileScratched
        jmp @Done
@FileScratched
        ;lda #diskerror.file_not_found$
        lda #diskerror.ok$

@Done
        sta disk.error$
        rts

disk.validate$
        ; Set the prefix command "v"
        lda #"v"
        sta disk.execmd.filename

        lda #02
        sta disk.execmd.len

        jmp disk.execmd

;disk.reset.string text "u:"
;;disk.reset.len byte #02
;disk.reset$
;        ; There is no file name
;        LDA #$00
;        LDX #$00
;        LDY #$00
;        JSR $FFBD     ; call SETNAM

;        LDA #$0f      ; file number 15
;        LDX $BA       ; last used device number
;        BNE @skip
;        LDX #$08      ; default to device 8
;@skip   LDY #$0f      ; secondary address 15
;        JSR $FFBA     ; call SETLFS

;        JSR $FFC0     ; call OPEN
;        BCS @error    ; if carry set, the file could not be opened

;        ; check drive error channel here to test for
;        ; FILE EXISTS error etc.

;        LDX #$0f      ; filenumber 15
;        JSR $FFC9     ; call CHKOUT (file 15 now used as output)

;        ; SET THE MEMORY ADDRESS
;        LDA #<disk.reset.string
;        STA $AE
;        LDA #>disk.reset.string
;        STA $AF

;        LDY #$00
;@loop
;        ;LDX #$08
;        JSR $FFB7     ; call READST (read status byte)
;        ;BNE @werror   ; write error
;        BNE @error   ; write error
;        LDA ($AE),Y   ; get byte from memory
;        JSR $FFD2     ; call CHROUT (write byte to file)
;        INY
;        CPY #02
;        BNE @loop

;        ;; Wait two seconds
;;        ; 2000 = $07D0
;;        lda #$D0
;;        sta time.wait.milliseconds$
;;        lda #$07
;;        sta time.wait.milliseconds$+1
;;        lda #$00
;;        sta time.wait.milliseconds$+2
;;        sta time.wait.milliseconds$+3
;;        jsr time.wait$

;@close
;        ;LDA #$0f      ; filenumber 15
;        ;JSR $FFC3     ; call CLOSE

;        JSR $FFCC     ; call CLRCHN
;        RTS
;@error
;        ; Akkumulator contains BASIC error code

;        ; most likely errors:
;        ; A = $05 (DEVICE NOT PRESENT)

;        ;... error handling for open errors ...
;        JMP @close    ; even if OPEN failed, the file has to be closed
;;@werror
;;        ; for further information, the drive error channel has to be read

;;        ;... error handling for write errors ...
;;        JMP @close

disk.reset.string text "u:"
disk.reset$
        ; There is no file name
        LDA #$02
        LDX #<disk.reset.string
        LDY #>disk.reset.string
        JSR $FFBD     ; call SETNAM

        LDA #$0f      ; file number 15
        LDX $BA       ; last used device number
        BNE @skip
        LDX #$08      ; default to device 8
@skip   LDY #$0f      ; secondary address 15
        JSR $FFBA     ; call SETLFS

        JSR $FFC0     ; call OPEN
        BCS @error    ; if carry set, the file could not be opened
@error
@close
        ;LDA #$0f      ; filenumber 15
        ;JSR $FFC3     ; call CLOSE

        JSR $FFCC     ; call CLRCHN
        RTS

serial.open$

        jsr serial.set_baud

        lda $ba
        sta serial.prev_device

        ; Need to close the file first because of a bug in Covert Bitops when used with SD2IEC!
        lda #$05      ; filenumber 5
        ;nop
        ;nop
        jsr $ffc3     ; call CLOSE
        ;nop
        ;nop
        ;nop

        ;lda #2
        lda #1
        ldx #<serial.baud$
        ldy #>serial.baud$
        jsr $ffbd     ; call SETNAM

        lda #$05      ; file number 5
        ldx #$02      ; default to device 2
        ldy #$00      ; secondary address 0
        jsr $ffba     ; call SETLFS

        jsr $ffc0     ; call OPEN

        ; Set the RS232 input timer
        ;poke665,73-(peek(678)*30)
        lda 678 ; 0=NTSC, 1=PAL
        beq @poke_665_73
        lda #43
        jmp @sta_665
@poke_665_73
        lda #73
@sta_665
        sta 665

        rts



; Skip $2000-$2800 for custom character set

*=$2800


#region Math
align $100

math.add16.addend1$ = $80 ; 2 bytes
math.add16.addend2$ = $82 ; 2 bytes
math.add16.sum$ = $84 ; 2 bytes

math.add16$
        ; http://codebase64.org/doku.php?id=base:16bit_addition_and_subtraction
        clc                             ; clear carry
        lda math.add16.addend1$
        adc math.add16.addend2$
        sta math.add16.sum$                       ; store sum of LSBs
        lda math.add16.addend1$+1
        adc math.add16.addend2$+1                      ; add the MSBs using carry from
        sta math.add16.sum$+1                       ; the previous calculation
        rts

math.add24.addend1$ = $80 ; 3 bytes
math.add24.addend2$ = $83 ; 3 bytes
math.add24.sum$ = $86 ; 3 bytes

math.add24$
        clc                             ; clear carry
        lda math.add24.addend1$
        adc math.add24.addend2$
        sta math.add24.sum$
        lda math.add24.addend1$+1
        adc math.add24.addend2$+1
        sta math.add24.sum$+1
        lda math.add24.addend1$+2
        adc math.add24.addend2$+2
        sta math.add24.sum$+2
        rts

math.add32.addend1$ = $80 ; 4 bytes
math.add32.addend2$ = $84 ; 4 bytes
math.add32.sum$ = $88 ; 4 bytes

math.add32$
        clc                             ; clear carry
        lda math.add32.addend1$
        adc math.add32.addend2$
        sta math.add32.sum$
        lda math.add32.addend1$+1
        adc math.add32.addend2$+1
        sta math.add32.sum$+1
        lda math.add32.addend1$+2
        adc math.add32.addend2$+2
        sta math.add32.sum$+2
        lda math.add32.addend1$+3
        adc math.add32.addend2$+3
        sta math.add32.sum$+3
        rts

math.inc16.address$ = $86 ; 2 bytes

math.inc16$

        ; Store Y
        tya
        pha

        ldy #$00
        lda (math.inc16.address$),y
        sta math.add16.addend1$
        iny
        lda (math.inc16.address$),y
        sta math.add16.addend1$+1

        lda #$01
        sta math.add16.addend2$
        lda #$00
        sta math.add16.addend2$+1
        
        jsr math.add16$ ; (*address) = (*address) + 1

        lda math.add16.sum$
        ldy #$00
        sta (math.inc16.address$),y
        lda math.add16.sum$+1
        iny
        sta (math.inc16.address$),y

        ; Restore Y
        pla
        tay

        rts        

math.inc24.address$ = $86 ; 2 bytes
math.inc24$

        ; Store Y
        tya
        pha

        ldy #$00
        lda (math.inc24.address$),y
        sta math.add24.addend1$
        iny
        lda (math.inc24.address$),y
        sta math.add24.addend1$+1
        iny
        lda (math.inc24.address$),y
        sta math.add24.addend1$+2

        lda #$01
        sta math.add24.addend2$
        lda #$00
        sta math.add24.addend2$+1
        lda #$00
        sta math.add24.addend2$+2
        
        jsr math.add24$ ; (*address) = (*address) + 1

        lda math.add24.sum$
        ldy #$00
        sta (math.inc24.address$),y
        lda math.add24.sum$+1
        iny
        sta (math.inc24.address$),y
        lda math.add24.sum$+2
        iny
        sta (math.inc24.address$),y

        ; Restore Y
        pla
        tay

        rts        

math.subtract16.menuend$ = $80 ; 2 bytes
math.subtract16.subtrahend$ = $82 ; 2 bytes
math.subtract16.difference$ = $84 ; 2 bytes

math.subtract16$
        ; http://codebase64.org/doku.php?id=base:16bit_addition_and_subtraction
        sec                             ; set carry for borrow purpose
        lda math.subtract16.menuend$
        sbc math.subtract16.subtrahend$                      ; perform subtraction on the LSBs
        sta math.subtract16.difference$
        lda math.subtract16.menuend$+1                     ; do the same for the MSBs, with carry
        sbc math.subtract16.subtrahend$+1                      ; set according to the previous result
        sta math.subtract16.difference$+1
        rts

math.subtract32.menuend$ = $80 ; 4 bytes
math.subtract32.subtrahend$ = $84 ; 4 bytes
math.subtract32.difference$ = $88 ; 4 bytes

math.subtract32$
        sec                             ; set carry for borrow purpose
        lda math.subtract32.menuend$
        sbc math.subtract32.subtrahend$                      ; perform subtraction on the LSBs
        sta math.subtract32.difference$
        lda math.subtract32.menuend$+1                      ; do the same for the MSBs, with carry
        sbc math.subtract32.subtrahend$+1                      ; set according to the previous result
        sta math.subtract32.difference$+1
        lda math.subtract32.menuend$+2
        sbc math.subtract32.subtrahend$+2                      ; perform subtraction on the LSBs
        sta math.subtract32.difference$+2
        lda math.subtract32.menuend$+3                      ; do the same for the MSBs, with carry
        sbc math.subtract32.subtrahend$+3                      ; set according to the previous result
        sta math.subtract32.difference$+3
        rts


math.dec16.address$ = $86 ; 2 bytes

math.dec16$

        ; Store Y
        tya
        pha

        ldy #$00
        lda (math.dec16.address$),y
        sta math.subtract16.menuend$
        iny
        lda (math.dec16.address$),y
        sta math.subtract16.menuend$+1

        lda #$01
        sta math.subtract16.subtrahend$
        lda #$00
        sta math.subtract16.subtrahend$+1
        
        jsr math.subtract16$ ; (*address) = (*address) - 1

        lda math.subtract16.difference$
        ldy #$00
        sta (math.dec16.address$),y
        lda math.subtract16.difference$+1
        iny
        sta (math.dec16.address$),y

        ; Restore Y
        pla
        tay

        rts


math.cmp16.num1$ = $80 ; 2 bytes
math.cmp16.num2$ = $82 ; 2 bytes

math.cmp16$
        lda math.cmp16.num1$+1
        cmp math.cmp16.num2$+1
        bne @done
        lda math.cmp16.num1$
        cmp math.cmp16.num2$
@done
        rts

align $100

math.cmp32.num1$ = $80 ; 4 bytes
math.cmp32.num2$ = $84 ; 4 bytes

math.cmp32$
        lda math.cmp32.num1$+3
        cmp math.cmp32.num2$+3
        bne @done
        lda math.cmp32.num1$+2
        cmp math.cmp32.num2$+2
        bne @done
        lda math.cmp32.num1$+1
        cmp math.cmp32.num2$+1
        bne @done
        lda math.cmp32.num1$
        cmp math.cmp32.num2$
@done
        rts

math.random8.seed$ = $80 ; 1 byte
math.random8.result$ = $80 ; 1 byte

math.random8$
        ; http://codebase64.org/doku.php?id=base:small_fast_8-bit_prng
        lda math.random8.seed$
        beq @doEor
        clc
        asl
        beq @noEor ;if the input was $80, skip the EOR
        bcc @noEor
@doEor
        eor #$12 ; magic number
@noEor
        sta math.random8.result$
        rts

math.random16.seed$ = $80 ; 2 bytes
math.random16.result$ = $80 ; 2 bytes

math.random16$
        lda math.random16.seed$
        beq @lowZero ; $0000 and $8000 are special values to test for

        ; Do a normal shift
        asl math.random16.seed$
        lda math.random16.seed$+1
        rol
        bcc @noEor

@doEor
        ; high byte is in .A
        eor #34 ; magic number (hi)
        sta math.random16.seed$+1
        lda math.random16.seed$
        eor #12 ; magic number (lo)
        sta math.random16.seed$
        rts

@lowZero
        lda math.random16.seed$+1
        beq @doEor ; High byte is also zero, so apply the EOR
           ; For speed, you could store 'magic' into 'seed' directly
           ; instead of running the EORs

        ; wasn't zero, check for $8000
        asl
        beq @noEor ; if $00 is left after the shift, then it was $80
        bcs @doEor ; else, do the EOR based on the carry bit as usual

@noEor
        sta math.random16.seed$+1
        rts


;align $100

math.multiply8.factor1$ = $80 ; 1 byte
math.multiply8.factor2$ = $82 ; 1 byte
math.multiply8.product$ = $83 ; 1 byte

math.multiply8$
        ; http://codebase64.org/doku.php?id=base:8bit_multiplication_16bit_product
        lda #$00
        tay
        sty math.multiply8.factor1$+1  ; remove this line for 16*8=16bit multiply
        beq @enterLoop

@doAdd
        clc
        adc math.multiply8.factor1$
        tax

        tya
        adc math.multiply8.factor1$+1
        tay
        txa

@loop
        asl math.multiply8.factor1$
        rol math.multiply8.factor1$+1
@enterLoop  ; accumulating multiply entry point (enter with .A=lo, .Y=hi)
        lsr math.multiply8.factor2$
        bcs @doAdd
        bne @loop

        sta math.multiply8.product$
        sty math.multiply8.product$+1
        rts

math.multiply16.factor1$ = $80 ; 2 bytes
math.multiply16.factor2$ = $82 ; 2 bytes
math.multiply16.product$ = $84 ; 2 bytes

math.multiply16$
        ; http://codebase64.org/doku.php?id=base:16bit_multiplication_32-bit_product
        lda #$00
        sta math.multiply16.product$+2       ; clear upper bits of product
        sta math.multiply16.product$+3 
        ldx #$10            ; set binary count to 16 
@shift_r
        lsr math.multiply16.factor1$+1    ; divide multiplier by 2 
        ror math.multiply16.factor1$
        bcc @rotate_r 
        lda math.multiply16.product$+2       ; get upper half of product and add multiplicand
        clc
        adc math.multiply16.factor2$
        sta math.multiply16.product$+2
        lda math.multiply16.product$+3
        adc math.multiply16.factor2$+1
@rotate_r        
        ror                     ; rotate partial product 
        sta math.multiply16.product$+3
        ror math.multiply16.product$+2
        ror math.multiply16.product$+1 
        ror math.multiply16.product$ 
        dex
        bne @shift_r 
        rts

math.multiply32.factor1$ = $80 ; 4 bytes
math.multiply32.factor2$ = $84 ; 4 bytes
math.multiply32.product$ = $88 ; 4 bytes

math.multiply32$
        lda #$00                        ; set product to zero
        sta math.multiply32.product$
        sta math.multiply32.product$+1
        sta math.multiply32.product$+2
        sta math.multiply32.product$+3

@loop
        lda math.multiply32.factor2$                     ; while factor2 != 0
        bne @nz
        lda math.multiply32.factor2$+1
        bne @nz
        lda math.multiply32.factor2$+2
        bne @nz
        lda math.multiply32.factor2$+3
        bne @nz
        rts
@nz
        lda math.multiply32.factor2$                     ; if factor2 is odd
        and #$01
        beq @skip
        
        lda math.multiply32.factor1$                     ; product += factor1
        clc
        adc math.multiply32.product$
        sta math.multiply32.product$
        
        lda math.multiply32.factor1$+1
        adc math.multiply32.product$+1
        sta math.multiply32.product$+1
        
        lda math.multiply32.factor1$+2
        adc math.multiply32.product$+2
        sta math.multiply32.product$+2

        lda math.multiply32.factor1$+3
        adc math.multiply32.product$+3
        sta math.multiply32.product$+3

@skip
        asl math.multiply32.factor1$
        rol math.multiply32.factor1$+1
        rol math.multiply32.factor1$+2
        rol math.multiply32.factor1$+3
        lsr math.multiply32.factor2$+3
        ror math.multiply32.factor2$+2
        ror math.multiply32.factor2$+1
        ror math.multiply32.factor2$

        jmp @loop                       ; end while


;align $100

math.divide8.divisor$ = $80 ; 1 byte
math.divide8.dividend$ = $81 ; 1 byte
math.divide8.quotient$ = math.divide8.dividend$ ; 1 byte
math.divide8.remainder$ = $82 ; 1 byte

math.divide8$
        ; http://codebase64.org/doku.php?id=base:8bit_divide_8bit_product
        lda #$00
        ldx #$07
        clc
@loop1
        rol math.divide8.dividend$
        rol
        cmp math.divide8.divisor$
        bcc @loop2
        sbc math.divide8.divisor$
@loop2
        dex
        bpl @loop1
        rol math.divide8.dividend$
        sta math.divide8.remainder$
        rts

align $100

math.divide16.divisor$ = $80 ; 2 bytes
math.divide16.dividend$ = $82 ; 2 bytes
math.divide16.quotient$ = math.divide16.dividend$ ; 2 bytes
math.divide16.remainder$ = $84 ; 2 bytes

math.divide16$
        ; http://codebase64.org/doku.php?id=base:16bit_division_16-bit_result
        lda #0          ;preset remainder to 0
        sta math.divide16.remainder$
        sta math.divide16.remainder$+1
        ldx #16         ;repeat for each bit: ...

@loop
        asl math.divide16.dividend$    ;dividend lb & hb*2, msb -> Carry
        rol math.divide16.dividend$+1
        rol math.divide16.remainder$   ;remainder lb & hb * 2 + msb from carry
        rol math.divide16.remainder$+1
        lda math.divide16.remainder$
        sec
        sbc math.divide16.divisor$     ;substract divisor to see if it fits in
        tay             ;lb result -> Y, for we may need it later
        lda math.divide16.remainder$+1
        sbc math.divide16.divisor$+1
        bcc @skip        ;if carry=0 then divisor didn't fit in yet

        sta math.divide16.remainder$+1 ;else save substraction result as new remainder,
        sty math.divide16.remainder$   
        inc math.divide16.quotient$      ;and INCrement result cause divisor fit in 1 times

@skip    
        dex
        bne @loop     
        rts

math.divide32.divisor$ = $80 ; 4 bytes
math.divide32.dividend$ = $84 ; 4 bytes
math.divide32.quotient$ = math.divide32.dividend$ ; 4 bytes
math.divide32.remainder$ = $8c ; 4 bytes (don't use $88-$8b as this will mess up time.getticks)
math.divide32.temp1 = $fb ; 1 byte
math.divide32.temp2 = $fe ; 1 byte

math.divide32$
        ; http://www.codebase64.org/doku.php?id=base:24bit_division_24-bit_result
        lda #0          ;preset remainder to 0
        sta math.divide32.remainder$
        sta math.divide32.remainder$+1
        sta math.divide32.remainder$+2
        sta math.divide32.remainder$+3
        sta math.divide32.temp1
        sta math.divide32.temp2
        ldx #32         ;repeat for each bit: ...

@divloop 
        asl math.divide32.dividend$    ;dividend lb & hb*2, msb -> Carry
        rol math.divide32.dividend$+1
        rol math.divide32.dividend$+2
        rol math.divide32.dividend$+3
        rol math.divide32.remainder$   ;remainder lb & hb * 2 + msb from carry
        rol math.divide32.remainder$+1
        rol math.divide32.remainder$+2
        rol math.divide32.remainder$+3
        lda math.divide32.remainder$
        sec
        sbc math.divide32.divisor$     ;substract divisor to see if it fits in
        tay             ;lb result -> Y, for we may need it later
        lda math.divide32.remainder$+1
        sbc math.divide32.divisor$+1
        sta math.divide32.temp1
        lda math.divide32.remainder$+2
        sbc math.divide32.divisor$+2
        sta math.divide32.temp2
        lda math.divide32.remainder$+3
        sbc math.divide32.divisor$+3
        bcc @skip        ;if carry=0 then divisor didn't fit in yet

        sta math.divide32.remainder$+3 ;else save substraction result as new remainder,
        lda math.divide32.temp2
        sta math.divide32.remainder$+2 ;else save substraction result as new remainder,
        lda math.divide32.temp1
        sta math.divide32.remainder$+1
        sty math.divide32.remainder$
        inc math.divide32.dividend$    ;and INCrement result cause divisor fit in 1 times

@skip    
        dex
        ;bne @divloop
        beq @done
        jmp @divloop

@done
        rts

math.abs16.integer$ = $80 ; 2 bytes
math.abs16.value$ = $84 ; 2 bytes
math.abs16$
        lda math.abs16.integer$
        ldy math.abs16.integer$+1
        ldx math.abs16.integer$+1
        bpl @end     ;if the number is positive, exit
        sec           ;else take the 2's complement of the negative
        sta math.abs16.integer$+1       ;  value to get the positive value
        lda #$00
        sbc math.abs16.integer$+1
        pha
        sty math.abs16.integer$+1
        lda #$00
        sbc math.abs16.integer$+1
        tay
        pla
@end
        sta math.abs16.value$
        sty math.abs16.value$+1
        rts

; See memory.swap$
;math.swap16.intaddress1$ = $80 ; 2 bytes
;math.swap16.intaddress2$ = $84 ; 2 bytes
;math.swap16.temp = $88 ; 2 bytes
;math.swap16$
;        ; temp = integer1
;        ldy #$00
;        lda (math.swap16.intaddress1$),y
;        sta math.swap16.temp
;        iny
;        lda (math.swap16.intaddress1$),y
;        sta math.swap16.temp+1

;        ; integer1 = integer2
;        ldy #$00
;        lda (math.swap16.intaddress2$),y
;        sta (math.swap16.intaddress1$),y
;        iny
;        lda (math.swap16.intaddress2$),y
;        sta (math.swap16.intaddress1$),y

;        ; integer2 = temp
;        ldy #$00
;        lda math.swap16.temp
;        sta (math.swap16.intaddress2$),y
;        iny
;        lda math.swap16.temp+1
;        sta (math.swap16.intaddress2$),y

;        rts

math.exponent8.base$ = $8a
math.exponent8.power$ = $8b
math.exponent8.value$ = $8c
math.exponent8$

        lda #$01
        sta math.exponent8.value$

@Loop
        lda math.exponent8.power$
        bne @Continue
        rts
@Continue
        lda math.exponent8.base$
        sta math.multiply8.factor1$
        lda math.exponent8.value$
        sta math.multiply8.factor2$
        jsr math.multiply8$
        lda math.multiply8.product$
        sta math.exponent8.value$
        dec math.exponent8.power$
        jmp @Loop

#endregion


#region String

;align $100

string.create.character$ = $02 ; 1 byte
string.create.length$ = $fb ; 2 bytes
string.create.address$ = $7a ; 2 bytes
string.create.address_lr = $fd ; 2 bytes
string.create$

        ; Increase the length by one.
        jsr string.create.inc_length ; length = length + 1

        ; Allocate the memory block.
        lda string.create.length$
        sta memory.allocate.length$
        lda string.create.length$+1
        sta memory.allocate.length$+1

        jsr memory.allocate$ ; address$ = memory.allocate$(length)

        lda memory.allocate.address$
        sta string.create.address$
        lda memory.allocate.address$+1
        sta string.create.address$+1

        jsr string.create.dec_length ; length = length - 1

        ; Fill the memory with the default character.
        lda string.create.character$
        cmp #$00
        beq @SkipFillStr ; Skip the fill if the default character is $00
        sta memory.fill16.value$

        lda string.create.address$
        sta memory.fill16.address$
        lda string.create.address$+1
        sta memory.fill16.address$+1

        lda string.create.length$
        sta memory.fill16.length$
        lda string.create.length$+1
        sta memory.fill16.length$+1

        jsr memory.fill16$
@SkipFillStr

        ; Caculate the location of the last character.
        lda string.create.address$
        sta math.add16.addend1$
        lda string.create.address$+1
        sta math.add16.addend1$+1

        lda string.create.length$
        sta math.add16.addend2$
        lda string.create.length$+1
        sta math.add16.addend2$+1

        jsr math.add16$ ; address_lr = address + length

        lda math.add16.sum$
        sta string.create.address_lr
        lda math.add16.sum$+1
        sta string.create.address_lr+1

        ; The last address needs to be the null$ character.
        ldy #$00
        lda #console.null$
        sta (string.create.address_lr),y

        rts

string.create.inc_length
        lda string.create.length$
        sta math.add16.addend1$
        lda string.create.length$+1
        sta math.add16.addend1$+1

        lda #$01
        sta math.add16.addend2$
        lda #$00
        sta math.add16.addend2$+1

        jsr math.add16$ ; length = length + 1

        lda math.add16.sum$
        sta string.create.length$
        lda math.add16.sum$+1
        sta string.create.length$+1

        rts

string.create.dec_length
        lda string.create.length$
        sta math.subtract16.menuend$
        lda string.create.length$+1
        sta math.subtract16.menuend$+1

        lda #$01
        sta math.subtract16.subtrahend$
        lda #$00
        sta math.subtract16.subtrahend$+1

        jsr math.subtract16$ ; length = length - 1

        lda math.subtract16.difference$
        sta string.create.length$
        lda math.subtract16.difference$+1
        sta string.create.length$+1

        rts

string.isheap.address$ = $7a ; 2 bytes
string.isheap.heap$ = $73 ; 1 byte
string.isheap$

        ; Default heap$ = 0
        lda #$00
        sta string.isheap.heap$

        ; Determine whether or not the address is in the memory heap.
        lda string.isheap.address$
        sta math.cmp16.num1$
        lda string.isheap.address$+1
        sta math.cmp16.num1$+1

        lda memory.heapadress_lr
        sta math.cmp16.num2$
        lda memory.heapadress_lr+1
        sta math.cmp16.num2$+1

        jsr math.cmp16$ ; Carry flag is set if address$ >= memory.heapaddress_lr
        bcs @end
        
        ; Determine whether or not the address is in the memory heap.
        lda memory.heapadress
        sta math.cmp16.num1$
        lda memory.heapadress+1
        sta math.cmp16.num1$+1

        lda string.isheap.address$
        sta math.cmp16.num2$
        lda string.isheap.address$+1
        sta math.cmp16.num2$+1

        jsr math.cmp16$ ; Carry flag is set if memory.heapadress$ >= address$
        bcs @end

        lda #$01
        sta string.isheap.heap$

@end
        rts

string.getlength.address$ = $7a ; 2 bytes
string.getlength.length$ = $fb ; 2 bytes
string.getlength$
        
        ; Check to see if the address is from the heap
        lda string.getlength.address$
        sta string.isheap.address$
        lda string.getlength.address$+1
        sta string.isheap.address$+1

        jsr string.isheap$ ; string.isheap$(address$)
        lda string.isheap.heap$
        cmp #$01
        beq @GetSizeOf
        jsr string.getlength_GetNullChar
        jmp @End
@GetSizeOf
        jsr string.getlength_GetSizeOf
@End
        rts

string.getlength_GetNullChar
        ; We should only get here if the string is a constant.

        ; Count up the number of non-null$ characters.
        ldy #$00
        sty string.getlength.length$
        sty string.getlength.length$+1
@Loop
        lda (string.getlength.address$),y
        cmp #console.null$
        beq @Done
        iny
        cpy #$00 ; If Y = $00 then we wrapped around the lo-byte
        bne @Loop
        ; Increment the address and length hi-bytes
        inc string.getlength.address$+1
        inc string.getlength.length$+1
        jmp @Loop
@Done
        sty string.getlength.length$

        rts

string.getlength_GetSizeOf
        ; We should only get here if the string is created via string.create$

        lda string.getlength.address$
        sta memory.sizeof.address$
        lda string.getlength.address$+1
        sta memory.sizeof.address$+1

        jsr memory.sizeof$ ; length$ = memory.sizeof$(address$)

        ; memory.sizeof() returns the length of the memory block
        ; including the 2 bytes which is the length of the block and
        ; because string.create$ appends a null$ character,
        ; we need to subtract 3 bytes from sizeof to get the length.
        
        lda memory.sizeof.length$
        sta math.subtract16.menuend$
        lda memory.sizeof.length$+1
        sta math.subtract16.menuend$+1

        lda #$03
        sta math.subtract16.subtrahend$
        lda #$00
        sta math.subtract16.subtrahend$+1

        jsr math.subtract16$ ; length$ = length$ - 1

        lda math.subtract16.difference$
        sta string.getlength.length$
        lda math.subtract16.difference$+1
        sta string.getlength.length$+1

        rts

;align $100


string.copy.srcaddress$ = $7e ; 2 bytes
string.copy.dstaddress$ = $7a ; 2 bytes
string.copy$
        ; Creates a new instance of a string with the same characters as the source

        ; Get the length of the source address
        lda string.copy.srcaddress$
        sta string.getlength.address$
        lda string.copy.srcaddress$+1
        sta string.getlength.address$+1
        jsr string.getlength$

        ; Create the new string
        lda string.getlength.length$
        sta string.create.length$
        lda string.getlength.length$+1
        sta string.create.length$+1

        ; Setting #0 will tell the create routine to skip the fill part
        lda #$00
        sta string.create.character$
        jsr string.create$

        lda string.create.address$
        sta string.copy.dstaddress$
        lda string.create.address$+1
        sta string.copy.dstaddress$+1

        ; Copy the contents of source address to address
        lda string.copy.srcaddress$
        sta memory.copy16.source$
        lda string.copy.srcaddress$+1
        sta memory.copy16.source$+1

        lda string.copy.dstaddress$
        sta memory.copy16.destination$
        lda string.copy.dstaddress$+1
        sta memory.copy16.destination$+1

        lda string.getlength.length$
        sta memory.copy16.length$
        lda string.getlength.length$+1
        sta memory.copy16.length$+1

        jsr memory.copy16$

        rts

string.contains.address1$ = $7a ; 2 bytes
string.contains.address2$ = $7c ; 2 bytes
string.contains.value$ = $73 ; 1 byte
string.contains$
        ; Sets value$ = 1 if the string at address1$ contains address2$

        lda string.contains.address1$
        sta string.indexof.address1$
        lda string.contains.address1$+1
        sta string.indexof.address1$+1

        lda string.contains.address2$
        sta string.indexof.address2$
        lda string.contains.address2$+1
        sta string.indexof.address2$+1

        lda #$00
        sta string.indexof.index$
        sta string.indexof.index$+1

        jsr string.indexof$ ; index$ = string.indexof$(address1$, address2$, 0)

        lda string.indexof.index$
        sta math.cmp16.num1$
        lda string.indexof.index$+1
        sta math.cmp16.num1$+1

        lda #$ff
        sta math.cmp16.num2$
        sta math.cmp16.num2$+1

        jsr math.cmp16$ ; If index$ <> $ffff then value$ = 1
        bne @SetValue
@ClearValue
        lda #$00
        jmp @End

@SetValue
        lda #$01
@End
        sta string.contains.value$
        rts

;align $100

string.indexof.address1$ = $7a ; 2 bytes
string.indexof.address2$ = $7c ; 2 bytes
string.indexof.index$ = $7e ; 2 bytes
string.indexof.chr1 = $73 ; 1 byte
string.indexof.chr2 = $74 ; 1 byte
string.indexof.address1_org = $fb ; 2 bytes
string.indexof.address2_org = $fd ; 2 bytes
string.indexof$
        ; Find the index where theree exists an occurance of a string within another.

        jsr memory.pushzp$

        ; Verify that the length of index is not greater than address1$
        lda string.indexof.address1$
        sta string.getlength.address$
        lda string.indexof.address1$+1
        sta string.getlength.address$+1
        jsr string.getlength$

        jsr memory.pullzp$

        lda string.indexof.index$
        sta math.cmp16.num1$
        lda string.indexof.index$+1
        sta math.cmp16.num1$+1

        lda string.getlength.length$
        sta math.cmp16.num2$
        lda string.getlength.length$+1
        sta math.cmp16.num2$+1

        jsr math.cmp16$
        bcc @LengthOK ; OK if index$ < string.getlength$(address1$)
        beq @LengthOK ; OK if index$ = string.getlength$(address1$)
        jmp @NoFoundStr

@LengthOK
        ; Store the orginal addresses
        lda string.indexof.address1$
        sta string.indexof.address1_org
        lda string.indexof.address1$+1
        sta string.indexof.address1_org+1
        
        lda string.indexof.address2$
        sta string.indexof.address2_org
        lda string.indexof.address2$+1
        sta string.indexof.address2_org+1
 
        jmp @InitAddresses
       
@NoMatchChr
        ; Increment index$
        lda #<string.indexof.index$
        sta math.inc16.address$
        lda #>string.indexof.index$
        sta math.inc16.address$+1
        jsr math.inc16$

@InitAddresses
        ; Update the location of address1$ by the value in index$
        lda string.indexof.address1_org
        sta math.add16.addend1$
        lda string.indexof.address1_org+1
        sta math.add16.addend1$+1

        lda string.indexof.index$
        sta math.add16.addend2$
        lda string.indexof.index$+1
        sta math.add16.addend2$+1

        jsr math.add16$ ; address1$ = address1$ + index$

        lda math.add16.sum$
        sta string.indexof.address1$
        lda math.add16.sum$+1
        sta string.indexof.address1$+1

        lda string.indexof.address2_org
        sta string.indexof.address2$
        lda string.indexof.address2_org+1
        sta string.indexof.address2$+1

;        ; Default string.indexof.index$ to $ffff (-1)
;        lda #$00
;        lda string.indexof.index$
;        lda string.indexof.index$+1
        
        ; Begin matching each character in the address2$ with address1$
        ldy #$00
@Loop
        lda (string.indexof.address1$),y
        sta string.indexof.chr1

        lda (string.indexof.address2$),y
        sta string.indexof.chr2
        cmp #console.null$
        beq @FoundStr

        lda string.indexof.chr1
        cmp #console.null$
        beq @NoFoundStr

        cmp string.indexof.chr2
        bne @NoMatchChr
        
;        tax
;        cmp (string.indexof.address2$),y
;        bne @NoMatchChr
;        cpx #console.null$
;        beq @NoFoundStr

        ; Increment index$
        lda #<string.indexof.index$
        sta math.inc16.address$
        lda #>string.indexof.index$
        sta math.inc16.address$+1
        jsr math.inc16$

        iny
        cpy #$00
        beq @IncY
        jmp @Loop

@IncY
        inc string.indexof.address1$+1
        inc string.indexof.address2$+1
        jmp @Loop

@NoFoundStr
        ; index$ = $ffff (Not found)
        lda #$ff
        sta string.indexof.index$
        sta string.indexof.index$+1
        jmp @End

@FoundStr
        ; index$ = index$ - string.getlength$(address2)
        
        lda string.indexof.address2$
        sta string.getlength.address$
        lda string.indexof.address2$+1
        sta string.getlength.address$+1

        jsr string.getlength$

        lda string.indexof.index$
        sta math.subtract16.menuend$
        lda string.indexof.index$+1
        sta math.subtract16.menuend$+1

        lda string.getlength.length$
        sta math.subtract16.subtrahend$
        lda string.getlength.length$+1
        sta math.subtract16.subtrahend$+1

        jsr math.subtract16$

        lda math.subtract16.difference$
        sta string.indexof.index$
        lda math.subtract16.difference$+1
        sta string.indexof.index$+1

@End
        rts

string.concat.srcaddress1$ = $e0 ; 2 bytes
string.concat.srcaddress2$ = $e2 ; 2 bytes
string.concat.dstaddress$ = $7a ; 2 bytes
string.concat.srclength1 = $e4 ; 2 bytes
string.concat.srclength2 = $e6 ; 2 bytes
string.concat.dstlength = $e8 ; 2 bytes
string.concat.address = $ea ; 2 bytes
string.concat$
        ; Returns a new string which contains the contents of srcaddress1 + srcaddress2

        ; Create a new string which has the length of srcaddress1 + srcaddress2

        ; string.concat.srclength1 = string.getlength$(string.concat.srcaddress1$)
        lda string.concat.srcaddress1$
        sta string.getlength.address$
        lda string.concat.srcaddress1$+1
        sta string.getlength.address$+1
        jsr string.getlength$
        lda string.getlength.length$
        sta string.concat.srclength1
        lda string.getlength.length$+1
        sta string.concat.srclength1+1

        ; string.concat.srclength2 = string.getlength$(string.concat.srcaddress2$)
        lda string.concat.srcaddress2$
        sta string.getlength.address$
        lda string.concat.srcaddress2$+1
        sta string.getlength.address$+1
        jsr string.getlength$
        lda string.getlength.length$
        sta string.concat.srclength2
        lda string.getlength.length$+1
        sta string.concat.srclength2+1

        ; string.concat.dstlength = string.concat.srclength1 + string.concat.srclength2
        lda string.concat.srclength1
        sta math.add16.addend1$
        lda string.concat.srclength1+1
        sta math.add16.addend1$+1
        lda string.concat.srclength2
        sta math.add16.addend2$
        lda string.concat.srclength2+1
        sta math.add16.addend2$+1
        jsr math.add16$
        lda math.add16.sum$
        sta string.concat.dstlength
        lda math.add16.sum$+1
        sta string.concat.dstlength+1

        ; string.concat.dstaddress$ = string.create$(string.concat.dstlength, 0)
        lda string.concat.dstlength
        sta string.create.length$
        lda string.concat.dstlength+1
        sta string.create.length$+1
        lda #$00
        sta string.create.character$
        jsr string.create$
        lda string.create.address$
        sta string.concat.dstaddress$
        sta string.concat.address
        lda string.create.address$+1
        sta string.concat.address+1
        sta string.concat.dstaddress$+1

        ; Copy the contents from srcaddress1 to dstaddress
        lda string.concat.srcaddress1$
        sta memory.copy16.source$
        lda string.concat.srcaddress1$+1
        sta memory.copy16.source$+1

        lda string.concat.address
        sta memory.copy16.destination$
        lda string.concat.address+1
        sta memory.copy16.destination$+1

        lda string.concat.srclength1
        sta memory.copy16.length$
        lda string.concat.srclength1+1
        sta memory.copy16.length$+1

        jsr memory.copy16$        

        ; Increment address by srclength1
        lda string.concat.address
        sta math.add16.addend1$
        sta memory.copy16.source$+1
        lda math.add16.addend1$+1
        
        lda string.concat.srclength1
        sta math.add16.addend2$
        lda string.concat.srclength1+1
        sta math.add16.addend2$+1

        jsr math.add16$ ; address = address + srclength1

        lda math.add16.sum$
        sta string.concat.address
        lda math.add16.sum$+1
        sta string.concat.address+1

        ; Copy the contents from srcaddress2 to dstaddress
        lda string.concat.srcaddress2$
        sta memory.copy16.source$
        lda string.concat.srcaddress2$+1
        sta memory.copy16.source$+1

        lda string.concat.address
        sta memory.copy16.destination$
        sta string.concat.address+1
        lda memory.copy16.destination$+1

        lda string.concat.srclength2
        sta memory.copy16.length$
        lda string.concat.srclength2+1
        sta memory.copy16.length$+1

        jsr memory.copy16$        

        rts

#region

#region Graphics
;align $100

graphics.memoryaddress           = $6000 ; - $7f3f
graphics.memoryaddress_2r        = $6140
graphics.memoryaddress_lr        = $7e00
graphics.currentaddress          word console.memoryaddress
graphics.coloraddress            = $4400
graphics.currentcoloraddr        word graphics.coloraddress
graphics.bitmapcoloraddress      = $7f40
graphics.multivideofile          = $7f40
graphics.multicolorfile          = $8328
graphics.multibgcolorfile        = $8710
graphics.multivideoaddress       = $4400
graphics.multicoloraddress       = $d800
graphics.multibgcoloraddress     = $d021

graphics.imageaddress$           = $6000

;TODO change the addresses below accordingly:
;graphics.Y_Table_Lo              = $c100
;graphics.Y_Table_Hi              = $c200
;graphics.X_Table                 = $c300
;graphics.BitMask                 = $c400
graphics.Y_Table_Lo              = graphics.Y_Table_Lo_address
graphics.Y_Table_Hi              = graphics.Y_Table_Hi_address
graphics.X_Table                 = graphics.X_Table_address
graphics.BitMask                 = graphics.BitMask_address

graphics.isactive$               byte $00

graphics.enter$
        jsr graphics.start
        rts

graphics.leave$
        jsr graphics.end
        rts

graphics.setbitmapmode$
        ; Indicate that graphics mode is active
        lda #$01
        sta graphics.isactive$

;        ldx #$00
;@loop
;        lda graphics.bitmapcoloraddress,x  ; copy colours to screen RAM
;        sta graphics.coloraddress,x
;        lda graphics.bitmapcoloraddress+$100,x
;        sta graphics.coloraddress+$100,x
;        lda graphics.bitmapcoloraddress+$200,x
;        sta graphics.coloraddress+$200,x
;        lda graphics.bitmapcoloraddress+$300,x
;        sta graphics.coloraddress+$300,x
;        dex
;        bne @loop

        ;$DD00 = %xxxxxx11 -> bank0: $0000-$3fff
        ;$DD00 = %xxxxxx10 -> bank1: $4000-$7fff
        ;$DD00 = %xxxxxx01 -> bank2: $8000-$bfff
        ;$DD00 = %xxxxxx00 -> bank3: $c000-$ffff
        ; Default: 10010111
        lda $DD00
        and #%11111100
        ora #%00000010 ;<- your desired VIC bank value, see above
        ;ora #%00000011 ;<- your desired VIC bank value, see above
        sta $DD00

;        ; Set Bitmap memory at $2000+VIC Bank Address ($6000)
;        lda $d018
;        ;ora #%00001000
;        ora #%00011000
;        sta $d018

;        ; Enter Standard Bitmap Mode
;        lda $d011
;        ora #%00100000
;        sta $d011

        lda #$3b     ; bitmap mode
        ;ldx #$18     ; multi-colour mode
        ldy #$18     ; screen at $0400, bitmap at $2000
        sta $d011
        ;stx $d016
        sty $d018

        ; Set the Sprite addresses be $4200-$43ff
        lda #$08
        sta $47f8
        lda #$09
        sta $47f9
        lda #$0a
        sta $47fa
        lda #$0b
        sta $47fb
        lda #$0c
        sta $47fc
        lda #$0d
        sta $47fd
        lda #$0e
        sta $47fe
        lda #$0f
        sta $47ff

        rts

graphics.sethiresmode$
        jsr graphics.setbitmapmode$

        ldx #$00 
@loop
        ; Transfers video data 
        lda graphics.multivideofile,x 
        sta graphics.multivideoaddress,x 
        lda graphics.multivideofile+$100,x 
        sta graphics.multivideoaddress+$100,x 
        lda graphics.multivideofile+$200,x 
        sta graphics.multivideoaddress+$200,x 
        lda graphics.multivideofile+$2e8,x 
        sta graphics.multivideoaddress+$2e8,x 
        inx 
        bne @loop 

graphics.disablemulticolormode$
        ; Disable Multi-Color Mode
        lda $d016
        and #%11101111 ; Bit #4: 0 = Multicolor mode off.
        sta $d016

        rts

graphics.setmulticolormode$
        jsr graphics.setbitmapmode$

        lda graphics.multibgcolorfile
        sta graphics.multibgcoloraddress ; Screen Color 

        ldx #$00 
@loop
        ; Transfers video data 
        lda graphics.multivideofile,x 
        sta graphics.multivideoaddress,x 
        lda graphics.multivideofile+$100,x 
        sta graphics.multivideoaddress+$100,x 
        lda graphics.multivideofile+$200,x 
        sta graphics.multivideoaddress+$200,x 
        lda graphics.multivideofile+$2e8,x 
        sta graphics.multivideoaddress+$2e8,x 
        ; Transfers color data 
        lda graphics.multicolorfile,x 
        sta graphics.multicoloraddress,x 
        lda graphics.multicolorfile+$100,x 
        sta graphics.multicoloraddress+$100,x 
        lda graphics.multicolorfile+$200,x 
        sta graphics.multicoloraddress+$200,x 
        lda graphics.multicolorfile+$2e8,x 
        sta graphics.multicoloraddress+$2e8,x 
        inx 
        bne @loop 

graphics.enablemulticolormode$
        ; EnableMulti-Color Mode
        lda $d016
        ora #%00010000 ; Bit #4: 1 = Multicolor mode on.
        sta $d016

        rts

graphics.settextmode$
        ; Leave Standard Bitmap Mode
        lda $d011
        and #%11011111
        sta $d011

        ;$DD00 = %xxxxxx11 -> bank0: $0000-$3fff
        ;$DD00 = %xxxxxx10 -> bank1: $4000-$7fff
        ;$DD00 = %xxxxxx01 -> bank2: $8000-$bfff
        ;$DD00 = %xxxxxx00 -> bank3: $c000-$ffff
        ; Default: 10010111
        lda $DD00
        and #%11111100
        ;ora #%00000010 ;<- your desired VIC bank value, see above
        ora #%00000011 ;<- your desired VIC bank value, see above
        sta $DD00

        ; Indicate that graphics mode is inactive
        lda #$00
        sta graphics.isactive$
        
        rts

graphics.start

        jsr console.clear$
        jsr graphics.clear$

        jsr graphics.sethiresmode$

        jsr graphics.setcolor$
        jsr graphics.createtable
 
        rts

graphics.end
        ;; Set Bitmap memory at $2000+VIC Bank Address ($2000)
;        lda $d018
;        and #%11110001
;        ora #%00000010 ; $0800
;        sta $d018

        jsr console.clear$
        jsr graphics.clear$

        jsr graphics.settextmode$

        rts

;align $100

graphics.setcolor$
        ldx #$00
        lda #$10 ; White on black
@loop
        sta graphics.coloraddress,x
        sta graphics.coloraddress+$100,x
        sta graphics.coloraddress+$200,x
        sta graphics.coloraddress+$300,x
        dex
        ;bne @loop
        beq @done
        jmp @loop

@done
        rts

graphics.clear$
        ldx #$00
        lda #$00
@loop
        sta graphics.memoryaddress,x
        sta graphics.memoryaddress+$100,x
        sta graphics.memoryaddress+$200,x
        sta graphics.memoryaddress+$300,x
        sta graphics.memoryaddress+$400,x
        sta graphics.memoryaddress+$500,x
        sta graphics.memoryaddress+$600,x
        sta graphics.memoryaddress+$700,x
        sta graphics.memoryaddress+$800,x
        sta graphics.memoryaddress+$900,x
        sta graphics.memoryaddress+$a00,x
        sta graphics.memoryaddress+$b00,x
        sta graphics.memoryaddress+$c00,x
        sta graphics.memoryaddress+$d00,x
        sta graphics.memoryaddress+$e00,x
        sta graphics.memoryaddress+$f00,x
        sta graphics.memoryaddress+$1000,x
        sta graphics.memoryaddress+$1100,x
        sta graphics.memoryaddress+$1200,x
        sta graphics.memoryaddress+$1300,x
        sta graphics.memoryaddress+$1400,x
        sta graphics.memoryaddress+$1500,x
        sta graphics.memoryaddress+$1600,x
        sta graphics.memoryaddress+$1700,x
        sta graphics.memoryaddress+$1800,x
        sta graphics.memoryaddress+$1900,x
        sta graphics.memoryaddress+$1a00,x
        sta graphics.memoryaddress+$1b00,x
        sta graphics.memoryaddress+$1c00,x
        sta graphics.memoryaddress+$1d00,x
        sta graphics.memoryaddress+$1e00,x
        sta graphics.memoryaddress+$1f00,x

        sta graphics.memoryaddress+$2000,x
        sta graphics.memoryaddress+$2100,x
        sta graphics.memoryaddress+$2200,x
        sta graphics.memoryaddress+$2300,x

        sta graphics.memoryaddress+$2400,x
        sta graphics.memoryaddress+$2500,x
        sta graphics.memoryaddress+$2600,x
        sta graphics.memoryaddress+$2700,x
        dex
        ;bne @loop
        beq @done
        jmp @loop
@done

        lda #color.black$
        sta graphics.multibgcoloraddress

        ldx #$00 
        lda #color.black$
@loop2
        ; Transfers video data 
        sta graphics.multivideoaddress,x 
        sta graphics.multivideoaddress+$100,x 
        sta graphics.multivideoaddress+$200,x 
        sta graphics.multivideoaddress+$2e8,x 
        ; Transfers color data 
        sta graphics.multicoloraddress,x 
        sta graphics.multicoloraddress+$100,x 
        sta graphics.multicoloraddress+$200,x 
        sta graphics.multicoloraddress+$2e8,x 
        inx 
        bne @loop2

        lda #<graphics.memoryaddress
        sta graphics.currentaddress
        lda #>graphics.memoryaddress
        sta graphics.currentaddress+1

        lda #<graphics.coloraddress
        sta graphics.currentcoloraddr
        lda #>graphics.coloraddress
        sta graphics.currentcoloraddr+1

        rts

graphics.tablecreated byte $00

;align $100 

graphics.createtable
    lda graphics.tablecreated
    beq @NeedToCreate
    rts
@NeedToCreate
    lda #$01
    sta graphics.tablecreated

    clc ; Need to clear the carry flag
    ldx #$00
    lda #$80
@Loop1
    sta graphics.BitMask,x
    ror
    bcc @Skip1
        ror
@Skip1
    tay
    txa
    and #%11111000
    sta graphics.X_Table,x
    tya
    inx
    bne @Loop1

    lda #<graphics.memoryaddress ; Can be replaced with a TXA if GFX_MEM is page aligned
@Loop2
    ldy #$07
@Loop3
    sta graphics.Y_Table_Lo,x
    pha
@SMC1
    lda #>graphics.memoryaddress
    sta graphics.Y_Table_Hi,x
    pla
    inx
    clc
    adc #$01
    dey
    bpl @Loop3
    inc @SMC1+1
    clc
    ;adc #$40
    adc #$38
    bcc @Skip2
        inc @SMC1+1
@Skip2
    cpx #8*25
    bne @Loop2
        rts

;align $100

graphics.drawchr.chraddress = $20 ; 2 bytes
graphics.drawchr.bmpaddress = $22 ; 2 bytes
graphics.drawchr.col_offset = $24 ; 2 bytes
graphics.drawchr.row_offset = $26 ; 2 bytes
graphics.drawchr.chr = $28 ; 1 byte
graphics.drawchr

        sta graphics.drawchr.chr
        lda graphics.isactive$
        cmp #$01
        beq @OkToDrawChr
        ;lda graphics.drawchr.chr
        rts
@OkToDrawChr

        ; Set the character color
        ; Address = console.currentaddress + $4000 (2nd bank)
        lda console.currentaddress
        sta math.add16.addend1$
        lda console.currentaddress+1
        sta math.add16.addend1$+1
        lda #$00
        sta math.add16.addend2$
        lda #$40
        sta math.add16.addend2$+1
        jsr math.add16$
        lda math.add16.sum$
        sta graphics.drawchr.chraddress
        lda math.add16.sum$+1
        sta graphics.drawchr.chraddress+1
        ldy #$00
        lda console.charactercolor
        cmp #$80 
        rol 
        cmp #$80 
        rol 
        cmp #$80 
        rol 
        cmp #$80 
        rol
        sta (graphics.drawchr.chraddress),y

TODO Create table to look up the charactermap address by console.writechr.char$        
        ; Get the memory address of the character
        ; Address = font.memoryaddress + (chr * 8)
        lda graphics.drawchr.chr
        sta math.multiply16.factor1$
        lda #$08
        sta math.multiply16.factor2$
        lda #$00
        sta math.multiply16.factor1$+1
        sta math.multiply16.factor2$+1
        jsr math.multiply16$

        lda math.multiply16.product$
        sta math.add16.addend2$
        lda math.multiply16.product$+1
        sta math.add16.addend2$+1
        lda #<font.memoryaddress
        sta math.add16.addend1$
        lda #>font.memoryaddress
        sta math.add16.addend1$+1
        jsr math.add16$

        lda math.add16.sum$
        sta graphics.drawchr.chraddress
        lda math.add16.sum$+1
        sta graphics.drawchr.chraddress+1

        ; Get the memory address of the screen
        ; Address = graphics.memoryaddress + (Col * 8) + (Row * 320)

        ; col_offset = currentcolumn * 8
        lda console.currentcolumn
        sta math.multiply16.factor1$
        lda #$08
        sta math.multiply16.factor2$
        lda #$00
        sta math.multiply16.factor1$+1
        sta math.multiply16.factor2$+1
        jsr math.multiply16$
        lda math.multiply16.product$
        sta graphics.drawchr.col_offset
        lda math.multiply16.product$+1
        sta graphics.drawchr.col_offset+1

        ; row_offset = currentrow * 320
        lda console.currentrow
        sta math.multiply16.factor1$
        lda #$00
        sta math.multiply16.factor1$+1
        lda #$40
        sta math.multiply16.factor2$
        lda #$01
        sta math.multiply16.factor2$+1
        jsr math.multiply16$
        lda math.multiply16.product$
        sta graphics.drawchr.row_offset
        lda math.multiply16.product$+1
        sta graphics.drawchr.row_offset+1
        
        ; sum = row_offset + col_offset
        lda math.multiply16.product$
        sta math.add16.addend2$
        lda math.multiply16.product$+1
        sta math.add16.addend2$+1
        lda graphics.drawchr.col_offset
        sta math.add16.addend1$
        lda graphics.drawchr.col_offset+1
        sta math.add16.addend1$+1
        jsr math.add16$

        ; bmpaddress = sum + graphics.memoryaddress
        lda math.add16.sum$
        sta math.add16.addend2$
        lda math.add16.sum$+1
        sta math.add16.addend2$+1
        lda #<graphics.memoryaddress
        sta math.add16.addend1$
        lda #>graphics.memoryaddress
        sta math.add16.addend1$+1
        jsr math.add16$

        lda math.add16.sum$
        sta graphics.drawchr.bmpaddress
        lda math.add16.sum$+1
        sta graphics.drawchr.bmpaddress+1

        ; Copy the character to the screen
        lda graphics.drawchr.chraddress
        sta memory.copy.source$
        lda graphics.drawchr.chraddress+1
        sta memory.copy.source$+1
        lda graphics.drawchr.bmpaddress
        sta memory.copy.destination$
        lda graphics.drawchr.bmpaddress+1
        sta memory.copy.destination$+1
        lda #$08
        sta memory.copy.length$
        jsr memory.copy$

        ;lda graphics.drawchr.chr

        rts

graphics.scrollup

        sta graphics.drawchr.chr
        lda graphics.isactive$
        cmp #$01
        beq @OkToScrollUp
        rts
@OkToScrollUp

        ; Copy the characters from the 2nd row and override the first row.
        ; Clear out the text on the last row.
        lda #<graphics.memoryaddress_2r
        sta memory.copy16.source$
        lda #>graphics.memoryaddress_2r
        sta memory.copy16.source$+1
        lda #<graphics.memoryaddress
        sta memory.copy16.destination$
        lda #>graphics.memoryaddress
        sta memory.copy16.destination$+1
        lda #$00
        sta memory.copy16.length$
        lda #$1e
        sta memory.copy16.length$+1
        jsr memory.copy16$

        ; Need to "scroll" up the character colors as well
        lda #<graphics.coloraddress+$28
        sta memory.copy16.source$
        lda #>graphics.coloraddress
        sta memory.copy16.source$+1
        lda #<graphics.coloraddress
        sta memory.copy16.destination$
        lda #>graphics.coloraddress
        sta memory.copy16.destination$+1
        lda #$c0
        sta memory.copy16.length$
        lda #$03
        sta memory.copy16.length$+1
        jsr memory.copy16$

        ; Clear the last line
        lda #<graphics.memoryaddress_lr
        sta memory.fill16.address$
        lda #>graphics.memoryaddress_lr
        sta memory.fill16.address$+1
        lda #$00
        sta memory.fill16.value$
        lda #$40
        sta memory.fill16.length$
        lda #$01
        sta memory.fill16.length$+1
        jsr memory.fill16$        
        jsr memory.fill16$

        rts

;graphics.scrollupchrs
;        ldx #$00
;@loop1 ; Do process 4 times (6*4 = 24)
;        ldy #$00
;@loop2 ; Move up 6 lines
;        lda ($fd),y
;        sta ($fb),y
;        iny
;        cpy #240 ; (40*6)
;        bne @loop2

;        inx
;        cpx #4
;        bne @incr
;        jmp @done

;@incr
;        ; Need to increase the value of the address that $fb and $fd are pointing to.
;        lda $fb
;        sta math.add16.addend1$
;        lda $fc
;        sta math.add16.addend1$+1

;        lda #240
;        sta math.add16.addend2$
;        lda #0
;        sta math.add16.addend2$+1

;        jsr math.add16$ ; ($fb+$fc) = ($fb+$fc) + $28

;        lda math.add16.sum$
;        sta $fb
;        lda math.add16.sum$+1
;        sta $fc

;        lda $fd
;        sta math.add16.addend1$
;        lda $fe
;        sta math.add16.addend1$+1

;        lda #240
;        sta math.add16.addend2$
;        lda #0
;        sta math.add16.addend2$+1

;        jsr math.add16$ ; ($fd+$fe) = ($fd+$fe) + $28

;        lda math.add16.sum$
;        sta $fd
;        lda math.add16.sum$+1
;        sta $fe

;        jmp @loop1
;@done

;        rts


;align $100

graphics.setpixel.x$ = $20 ; 2 bytes
graphics.setpixel.y$ = $22 ; 2 bytes
graphics.setpixel.color$ = $24 ; 1 byte
graphics.setpixel$
        ldx graphics.setpixel.x$
        ldy graphics.setpixel.y$
        lda graphics.setpixel.x$+1
;        cmp #$01
;        bne @Plot
;        sec

;@Plot
;        lda graphics.Y_Table_Hi,y
;        bcc @skip
;        adc #$00      ; Adds 1 (256 pixels) to HiByte
;@skip
;        sta $fc
        clc 
        lda graphics.Y_Table_Hi,y 
        adc graphics.setpixel.x$+1 
        sta $fc

        lda graphics.Y_Table_lo,y
        sta $fb
        ldy graphics.X_Table,x

        lda graphics.setpixel.color$
        cmp #$01
        beq @Set

        ;lda #$ff
        ;sec
        ;sbc graphics.BitMask,x
        lda graphics.BitMask,x
        eor #$ff
        and ($fb),y
        sta ($fb),y

        rts

@Set
        lda graphics.BitMask,x
        ora ($fb),y
        sta ($fb),y

        rts


graphics.drawfill.color$ = $24 ; 1 byte
graphics.drawfill.x1$ = $25 ; 2 bytes
graphics.drawfill.y1$ = $27 ; 2 bytes
graphics.drawfill.x2$ = $29 ; 2 bytes
graphics.drawfill.y2$ = $2b ; 2 bytes
graphics.drawfill.y = $2d ; 2 bytes
graphics.drawfill$
        ; Draw lines which fills a box

        ; Initilize y = y1
        lda graphics.drawfill.y1$
        sta graphics.drawfill.y
        lda graphics.drawfill.y1$+1
        sta graphics.drawfill.y+1

@DrawLine
        ; Draw line
        lda graphics.drawfill.x1$
        sta graphics.drawline.x1$
        lda graphics.drawfill.x1$+1
        sta graphics.drawline.x1$+1
        lda graphics.drawfill.y
        sta graphics.drawline.y1$
        lda graphics.drawfill.y+1
        sta graphics.drawline.y1$+1
        lda graphics.drawfill.x2$
        sta graphics.drawline.x2$
        lda graphics.drawfill.x2$+1
        sta graphics.drawline.x2$+1
        lda graphics.drawfill.y
        sta graphics.drawline.y2$
        lda graphics.drawfill.y+1
        sta graphics.drawline.y2$+1
        jsr graphics.drawline$

        lda graphics.drawfill.y
        sta math.cmp16.num1$
        lda graphics.drawfill.y+1
        sta math.cmp16.num1$+1
        lda graphics.drawfill.y2$
        sta math.cmp16.num2$
        lda graphics.drawfill.y2$+1
        sta math.cmp16.num2$+1
        jsr math.cmp16$
        bne @IncY ; If y <> y2 then @IncY
        rts
@IncY
        ; Increment y
        lda #<graphics.drawfill.y
        sta math.inc16.address$
        lda #>graphics.drawfill.y
        sta math.inc16.address$+1
        jsr math.inc16$ ; y = y + 1
        
        jmp @DrawLine
        ;rts

;align $100

graphics.drawline.x = $e0 ; 2 bytes
graphics.drawline.y = $e2 ; 2 bytes
graphics.drawline.color$ = $24 ; 1 byte
graphics.drawline.x1$ = $d0 ; 2 bytes
graphics.drawline.y1$ = $d2 ; 2 bytes
graphics.drawline.x2$ = $d4 ; 2 bytes
graphics.drawline.y2$ = $d6 ; 2 bytes
graphics.drawline.dx = $d8 ; 2 bytes
graphics.drawline.dy = $da ; 2 bytes
graphics.drawline.steep = $dc ; 1 bytes
graphics.drawline.x1_x2 = $e4 ; 2 bytes
graphics.drawline.y1_y2 = $e6 ; 2 bytes
graphics.drawline.derror2 = $e8 ; 2 bytes
graphics.drawline.error2 = $ea ; 2 bytes
graphics.drawline.y_offset = $ec ; 2 bytes
graphics.drawline.dx_2 = $ee ; 2 bytes
graphics.drawline$
; D:\test\Line1\Line1.vbp

;    steep = False
        lda #$00
        sta graphics.drawline.steep

;    If (Abs(x1 - x2) < Abs(y1 - y2)) Then
        lda graphics.drawline.x1$
        sta math.subtract16.menuend$
        lda graphics.drawline.x1$+1
        sta math.subtract16.menuend$+1
        lda graphics.drawline.x2$
        sta math.subtract16.subtrahend$
        lda graphics.drawline.x2$+1
        sta math.subtract16.subtrahend$+1
        jsr math.subtract16$ ; difference = x1 - x2

        lda math.subtract16.difference$
        sta math.abs16.integer$
        lda math.subtract16.difference$+1
        sta math.abs16.integer$+1
        jsr math.abs16$ ; x1_x2 = abs(difference)
        
        lda math.abs16.value$
        sta graphics.drawline.x1_x2
        lda math.abs16.value$+1
        sta graphics.drawline.x1_x2+1

        lda graphics.drawline.y1$
        sta math.subtract16.menuend$
        lda graphics.drawline.y1$+1
        sta math.subtract16.menuend$+1
        lda graphics.drawline.y2$
        sta math.subtract16.subtrahend$
        lda graphics.drawline.y2$+1
        sta math.subtract16.subtrahend$+1
        jsr math.subtract16$ ; difference = y1 - y2

        lda math.subtract16.difference$
        sta math.abs16.integer$
        lda math.subtract16.difference$+1
        sta math.abs16.integer$+1
        jsr math.abs16$ ; y1_y2 = abs(difference)
        
        lda math.abs16.value$
        sta graphics.drawline.y1_y2
        lda math.abs16.value$+1
        sta graphics.drawline.y1_y2+1

        lda graphics.drawline.x1_x2
        sta math.cmp16.num1$
        lda graphics.drawline.x1_x2+1
        sta math.cmp16.num1$+1
        lda graphics.drawline.y1_y2
        sta math.cmp16.num2$
        lda graphics.drawline.y1_y2+1
        sta math.cmp16.num2$+1
        jsr math.cmp16$
        bcc @SwapX1Y1_X2Y2 ; If x1_x2 < y1_y2 Then @SwapX1Y1_X2Y2
        jmp @SkipSwapX1Y1_X2Y2
@SwapX1Y1_X2Y2

;        Call Swap(x1, y1)        
        lda #<graphics.drawline.x1$
        sta memory.swap.address1$
        lda #>graphics.drawline.x1$
        sta memory.swap.address1$+1
        lda #<graphics.drawline.y1$
        sta memory.swap.address2$
        lda #>graphics.drawline.y1$
        sta memory.swap.address2$+1
        lda #$02
        sta memory.swap.length$
        jsr memory.swap$

;        Call Swap(x2, y2)
        lda #<graphics.drawline.x2$
        sta memory.swap.address1$
        lda #>graphics.drawline.x2$
        sta memory.swap.address1$+1
        lda #<graphics.drawline.y2$
        sta memory.swap.address2$
        lda #>graphics.drawline.y2$
        sta memory.swap.address2$+1
        lda #$02
        sta memory.swap.length$
        jsr memory.swap$

;        steep = True
        lda #$01
        sta graphics.drawline.steep

;    End If
@SkipSwapX1Y1_X2Y2

;    If (x1 > x2) Then
        lda graphics.drawline.x2$
        sta math.cmp16.num1$
        lda graphics.drawline.x2$+1
        sta math.cmp16.num1$+1
        lda graphics.drawline.x1$
        sta math.cmp16.num2$
        lda graphics.drawline.x1$+1
        sta math.cmp16.num2$+1
        jsr math.cmp16$ ; If x2 < x1 Then @SkipSwapX1X2_Y1Y2
        bcc @SwapX1X2_Y1Y2
        jmp @SkipSwapX1X2_Y1Y2

@SwapX1X2_Y1Y2
;        Call Swap(x1, x2)
        lda #<graphics.drawline.x1$
        sta memory.swap.address1$
        lda #>graphics.drawline.x1$
        sta memory.swap.address1$+1
        lda #<graphics.drawline.x2$
        sta memory.swap.address2$
        lda #>graphics.drawline.x2$
        sta memory.swap.address2$+1
        lda #$02
        sta memory.swap.length$
        jsr memory.swap$

;        Call Swap(y1, y2)
        lda #<graphics.drawline.y1$
        sta memory.swap.address1$
        lda #>graphics.drawline.y1$
        sta memory.swap.address1$+1
        lda #<graphics.drawline.y2$
        sta memory.swap.address2$
        lda #>graphics.drawline.y2$
        sta memory.swap.address2$+1
        lda #$02
        sta memory.swap.length$
        jsr memory.swap$

;    End If
@SkipSwapX1X2_Y1Y2

;    dx = x2 - x1
        lda graphics.drawline.x2$
        sta math.subtract16.menuend$
        lda graphics.drawline.x2$+1
        sta math.subtract16.menuend$+1
        lda graphics.drawline.x1$
        sta math.subtract16.subtrahend$
        lda graphics.drawline.x1$+1
        sta math.subtract16.subtrahend$+1
        jsr math.subtract16$ ; dx = x2 - x1
        lda math.subtract16.difference$
        sta graphics.drawline.dx
        lda math.subtract16.difference$+1
        sta graphics.drawline.dx+1

;    dy = y2 - y1
        lda graphics.drawline.y2$
        sta math.subtract16.menuend$
        lda graphics.drawline.y2$+1
        sta math.subtract16.menuend$+1
        lda graphics.drawline.y1$
        sta math.subtract16.subtrahend$
        lda graphics.drawline.y1$+1
        sta math.subtract16.subtrahend$+1
        jsr math.subtract16$ ; dy = y2 - y1
        lda math.subtract16.difference$
        sta graphics.drawline.dy
        lda math.subtract16.difference$+1
        sta graphics.drawline.dy+1

;    derror2 = Abs(dy) * 2
        lda graphics.drawline.dy
        sta math.abs16.integer$
        lda graphics.drawline.dy+1
        sta math.abs16.integer$+1
        jsr math.abs16$ ; value = abs(dy)

        lda math.abs16.value$
        sta math.multiply16.factor1$
        lda math.abs16.value$+1
        sta math.multiply16.factor1$+1
        lda #$02
        sta math.multiply16.factor2$
        lda #$00
        sta math.multiply16.factor2$+1
        jsr math.multiply16$ ; derror2 = value * 2
        
        lda math.multiply16.product$
        sta graphics.drawline.derror2
        lda math.multiply16.product$+1
        sta graphics.drawline.derror2+1

;    error2 = 0
        lda #$00
        sta graphics.drawline.error2
        sta graphics.drawline.error2+1

;    Y = y1
        lda graphics.drawline.y1$
        sta graphics.drawline.y
        lda graphics.drawline.y1$+1
        sta graphics.drawline.y+1

        ; y_offset = IIf(y2 > y1, 1, -1)
        lda graphics.drawline.y1$
        sta math.cmp16.num1$
        lda graphics.drawline.y1$+1
        sta math.cmp16.num1$+1
        lda graphics.drawline.y2$
        sta math.cmp16.num2$
        lda graphics.drawline.y2$+1
        sta math.cmp16.num2$+1
        jsr math.cmp16$ ; If y1 < y2 Then @SetY_Offset1
        bcc @SetY_Offset1
        lda #$ff ; -1
        sta graphics.drawline.y_offset
        lda #$ff ; -1
        sta graphics.drawline.y_offset+1
        jmp @SkipSetY_Offset
@SetY_Offset1
        lda #$01
        sta graphics.drawline.y_offset
        lda #$00
        sta graphics.drawline.y_offset+1
@SkipSetY_Offset
    
        ; dx_2 = (dx * 2)
        lda graphics.drawline.dx
        sta math.multiply16.factor1$
        lda graphics.drawline.dx+1
        sta math.multiply16.factor1$+1
        lda #$02
        sta math.multiply16.factor2$
        lda #$00
        sta math.multiply16.factor2$+1
        jsr math.multiply16$
        lda math.multiply16.product$
        sta graphics.drawline.dx_2
        lda math.multiply16.product$+1
        sta graphics.drawline.dx_2+1

;    For X = x1 To x2
        lda graphics.drawline.x1$
        sta graphics.drawline.x
        lda graphics.drawline.x1$+1
        sta graphics.drawline.x+1
        
@Loop
        lda graphics.drawline.x2$
        sta math.cmp16.num1$
        lda graphics.drawline.x2$+1
        sta math.cmp16.num1$+1
        lda graphics.drawline.x
        sta math.cmp16.num2$
        lda graphics.drawline.x+1
        sta math.cmp16.num2$+1
        jsr math.cmp16$ ; If x2 >= X Then @ProcessLoop
        bcs @ProcessLoop
        jmp @SkipProcessLoop
@ProcessLoop

;        If (steep = True) Then
        lda graphics.drawline.steep
        cmp #$01
        beq @DrawPixelYX ; If steep = $01 Then @DrawPixelYX
        jmp @DrawPixelXY
@DrawPixelYX
;            PictureBox.PSet (Y, X), Color
        lda graphics.drawline.y
        sta graphics.setpixel.x$
        lda graphics.drawline.y+1
        sta graphics.setpixel.x$+1
        lda graphics.drawline.x
        sta graphics.setpixel.y$
        lda graphics.drawline.x+1
        sta graphics.setpixel.y$+1
        lda graphics.drawline.color$
        sta graphics.setpixel.color$
        jsr graphics.setpixel$

        jmp @SkipDrawPixel
;        Else
@DrawPixelXY
;            PictureBox.PSet (X, Y), Color
        lda graphics.drawline.x
        sta graphics.setpixel.x$
        lda graphics.drawline.x+1
        sta graphics.setpixel.x$+1
        lda graphics.drawline.y
        sta graphics.setpixel.y$
        lda graphics.drawline.y+1
        sta graphics.setpixel.y$+1
        lda graphics.drawline.color$
        sta graphics.setpixel.color$
        jsr graphics.setpixel$

;        End If
@SkipDrawPixel

;        error2 = error2 + derror2
        lda graphics.drawline.error2
        sta math.add16.addend1$
        lda graphics.drawline.error2+1
        sta math.add16.addend1$+1
        lda graphics.drawline.derror2
        sta math.add16.addend2$
        lda graphics.drawline.derror2+1
        sta math.add16.addend2$+1
        jsr math.add16$
        lda math.add16.sum$
        sta graphics.drawline.error2
        lda math.add16.sum$+1
        sta graphics.drawline.error2+1
        
;;        If (error2 > dx) Then
;        lda graphics.drawline.dx
;        sta math.cmp16.num1$
;        lda graphics.drawline.dx+1
;        sta math.cmp16.num1$+1
;        lda graphics.drawline.error2
;        sta math.cmp16.num2$
;        lda graphics.drawline.error2+1
;        sta math.cmp16.num2$+1
;        jsr math.cmp16$ ; If dx < error2 Then @ProcessYError2
;        bcc @ProcessYError2

;        If (error2 > dx) Then [signed integer check!]

        lda graphics.drawline.error2
        sta math.subtract16.menuend$
        lda graphics.drawline.error2+1
        sta math.subtract16.menuend$+1
        lda graphics.drawline.dx
        sta math.subtract16.subtrahend$
        lda graphics.drawline.dx+1
        sta math.subtract16.subtrahend$+1
        jsr math.subtract16$
        lda math.subtract16.difference$+1
        cmp #$80
        bcc @ProcessYError2_1
        jmp @SkipProcessYError2
@ProcessYError2_1
        lda math.subtract16.difference$+1
        cmp #$00
        bne @ProcessYError2
        lda math.subtract16.difference$
        cmp #$00
        bne @ProcessYError2
        ;beq @SkipProcessYError2_1
        ;bpl @ProcessYError2
        ;bmi @ProcessYError2
;@SkipProcessYError2_1
        jmp @SkipProcessYError2
@ProcessYError2

;        Y = Y + IIf(y2 > y1, 1, -1)
        lda graphics.drawline.y
        sta math.add16.addend1$
        lda graphics.drawline.y+1
        sta math.add16.addend1$+1
        lda graphics.drawline.y_offset
        sta math.add16.addend2$
        lda graphics.drawline.y_offset+1
        sta math.add16.addend2$+1
        jsr math.add16$ ; Y = Y + y_offset
        lda math.add16.sum$
        sta graphics.drawline.y
        lda math.add16.sum$+1
        sta graphics.drawline.y+1

;        lda graphics.drawline.y_offset
;        cmp #$01
;        beq @IncY
;        jmp @DecY
;@IncY
;        lda #<graphics.drawline.y
;        sta math.inc16.address$
;        lda #>graphics.drawline.y
;        sta math.inc16.address$+1
;        jsr math.inc16$
;        jmp @SkpIncDecY
;@DecY
;        lda #<graphics.drawline.y
;        sta math.dec16.address$
;        lda #>graphics.drawline.y
;        sta math.dec16.address$+1
;        jsr math.dec16$
;        jmp @SkpIncDecY
;@SkpIncDecY

;            error2 = error2 - (dx * 2)
        lda graphics.drawline.error2
        sta math.subtract16.menuend$
        lda graphics.drawline.error2+1
        sta math.subtract16.menuend$+1
        lda graphics.drawline.dx_2
        sta math.subtract16.subtrahend$
        lda graphics.drawline.dx_2+1
        sta math.subtract16.subtrahend$+1
        jsr math.subtract16$ ; error2 = error2 - dx_2
        lda math.subtract16.difference$
        sta graphics.drawline.error2
        lda math.subtract16.difference$+1
        sta graphics.drawline.error2+1

;        End If
@SkipProcessYError2

;    Next X
        lda #<graphics.drawline.x
        sta math.inc16.address$
        lda #>graphics.drawline.x
        sta math.inc16.address$+1
        jsr math.inc16$ ; X = X + 1

        jmp @Loop

@SkipProcessLoop

        rts

graphics.drawbox.color$ = $24 ; 1 byte
graphics.drawbox.x1$ = $25 ; 2 bytes
graphics.drawbox.y1$ = $27 ; 2 bytes
graphics.drawbox.x2$ = $29 ; 2 bytes
graphics.drawbox.y2$ = $2b ; 2 bytes
graphics.drawbox$
        ; Draw 4 lines

        ; Top
        lda graphics.drawbox.x1$
        sta graphics.drawline.x1$
        lda graphics.drawbox.x1$+1
        sta graphics.drawline.x1$+1
        lda graphics.drawbox.y1$
        sta graphics.drawline.y1$
        lda graphics.drawbox.y1$+1
        sta graphics.drawline.y1$+1
        lda graphics.drawbox.x2$
        sta graphics.drawline.x2$
        lda graphics.drawbox.x2$+1
        sta graphics.drawline.x2$+1
        lda graphics.drawbox.y1$
        sta graphics.drawline.y2$
        lda graphics.drawbox.y1$+1
        sta graphics.drawline.y2$+1
        jsr graphics.drawline$

        ; Right
        lda graphics.drawbox.x2$
        sta graphics.drawline.x1$
        lda graphics.drawbox.x2$+1
        sta graphics.drawline.x1$+1
        lda graphics.drawbox.y1$
        sta graphics.drawline.y1$
        lda graphics.drawbox.y1$+1
        sta graphics.drawline.y1$+1
        lda graphics.drawbox.x2$
        sta graphics.drawline.x2$
        lda graphics.drawbox.x2$+1
        sta graphics.drawline.x2$+1
        lda graphics.drawbox.y2$
        sta graphics.drawline.y2$
        lda graphics.drawbox.y2$+1
        sta graphics.drawline.y2$+1
        jsr graphics.drawline$

        ; Bottom
        lda graphics.drawbox.x2$
        sta graphics.drawline.x1$
        lda graphics.drawbox.x2$+1
        sta graphics.drawline.x1$+1
        lda graphics.drawbox.y2$
        sta graphics.drawline.y1$
        lda graphics.drawbox.y2$+1
        sta graphics.drawline.y1$+1
        lda graphics.drawbox.x1$
        sta graphics.drawline.x2$
        lda graphics.drawbox.x1$+1
        sta graphics.drawline.x2$+1
        lda graphics.drawbox.y2$
        sta graphics.drawline.y2$
        lda graphics.drawbox.y2$+1
        sta graphics.drawline.y2$+1
        jsr graphics.drawline$

        ; Left
        lda graphics.drawbox.x1$
        sta graphics.drawline.x1$
        lda graphics.drawbox.x1$+1
        sta graphics.drawline.x1$+1
        lda graphics.drawbox.y2$
        sta graphics.drawline.y1$
        lda graphics.drawbox.y2$+1
        sta graphics.drawline.y1$+1
        lda graphics.drawbox.x1$
        sta graphics.drawline.x2$
        lda graphics.drawbox.x1$+1
        sta graphics.drawline.x2$+1
        lda graphics.drawbox.y1$
        sta graphics.drawline.y2$
        lda graphics.drawbox.y1$+1
        sta graphics.drawline.y2$+1
        jsr graphics.drawline$

        rts

graphics.drawcircle.color$ = $24 ; 1 byte
graphics.drawcircle.radius$ = $25 ; 1 byte
graphics.drawcircle.xcenter$ = $26 ; 2 bytes
graphics.drawcircle.ycenter$ = $28 ; 2 bytes
graphics.drawcircle.x = $2a ; 2 bytes
graphics.drawcircle.y = $2c ; 2 bytes
graphics.drawcircle.d = $2e ; 2 bytes
graphics.drawcircle$
; See: https://www.geeksforgeeks.org/bresenhams-circle-drawing-algorithm/

        ; x = 0
        ; y = r
        lda #$00
        sta graphics.drawcircle.x
        sta graphics.drawcircle.x+1
        sta graphics.drawcircle.y+1
        lda graphics.drawcircle.radius$
        sta graphics.drawcircle.y

;        ; d = 3 - (2 * r)
;        lda graphics.drawcircle.radius$
;        sta math.multiply16.factor1$
;        lda #$02
;        sta math.multiply16.factor2$
;        lda #$00
;        sta math.multiply16.factor1$+1
;        sta math.multiply16.factor2$+1
;        jsr math.multiply16$ ; product = 2 * radius
;        lda math.multiply16.product$
;        sta math.subtract16.subtrahend$
;        lda math.multiply16.product$+1
;        sta math.subtract16.subtrahend$+1
;        lda #$03
;        sta math.subtract16.menuend$
;        lda #$00
;        sta math.subtract16.menuend$+1
;        jsr math.subtract16$ ; d = 3 - product
;        lda math.subtract16.difference$
;        sta graphics.drawcircle.d
;        lda math.subtract16.difference$+1
;        sta graphics.drawcircle.d+1

        ; d = 0 - (2 * r)
        lda graphics.drawcircle.radius$
        sta math.multiply16.factor1$
        lda #$02
        sta math.multiply16.factor2$
        lda #$00
        sta math.multiply16.factor1$+1
        sta math.multiply16.factor2$+1
        jsr math.multiply16$ ; product = 2 * radius
        lda math.multiply16.product$
        sta math.subtract16.subtrahend$
        lda math.multiply16.product$+1
        sta math.subtract16.subtrahend$+1
        lda #$00
        sta math.subtract16.menuend$
        sta math.subtract16.menuend$+1
        jsr math.subtract16$ ; d = 0 - product
        lda math.subtract16.difference$
        sta graphics.drawcircle.d
        lda math.subtract16.difference$+1
        sta graphics.drawcircle.d+1

        ; Call DrawCircle(xc, yc, x, y, Color)
        jsr graphics.plotcircle

        ; While (y >= x)
@check_y_x
        lda graphics.drawcircle.y
        sta math.cmp16.num1$
        lda graphics.drawcircle.y+1
        sta math.cmp16.num1$+1
        lda graphics.drawcircle.x
        sta math.cmp16.num2$
        lda graphics.drawcircle.x+1
        sta math.cmp16.num2$+1
        jsr math.cmp16$
        bcs @continue ; If y >= x Then @continue
        rts
@continue

        ; for each pixel we will draw all eight pixels
        ; x = x + 1
        lda #<graphics.drawcircle.x
        sta math.inc16.address$
        lda #>graphics.drawcircle.x
        sta math.inc16.address$+1
        jsr math.inc16$

        ; check for decision parameter and correspondingly update d, x, y
        ; If d > 0 Then
        lda graphics.drawcircle.d+1
        cmp #$80
        bcc @d_not_neg ; If d(hi) < $80 Then @d_not_neg
        jmp @d_neg
@d_not_neg
        cmp #$00
        bne @d_pos ; If d(hi) != $00 Then @d_pos
        lda graphics.drawcircle.d
        cmp #$00
        bne @d_pos ; If d(lo) != $00 Then @d_pos
        jmp @d_neg
@d_pos

        ; y = y - 1
        lda #<graphics.drawcircle.y
        sta math.dec16.address$
        lda #>graphics.drawcircle.y
        sta math.dec16.address$+1
        jsr math.dec16$

        ; d = d + 10 + (4 * (x - y))
        lda graphics.drawcircle.x
        sta math.subtract16.menuend$
        lda graphics.drawcircle.x+1
        sta math.subtract16.menuend$+1
        lda graphics.drawcircle.y
        sta math.subtract16.subtrahend$
        lda graphics.drawcircle.y+1
        sta math.subtract16.subtrahend$+1
        jsr math.subtract16$ ; difference = x - y
        
        lda math.subtract16.difference$
        sta math.multiply16.factor1$
        lda math.subtract16.difference$+1
        sta math.multiply16.factor1$+1
        lda #$04
        sta math.multiply16.factor2$
        lda #$00
        sta math.multiply16.factor2$+1
        jsr math.multiply16$ ; product = 4 * difference

        lda math.multiply16.product$
        sta math.add16.addend1$
        lda math.multiply16.product$+1
        sta math.add16.addend1$+1
        lda #$0a
        sta math.add16.addend2$
        lda #$00
        sta math.add16.addend2$+1
        jsr math.add16$ ; sum = 10 + product

        lda math.add16.sum$
        sta math.add16.addend1$
        lda math.add16.sum$+1
        sta math.add16.addend1$+1
        lda graphics.drawcircle.d
        sta math.add16.addend2$
        lda graphics.drawcircle.d+1
        sta math.add16.addend2$+1
        jsr math.add16$ ; d = d + sum

        lda math.add16.sum$
        sta graphics.drawcircle.d
        lda math.add16.sum$+1
        sta graphics.drawcircle.d+1

        jmp @skip_check_d

@d_neg
        ; d = d + 6 + (4 * x)
        lda graphics.drawcircle.x
        sta math.multiply16.factor1$
        lda graphics.drawcircle.x+1
        sta math.multiply16.factor1$+1
        lda #$04
        sta math.multiply16.factor2$
        lda #$00
        sta math.multiply16.factor2$+1
        jsr math.multiply16$ ; product = 4 * x

        lda math.multiply16.product$
        sta math.add16.addend1$
        lda math.multiply16.product$+1
        sta math.add16.addend1$+1
        lda #$06
        sta math.add16.addend2$
        lda #$00
        sta math.add16.addend2$+1
        jsr math.add16$ ; sum = 6 + product

        lda math.add16.sum$
        sta math.add16.addend1$
        lda math.add16.sum$+1
        sta math.add16.addend1$+1
        lda graphics.drawcircle.d
        sta math.add16.addend2$
        lda graphics.drawcircle.d+1
        sta math.add16.addend2$+1
        jsr math.add16$ ; d = d + sum

        lda math.add16.sum$
        sta graphics.drawcircle.d
        lda math.add16.sum$+1
        sta graphics.drawcircle.d+1
@skip_check_d

        jsr graphics.plotcircle

        jmp @check_y_x

graphics.plotcircle
        ; Function to put pixels at subsequence points

        ; PSet (xc + x, yc + y), Color
        lda graphics.drawcircle.xcenter$
        sta math.add16.addend1$
        lda graphics.drawcircle.xcenter$+1
        sta math.add16.addend1$+1
        lda graphics.drawcircle.x
        sta math.add16.addend2$
        lda graphics.drawcircle.x+1
        sta math.add16.addend2$+1
        jsr math.add16$ ; (xc + x)
        lda math.add16.sum$
        sta graphics.setpixel.x$
        lda math.add16.sum$+1
        sta graphics.setpixel.x$+1

        lda graphics.drawcircle.ycenter$
        sta math.add16.addend1$
        lda graphics.drawcircle.ycenter$+1
        sta math.add16.addend1$+1
        lda graphics.drawcircle.y
        sta math.add16.addend2$
        lda graphics.drawcircle.y+1
        sta math.add16.addend2$+1
        jsr math.add16$ ; (yc + y)
        lda math.add16.sum$
        sta graphics.setpixel.y$
        lda math.add16.sum$+1
        sta graphics.setpixel.y$+1

        jsr graphics.setpixel$

        ; PSet (xc - x, yc + y), Color
        lda graphics.drawcircle.xcenter$
        sta math.subtract16.menuend$
        lda graphics.drawcircle.xcenter$+1
        sta math.subtract16.menuend$+1
        lda graphics.drawcircle.x
        sta math.subtract16.subtrahend$
        lda graphics.drawcircle.x+1
        sta math.subtract16.subtrahend$+1
        jsr math.subtract16$ ; (xc - x)
        lda math.subtract16.difference$
        sta graphics.setpixel.x$
        lda math.subtract16.difference$+1
        sta graphics.setpixel.x$+1

        lda graphics.drawcircle.ycenter$
        sta math.add16.addend1$
        lda graphics.drawcircle.ycenter$+1
        sta math.add16.addend1$+1
        lda graphics.drawcircle.y
        sta math.add16.addend2$
        lda graphics.drawcircle.y+1
        sta math.add16.addend2$+1
        jsr math.add16$ ; (yc + y)
        lda math.add16.sum$
        sta graphics.setpixel.y$
        lda math.add16.sum$+1
        sta graphics.setpixel.y$+1

        jsr graphics.setpixel$

        ; PSet (xc + x, yc - y), Color
        lda graphics.drawcircle.xcenter$
        sta math.add16.addend1$
        lda graphics.drawcircle.xcenter$+1
        sta math.add16.addend1$+1
        lda graphics.drawcircle.x
        sta math.add16.addend2$
        lda graphics.drawcircle.x+1
        sta math.add16.addend2$+1
        jsr math.add16$ ; (xc + x)
        lda math.add16.sum$
        sta graphics.setpixel.x$
        lda math.add16.sum$+1
        sta graphics.setpixel.x$+1

        lda graphics.drawcircle.ycenter$
        sta math.subtract16.menuend$
        lda graphics.drawcircle.ycenter$+1
        sta math.subtract16.menuend$+1
        lda graphics.drawcircle.y
        sta math.subtract16.subtrahend$
        lda graphics.drawcircle.y+1
        sta math.subtract16.subtrahend$+1
        jsr math.subtract16$ ; (yc - y)
        lda math.subtract16.difference$
        sta graphics.setpixel.y$
        lda math.subtract16.difference$+1
        sta graphics.setpixel.y$+1

        jsr graphics.setpixel$

        ; PSet (xc - x, yc - y), Color
        lda graphics.drawcircle.xcenter$
        sta math.subtract16.menuend$
        lda graphics.drawcircle.xcenter$+1
        sta math.subtract16.menuend$+1
        lda graphics.drawcircle.x
        sta math.subtract16.subtrahend$
        lda graphics.drawcircle.x+1
        sta math.subtract16.subtrahend$+1
        jsr math.subtract16$ ; (xc - x)
        lda math.subtract16.difference$
        sta graphics.setpixel.x$
        lda math.subtract16.difference$+1
        sta graphics.setpixel.x$+1

        lda graphics.drawcircle.ycenter$
        sta math.subtract16.menuend$
        lda graphics.drawcircle.ycenter$+1
        sta math.subtract16.menuend$+1
        lda graphics.drawcircle.y
        sta math.subtract16.subtrahend$
        lda graphics.drawcircle.y+1
        sta math.subtract16.subtrahend$+1
        jsr math.subtract16$ ; (yc - y)
        lda math.subtract16.difference$
        sta graphics.setpixel.y$
        lda math.subtract16.difference$+1
        sta graphics.setpixel.y$+1

        jsr graphics.setpixel$

        ; PSet (xc + y, yc + x), Color
        lda graphics.drawcircle.xcenter$
        sta math.add16.addend1$
        lda graphics.drawcircle.xcenter$+1
        sta math.add16.addend1$+1
        lda graphics.drawcircle.y
        sta math.add16.addend2$
        lda graphics.drawcircle.y+1
        sta math.add16.addend2$+1
        jsr math.add16$ ; (xc + y)
        lda math.add16.sum$
        sta graphics.setpixel.x$
        lda math.add16.sum$+1
        sta graphics.setpixel.x$+1

        lda graphics.drawcircle.ycenter$
        sta math.add16.addend1$
        lda graphics.drawcircle.ycenter$+1
        sta math.add16.addend1$+1
        lda graphics.drawcircle.x
        sta math.add16.addend2$
        lda graphics.drawcircle.x+1
        sta math.add16.addend2$+1
        jsr math.add16$ ; (yc + x)
        lda math.add16.sum$
        sta graphics.setpixel.y$
        lda math.add16.sum$+1
        sta graphics.setpixel.y$+1

        jsr graphics.setpixel$

        ; PSet (xc - y, yc + x), Color
        lda graphics.drawcircle.xcenter$
        sta math.subtract16.menuend$
        lda graphics.drawcircle.xcenter$+1
        sta math.subtract16.menuend$+1
        lda graphics.drawcircle.y
        sta math.subtract16.subtrahend$
        lda graphics.drawcircle.y+1
        sta math.subtract16.subtrahend$+1
        jsr math.subtract16$ ; (xc - y)
        lda math.subtract16.difference$
        sta graphics.setpixel.x$
        lda math.subtract16.difference$+1
        sta graphics.setpixel.x$+1

        lda graphics.drawcircle.ycenter$
        sta math.add16.addend1$
        lda graphics.drawcircle.ycenter$+1
        sta math.add16.addend1$+1
        lda graphics.drawcircle.x
        sta math.add16.addend2$
        lda graphics.drawcircle.x+1
        sta math.add16.addend2$+1
        jsr math.add16$ ; (yc + x)
        lda math.add16.sum$
        sta graphics.setpixel.y$
        lda math.add16.sum$+1
        sta graphics.setpixel.y$+1

        jsr graphics.setpixel$

        ; PSet (xc + y, yc - x), Color
        lda graphics.drawcircle.xcenter$
        sta math.add16.addend1$
        lda graphics.drawcircle.xcenter$+1
        sta math.add16.addend1$+1
        lda graphics.drawcircle.y
        sta math.add16.addend2$
        lda graphics.drawcircle.y+1
        sta math.add16.addend2$+1
        jsr math.add16$ ; (xc + y)
        lda math.add16.sum$
        sta graphics.setpixel.x$
        lda math.add16.sum$+1
        sta graphics.setpixel.x$+1

        lda graphics.drawcircle.ycenter$
        sta math.subtract16.menuend$
        lda graphics.drawcircle.ycenter$+1
        sta math.subtract16.menuend$+1
        lda graphics.drawcircle.x
        sta math.subtract16.subtrahend$
        lda graphics.drawcircle.x+1
        sta math.subtract16.subtrahend$+1
        jsr math.subtract16$ ; (yc - x)
        lda math.subtract16.difference$
        sta graphics.setpixel.y$
        lda math.subtract16.difference$+1
        sta graphics.setpixel.y$+1

        jsr graphics.setpixel$

        ; PSet (xc - y, yc - x), Color
        lda graphics.drawcircle.xcenter$
        sta math.subtract16.menuend$
        lda graphics.drawcircle.xcenter$+1
        sta math.subtract16.menuend$+1
        lda graphics.drawcircle.y
        sta math.subtract16.subtrahend$
        lda graphics.drawcircle.y+1
        sta math.subtract16.subtrahend$+1
        jsr math.subtract16$ ; (xc - y)
        lda math.subtract16.difference$
        sta graphics.setpixel.x$
        lda math.subtract16.difference$+1
        sta graphics.setpixel.x$+1

        lda graphics.drawcircle.ycenter$
        sta math.subtract16.menuend$
        lda graphics.drawcircle.ycenter$+1
        sta math.subtract16.menuend$+1
        lda graphics.drawcircle.x
        sta math.subtract16.subtrahend$
        lda graphics.drawcircle.x+1
        sta math.subtract16.subtrahend$+1
        jsr math.subtract16$ ; (yc - x)
        lda math.subtract16.difference$
        sta graphics.setpixel.y$
        lda math.subtract16.difference$+1
        sta graphics.setpixel.y$+1

        jsr graphics.setpixel$


        rts  

; Note: Sprites take atmost 512 bytes of memory.

graphics.sprite1$ = #1
graphics.sprite2$ = #2
graphics.sprite3$ = #3
graphics.sprite4$ = #4
graphics.sprite5$ = #5
graphics.sprite6$ = #6
graphics.sprite7$ = #7
graphics.sprite8$ = #8

graphics.sprite1address$ = $4200
graphics.sprite2address$ = $4240
graphics.sprite3address$ = $4280
graphics.sprite4address$ = $42c0
graphics.sprite5address$ = $4300
graphics.sprite6address$ = $4340
graphics.sprite7address$ = $4380
graphics.sprite8address$ = $43c0

graphics.spritemulticolor1address$ = $d025
graphics.spritemulticolor2address$ = $d026

graphics.getspriteormask.number = $73
graphics.getspriteormask
        ; number = 2^(number - 1)
        lda graphics.getspriteormask.number
        sec
        sbc #$01
        sta math.exponent8.power$
        lda #$02
        sta math.exponent8.base$
        jsr math.exponent8$
        lda math.exponent8.value$
        sta graphics.getspriteormask.number
        rts

graphics.getspriteandmask.number = $73
graphics.getspriteandmask
        ; number = 255 - number (2's comp.)
        sec
        ;sbc #$ff
        lda #$ff
        sbc graphics.getspriteandmask.number
        sta graphics.getspriteandmask.number
        rts

graphics.showsprite.number$ = $73 ; 1 byte
graphics.showsprite$
        jsr graphics.getspriteormask

        ; Enable the specific sprite
        lda $d015
        ora graphics.showsprite.number$
        sta $d015

        rts

graphics.hidesprite.number$ = $73 ; 1 byte
graphics.hidesprite$
        jsr graphics.getspriteormask
        jsr graphics.getspriteandmask

        ; Enable the specific sprite
        lda $d015
        and graphics.hidesprite.number$
        sta $d015

        rts

graphics.setspritemulticolor.number$ = $73 ; 1 byte
graphics.setspritemulticolor$
        jsr graphics.getspriteormask

        ; Enable the specific sprite
        lda $d01c
        ora graphics.setspritemulticolor.number$
        sta $d01c

        rts

graphics.setspritehires.number$ = $73 ; 1 byte
graphics.setspritehires$
        jsr graphics.getspriteormask
        jsr graphics.getspriteandmask

        ; Enable the specific sprite
        lda $d01c
        and graphics.setspritehires.number$
        sta $d01c

        rts

graphics.stretchspritehorizontally.number$ = $73 ; 1 byte
graphics.stretchspritehorizontally$
        jsr graphics.getspriteormask

        ; Enable the specific sprite
        lda $d01d
        ora graphics.stretchspritehorizontally.number$
        sta $d01d

        rts

graphics.unstretchspritehorizontally.number$ = $73 ; 1 byte
graphics.unstretchspritehorizontally$
        jsr graphics.getspriteormask
        jsr graphics.getspriteandmask

        ; Enable the specific sprite
        lda $d01d
        and graphics.unstretchspritehorizontally.number$
        sta $d01d

        rts

graphics.stretchspritevertically.number$ = $73 ; 1 byte
graphics.stretchspritevertically$
        jsr graphics.getspriteormask

        ; Enable the specific sprite
        lda $d017
        ora graphics.stretchspritevertically.number$
        sta $d017

        rts

graphics.unstretchspritevertically.number$ = $73 ; 1 byte
graphics.unstretchspritevertically$
        jsr graphics.getspriteormask
        jsr graphics.getspriteandmask

        ; Enable the specific sprite
        lda $d017
        and graphics.unstretchspritevertically.number$
        sta $d017

        rts

graphics.setspritecolor.number$ = $73 ; 1 byte
graphics.setspritecolor.color$ = $74 ; 1 byte
graphics.setspritecolor.address = $75 ; 2 bytes
graphics.setspritecolor$

        ; The sprite colors are located at $d027-$d02e
        lda #$27
        sta graphics.setspritecolor.address
        lda #$d0
        sta graphics.setspritecolor.address+1

        ; Set the color at $d027+(number-1)
        ldy graphics.setspritecolor.number$
        dey
        lda graphics.setspritecolor.color$
        sta (graphics.setspritecolor.address),y

        rts

graphics.getspritecolor.number$ = $73 ; 1 byte
graphics.getspritecolor.color$ = $74 ; 1 byte
graphics.getspritecolor.address = $75 ; 2 bytes
graphics.getspritecolor$

        ; The sprite colors are located at $d027-$d02e
        lda #$27
        sta graphics.getspritecolor.address
        lda #$d0
        sta graphics.getspritecolor.address+1

        ; Get the color at $d027+(number-1)
        ldy graphics.getspritecolor.number$
        dey
        lda (graphics.getspritecolor.address),y
        and #%00001111
        sta graphics.getspritecolor.color$

        rts

graphics.setspritelocation.number$ = $73 ; 1 byte
graphics.setspritelocation.x$ = $74 ; 2 bytes
graphics.setspritelocation.y$ = $76 ; 2 bytes
graphics.setspritelocation.address = $78 ; 2 bytes
graphics.setspritelocation$

        ; The sprite locations are located at $d000-$d00f
        lda #$00
        sta graphics.setspritelocation.address
        lda #$d0
        sta graphics.setspritelocation.address+1

        ; number = (number-1)*2
        ldy graphics.setspritelocation.number$
        dey
        tya
        asl ; A=A*2
        tay

        lda graphics.setspritelocation.x$ ; We only care about the lo byte
        sta (graphics.setspritelocation.address),y

        iny
        lda graphics.setspritelocation.y$ ; We only care about the lo byte
        sta (graphics.setspritelocation.address),y

        ; Determine if we need to set/clear the 9th bit for X's hi byte
        lda graphics.setspritelocation.x$+1
        beq @ClearXHi
@SetXHi
        jsr graphics.getspriteormask
        lda $d010
        ora graphics.setspritelocation.number$
        sta $d010
        jmp @Done
@ClearXHi
        jsr graphics.getspriteormask
        jsr graphics.getspriteandmask
        lda $d010
        and graphics.setspritelocation.number$
        sta $d010
@Done
        rts

graphics.getspritelocation.number$ = $73 ; 1 byte
graphics.getspritelocation.x$ = $74 ; 2 bytes
graphics.getspritelocation.y$ = $76 ; 2 bytes
graphics.getspritelocation.address = $78 ; 2 bytes
graphics.getspritelocation$

        ; The sprite locations are located at $d000-$d00f
        lda #$00
        sta graphics.getspritelocation.address
        lda #$d0
        sta graphics.getspritelocation.address+1

        ; number = (number-1)*2
        ldy graphics.getspritelocation.number$
        dey
        tya
        asl ; A=A*2
        tay

        lda (graphics.getspritelocation.address),y
        sta graphics.getspritelocation.x$ ; We only care about the lo byte

        iny
        lda (graphics.getspritelocation.address),y
        sta graphics.getspritelocation.y$ ; We only care about the lo byte
        lda #$00
        sta graphics.getspritelocation.y$+1

        ; Find the 9th bit for X's hi byte
        jsr graphics.getspriteormask
        lda $d010
        and graphics.getspritelocation.number$
        beq @ClearXHi
        ;jmp @Done
@SetXHi
        lda #$01
        sta graphics.getspritelocation.x$+1
        jmp @Done
@ClearXHi
        lda #$00
        sta graphics.getspritelocation.x$+1
@Done
        rts


#endregion

#region Audio

audio.voice1$   = #01
audio.voice2$   = #02
audio.voice3$   = #03

audio.volumeaddress     = $d418

audio.triangleon$       = $11
audio.triangleoff$      = $10
audio.sawtoothon$       = $21
audio.sawtoothoff$      = $20
audio.pulseon$          = $41
audio.pulseoff$         = $40
audio.noiseon$          = $81
audio.noiseoff$         = $80

audio.attackhigh$       = $80
audio.attackmedium$     = $40
audio.attacklow$        = $20
audio.attacklowest$     = $10
audio.decayhigh$        = $08
audio.decaymedium$      = $04
audio.decaylow$         = $02
audio.decaylowest$      = $01

audio.sustainhigh$      = $80
audio.sustainmedium$    = $40
audio.sustainlow$       = $20
audio.sustainlowest$    = $10
audio.releasehigh$      = $08
audio.releasemedium$    = $04
audio.releaselow$       = $02
audio.releaselowest$    = $01

audio.setvolume.value$ = $73 ; 1 byte
audio.setvolume$
        ; 0 = off, 15 = max
        lda audio.setvolume.value$
        sta audio.volumeaddress
        rts

audio.getvoiceaddress.voice = $73 ; 1 byte
audio.getvoiceaddress.address = $74 ; 1 byte
audio.getvoiceaddress

        ; product = (voice-1)*7
        ldx audio.getvoiceaddress.voice
        dex
        stx math.multiply8.factor1$
        lda #$07
        sta math.multiply8.factor2$
        jsr math.multiply8$

        ; voice(lo) = product + address
        lda math.multiply8.product$
        clc
        adc audio.getvoiceaddress.address
        sta audio.getvoiceaddress.voice

        ; voice(hi) = $d4
        lda #$d4
        sta audio.getvoiceaddress.voice+1

        rts

audio.setwaveform.voice$ = $73 ; 1 byte
audio.setwaveform.value$ = $75 ; 1 byte
audio.setwaveform$
        lda #$04
        sta audio.getvoiceaddress.address
        jsr audio.getvoiceaddress

        ldy #$00
        lda audio.setwaveform.value$
        sta (audio.setwaveform.voice$),y
        rts


audio.setattackdecay.voice$ = $73 ; 1 byte
audio.setattackdecay.value$ = $75 ; 1 byte
audio.setattackdecay$
        lda #$05
        sta audio.getvoiceaddress.address
        jsr audio.getvoiceaddress

        ldy #$00
        lda audio.setattackdecay.value$
        sta (audio.setattackdecay.voice$),y
        rts

audio.setsustainrelease.voice$ = $73 ; 2 bytes
audio.setsustainrelease.value$ = $75 ; 1 byte
audio.setsustainrelease$
        lda #$06
        sta audio.getvoiceaddress.address
        jsr audio.getvoiceaddress

        ldy #$00
        lda audio.setsustainrelease.value$
        sta (audio.setsustainrelease.voice$),y
        rts

audio.setfrequency.voice$ = $73 ; 1 byte
audio.setfrequency.frequency$ = $75 ; 2 bytes
audio.setfrequency$
        lda #$00
        sta audio.getvoiceaddress.address
        jsr audio.getvoiceaddress

        ldy #$00
        lda audio.setfrequency.frequency$
        sta (audio.setfrequency.voice$),y
        iny
        lda audio.setfrequency.frequency$+1
        sta (audio.setfrequency.voice$),y

        rts

audio.beep$

        ; Set the volume
        lda #$0f
        sta audio.volumeaddress

        ; Set attack/decay
        lda #$0
        sta $d405

        ; Set sustain/release
        lda #$f8
        sta $d406

        ; Set frequency
        lda #$4a
        sta $d400 ; lo
        lda #$22
        sta $d401 ; hi

        ; Set waveform
        lda #$11
        sta $d404

        ; Wait
        jsr time.halt$
        jsr time.halt$

        ; Disable waveform
        lda #$10
        sta $d404

        rts

; https://codebase64.org/doku.php?id=base:simple_irq_music_player
audio.sidinitaddress$   word $a000 ;$a048
audio.sidplayaddress$   word $a006 ;$a021
;audio.sidloadaddress$   word $a000
audio.sidfinished$      byte $00
audio.sidtimer$         word $5000

;;audio.cia1
;;incasm "buffer256.asm"

;audio.sidstart$
;        sei

;;;        lda #$10
;;;        sta memory.copy16.source$
;;;        lda #$dc
;;;        sta memory.copy16.source$+1
;;;        lda #<audio.cia1
;;;        sta memory.copy16.destination$
;;;        lda #>audio.cia1
;;;        sta memory.copy16.destination$+1
;;;        lda #$f0
;;;        sta memory.copy16.length$
;;;        lda #$00
;;;        sta memory.copy16.length$+1
;;;        jsr memory.copy16$
;;        lda #$00
;;        sta memory.copy16.source$
;;        lda #$dc
;;        sta memory.copy16.source$+1
;;        lda #<audio.cia1
;;        sta memory.copy16.destination$
;;        lda #>audio.cia1
;;        sta memory.copy16.destination$+1
;;        lda #$00
;;        sta memory.copy16.length$
;;        lda #$01
;;        sta memory.copy16.length$+1
;;        jsr memory.copy16$
;;;        lda #$00
;;;        sta memory.copy16.source$
;;;        lda #$dc
;;;        sta memory.copy16.source$+1
;;;        lda #<audio.cia1
;;;        sta memory.copy16.destination$
;;;        lda #>audio.cia1
;;;        sta memory.copy16.destination$+1
;;;        lda #$10
;;;        sta memory.copy16.length$
;;;        lda #$00
;;;        sta memory.copy16.length$+1
;;;        jsr memory.copy16$

;        lda #<audio.sidirq 
;        ldx #>audio.sidirq
;        sta $0314
;        stx $0315
;        lda #$1b
;        ldx #$00 
;        ldy #$7f 
;        sta $d011 
;        stx $d012 
;        sty $dc0d; CIA #1
;        ;sty $dd0d; CIA #2

;          ;lda $dc0d  ;by reading this two registers we negate any pending CIA irqs. 
;          ;lda $dd0d  ;if we don't do this, a pending CIA irq might occur after we finish setting up our irq. 
;                       ;we don't want that to happen.

;        lda #$01 
;        sta $d01a 
;        sta $d019 ; ACK any raster IRQs 
;        lda #$00
;        
;        ; Change TOD to 50 Hz
;        lda $DD0E
;        ora #%10000000
;        sta $DD0E
;        lda $DC0E
;        ora #%10000000
;        sta $DC0E

;        ;jsr $a000
;        ;;jsr $a048
;        lda #>audio.sidafterinijmp
;        pha
;        lda #<audio.sidafterinijmp
;        pha
;        lda #$00 ; !!!
;        jmp (audio.sidinitaddress$) ;Initialize Richard's music
;audio.sidafterinijmp=*-1

;;        lda audio.sidinitaddress$
;;        sta audio.sidinitjsr+1
;;        lda audio.sidinitaddress$+1
;;        sta audio.sidinitjsr+2
;;        lda #$00
;;audio.sidinitjsr
;;        jsr $1234

;        cli
;        rts


;audio.sidirq

;           pha        ;store register A in stack 
;           txa 
;           pha        ;store register X in stack 
;           tya 
;           pha        ;store register Y in stack 


;        lda audio.sidfinished$
;        cmp #$01
;        bne @cont
;        jmp @done
;@cont


;        lda #$01 
;        sta $d019 ; ACK any raster IRQs 

;        ;jsr $a006
;        ;jsr $a021 ;Play the music 
;        lda #>audio.sidafterplayjmp
;        pha
;        lda #<audio.sidafterplayjmp
;        pha
;        jmp (audio.sidplayaddress$) ;Play the music 
;audio.sidafterplayjmp=*-1

;@done
;           pla 
;           tay        ;restore register Y from stack (remember stack is FIFO: First In First Out) 
;           pla 
;           tax        ;restore register X from stack 
;           pla        ;restore register A from stack 

;           ;jmp $ea81
;           jmp $ea31   ; call routine to move/flash cursor, read keyboard, etc. (2) 
;           ;rti         ;(3) 


;audio.sidend$

;        lda #$01
;        sta audio.sidfinished$

;        sei

;        lda #$31
;        ;lda #$81
;        ldx #$ea
;        sta $0314
;        stx $0315

;;;        lda #$10
;;;        sta memory.copy16.destination$
;;;        lda #$dc
;;;        sta memory.copy16.destination$+1
;;;        lda #<audio.cia1
;;;        sta memory.copy16.source$
;;;        lda #>audio.cia1
;;;        sta memory.copy16.source$+1
;;;        lda #$f0
;;;        sta memory.copy16.length$
;;;        lda #$00
;;;        sta memory.copy16.length$+1
;;;        jsr memory.copy16$
;;        lda #$00
;;        sta memory.copy16.destination$
;;        lda #$dc
;;        sta memory.copy16.destination$+1
;;        lda #<audio.cia1
;;        sta memory.copy16.source$
;;        lda #>audio.cia1
;;        sta memory.copy16.source$+1
;;        lda #$00
;;        sta memory.copy16.length$
;;        lda #$01
;;        sta memory.copy16.length$+1
;;        jsr memory.copy16$
;;;;        lda #$00
;;;;        sta memory.copy16.destination$
;;;;        lda #$dc
;;;;        sta memory.copy16.destination$+1
;;;;        lda #<audio.cia1
;;;;        sta memory.copy16.source$
;;;;        lda #>audio.cia1
;;;;        sta memory.copy16.source$+1
;;;;        lda #$10
;;;;        sta memory.copy16.length$
;;;;        lda #$00
;;;;        sta memory.copy16.length$+1
;;;;        jsr memory.copy16$

;        lda #$1b
;        ;lda #$9B
;        sta $d011

;        ldx #$00
;        ;ldx #$0c
;        stx $d012


;         lda #0 
;   sta $dc0e      ;Set TOD Clock Frequency to 60Hz 
;   sta $dc0f      ;Enable Set-TOD-Clock 
;   sta $dc0b      ;Set TOD-Clock to 0 (hours) 
;   sta $dc0a      ;- (minutes) 
;   sta $dc09      ;- (seconds) 
;   sta $dc08      ;- (deciseconds) 
;        bit $dc0e 
;        bit $dc0f 
;        bit $dc0d 
;                lda #0 
;                sta $dc0e 

;        ;ldy #$00
;        ;ldy #$81 ; CIA #1: http://unusedino.de/ec64/technical/aay/c64/cia113.htm
;        ldy #$7f
;        sty $dc0d
;        ldy #$81
;        sty $dc0d

;        ldy #$7f ; CIA #2: http://unusedino.de/ec64/technical/aay/c64/cia213.htm
;        sty $dd0d

;        lda #$01
;        sta $dc0e
;;        lda #$08
;;        sta $dc0f

;;        ;lda #$7f 
;;;        sta $d01a ; turn off raster interrupts 
;;;        lda #$01
;;;        sta $dc0d ; turn on CIA interrupts 

;        ldx #$00
;        ;ldx #$f0
;        ;ldy #$01
;        stx $d01a
;        ;sty $d019 ; ACK any raster IRQs 

;        lda #$FF 
;        ;lda #$00
;        sta $d019 ; Ack any pending interrupt 

;        cli

;;        jsr $FFEA ; call UDTIM

;        lda #audio.voice1$
;        sta audio.setfrequency.voice$
;        lda #$00
;        sta audio.setfrequency.frequency$
;        sta audio.setfrequency.frequency$+1
;        jsr audio.setfrequency$

;        lda #audio.voice2$
;        sta audio.setfrequency.voice$
;        lda #$00
;        sta audio.setfrequency.frequency$
;        sta audio.setfrequency.frequency$+1
;        jsr audio.setfrequency$

;        lda #audio.voice3$
;        sta audio.setfrequency.voice$
;        lda #$00
;        sta audio.setfrequency.frequency$
;        sta audio.setfrequency.frequency$+1
;        jsr audio.setfrequency$

;        rts

audio.sidstart$
        sei
        lda #$35; Disable Kernal and BASIC ROMs
        sta $01

        jsr audio.sid_init

        jsr audio.sid_play

        rts


audio.sidend$
        lda #$01
        sta audio.sidfinished$
        
        jsr audio.sid_off
        
        lda #$36 ; Enable Kernal but keep BASIC disabled
        sta $01
        cli

        rts

audio.sid_init
        jsr audio.sid_off

        ;lda #$00 
        ;jsr $a000 ;Initialize Richard's music 

        lda #>audio.sidafterinijmp
        pha
        lda #<audio.sidafterinijmp
        pha
        lda #$00 ; !!!
        jmp (audio.sidinitaddress$) ;Initialize Richard's music
audio.sidafterinijmp=*-1

        ;cli

        rts

audio.sid_on
        ; Turn on volume
        lda #$0f
        sta audio.setvolume.value$
        jsr audio.setvolume$

        LDA #>audio.sidon
        STA $FFFB
        LDA #<audio.sidon
        STA $FFFA

        LDA #%10000001    ; enable CIA-2 timer A nmi
        STA $DD0D
        lda $DD0D
        LDA #%00000001    ; timer A start
        STA $DD0E
        rts

audio.sid_off
        LDA #%00000000
        STA $DD0E         ; timer A stop
        LDA #%01001111    ; disable all CIA-2 nmi's
        STA $DD0D
        lda $DD0D

        LDA #>audio.sidoff
        STA $FFFB
        LDA #<audio.sidoff
        STA $FFFA

        ; Turn off volume
        lda #$00
        sta audio.setvolume.value$
        jsr audio.setvolume$

        lda #audio.voice1$
        sta audio.setfrequency.voice$
        lda #$00
        sta audio.setfrequency.frequency$
        sta audio.setfrequency.frequency$+1
        jsr audio.setfrequency$

        lda #audio.voice2$
        sta audio.setfrequency.voice$
        lda #$00
        sta audio.setfrequency.frequency$
        sta audio.setfrequency.frequency$+1
        jsr audio.setfrequency$

        lda #audio.voice3$
        sta audio.setfrequency.voice$
        lda #$00
        sta audio.setfrequency.frequency$
        sta audio.setfrequency.frequency$+1
        jsr audio.setfrequency$

        rts

audio.sid_play

        jsr audio.sid_off

;        ; timer value of 19656 ($4CC8)
;        lda #$00
;        sta $DD04
;        lda #$50
;        sta $DD05
        lda audio.sidtimer$
        sta $DD04
        lda audio.sidtimer$+1
        sta $DD05

        jsr audio.sid_on

        rts

audio.sidon

        ; This will store the values of A,X,Y at the memory location where they 
        ; are loaded back near the end of this interrupt handler
        STA audio.sidabuff
        STY audio.sidybuff
        STX audio.sidxbuff

        ;jsr $a006

        lda #>audio.sidafterplayjmp
        pha
        lda #<audio.sidafterplayjmp
        pha
        jmp (audio.sidplayaddress$) ;Play the music 
audio.sidafterplayjmp=*-1

        ; Manually update the TOD variables
        clc                             ; clear carry
        lda $a2
        adc #$01
        sta $a2
        lda $a1
        adc #$00
        sta $a1
        lda $a0
        adc #$00
        sta $a0

        LDA $DD0D

audio.sidabuff=*+1
        LDA #$00
audio.sidybuff=*+1
        LDY #$00
audio.sidxbuff=*+1
        LDX #$00

audio.sidoff
        RTI


;-------------------------------------------------------------------------
;align $100

; https://codebase64.org/doku.php?id=base:nmi_sample_player
audio.digitable=*
audio.digistartaddress$  word $a000 ; Digi start address
audio.digiendaddress$    word $bfff ; Digi endi address
audio.digisamplerate$    word $0100 ; Sample Rate: 256 for 8 bit mono 8 kHz
audio.digifinished$      byte $00 ; Is set to 1 once the audio has finished playing

audio.digisoundptr      = $30 ; 2 bytes
audio.digipoint         = $32 ; 2 bytes
audio.sidaddress        = $d400
audio.digidb = 0

withsidplayer = 0
if withsidplayer = 1
sidplayervol = $d418 ; D418HLP
endif

;0: high nibble first 1: low nibble first
;firstnibble=1
firstnibble=0
;1: no nibbles
;nonibbles=1
nonibbles=0

audio.digistart$

        sei
        lda #$35; Disable Kernal and BASIC ROMs
        sta $01

        lda #$00
        sta audio.digifinished$

        jsr audio.digiinit$
        ldy #<audio.digitable
        ldx #>audio.digitable
        jsr audio.digiplay$

;        lda #$36 ; Enable Kernal but keep BASIC disabled
;        sta $01
;        cli

        rts

audio.digiend$

        jsr audio.digioff$

        lda #$36 ; Enable Kernal but keep BASIC disabled
        sta $01
        cli

        rts

audio.digiinit$
                      jsr audio.digioff$

                      lda #$00
                      ldx #$00
                      nop
@l
                      sta audio.sidaddress,x
                      inx
                      bne @l

                      lda #$00
                      sta audio.sidaddress+$05   ; voice 1 ad
                      lda #$f0
                      sta audio.sidaddress+$06   ;         sr
                      lda #$01
                      sta audio.sidaddress+$04   ;         ctrl
                      lda #$00
                      sta audio.sidaddress+$0c   ; voice 2 ad
                      lda #$f0
                      sta audio.sidaddress+$0d   ;         sr
                      lda #$01
                      sta audio.sidaddress+$0b   ;         ctrl
                      lda #$00
                      sta audio.sidaddress+$13   ; voice 3 ad
                      lda #$f0
                      sta audio.sidaddress+$14   ;         sr
                      lda #$01
                      sta audio.sidaddress+$12   ;         ctrl
                      lda #$00
                      sta audio.sidaddress+$15   ; filter lo
                      lda #$10
                      sta audio.sidaddress+$16   ; filter hi
                      lda #%11110111
                      sta audio.sidaddress+$17   ; filter voices+reso

                      rts

audio.digion$
                      LDA #>audio._digion
                      STA $FFFB
                      LDA #<audio._digion
                      STA $FFFA

                      LDA #%10000001    ; enable CIA-2 timer A nmi
                      STA $DD0D
                      lda $DD0D
                      LDA #%00000001    ; timer A start
                      STA $DD0E
                      rts
audio.digioff$
                      LDA #%00000000
                      STA $DD0E         ; timer A stop
                      LDA #%01001111    ; disable all CIA-2 nmi's
                      STA $DD0D
                      lda $DD0D

                      LDA #>audio._digioff
                      STA $FFFB
                      LDA #<audio._digioff
                      STA $FFFA

                      lda #$00
                      sta audio.digipoint
                      sta audio.digipoint+1
                      sta audio.digistoplo+1
                      sta audio.digistophi+1

                      lda #%00000000
                      sta audio.sidaddress+$17   ; filter voices+reso

                      rts


audio.digiplay$

                      ;jsr audio.digioff$
                      nop
                      nop
                      nop

                      stx audio.digisoundptr+1
                      sty audio.digisoundptr

                      ldy #$00
                      lda (audio.digisoundptr),y
                      sta audio.digipoint
                      iny
                      lda (audio.digisoundptr),y
                      sta audio.digipoint+1
                      iny
                      lda (audio.digisoundptr),y
                      sta audio.digistoplo+1
                      iny
                      lda (audio.digisoundptr),y
                      sta audio.digistophi+1
                      iny
                      lda (audio.digisoundptr),y
                      sta $DD04
                      iny
                      lda (audio.digisoundptr),y
                      sta $DD05


if nonibbles = 0
                      lda #$00
                      sta audio.digi_nib+1
endif

                      jsr audio.digion$

                      rts

;-------------------------------------------
;align $100

audio._digion
                STA audio._digiabuffer
                STY audio._digiybuffer

                ;jsr audio.checkcallback

if withsidplayer = 1
                  lda sidplayervol
                  and #$f0
else
                  lda #$10
endif

audio.digid418nmi        ora #$00
                sta audio.sidaddress+$18          ; volume reg

if withsidplayer = 1
                  sta sidplayervol
endif

if audio.digidb = 1
                 sta $d020
endif

                LDA audio.digipoint+1
audio.digistophi      CMP #$12                ;ENDHIGH
                BNE audio.digi_SK1

                LDA audio.digipoint
audio.digistoplo      CMP #$00                ;ENDLOW
                BNE audio.digi_SK1

if withsidplayer = 1
                  lda #$08
else
                  lda #$00
endif

                STA audio.digid418nmi+1

                lda #$01
                sta audio.digifinished$

                ;jsr audio.digioff$
                nop
                nop
                nop

                LDA audio._digiabuffer

                RTI

audio.digi_SK1

                LDY #$00

if nonibbles = 0
audio.digi_nib
                lda #$00
                and #$01
                bne audio.digi_s1
endif

                LDA (audio.digipoint),Y

if nonibbles = 0
if firstnibble = 0 ; high nibble first
                  lsr a
                  lsr a
                  lsr a
                  lsr a
else              ; low nibble first
                  AND #$0F
endif

                jmp audio.digi_s2
audio.digi_s1
                LDA (audio.digipoint),Y
if firstnibble = 1 ; high nibble second
                  lsr a
                  lsr a
                  lsr a
                  lsr a
else              ; low nibble second
                  AND #$0F
endif
endif

                INC audio.digipoint
                BNE @SK
                INC audio.digipoint+1
@SK
audio.digi_s2
                STA audio.digid418nmi+1

if nonibbles = 0
                inc audio.digi_nib+1
endif

                LDA $DD0D ; ACK

audio._digiabuffer=*+1
                LDA #$00
audio._digiybuffer=*+1
                LDY #$00

audio._digioff
                RTI

#endregion

#region Joystick

joystick.port1$ = #01
joystick.port2$ = #02

joystick.getstate.port$ = $7a ; 1 byte
joystick.getstate.fire$ = $7b ; 1 byte
joystick.getstate.deltax$ = $7c ; 1 byte
joystick.getstate.deltay$ = $7d ; 1 byte
joystick.getstate$
        ;https://codebase64.org/doku.php?id=base:joystick_input_handling

        lda joystick.getstate.port$
        cmp #joystick.port1$
        beq @port1
        jmp @port2
@port1
        lda $dc01 ; port 1
        jmp @getstate
@port2
        lda $dc00 ; port 2
@getstate

djrrb   ldy #0        ; this routine reads and decodes the
        ldx #0        ; joystick/firebutton input data in
        lsr           ; the accumulator. this least significant
        bcs djr0      ; 5 bits contain the switch closure
        dey           ; information. if a switch is closed then it
djr0    lsr           ; produces a zero bit. if a switch is open then
        bcs djr1      ; it produces a one bit. The joystick dir-
        iny           ; ections are right, left, forward, backward
djr1    lsr           ; bit3=right, bit2=left, bit1=backward,
        bcs djr2      ; bit0=forward and bit4=fire button.
        dex           ; at rts time dx and dy contain 2's compliment
djr2    lsr           ; direction numbers i.e. $ff=-1, $00=0, $01=1.
        bcs djr3      ; dx=1 (move right), dx=-1 (move left),
        inx           ; dx=0 (no x change). dy=-1 (move up screen),
djr3    lsr           ; dy=0 (move down screen), dy=0 (no y change).
        stx joystick.getstate.deltax$        ; the forward joystick position corresponds
        sty joystick.getstate.deltay$        ; to move up the screen and the backward
                      ; position to move down screen.
        lda #$00
        bcc @fire
        jmp @setfire
@fire                 ; at rts time the carry flag contains the fire
        lda #$01      ; button state. if c=1 then button not pressed.
@setfire              ; if c=0 then pressed.
        sta joystick.getstate.fire$

        rts

#endregion

#region Disk

;align $100

; http://www.unusedino.de/ec64/technical/misc/c64/romlisting.html
disk.error$ byte $00
;diskerr.run_stop$                = $00 ; This could happen if the user presses RUN/STOP during load
;diskerr.too_many_files$          = $01
;diskerr.file_open$               = $02
;diskerr.file_not_open$           = $03
;diskerr.file_not_found$          = $04
;diskerr.device_not_present$      = $05
;diskerr.not_input_file$          = $06
;diskerr.not_output_file$         = $07
;diskerr.missing_file_name$       = $08
;diskerr.illegal_device_number$   = $09
;diskerr.out_of_data$             = $0d
;diskerr.out_of_memory$           = $10
;diskerr.string_too_long$         = $17
;diskerr.file_data$               = $18
;diskerr.verify$                  = $1c
;diskerr.load$                    = $1d
;diskerr.break$                   = $1e
diskerror.ok$                     = 00
diskerror.file_scratched$         = 01
diskerror.file_open$               = 02
;diskerror.file_not_open$           = 03
;diskerror.file_not_found$          = 04
diskerror.device_not_present$      = 05
diskerror.not_input_file$          = 06
diskerror.not_output_file$         = 07
diskerror.missing_file_name$       = 08
diskerror.illegal_device_number$   = 09
diskerror.out_of_data$             = 13
diskerror.out_of_memory$           = 16
diskerror.block_header_not_found$ = 20
diskerror.sync_char_not_found$    = 21
diskerror.data_block_not_present$ = 22
diskerror.checksum_error$         = 23
diskerror.byte_decode_error$      = 24
diskerror.write_verify_error$     = 25
diskerror.write_protect_on$       = 26
diskerror.checksum_error_header$  = 27
diskerror.data_extends_block$     = 28
diskerror.disk_id_mismatch$       = 29
diskerror.general_syntax_error$   = 30
diskerror.invalid_command$        = 31
diskerror.long_line$              = 32
diskerror.invalid_filename$       = 33
diskerror.no_file_given$          = 34
diskerror.cmd_file_not_found$     = 39
diskerror.rcd_not_present$        = 50
diskerror.overflow_in_rcd$        = 51
diskerror.file_too_large$         = 52
diskerror.file_open_for_write$    = 60
diskerror.file_not_open$          = 61
diskerror.file_not_found$         = 62
diskerror.file_exists$            = 63
diskerror.file_type_mismatch$     = 64
diskerror.no_block$               = 65
diskerror.illegal_track_sector$   = 66
diskerror.illegal_sys_track_sector$ = 67
diskerror.no_channels$            = 70
diskerror.directory_error$        = 71
diskerror.disk_directory_full$    = 72
diskerror.power_up$               = 73
diskerror.drive_not_ready$        = 74



disk.setnam.filename$ = $20 ; 2 bytes
disk.setnam

        lda #$00
        jsr $ff90 ; disable kernal messages (searching/loading) 

        ; Need to close the file first because of a bug in Covert Bitops when used with SD2IEC!
        ;lda #$02      ; filenumber 2
        ;jsr $ffc3     ; call CLOSE

        lda #diskerror.ok$
        sta disk.error$

        lda disk.setnam.filename$
        sta string.getlength.address$
        lda disk.setnam.filename$+1
        sta string.getlength.address$+1
        jsr string.getlength$

        lda string.getlength.length$
        ldx disk.setnam.filename$
        ldy disk.setnam.filename$+1
        jsr $ffbd     ; call SETNAM
        lda #$01
        ldx $ba       ; last used device number
        bne @skip
        ldx #$08      ; default to device 8
@skip   
        ;ldy #$01      ; not $01 means: load to address stored in file
        ldy #$00        ; secondary address overridden below in call to $FFD5
        jsr $ffba     ; call SETLFS

        rts

disk.readfile.filename$ = $20 ; 2 bytes
disk.readfile.address$ = $22 ; 2 bytes
disk.readfile.length$ = $24 ; 2 bytes
disk.readfile$

        lda #$00
        sta disk.readfile.length$
        sta disk.readfile.length$+1

        jsr disk.setnam

        lda #$00      ; $00 means: load to memory (not verify)
        ldx disk.readfile.address$ ; memory address to load
        ldy disk.readfile.address$+1
        jsr $ffd5     ; call LOAD
        bcc @ok    ; if carry set, a load error has happened
@error
        ; Accumulator contains BASIC error code

        ; most likely errors:
        ; A = $05 (DEVICE NOT PRESENT)
        ; A = $04 (FILE NOT FOUND)
        ; A = $1D (LOAD ERROR)
        ; A = $00 (BREAK, RUN/STOP has been pressed during loading)

        ;... error handling ...

        ;sta disk.error$
        ;rts

        ; For some reason the machine has encountered a BREAK.
        ; Try loading the file again.
        cmp #$00
        beq disk.readfile$

        jmp disk.readerrorchannel

@ok

        ;  X/Y = Address of last byte loaded/verified (if Carry = 0)
        stx math.subtract16.menuend$
        ;sty math.subtract32.menuend$+1
        sty math.subtract16.menuend$+1
        lda disk.readfile.address$
        sta math.subtract16.subtrahend$
        lda disk.readfile.address$+1
        sta math.subtract16.subtrahend$+1
        jsr math.subtract16$
        lda math.subtract16.difference$
        sta disk.readfile.length$
        lda math.subtract16.difference$+1
        sta disk.readfile.length$+1

        rts

disk.readfile.filename$ = $20 ; 2 bytes
disk.readfile.address$ = $22 ; 2 bytes
disk.readfile.length$ = $24 ; 2 bytes
disk.readfile

        ; Defaults

        ;jsr console.resetbufaddress

        ; Need to close the file first because of a bug in Covert Bitops when used with SD2IEC!
        lda #$02      ; filenumber 2
        jsr $ffc3     ; call CLOSE

        lda #diskerror.ok$
        sta disk.error$

        lda #$00
        sta disk.readfile.length$
        sta disk.readfile.length$+1

        lda disk.readfile.filename$
        sta string.getlength.address$
        lda disk.readfile.filename$+1
        sta string.getlength.address$+1
        jsr string.getlength$

        lda string.getlength.length$
        ldx disk.readfile.filename$
        ldy disk.readfile.filename$+1
        jsr $ffbd     ; call SETNAM

        lda #$02      ; file number 2
        ldx $ba       ; last used device number
        bne @skip
        ldx #$08      ; default to device 8
@skip   
        ldy #$02      ; secondary address 2
        ldy #$00
        jsr $ffba     ; call setlfs

        jsr $ffc0     ; call open
        ;bcs error    ; if carry set, the file could not be opened
        bcc @ok
        ; Akkumulator contains BASIC error code

        ; most likely errors:
        ; A = $05 (DEVICE NOT PRESENT)
        sta disk.error$
        ;nop
        ;nop
        ;nop

        ;... error handling for open errors ...
        jmp @close    ; even if OPEN failed, the file has to be closed
        ;nop
        ;nop
        ;nop
@ok

        ;; check drive error channel here to test for
        ;; FILE NOT FOUND error etc.
        ;jsr disk.readerrorchannel
        ;lda #diskerror.ok$
        ;cmp disk.error$
        ;beq @ok2
        ;jmp @close

@ok2
        ldx #$02      ; filenumber 2
        jsr $ffc6     ; call CHKIN (file 2 now used as input)

        lda disk.readfile.address$
        sta $ae
        lda disk.readfile.address$+1
        sta $af

        ldy #$00
@loop
        jsr $ffb7     ; call READST (read status byte)
        ;bne @eof      ; either EOF or read error
        ;beq @cont
        bne @no_cont
        jmp @cont
@no_cont
        jmp @eof

        nop
        nop
        nop
        nop
        nop

@eof
        and #$40      ; end of file?
        ;BEQ readerror
        bne @readerror
        jmp @close
        
@readerror
        ; for further information, the drive error channel has to be read
        jsr disk.readerrorchannel

        jmp @close
        
@cont
        ;inc $d020
        jsr $ffcf     ; call CHRIN (get a byte from file)
        sta ($ae),y   ; write byte to memory

        ; Increment the length
        ldx #<disk.readfile.length$
        stx math.inc16.address$
        ldx #>disk.readfile.length$
        stx math.inc16.address$+1
        jsr math.inc16$

        inc $ae
        bne @skip2
        inc $af
@skip2  
        jmp @loop     ; next byte

@close
        lda #$02      ; filenumber 2
        jsr $ffc3     ; call CLOSE

        jsr $ffcc     ; call CLRCHN
        rts

disk.readerrorchannel.errordec word $0000
disk.readerrorchannel
; https://codebase64.org/doku.php?id=base:reading_the_error_channel_of_a_disk_drive
        lda #$00      ; no filename
        ldx #$00
        ldy #$00
        jsr $ffbd     ; call SETNAM

        lda #$0f      ; file number 15
        ldx $ba       ; last used device number
        bne @skip
        ldx #$08      ; default to device 8
@skip   
        ldy #$0f      ; secondary address 15 (error channel)
        jsr $ffba     ; call SETLFS

        jsr $ffc0     ; call OPEN
        ;bcs @error    ; if carry set, the file could not be opened
        bcc @ok
        jmp @error
@ok

        ldx #$0f      ; filenumber 15
        jsr $ffc6     ; call CHKIN (file 15 now used as input)

        ; Set the length to be converted from PETSCII to integer to be 2 characters
        lda #$02
        sta convert.dec2hex8.len

        ; Read the first two character from the drive (this will be the error number)
        ldy #$00
@Loop
        jsr $ffb7     ; call READST (read status byte)
        ;bne @eof      ; either EOF or read error
        beq @noteof
        jmp @eof
@noteof
        jsr $ffcf     ; call CHRIN (get a byte from file)
        sta convert.dec2hex8.value,y
        iny
        cpy convert.dec2hex8.len
        bne @Loop

        ; Convert the error number characters to integer
        jsr convert.dec2hex8
        lda convert.dec2hex8.result
        sta disk.error$

@eof
@close
        lda #$0f      ; filenumber 15
        jsr $ffc3     ; call CLOSE

        jsr $ffcc     ; call CLRCHN
        rts
@error
        ; Akkumulator contains BASIC error code

        ; most likely error:
        ; A = $05 (DEVICE NOT PRESENT)

        ;... error handling for open errors ...
        jmp @close    ; even if OPEN failed, the file has to be closed

disk.getdiskinfo.filename text '$:', console.null$
disk.getdiskinfo.label$  text $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, console.null$
;disk.getdiskinfo.id$ text $ff, $ff, console.null$
;disk.getdiskinfo.type$   byte $00
disk.getdiskinfo.blocksfree$ word $0000
disk.getdiskinfo$

        jsr console.resetbufaddress

        ; Load the file into memory
        lda #<disk.getdiskinfo.filename
        sta disk.readfile.filename$
        lda #>disk.getdiskinfo.filename
        sta disk.readfile.filename$+1
        lda #<console.readstr.bufaddress
        sta disk.readfile.address$
        lda #>console.readstr.bufaddress
        sta disk.readfile.address$+1
        jsr disk.readfile

        ; Clear the label
        lda #<disk.getdiskinfo.label$
        sta memory.fill.address$
        lda #>disk.getdiskinfo.label$
        sta memory.fill.address$+1
        lda #$ff
        sta memory.fill.value$
        lda #16
        sta memory.fill.length$
        jsr memory.fill$

        ; Figure out the offset of the label
        lda #<console.readstr.bufaddress
        sta math.add16.addend1$
        lda #>console.readstr.bufaddress
        sta math.add16.addend1$+1
        lda #8
        sta math.add16.addend2$
        lda #0
        sta math.add16.addend2$+1
        jsr math.add16$

        ; Disk label text is from 8 thru 23
        lda math.add16.sum$
        sta memory.copy.source$
        lda math.add16.sum$+1
        sta memory.copy.source$+1
        lda #<disk.getdiskinfo.label$
        sta memory.copy.destination$
        lda #>disk.getdiskinfo.label$
        sta memory.copy.destination$+1
        lda #16
        sta memory.copy.length$
        jsr memory.copy$

        ; Clear blocks free
        lda #$00
        sta disk.getdiskinfo.blocksfree$
        lda #$00
        sta disk.getdiskinfo.blocksfree$+1

        ; Figure out the offset of the blocks free
        lda #<console.readstr.bufaddress
        sta math.add16.addend1$
        lda #>console.readstr.bufaddress
        sta math.add16.addend1$+1
        lda #34
        sta math.add16.addend2$
        lda #0
        sta math.add16.addend2$+1
        jsr math.add16$

        ; Disk blocks free hexadecimal is from 34 thru 35
        lda math.add16.sum$
        sta memory.copy.source$
        lda math.add16.sum$+1
        sta memory.copy.source$+1
        lda #<disk.getdiskinfo.blocksfree$
        sta memory.copy.destination$
        lda #>disk.getdiskinfo.blocksfree$
        sta memory.copy.destination$+1
        lda #2
        sta memory.copy.length$
        jsr memory.copy$

        rts

;align $100

disk.fileexists.filename$      = $20 ; 2 bytes
disk.fileexists.exists$        = $26 ; 1 byte
disk.fileexists$
        ; For reasons unclear, after searching for the file using the
        ; LOAD"$:filename",8 command, you get a "?DEVICE NOT READY" error
        ; which is only resolved by using LOAD"$",8
        ; This adds extra overhead which used with a 1541 drive
        ; not so much when used with a IEC device

        ; Find the file using the LOAD"$:filename",8 command
        jsr disk.getfileinfo$
        jsr disk.getfileinfoclose$

        ; Check for errors
        lda disk.error$
        cmp #diskerror.ok$
        beq @FileExistOk
        rts
@FileExistOk

        ; If type != unknown then we have found the file
        lda disk.getfileinfo.type$
        beq @done
        lda #$01
@done
        sta disk.fileexists.exists$

        ; The following code is the fix for the "?DEVICE NOT READY" error
        lda #'$'
        sta disk.getfileinfo.filename
        jsr disk.getdiskinfo.reset
        
@loop
        lda disk.getfileinfo.type$
        beq @done2
        jsr disk.getnextfileinfo$
        jmp @loop

@done2
        jsr disk.getfileinfoclose$   

        lda disk.fileexists.exists$

        rts

;disk.fileexists.filename$      = $20 ; 2 bytes
;disk.fileexists.exists$        = $26 ; 1 byte
;disk.fileexists$
;        lda #$00
;        sta disk.fileexists.exists$

;        lda #'$'
;        sta disk.getfileinfo.filename
;        jsr disk.getdiskinfo.reset
;        
;@loop
;        lda disk.getfileinfo.filename$
;        sta string.isequal.address1$
;        lda disk.getfileinfo.filename$+1
;        sta string.isequal.address1$+1
;        lda #<disk.getfileinfo.name$
;        sta string.isequal.address2$
;        lda #>disk.getfileinfo.name$
;        sta string.isequal.address2$+1
;        jsr string.isequal$
;        lda string.isequal.value$
;        bne @FoundFile
;        jmp @CheckFileType
;@FoundFile
;        lda #$01
;        sta disk.fileexists.exists$

;@CheckFileType
;        lda disk.getfileinfo.type$
;        beq @done2
;        jsr disk.getnextfileinfo$
;        jmp @loop

;@done2
;        jsr disk.getfileinfoclose$   

;        lda disk.fileexists.exists$

;        rts

disk.getfileinfoclose$
;@close
        lda #$03      ; filenumber 3
        jsr $ffc3     ; call CLOSE

        jsr $ffcc     ; call CLRCHN
        rts

;;disk.writefile.filename text "@0:"
;disk.writefile.filename
;disk.writefile.name text '1234567890123456'
;disk.writefile.ext text ",p,w"
;disk.writefile.filename$ = $20 ; 2 bytes
;disk.writefile.address$ = $22 ; 2 bytes
;disk.writefile.length$ = $24 ; 2 bytes
;disk.writefile.len = $26 ; 2 bytes
;disk.writefile$

;        ; Need to close the file first because of a bug in Covert Bitops when used with SD2IEC!
;        lda #$02      ; filenumber 2
;        jsr $ffc3     ; call CLOSE

;        ; Due to a bug for the REPLACE command we need to scratch the file prior to saving it
;        ; https://www.c64-wiki.com/wiki/Commodore_1541#Disk_Drive_Commands
;        jsr disk.scratchfile
;        lda disk.error$
;        ;nop
;        ;nop
;        cmp #diskerror.ok$
;        beq @scratchok
;        cmp #diskerror.file_not_found$
;        beq @scratchok
;        rts
;@scratchok

;        ; Set default values
;        lda #diskerror.ok$
;        sta disk.error$

;        ; Check for 0 length$
;        lda #$00
;        sta math.cmp16.num1$
;        sta math.cmp16.num1$+1
;        lda disk.writefile.length$
;        sta math.cmp16.num2$
;        lda disk.writefile.length$+1
;        sta math.cmp16.num2$+1
;        jsr math.cmp16$
;        bne @lenok
;        rts
;@lenok

;;        ; check drive error channel
;;        jsr disk.readerrorchannel
;;        lda disk.error$
;;        cmp #diskerror.ok$
;;        beq @ok0
;;        jmp @close
;;@ok0

;        ; Get the length of filename$
;        lda disk.writefile.filename$
;        sta string.getlength.address$
;        lda disk.writefile.filename$+1
;        sta string.getlength.address$+1
;        jsr string.getlength$
;        lda string.getlength.length$
;        sta disk.writefile.len

;        ; Copy filename$ into filename at position 3
;        lda disk.writefile.filename$
;        sta memory.copy.source$
;        lda disk.writefile.filename$+1
;        sta memory.copy.source$+1
;        lda #<disk.writefile.name
;        sta memory.copy.destination$
;        lda #>disk.writefile.name
;        sta memory.copy.destination$+1
;        lda disk.writefile.len
;        sta memory.copy.length$
;        jsr memory.copy$
;        
;        ; Append ',p,w'
;        ldx #$00
;        ldy disk.writefile.len
;@extcopy_loop
;        lda disk.writefile.ext,x
;        sta disk.writefile.name,y
;        inx
;        iny
;        cpx #4
;        bne @extcopy_loop

;        ; Calculate the length (length of filename$ + 7)
;        lda disk.writefile.len
;        clc
;        ;adc #7
;        adc #4

;        ; Write length$ number of bytes from address$ to disk
;        ldx #<disk.writefile.filename
;        ldy #>disk.writefile.filename
;        jsr $ffbd     ; call SETNAM

;        lda #$02      ; file number 2
;        ldx $ba       ; last used device number
;        bne @skip
;        ldx #$08      ; default to device 8
;@skip   
;        ldy #$02      ; secondary address 2
;        ;ldy #$00
;        jsr $ffba     ; call setlfs

;        jsr $ffc0     ; call open
;        ;bcs error    ; if carry set, the file could not be opened
;        bcc @ok
;        ; Akkumulator contains BASIC error code

;        ;lda #$01 ; red
;        ;sta $d020

;        ; most likely errors:
;        ; A = $05 (DEVICE NOT PRESENT)
;        sta disk.error$

;        ;... error handling for open errors ...
;        jmp @close    ; even if OPEN failed, the file has to be closed
;@ok
;        ;; check drive error channel here to test for
;        ;; FILE NOT FOUND error etc.
;        ;jsr disk.readerrorchannel
;        ;lda disk.error$
;        ;cmp #diskerror.ok$
;        ;beq @ok2
;        ;jmp @close

;@ok2

;        ;lda #$04 ; purple
;        ;sta $d020

;;        ; Check for 0 length$
;;        lda #$00
;;        sta math.cmp16.num1$
;;        sta math.cmp16.num1$+1
;;        lda disk.writefile.length$
;;        sta math.cmp16.num2$
;;        lda disk.writefile.length$+1
;;        sta math.cmp16.num2$+1
;;        jsr math.cmp16$
;;        bne @ok3
;;        jmp @close
;@ok3

;        ldx #$02      ; filenumber 2
;        jsr $ffc9     ; call CHKOUT (file 2 now used as output)

;        ; Set the memory address
;        lda disk.writefile.address$
;        sta $ae
;        lda disk.writefile.address$+1
;        sta $af

;        ldy #$00

;        ; Reset the counter
;        lda #$00
;        sta disk.writefile.len
;        sta disk.writefile.len+1

;@loop
;        ldy #$00
;        ldx #$08
;        jsr $ffb7     ; call READST (read status byte)
;        ;bne @eof      ; either EOF or read error
;        beq @cont

;@writeerror

;        ;lda #$02 ; red
;        ;sta $d020

;        ; for further information, the drive error channel has to be read
;        jsr disk.readerrorchannel

;        jmp @close
;        
;@cont
;        ;lda #$03 ; cyan
;        ;sta $d020

;        lda ($ae),y   ; get byte from memory
;        jsr $ffd2     ; call CHROUT (write byte to file)

;        ; Increment the counter
;        lda #<disk.writefile.len
;        sta math.inc16.address$
;        lda #>disk.writefile.len
;        sta math.inc16.address$+1
;        jsr math.inc16$

;        ; Check how many bytes have been written to disk
;        lda disk.writefile.len
;        sta math.cmp16.num1$
;        lda disk.writefile.len+1
;        sta math.cmp16.num1$+1
;        lda disk.writefile.length$
;        sta math.cmp16.num2$
;        lda disk.writefile.length$+1
;        sta math.cmp16.num2$+1
;        jsr math.cmp16$
;        bne @inc_mem
;        jmp @close

;@inc_mem
;        ; Increment memory address
;        inc $ae
;        bne @skip2
;        inc $af
;@skip2  

;        jmp @loop     ; next byte

;@close
;        lda #$02      ; filenumber 2
;        jsr $ffc3     ; call CLOSE

;        jsr $ffcc     ; call CLRCHN

;        jsr disk.readerrorchannel

;        rts

disk.writefile.filename$ = $20 ; 2 bytes
disk.writefile.address$ = $22 ; 2 bytes
disk.writefile.length$ = $24 ; 2 bytes
;disk.writefile.len = $26 ; 2 bytes
disk.writefile$

        jsr disk.scratchfile
        lda disk.error$
        cmp #diskerror.ok$
        beq @scratchok
        cmp #diskerror.file_not_found$
        beq @scratchok
        rts
@scratchok

        ; Set default values
        lda #diskerror.ok$
        sta disk.error$

        ; Check for 0 length$
        lda #$00
        sta math.cmp16.num1$
        sta math.cmp16.num1$+1
        lda disk.writefile.length$
        sta math.cmp16.num2$
        lda disk.writefile.length$+1
        sta math.cmp16.num2$+1
        jsr math.cmp16$
        bne @lenok
        rts
@lenok

        jsr disk.setnam

        ; Calculate the ending address
        lda disk.writefile.address$
        sta math.add16.addend1$
        lda disk.writefile.address$+1
        sta math.add16.addend1$+1
        lda disk.writefile.length$
        sta math.add16.addend2$
        lda disk.writefile.length$+1
        sta math.add16.addend2$+1
        jsr math.add16$

        lda #disk.writefile.address$ ; the zp address of the starting address
        ldx math.add16.sum$
        ldy math.add16.sum$+1
        jsr $ffd8     ; call SAVE
        bcc @ok       ; if carry set, a load error has happened
@error
        ; Akkumulator contains BASIC error code

        ; ... error handling ...

        ;sta disk.error$
        ;rts

        jmp disk.readerrorchannel

@ok
        rts

diskfiletypes.none$     = 0
diskfiletypes.prg$      = 1
diskfiletypes.seq$      = 2
diskfiletypes.usr$      = 3
diskfiletypes.rel$      = 4
diskfiletypes.del$      = 5

disk.getfileinfo.filename$      = $20 ; 2 bytes
disk.getfileinfo.len            byte $00
disk.getfileinfo.offset         byte $00
disk.getfileinfo.cbm            word $0000 ; 2
disk.getfileinfo.cbm2           word $0000 ; 2
disk.getfileinfo.blocks$        byte $00 ; 1 (1 block => 254 bytes)
disk.getfileinfo.buf1           text '   ' ; 3
disk.getfileinfo.filename       text '$:' ; 2
disk.getfileinfo.name$          text $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff, $ff ; 16
disk.getfileinfo.buf2           text '  ' ; 2
disk.getfileinfo.extension      text  '   ' ; 3
disk.getfileinfo.buf3           text '    ' ; 5
disk.getfileinfo.type$          byte $00
disk.getfileinfo.typemap        text 'PSURD'

disk.getfileinfo$

        ; Set default values
        lda #diskerror.ok$
        sta disk.error$

        lda #$00
        sta disk.getfileinfo.offset

        lda #'$'
        sta disk.getfileinfo.filename
        lda #':'
        sta disk.getfileinfo.filename+1

        lda #<disk.getfileinfo.name$
        sta memory.fill.address$
        lda #>disk.getfileinfo.name$
        sta memory.fill.address$+1
        lda #$ff
        sta memory.fill.value$
        lda #16
        sta memory.fill.length$
        jsr memory.fill$

        ; Check to see if filename$ is zero
        lda disk.getfileinfo.filename$
        sta math.cmp16.num1$
        lda disk.getfileinfo.filename$+1
        sta math.cmp16.num1$+1
        lda #$00
        sta math.cmp16.num2$
        sta math.cmp16.num2$+1
        jsr math.cmp16$
        bne @setnam_specific
        jmp disk.getdiskinfo._setnam_all

@setnam_specific ; Set filename = "$:" + filename$

        ; Get the length of the string
        lda disk.getfileinfo.filename$
        sta string.getlength.address$
        lda disk.getfileinfo.filename$+1
        sta string.getlength.address$+1
        jsr string.getlength$
        lda string.getlength.length$
        sta disk.getfileinfo.len

        ; Copy the string to disk.getfileinfo.name$
        lda disk.getfileinfo.filename$
        sta memory.copy.source$
        lda disk.getfileinfo.filename$+1
        sta memory.copy.source$+1
        lda #<disk.getfileinfo.name$
        sta memory.copy.destination$
        lda #>disk.getfileinfo.name$
        sta memory.copy.destination$+1        
        lda disk.getfileinfo.len
        sta memory.copy.length$
        jsr memory.copy$

        ; Calculate the length (len of filename$ + 2)
        lda disk.getfileinfo.len
        clc
        adc #2

        jmp disk.getdiskinfo._setnam

disk.getdiskinfo.reset

disk.getdiskinfo._setnam_all ; Set filename = "$"
        lda #01
        ;jmp @setnam

disk.getdiskinfo._setnam
        ldx #<disk.getfileinfo.filename
        ldy #>disk.getfileinfo.filename
        jsr $ffbd     ; call SETNAM

        lda #$03      ; file number 3
        ldx $ba       ; last used device number
        bne @skip
        ldx #$08      ; default to device 8
@skip   
        ldy #$02      ; secondary address 2
        ldy #$00
        jsr $ffba     ; call setlfs

        jsr $ffc0     ; call open
        bcc @ok
        ; Akkumulator contains BASIC error code

        sta disk.error$

        jmp disk.getfileinfoclose$    ; even if OPEN failed, the file has to be closed
@ok
@ok2
        ldx #$03      ; filenumber 3
        jsr $ffc6     ; call CHKIN (file 3 now used as input)

        ;; Skip the first 2 bytes
        ;lda #2
        ;sta disk.getfileinfo.len
        ;jsr disk.getnextfileinfo$

        ; Skip the disk label
        ;lda #28
        lda #30
        sta disk.getfileinfo.len
        jsr disk.getnextfileinfo$

        lda disk.error$
        ;nop
        beq @get_first_file
        jmp disk.getfileinfoclose$
        ;jmp @done
        ;;cmp #diskerror.ok$
        ;;bne @done

@get_first_file
        ; Get the first file
        lda #32
        sta disk.getfileinfo.len
        jsr disk.getnextfileinfo$
        rts
;@done
;        rts

disk.getnextfileinfo$

        ; Set defaults
        lda #$00
        sta disk.getfileinfo.offset

        lda #diskfiletypes.none$
        sta disk.getfileinfo.type$

        lda #<disk.getfileinfo.cbm
        sta $ae
        lda #>disk.getfileinfo.cbm
        sta $af

        ldy #$00
@loop
        jsr $ffb7     ; call READST (read status byte)
        beq @cont

@eof
        and #$40      ; end of file?
        bne @readerror
        jmp disk.getfileinfoclose$
        
@readerror
        ; for further information, the drive error channel has to be read
        jsr disk.readerrorchannel

        jmp disk.getfileinfoclose$
        
@cont
        jsr $ffcf     ; call CHRIN (get a byte from file)
        ; DO NOT OVERRIDE A!

        ; Check to see if we have read the max number of bytes that we want
        inc disk.getfileinfo.offset
        ldx disk.getfileinfo.offset
        cpx disk.getfileinfo.len
        ;beq @done
        ;nop
        bne @cont2
        jmp @done
@cont2

        ; Need to check the block size (see below)
        cpx #6
        bne @write_mem
        jmp @check_blocks
@write_mem

        sta ($ae),y   ; write byte to memory
        inc $ae
        bne @skip2
        inc $af

@skip2  
        jmp @loop     ; next byte

@check_blocks

        ; Because the 1541 directory listing adds spaces between the block
        ; size and the file name, we need to adjust Y by the number of blocks.
        ldx disk.getfileinfo.blocks$
        ;cpx #00 ; If less than 0 get must be 128-255
        ;bmi @inc_y2
        cpx #10 ; Check if less than 10
;        nop
;        nop
;        nop
;        nop
;        nop
        ;bcc @write_mem
        bcs @write_mem_ok1
        jmp @write_mem
@write_mem_ok1
        iny
        cpx #100 ; Check if less than 100
        ;bcc @write_mem
        bcs @write_mem_ok2
        jmp @write_mem
@write_mem_ok2
        iny
        jmp @write_mem

;@inc_y2 
;        iny
;        iny
;        jmp @write_mem

@done

        ; Replace the " character in the name$ with a null$
        lda #<disk.getfileinfo.name$
        sta $ae
        lda #>disk.getfileinfo.name$
        sta $af
        ldy #$ff
@fname_loop
        iny
        cpy #17
        beq @fname_done
@fname_cont
        lda ($ae),y
        cmp #$22 ; double-quotes
        ;bne @fname_loop
        beq @fname_loop2
        jmp @fname_loop
@fname_loop2
        lda #$ff
        sta ($ae),y
@fname_done

        lda #<disk.getfileinfo.typemap
        sta $ae
        lda #>disk.getfileinfo.typemap
        sta $af
        ldy #$ff
@ftype_loop
        iny
        cpy #5
        ;beq @ftype_done
        bne @ftype_cont
        jmp @ftype_done
@ftype_cont
        lda ($ae),y
        cmp disk.getfileinfo.extension
        ;bne @ftype_loop
        beq @ftype_cont2
        jmp @ftype_loop
@ftype_cont2
        iny
        sty disk.getfileinfo.type$
@ftype_done

        lda #32
        sta disk.getfileinfo.len

        rts

disk.execmd.filename text "x0:"
disk.execmd.name text '1234567890123456789012345678901234567890'
disk.execmd.len byte $00
disk.execmd

        ; Set default value
        lda #diskerror.ok$
        sta disk.error$

        lda disk.execmd.len
        ldx #<disk.execmd.filename
        ldy #>disk.execmd.filename
        jsr $ffbd     ; call SETNAM

        lda #$04      ; file number 4
        ldx $ba       ; last used device number
        bne @skip
        ldx #$08      ; default to device 8
@skip   
        ldy #$0f      ; secondary address 15
        jsr $ffba     ; call setlfs

        jsr $ffc0     ; call open
        nop
        ;bcs error    ; if carry set, the file could not be opened
        bcc @close
        ; Akkumulator contains BASIC error code

        ; most likely errors:
        ; A = $05 (DEVICE NOT PRESENT)
        sta disk.error$

        ;... error handling for open errors ...
        ;jmp @close    ; even if OPEN failed, the file has to be closed

@close
        lda #$04      ; filenumber 4
        jsr $ffc3     ; call CLOSE

        jsr $ffcc     ; call CLRCHN

        jsr disk.readerrorchannel

        jsr disk.checkerror

        rts

disk.execmd1.filename = $20 ; 2 bytes
disk.execmd1

        ; Get the length of filename$
        lda disk.execmd1.filename
        sta string.getlength.address$
        lda disk.execmd1.filename+1
        sta string.getlength.address$+1
        jsr string.getlength$
        lda string.getlength.length$
        sta disk.execmd.len

        ; Copy filename$ into filename
        lda disk.execmd1.filename
        sta memory.copy.source$
        lda disk.execmd1.filename+1
        sta memory.copy.source$+1
        lda #<disk.execmd.name
        sta memory.copy.destination$
        lda #>disk.execmd.name
        sta memory.copy.destination$+1
        lda disk.execmd.len
        sta memory.copy.length$
        jsr memory.copy$

        ; Add 3 to len
        lda disk.execmd.len
        clc
        adc #3
        sta disk.execmd.len

        ; Execute the command
        jmp disk.execmd

disk.format.labelname$ = $20 ; 2 bytes
disk.format$

        ; Set the prefix command "n"
        lda #"n"
        sta disk.execmd.filename

        ; Execute the command
        jmp disk.execmd1


disk.scratchfile.filename$ = $20 ; 2 bytes
disk.scratchfile$

        ; NOTE: The 1541 does not report an error if the file doesn't exist!

        ; Confirm that filename1 exists
        jsr disk.fileexists$
        lda disk.error$
        cmp #diskerror.ok$
        beq @FileExistOk
        rts
@FileExistOk
        lda disk.fileexists.exists$
        bne @FileExists
;        beq @FileNoExists
;        jmp @FileExists
;@FileNoExists
        lda #diskerror.file_not_found$
        sta disk.error$
        rts
@FileExists

disk.scratchfile

        ; Set the prefix command "s"
        lda #"s"
        sta disk.execmd.filename

        ;; Get the length of filename$
;        lda disk.scratchfile.filename$
;        sta string.getlength.address$
;        lda disk.scratchfile.filename$+1
;        sta string.getlength.address$+1
;        jsr string.getlength$
;        lda string.getlength.length$
;        sta disk.execmd.len

;        ; Copy filename$ into filename
;        lda disk.scratchfile.filename$
;        sta memory.copy.source$
;        lda disk.scratchfile.filename$+1
;        sta memory.copy.source$+1
;        lda #<disk.execmd.name
;        sta memory.copy.destination$
;        lda #>disk.execmd.name
;        sta memory.copy.destination$+1
;        lda disk.execmd.len
;        sta memory.copy.length$
;        jsr memory.copy$

;        ; Add 3 to len
;        lda disk.execmd.len
;        clc
;        adc #3
;        sta disk.execmd.len

        ; Execute the command
        jmp disk.execmd1


disk.copyfile.srcfilename$ = $20 ; 2 bytes
disk.copyfile.dstfilename$ = $22 ; 2 bytes
;disk.copyfile.srclen = $24 ; 1 byte
;disk.copyfile.dstlen = $25 ; 1 byte
disk.copyfile$

        ; Set the prefix command "c"
        lda #"c"
        sta disk.execmd.filename

;        ; Copy characters from dstfilename$ to filename
;        lda disk.copyfile.dstfilename$
;        sta $ae
;        lda disk.copyfile.dstfilename$+1
;        sta $af
;        ldy #$00
;        ldx #$00
;@dstloop
;        lda ($ae),y
;        cmp #console.null$
;        beq @dstdone
;        sta disk.execmd.name,x
;        iny
;        inx
;        jmp @dstloop
;@dstdone
;        sty disk.copyfile.dstlen

;        ; Append "="
;        lda #61
;        sta disk.execmd.name,x
;        inx

;        ; Copy characters from srcfilename$ to filename
;        lda disk.copyfile.srcfilename$
;        sta $ae
;        lda disk.copyfile.srcfilename$+1
;        sta $af
;        ldy #$00
;@srcloop
;        lda ($ae),y
;        cmp #console.null$
;        beq @srcdone
;        sta disk.execmd.name,x
;        iny
;        inx
;        jmp @srcloop
;@srcdone
;        sty disk.copyfile.srclen

;        ; len = dstlen + srclen + 3(C0:) + 1(=)
;        lda #4
;        clc
;        adc disk.copyfile.dstlen
;        adc disk.copyfile.srclen
;        sta disk.execmd.len

        ; Execute the command
        jmp disk.execmd2

disk.renamefile.oldfilename$ = $20 ; 2 bytes
disk.renamefile.newfilename$ = $22 ; 2 bytes
disk.renamefile$

        ; Set the prefix command "r"
        lda #"r"
        sta disk.execmd.filename

        ; Execute the command
        jmp disk.execmd2


disk.execmd2.filename1 = $20 ; 2 bytes
disk.execmd2.filename2 = $22 ; 2 bytes
disk.execmd2.len1 = $24 ; 1 byte
disk.execmd2.len2 = $25 ; 1 byte
disk.execmd2

        ; Confirm that filename1 exists
;        jsr disk.fileexists$
;        bne @FileExists
;        lda #diskerror.file_not_found$
;        sta disk.error$
;        rts
;@FileExists
        ; Confirm that filename1 exists
        jsr disk.fileexists$
        lda disk.error$
        cmp #diskerror.ok$
        beq @FileExistOk
        rts
@FileExistOk
        lda disk.fileexists.exists$
        bne @FileExists
;        beq @FileNoExists
;        jmp @FileExists
;@FileNoExists
        lda #diskerror.file_not_found$
        sta disk.error$
        rts
@FileExists

        ; Copy characters from dstfilename$ to filename
        lda disk.execmd2.filename2
        sta $ae
        lda disk.execmd2.filename2+1
        sta $af
        ldy #$00
        ldx #$00
@dstloop
        lda ($ae),y
        cmp #console.null$
        nop
        nop
        nop
        ;beq @dstdone
        bne @dstcont
        jmp @dstdone
@dstcont
        sta disk.execmd.name,x
        iny
        inx
        jmp @dstloop
@dstdone
        sty disk.execmd2.len2

        ; Append "="
        lda #61
        sta disk.execmd.name,x
        inx

        ; Copy characters from srcfilename$ to filename
        lda disk.execmd2.filename1
        sta $ae
        lda disk.execmd2.filename1+1
        sta $af
        ldy #$00
@srcloop
        lda ($ae),y
        cmp #console.null$
        beq @srcdone
        sta disk.execmd.name,x
        iny
        inx
        jmp @srcloop
@srcdone
        sty disk.execmd2.len1

        ; len = dstlen + srclen + 3(C0:) + 1(=)
        lda #4
        clc
        adc disk.execmd2.len2
        adc disk.execmd2.len1
        sta disk.execmd.len

        ; Execute the command
        jmp disk.execmd

disk.loadfile.filename$ = $20 ; 2 bytes
disk.loadfile$

        ;lda #$fe
        ;sta disk.readfile.address$
        ;lda #$bf
        ;sta disk.readfile.address$+1
        lda #$00
        sta disk.readfile.address$
        lda #$c0
        sta disk.readfile.address$+1
        jsr disk.readfile$

        lda disk.error$
        beq @ok
        jmp @error

@ok
        ;jmp $c000
        jsr kernel.end
        ;pla
        ;pla
        ;jmp kernel.begin
        jsr kernel.begin
        jsr kernel.reset$

@error
        rts

#endregion

#region Printer

printer.prev_devcice    byte $00

printer.error$ byte $00
printererror.ok$                     = 00
printererror.open_error$             = 01
printererror.print_error$            = 02

printer.carriage_return$        = $0d
printer.line_feed$              = $0a
printer.null$                   = $ff
printer.lower_case$             = 17
printer.upper_case$             = 145

printer.printstr.address$ = $20 ; 2 bytes
printer.printstr$

        lda $ba
        sta printer.prev_devcice

        ; Set default values
        lda #printererror.ok$
        sta printer.error$

        lda #$04      ; file number 4
        ldx #$04      ; default to device 4
        ldy #$04      ; secondary address 4
        jsr $ffba     ; call setlfs

        jsr $ffc0     ; call open
        bcc @ok

        lda #printererror.open_error$
        sta printer.error$

        jmp @close    ; even if OPEN failed, the file has to be closed
@ok

        ldx #$04      ; filenumber 4
        jsr $ffc9     ; call CHKOUT (file 4 now used as output)

        ; Set the memory address
        lda printer.printstr.address$
        sta $ae
        lda printer.printstr.address$+1
        sta $af

@loop
        ldy #$00
        ldx #$08
        jsr $ffb7     ; call READST (read status byte)
        ;;bne @eof      ; either EOF or read error
        ;beq @cont
        jmp @cont 
@writeerror

        lda #printererror.print_error$
        sta printer.error$

        jmp @close
        
@cont
        lda ($ae),y   ; get byte from memory
        cmp #printer.null$
        bne @chrout
        jmp @close

@chrout
        jsr $ffd2     ; call CHROUT (write byte to file)

        ;nop
        ;nop
@inc_mem
        ; Increment memory address
        inc $ae
        bne @skip2
        inc $af
@skip2  

        jmp @loop     ; next byte

@close
        lda #$04      ; filenumber 4
        jsr $ffc3     ; call CLOSE

        jsr $ffcc     ; call CLRCHN

        lda printer.prev_devcice
        sta $ba

        rts


#endregion

#region Mouse

mouse.oldx byte $00
mouse.oldy byte $00

mouse.getstate.leftbutton$ = $7a ; 1 byte
mouse.getstate.rightbutton$ = $7b ; 1 byte
mouse.getstate.deltax$ = $7c ; 1 byte
mouse.getstate.deltay$ = $7d ; 1 byte
mouse.getstate$
        ;https://codebase64.org/doku.php?id=base:c_1351_standard_mouse_routine

        lda #%00010000
        jsr mouse.buttoncheck
        sta mouse.getstate.leftbutton$

        lda #%00000001
        jsr mouse.buttoncheck
        sta mouse.getstate.rightbutton$

        lda $d419
        ;lsr  //CCS64 fix (remove for other emus/real HW)
        ldy mouse.oldx
        jsr mouse.movecheck
        sty mouse.oldx
        sta mouse.getstate.deltax$

        lda $d41a
        ;lsr  //CCS64 fix (remove for other emus/real HW)
        ldy mouse.oldy
        jsr mouse.movecheck
        sty mouse.oldy
        sec  ; modify y position ( decrease y for increase in pot )
        eor #$ff
        adc #$00
        sta mouse.getstate.deltay$

        rts

mouse.buttoncheck.buttonmask = $7e ; 1 byte
mouse.buttoncheck
        sta mouse.buttoncheck.buttonmask

        lda $dc01 ; port 1
        and mouse.buttoncheck.buttonmask
        cmp mouse.buttoncheck.buttonmask
        
        bne @SetBtn
        lda #$00
        rts

@SetBtn
        lda #$01
        rts

mouse.movecheck.olddelta = $7e ; 1 byte
mouse.movecheck.newdelta = $7f ; 1 byte
mouse.movecheck
        sty mouse.movecheck.olddelta
        sta mouse.movecheck.newdelta
        ldx #0

        sec
        sbc mouse.movecheck.olddelta
        and #%01111111      
        cmp #%01000000
        bcs @movchk1
        lsr
        beq @movchk2
        ldy mouse.movecheck.newdelta
        rts

@movchk1
        ora #%11000000
        cmp #$ff
        beq @movchk2
        sec
        ror
        ldx #$ff
        ldy mouse.movecheck.newdelta
        rts
@movchk2
        lda #0
        rts

#endregion

#region Serial

serial.prev_device      byte $00
serial.discard_byte$    byte $00 ; Set to one to have the first first of each send/recv call to be discarded
serial.recv_eot$        byte $00 ; Set to one to have the recv routine wait for the eot byte - chr$(13)
serial.send_eot$        byte $00 ; Set to one to have the send routine to send the eot byte - chr$(13)

serial.eot$    = $ff
serial.skip    = $fe
;serial.eot2    = $7f
;serial.skip2   = $7e
;serial.args    text 08, 00 ; 1200 BaudRate, No Parity, 8 DataBits, 1 StopBit, Dtr Not Enabled, Rts Not Enabled, No Handshake
;serial.args    text 08
serial.baud$   byte $08 ; 1200
        ; See https://www.commodore.ca/manuals/c64_programmers_reference/c64-programmers_reference_guide-06-input_output_guide.pdf (page 349)
;        0 0 0 1 50 BAUD
;        0 0 1 0 75
;        0 0 1 1 110
;        0 1 0 0 134.5
;        0 1 0 1 150
;        0 1 1 0 300 (6)
;        0 1 1 1 600
;        1 0 0 0 1200 (8)
;        1 0 0 1 (1800) 2400 (9)
;        1 0 1 0 2400 (10)
;        1 0 1 1 3600 [NI]
;        1 1 0 0 4800 [NI]
;        1 1 0 1 7200 [NI)
;        1 1 1 0 9600 [NI] (14)
;        1 1 1 1 19200 [NI]
;serial.baud_50$         = $01
;serial.baud_75$         = $02
;serial.baud_110$        = $03
;serial.baud_135$        = $04
;serial.baud_150$        = $05
serial.baud_300$        = $06
serial.baud_600$        = $07
serial.baud_1200$       = $08
;serial.baud_1800$       = $09
;serial.baud_2400$       = $0a
;serial.baud_3600$       = $0b
;serial.baud_4800$       = $0c
;serial.baud_7200$       = $0d
serial.baud_9600$       = $0e
;serial.baud_19200$       = $0f

;serial.open$

;        jsr serial.set_baud

;        lda $ba
;        sta serial.prev_device

;        ; Need to close the file first because of a bug in Covert Bitops when used with SD2IEC!
;        lda #$05      ; filenumber 5
;        ;nop
;        ;nop
;        jsr $ffc3     ; call CLOSE
;        ;nop
;        ;nop
;        ;nop

;        ;lda #2
;        lda #1
;        ldx #<serial.baud$
;        ldy #>serial.baud$
;        jsr $ffbd     ; call SETNAM

;        lda #$05      ; file number 5
;        ldx #$02      ; default to device 2
;        ldy #$00      ; secondary address 0
;        jsr $ffba     ; call SETLFS

;        jsr $ffc0     ; call OPEN

;        ; Set the RS232 input timer
;        ;poke665,73-(peek(678)*30)
;        lda 678 ; 0=NTSC, 1=PAL
;        beq @poke_665_73
;        lda #43
;        jmp @sta_665
;@poke_665_73
;        lda #73
;@sta_665
;        sta 665

;        rts

;serial.close$
;        lda #$05      ; filenumber 5
;        jsr $ffc3     ; call CLOSE

;        jsr $ffcc     ; call CLRCHN

;        lda serial.prev_device
;        sta $ba

;        rts

serial.close$
        lda #$05      ; filenumber 5
        jsr $ffc3     ; call CLOSE

        jsr $ffcc     ; call CLRCHN

        lda serial.prev_device
        sta $ba

        rts

serial.set_baud
        lda serial.baud$
        
;        cmp #serial.baud_2400$ ; 10 = 2400
;        bne @not_2400
;        jsr T2400.setup
;        jmp @set_baud
;@not_2400

        cmp #serial.baud_9600$ ; 14 = 9600
        bne @not_9600
        jsr UP9600.INIT
        jmp @set_baud
@not_9600

@set_baud
        sta $0293
        rts


serial.send.address$ = $22 ; 2 bytes
serial.send$

        lda serial.send.address$       ; set buffer address
        sta $ae
        lda serial.send.address$+1
        sta $af

        ldx #$05      ; filenumber 5
        jsr $ffc9     ; call CHKOUT (file 5 now used as output)

@send

        lda serial.discard_byte$
        beq @no_discard
        lda #serial.skip
        jsr $ffd2     ; throw away first byte
@no_discard

        ldy #$00
@wloop   
        lda ($ae),y   ; get byte from memory

        cmp #serial.eot$
        bne @wjsr
        lda serial.send_eot$
        beq @wend
        lda #13
        jsr $ffd2
        jmp @wend
@wjsr
        jsr $ffd2     ; call CHROUT (write byte to file)
        
        ;cmp #serial.eot$
        ;beq @wend

        ;lda serial.check_for_eot$
        ;beq @wend

        iny
        beq @wend
        jmp @wloop
@wend

        ldx #$03      ; filenumber 3 (screen output)
        jsr $ffc9     ; call CHKOUT (file 3 now used as output)

        rts

serial.recv.address$ = $22 ; 2 bytes
serial.recv.first_byte byte $00
serial.recv$

        lda serial.recv.address$       ; set buffer address
        sta $ae
        lda serial.recv.address$+1
        sta $af

        lda #$00
        sta serial.recv.first_byte
        
        ldx #$05      ; filenumber 5
        jsr $ffc6     ; call CHKIN (file 5 now used as input)
        
        ;lda $0297 ; Is the RS-232 input buffer empty or stop bit present
        ;and #%00001010
        ;beq @buffer_ok
        ;jmp @done

@buffer_ok

        lda serial.discard_byte$
        beq @no_discard
        jsr $ffcf     ; throw away first byte
@no_discard

        ldy #$00
@rloop   

        lda serial.recv.first_byte
        bne @chrin_wait
        jmp @chrin_no_wait

@chrin_wait
        jsr $ffcf     ; call CHRIN (get a byte from file)
        inc serial.recv.first_byte
        jmp @chin_done

@chrin_no_wait
        ;jsr $ffcf     ; call CHRIN (get a byte from file)
        JSR $F14E

        tax
        lda $0297
        ;and #%00001010 ; Is the RS-232 input buffer empty or stop bit present
        and #%00001000 ; Is the RS-232 input buffer empty
        beq @buffer_ok2

        lda serial.recv_eot$
        bne @chrin_no_wait

        jmp @done
@buffer_ok2

        ;lda #$01
        ;sta serial.recv.first_byte
        txa

@chin_done

;        cmp #13
;        bne @rjsr
;        lda #serial.eot$
;@rjsr

        ;beq @rend    ; No data

        sta ($ae),y   ; write byte to memory

        cmp #10
        bne @rinc
        lda serial.recv_eot$
        bne @rend
        ;cmp #serial.eot2
        ;beq @rend

        ;lda serial.wait_for_eot$
        ;beq @done

@rinc
        iny
        beq @done
        jmp @rloop     ; next byte
@rend
        lda #serial.eot$
        sta ($ae),y

@done
        ldx #$03      ; filenumber 3
        jsr $ffc6     ; call CHKIN (file 3 now used as input)

        rts


#endregion

*=$5000

convert.str2ascii.str$ = $e0 ; 2 bytes
convert.str2ascii$

        lda convert.str2ascii.str$
        sta $ae
        lda convert.str2ascii.str$+1
        sta $af

@skip

        ldy #$00
@Loop
        lda ($ae),y

        cmp #console.null$
        beq @Null_Yes
        jmp @Null_No
@Null_Yes
        jmp @Done
@Null_No

        cmp #console.newline$
        beq @NewLine_Yes
        jmp @NewLine_No
@NewLine_Yes
        lda #13
        jmp @NextChar
@NewLine_No

        cmp #console.backspace$
        beq @BackSpace_Yes
        jmp @BackSpace_No
@BackSpace_Yes

        lda #20

        jmp @NextChar
@BackSpace_No

        cmp #$01
        bcs @Alpha1 ; A >= $01
        jmp @NotAlpha1
@Alpha1
        cmp #$1b
        bcc @Alpha2 ; A < $1b
        jmp @NotAlpha2
@Alpha2
        clc
        ;adc #$40
        adc #$60
        jmp @NextChar
@NotAlpha1
@NotAlpha2

;        cmp #$41
;        bcs @Alpha12 ; A >= $41
;        jmp @NotAlpha12
;@Alpha12
;        cmp #$5b
;        bcc @Alpha22 ; A < $5b
;        jmp @NotAlpha22
;@Alpha22
;        clc
;        adc #$20
;        jmp @NextChar
;@NotAlpha12
;@NotAlpha22

@NextChar
        sta ($ae),y

        inc $ae
        beq @inc_af
        jmp @Loop
@inc_af
        inc $af
        jmp @Loop

@Done

        lda #$ff
        sta ($ae),y

        rts

convert.ascii2str.ascii$ = $e0 ; 2 bytes
convert.ascii2str$

        lda convert.ascii2str.ascii$
        sta $ae
        lda convert.ascii2str.ascii$+1
        sta $af

@skip

        ldy #$00
@Loop
        lda ($ae),y

        cmp #$ff
        beq @Null_Yes
        jmp @Null_No
@Null_Yes
        jmp @Done
@Null_No

        cmp #10
        beq @Skip_Yes
        jmp @Skip_No
@Skip_Yes
        lda '-'
        jmp @NextChar
@Skip_No

        cmp #13
        beq @NewLine_Yes
        jmp @NewLine_No
@NewLine_Yes
        lda #console.newline$
        jmp @NextChar
@NewLine_No

        cmp #20
        beq @BackSpace_Yes
        jmp @BackSpace_No
@BackSpace_Yes

;        lda #console.backspace$
;        sta console.writechr.char$
;        jsr console.writechr$

;        lda #' '
;        sta console.writechr.char$
;        jsr console.writechr$

        lda #console.backspace$

        jmp @NextChar
@BackSpace_No

;        cmp #$41
;        bcs @Alpha1 ; A >= $41
;        jmp @NotAlpha1
;@Alpha1
;        cmp #$5b
;        bcc @Alpha2 ; A < $5b
;        jmp @NotAlpha2
;@Alpha2
;        sec
;        sbc #$40
;        jmp @NextChar
;@NotAlpha1
;@NotAlpha2

        cmp #$61
        bcs @Alpha12 ; A >= $61
        jmp @NotAlpha12
@Alpha12
        cmp #$7b
        bcc @Alpha22 ; A < $7b
        jmp @NotAlpha22
@Alpha22
        sec
        ;sbc #$20
        sbc #$60
        jmp @NextChar
@NotAlpha12
@NotAlpha22

@NextChar
        sta ($ae),y

        inc $ae
        beq @inc_af
        jmp @Loop
@inc_af
        inc $af
        jmp @Loop

@Done

        lda #console.null$
        sta ($ae),y

        rts


#region Ram Expansion Unit (REU)

; https://codebase64.org/doku.php?id=base:reu_programming

reu.status   = $df00
reu.command  = $df01
reu.c64base  = $df02
reu.reubase  = $df04
reu.translen = $df07
reu.irqmask  = $df09
reu.control  = $df0a

reu.isinstalled.value$ = $fb ; 1 byte
reu.isinstalled$
        lda #$00
        sta reu.isinstalled.value$ ; set default value

        ; If the value put into the c64base address stays then there is a REU installed.
        lda #$01
        sta reu.c64base
        lda reu.c64base
        beq @done
        sta reu.isinstalled.value$
@done
        rts

reu.transferdata.c64address = $fb ; 2 bytes
reu.transferdata.reuaddress = $8b ; 3 bytes
reu.transferdata.length = $fd ; 2 bytes
reu.transferdata.command = $2a ; 1 byte
reu.transferdata.orglength = $57 ; 2 bytes
reu.transferdata

        ; We need to determine whether or not the reubase 3rd and highest byte
        ; is going to wrap, if so we need to perform a second transfer
        lda reu.transferdata.reuaddress
        sta math.add24.addend1$
        lda reu.transferdata.reuaddress+1
        sta math.add24.addend1$+1
        lda reu.transferdata.reuaddress+2
        sta math.add24.addend1$+2
        lda reu.transferdata.length
        sta math.add24.addend2$
        lda reu.transferdata.length+1
        sta math.add24.addend2$+1
        lda #0
        sta math.add24.addend2$+2
        jsr math.add24$
        lda math.add24.sum$+2
        cmp reu.transferdata.reuaddress+2
        bne @wrapped
        jmp reu.transferdata.setregisters
@wrapped

        ; At this point there will be a wrap so we need to perform
        ; two separate transfers

        ; Copy the original length
        lda reu.transferdata.length
        sta reu.transferdata.orglength
        lda reu.transferdata.length+1
        sta reu.transferdata.orglength+1

        ; $010000 - rue.transferdata.reuaddress(16 bits) = 1st new length
        lda #$00
        sta math.subtract24.menuend$
        sta math.subtract24.menuend$+1
        lda #$01
        sta math.subtract24.menuend$+2
        lda reu.transferdata.reuaddress
        sta math.subtract24.subtrahend$
        lda reu.transferdata.reuaddress+1
        sta math.subtract24.subtrahend$+1
        lda #$00
        sta math.subtract24.subtrahend$+2
        jsr math.subtract24$
        lda math.subtract24.difference$
        sta reu.transferdata.length
        lda math.subtract24.difference$+1
        sta reu.transferdata.length+1
        
        ; Perform the first transfer
        jsr reu.transferdata.setregisters
        

        ; The C64 will do this for us!
;        ; Need to increase reu.transferdata.c64address by 1st new length
;        lda reu.c64base
;        sta math.add16.addend1$
;        lda reu.c64base+1
;        sta math.add16.addend1$+1
;        lda reu.translen
;        sta math.add16.addend2$
;        lda reu.translen+1
;        sta math.add16.addend2$+1
;        jsr math.add16$
;        lda math.add16.sum$
;        sta reu.c64base
;        lda math.add16.sum$+1
;        sta reu.c64base+1
        lda reu.c64base
        sta reu.transferdata.c64address
        lda reu.c64base+1
        sta reu.transferdata.c64address+1

        ; original length - 1st new length = 2nd new length
        lda reu.transferdata.orglength
        sta math.subtract16.menuend$
        lda reu.transferdata.orglength+1
        sta math.subtract16.menuend$+1
        lda reu.transferdata.length
        sta math.subtract16.subtrahend$
        lda reu.transferdata.length+1
        sta math.subtract16.subtrahend$+1
        jsr math.subtract16$
        lda math.subtract16.difference$
        sta reu.transferdata.length
        lda math.subtract16.difference$+1
        sta reu.transferdata.length+1

        ; Set the reu.transferdata.reuaddress to the next 24-bit page
        lda #0
        sta reu.transferdata.reuaddress
        sta reu.transferdata.reuaddress+1
        inc reu.transferdata.reuaddress+2

        ; Fall through to the code below

reu.transferdata.setregisters
        lda #0
        sta reu.control ; to make sure both addresses are counted up

        lda reu.transferdata.c64address
        sta reu.c64base
        lda reu.transferdata.c64address+1
        sta reu.c64base+1

        lda reu.transferdata.reuaddress
        sta reu.reubase
        lda reu.transferdata.reuaddress+1
        sta reu.reubase+1
        lda reu.transferdata.reuaddress+2
        sta reu.reubase+2

        lda reu.transferdata.length
        sta reu.translen
        lda reu.transferdata.length+1
        sta reu.translen+1

;reu.transferdata.setcommand

        lda reu.transferdata.command
        sta reu.command

        rts

reu.savedata.c64address$ = $fb ; 2 bytes
reu.savedata.reuaddress$ = $8b ; 3 bytes
reu.savedata.length$ = $fd ; 2 bytes
reu.savedata$
        lda #%10010000;  C64 -> REU with immediate execution
        sta reu.transferdata.command
        jmp reu.transferdata

reu.loaddata.c64address$ = $fb ; 2 bytes
reu.loaddata.reuaddress$ = $8b ; 3 bytes
reu.loaddata.length$ = $fd ; 2 bytes
reu.loaddata$
        lda #%10010001;  REU -> C64 with immediate execution
        sta reu.transferdata.command
        jmp reu.transferdata

reu.swapdata.c64address$ = $fb ; 2 bytes
reu.swapdata.reuaddress$ = $8b ; 3 bytes
reu.swapdata.length$ = $fd ; 2 bytes
reu.swapdata$
        lda #%10010010;  C64 <-> REU with immediate execution
        sta reu.transferdata.command
        jmp reu.transferdata

reu.comparedata.c64address$ = $fb ; 2 bytes
reu.comparedata.reuaddress$ = $8b ; 3 bytes
reu.comparedata.length$ = $fd ; 2 bytes
reu.comparedata.isequal$ = $02 ; 1 bytes
reu.comparedata$
        lda #$00
        sta reu.comparedata.isequal$ ; set default value

        lda #%10010011;  C64 - REU with immediate execution
        sta reu.transferdata.command
        jsr reu.transferdata

        ;Bit 5:     FAULT  (1 = block verify error)
        ;           Set if a difference between C64- and REU-memory areas was found
        ;           during a compare-command.
        lda reu.status
        and #%00100000
        bne @done ; If not equal to 0 then there was a fault (difference)
        lda #$01
        sta reu.comparedata.isequal$
@done
        rts

#endregion

#region Interrupt Requests (IRQ)

;irq.raterline$ byte 210
irq.raterline$ byte 140

irq.address     word $000
irq.oldaddress  word $000
irq.install.address$ = $fb ; 2 bytes
irq.install$
        sei        ;disable maskable IRQs

        lda irq.install.address$
        sta irq.address
        lda irq.install.address$+1
        sta irq.address+1        

        lda $fffe
        sta irq.oldaddress
        lda $ffff
        sta irq.oldaddress+1

        lda #$7f
        sta $dc0d  ;disable timer interrupts which can be generated by the two CIA chips
        sta $dd0d  ;the kernal uses such an interrupt to flash the cursor and scan the keyboard, so we better
                   ;stop it.

        lda $dc0d  ;by reading this two registers we negate any pending CIA irqs.
        lda $dd0d  ;if we don't do this, a pending CIA irq might occur after we finish setting up our irq.
                   ;we don't want that to happen.

        lda #$01   ;this is how to tell the VICII to generate a raster interrupt
        sta $d01a

        lda irq.raterline$ ;this is how to tell at which rasterline we want the irq to be triggered
        sta $d012

        lda #$1b   ;as there are more than 256 rasterlines, the topmost bit of $d011 serves as
        sta $d011  ;the 9th bit for the rasterline we want our irq to be triggered.
                   ;here we simply set up a character screen, leaving the topmost bit 0.

        lda #$35   ;we turn off the BASIC and KERNAL rom here
        sta $01    ;the cpu now sees RAM everywhere except at $d000-$e000, where still the registers of
                   ;SID/VICII/etc are visible

        lda #<irq.handler  ;this is how we set up
        sta $fffe  ;the address of our interrupt code
        lda #>irq.handler
        sta $ffff

        cli        ;enable maskable interrupts again

        rts

irq.uninstall$
        sei        ;disable maskable IRQs

        lda #$81
        sta $dc0d  ;disable timer interrupts which can be generated by the two CIA chips
        sta $dd0d  ;the kernal uses such an interrupt to flash the cursor and scan the keyboard, so we better
                   ;stop it.

        lda $dc0d  ;by reading this two registers we negate any pending CIA irqs.
        lda $dd0d  ;if we don't do this, a pending CIA irq might occur after we finish setting up our irq.
                   ;we don't want that to happen.

        lda #$00   ;this is how to tell the VICII to generate a raster interrupt
        sta $d01a

        lda irq.raterline$ ;this is how to tell at which rasterline we want the irq to be triggered
        sta $d012

        lda #$1b   ;as there are more than 256 rasterlines, the topmost bit of $d011 serves as
        sta $d011  ;the 9th bit for the rasterline we want our irq to be triggered.
                   ;here we simply set up a character screen, leaving the topmost bit 0.

        lda #$35   ;we turn off the BASIC and KERNAL rom here
        sta $01    ;the cpu now sees RAM everywhere except at $d000-$e000, where still the registers of
                   ;SID/VICII/etc are visible

        lda irq.oldaddress
        sta $fffe  ;the address of our interrupt code
        lda irq.oldaddress+1
        sta $ffff

        cli        ;enable maskable interrupts again


        lda #$36 ; Bank switch BASIC ROM into RAM
        sta $01

        rts

irq.handler
        sta @atemp+1
        stx @xtemp+1
        sty @ytemp+1

        ; This is how to do an indirect JSR
        lda #>@return   ; Because the stack works backwards you need to push first then hi then lo address
        pha
        lda #<@return
        pha
        jmp (irq.address)
@return
        nop             ; Because RTS adds 1 to the return address we put this NOP as a place holder.

        lsr $d019    ;as stated earlier this might fail only on exotic HW like c65 etc.
                   ;lda #$ff sta $d019 is equally fast, but uses two more bytes and
                   ;trashes A
@atemp 
        lda #$00
@xtemp 
        ldx #$00
@ytemp 
        ldy #$00

        rti        ;Return From Interrupt, this will load into the Program vcounter register the address
                   ;where the CPU was when the interrupt condition arised which will make the CPU continue
                   ;the code it was interrupted at also restores the status register of the CPU
irq.disable$
        sei
        rts

irq.enable$
        cli
        rts

#endregion

;align $100 ; Align the Main entry point
*=$c000

 