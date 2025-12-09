.model small                        ; Define memory model as 'small' (code and data each fit in 64KB)
.stack 100h                         ; Allocate 256 bytes (100h) for the stack

.data                               ; Start of data segment
	msg1 db "Enter your name: $"            ; String prompt for name input ($ = terminator)
	msg2 db 0Ah, 0Dh, "Good Evening, $"     ; String with newline (0Ah=LF, 0Dh=CR) + greeting
	idn db 30, 0, 28 DUP('$')               ; Buffer for name: max 30 chars, actual length byte, 28 spaces filled with '$'
	                                        ; Format: [max_size][actual_length][input_characters...]
.code                               ; Start of code segment

	mov ax, @data                   ; Load the address of data segment into AX
	mov ds, ax                      ; Move AX value into DS (Data Segment register) to access data

	mov ah, 09h                     ; DOS function 09h: Display string terminated by '$'
	mov dx, offset msg1             ; Load offset address of msg1 into DX
	int 21h                         ; Call DOS interrupt to display "Enter your name: "

	mov ah, 0Ah                     ; DOS function 0Ah: Buffered string input
	mov dx, offset idn              ; Load offset address of idn buffer into DX
	int 21h                         ; Call DOS interrupt to read string from keyboard
	                                ; After input: idn[0]=max length, idn[1]=actual length, idn[2... ]=characters

	mov ah, 09h                     ; DOS function 09h: Display string terminated by '$'
	mov dx, offset msg2             ; Load offset address of msg2 into DX
	int 21h                         ; Call DOS interrupt to display newline + "Good Evening, "

	lea si, idn+2                   ; Load effective address of idn+2 into SI (points to first character of input)
	                                ; Skip first 2 bytes: [max_length] and [actual_length]

	mov ch, 00h                     ; Clear upper byte of CX register (set to 0)
	mov cl, idn[1]                  ; Load actual length of input string into CL (from idn[1])
	                                ; CX now contains the loop counter (number of characters entered)

	mov ah, 02h                     ; DOS function 02h: Display single character
	x:                              ; Label for loop (iterates through each character of name)
		mov dl, [si]                ; Load character at address pointed by SI into DL
		int 21h                     ; Call DOS interrupt to display character in DL
		
		inc si                      ; Increment SI to point to next character in buffer

	loop x                          ; Decrement CX, jump to 'x' if CX != 0 (repeat for all characters)

	mov ah, 4ch                     ; DOS function 4Ch: Terminate program
	int 21h                         ; Call DOS interrupt to exit program
end                                 ; End of program (marks end of source code)