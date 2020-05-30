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

;        cmp #'9'
;        bne @not9
;        jsr Do9
;@not9

;        cmp #'0'
;        bne @not0
;        jsr Do0
;@not0

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

ErrorMsg
        ; A contains the disk error.
        ; See diskerror for list of possible errors.
        sta derror

        jsr audio.beep$

        lda #color.red$
        sta console.setcharactercolor.color$
        jsr console.setcharactercolor$

        lda #<error
        sta console.writestr.straddress$
        lda #>error
        sta console.writestr.straddress$+1
        jsr console.writestr$

        lda derror
        sta console.writeint8.integer$
        jsr console.writeint8$

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

DoneMsg

        lda #<done
        sta console.writestr.straddress$
        lda #>done
        sta console.writestr.straddress$+1
        jsr console.writestr$

        rts

align $100

Do1

        jsr console.clear$

        jsr PleaseWait

        jsr disk.getdiskinfo$

        lda disk.error$
        cmp #diskerror.ok$
        beq @ok
        jmp ErrorMsg
@ok

        jsr DoneMsg

        lda #<dname
        sta console.writestr.straddress$
        lda #>dname
        sta console.writestr.straddress$+1
        jsr console.writestr$

        lda #<disk.getdiskinfo.label$
        sta console.writestr.straddress$
        lda #>disk.getdiskinfo.label$
        sta console.writestr.straddress$+1
        jsr console.writestr$
        jsr console.writeln$

        lda #<dblocks
        sta console.writestr.straddress$
        lda #>dblocks
        sta console.writestr.straddress$+1
        jsr console.writestr$

        lda disk.getdiskinfo.blocksfree$
        sta console.writeint16.integer$
        lda disk.getdiskinfo.blocksfree$+1
        sta console.writeint16.integer$+1
        jsr console.writeint16$
        jsr console.writeln$

        jsr PressAnyKey

        rts

Do2

        ; NOTE: Setting the filename to 0 will return all of the files
        ; This is the same as passing * as the filename.
        ; You can do wildcard searches for files using * and ? characters.
        ; All filenames must be uppercased.

        jsr console.clear$

        ; Prompt for search file name
        lda #<fsearch
        sta console.writestr.straddress$
        lda #>fsearch
        sta console.writestr.straddress$+1
        jsr console.writestr$
        
        ; Get the string from the console
        jsr console.readstr$
        lda console.readstr.straddress$
        sta fname
        lda console.readstr.straddress$+1
        sta fname+1
        jsr console.writeln$

        jsr PleaseWait

        ; If the length is 0 then nothing was entered
        lda fname
        sta string.getlength.address$
        lda fname+1
        sta string.getlength.address$+1
        jsr string.getlength$

        lda string.getlength.length$
        cmp #$00
        beq @NoFileName
        
        ; Set the arguments and get the file information
        lda fname
        sta disk.getfileinfo.filename$
        lda fname+1
        sta disk.getfileinfo.filename$+1
        jmp @GetFileInfo
@NoFileName
        lda #$00
        sta disk.getfileinfo.filename$
        sta disk.getfileinfo.filename$+1
@GetFileInfo
        jsr disk.getfileinfo$

        ; Check for error
        lda disk.error$
        cmp #diskerror.ok$
        beq @PrintTitle
        jmp ErrorMsg

@PrintTitle

        jsr DoneMsg

        jsr console.writeln$

        lda #<fptitle
        sta console.writestr.straddress$
        lda #>fptitle
        sta console.writestr.straddress$+1
        jsr console.writestr$
        jsr console.writeln$

@CheckFile

        ; Check to see if there are any more valid files
        lda disk.getfileinfo.type$
        cmp #diskfiletypes.none$
        bne @FileOk
        jmp @Done

@FileOk

