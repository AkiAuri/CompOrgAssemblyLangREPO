.model small                        ; Define memory model as 'small' (code and data each fit in 64KB)
.stack 100h                         ; Allocate 256 bytes (100h) for the stack

.data                               ; Start of data segment
	msg1 db 10,13,"DO YOU LOVE THE CITY YOU LIVE IN? (Y|N): $"  ; Question with newline (10=LF, 13=CR)
	msg2 db 10,13,"Invalid Input$"                              ; Error message with newline
	ans db 0                                                    ; Variable to store user's answer (1 byte)
.code                               ; Start of code segment

	mov ax, @data                   ; Load the address of data segment into AX
	mov ds, ax                      ; Move AX value into DS (Data Segment register) to access data
	
	rpt:                            ; Label 'rpt' (repeat) - main loop starts here
		mov ah, 09h                 ; DOS function 09h: Display string terminated by '$'
		mov dx, offset msg1         ; Load offset address of msg1 into DX
		int 21h                     ; Call DOS interrupt to display question
	
		mov ah, 01h                 ; DOS function 01h: Read single character from keyboard
		int 21h                     ; Call DOS interrupt, character stored in AL (with echo to screen)
		
		mov ans, al                 ; Store the input character from AL into 'ans' variable
		
	cmp ans, 'Y'                    ; Compare ans with uppercase 'Y'
	je rpt                          ; Jump to 'rpt' if equal (if user answered 'Y', ask again)
	
	cmp ans, 'y'                    ; Compare ans with lowercase 'y'
	je rpt                          ; Jump to 'rpt' if equal (if user answered 'y', ask again)
	
	cmp ans, 'N'                    ; Compare ans with uppercase 'N'
	je dne                          ; Jump to 'dne' (done) if equal (if user answered 'N', exit program)
	
	cmp ans, 'n'                    ; Compare ans with lowercase 'n'
	je dne                          ; Jump to 'dne' (done) if equal (if user answered 'n', exit program)
	
	mov ah, 09h                     ; DOS function 09h: Display string (reached if input was invalid)
	mov dx, offset msg2             ; Load offset address of msg2 into DX
	int 21h                         ; Call DOS interrupt to display "Invalid Input"
	
	jmp rpt                         ; Unconditional jump back to 'rpt' to ask question again
	
	dne:                            ; Label 'dne' (done) - program termination point
		mov ah, 4ch                 ; DOS function 4Ch: Terminate program
		int 21h                     ; Call DOS interrupt to exit program
end                                 ; End of program (marks end of source code)