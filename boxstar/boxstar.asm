.model small                        ; Define memory model as 'small' (code and data each fit in 64KB)
.stack 100h                         ; Allocate 256 bytes (100h) for the stack

.data                               ; Start of data segment
	msg1 db "Enter Number of Row:$"        ; Define string for row prompt ($ is terminator for DOS)
	msg2 db 10,13,"Enter number of columns:$"  ; Define string for column prompt (10=LF, 13=CR for newline)
	row db 0                                ; Reserve 1 byte to store number of rows
	col db 0                                ; Reserve 1 byte to store number of columns
	newln db 10,13,"$"                      ; Define newline string (LF + CR)

.code                               ; Start of code segment
	mov ax, @data                   ; Load the address of data segment into AX
	mov ds, ax                      ; Move AX value into DS (Data Segment register)

	mov ah, 09h                     ; DOS function 09h: Display string
	lea dx, msg1                    ; Load effective address of msg1 into DX
	int 21h                         ; Call DOS interrupt to display "Enter Number of Row:"

	mov ah, 01h                     ; DOS function 01h: Read single character from keyboard
	int 21h                         ; Call DOS interrupt, character stored in AL

	mov row, al                     ; Store the input character (ASCII) in 'row' variable

	mov ah, 09h                     ; DOS function 09h: Display string
	mov dx, offset msg2             ; Load offset address of msg2 into DX
	int 21h                         ; Call DOS interrupt to display "Enter number of columns:"

	mov ah, 01h                     ; DOS function 01h: Read single character from keyboard
	int 21h                         ; Call DOS interrupt, character stored in AL

	mov col, al                     ; Store the input character (ASCII) in 'col' variable

	sub row, 30h                    ; Convert ASCII digit to actual number (subtract 48/'0')
	sub col, 30h                    ; Convert ASCII digit to actual number (subtract 48/'0')
	
	mov ah, 09h                     ; DOS function 09h: Display string
	lea dx, newln                   ; Load effective address of newln into DX
	int 21h                         ; Call DOS interrupt to print newline
	
	mov ch, 00h                     ; Clear upper byte of CX register
	mov cl, row                     ; Load row count into CL (CX = number of rows for outer loop)

	y:                              ; Label for outer loop (iterates through rows)
	push cx                         ; Save outer loop counter (CX) onto stack

	mov ch, 00h                     ; Clear upper byte of CX register
	mov cl, col                     ; Load column count into CL (CX = number of columns for inner loop)

	mov ah, 02h                     ; DOS function 02h: Display single character
	mov dl, "*"                     ; Load '*' character into DL (character to display)
	x:                              ; Label for inner loop (iterates through columns)
	int 21h                         ; Call DOS interrupt to display '*'

	loop x                          ; Decrement CX, jump to 'x' if CX != 0 (print stars in a row)

	mov ah, 09h                     ; DOS function 09h: Display string
	mov dx, offset newln            ; Load offset address of newln into DX
	int 21h                         ; Call DOS interrupt to print newline (move to next row)

	pop cx                          ; Restore outer loop counter (CX) from stack

	loop y                          ; Decrement CX, jump to 'y' if CX != 0 (repeat for next row)

	mov ah, 4ch                     ; DOS function 4Ch: Terminate program
	int 21h                         ; Call DOS interrupt to exit program
	end                             ; End of program (marks end of source code)