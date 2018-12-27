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
	
	; Holds the color code of the current chosen color
	; The color can be chosen programmatically by the developer or by the user
	; Optional values are 0h - 0Fh
	color db 0
	
	; startX, startY, endX and endY are used in the DisplayRectangle procedure
	; They allow the developer to create a rectangle with any dimensions he wants

	; Represents the top left point of the rectangle
	startX dw 0
	startY dw 0

	; Represents the bottom right point of the rectangle
	endX dw 0
	endY dw 0
	
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


; Displays a line in the length of the whole screen
proc DisplayFullLine
DisplayDotLoop:
	call DisplayDot
	inc cx
	
	cmp cx, 320
	jne DisplayDotLoop
	
	mov cx, 0
	inc dx
	
	ret
endp DisplayFullLine


; Clears the screen
; Loops over all the pixels and makes them white line by line using DisplayFullLine procedure
proc ClearScreen
	mov [color], 0Fh

	mov cx, 0
	mov dx, 0
	
DisplayLineLoop:
	call DisplayFullLine
	
	cmp dx, 200
	jne DisplayLineLoop

	mov dx, 0
	ret
endp ClearScreen


; Inits the mouse and displays a cursor
proc InitMouse
	mov ax, 0
	int 33h

	mov ax, 1
	int 33h

	ret
endp InitMouse


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
	mov [color], 9

	mov [startX], 0
	mov [endX], 40

	mov [startY], 160
	mov [endY], 180

	call DisplayRectangle

	mov [color], 4

	mov [startX], 0
	mov [endX], 40

	mov [startY], 180
	mov [endY], 200

	call DisplayRectangle

	ret
endp DisplayEraser


; Displays the options bar
; Displays each block that makes up the options bar using DisplayRectangle
; The blocks are currently:
; 1) Escape button
; 2) Clear screen button
proc DisplayOptionsBar
	mov [color], 7

	mov [startX], 0
	mov [startY], 0

	mov [endX], 320
	mov [endY], 20

	call DisplayRectangle

	; Escape Button
	mov [color], 4

	mov [startX], 5
	mov [startY], 5

	mov [endX], 15
	mov [endY], 15

	call DisplayRectangle

	; Clear Screen Button
	mov [color], 0Fh

	mov [startX], 20
	mov [startY], 5

	mov [endX], 30
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
	mov [color], 0Fh
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

	cmp cx, 30
	jbe ClearScreenClicked

	jmp GetMouseLoop

ClearScreenClicked:
	mov ah, 0
	mov al, [color]

	push ax
		mov [color], 0Fh

		mov [startX], 0
		mov [endX], 320

		mov [startY], 20
		mov [endY], 160

		call DisplayRectangle
	pop ax

	mov [color], al

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
	call ClearScreen
	call DisplayOptionsBar
	call DisplayColors
	call DisplayEraser
	call InitMouse
	
	call HandleUserInput
END Start