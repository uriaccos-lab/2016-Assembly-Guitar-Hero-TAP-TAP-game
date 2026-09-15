IDEAL;All Rights Reserved © Uri Accos
MODEL small
STACK 100h
DATASEG
; --------------------------

;first page messages
opmsg db "Guitar Master",10,13,10,13,10,13,10,13,10,13
msg1 db "By Uri Accos",10,13,10,13,10,13
msg2 db "Teacher: Starinsky Ayelet",10,13,10,13,10,13
msg3 db "Teacher assistant: Sheinbox Liran",10,13,10,13,10,13
msg4 db "press 1 for instructions",10,13
msg5 db "press 2 to start game","$"
;second page messages
msginstr db "Instructions",10,13,10,13,10,13,10,13,10,13
msgi1 db "There are blocks which going down to theletters squares.",10,13,10,13
msgi2 db "You should press the letter when the    block exactly on the letter square.",10,13,10,13
msgi3 db "The game continues untill you miss threetimes.",10,13
msgki db "press 2 to start game""$"
x dw ?
y dw ?
gamey dw ?
gamex dw ?
color db ?
loopreturns dw ?;the length or size
charx dw ?;not in use
score db 0
note dw ?;not in use
scancode db ?
missc db 0
isAalreadypressed db 0
isSalreadypressed db 0
isDalreadypressed db 0
isFalreadypressed db 0
yonatankarr dw 1 dup (225,121,121,173,70,70,70,121,173,225,225,225,225,225,121,121,173,70,70,70,121,225,225,70,70,70,70,70,70,70,121,173,121,121,121,121,121,121,173,225,225,121,121,173,70,70,70,121,225,225,70,00)
yonatansarr dw 1 dup (4063,4831,4831,4560,5423,5423,6087,5423,4831,4560,4063,4063,4063,4063,4831,4831,4560,5423,5423,6087,4831,4063,4063,6087,5423,5423,5423,5423,5423,5423,4831,4560,4831,4831,4831,4831,4831,4831,4560,4063,4063,4831,4831,4560,5423,5423,6087,4831,4063,4063,6087,4560,3615,3043,4560,3615,3043,)
yonatansparr dw 1 dup (4,1,1,4,1,1,4,4,4,4,1,1,1,4,1,1,4,1,1,4,4,1,1,4,1,1,1,1,1,1,4,4,1,1,1,1,1,1,4,4,4,1,1,4,1,1,4,4,1,1,8,1,1,1,1,1)
endmessage db "Your score is: $"
winmessage db 10,13,"YOU WIN!!!$"
;bmp file reading varibales
filename db 'OpenS.bmp',0
filehandle dw ?
Header db 54 dup (0)
Palette db 256*4 dup (0)
ScrLine db 320 dup (0)
ErrorMsg db 'Error', 13, 10,'$'
; --------------------------
CODESEG
;~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc OpenFile
	; Open file
	mov ah, 3Dh
	xor al, al
	mov dx, offset filename
	int 21h
	jc openerror
	mov [filehandle], ax
	ret
	openerror:
	mov dx, offset ErrorMsg
	mov ah, 9h
	int 21h
	ret
endp OpenFile
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc ReadHeader
	; Read BMP file header, 54 bytes
	mov ah,3fh
	mov bx, [filehandle]
	mov cx,54
	mov dx,offset Header
	int 21h
	ret
	endp ReadHeader
	proc ReadPalette
	; Read BMP file color palette, 256 colors * 4 bytes (400h)
	mov ah,3fh
	mov cx,400h
	mov dx,offset Palette
	int 21h
	ret
endp ReadPalette
;~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc CopyPal
	; Copy the colors palette to the video memory
	; The number of the first color should be sent to port 3C8h
	; The palette is sent to port 3C9h
	mov si,offset Palette
	mov cx,256
	mov dx,3C8h
	mov al,0
	; Copy starting color to port 3C8h
	out dx,al
	; Copy palette itself to port 3C9h
	inc dx
	PalLoop:
	; Note: Colors in a BMP file are saved as BGR values rather than RGB.
	mov al,[si+2] ; Get red value.
	shr al,2 ; Max. is 255, but video palette maximal
	; value is 63. Therefore dividing by 4.
	out dx,al ; Send it.
	mov al,[si+1] ; Get green value.
	shr al,2
	out dx,al ; Send it.
	mov al,[si] ; Get blue value.
	shr al,2
	out dx,al ; Send it.
	add si,4 ; Point to next color.
	; (There is a null chr. after every color.)
	loop PalLoop
	ret