;        lda #<fpbuf
;        sta memory.fill.address$
;        lda #>fpbuf
;        sta memory.fill.address$+1
;        lda #' '
;        sta memory.fill.value$
;        lda #17
;        sta memory.fill.value$+1
;        jsr memory.fill$
;        
;        lda #<disk.getfileinfo.name$
;        sta memory.copy.source$
;        lda #>disk.getfileinfo.name$
;        sta memory.copy.source$+1
;        lda #<fpbuf
;        sta memory.copy.destination$
;        lda #>fpbuf
;        sta memory.copy.destination$+1
;        lda #16
;        sta memory.copy.length$
;        jsr memory.copy$

        lda #0
        sta console.setcolumn.column$
        jsr console.setcolumn$

        lda #<disk.getfileinfo.name$
        sta console.writestr.straddress$
        lda #>disk.getfileinfo.name$
        sta console.writestr.straddress$+1
        jsr console.writestr$

        lda #17
        sta console.setcolumn.column$
        jsr console.setcolumn$

        lda disk.getfileinfo.blocks$
        sta console.writeint8.integer$
        jsr console.writeint8$

        lda #25
        sta console.setcolumn.column$
        jsr console.setcolumn$

        lda disk.getfileinfo.type$
        cmp #diskfiletypes.prg$
        bne @NotPrg
        ldx #<prg
        ldy #>prg
        jmp @PrintType
@NotPrg
        cmp #diskfiletypes.seq$
        bne @NotSeq
        ldx #<seq
        ldy #>seq
        jmp @PrintType
@NotSeq
        cmp #diskfiletypes.usr$
        bne @NotUsr
        ldx #<usr
        ldy #>usr
        jmp @PrintType
@NotUsr
        cmp #diskfiletypes.rel$
        bne @NotRel
        ldx #<rel
        ldy #>rel
        jmp @PrintType
@NotRel
        cmp #diskfiletypes.del$
        bne @NotDel
        ldx #<del
        ldy #>del
        jmp @PrintType
@NotDel
        ldx #<unk
        ldy #>unk

@PrintType
        stx console.writestr.straddress$
        sty console.writestr.straddress$+1
        jsr console.writestr$

        jsr console.writeln$


        ; Get the next file info
        jsr disk.getnextfileinfo$

        jmp @CheckFile

@Done
        jsr disk.getfileinfoclose$

        lda fname
        sta memory.deallocate.address$
        lda fname+1
        sta memory.deallocate.address$+1
        jsr memory.deallocate$

        jsr PressAnyKey

        rts

Do3

        ; Note that any zero byte data will NOT created a file.

        jsr console.clear$

        ; Prompt user to enter some text
        lda #<wtext
        sta console.writestr.straddress$
        lda #>wtext
        sta console.writestr.straddress$+1
        jsr console.writestr$
        
        ; Get the text from the console
        jsr console.readstr$
        lda console.readstr.straddress$
        sta wstr
        lda console.readstr.straddress$+1
        sta wstr+1

        jsr console.writeln$

        jsr PleaseWait

        ; Get the length of the text
        lda wstr
        sta string.getlength.address$
        lda wstr+1
        sta string.getlength.address$+1
        jsr string.getlength$

        ; Write the text to disk
        lda string.getlength.length$
        sta disk.writefile.length$
        lda string.getlength.length$+1
        sta disk.writefile.length$+1
        lda #<wname
        sta disk.writefile.filename$
        lda #>wname
        sta disk.writefile.filename$+1
        lda wstr
        sta disk.writefile.address$
        lda wstr+1
        sta disk.writefile.address$+1
        jsr disk.writefile$

        ; Check for errors
        lda disk.error$
        cmp #diskerror.ok$
        beq @Ok
        jmp ErrorMsg
@Ok

        jsr DoneMsg

        jsr PressAnyKey

        lda wstr
        sta memory.deallocate.address$
        lda wstr+1
        sta memory.deallocate.address$+1
        jsr memory.deallocate$

        rts

Do4

        ; Note that any zero byte data will NOT created a file.

        jsr console.clear$

        jsr PleaseWait

        ; Create a string with a length of 255 characters
        lda #$ff
        sta string.create.length$
        lda #$00
        sta string.create.length$+1
        lda #console.null$
        sta string.create.character$
        jsr string.create$
        lda string.create.address$
        sta rstr
        lda string.create.address$+1
        sta rstr+1        

        ; Read the file from disk
        lda #<rname
        sta disk.readfile.filename$
        lda #>rname
        sta disk.readfile.filename$+1
        lda rstr
        sta disk.readfile.address$
        lda rstr+1
        sta disk.readfile.address$+1
        jsr disk.readfile$

        ; Check for errors
        lda disk.error$
        cmp #diskerror.ok$
        beq @Ok
        jmp ErrorMsg
@Ok

        jsr DoneMsg

        lda #<rtext
        sta console.writestr.straddress$
        lda #>rtext
        sta console.writestr.straddress$+1
        jsr console.writestr$

        ; Show the file contents to the screen
        lda rstr
        sta console.writestr.straddress$
        lda rstr+1
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr console.writeln$

        jsr PressAnyKey

        lda rstr
        sta memory.deallocate.address$
        lda rstr+1
        sta memory.deallocate.address$+1
        jsr memory.deallocate$

        rts

