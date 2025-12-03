. model small
. stack 100h
. data
	mov ah, 56h
	mov bh, 61h
	mov cx, 2Ah
	mov dh, 7Ah
	mov ax, 41h

. code
	mov ax, @data
	mov ds, ax

x:
	mov ah, 56h
	int 21h
	
	mov bh, 61h
	int 21h
	
	mov bh, 61h
	int 21h
	
	mov bh, 61h
	int 21h
	
	mov cx, 2Ah
	int 21h
	
	mov dh, 7Ah
	int 21h
	
	mov dh, 7Ah
	int 21h
	
	mov dh, 7Ah
	int 21h
	
	mov ax, 41h
	int 21h
	
	dec ah
	inc bh
	dec dh
	inc ax
	loop x
	int 21h

end