# How to make PRG files

1. Launch CBM prg Studio and open the C64Kernel.cbmprj.
2. Select the asm files and press F6 in the following order:
	- kernel.asm (Save to ..\bin\kernel.prg)
	- logo.asm (Save to ..\bin\kernel.prg)
	- Run BuildKernelHeader.bat
	- demo(0-9).asm (Save to ..\bin\demo(0-9).prg)
3. Run CompressKernel.bat
4. Open the file ..\bin\demo.d64 in DirMaster.
5. Delete the PRG files that have been updated in the bin folder
6. Drag the updated PRG files from bin into the D64 file, including the loader.prg and kernele.prg files.
7. Save the image.

# Note about RS232 emulation and the NullModemServer

At the time of implementing the serial routines, I couldn't find a good program that could simulate a modem compatible with the Hayes AT commands. You could use "tcpser" but I found it to be highly limited.  Therefore, I wrote my own program in C# which emulates the modem (specifically, WiFi64).

Note that this is a "null" modem which means that you need to have a software null modem (such as com0com) to have VICE connect to the NullModemServer.

NullModemServer is hard coded to connect to COM4, so you should have the com0com connect COM4 and COM3 together and then configure VICE to use Serial1 to connect to com3 at 1200 baud.