endp CopyPal
;~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc CopyBitmap
	; BMP graphics are saved upside-down.
	; Read the graphic line by line (200 lines in VGA format),
	; displaying the lines from bottom to top.
	mov ax, 0A000h
	mov es, ax
	mov cx,200
	PrintBMPLoop:
	push cx
	; di = cx*320, point to the correct screen line
	mov di,cx
	shl cx,6
	shl di,8
	add di,cx
	; Read one line
	mov ah,3fh
	mov cx,320
	mov dx,offset ScrLine
	int 21h
	; Copy one line into video memory
	cld ; Clear direction flag, for movsb
	mov cx,320
	mov si,offset ScrLine
	rep movsb ; Copy line to the screen
	 ;rep movsb is same as the following code:
	 ;mov es:di, ds:si
	 ;inc si
	 ;inc di
	 ;dec cx
	 ;loop until cx=0
	pop cx
	loop PrintBMPLoop
	ret
endp CopyBitmap
;~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc CloseFile
  mov ah,3Eh
  int 21h
  ret
endp CloseFile
;~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc clrals;clears all the screen
	mov ah,06h
	xor al,al
	xor bh,bh
	xor cx,cx
	mov	dl, 39
	mov	dh, 24
	int 10h
	ret
endp clrals
;~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc clrscr2
	mov ah,06h
	xor al,al
	xor bh,bh
	xor cx,cx
	mov	dl, 39
	mov	dh, 19
	int 10h
	ret
endp clrscr2
;~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc verticaline
	mov cx,[word ptr loopreturns]
loopverticaline:
	push cx
	xor bh,bh
	mov cx,[WORD ptr x];why we push second time cx
	mov dx,[WORD ptr y]
	mov al,[byte ptr color]
	mov ah,0ch
	int 10h
	inc [y]
	pop cx
	loop loopverticaline
	ret
endp verticaline
;~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc delayp;loopreturns
	push es
	xor ax,ax
	mov es,ax
	mov bx,046ch
	mov ax,[es:[word ptr bx]]
	mov cx,[loopreturns]
FirstTick:
	cmp ax,[es:[word ptr bx]]
	je FirstTick
	mov ax,[es:[word ptr bx]]
	loop FirstTick
	pop es
	ret
endp delayp
;~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc ms055delay;loopreturns
	push es
	xor ax,ax
	mov es,ax
	mov bx,046ch
	mov ax,[es:[word ptr bx]]
FirstTick2:
	cmp ax,[es:[word ptr bx]]
	je FirstTick2
	pop es
	ret
endp ms055delay
;~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc horizontaline;loopreturns,x,y,color
	mov cx,[word ptr loopreturns]
loophorizontaline:
	push cx
	xor bh,bh
	mov cx,[WORD ptr x];why we push second time cx
	mov dx,[WORD ptr y]
	mov al,[byte ptr color]
	mov ah,0ch
	int 10h
	inc [x]
	pop cx
	loop loophorizontaline
	ret
endp horizontaline
;~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc reverseslant;loopreturns,x,y,color
	mov cx,[word ptr loopreturns]
loopreverseslant:
	push cx
	xor bh,bh
	mov cx,[WORD ptr x];why we push second time cx
	mov dx,[WORD ptr y]
	mov al,[byte ptr color]
	mov ah,0ch
	int 10h
	inc [y]
	dec [x]
	pop cx
	loop loopreverseslant
	ret
endp reverseslant
;~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc slant;loopreturns,x,y,color
	mov cx,[word ptr loopreturns]
loopslant:
	push cx
	xor bh,bh
	mov cx,[WORD ptr x];why we push second time cx
	mov dx,[WORD ptr y]
	mov al,[byte ptr color]
	mov ah,0ch
	int 10h
	inc [y]
	inc [x]
	pop cx
	loop loopslant
	ret
endp slant
;~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc Square;loopreturns,x,y,color

	mov cx,25
loopsquare:
	push cx
	mov cx,25
	
