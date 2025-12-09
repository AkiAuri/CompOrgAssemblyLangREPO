;===============================================================================
; PROGRAM:  Service 09h - Write Character and Attribute at Cursor Position
; PURPOSE:  Demonstrates INT 10h, AH=09h (Write Character with Attribute)
; DESCRIPTION: This service writes a character (or multiple copies) at the
;              current cursor position with a specified color attribute.
;              The cursor position does NOT advance automatically.
;===============================================================================

.model small                        ; Define memory model as 'small' (code and data each fit in 64KB)
.stack 100h                         ; Allocate 256 bytes (100h) for the stack

.data                               ; Start of data segment (where variables and constants are stored)
    title_msg db "Write Character with Attribute Demo",10,13,10,13,"$"
    
    demo1_msg db "1. Single red 'A':  $"
    demo2_msg db 10,13,"2. Five green 'B' characters: $"
    demo3_msg db 10,13,"3. Ten yellow on blue 'C': $"
    demo4_msg db 10,13,"4. Rainbow text (different colors): $"
    demo5_msg db 10,13,10,13,"5. Blinking text: $"
    demo6_msg db 10,13,10,13,"6. Background colors: $"
    
    msg_exit db 10,13,10,13,"Press any key to exit...$"
    
    ; Array of characters for rainbow demo
    rainbow_chars db "RAINBOW$"
    ; Array of color attributes for rainbow (each letter different color)
    rainbow_colors db 0Ch, 0Eh, 0Ah, 0Bh, 09h, 0Dh, 0Ch  ; Red, Yellow, Green, Cyan, Blue, Magenta, Red

