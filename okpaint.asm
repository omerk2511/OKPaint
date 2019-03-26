; OKPaint - A paint program for DOS operating system
; Made by Omer Katz AKA MagnuM

IDEAL
MODEL small
STACK 100h
DATASEG
	; Holds the value of the welcome message
	welcome db 13, 10, 13, 10, 13, 10
			db '      ________  ___  __    ________  ________  ___  ________   __________', 13, 10
			db '     |\   __  \|\  \|\  \ |\   __  \|\   __  \|\  \|\   ___  \|\___   ___\ ', 13, 10
			db '     \ \  \|\  \ \  \/  /|\ \  \|\  \ \  \|\  \ \  \ \  \\ \  \|___ \  \_|', 13, 10
			db '      \ \  \\\  \ \   ___  \ \   ____\ \   __  \ \  \ \  \\ \  \   \ \  \ ', 13, 10
			db '       \ \  \\\  \ \  \\ \  \ \  \___|\ \  \ \  \ \  \ \  \\ \  \   \ \  \ ', 13, 10
			db '        \ \_______\ \__\\ \__\ \__\    \ \__\ \__\ \__\ \__\\ \__\   \ \__\ ', 13, 10
			db '         \|_______|\|__| \|__|\|__|     \|__|\|__|\|__|\|__| \|__|    \|__|', 13, 10, 13, 10, 13, 10, 13, 10
			db '                              Enter to continue...', 13, 10, '$'
	
	; Holds the value of the title of the program
	; The title is displayed in the top bar of the program
	; Must end with '$'
	okpaintTitle db 'OKPaint$'

	; Holds the value of the save button text
	; This text is displayed in the top bar of the program
	; Must end with '$'
	saveButtonText db 'Save$'

	; Holds the color code of the current chosen color
	; The color can be chosen programmatically by the developer or by the user
	; Optional values are 0 - 255
	color db 0
	
	; startX, startY, endX and endY are used in the DisplayRectangle procedure
	; They allow the developer to create a rectangle with any dimensions he wants

	; Represents the top left point of the rectangle
	startX dw 0
	startY dw 0

	; Represents the bottom right point of the rectangle
	endX dw 0
	endY dw 0

	; char, charRow and charColumn are used in the DisplayChar procedure 

	; char is the char needed to be displayed
	char db 0

	; charRow and charColumn represent the location of the char
	charRow db 0
	charColumn db 0

	; Holds the color code of the char color to be displayed
	; Optional values are 0h - 0Fh
	charColor db 0

	; Holds the name of the image that is saved and loaded
	imageName db 'image.bmp', 0

	; Holds the file handler that is currently used for I/O operations
	filehandler dw ?

	; Holds the header of the BMP file
	header db 54 dup (0)

	; Holds the color palette of the BMP file
	palette db 256*4 dup (0)

	; Holds each screen line that is loaded from the BMP file
	scrLine db 320 dup (0)

	; Holds the error message
	; This message is printed when there is an I/O exception
	errorMsg db 'I/O Error. Please try again. Make sure that image.bmp exists.', 13, 10,'$'
	
CODESEG
; Prints the welcome message to the screen
proc PrintWelcome
	mov ah, 9h
	lea dx, [welcome]
	int 21h

	ret
endp PrintWelcome


; Switches to graphics mode
proc SwitchToGraphicsMode
	mov ax, 13h
	int 10h
	
	ret
endp SwitchToGraphicsMode


; Switches to text mode
proc SwitchToTextMode
	mov ax, 2
	int 10h
	
	ret
endp SwitchToTextMode


; Waits for any key
; Used to enter the program from the welcome screen
proc WaitForKey
	mov ah, 0
	int 16h
	
	ret
endp WaitForKey


; Exits the program
proc Exit
	mov ax, 4c00h
	int 21h

	ret
endp Exit


; Displays a dot
; The color is taken from the color variable
; The x and y coordinates are taken from cx and dx
proc DisplayDot
	mov al, [color]
	mov bl, 0

	mov ah, 0Ch
	int 10h
	
	ret
endp DisplayDot


; Initializes the mouse and displays a cursor
proc InitMouse
	mov ax, 0
	int 33h

	mov ax, 1
	int 33h

	ret
endp InitMouse


; Opens the file at [imageName]
; The filehandler id is put at [filehandler]
proc OpenFile
	mov ah, 3Dh
	xor al, al
	lea dx, [imageName]

	int 21h
	jc OpenError

	mov [filehandler], ax

	ret