loopline:
	push cx
	xor bh,bh
	mov cx,[WORD ptr x];why we push second time cx
	mov dx,[WORD ptr y]
	mov al,[byte ptr color]
	mov ah,0ch
	int 10h
	inc [WORD ptr x]
	pop cx
	loop loopline
	
	mov ax,25d;loopreturns
	sub [x],ax;must
	inc [y];must
	pop cx
	loop loopsquare
	
	ret
endp Square
;~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc staticsquares
	mov [x],70
	mov [y],160
	mov [color],4
	call Square;(x,y,color,loopreturns)
	
	mov [x],121;.5
	mov [y],160
	mov [color],4
	call Square;(x,y,color,loopreturns)
	
	mov [x],173
	mov [y],160
	mov [color],4
	call Square;(x,y,color,loopreturns)
	
	mov [x],225;.5
	mov [y],160
	mov [color],4
	call Square;(x,y,color,loopreturns)
	ret
endp staticsquares
;~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc gamesquare
	push [gamey]
	mov cx,25
loopsquare2:
	push cx
	mov cx,25
loopline2:
	push cx
	xor bh,bh
	mov cx,[WORD ptr x];why we push second time cx
	mov dx,[WORD ptr gamey]
	mov al,36d
	mov ah,0ch
	int 10h
	inc [WORD ptr x]
	pop cx
	loop loopline2
	
	mov ax,25d;loopreturns
	sub [x],ax;must
	inc [gamey];must
	pop cx
	loop loopsquare2
	pop [gamey]
	ret
endp gamesquare
;~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc gamesound;note,loopreturns=delay
	in al, 61h; open speaker
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play 
	mov ax, [di]
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al; Sending upper byte
;	mov dx,5
	mov ax,di
	mov cx,offset yonatansarr
	sub ax,cx
	mov bx,ax
	mov cx,[word ptr yonatansparr+bx]
	mov [loopreturns],cx
	call delayp
;delayloop3:
	
	;loop delayloop3
	;mov cx,0
delayloop4:
	;loop delayloop4
	dec dx
	cmp dx,0
	;jnz delayloop3
	in al, 61h
	and al, 11111100b
	out 61h, al
	; close the speaker
	;in al, 61h
	;and al, 11111100b
	;out 61h, al
	add di,2
	ret
endp gamesound
;~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc missnd
	in al, 61h; open speaker
	or al, 00000011b
	out 61h, al
	; send control word to change frequency
	mov al, 0B6h
	out 43h, al
	; play 
	mov ax, 10000d
	out 42h, al ; Sending lower byte
	mov al, ah
	out 42h, al; Sending upper byte
;	mov dx,5
	call ms055delay
;delayloop3:
	
	;loop delayloop3
	;mov cx,0
;delayloop4:
	;loop delayloop4
	;dec dx
	;cmp dx,0
	;jnz delayloop3
	in al, 61h
	and al, 11111100b
	out 61h, al
	; close the speaker
	ret
endp missnd
;~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc letterA
	;A start
	mov [loopreturns],10d
	mov [x],82
	mov [y],165
	mov [color],15
	call slant;(x,y,color,loopreturns)
	
	mov [loopreturns],10d
	mov [x],82
	mov [y],165
	mov [color],15
	call reverseslant;(x,y,color,loopreturns)
	
	mov [loopreturns],9d
	mov [x],78
	mov [y],169
	mov [color],15
	call horizontaline;loopreturns,x,y,color
	;A end
	ret
endp letterA
;~~~~~~~~~~~
proc letterS
	;S start
	mov [loopreturns],9d
	mov [x],129
	mov [y],165
	mov [color],15
	call horizontaline;loopreturns,x,y,color
	
	mov [loopreturns],7d
	mov [x],129
	mov [y],165
	mov [color],15
	call verticaline;loopreturns,x,y,color
	
	mov [loopreturns],9d
	mov [x],129
	mov [y],172
	mov [color],15
	call horizontaline;loopreturns,x,y,color
	
	mov [loopreturns],7d
	mov [x],137
	mov [y],172
	mov [color],15
	call verticaline;loopreturns,x,y,color
	
	mov [loopreturns],9d
	mov [x],129
	mov [y],179
	mov [color],15
	call horizontaline;loopreturns,x,y,color
	;s end
	ret
