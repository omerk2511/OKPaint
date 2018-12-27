# OKPaint
Welcome to OKPaint! My final project in Assembly 8086

OKPaint is my version of MSPaint for the DOS operating system

![Welcome Screen](https://raw.githubusercontent.com/omerk2511/OKPaint/master/Screenshots/welcome.png)
![Main Screen](https://raw.githubusercontent.com/omerk2511/OKPaint/master/Screenshots/main.png)

## How to use it?
 - Install TASM (Turbo Assembler)
   - You can install TASM here: [TASM Download](data.cyber.org.il/assembly/TASM.rar)
   - Just put it under C:\
 - Download OKPaint
   - Download it from this repository
   - Put it under C:\tasm\bin\
 - Install DosBox
   - You can install DosBox here: [DosBox Download](https://www.dosbox.com/download.php?main=1)
 - Enter DosBox
 - Enter to the command line:
 ```
 mount c: c:\
 c:
 cd tasm
 cd bin
 cycles = max 
 tasm /zi okpaint.asm
 tlink /v okpaint.obj
 ```
 - Then, just enter `okpaint` to run it!

Enjoy!
