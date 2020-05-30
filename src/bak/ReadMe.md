# How to make PRG files



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
incasm "..\src\kernel.hdr"

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

# Required Programs

- IDE: CBM .prg Studio (https://www.ajordison.co.uk)
- Emulator: VICE (https://vice-emu.sourceforge.io)
- Tools: Visual Studio .NET (https://visualstudio.microsoft.com/vs/features/net-development/)

# License

MIT License

Copyright (c) 2020 vbguyny

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
