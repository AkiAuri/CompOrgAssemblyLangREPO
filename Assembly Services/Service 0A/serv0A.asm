;===============================================================================
; PROGRAM: Service 0Ah - Write Character Only at Cursor Position
; PURPOSE:  Demonstrates INT 10h, AH=0Ah (Write Character Only)
; DESCRIPTION: This service writes a character (or multiple copies) at the
;              cursor position using the CURRENT attribute (color already there).
;              Unlike Service 09h, this does NOT change the color attribute.
;===============================================================================

.model small                        ; Define memory model as 'small' (code and data each fit in 64KB)
.stack 100h                         ; Allocate 256 bytes (100h) for the stack

.data                               ; Start of data segment (where variables and constants are stored)
    title_msg db "Write Character Only (Service 0Ah) Demo",10,13,10,13,"$"
    
    msg1 db "Difference between Service 09h and 0Ah:",10,13,10,13,"$"
    msg2 db "Using Service 09h (with attribute): $"
    msg3 db 10,13,"Using Service 0Ah (current attribute): $"
    msg4 db 10,13,10,13,"Demo:  Writing over colored background",10,13,"$"
    msg5 db "Background created with Service 09h",10,13,"$"
    msg6 db "Now overwriting with Service 0Ah.. .",10,13,10,13,"$"
    msg7 db 10,13,10,13,"Service 0Ah preserves existing colors! ",10,13,"$"
    
    msg_exit db 10,13,"Press any key to exit...$"

