;===============================================================================
; PROGRAM: Service 01h - Set Cursor Shape
; PURPOSE:  Demonstrates INT 10h, AH=01h (Set Cursor Shape)
; DESCRIPTION: This program shows how to modify the cursor appearance by
;              changing its start and end scan lines.  Different cursor styles
;              can be created for various visual effects.
;===============================================================================

.model small                        ; Define memory model as 'small' (code and data each fit in 64KB)
.stack 100h                         ; Allocate 256 bytes (100h) for the stack

.data                               ; Start of data segment (where variables and constants are stored)
    msg1 db "Cursor Shape Demonstration",10,13,10,13,"$"        ; Title message
    msg2 db "1. Default Cursor (lines 6-7)",10,13,"$"           ; Message for default cursor
    msg3 db "2. Block Cursor (lines 0-7)",10,13,"$"             ; Message for block cursor
    msg4 db "3. Thin Cursor (lines 0-1)",10,13,"$"              ; Message for thin cursor
    msg5 db "4. Middle Cursor (lines 3-5)",10,13,"$"            ; Message for middle cursor
    msg6 db "5. Hidden Cursor",10,13,10,13,"$"                  ; Message for hidden cursor
    prompt db "Press any key for next cursor.. .",10,13,"$"      ; Prompt message
    final db "Cursor reset to default.  Press any key to exit.$" ; Exit message

