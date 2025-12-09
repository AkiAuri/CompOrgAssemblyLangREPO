;===============================================================================
; PROGRAM: Service 06h & 07h - Scroll Window Up/Down
; PURPOSE: Demonstrates INT 10h, AH=06h (Scroll Up) and AH=07h (Scroll Down)
; DESCRIPTION: These services scroll a rectangular window of the screen up or
;              down by a specified number of lines.  When AL=0, the window is
;              cleared.  This is the preferred method to clear the screen.
;===============================================================================

.model small                        ; Define memory model as 'small' (code and data each fit in 64KB)
.stack 100h                         ; Allocate 256 bytes (100h) for the stack

.data                               ; Start of data segment (where variables and constants are stored)
    title_msg db "Scroll Window Up/Down Demonstration",10,13,10,13,"$"
    
    msg1 db "This is line 1 of original content",10,13,"$"
    msg2 db "This is line 2 of original content",10,13,"$"
    msg3 db "This is line 3 of original content",10,13,"$"
    msg4 db "This is line 4 of original content",10,13,"$"
    msg5 db "This is line 5 of original content",10,13,10,13,"$"
    
    prompt1 db "Press key to CLEAR screen (scroll up AL=0).. .$"
    prompt2 db "Press key to scroll UP 3 lines.. .$"
    prompt3 db "Press key to scroll DOWN 5 lines...$"
    prompt4 db "Press key to clear a WINDOW area...$"
    prompt5 db "Press key to exit...$"
    
    after_clear db "Screen cleared using Service 06h! ",10,13,10,13,"$"
    after_scroll_up db "Scrolled up 3 lines",10,13,"$"
    after_scroll_down db "Scrolled down 5 lines - see the colored area",10,13,"$"
    window_msg db "A window area was cleared!",10,13,10,13,"$"

