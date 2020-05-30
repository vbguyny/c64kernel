incasm "kernel.hdr"
;incasm "kernel.asm"

; NOTE: If you are using an enumator, ensure that the RS232 is enabled 
; prior to running this demo.

main

@loop
        jsr console.clear$

        ;jsr disk.reset$

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

PleaseWait

        lda #<wait
        sta console.writestr.straddress$
        lda #>wait
        sta console.writestr.straddress$+1
        jsr console.writestr$

        rts

OpenMsg

        lda #<open
        sta console.writestr.straddress$
        lda #>open
        sta console.writestr.straddress$+1
        jsr console.writestr$

        rts

CloseMsg

        lda #<close
        sta console.writestr.straddress$
        lda #>close
        sta console.writestr.straddress$+1
        jsr console.writestr$

        rts

SendMsg

        lda #<send
        sta console.writestr.straddress$
        lda #>send
        sta console.writestr.straddress$+1
        jsr console.writestr$

        rts

RecvMsg

        lda #<recv
        sta console.writestr.straddress$
        lda #>recv
        sta console.writestr.straddress$+1
        jsr console.writestr$

        rts

DoneMsg

        lda #<done
        sta console.writestr.straddress$
        lda #>done
        sta console.writestr.straddress$+1
        jsr console.writestr$

        rts

Do1

        ; Note: In order to run this demo you need to have one of the two environments:
        ; 1. An emulator that has RS232 support (such as VICE) along with 
        ;    a null modem driver (such as com0com) and a server on the workstation
        ;    which can receive the incoming communications (such as NullEchoServer).
        ; 
        ; 2. An actual C64 which has an adapter for user port to RS232/COM which
        ;    is connected to a PC which is running a server which can process 
        ;    the incoming communications (such as NullEchoServer).

        ; Note: the C64 will freeze if it cannot send any data to the server.

        ; Note: Although RS232 supports all characters, when communicating with 
        ; the server it is best to only use upper-cased characters.

        ; Note: The Kernel routines are hardcoded to transfer data at 1200 baud.
        
        ; Note: Due to a weird bug with how the C64 handles serial communications
        ; the kernel will discard the first byte. You don't need to do any
        ; special coding here but this fact needs to be known if you plan
        ; on writting your own server.  It is best to refer to the source for
        ; NullEchoServer.

        jsr console.clear$

        lda #$01
        sta serial.discard_byte$
        sta serial.send_eot$
        sta serial.recv_eot$

        ; Prompt for string
        lda #<sendtxt
        sta console.writestr.straddress$
        lda #>sendtxt
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr console.readstr$
        lda console.readstr.straddress$
        sta sendstr
        lda console.readstr.straddress$+1
        sta sendstr+1

        jsr console.writeln$
        jsr console.writeln$

        ; Open connection
        jsr OpenMsg

        jsr time.halt$ ; Need to add this otherwise the open msg prints after the open finishes.

        jsr serial.open$
        
        jsr DoneMsg

        ; Send string to server
        jsr SendMsg

        lda sendstr
        sta serial.send.address$
        lda sendstr+1
        sta serial.send.address$+1
        jsr serial.send$

        jsr DoneMsg

        ; Receive response from server

        jsr RecvMsg

        lda #$ff
        sta memory.allocate.length$
        lda #$00
        sta memory.allocate.length$+1
        jsr memory.allocate$
        lda memory.allocate.address$
        sta recvstr
        lda memory.allocate.address$+1
        sta recvstr+1
        
        lda recvstr
        sta serial.recv.address$
        lda recvstr+1
        sta serial.recv.address$+1
        jsr serial.recv$

        jsr DoneMsg

        ; Close connection
        jsr CloseMsg

        jsr serial.close$

        jsr DoneMsg

        ; Display response
        lda #<recvtxt
        sta console.writestr.straddress$
        lda #>recvtxt
        sta console.writestr.straddress$+1
        jsr console.writestr$

        lda recvstr
        sta console.writestr.straddress$
        lda recvstr+1
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr PressAnyKey

        ; Deallocate strings
        lda sendstr
        sta memory.deallocate.address$
        lda sendstr+1
        sta memory.deallocate.address$+1
        jsr memory.deallocate$

        lda recvstr
        sta memory.deallocate.address$
        lda recvstr+1
        sta memory.deallocate.address$+1
        jsr memory.deallocate$

        rts

Do2

        ; Note: In order to run this demo you need to have one of the two environments:
        ; 1. An emulator that has RS232 support (such as VICE) along with 
        ;    a null modem driver (such as com0com) and a server on the workstation
        ;    which can receive the incoming communications (such as NullModemServer).
        ; 
        ; 2. An actual C64 which has an adapter for user port to RS232/COM which
        ;    is connected to a PC which is running a server which can process 
        ;    the incoming communications (such as NullEchoServer).

        ; Note: the C64 will freeze if it cannot send any data to the server.

        ; Note: Although RS232 supports all characters, when communicating with 
        ; the server it is best to only use upper-cased characters.

        ; Note: The Kernel routines are hardcoded to transfer data at 1200 baud.
        
        jsr console.clear$

        lda #<inf1
        sta console.writestr.straddress$
        lda #>inf1
        sta console.writestr.straddress$+1
        jsr console.writestr$
        
        ; Allocate buffer
        lda #$ff
        sta memory.allocate.length$
        lda #$00
        sta memory.allocate.length$+1
        jsr memory.allocate$
        lda memory.allocate.address$
        sta resp
        lda memory.allocate.address$+1
        sta resp+1

        lda #8 ; 8 = 1200
        sta serial.baud$

        jsr serial.open$ ; open5,2,0,chr$(8):poke665,73-(peek(678)*30)
        
        lda #$00
        sta serial.recv_eot$
        sta serial.discard_byte$
        lda #$01
        sta serial.send_eot$      

        ; print#5,"at&p1e1"
        lda #<msg1
        sta serial.send.address$
        lda #>msg1
        sta serial.send.address$+1
        jsr serial.send$

        ; print#5,"at&p1e1"
        jsr serial.send$

        lda #$00
        sta serial.discard_byte$
        sta serial.send_eot$
        sta serial.recv_eot$