.code                               ; Start of code segment (where program instructions are stored)
    mov ax, @data                   ; Load the address of data segment into AX register
    mov ds, ax                      ; Move AX value into DS (Data Segment register) to access variables

    ; Clear screen first
    mov ah, 00h                     ; AH = 00h: Set video mode
    mov al, 03h                     ; AL = 03h: 80x25 text mode (clears screen)
    int 10h                         ; Call BIOS interrupt to clear screen

    ; Display title
    mov ah, 09h                     ; DOS function 09h: Display string terminated by '$'
    mov dx, offset msg1             ; Load offset address of title message
    int 21h                         ; Display title

    ;---------------------------------------------------------------------------
    ; CURSOR SHAPE EXPLANATION
    ;---------------------------------------------------------------------------
    ; The cursor in text mode is made up of scan lines (horizontal rows of pixels)
    ; In standard VGA text mode, each character cell is 8 pixels wide x 16 tall
    ; Scan lines are numbered 0 (top) to 15 (bottom)
    ; 
    ; CH register = Starting scan line (0-15)
    ; CL register = Ending scan line (0-15)
    ;
    ; The cursor appears between (and including) these two scan lines
    ; Setting bit 5 of CH to 1 makes the cursor invisible
    ;---------------------------------------------------------------------------

    ;---------------------------------------------------------------------------
    ; 1. DEFAULT CURSOR (Normal underline cursor)
    ;---------------------------------------------------------------------------
    ; Start line: 6, End line: 7 (bottom two scan lines)
    ; This is the standard DOS cursor - a thin underline at the bottom
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg2             ; Load offset address of msg2
    int 21h                         ; Display "1. Default Cursor..."
    
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset prompt           ; Load offset address of prompt
    int 21h                         ; Display "Press any key..."
    
    ; SERVICE 01h - Set cursor to default shape
    mov ah, 01h                     ; AH = 01h:  BIOS function to set cursor shape
    mov ch, 06h                     ; CH = 06h: Start scan line 6 (near bottom)
    mov cl, 07h                     ; CL = 07h: End scan line 7 (very bottom)
                                    ; Creates a thin 2-line cursor at the bottom
                                    ; This is the standard cursor you see in DOS
    int 10h                         ; Call BIOS interrupt 10h (Video Services)
    
    ; Wait for keypress
    mov ah, 01h                     ; DOS function 01h: Read character from keyboard
    int 21h                         ; Wait for user input

    ;---------------------------------------------------------------------------
    ; 2. BLOCK CURSOR (Full character cell)
    ;---------------------------------------------------------------------------
    ; Start line: 0, End line: 7 (entire visible character cell)
    ; Creates a solid block that covers the entire character
    ; Useful for overwrite mode or high visibility
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg3             ; Load offset address of msg3
    int 21h                         ; Display "2. Block Cursor..."
    
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset prompt           ; Load offset address of prompt
    int 21h                         ; Display "Press any key..."
    
    ; SERVICE 01h - Set cursor to block shape
    mov ah, 01h                     ; AH = 01h: BIOS function to set cursor shape
    mov ch, 00h                     ; CH = 00h: Start scan line 0 (top of character)
    mov cl, 07h                     ; CL = 07h: End scan line 7 (bottom)
                                    ; Creates a full block cursor (8 scan lines tall)
                                    ; Note: In VGA, characters use lines 0-15, but 0-7 visible
    int 10h                         ; Call BIOS interrupt 10h
    
    ; Wait for keypress
    mov ah, 01h                     ; DOS function 01h: Read character
    int 21h                         ; Wait for user input

    ;---------------------------------------------------------------------------
    ; 3. THIN CURSOR (Top two scan lines)
    ;---------------------------------------------------------------------------
    ; Start line: 0, End line: 1 (top of character)
    ; Creates a thin cursor at the top of the character cell
    ; Unusual but demonstrates flexibility
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg4             ; Load offset address of msg4
    int 21h                         ; Display "3. Thin Cursor..."
    
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset prompt           ; Load offset address of prompt
    int 21h                         ; Display "Press any key..."
    
    ; SERVICE 01h - Set cursor to thin top shape
    mov ah, 01h                     ; AH = 01h: BIOS function to set cursor shape
    mov ch, 00h                     ; CH = 00h: Start scan line 0 (very top)
    mov cl, 01h                     ; CL = 01h:  End scan line 1 (second line)
                                    ; Creates a thin 2-line cursor at the top
                                    ; Uncommon but can be useful for special interfaces
    int 10h                         ; Call BIOS interrupt 10h
    
    ; Wait for keypress
    mov ah, 01h                     ; DOS function 01h: Read character
    int 21h                         ; Wait for user input

    ;---------------------------------------------------------------------------
    ; 4. MIDDLE CURSOR (Middle three scan lines)
    ;---------------------------------------------------------------------------
    ; Start line: 3, End line: 5 (middle of character)
    ; Creates a cursor in the middle of the character cell
    ; Can be used for unique visual effects
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h:  Display string
    mov dx, offset msg5             ; Load offset address of msg5
    int 21h                         ; Display "4. Middle Cursor..."
    
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset prompt           ; Load offset address of prompt
    int 21h                         ; Display "Press any key..."
    
    ; SERVICE 01h - Set cursor to middle shape
    mov ah, 01h                     ; AH = 01h: BIOS function to set cursor shape
    mov ch, 03h                     ; CH = 03h: Start scan line 3 (middle)
    mov cl, 05h                     ; CL = 05h: End scan line 5 (middle)
                                    ; Creates a 3-line cursor in the middle
                                    ; Demonstrates that cursor can be anywhere vertically
    int 10h                         ; Call BIOS interrupt 10h
    
    ; Wait for keypress
    mov ah, 01h                     ; DOS function 01h: Read character
    int 21h                         ; Wait for user input

    ;---------------------------------------------------------------------------
    ; 5. HIDDEN CURSOR (Invisible)
    ;---------------------------------------------------------------------------
    ; Setting bit 5 of CH to 1 makes cursor invisible
    ; CH = 20h (bit 5 set) = cursor off
    ; Useful when you don't want cursor visible during output
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg6             ; Load offset address of msg6
    int 21h                         ; Display "5. Hidden Cursor"
    
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset prompt           ; Load offset address of prompt
    int 21h                         ; Display "Press any key..."
    
    ; SERVICE 01h - Hide cursor
    mov ah, 01h                     ; AH = 01h: BIOS function to set cursor shape
    mov ch, 20h                     ; CH = 20h:  Bit 5 set (00100000b) = cursor invisible
                                    ; Any value with bit 5 set will hide cursor
                                    ; Common values: 20h, 32h (when bit 5 is on)
    mov cl, 00h                     ; CL = 00h: End line (doesn't matter when hidden)
                                    ; When cursor is hidden, CL value is ignored
    int 10h                         ; Call BIOS interrupt 10h
                                    ; Cursor is now invisible
    
    ; Wait for keypress
    mov ah, 01h                     ; DOS function 01h: Read character
    int 21h                         ; Wait for user input

    ;---------------------------------------------------------------------------
    ; Restore Default Cursor
    ;---------------------------------------------------------------------------
    mov ah, 01h                     ; AH = 01h: Set cursor shape
    mov ch, 06h                     ; CH = 06h: Start line 6 (default)
    mov cl, 07h                     ; CL = 07h: End line 7 (default)
    int 10h                         ; Restore normal cursor

    ; Display final message
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset final            ; Load offset address of final message
    int 21h                         ; Display exit message
    
    ; Wait before exit
    mov ah, 01h                     ; DOS function 01h:  Read character
    int 21h                         ; Wait for final keypress

    ;---------------------------------------------------------------------------
    ; Exit Program
    ;---------------------------------------------------------------------------
    mov ah, 4ch                     ; DOS function 4Ch:  Terminate program
    int 21h                         ; Call DOS interrupt to exit
end                                 ; End of program

;===============================================================================
; CURSOR SHAPE REFERENCE
;===============================================================================
; CH (Start Line) | CL (End Line) | Cursor Appearance
;-----------------|---------------|---------------------------------------
; 06h             | 07h           | Default underline (2 lines at bottom)
; 00h             | 07h           | Block cursor (full character)
; 00h             | 01h           | Thin cursor at top
; 03h             | 05h           | Middle cursor
; 20h             | 00h           | Hidden/Invisible cursor
; 00h             | 0Fh           | Full VGA block (16 lines)
;
; NOTES:
; - Standard VGA characters are 16 scan lines tall (0-15)
; - In 80x25 text mode, typically only lines 0-7 or 0-13 are visible
; - Setting bit 5 of CH (value 20h or higher with bit 5) hides cursor
; - Some BIOS may use different scan line counts
;===============================================================================