OpenError:
	mov dx, offset errorMsg
	mov ah, 9h
	int 21h

	ret
endp OpenFile


; Reads the BMP file header from [filehandler] into [header]
proc ReadHeader
	mov ah, 3Fh
	mov bx, [filehandler]
	mov cx, 54
	lea dx, [header]

	int 21h

	ret
endp ReadHeader


; Reads the BMP file header from [filehandler] into [palette]
proc ReadPalette
	mov ah, 3Fh
	mov cx, 400h
	lea dx, [palette]

	int 21h

	ret
endp ReadPalette


; Copies the color palette from [palette] into the video memory
proc CopyPalette
	lea si, [palette]
	mov cx, 256
	mov dx, 3C8h
	xor al, al

	out dx, al
	inc dx

PaletteLoop:
	; Red
	mov al, [si+2]
	shr al, 2
	out dx, al

	; Green
	mov al, [si+1]
	shr al, 2
	out dx, al

	; Blue
	mov al, [si]
	shr al, 2
	out dx, al

	; Next color in the palette
	add si, 4
	loop PaletteLoop

	ret
endp CopyPalette


; Displays the actual image that is loaded from [filehandler]
; Displays line by line
proc CopyBitmap
	mov ax, 0A000h
	mov es, ax
	mov cx, 200

PrintBMPLoop:
	push cx
		mov di, cx
		shl cx, 6
		shl di, 8
		add di,cx
		
		mov ah, 3Fh
		mov cx, 320
		lea dx,[scrLine]

		int 21h

		cld
		mov cx,320
		lea si, [scrLine]
		rep movsb
	pop cx

	loop PrintBMPLoop

	ret
endp CopyBitmap


; Loads the image from [imageName] into the screen
; Should be called when the program is first run to continue drawing from last use
proc LoadImage
	call OpenFile
	call ReadHeader
	call ReadPalette
	call CopyPalette
	call CopyBitmap

	ret
endp LoadImage


; Saves the current screen into [filehandler]
proc SaveImage
	ret
endp SaveImage


; Displays a line
; Starts at the variable startX and ends in endX
; Height should be stored at dx
proc DisplayLine
	mov cx, [startX]
	
DisplayDotOnScreen:
	call DisplayDot
	
	inc cx
	cmp cx, [endX]
	jne DisplayDotOnScreen

	ret
endp DisplayLine


; Displays a rectangle
; Starts at the variables startX and startY and ends in endX and endY
; Displays the rectangle line by line using DisplayLine procedure
; It's the most important procedure! It's the base procedure to all displaying
proc DisplayRectangle
	mov dx, [startY]
	
DisplayLineOnScreen:
	call DisplayLine
	
	inc dx
	cmp dx, [endY]
	jne DisplayLineOnScreen

	ret
endp DisplayRectangle


; Displays a char
; Char should be in the char variable
; Row and column should be in the charRow and charColumn variables
; Char color should be in the charColor variable
proc DisplayChar
	mov ah, 3
	mov bh, 0

	int 10h

	push dx
		mov ah, 2

		mov dh, [charRow]
		mov dl, [charColumn]

		int 10h

		mov ah, 9

		mov al, [char]
		mov bl, [charColor]

		mov cx, 1

		int 10h
	pop dx

	mov ah, 2
	int 10h

	ret
endp DisplayChar


; Clears the screen
; Displays a white area in the drawing area
proc ClearScreen
	mov [color], 0Fh

	mov [startX], 0
	mov [endX], 320

	mov [startY], 20
	mov [endY], 160

	call DisplayRectangle

	ret
endp ClearScreen


; Displays the list of the optional 7 color
; Displays each color in its own block using DisplayRectangle
proc DisplayColors
	mov [color], 0

	mov [startX], 40
	mov [endX], 80

	mov [startY], 160
	mov [endY], 200

DisplayColor:
	call DisplayRectangle
	
	inc [color]
	add [startX], 40
	add [endX], 40
	
	cmp [color], 7
	jne DisplayColor

	ret
endp DisplayColors


; Displays the eraser
; Displays two blocks that make up the eraser using DisplayRectangle
proc DisplayEraser
	mov [color], 87

	mov [startX], 0
	mov [endX], 40

	mov [startY], 160
	mov [endY], 180

	call DisplayRectangle

	mov [color], 217

	mov [startX], 0
	mov [endX], 40

	mov [startY], 180
	mov [endY], 200

	call DisplayRectangle

	ret
endp DisplayEraser