Do5

        jsr console.clear$

        ; Indicate which file is going to be deleted
        lda #<stext
        sta console.writestr.straddress$
        lda #>stext
        sta console.writestr.straddress$+1
        jsr console.writestr$
        lda #<sname
        sta console.writestr.straddress$
        lda #>sname
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr console.writeln$

        jsr PleaseWait

        ; Scratch/delete the file
        lda #<sname
        sta disk.scratchfile.filename$
        lda #>sname
        sta disk.scratchfile.filename$+1
        jsr disk.scratchfile$

        ; Check for errors
        lda disk.error$
        cmp #diskerror.ok$
        beq @Ok
        jmp ErrorMsg
@Ok

        jsr DoneMsg
        jsr PressAnyKey
        
        rts

Do6

        jsr console.clear$

        ; Indicate which file is going to be copied
        lda #<ctext1
        sta console.writestr.straddress$
        lda #>ctext1
        sta console.writestr.straddress$+1
        jsr console.writestr$
        lda #<cname1
        sta console.writestr.straddress$
        lda #>cname1
        sta console.writestr.straddress$+1
        jsr console.writestr$

        ; Indicate where the file is going to be copied to
        lda #<ctext2
        sta console.writestr.straddress$
        lda #>ctext2
        sta console.writestr.straddress$+1
        jsr console.writestr$
        lda #<cname2
        sta console.writestr.straddress$
        lda #>cname2
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr console.writeln$

        jsr PleaseWait

        ; Delete the destination file first for demo purposes
        lda #<cname2
        sta disk.scratchfile.filename$
        lda #>cname2
        sta disk.scratchfile.filename$+1
        jsr disk.scratchfile$

;        ; Confirm that the source file exists
;        ldx #<cname1
;        ldy #>cname1
;        jsr FileExists
;        bne @OkExists
;        lda #diskerror.file_not_found$
;        jmp ErrorMsg
;@OkExists

        ; Copy the file
        lda #<cname1
        sta disk.copyfile.srcfilename$
        lda #>cname1
        sta disk.copyfile.srcfilename$+1
        lda #<cname2
        sta disk.copyfile.dstfilename$
        lda #>cname2
        sta disk.copyfile.dstfilename$+1
        jsr disk.copyfile$

        ; Check for errors
        lda disk.error$
        cmp #diskerror.ok$
        beq @Ok
        jmp ErrorMsg
@Ok

        jsr DoneMsg

        jsr PressAnyKey
        
        rts

Do7

        jsr console.clear$

        ; Indicate which file is going to be renamed
        lda #<rtext1
        sta console.writestr.straddress$
        lda #>rtext1
        sta console.writestr.straddress$+1
        jsr console.writestr$
        lda #<rname1
        sta console.writestr.straddress$
        lda #>rname1
        sta console.writestr.straddress$+1
        jsr console.writestr$

        ; Indicate what the file is going to be renamed to
        lda #<rtext2
        sta console.writestr.straddress$
        lda #>rtext2
        sta console.writestr.straddress$+1
        jsr console.writestr$
        lda #<rname2
        sta console.writestr.straddress$
        lda #>rname2
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr console.writeln$

        jsr PleaseWait

        ; Delete the new file first for demo purposes
        lda #<rname2
        sta disk.scratchfile.filename$
        lda #>rname2
        sta disk.scratchfile.filename$+1
        jsr disk.scratchfile$

        ; Rename the file
        lda #<rname1
        sta disk.renamefile.oldfilename$
        lda #>rname1
        sta disk.renamefile.oldfilename$+1
        lda #<rname2
        sta disk.renamefile.newfilename$
        lda #>rname2
        sta disk.renamefile.newfilename$+1
        jsr disk.renamefile$

        ; Check for errors
        lda disk.error$
        cmp #diskerror.ok$
        beq @Ok
        jmp ErrorMsg
@Ok

        jsr DoneMsg

        jsr PressAnyKey
        
        rts