.code                               ; Start of code segment (where program instructions are stored)
    mov ax, @data                   ; Load the address of data segment into AX register
    mov ds, ax                      ; Move AX value into DS (Data Segment register) to access variables

    ;---------------------------------------------------------------------------
    ; SCROLL WINDOW EXPLANATION
    ;---------------------------------------------------------------------------
    ; Service 06h (Scroll Up) and 07h (Scroll Down) can: 
    ;   1. Clear entire screen (AL=0, full window coordinates)
    ;   2. Clear a rectangular window (AL=0, specific coordinates)
    ;   3. Scroll screen/window up (06h) or down (07h) by AL lines
    ;
    ; Window is defined by:
    ;   (CH,CL) = Top-left corner (row, column)
    ;   (DH,DL) = Bottom-right corner (row, column)
    ;
    ; BH = Attribute for blank lines (color for cleared/scrolled area)
    ;   Bits 0-3:  Foreground color (0-15)
    ;   Bits 4-6: Background color (0-7)
    ;   Bit 7: Blink (if enabled)
    ;---------------------------------------------------------------------------

    ;---------------------------------------------------------------------------
    ; Display Initial Content
    ;---------------------------------------------------------------------------
    ; First, set video mode to clear screen
    mov ah, 00h                     ; AH = 00h: Set video mode
    mov al, 03h                     ; AL = 03h: 80x25 text mode
    int 10h                         ; Clear screen
    
    ; Display title
    mov ah, 09h                     ; DOS function 09h: Display string terminated by '$'
    mov dx, offset title_msg        ; Load offset address of title
    int 21h                         ; Display title
    
    ; Display several lines of content
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg1             ; Load offset of line 1
    int 21h                         ; Display line 1
    
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg2             ; Load offset of line 2
    int 21h                         ; Display line 2
    
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg3             ; Load offset of line 3
    int 21h                         ; Display line 3
    
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg4             ; Load offset of line 4
    int 21h                         ; Display line 4
    
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg5             ; Load offset of line 5
    int 21h                         ; Display line 5
    
    ; Display prompt
    mov ah, 09h                     ; DOS function 09h:  Display string
    mov dx, offset prompt1          ; Load offset of prompt
    int 21h                         ; Display "Press key to CLEAR screen..."
    
    ; Wait for keypress
    mov ah, 01h                     ; DOS function 01h: Read character from keyboard
    int 21h                         ; Wait for user input

    ;---------------------------------------------------------------------------
    ; SERVICE 06h - Clear Entire Screen (Scroll Up with AL=0)
    ;---------------------------------------------------------------------------
    ; This is the PROPER way to clear the screen using BIOS
    ; When AL=0, the entire window is blanked (cleared)
    ; This is more portable than setting video mode to clear screen
    ;---------------------------------------------------------------------------
    mov ah, 06h                     ; AH = 06h:  BIOS function to scroll window up
    mov al, 00h                     ; AL = 00h: Number of lines to scroll (0 = clear entire window)
                                    ; AL=0 means "blank the entire window"
                                    ; AL=1 would scroll up 1 line
                                    ; AL=5 would scroll up 5 lines, etc.
    mov bh, 07h                     ; BH = 07h:  Attribute for blank lines
                                    ; 07h = 0000 0111 binary
                                    ; Bits 0-2 (111) = White foreground (7)
                                    ; Bits 3 (0) = Normal intensity
                                    ; Bits 4-6 (000) = Black background (0)
                                    ; Bit 7 (0) = No blink
                                    ; Result: White text on black background (standard)
    mov ch, 00h                     ; CH = 00h: Top row of window (row 0 = top of screen)
    mov cl, 00h                     ; CL = 00h: Left column of window (column 0 = left edge)
    mov dh, 18h                     ; DH = 18h (24 decimal): Bottom row of window (row 24 = bottom)
    mov dl, 4Fh                     ; DL = 4Fh (79 decimal): Right column of window (column 79 = right edge)
                                    ; Together, (0,0) to (24,79) = entire 80x25 screen
    int 10h                         ; Call BIOS interrupt 10h (Video Services)
                                    ; Screen is now completely cleared with white on black

    ; Display message after clear
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset after_clear      ; Load offset of "Screen cleared" message
    int 21h                         ; Display message
    
    ; Display several lines again
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg1             ; Display line 1
    int 21h
    
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg2             ; Display line 2
    int 21h
    
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg3             ; Display line 3
    int 21h
    
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg4             ; Display line 4
    int 21h
    
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg5             ; Display line 5
    int 21h
    
    ; Display prompt
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset prompt2          ; Load offset of prompt
    int 21h                         ; Display "Press key to scroll UP 3 lines..."
    
    ; Wait for keypress
    mov ah, 01h                     ; DOS function 01h:  Read character
    int 21h                         ; Wait for user input

    ;---------------------------------------------------------------------------
    ; SERVICE 06h - Scroll Entire Screen Up by 3 Lines
    ;---------------------------------------------------------------------------
    ; When AL > 0, the window scrolls up by AL lines
    ; The bottom AL lines become blank with the specified attribute
    ; Text "moves up" and new blank lines appear at bottom
    ;---------------------------------------------------------------------------
    mov ah, 06h                     ; AH = 06h:  Scroll window up
    mov al, 03h                     ; AL = 03h:  Scroll up 3 lines
                                    ; Top 3 lines disappear off the top
                                    ; Content moves up 3 rows
                                    ; Bottom 3 lines become blank
    mov bh, 0Eh                     ; BH = 0Eh: Attribute for new blank lines
                                    ; 0Eh = 0000 1110 binary
                                    ; Bits 0-3 (1110) = Yellow foreground (14)
                                    ; Bits 4-6 (000) = Black background (0)
                                    ; Result: Yellow on black for the 3 new blank lines
    mov ch, 00h                     ; CH = 0: Top row (entire screen)
    mov cl, 00h                     ; CL = 0: Left column (entire screen)
    mov dh, 18h                     ; DH = 24: Bottom row (entire screen)
    mov dl, 4Fh                     ; DL = 79: Right column (entire screen)
    int 10h                         ; Call BIOS interrupt
                                    ; Screen content scrolls up 3 lines

    ; Display message after scroll up
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset after_scroll_up  ; Load offset of message
    int 21h                         ; Display "Scrolled up 3 lines"
    
    ; Display prompt
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset prompt3          ; Load offset of prompt
    int 21h                         ; Display "Press key to scroll DOWN..."
    
    ; Wait for keypress
    mov ah, 01h                     ; DOS function 01h: Read character
    int 21h                         ; Wait for user input

    ;---------------------------------------------------------------------------
    ; SERVICE 07h - Scroll Entire Screen Down by 5 Lines
    ;---------------------------------------------------------------------------
    ; Service 07h scrolls DOWN (opposite of 06h)
    ; When AL > 0, the window scrolls down by AL lines
    ; The top AL lines become blank with the specified attribute
    ; Text "moves down" and new blank lines appear at top
    ;---------------------------------------------------------------------------
    mov ah, 07h                     ; AH = 07h:  BIOS function to scroll window DOWN
    mov al, 05h                     ; AL = 05h:  Scroll down 5 lines
                                    ; Bottom 5 lines disappear off the bottom
                                    ; Content moves down 5 rows
                                    ; Top 5 lines become blank
    mov bh, 1Fh                     ; BH = 1Fh: Attribute for new blank lines
                                    ; 1Fh = 0001 1111 binary
                                    ; Bits 0-3 (1111) = White foreground (15)
                                    ; Bits 4-6 (001) = Blue background (1)
                                    ; Result: White on blue for the 5 new blank lines at top
    mov ch, 00h                     ; CH = 0: Top row (entire screen)
    mov cl, 00h                     ; CL = 0: Left column (entire screen)
    mov dh, 18h                     ; DH = 24: Bottom row (entire screen)
    mov dl, 4Fh                     ; DL = 79: Right column (entire screen)
    int 10h                         ; Call BIOS interrupt
                                    ; Screen content scrolls down 5 lines
                                    ; Top 5 lines are now white on blue

    ; Position cursor below the blue area
    mov ah, 02h                     ; AH = 02h: Set cursor position
    mov bh, 00h                     ; BH = page 0
    mov dh, 06h                     ; DH = row 6 (below the 5 blue lines)
    mov dl, 00h                     ; DL = column 0
    int 10h                         ; Position cursor

    ; Display message after scroll down
    mov ah, 09h                     ; DOS function 09h:  Display string
    mov dx, offset after_scroll_down ; Load offset of message
    int 21h                         ; Display "Scrolled down 5 lines..."
    
    ; Display prompt
    mov ah, 09h                     ; DOS function 09h:  Display string
    mov dx, offset prompt4          ; Load offset of prompt
    int 21h                         ; Display "Press key to clear a WINDOW..."
    
    ; Wait for keypress
    mov ah, 01h                     ; DOS function 01h: Read character
    int 21h                         ; Wait for user input

    ;---------------------------------------------------------------------------
    ; SERVICE 06h - Clear a Specific Window Area (Partial Screen)
    ;---------------------------------------------------------------------------
    ; You can clear just a rectangular area instead of entire screen
    ; This is useful for: 
    ;   - Clearing a menu area
    ;   - Erasing a dialog box
    ;   - Clearing a section without affecting rest of screen
    ;---------------------------------------------------------------------------
    mov ah, 06h                     ; AH = 06h:  Scroll window up
    mov al, 00h                     ; AL = 0: Clear the window (don't scroll, just blank it)
    mov bh, 2Eh                     ; BH = 2Eh: Attribute for cleared window
                                    ; 2Eh = 0010 1110 binary
                                    ; Bits 0-3 (1110) = Yellow foreground (14)
                                    ; Bits 4-6 (010) = Green background (2)
                                    ; Result: Yellow on green (high visibility)
    mov ch, 0Ah                     ; CH = 0Ah (10 decimal): Top row of window (row 10)
    mov cl, 14h                     ; CL = 14h (20 decimal): Left column of window (column 20)
    mov dh, 14h                     ; DH = 14h (20 decimal): Bottom row of window (row 20)
    mov dl, 3Ch                     ; DL = 3Ch (60 decimal): Right column of window (column 60)
                                    ; This clears a rectangle from (10,20) to (20,60)
                                    ; A box in the middle of the screen
    int 10h                         ; Call BIOS interrupt
                                    ; Only the specified window is cleared (yellow on green)

    ; Position cursor in the cleared window
    mov ah, 02h                     ; AH = 02h: Set cursor position
    mov bh, 00h                     ; BH = page 0
    mov dh, 0Fh                     ; DH = row 15 (middle of window vertically)
    mov dl, 1Eh                     ; DL = column 30 (inside window horizontally)
    int 10h                         ; Position cursor inside the cleared window

    ; Display message in the cleared window
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset window_msg       ; Load offset of message
    int 21h                         ; Display "A window area was cleared!"

    ; Position cursor for exit prompt
    mov ah, 02h                     ; AH = 02h: Set cursor position
    mov bh, 00h                     ; BH = page 0
    mov dh, 17h                     ; DH = row 23 (near bottom)
    mov dl, 00h                     ; DL = column 0
    int 10h                         ; Position cursor

    ; Display exit prompt
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset prompt5          ; Load offset of exit prompt
    int 21h                         ; Display "Press key to exit..."
    
    ; Wait for keypress
    mov ah, 01h                     ; DOS function 01h: Read character
    int 21h                         ; Wait for user input

    ;---------------------------------------------------------------------------
    ; Exit Program
    ;---------------------------------------------------------------------------
    mov ah, 4ch                     ; DOS function 4Ch:  Terminate program
    int 21h                         ; Call DOS interrupt to exit
end                                 ; End of program

;===============================================================================
; SCROLL WINDOW REFERENCE
;===============================================================================
; INT 10h, AH=06h - Scroll Window Up
; INT 10h, AH=07h - Scroll Window Down
;
; INPUT:
;   AH = 06h (scroll up) or 07h (scroll down)
;   AL = Number of lines to scroll
;        AL=0: Clear entire window (most common for screen clear)
;        AL=1-25: Scroll by that many lines
;   BH = Attribute for blank lines (color of cleared/new lines)
;        Bits 0-3: Foreground color (0-15)
;        Bits 4-6: Background color (0-7)
;        Bit 7: Blink enable
;   CH = Top row of window (0-24)
;   CL = Left column of window (0-79)
;   DH = Bottom row of window (0-24)
;   DL = Right column of window (0-79)
;
; COMMON USES:
;   1. Clear screen:  AH=06h, AL=0, CH=0, CL=0, DH=24, DL=79, BH=07h
;   2. Clear window: AH=06h, AL=0, specify window coords, BH=attribute
;   3. Scroll up: AH=06h, AL=lines, window coords, BH=attribute
;   4. Scroll down: AH=07h, AL=lines, window coords, BH=attribute
;
; COLOR ATTRIBUTE VALUES (BH):
;   00h = Black on Black      08h = Dark Gray on Black
;   01h = Blue on Black       09h = Light Blue on Black
;   02h = Green on Black      0Ah = Light Green on Black
;   03h = Cyan on Black       0Bh = Light Cyan on Black
;   04h = Red on Black        0Ch = Light Red on Black
;   05h = Magenta on Black    0Dh = Light Magenta on Black
;   06h = Brown on Black      0Eh = Yellow on Black
;   07h = White on Black      0Fh = Bright White on Black
;   
;   For background colors, multiply by 16 (shift left 4 bits):
;   10h = Black on Blue, 20h = Black on Green, 70h = Black on White, etc.
;===============================================================================