endp letterS
;~~~~~~~~~~~
proc letterD
;d start
	mov [loopreturns],20d
	mov [x],183
	mov [y],163
	mov [color],15
	call verticaline;loopreturns,x,y,color
	
	mov [loopreturns],6d
	mov [x],183
	mov [y],163
	mov [color],15
	call slant;loopreturns,x,y,color
	
	mov [loopreturns],6d
	mov [x],188
	mov [y],177
	mov [color],15
	call reverseslant;loopreturns,x,y,color
	
	mov [loopreturns],8d
	mov [x],188
	mov [y],169
	mov [color],15
	call verticaline;loopreturns,x,y,color
	;d end
	ret
endp letterD
;~~~~~~~~~~~
proc letterF
	;f start
	mov [loopreturns],15d
	mov [x],230
	mov [y],163
	mov [color],15
	call horizontaline;loopreturns,x,y,color
	
	mov [loopreturns],20d
	mov [x],230
	mov [y],163
	mov [color],15
	call verticaline;loopreturns,x,y,color
	
	mov [loopreturns],12d
	mov [x],230
	mov [y],169
	mov [color],15
	call horizontaline;loopreturns,x,y,color
	ret
endp letterF
;~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc hitp
	call gamesound
	add si,2
	mov [gamey],0
	inc [score]
	jmp WaitForKey
	ret
endp hitp
;~~~~~~~~~~~~~~~~~~~~~~~~~~~
proc missp
	inc [missc]
	cmp [missc],3
	je exit5
	jmp continue
exit5:
	jmp exit
continue:
	add si,2
	add di,2
	mov [gamey],0
	cmp [score],0
	je scoreiszero
	dec [score]
scoreiszero:
	jmp waitforkey
	ret
endp missp
;~~~~~~~~~~~~~~~~~~~~~~~~~~~
start:

	mov ax, @data
	mov es, ax
	mov ds, ax

	xor ah,ah;mode 320x200 256 colors
	mov al,13h
	int 10h
	
	;prints open screen
	call OpenFile
	call ReadHeader
	call ReadPalette
	call CopyPal
	call CopyBitmap
	call CloseFile
	jmp waitfordata
firstpage:
	mov ax,seg opmsg
	mov es,ax
	xor ah,ah;mode  320x200 16 color
	mov al,0dh
	int 10h
	mov ah,0bh;background color light blue
	xor bh,bh
	mov bl,09h
	int 10h
	;prints first page messages
	mov ah,13h
	xor al, al
	xor bh,bh
	mov bl,0fbh
	mov cx,153
	mov dh,4
	mov dl,0ah
	mov bp,offset opmsg
	int 10h
	
	;wait for key pressed
waitfordata:
	in al,64h
	cmp al,10b
	je waitfordata
	in al,60h
	cmp al,1h
	je firstpage
	cmp al,2h
	je k1pressed
	cmp al,3h
	jne waitfordata
k2pressed:
	jmp gamestart
k1pressed:
	call clrals
	xor ah,ah;mode  320x200 16 color
	mov al,0dh
	int 10h
	mov ah,0bh;background color light blue
	xor bh,bh
	mov bl,09h
	int 10h
	mov ah,13h
	xor al, al
	xor bh,bh
	mov bl,0fbh
	mov cx,230
	mov dh,4
	mov dl,0ah
	mov bp,offset msginstr
	int 10h
	jmp waitfordata
gamestart:
	mov ax, 13h;graphic mode 320x200 256 colors
	int 10h
	
	call staticsquares
	;mov [x],9
	;mov [y],2
	;call setcurspo
	;mov [color],0fh
	;mov [charx],'A'
	;call char1
	call letterA
	call letterS
	call letterD
	call letterF
	mov cx,20000
	lea si,[yonatankarr]
gameloop:
	mov di,offset yonatansarr
	push cx
	call clrscr2
	call staticsquares
	call letterA
	call letterS
	call letterD
	call letterF
	mov ax,[word ptr si]
	mov [x],ax
	mov [gamey],0
	call gamesquare
waitforkey:
	call letterA
	call letterS
	call letterD
	call letterF
	mov ax,offset yonatankarr
	mov bx,si
	sub bx,ax
	cmp bx,66h
	je q
	mov ax,di
	mov cx,offset yonatansarr
	sub ax,cx
	mov bx,ax
	mov cx,[word ptr yonatansparr+bx]
	mov [loopreturns],cx
	call ms055delay
	;mov cx,0
