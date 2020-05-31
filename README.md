# VBGuyNY C64 Kernel

A custom kernel written in assembly created for the Commodore 64.

![VBGuyNY C64 Kernel](https://raw.githubusercontent.com/vbguyny/c64kernel/master/doc/c64k.png)

# How to Run

Attach the image file demo.d64 either to an emulater (such as VICE) or load it to a disk and insert it into an actual Commodore 64.
Type the following command after the READY. prompt and press return.

```
LOAD"*",8,1
```

# Sample Program

You can build a simple PRG file using the following code. The code below will include the kernel in the PRG file and make it very large (atleast 187 blocks).

```
incasm "..\src\kernel.asm"

main

        jsr console.clear$

        lda #<msg
        sta console.writestr.straddress$
        lda #>msg
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr console.readchr$
        lda console.readchr.char$

        rts

msg     text 'Hello world!', console.newline$, console.null$
```

You can alternately you can build a PRG file using the just the header (recommended). The resulting PRG will be much smaller but you will need to add it to a D64 image (bin\boilerplate.d64) that has the the Kernel already loaded with the logo.

```
; Compile to "main.prg"
incasm "kernel.hdr"

main

        jsr console.clear$

        lda #<msg
        sta console.writestr.straddress$
        lda #>msg
        sta console.writestr.straddress$+1
        jsr console.writestr$

        jsr console.readchr$
        lda console.readchr.char$

        rts

msg     text 'Hello world!', console.newline$, console.null$
```

Refer to the Docs for additional information.

# Minimum Requirements

- OS: Windows 7 32 bit
- Emulator: Any Commodore 64 emulater
- Tools: .NET Framework 4.5 or later

# Recommended Requirements

- OS: Windows 10 64 bit
- IDE: CBM .prg Studio (https://www.ajordison.co.uk)
- Emulator: VICE (https://vice-emu.sourceforge.io)
- Image: DirMaster (https://style64.org/dirmaster)
- Tools: Visual Studio .NET (https://visualstudio.microsoft.com/vs/features/net-development/)
- RS232: Virtual serial port driver for null modems. 

# Hardware Requirements

* Only needed if you are planning on running on an actual Commodore 64!

- Commodore 64 or 64C (NTSC/PAL)
- Optional Epyx Fast Load
- If using serial communation, modem compatible with Hayes AT commands (example, Wifi64)

# License

MIT License

Copyright (c) 2019-2020 vbguyny

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