Do8
        ; You can do wildcard searches for files using * and ? characters.
        ; All filenames must be uppercased.

        jsr console.clear$

        ; Prompt for search file name
        lda #<fsearch
        sta console.writestr.straddress$
        lda #>fsearch
        sta console.writestr.straddress$+1
        jsr console.writestr$
        
        ; Get the string from the console
        jsr console.readstr$
        lda console.readstr.straddress$
        sta fname
        lda console.readstr.straddress$+1
        sta fname+1
        jsr console.writeln$

        jsr PleaseWait

        lda fname
        sta disk.fileexists.filename$
        lda fname+1
        sta disk.fileexists.filename$+1
        jsr disk.fileexists$

        ; Check for error
        lda disk.error$
        cmp #diskerror.ok$
        beq @PrintTitle
        jmp ErrorMsg

@PrintTitle

        jsr DoneMsg

        jsr console.writeln$

        lda disk.fileexists.exists$
        cmp #$01
        beq @FileExists
        jmp @FileNoExists
@FileExists

        lda #<fexists
        sta console.writestr.straddress$
        lda #>fexists
        sta console.writestr.straddress$+1
        jsr console.writestr$
        jsr console.writeln$

        jmp @Done

@FileNoExists

        lda #<fnoex
        sta console.writestr.straddress$
        lda #>fnoex
        sta console.writestr.straddress$+1
        jsr console.writestr$
        jsr console.writeln$

@Done

        lda fname
        sta memory.deallocate.address$
        lda fname+1
        sta memory.deallocate.address$+1
        jsr memory.deallocate$

        jsr PressAnyKey

        rts

;Do9

;        jsr console.clear$

;        jsr console.writeln$

;        jsr PleaseWait

;        ; Validate the disk
;        jsr disk.validate$

;        ; Check for errors
;        lda disk.error$
;        cmp #diskerror.ok$
;        beq @Ok
;        jmp ErrorMsg
;@Ok

;        jsr DoneMsg
;        jsr PressAnyKey
;        
;        rts

;Do0

;        jsr console.clear$

;        jsr console.writeln$

;        jsr PleaseWait

;        ; Reset the drive
;        jsr disk.reset$

;        ; Check for errors
;        lda disk.error$
;        cmp #diskerror.ok$
;        beq @Ok
;        jmp ErrorMsg
;@Ok

;        jsr DoneMsg
;        jsr PressAnyKey
;        
;        rts


title   text 'Disk', console.newline$, console.newline$
        text 'Please select one of the options below:', console.newline$, console.null$

options text '1. Get Disk Info', console.newline$
        text '2. Get File Info', console.newline$
        text '3. Write File', console.newline$
        text '4. Read File', console.newline$
        text '5. Scratch File', console.newline$
        text '6. Copy File', console.newline$
        text '7. Rename File', console.newline$
        text '8. File Exists', console.newline$
;        text '9. Validate Disk', console.newline$
;        text '0. Reset Drive', console.newline$
        text 'x. Exit', console.newline$
        text console.null$

anykey  text 'Press any key to go back', console.null$

filename word $0000
fnnext  text 'DEMO8-X', console.null$
fnback  text 'MAIN', console.null$
failed  text 'Failed to load ', console.null$

error   text 'Error ', console.null$
derror  byte $00
wait    text console.newline$, 'Please wait... ', console.null$
done    text 'Done!', console.newline$, console.newline$, console.null$

dname   text 'Disk Label: ', console.null$
dblocks text 'Blocks Free: ', console.null$

fsearch text 'Enter the name to search: ', console.null$
fname   word $0000
fptitle text 'Filename         Blocks  Type', console.null$
fpbuf   text '                 000     ???', console.null$
prg     text 'PRG', console.null$
seq     text 'SEQ', console.null$
usr     text 'USR', console.null$
rel     text 'REL', console.null$
del     text 'DEL', console.null$
unk     text '???', console.null$


wname   text 'FILEDEMO', console.null$
wtext   text 'Enter some text: ', console.newline$, console.null$
wstr    word $0000

rname   text 'FILEDEMO', console.null$
rtext   text 'File contents: ', console.newline$, console.null$
rstr    word $0000

sname   text 'FILEDEMO', console.null$
stext   text 'Deleting file ', console.null$

cname1  text 'FILEDEMO', console.null$
cname2  text 'FILEDEMO2', console.null$
ctext1  text 'Copying file ', console.null$
ctext2  text ' to ', console.null$

rname1  text 'FILEDEMO', console.null$
rname2  text 'FILEDEMO2', console.null$
rtext1  text 'Renaming file ', console.null$
rtext2  text ' to ', console.null$

fexists text 'File exists', console.null$
fnoex   text 'File does NOT exist', console.null$