;delayloop2:
	;loop delayloop2
	call clrscr2
	cmp [gamey],164d
	je y164
	add [gamey],4
	mov ax,[word ptr si]
	mov [x],ax
	call gamesquare
	in al,64h
	cmp al,10b
	je waitforkey
	in al,60h
	mov [scancode],al
	cmp al,1
	je q
	cmp [scancode],1eh;key pressed
	je apressed
	cmp [scancode],1fh
	je spressed2
	cmp [scancode],20h
	je dpressed2
	cmp [scancode],21h
	je fpressed2
	cmp [scancode],9eh
	je keyarealesed;key realesed
	cmp [scancode],9fh 
	je keysrealesed
	cmp [scancode],0a0h
	je keydrealesed
	cmp [scancode],0a1h
	je keyfrealesed
	jmp waitforkey
	;and al,80h
	;jnz keyrealesed
q:
	jmp exit
y164:
	call clrals
	call staticsquares
	call missnd
	call missp
apressed:
	jmp apressed2
spressed2:
	jmp spressed
dpressed2:
	jmp dpressed
fpressed2:
	jmp fpressed
apressed2:
	call clrals
	call staticsquares
	cmp [isAalreadypressed],1
	je alreadypressed
	mov [isAalreadypressed],1
	cmp [word ptr si],70
	jne missed
	cmp [gamey],150
	jae hit
	jmp missed
keyarealesed:
	mov [isAalreadypressed],0
	jmp waitforkey
keysrealesed:
	mov [isSalreadypressed],0
	jmp waitforkey
keydrealesed:
	mov [isDalreadypressed],0
	jmp waitforkey
keyfrealesed:
	mov [isFalreadypressed],0
	jmp waitforkey
spressed:
	call clrals
	call staticsquares
	cmp [isSalreadypressed],1
	je alreadypressed
	mov [isSalreadypressed],1
	cmp [word ptr si],121
	jne missed
	mov cx,10
	mov ax,160
	cmp [gamey],150
	jae hit
	jmp missed
alreadypressed:
	jmp waitforkey
missed: 
	call missnd
	call missp
hit:
	call staticsquares
	call letterA
	call letterS
	call letterD
	call letterF
	call hitp
	;add si,2
	;mov [gamey],0
	;inc [score]
	;jmp WaitForKey
dpressed:
	call clrals
	call staticsquares
	cmp [isDalreadypressed],1
	je alreadypressed
	mov [isDalreadypressed],1
	cmp [word ptr si],173
	jne missed
	cmp [gamey],150
	jae hit
	jmp missed
fpressed:
	call clrals
	call staticsquares
	cmp [isFalreadypressed],1
	je alreadypressed
	mov [isFalreadypressed],1
	cmp [word ptr si],225
	jne missed
	cmp [gamey],150
	jae hit
	jmp missed

;;*&^%$#@!~*&^%$#@!~*&^%$#@!~
	xor ah,ah;wait key pressed
	int 16h
; --------------------------
	
exit:
	call gamesound
	call gamesound
	call gamesound
	call gamesound
	call gamesound
	xor ah,ah;mode  320x200 16 color
	mov al,0dh
	int 10h
	mov dx,offset endmessage
	xor al,al
	mov ah,9
	int 21h
	cmp [score],9
	jbe hadsiphra
	jmp dusiphra
hadsiphra:
	mov dl,[score]
	add dl,30h
	mov ah, 2
	int 21h
	jmp lastmessage
winmessageq:
	mov dx,offset winmessage
	xor al,al
	mov ah,9
	int 21h
	jmp waitfk
dusiphra:
	mov al,[score]
	mov ah,0
	mov bl,10
	div bl
	mov dl,al
	add dl,30h
	mov ah, 2
	int 21h
	mov dl,ah
	add dl,30h
	mov ah, 2
	int 21h
lastmessage:
	mov ax,offset yonatankarr
	mov bx,si
	sub bx,ax
	cmp bx,66h
	je winmessageq
waitfk:
	xor al,al;wait for key
	mov ah,0Ch
	mov al,07h
	int 21h
	xor ah,ah;back to text mode
	mov al,3h
	int 10h
	mov ax, 4c00h
	int 21h
END start;All Rights Reserved © Uri Accoss