.code                               ; Start of code segment (where program instructions are stored)
    mov ax, @data                   ; Load the address of data segment into AX register
    mov ds, ax                      ; Move AX value into DS (Data Segment register) to access variables

    ;---------------------------------------------------------------------------
    ; Clear Screen
    ;---------------------------------------------------------------------------
    mov ah, 00h                     ; AH = 00h: Set video mode
    mov al, 03h                     ; AL = 03h: 80x25 text mode
    int 10h                         ; Clear screen and reset cursor

    ;---------------------------------------------------------------------------
    ; Display Title
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h:  Display string terminated by '$'
    mov dx, offset title_msg        ; Load offset address of title
    int 21h                         ; Display title

    ;---------------------------------------------------------------------------
    ; COLOR ATTRIBUTE EXPLANATION
    ;---------------------------------------------------------------------------
    ; The attribute byte (BL register) controls text appearance:
    ;
    ; Bit layout:  IBBBFFFF
    ;   I (bit 7): Blink enable (1=blink, 0=no blink)
    ;   BBB (bits 6-4): Background color (0-7)
    ;   FFFF (bits 3-0): Foreground color (0-15)
    ;
    ; Foreground Colors (0-15):
    ;   0=Black    1=Blue      2=Green     3=Cyan
    ;   4=Red      5=Magenta   6=Brown     7=Light Gray
    ;   8=Dark Gray  9=Light Blue  10=Light Green  11=Light Cyan
    ;   12=Light Red  13=Light Magenta  14=Yellow  15=White
    ;
    ; Background Colors (0-7, shifted left 4 bits):
    ;   0=Black    1=Blue      2=Green     3=Cyan
    ;   4=Red      5=Magenta   6=Brown     7=Light Gray
    ;
    ; Examples:
    ;   07h = White on Black (0000 0111)
    ;   1Fh = White on Blue (0001 1111)
    ;   4Eh = Yellow on Red (0100 1110)
    ;   8Fh = Blinking White on Black (1000 1111)
    ;---------------------------------------------------------------------------

    ;---------------------------------------------------------------------------
    ; Demo 1: Write Single Character with Color
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset demo1_msg        ; Load offset of demo 1 message
    int 21h                         ; Display "1. Single red 'A':"
    
    ; SERVICE 09h - Write 'A' in red
    mov ah, 09h                     ; AH = 09h:  BIOS function to write character with attribute
    mov al, 'A'                     ; AL = 'A': Character to write
    mov bh, 00h                     ; BH = 00h: Display page number (page 0 for text mode)
                                    ; Text mode typically uses page 0
                                    ; Multiple pages allow screen buffering
    mov bl, 04h                     ; BL = 04h: Attribute byte
                                    ; 04h = 0000 0100 binary
                                    ; Background (bits 6-4) = 000 = Black (0)
                                    ; Foreground (bits 3-0) = 0100 = Red (4)
                                    ; Result: Red text on black background
    mov cx, 01h                     ; CX = 01h:  Repeat count (write character 1 time)
                                    ; CX specifies how many times to write the character
                                    ; Useful for drawing lines or filling areas
    int 10h                         ; Call BIOS interrupt 10h (Video Services)
                                    ; Character 'A' is written in red at cursor position
                                    ; IMPORTANT: Cursor position does NOT move! 
    
    ; Move cursor forward manually (Service 09h doesn't advance cursor)
    mov ah, 03h                     ; AH = 03h: Get cursor position
    mov bh, 00h                     ; BH = page 0
    int 10h                         ; Returns position in DH (row), DL (column)
    
    inc dl                          ; Increment column position (move right 1 position)
    mov ah, 02h                     ; AH = 02h: Set cursor position
    mov bh, 00h                     ; BH = page 0
                                    ; DH still contains row (unchanged)
                                    ; DL now contains column+1
    int 10h                         ; Set new cursor position

    ;---------------------------------------------------------------------------
    ; Demo 2: Write Multiple Characters (Repeat Count)
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h:  Display string
    mov dx, offset demo2_msg        ; Load offset of demo 2 message
    int 21h                         ; Display "2. Five green 'B' characters:"
    
    ; SERVICE 09h - Write 'B' five times in green
    mov ah, 09h                     ; AH = 09h: Write character with attribute
    mov al, 'B'                     ; AL = 'B': Character to write
    mov bh, 00h                     ; BH = page 0
    mov bl, 02h                     ; BL = 02h: Attribute
                                    ; 02h = 0000 0010 binary
                                    ; Background = 000 = Black (0)
                                    ; Foreground = 0010 = Green (2)
                                    ; Result: Green text on black background
    mov cx, 05h                     ; CX = 05h: Write character 5 times
                                    ; This creates "BBBBB" in green
                                    ; All 5 B's start at current cursor position
                                    ; They overwrite each other unless cursor moves
    int 10h                         ; Call BIOS interrupt
                                    ; Five 'B' characters written horizontally in green
    
    ; Move cursor forward by 5 positions
    mov ah, 03h                     ; AH = 03h: Get cursor position
    mov bh, 00h                     ; BH = page 0
    int 10h                         ; Get current position
    
    add dl, 05h                     ; Add 5 to column (skip over the 5 B's)
    mov ah, 02h                     ; AH = 02h: Set cursor position
    mov bh, 00h                     ; BH = page 0
    int 10h                         ; Set new cursor position

    ;---------------------------------------------------------------------------
    ; Demo 3: Character with Background Color
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h:  Display string
    mov dx, offset demo3_msg        ; Load offset of demo 3 message
    int 21h                         ; Display "3. Ten yellow on blue 'C':"
    
    ; SERVICE 09h - Write 'C' ten times in yellow on blue background
    mov ah, 09h                     ; AH = 09h: Write character with attribute
    mov al, 'C'                     ; AL = 'C':  Character to write
    mov bh, 00h                     ; BH = page 0
    mov bl, 1Eh                     ; BL = 1Eh: Attribute
                                    ; 1Eh = 0001 1110 binary
                                    ; Background (bits 6-4) = 001 = Blue (1)
                                    ; Foreground (bits 3-0) = 1110 = Yellow (14)
                                    ; Result:  Yellow text on blue background
                                    ; To calculate: (background * 16) + foreground
                                    ; (1 * 16) + 14 = 30 = 1Eh
    mov cx, 0Ah                     ; CX = 0Ah (10 decimal): Write 10 times
                                    ; Creates "CCCCCCCCCC" in yellow on blue
    int 10h                         ; Call BIOS interrupt
                                    ; Ten 'C' characters with yellow on blue
    
    ; Move cursor forward by 10 positions
    mov ah, 03h                     ; AH = 03h: Get cursor position
    mov bh, 00h                     ; BH = page 0
    int 10h                         ; Get current position
    
    add dl, 0Ah                     ; Add 10 to column
    mov ah, 02h                     ; AH = 02h: Set cursor position
    mov bh, 00h                     ; BH = page 0
    int 10h                         ; Set new cursor position

    ;---------------------------------------------------------------------------
    ; Demo 4: Rainbow Text (Different Colors for Each Character)
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset demo4_msg        ; Load offset of demo 4 message
    int 21h                         ; Display "4. Rainbow text:"
    
    ; Loop through "RAINBOW" string, each letter in different color
    mov si, 0                       ; SI = 0: Index for character array
    mov di, 0                       ; DI = 0: Index for color array
    
rainbow_loop:                       ; Label for rainbow loop
    mov al, rainbow_chars[si]       ; Load character from rainbow_chars array
                                    ; SI is the index (0, 1, 2, ...)
                                    ; First iteration: AL = 'R'
    cmp al, '$'                     ; Check if end of string ($ terminator)
    je rainbow_done                 ; If end, jump to rainbow_done
    
    ; SERVICE 09h - Write character in specific color
    mov ah, 09h                     ; AH = 09h: Write character with attribute
                                    ; AL already contains character from array
    mov bh, 00h                     ; BH = page 0
    mov bl, rainbow_colors[di]      ; Load color attribute from rainbow_colors array
                                    ; DI is the index for colors
                                    ; Each character gets a different color
    mov cx, 01h                     ; CX = 1: Write once
    int 10h                         ; Call BIOS interrupt
                                    ; Character written in its specific color
    
    ; Move cursor forward 1 position for next character
    mov ah, 03h                     ; AH = 03h: Get cursor position
    mov bh, 00h                     ; BH = page 0
    int 10h                         ; Get current position
    
    inc dl                          ; Increment column (move right)
    mov ah, 02h                     ; AH = 02h: Set cursor position
    mov bh, 00h                     ; BH = page 0
    int 10h                         ; Set new cursor position
    
    inc si                          ; Increment character index
    inc di                          ; Increment color index
    jmp rainbow_loop                ; Jump back to process next character
    
rainbow_done:                       ; Label when rainbow text is complete

    ;---------------------------------------------------------------------------
    ; Demo 5: Blinking Text
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset demo5_msg        ; Load offset of demo 5 message
    int 21h                         ; Display "5. Blinking text:"
    
    ; SERVICE 09h - Write blinking text
    mov ah, 09h                     ; AH = 09h: Write character with attribute
    mov al, '*'                     ; AL = '*':  Star character
    mov bh, 00h                     ; BH = page 0
    mov bl, 8Ch                     ; BL = 8Ch: Attribute with blink
                                    ; 8Ch = 1000 1100 binary
                                    ; Bit 7 = 1: Blink enabled
                                    ; Background (bits 6-4) = 000 = Black (0)
                                    ; Foreground (bits 3-0) = 1100 = Light Red (12)
                                    ; Result:  Blinking light red star on black
                                    ; To enable blink: Add 80h (128) to normal attribute
                                    ; 0Ch (light red) + 80h (blink) = 8Ch
    mov cx, 06h                     ; CX = 6: Write 6 stars
    int 10h                         ; Call BIOS interrupt
                                    ; Six blinking stars displayed
                                    ; NOTE: Blinking may not work on all modern systems
    
    ; Move cursor forward
    mov ah, 03h                     ; AH = 03h: Get cursor position
    mov bh, 00h                     ; BH = page 0
    int 10h                         ; Get current position
    
    add dl, 06h                     ; Add 6 to column
    mov ah, 02h                     ; AH = 02h: Set cursor position
    mov bh, 00h                     ; BH = page 0
    int 10h                         ; Set new cursor position

    ;---------------------------------------------------------------------------
    ; Demo 6: Various Background Colors
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset demo6_msg        ; Load offset of demo 6 message
    int 21h                         ; Display "6. Background colors:"
    
    ; Write character with RED background
    mov ah, 09h                     ; AH = 09h: Write character with attribute
    mov al, ' '                     ; AL = ' ': Space character (shows background better)
    mov bh, 00h                     ; BH = page 0
    mov bl, 4Fh                     ; BL = 4Fh: White on red background
                                    ; 4Fh = 0100 1111 binary
                                    ; Background = 0100 = Red (4)
                                    ; Foreground = 1111 = White (15)
    mov cx, 03h                     ; CX = 3: Write 3 spaces
    int 10h                         ; Three spaces with red background
    
    ; Move cursor forward
    mov ah, 03h                     ; AH = 03h: Get cursor position
    mov bh, 00h                     ; BH = page 0
    int 10h                         ; Get position
    add dl, 03h                     ; Move 3 columns
    mov ah, 02h                     ; AH = 02h: Set cursor position
    mov bh, 00h                     ; BH = page 0
    int 10h                         ; Set position
    
    ; Write character with GREEN background
    mov ah, 09h                     ; AH = 09h: Write character with attribute
    mov al, ' '                     ; AL = space
    mov bh, 00h                     ; BH = page 0
    mov bl, 2Fh                     ; BL = 2Fh: White on green background
                                    ; Background = 0010 = Green (2)
                                    ; Foreground = 1111 = White (15)
    mov cx, 03h                     ; CX = 3
    int 10h                         ; Three spaces with green background
    
    ; Move cursor forward
    mov ah, 03h                     ; AH = 03h: Get cursor position
    mov bh, 00h                     ; BH = page 0
    int 10h                         ; Get position
    add dl, 03h                     ; Move 3 columns
    mov ah, 02h                     ; AH = 02h:  Set cursor position
    mov bh, 00h                     ; BH = page 0
    int 10h                         ; Set position
    
    ; Write character with CYAN background
    mov ah, 09h                     ; AH = 09h: Write character with attribute
    mov al, ' '                     ; AL = space
    mov bh, 00h                     ; BH = page 0
    mov bl, 30h                     ; BL = 30h: Black on cyan background
                                    ; Background = 0011 = Cyan (3)
                                    ; Foreground = 0000 = Black (0)
    mov cx, 03h                     ; CX = 3
    int 10h                         ; Three spaces with cyan background
    
    ; Move cursor forward
    mov ah, 03h                     ; AH = 03h: Get cursor position
    mov bh, 00h                     ; BH = page 0
    int 10h                         ; Get position
    add dl, 03h                     ; Move 3 columns
    mov ah, 02h                     ; AH = 02h:  Set cursor position
    mov bh, 00h                     ; BH = page 0
    int 10h                         ; Set position
    
    ; Write character with MAGENTA background
    mov ah, 09h                     ; AH = 09h: Write character with attribute
    mov al, ' '                     ; AL = space
    mov bh, 00h                     ; BH = page 0
    mov bl, 5Fh                     ; BL = 5Fh: White on magenta background
                                    ; Background = 0101 = Magenta (5)
                                    ; Foreground = 1111 = White (15)
    mov cx, 03h                     ; CX = 3
    int 10h                         ; Three spaces with magenta background

    ;---------------------------------------------------------------------------
    ; Display Exit Message and Wait
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg_exit         ; Load offset of exit message
    int 21h                         ; Display "Press any key to exit..."
    
    mov ah, 01h                     ; DOS function 01h: Read character
    int 21h                         ; Wait for keypress

    ;---------------------------------------------------------------------------
    ; Exit Program
    ;---------------------------------------------------------------------------
    mov ah, 4ch                     ; DOS function 4Ch:  Terminate program
    int 21h                         ; Call DOS interrupt to exit
end                                 ; End of program

;===============================================================================
; SERVICE 09h REFERENCE
;===============================================================================
; INT 10h, AH=09h - Write Character and Attribute at Cursor Position
;
; INPUT:
;   AH = 09h (function number)
;   AL = Character to write (ASCII code)
;   BH = Display page number (usually 0)
;   BL = Attribute (color) byte
;        Bit 7: Blink (1=blink, 0=normal)
;        Bits 6-4: Background color (0-7)
;        Bits 3-0: Foreground color (0-15)
;   CX = Repeat count (number of times to write character)
;
; OUTPUT:
;   None (character displayed on screen)
;
; NOTES:
;   - Cursor position does NOT advance (must move manually)
;   - Character written CX times starting at cursor position
;   - If CX > 1, characters written horizontally
;   - Does not interpret control characters (like newline)
;   - Only works in text modes
;   - Attribute byte format:  IBBBFFFF (I=blink, BBB=bg, FFFF=fg)
;
; ATTRIBUTE BYTE CALCULATION:
;   attribute = (blink * 128) + (background * 16) + foreground
;   Example:  Blinking yellow on blue = 128 + (1*16) + 14 = 158 = 9Eh
;
; COMMON ATTRIBUTES:
;   07h = White on Black (default)
;   0Fh = Bright White on Black
;   70h = Black on White (inverse)
;   1Fh = White on Blue
;   2Eh = Yellow on Green
;   4Eh = Yellow on Red
;   8Fh = Blinking White on Black
;===============================================================================