; Displays text in the top bar of the screen
; The text you want to display must end with '$'
; You should first push the address of the text and then the starting position
proc DisplayText
	textAddress equ [bp+6]
	startingPlace equ [bp+4]

	push bp
		mov bp, sp

		mov bx, textAddress

		mov [charRow], 1

		mov al, startingPlace
		mov [charColor], 246

	DisplayCharLoop:
		mov ah, [byte ptr bx]
		mov [char], ah

		mov [charColumn], al

		push bx
			push ax
				call DisplayChar
			pop ax
		pop bx

		inc al
		inc bx

		cmp [byte ptr bx], '$'
		jne DisplayCharLoop

	pop bp

	ret 4
endp DisplayText


; Displays the options bar
; Displays each block that makes up the options bar using DisplayRectangle
; The blocks are currently:
; 1) Escape button
; 2) Clear screen button
proc DisplayOptionsBar
	mov [color], 0

	mov [startX], 0
	mov [startY], 0

	mov [endX], 320
	mov [endY], 20

	call DisplayRectangle

	; Escape Button
	mov [color], 14

	mov [startX], 5
	mov [startY], 5

	mov [endX], 15
	mov [endY], 15

	call DisplayRectangle

	; OKPaint Title
	push offset okpaintTitle
	push 3

	call DisplayText

	; Save Button Text
	push offset saveButtonText
	push 33

	call DisplayText

	; Clear Screen Button
	mov [color], 246

	mov [startX], 305
	mov [startY], 5

	mov [endX], 315
	mov [endY], 15

	call DisplayRectangle

	ret
endp DisplayOptionsBar


; Switches the current color
; Based on the value of cx, it chooses the color that matches that place
proc SwitchColor
	cmp cx, 41
	jb Choose0

	cmp cx, 81
	jb Choose1

	cmp cx, 121
	jb Choose2

	cmp cx, 161
	jb Choose3

	cmp cx, 201
	jb Choose4

	cmp cx, 241
	jb Choose5

	cmp cx, 281
	jb Choose6

	jmp Choose7

Choose0:
	mov [color], 246
	jmp EndSwitchColorProc

Choose1:
	mov [color], 0
	jmp EndSwitchColorProc

Choose2:
	mov [color], 1
	jmp EndSwitchColorProc

Choose3:
	mov [color], 2
	jmp EndSwitchColorProc

Choose4:
	mov [color], 3
	jmp EndSwitchColorProc

Choose5:
	mov [color], 4
	jmp EndSwitchColorProc

Choose6:
	mov [color], 5
	jmp EndSwitchColorProc

Choose7:
	mov [color], 6

EndSwitchColorProc:
	ret
endp SwitchColor


; Handles the user input, the main procedure of the program
; It checks every moment if the mouse is pressed
; If it's pressed, it gives one of the following responses:
; 1) If the cursor is on one of the colors, it switches the color
; 2) If the cursor is on the escape key, it switches back to text mode and exits the program
; 3) Else, it draws a block of 2X2 in the cursor's position
proc HandleUserInput
	mov [color], 0

GetMouseLoop:
	mov ax, 3
	int 33h

	cmp bx, 1
	jne GetMouseLoop

	shr cx, 1

	cmp dx, 160
	jae SwitchColorClicked

	cmp dx, 20
	jbe TopPartClicked

DisplayPaintedRegtangle:
	sub cx, 1
	mov [startX], cx

	add cx, 2
	mov [endX], cx

	sub dx, 1
	mov [startY], dx

	add dx, 2
	mov [endY], dx

	call DisplayRectangle
	jmp GetMouseLoop

SwitchColorClicked:
	call SwitchColor
	jmp GetMouseLoop

TopPartClicked:
	cmp cx, 15
	jbe EscapeClicked

	cmp cx, 305
	jae ClearScreenClicked

	cmp cx, 260
	jae SaveImageClicked

	jmp GetMouseLoop

ClearScreenClicked:
	mov ah, 0
	mov al, [color]

	push ax
		call ClearScreen
	pop ax

	mov [color], al

	jmp GetMouseLoop

SaveImageClicked:
	call SaveImage
	jmp GetMouseLoop

EscapeClicked:
	call SwitchToTextMode
	call Exit
endp HandleUserInput

Start:
	mov ax, @data
	mov ds, ax
	
	call SwitchToTextMode
	call PrintWelcome
	call WaitForKey
	
	call SwitchToGraphicsMode
	call LoadImage
	call DisplayOptionsBar
	call DisplayColors
	call DisplayEraser
	call InitMouse
	
	call HandleUserInput
END Start