@get_data

        ; Reset the buffer
        lda resp
        sta memory.fill.address$
        lda resp+1
        sta memory.fill.address$+1
        lda #serial.eot$
        sta memory.fill.value$
        lda #$ff
        sta memory.fill.length$
        jsr memory.fill$

        lda resp
        sta serial.recv.address$
        lda resp+1
        sta serial.recv.address$+1
        jsr serial.recv$ ; get#5,a$

        jsr ProcessResp

@print_resp ; printa$
        lda resp
        sta console.writestr.straddress$
        lda resp+1
        sta console.writestr.straddress$+1
        jsr console.writestr$

@get_char
        ; geta$
        jsr ReadKey
        bcc @print_requ
        jmp @get_data

@print_requ ; print#5,a$;

        sta requ ; Store the key pressed

        cmp #$1f ; left arrow
        beq @Done

        lda #<requ
        sta serial.send.address$
        lda #>requ
        sta serial.send.address$+1
        jsr serial.send$

        jmp @get_data

@Done

        ; Close the serial connection
        jsr serial.close$

        ; Deallocate the buffer
        lda resp
        sta memory.deallocate.address$
        lda resp+1
        sta memory.deallocate.address$+1
        jsr memory.deallocate$

        jsr PressAnyKey

        rts

align $100

ReadKey.Prev    byte $00

ReadKey
        ; Read the key from the keyboard
        jsr console.readkey$

        ; Determine if anything was pressed
        lda console.readkey.state$
        cmp #console.readkey.state.ok$
        beq @StateOk
        
        ; Clear the previous key press
        lda #$00
        sta ReadKey.Prev

        sec
        rts
@StateOk

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
        
        lda console.readkey.char$
        cmp #$01
        bcs @Alpha1 ; A >= $01
        jmp @End
@Alpha1
        cmp #$1b
        bcc @Alhpa2 ; A < $1b
        jmp @End
@Alhpa2
        
        clc
        adc #$40
        jmp @End

@ShiftPressed
        ; If a valid character was pressed while the shift key was pressed,
        ; return the upper-cased version of the character
        ldx console.readkey.char$
        lda console.getkey.KeyTableShift$,x
        cmp #console.readkey.char.invalid$
        bne @ShiftOk
        sec 
        rts
@ShiftOk
        clc
        ;adc #$40
        jmp @End2

@CheckSpecial
        ; If the return key is pressed, return null
        lda console.readkey.shift1$
        cmp #console.readkey.shift1.return$
        beq @ReturnNull
        cmp #console.readkey.shift1.insert_delete$
        beq @ReturnBackSpace

        sec
        rts

@ReturnNull
        lda #13
        jmp @Wait

@ReturnBackSpace
        
        lda #console.backspace$
        lda #20
        jmp @Wait

@Wait
        ;pha
        ;jsr time.halt$
        ;jsr time.halt$
        ;jsr time.halt$
        ;pla
@End

        ; Check to see if same key was previously pressed
        cmp ReadKey.Prev
        bne @Ok
        sec
        rts
@Ok
        sta ReadKey.Prev

@End2

        clc
        rts

align $100

ProcessResp

        lda resp
        sta $ae
        lda resp+1
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
        lda #'-'
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

        lda #console.backspace$
        sta console.writechr.char$
        jsr console.writechr$

        lda #' '
        sta console.writechr.char$
        jsr console.writechr$

        lda #console.backspace$

        jmp @NextChar
@BackSpace_No

        cmp #$41
        bcs @Alpha1 ; A >= $41
        jmp @NotAlpha1
@Alpha1
        cmp #$5b
        bcc @Alpha2 ; A < $5b
        jmp @NotAlpha2
@Alpha2
        sec
        sbc #$40
        jmp @NextChar
@NotAlpha1
@NotAlpha2

        cmp #$61
        bcs @Alpha12 ; A >= $41
        jmp @NotAlpha12
@Alpha12
        cmp #$7b
        bcc @Alpha22 ; A < $7b
        jmp @NotAlpha22
@Alpha22
        sec
        sbc #$20
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

        rts


title   text 'Serial', console.newline$, console.newline$
        text 'Please select one of the options below:', console.newline$, console.null$

options text '1. Send/Receive (Echo)', console.newline$
        text '2. Modem Test', console.newline$
        text 'x. Exit', console.newline$
        text console.null$

anykey  text 'Press any key to go back', console.null$

filename word $0000
fnnext  text 'DEMO0-X', console.null$
fnback  text 'MAIN', console.null$
failed  text 'Failed to load ', console.null$

wait    text console.newline$, 'Please wait... ', console.null$
done    text 'Done!', console.newline$, console.newline$, console.null$

open    text 'Opening connection... ', console.null$
close   text 'Closing connection... ', console.null$
send    text 'Sending data... ', console.null$
recv    text 'Receiving data... ', console.null$

sendtxt text 'Enter some text: ', console.null$
sendstr word $0000
recvtxt text 'Received from server: ', console.null$
recvstr word $0000

inf1    text 'Press ', $1f, ' (End) to go exit.', console.newline$, console.null$
msg1    text "at&p1e1", serial.eot$
requ    text $00, serial.eot$
resp    word $0000
