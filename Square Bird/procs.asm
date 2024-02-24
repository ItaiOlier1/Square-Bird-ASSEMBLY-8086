

									;the procs of the game : SQUARE BIRD





;-------------------------Graphic mode-------------------------	
;move to graphic mode
proc graphicMode
	mov ax, 13h
	int 10h
ret
endp graphicMode
	
	
	
;-------------------------text mode-------------------------
;move to graphic mode
proc textMode
	xor ah, ah
	mov al, 2
	int 10h
ret
endp textMode
	
	
;-------------------------print a BMP picture-------------------------
	
;enter – file name in file, got in dx the offset
;exit - Open file, put handle in filehandle
;(if the file didn't open, print a problam message)
proc OpenFile
	push ax

	mov ah, 3Dh
	xor al, al
	int 21h
	jc openerror
	mov [filehandle], ax
	
	pop ax
ret
openerror:
	mov dx, offset ErrorMsg
	mov ah, 9h
	int 21h
	mov ax, 4c00h ; exit the program
	int 21h
endp OpenFile


;Read BMP file header, 54 bytes
proc ReadHeader

	doPush ax,bx,cx,dx

    mov ah, 3fh
    mov bx, [filehandle]
    mov cx , 54
    mov dx, offset Header
    int 21h
	

	doPop dx,cx,bx,ax
ret
endp ReadHeader


;Read BMP file color palette, 256 colors * 4 bytes (400h)
proc ReadPalette
	doPush ax,bx,cx,dx

    mov ah,3fh
    mov bx, [filehandle]
    mov cx , 400h
    mov dx,offset Palette
    int 21h
	
	doPop dx,cx,bx,ax
ret
endp ReadPalette


; Copy the colors palette to the video memory registers
; The number of the first color should be sent to port 3C8h
; The palette is sent to port 3C9h
proc CopyPal

	
	doPush si,ax,bx,cx,dx
	
	mov si, offset Palette
	mov cx, 256
	mov dx, 3C8h
	mov al, 0
; Copy starting color to port 3C8h
	out dx, al
; Copy palette itself to port 3C9h
	inc dx
PalLoop:
; Note: Colors in a BMP file are saved as BGR values rather than RGB.
	mov al,[si+2] ; Get red value.
	shr al,2 ; Max. is 255, but video palette maximal
	;value is 63. Therefore dividing by 4.
	out dx,al ; Send it.
	mov al,[si+1] ; Get green value.
	shr al,2
	out dx,al ; Send it.
	mov al,[si] ; Get blue value.
	shr al,2
	out dx,al ; Send it.
	add si,4 ; Point to next color.
    ;(There is a null chr. after every color.)
	loop PalLoop
	
	
	
	doPop dx,cx,bx,ax,si
ret
endp CopyPal



;BMP graphics are saved upside-down.
;Read the graphic line by line (200 lines in VGA format),
;displaying the lines from bottom to top.
proc CopyBitmap
	

	doPush ax,bx,cx,dx,di,si,es
	
	mov ax, 0A000h
	mov es, ax
	mov bx, [filehandle]
	mov cx, [picHigh]
PrintBMPLoop:
	push cx
;di = cx*320, point to the correct screen line
	mov di,cx
	shl cx,6
	shl di,8
	add di,cx

	add di, [leftGap]
	add di, [topGap]
;Read one line
	mov ah,3fh
	mov cx, [picWidth]
	mov dx,offset ScrLine
	int 21h
;Copy one line into video memory
	cld ; Clear direction flag, for movsb	
	mov cx,320
	mov si,offset ScrLine
	rep movsb ; Copy line to the screen
	pop cx
	loop PrintBMPLoop
	
	doPop es,si,di,dx,cx,bx,ax
ret
endp CopyBitmap




;enter – filehandle
;exit – close the file
proc CloseFile
	doPush ax,bx
	
	mov ah,3Eh
	mov bx, [filehandle]
	int 21h
	
	doPop ax,bx
ret
endp CloseFile

;enter: gets all the BMP procedures (OpenFile,ReadHeader,ReadPalette,CopyPal,CopyBitmap,CloseFile) 
;exit: print a picture:
proc printPic
	call OpenFile
	call ReadHeader
	call ReadPalette
	call CopyPal
	call CopyBitmap
	call CloseFile
ret
endp printPic




;-------------------------print a DOT (pixel), LINE, SQUARE-------------------------	
	
	
	


;print a dot (pixel) on the screen
proc dot
	;print:
	mov ah, 0ch
	int 10h
ret
endp dot



;print a line (useing the proc 'dot')
proc drawLine
;set counter
	push si
	mov si, [widthS]
print_line:
	cmp si, 0
	jz end_print_line
	call dot
	inc cx  ;move to the next place
	dec si  ;sub 1 from the counter
	jmp print_line
end_print_line:
	;move the pixel location to his starting place again:
	mov cx, [cxFirst]
	;send back the counter of printSquare
	pop si
ret
endp drawLine



;enter: gets all the information in the registers:
		;cx gets the X location ,dx gets the Y location 
		;bh gets the first screen,al gets the color
		;(useing the proc 'dot' and 'drawLine')
;exit: print a square
proc printSquare
	xor bh, bh  ;the first screen
	mov si, [lenS]  ;si is the counter 
square:
	call drawLine
	inc dx  ;move to the next place
	cmp si, 0
	jz end_print_square
	dec si
	jmp square
end_print_square:
ret
endp printSquare

;-----------------------------mask-----------------------------------------

;enter: newPosBird - location, charOff - offset of character
;and set the size in [Hight_mask] and [Width_mask]
;exit: anding between character and screen
proc anding
	
	
	doPush ax,es,di,cx
	
	mov ax, 0A000h
	mov es, ax
	mov di, [newPos]
	mov cx, [Hight_mask]
and1:
	push cx
	mov cx, [Width_mask]
and2:
	lodsb
	and [es:di], al
	inc di
	loop and2
	add di, 320
	sub di, [Width_mask]
	pop cx
	loop and1
	
	

	doPop cx,di,es,ax

ret
endp anding



;enter: newPosBird - location, charOff - offset of character
;and set the size in [Hight_mask] and [Width_mask]
;exit: oring between character and screen
proc oring
	doPush ax,es,di,cx
	
	mov ax, 0A000h
	mov es, ax
	mov di, [newPos]
	mov cx, [Hight_mask]
or1:
	push cx
	mov cx, [Width_mask]
or2:
	lodsb
	or [es:di], al
	inc di
	loop or2
	add di, 320
	sub di, [Width_mask]
	pop cx
	loop or1
	
	doPop cx,di,es,ax
ret
endp oring






;enter: the position of the bird [newPos]:
;exit: print the bird
proc print_bird
	
	;the size of the bird
	mov [Hight_mask], 20
	mov [Width_mask], 20
	
	;print the bird
	mov si, offset birdMask
	call anding
	mov si, offset bird
	call oring
ret
endp print_bird


;enter: the position of the obstacle [newPos]:
;exit: print the blue background to cover the obstacle
proc print_blue_background_cover_obs
	
	;the size of the blue square
	mov [Hight_mask], 16
	mov [Width_mask], 16
	
	;print the blue square
	mov si, offset cover_obs1_mask
	call anding
	mov si, offset cover_obs1
	call oring
ret
endp print_blue_background_cover_obs

;-------------------------speacker--------------------------------------------------

;turn on the speacker, and change the frequency before send:
proc speackerOn
	in al, 61h
	or al, 00000011b
	out 61h, al
	;change frequency
	mov al, 0B6h
	out 43h, al
ret
endp speackerOn


;turn off the speacker, and change the frequency before send:
proc speackerOff
	in al, 61h
	and al, 11111100b
	out 61h, al
ret
endp speackerOff



;play the Sound/Frequency: (using the sound we sent to register: ax)
proc playSound
	out 42h, al	; sending lower byte
	mov al, ah
	out 42h, al	; sending upper byte
ret
endp playSound



;-------------------------delay--------------------------------------

; enter: register cx get the amount of time to wait
; exit: wait 
proc delay
	push es
	push ax
	
	;set es to the place of the time:
	mov ax, 40h
	mov es, ax
	
	mov ax, [Clock]  ;put the current time in ax
	
waitLoop:
	cmp ax, [Clock]  ;do it if the time didn't change
	je waitLoop  ;wait again until the tick
	
	mov ax, [Clock]  ;put the current time in ax
	dec cx  ;sub 1 from the loop counter
	jz finishedDelay
	
	jmp waitLoop
	
finishedDelay:
	pop ax
	pop es
ret
endp delay



;this is a faster delay than 'delay' and it works on a 2 loops running
proc delay1
;delay:
	mov cx, 10000
	mov si, 50
dealy1:
	
	push cx
	mov cx, si
dealy2:
	loop dealy2
	pop cx
	loop dealy1
ret 
endp delay1



;-------------------------random--------------------------------

;chose a random number between 0-9 and add one to the number, put the random number in [random_number]
;(random between 1-10)
proc random

	doPush es,ax,bx,cx 
	
	; initialize
	mov ax, 40h
	mov es, ax
	
	mov cx, 10
	mov bx, 0
	
RandLoop:
	; generate random number, cx number of times
	mov ax, [Clock] 		; read timer counter
	mov ah, [byte cs:bx] 	; read one byte from memory
	xor al, ah 				; xor memory and counter
	inc bx
	loop RandLoop
	
	mov bl, 10
	div bl
	
	inc ah
	mov [random_number], ah
	
	doPop cx,bx,ax,es 
ret
endp random



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;print number on the screen;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; enter – number in al
; exit – printing the numbers digit by digit
proc printNumber
	
	doPush ax,bx,cx
	
	mov  bx, offset divisorTable
nextDigit:
    xor ah,ah        
    div [byte ptr bx]   ;al = quotient, ah = remainder
    add al,'0'
    call printCharacter   ;Display the quotient
    mov al,ah           ;ah = remainder
	add bx,1                ;bx = address of next divisor
    cmp [byte ptr bx],0 ;Have all divisors been done?
    jne nextDigit

	doPop cx,bx,ax
ret
endp printNumber


; enter – character in al
; exit – printing the character
proc printCharacter
	doPush ax,bx,cx
	mov dl, al
	mov ah,2
	int 21h

	doPop cx,bx,ax
ret
endp printCharacter



;-------------------------------------------print the game's regular start screen-------------------------------
;print the game's regular start screen that has the blue sky, the ground and the bird
proc print_regular_start_screen
		
	;Back to text mode
	call textMode
	;Graphic mode
	call graphicMode
	
	
	
;print blue background:
	mov dx, 0  			;the place of the line. (y)
	mov cx, 0 			;the place of the row. (x)
	mov al, 11  		;the color blue
	mov [cxFirst], cx  	;the first place on the screen(from the left)
	mov [widthS], 320  	;the width of the square
	mov [lenS], 200 	;the length of the square 
	call printSquare

;print the brown ground:
	mov dx, 170  		;the place of the line. (y)
	mov cx, 0  			;the place of the row. (x)
	
	;set the color:
	call random
	mov al, [random_number]
	add al, 040h ;0b7h
	;mov al, 6  			;the color brown
	mov [cxFirst], cx  	;the first place on the screen(from the left)
	mov [widthS], 320  	;the width of the square
	mov [lenS], 30  	;the length of the square 
	call printSquare




	;print the green ground:
	mov dx, 165  		;the place of the line. (y)
	mov cx, 0  			;the place of the row. (x)
	
	;set the color:
	call random
	mov al, [random_number]
	add al, 70h
	;mov al, 2 			;the color green
	mov [cxFirst], cx  	;the first place on the screen(from the left)
	mov [widthS], 320  	;the width of the square
	mov [lenS], 10  	;the length of the square 
	call printSquare

;#print the white bird by using mask:

	;the location on the screen:
	mov [newPosBird], 145*320 + 80 ;46480 ;the starting place for the bird (145*320+80)(FOR THE EGGS LOCATION)
	mov [newPos], 145*320 + 80 ;46480 ;the starting place for the bird (145*320+80)(FOR THE MASK)
	
	;set bird's size:
	mov [Hight_mask], 20
	mov [Width_mask], 20
	
	;print the bird by using mask
	mov si, offset birdMask
	call anding
	mov si, offset bird
	call oring
	
ret
endp print_regular_start_screen





