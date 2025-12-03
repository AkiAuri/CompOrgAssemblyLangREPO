. model small
. stack 100h
. data
	mov ah, 49h
	mov bh, 61h
	mov cx, 39h

. code
	mov ax, @data
	mov ds, ax
	
x:
	mov ah, 49h
	int 21h 
	
	mov bh, 61h
	int 21h
	
	mov cx, 39h
	int 21h
	
	mov cx, 38h
	int 21h
	
	mov cx, 37h
	int 21h
	
	mov cx, 36h
	int 21h
	
	mov cx, 35h
	int 21h
	
	mov cx, 34h
	int 21h
	
	mov cx, 33h
	int 21h
	
	mov cx, 32h
	int 21h
	
	mov cx, 31h
	int 21h
	
	mov bh, 61h
	int 21h

	mov ah, 49h
	int 21h
	
	dec ah
	inc bh
	pop cx
	loop x
	int 21h
end