.code                               ; Start of code segment (where program instructions are stored)
    mov ax, @data                   ; Load the address of data segment into AX register
    mov ds, ax                      ; Move AX value into DS (Data Segment register) to access variables

    ;---------------------------------------------------------------------------
    ; SERVICE 0Ah vs SERVICE 09h EXPLANATION
    ;---------------------------------------------------------------------------
    ; Service 09h (AH=09h):
    ;   - Writes character WITH attribute (color)
    ;   - Changes both character AND color at position
    ;   - You specify the color in BL register
    ;   - Useful when you want to set specific colors
    ;
    ; Service 0Ah (AH=0Ah):
    ;   - Writes character WITHOUT changing attribute
    ;   - Only changes the character, keeps existing color
    ;   - BL register is ignored (color not changed)
    ;   - Useful for:  
    ;     * Overwriting text while preserving colors
    ;     * Drawing on colored backgrounds
    ;     * Updating text in colored areas
    ;---------------------------------------------------------------------------

    ;---------------------------------------------------------------------------
    ; Clear Screen
    ;---------------------------------------------------------------------------
    mov ah, 00h                     ; AH = 00h: Set video mode
    mov al, 03h                     ; AL = 03h: 80x25 text mode
    int 10h                         ; Clear screen and reset cursor

    ;---------------------------------------------------------------------------
    ; Display Title and Introduction
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h: Display string terminated by '$'
    mov dx, offset title_msg        ; Load offset address of title
    int 21h                         ; Display title
    
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg1             ; Load offset of explanation message
    int 21h                         ; Display "Difference between..."

    ;---------------------------------------------------------------------------
    ; Demo 1: Using Service 09h (WITH attribute)
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg2             ; Load offset of message
    int 21h                         ; Display "Using Service 09h..."
    
    ; SERVICE 09h - Write 'X' with specific attribute (yellow on red)
    mov ah, 09h                     ; AH = 09h:  BIOS function - Write char WITH attribute
    mov al, 'X'                     ; AL = 'X': Character to write
    mov bh, 00h                     ; BH = 00h: Display page 0
    mov bl, 4Eh                     ; BL = 4Eh:  Attribute byte
                                    ; 4Eh = 0100 1110 binary
                                    ; Background (bits 6-4) = 0100 = Red (4)
                                    ; Foreground (bits 3-0) = 1110 = Yellow (14)
                                    ; Result: Yellow 'X' on red background
    mov cx, 05h                     ; CX = 05h: Write 5 times
    int 10h                         ; Call BIOS interrupt
                                    ; Five 'X' characters in yellow on red
                                    ; Both character AND color are written
    
    ; Move cursor to next line
    mov ah, 02h                     ; AH = 02h: Set cursor position
    mov bh, 00h                     ; BH = page 0
    mov dh, 07h                     ; DH = row 7
    mov dl, 00h                     ; DL = column 0
    int 10h                         ; Position cursor

    ;---------------------------------------------------------------------------
    ; Demo 2: Using Service 0Ah (WITHOUT attribute - preserves existing color)
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg3             ; Load offset of message
    int 21h                         ; Display "Using Service 0Ah..."
    
    ; First, create a colored background using Service 09h
    mov ah, 09h                     ; AH = 09h: Write char with attribute
    mov al, 219                     ; AL = 219: Block character (█ full block)
    mov bh, 00h                     ; BH = page 0
    mov bl, 2Fh                     ; BL = 2Fh: White on green background
                                    ; This creates a green background
    mov cx, 05h                     ; CX = 5: Create 5 green blocks
    int 10h                         ; Five green blocks created
    
    ; Get current cursor position
    mov ah, 03h                     ; AH = 03h: Get cursor position
    mov bh, 00h                     ; BH = page 0
    int 10h                         ; Returns position in DH, DL
    
    ; Move cursor back to start of green blocks
    sub dl, 05h                     ; Subtract 5 from column (go back 5 positions)
    mov ah, 02h                     ; AH = 02h: Set cursor position
    mov bh, 00h                     ; BH = page 0
                                    ; DH still has correct row
                                    ; DL now points to start of green blocks
    int 10h                         ; Set cursor at start of blocks
    
    ; SERVICE 0Ah - Write 'O' WITHOUT changing color (keeps green background)
    mov ah, 0Ah                     ; AH = 0Ah:  BIOS function - Write char WITHOUT attribute
    mov al, 'O'                     ; AL = 'O': Character to write
    mov bh, 00h                     ; BH = page 0
    mov bl, 04h                     ; BL = 04h: This value is IGNORED by Service 0Ah
                                    ; The existing attribute (green background) is preserved
                                    ; Service 0Ah does not use BL register
    mov cx, 05h                     ; CX = 5: Write 5 'O' characters
    int 10h                         ; Call BIOS interrupt
                                    ; Five 'O' characters written
                                    ; They appear in WHITE on GREEN (existing attribute preserved)
                                    ; Only the character changed, NOT the color

    ;---------------------------------------------------------------------------
    ; Demo 3: Writing on Colored Background - Practical Example
    ;---------------------------------------------------------------------------
    ; Move to next section
    mov ah, 02h                     ; AH = 02h: Set cursor position
    mov bh, 00h                     ; BH = page 0
    mov dh, 09h                     ; DH = row 9
    mov dl, 00h                     ; DL = column 0
    int 10h                         ; Position cursor
    
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg4             ; Load offset of message
    int 21h                         ; Display "Demo: Writing over colored background"
    
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg5             ; Load offset of message
    int 21h                         ; Display "Background created with Service 09h"

    ;---------------------------------------------------------------------------
    ; Create a colorful background strip using Service 09h
    ;---------------------------------------------------------------------------
    mov ah, 02h                     ; AH = 02h: Set cursor position
    mov bh, 00h                     ; BH = page 0
    mov dh, 0Ch                     ; DH = row 12
    mov dl, 0Ah                     ; DL = column 10
    int 10h                         ; Position cursor
    
    ; Create RED background section
    mov ah, 09h                     ; AH = 09h: Write char with attribute
    mov al, ' '                     ; AL = space (shows background color better)
    mov bh, 00h                     ; BH = page 0
    mov bl, 4Fh                     ; BL = White on red background
    mov cx, 0Ah                     ; CX = 10 spaces
    int 10h                         ; Ten red background spaces
    
    ; Move cursor forward
    mov ah, 03h                     ; AH = 03h: Get cursor position
    mov bh, 00h                     ; BH = page 0
    int 10h                         ; Get position
    add dl, 0Ah                     ; Add 10 to column
    mov ah, 02h                     ; AH = 02h: Set cursor position
    mov bh, 00h                     ; BH = page 0
    int 10h                         ; Set position
    
    ; Create BLUE background section
    mov ah, 09h                     ; AH = 09h: Write char with attribute
    mov al, ' '                     ; AL = space
    mov bh, 00h                     ; BH = page 0
    mov bl, 1Fh                     ; BL = White on blue background
    mov cx, 0Ah                     ; CX = 10 spaces
    int 10h                         ; Ten blue background spaces
    
    ; Move cursor forward
    mov ah, 03h                     ; AH = 03h: Get cursor position
    mov bh, 00h                     ; BH = page 0
    int 10h                         ; Get position
    add dl, 0Ah                     ; Add 10 to column
    mov ah, 02h                     ; AH = 02h: Set cursor position
    mov bh, 00h                     ; BH = page 0
    int 10h                         ; Set position
    
    ; Create GREEN background section
    mov ah, 09h                     ; AH = 09h: Write char with attribute
    mov al, ' '                     ; AL = space
    mov bh, 00h                     ; BH = page 0
    mov bl, 2Fh                     ; BL = White on green background
    mov cx, 0Ah                     ; CX = 10 spaces
    int 10h                         ; Ten green background spaces

    ;---------------------------------------------------------------------------
    ; Display message before overwriting
    ;---------------------------------------------------------------------------
    mov ah, 02h                     ; AH = 02h: Set cursor position
    mov bh, 00h                     ; BH = page 0
    mov dh, 0Eh                     ; DH = row 14
    mov dl, 00h                     ; DL = column 0
    int 10h                         ; Position cursor
    
    mov ah, 09h                     ; DOS function 09h:  Display string
    mov dx, offset msg6             ; Load offset of message
    int 21h                         ; Display "Now overwriting with Service 0Ah..."
    
    ; Wait for keypress to see the effect
    mov ah, 01h                     ; DOS function 01h: Read character
    int 21h                         ; Wait for keypress

    ;---------------------------------------------------------------------------
    ; Use Service 0Ah to write text OVER the colored backgrounds
    ;---------------------------------------------------------------------------
    ; Position cursor at start of RED section
    mov ah, 02h                     ; AH = 02h: Set cursor position
    mov bh, 00h                     ; BH = page 0
    mov dh, 0Ch                     ; DH = row 12 (same as colored strip)
    mov dl, 0Ch                     ; DL = column 12 (middle of red section)
    int 10h                         ; Position cursor
    
    ; SERVICE 0Ah - Write 'ABC' over red background (preserves red)
    mov ah, 0Ah                     ; AH = 0Ah: Write char only (no attribute change)
    mov al, 'A'                     ; AL = 'A'
    mov bh, 00h                     ; BH = page 0
    mov cx, 01h                     ; CX = 1
    int 10h                         ; Write 'A' - appears in red background color
    
    mov ah, 03h                     ; Get cursor position
    mov bh, 00h
    int 10h
    inc dl                          ; Move right
    mov ah, 02h                     ; Set cursor position
    mov bh, 00h
    int 10h
    
    mov ah, 0Ah                     ; AH = 0Ah: Write char only
    mov al, 'B'                     ; AL = 'B'
    mov bh, 00h                     ; BH = page 0
    mov cx, 01h                     ; CX = 1
    int 10h                         ; Write 'B' - preserves red background
    
    mov ah, 03h                     ; Get cursor position
    mov bh, 00h
    int 10h
    inc dl                          ; Move right
    mov ah, 02h                     ; Set cursor position
    mov bh, 00h
    int 10h
    
    mov ah, 0Ah                     ; AH = 0Ah: Write char only
    mov al, 'C'                     ; AL = 'C'
    mov bh, 00h                     ; BH = page 0
    mov cx, 01h                     ; CX = 1
    int 10h                         ; Write 'C' - preserves red background
    
    ; Position cursor at BLUE section
    mov ah, 02h                     ; AH = 02h: Set cursor position
    mov bh, 00h                     ; BH = page 0
    mov dh, 0Ch                     ; DH = row 12
    mov dl, 1Ch                     ; DL = column 28 (middle of blue section)
    int 10h                         ; Position cursor
    
    ; Write '123' over blue background
    mov ah, 0Ah                     ; AH = 0Ah: Write char only
    mov al, '1'                     ; AL = '1'
    mov bh, 00h                     ; BH = page 0
    mov cx, 01h                     ; CX = 1
    int 10h                         ; Write '1' - preserves blue background
    
    mov ah, 03h                     ; Get cursor position
    mov bh, 00h
    int 10h
    inc dl                          ; Move right
    mov ah, 02h                     ; Set cursor position
    mov bh, 00h
    int 10h
    
    mov ah, 0Ah                     ; AH = 0Ah: Write char only
    mov al, '2'                     ; AL = '2'
    mov bh, 00h                     ; BH = page 0
    mov cx, 01h                     ; CX = 1
    int 10h                         ; Write '2' - preserves blue background
    
    mov ah, 03h                     ; Get cursor position
    mov bh, 00h
    int 10h
    inc dl                          ; Move right
    mov ah, 02h                     ; Set cursor position
    mov bh, 00h
    int 10h
    
    mov ah, 0Ah                     ; AH = 0Ah:  Write char only
    mov al, '3'                     ; AL = '3'
    mov bh, 00h                     ; BH = page 0
    mov cx, 01h                     ; CX = 1
    int 10h                         ; Write '3' - preserves blue background
    
    ; Position cursor at GREEN section
    mov ah, 02h                     ; AH = 02h: Set cursor position
    mov bh, 00h                     ; BH = page 0
    mov dh, 0Ch                     ; DH = row 12
    mov dl, 2Ch                     ; DL = column 44 (middle of green section)
    int 10h                         ; Position cursor
    
    ; Write 'XYZ' over green background
    mov ah, 0Ah                     ; AH = 0Ah: Write char only
    mov al, 'X'                     ; AL = 'X'
    mov bh, 00h                     ; BH = page 0
    mov cx, 01h                     ; CX = 1
    int 10h                         ; Write 'X' - preserves green background
    
    mov ah, 03h                     ; Get cursor position
    mov bh, 00h
    int 10h
    inc dl                          ; Move right
    mov ah, 02h                     ; Set cursor position
    mov bh, 00h
    int 10h
    
    mov ah, 0Ah                     ; AH = 0Ah: Write char only
    mov al, 'Y'                     ; AL = 'Y'
    mov bh, 00h                     ; BH = page 0
    mov cx, 01h                     ; CX = 1
    int 10h                         ; Write 'Y' - preserves green background
    
    mov ah, 03h                     ; Get cursor position
    mov bh, 00h
    int 10h
    inc dl                          ; Move right
    mov ah, 02h                     ; Set cursor position
    mov bh, 00h
    int 10h
    
    mov ah, 0Ah                     ; AH = 0Ah: Write char only
    mov al, 'Z'                     ; AL = 'Z'
    mov bh, 00h                     ; BH = page 0
    mov cx, 01h                     ; CX = 1
    int 10h                         ; Write 'Z' - preserves green background

    ;---------------------------------------------------------------------------
    ; Display final message
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg7             ; Load offset of message
    int 21h                         ; Display "Service 0Ah preserves existing colors!"

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
; SERVICE 0Ah REFERENCE
;===============================================================================
; INT 10h, AH=0Ah - Write Character Only at Cursor Position
;
; INPUT:
;   AH = 0Ah (function number)
;   AL = Character to write (ASCII code)
;   BH = Display page number (usually 0)
;   BL = NOT USED (ignored, existing attribute preserved)
;   CX = Repeat count (number of times to write character)
;
; OUTPUT:
;   None (character displayed on screen with existing attribute)
;
; KEY DIFFERENCES FROM SERVICE 09h:
;   Service 09h (AH=09h):
;     - Writes character AND attribute (changes color)
;     - BL register specifies new color attribute
;     - Both character and color are updated
;
;   Service 0Ah (AH=0Ah):
;     - Writes character ONLY (preserves existing color)
;     - BL register is ignored
;     - Only character is updated, color remains unchanged
;
; COMMON USES:
;   - Overwriting text on colored backgrounds
;   - Updating characters in colored dialog boxes
;   - Drawing on pre-colored areas without changing colors
;   - Text animation while preserving background colors
;   - Updating status displays with colored backgrounds
;
; NOTES:
;   - Cursor position does NOT advance (must move manually)
;   - Character written CX times starting at cursor position
;   - Existing attribute (color) at position is preserved
;   - Does not interpret control characters (like newline)
;   - Only works in text modes
;   - More efficient than Service 09h when color doesn't need changing
;===============================================================================