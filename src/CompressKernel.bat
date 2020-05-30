REM Run this from the src folder
..\bin\exomizer.exe level ..\bin\kernel.prg -o ..\bin\kernele.prg
..\bin\dasm.exe kernel.s -o..\bin\loader.prg -v3 -p3
