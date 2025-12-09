;===============================================================================
; PROGRAM: Variables in Assembly Language - DB, DW, DD
; PURPOSE: Demonstrates different variable types and memory allocation
; DESCRIPTION: Shows Define Byte (DB), Define Word (DW), and Define Double Word (DD)
;              and how to access them using different register combinations
;===============================================================================

.model small                        ; Define memory model as 'small' (code and data each fit in 64KB)
.stack 100h                         ; Allocate 256 bytes (100h) for the stack

.data                               ; Start of data segment (where variables and constants are stored)
    title_msg db 10,13,"=== Variable Types in Assembly ===",10,13,10,13,"$"
    
    ;---------------------------------------------------------------------------
    ; 1. DEFINE BYTE (DB) - 8 bits or 1 byte of memory allocation
    ;---------------------------------------------------------------------------
    ; DB allocates 1 byte (8 bits) of memory
    ; Can store values from 0 to 255 (unsigned) or -128 to 127 (signed)
    ; Accessible using 8-bit registers: AL, BL, CL, DL, AH, BH, CH, DH
    ;---------------------------------------------------------------------------
    
    byte_var1 db 65                 ; Define byte variable, stores value 65 (ASCII 'A')
                                    ; Allocates 1 byte of memory
                                    ; byte_var1 is the label (address) of this memory location
    
    byte_var2 db 'B'                ; Define byte with character literal 'B' (ASCII 66)
                                    ; Single quotes denote a character
                                    ; 'B' is automatically converted to ASCII value 66
    
    byte_var3 db 255                ; Maximum unsigned value for 1 byte
                                    ; Binary:  11111111
                                    ; This is the largest value a byte can hold
    
    byte_var4 db -128               ; Minimum signed value for 1 byte (using 2's complement)
                                    ; In binary (2's complement): 10000000
    
    byte_array db 1,2,3,4,5         ; Array of 5 bytes stored consecutively in memory
                                    ; byte_array[0]=1, byte_array[1]=2, etc.
                                    ; Occupies 5 bytes total
    
    byte_string db "Hello$"         ; String is just an array of bytes (characters)
                                    ; Each character occupies 1 byte
                                    ; H=48h, e=65h, l=6Ch, l=6Ch, o=6Fh, $=24h
                                    ; Total: 6 bytes
    
    ;---------------------------------------------------------------------------
    ; 2. DEFINE WORD (DW) - 16 bits or 2 bytes of memory allocation
    ;---------------------------------------------------------------------------
    ; DW allocates 2 bytes (16 bits) of memory
    ; Can store values from 0 to 65535 (unsigned) or -32768 to 32767 (signed)
    ; Accessible using 16-bit registers:  AX, BX, CX, DX, SI, DI, BP, SP
    ; Note: x86 is little-endian (low byte stored first, high byte second)
    ;---------------------------------------------------------------------------
    
    word_var1 dw 1234               ; Define word variable, stores value 1234 (04D2h)
                                    ; Allocates 2 bytes of memory
                                    ; Memory layout: [D2h][04h] (little-endian)
                                    ; Low byte (D2h) stored first, high byte (04h) second
    
    word_var2 dw 65535              ; Maximum unsigned value for 2 bytes (FFFFh)
                                    ; Binary: 1111111111111111 (all 16 bits set)
                                    ; This is the largest value a word can hold
    
    word_var3 dw -32768             ; Minimum signed value for 2 bytes (8000h in 2's complement)
                                    ; Binary: 1000000000000000
    
    word_max dw 0FFFFh              ; Same as 65535, but written in hexadecimal
                                    ; 'h' suffix indicates hexadecimal number
                                    ; Prefix with 0 if first digit is A-F (e.g., 0FFFFh not FFFFh)
    
    word_array dw 100,200,300       ; Array of 3 words (6 bytes total)
                                    ; word_array[0]=100 (0064h), [1]=200 (00C8h), [2]=300 (012Ch)
                                    ; Each element occupies 2 bytes
    
    ;---------------------------------------------------------------------------
    ; 3. DEFINE DOUBLE WORD (DD) - 32 bits or 4 bytes of memory allocation
    ;---------------------------------------------------------------------------
    ; DD allocates 4 bytes (32 bits) of memory
    ; Can store values from 0 to 4,294,967,295 (unsigned)
    ; Can also store memory addresses (segment:offset pairs)
    ; Accessible by combining registers (e.g., DX:AX for 32-bit values)
    ; Or using 32-bit registers in 386+ processors (EAX, EBX, ECX, EDX)
    ;---------------------------------------------------------------------------
    
    dword_var1 dd 123456            ; Define double word, stores value 123456 (0001E240h)
                                    ; Allocates 4 bytes of memory
                                    ; Memory layout: [40h][E2h][01h][00h] (little-endian)
                                    ; Lowest byte first, highest byte last
    
    dword_var2 dd 4294967295        ; Maximum unsigned value for 4 bytes (FFFFFFFFh)
                                    ; Binary: 32 ones
                                    ; This is the largest value a double word can hold
    
    dword_max dd 0FFFFFFFFh         ; Same as above, in hexadecimal notation
    
    dword_array dd 1000,2000,3000   ; Array of 3 double words (12 bytes total)
                                    ; Each element occupies 4 bytes
    
    ; Messages for display
    msg_db db 10,13,"1.  BYTE (DB) Variables:",10,13,"$"
    msg_dw db 10,13,"2. WORD (DW) Variables:",10,13,"$"
    msg_dd db 10,13,"3. DOUBLE WORD (DD) Variables:",10,13,"$"
    
    msg_byte1 db "   byte_var1 (65, ASCII 'A'): $"
    msg_byte2 db 10,13,"   byte_var2 ('B'): $"
    msg_word1 db "   word_var1 (1234): displayed above",10,13,"$"
    msg_dword1 db "   dword_var1 (123456): too large to easily display",10,13,"$"
    
    newline db 10,13,"$"
    press_key db 10,13,"Press any key to continue.. .$"

.code                               ; Start of code segment (where program instructions are stored)
    mov ax, @data                   ; Load the address of data segment into AX register
                                    ; @data is a special symbol that represents data segment address
    mov ds, ax                      ; Move AX value into DS (Data Segment register)
                                    ; DS must point to data segment to access variables
                                    ; Can't move immediate value directly to DS (CPU limitation)

    ;---------------------------------------------------------------------------
    ; Clear Screen
    ;---------------------------------------------------------------------------
    mov ah, 00h                     ; AH = 00h:  BIOS function to set video mode
    mov al, 03h                     ; AL = 03h: 80x25 text mode, 16 colors
    int 10h                         ; Call BIOS interrupt to clear screen

    ;---------------------------------------------------------------------------
    ; Display Title
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h: Display string terminated by '$'
    mov dx, offset title_msg        ; DX = offset address of title_msg in data segment
                                    ; offset gets the memory address (offset from DS) of variable
    int 21h                         ; Call DOS interrupt to display string

    ;---------------------------------------------------------------------------
    ; DEMONSTRATE BYTE (DB) VARIABLES
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg_db           ; Load offset of "BYTE (DB) Variables:" message
    int 21h                         ; Display section header

    ; Display byte_var1 (value 65, which is ASCII 'A')
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg_byte1        ; Display "byte_var1 (65, ASCII 'A'):"
    int 21h                         ; Display message
    
    ; Access and display byte_var1 using 8-bit register AL
    mov al, byte_var1               ; Move contents of byte_var1 into AL register
                                    ; AL can hold 8 bits (1 byte)
                                    ; byte_var1 is a label representing memory address
                                    ; This loads the VALUE (65) from that address into AL
    
    mov ah, 02h                     ; DOS function 02h: Display single character
    mov dl, al                      ; Move AL (contains 65) into DL for display
                                    ; DL is the register DOS uses for character output
                                    ; 65 is ASCII code for 'A', so 'A' will be displayed
    int 21h                         ; Display character (outputs 'A')
                                    ; DOS interprets value 65 as character 'A'

    ; Display byte_var2 (character 'B')
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg_byte2        ; Display "byte_var2 ('B'):"
    int 21h                         ; Display message
    
    ; Access byte_var2 - demonstrates that bytes can use AH, AL, BH, BL, CH, CL, DH, DL
    mov bl, byte_var2               ; Move byte_var2 into BL register (another 8-bit register)
                                    ; BL is the low byte of BX register
                                    ; Shows that bytes are accessible via multiple 8-bit registers
    
    mov ah, 02h                     ; DOS function 02h: Display character
    mov dl, bl                      ; Move BL (contains 'B') into DL
    int 21h                         ; Display character (outputs 'B')

    ; Demonstrate accessing byte from array
    mov cl, byte_array[0]           ; Access first element of byte_array (value 1)
                                    ; Array indexing:  byte_array[0] means first element
                                    ; CL is another 8-bit register (low byte of CX)
    
    mov cl, byte_array[2]           ; Access third element (value 3)
                                    ; byte_array[2] calculates address as: byte_array + 2
                                    ; Each byte occupies 1 byte, so offset is just the index

    ;---------------------------------------------------------------------------
    ; DEMONSTRATE WORD (DW) VARIABLES
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset newline          ; Print newline for spacing
    int 21h
    
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg_dw           ; Load offset of "WORD (DW) Variables:" message
    int 21h                         ; Display section header
    
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg_word1        ; Display message about word_var1
    int 21h                         ; Display message

    ; Access and display word_var1 (value 1234) - convert to displayable digits
    mov ax, word_var1               ; Move contents of word_var1 into AX register
                                    ; AX can hold 16 bits (2 bytes, 1 word)
                                    ; AX now contains 1234 (04D2h)
                                    ; AX is composed of AH (high byte=04h) and AL (low byte=D2h)
    
    ; To display the number 1234, we need to convert it to ASCII digits
    ; This is complex, so we'll show the general technique
    
    ; Extract thousands digit (1)
    mov dx, 0                       ; Clear DX register (required for division)
                                    ; DIV instruction divides DX:AX by operand
                                    ; Must clear DX or result will be wrong
    mov bx, 1000                    ; BX = 1000 (divisor to get thousands)
    div bx                          ; Divide DX:AX by BX (1234 / 1000 = 1 remainder 234)
                                    ; Quotient (1) goes in AX, remainder (234) goes in DX
    
    add al, 30h                     ; Convert digit to ASCII (1 + 48 = 49 = '1')
                                    ; ASCII codes: '0'=48, '1'=49, '2'=50, etc.
    mov dl, al                      ; Move ASCII digit to DL for display
    push dx                         ; Save remainder (234) on stack for later
    mov ah, 02h                     ; DOS function 02h: Display character
    int 21h                         ; Display '1' (thousands digit)
    
    ; Extract hundreds digit (2)
    pop dx                          ; Restore remainder (234) from stack into DX
    mov ax, dx                      ; Move 234 into AX for next division
    mov dx, 0                       ; Clear DX again
    mov bx, 100                     ; BX = 100 (divisor to get hundreds)
    div bx                          ; Divide 234 / 100 = 2 remainder 34
    
    add al, 30h                     ; Convert to ASCII (2 + 48 = '2')
    mov dl, al                      ; Move to DL
    push dx                         ; Save remainder (34) on stack
    mov ah, 02h                     ; DOS function 02h
    int 21h                         ; Display '2' (hundreds digit)
    
    ; Extract tens digit (3)
    pop dx                          ; Restore remainder (34)
    mov ax, dx                      ; Move 34 into AX
    mov dx, 0                       ; Clear DX
    mov bx, 10                      ; BX = 10 (divisor to get tens)
    div bx                          ; Divide 34 / 10 = 3 remainder 4
    
    add al, 30h                     ; Convert to ASCII (3 + 48 = '3')
    mov dl, al                      ; Move to DL
    push dx                         ; Save remainder (4)
    mov ah, 02h                     ; DOS function 02h
    int 21h                         ; Display '3' (tens digit)
    
    ; Display ones digit (4)
    pop dx                          ; Restore remainder (4)
    add dl, 30h                     ; Convert to ASCII (4 + 48 = '4')
    mov ah, 02h                     ; DOS function 02h
    int 21h                         ; Display '4' (ones digit)
                                    ; Complete number 1234 is now displayed! 

    ; Demonstrate that words can use AX, BX, CX, DX
    mov bx, word_var2               ; Load word_var2 into BX register (16-bit register)
                                    ; BX can also hold words
    mov cx, word_var3               ; Load word_var3 into CX register (16-bit register)
    mov dx, word_max                ; Load word_max into DX register (16-bit register)
                                    ; All 16-bit registers (AX, BX, CX, DX) can hold words

    ; Access word from array
    mov ax, word_array[0]           ; Access first word (100)
                                    ; word_array[0] = address of word_array + (0 * 2 bytes)
    mov bx, word_array[2]           ; Access second word (200)
                                    ; word_array[2] = address of word_array + (2 * 1) = +2 bytes
                                    ; Even though index is [1], offset is *2 because words are 2 bytes
    mov cx, word_array[4]           ; Access third word (300)
                                    ; word_array[4] = +4 bytes offset

    ;---------------------------------------------------------------------------
    ; DEMONSTRATE DOUBLE WORD (DD) VARIABLES
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h:  Display string
    mov dx, offset newline          ; Print newline
    int 21h
    
    mov ah, 09h                     ; DOS function 09h:  Display string
    mov dx, offset msg_dd           ; Load offset of "DOUBLE WORD (DD) Variables:" message
    int 21h                         ; Display section header
    
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg_dword1       ; Display message about dword_var1
    int 21h                         ; Display message

    ; Access double word (32-bit value) using register pairs
    ; In 16-bit mode, we need TWO 16-bit registers to hold a 32-bit value
    
    mov ax, word ptr dword_var1[0]  ; Load LOW word (first 2 bytes) into AX
                                    ; word ptr tells assembler to treat as 16-bit word
                                    ; dword_var1[0] = first 2 bytes (bits 0-15)
                                    ; For value 123456 (0001E240h):
                                    ; AX gets E240h (low word)
    
    mov dx, word ptr dword_var1[2]  ; Load HIGH word (next 2 bytes) into DX
                                    ; dword_var1[2] = bytes at offset +2 (bits 16-31)
                                    ; DX gets 0001h (high word)
                                    ; Together, DX: AX = 0001E240h = 123456
                                    ; DX: AX is the standard way to represent 32-bit values
                                    ; DX holds high 16 bits, AX holds low 16 bits

    ; Alternative access method - load entire 32-bit value at once (requires 386+)
    ; In 16-bit real mode, we typically work with 16-bit chunks
    ; But we can show the concept: 
    
    mov bx, word ptr dword_var2[0]  ; Load low word of dword_var2 into BX
    mov cx, word ptr dword_var2[2]  ; Load high word of dword_var2 into CX
                                    ; Now CX: BX contains the 32-bit value
                                    ; This demonstrates that DW can be stored like "bh & bl"
                                    ; but DD would be stored like "dx & ax" or "cx & bx"

    ;---------------------------------------------------------------------------
    ; MEMORY LAYOUT DEMONSTRATION
    ;---------------------------------------------------------------------------
    ; Let's show how these are actually stored in memory
    ; Assume byte_var1 is at address 1000h: 
    ;
    ; Address | Value | Variable
    ; --------|-------|----------
    ; 1000h   | 41h   | byte_var1 (65 decimal = 41h = 'A')
    ; 1001h   | 42h   | byte_var2 (66 decimal = 42h = 'B')
    ; 1002h   | FFh   | byte_var3 (255)
    ; 1003h   | 80h   | byte_var4 (-128 in 2's complement)
    ;
    ; For word_var1 (1234 = 04D2h) at address 2000h (little-endian):
    ; 2000h   | D2h   | word_var1 LOW byte
    ; 2001h   | 04h   | word_var1 HIGH byte
    ;
    ; For dword_var1 (123456 = 0001E240h) at address 3000h: 
    ; 3000h   | 40h   | dword_var1 byte 0 (lowest)
    ; 3001h   | E2h   | dword_var1 byte 1
    ; 3002h   | 01h   | dword_var1 byte 2
    ; 3003h   | 00h   | dword_var1 byte 3 (highest)

    ;---------------------------------------------------------------------------
    ; Wait for User Input
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset press_key        ; Load "Press any key" message
    int 21h                         ; Display message
    
    mov ah, 01h                     ; DOS function 01h: Read character from keyboard
    int 21h                         ; Wait for keypress

    ;---------------------------------------------------------------------------
    ; Exit Program
    ;---------------------------------------------------------------------------
    mov ah, 4ch                     ; DOS function 4Ch:  Terminate program with return code
    int 21h                         ; Call DOS interrupt to exit program and return to DOS
end                                 ; End of program (marks end of source code for assembler)

;===============================================================================
; VARIABLE TYPE SUMMARY
;===============================================================================
; 
; DB (Define Byte) - 8 bits (1 byte):
;   - Range: 0-255 (unsigned) or -128 to 127 (signed)
;   - Registers: AL, BL, CL, DL, AH, BH, CH, DH
;   - Example: byte_var db 100
;   - Memory: 1 byte
;
; DW (Define Word) - 16 bits (2 bytes):
;   - Range: 0-65535 (unsigned) or -32768 to 32767 (signed)
;   - Registers: AX, BX, CX, DX, SI, DI, BP, SP
;   - Example: word_var dw 1000
;   - Memory: 2 bytes (little-endian:  low byte first)
;
; DD (Define Double Word) - 32 bits (4 bytes):
;   - Range: 0-4294967295 (unsigned)
;   - Registers: DX: AX (high: low pair) or EAX (386+)
;   - Example: dword_var dd 100000
;   - Memory: 4 bytes (little-endian)
;
; Note: x86 is little-endian
;   - Lowest byte stored at lowest address
;   - Example: 1234h stored as [34h][12h]
;
;===============================================================================