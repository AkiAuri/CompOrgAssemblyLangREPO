;===============================================================================
; PROGRAM: Service 02h - Set Cursor Position
; PURPOSE:  Demonstrates INT 10h, AH=02h (Set Cursor Position)
; DESCRIPTION: This program shows how to position the cursor anywhere on the
;              screen using row and column coordinates.  The screen is treated
;              as a grid:  0-24 rows (top to bottom), 0-79 columns (left to right)
;===============================================================================

.model small                        ; Define memory model as 'small' (code and data each fit in 64KB)
.stack 100h                         ; Allocate 256 bytes (100h) for the stack

.data                               ; Start of data segment (where variables and constants are stored)
    title_msg db "Cursor Position Demonstration",10,13,10,13,"$"  ; Title message
    star db "*$"                    ; Character to display at each position
    msg_tl db "Top-Left (0,0)$"     ; Label for top-left corner
    msg_tr db "Top-Right (0,79)$"   ; Label for top-right corner
    msg_bl db "Bottom-Left (24,0)$" ; Label for bottom-left corner
    msg_br db "Bottom-Right (24,79)$" ; Label for bottom-right corner
    msg_center db "CENTER (12,40)$" ; Label for center position
    msg_exit db "Press any key to exit.. .$"  ; Exit prompt message
    
.code                               ; Start of code segment (where program instructions are stored)
    mov ax, @data                   ; Load the address of data segment into AX register
    mov ds, ax                      ; Move AX value into DS (Data Segment register) to access variables

    ;---------------------------------------------------------------------------
    ; Clear Screen by Setting Video Mode
    ;---------------------------------------------------------------------------
    mov ah, 00h                     ; AH = 00h:  BIOS function to set video mode
    mov al, 03h                     ; AL = 03h:  80x25 text mode, 16 colors
                                    ; Setting video mode clears screen and resets cursor
    int 10h                         ; Call BIOS interrupt 10h (Video Services)

    ;---------------------------------------------------------------------------
    ; CURSOR POSITION COORDINATE SYSTEM
    ;---------------------------------------------------------------------------
    ; Standard 80x25 text mode screen layout:
    ; - Rows (DH): 0 to 24 (25 total rows, 0=top, 24=bottom)
    ; - Columns (DL): 0 to 79 (80 total columns, 0=left, 79=right)
    ; - Page (BH): Usually 0 in text mode (multiple pages possible)
    ;
    ; Screen coordinate diagram:
    ;     Column:  0                    40                   79
    ;            ├─────────────────────┼────────────────────┤
    ; Row 0:     │ (0,0)              (0,40)             (0,79)
    ;     12:     │                   (12,40) CENTER
    ;     24:    │ (24,0)                              (24,79)
    ;---------------------------------------------------------------------------

    ;---------------------------------------------------------------------------
    ; Display Title at Top-Left (Default Position)
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h:  Display string terminated by '$'
    mov dx, offset title_msg        ; Load offset address of title_msg into DX
    int 21h                         ; Call DOS interrupt to display title
                                    ; Title displays at current cursor position (0,0)

    ;---------------------------------------------------------------------------
    ; SERVICE 02h - Position 1:  TOP-LEFT CORNER (Row 0, Column 0)
    ;---------------------------------------------------------------------------
    ; This is the origin point (0,0) - top-left corner of screen
    ; This is the default cursor position after clearing screen
    ;---------------------------------------------------------------------------
    mov ah, 02h                     ; AH = 02h: BIOS function to set cursor position
    mov bh, 00h                     ; BH = 00h: Display page number (page 0 for text mode)
                                    ; Multiple pages can exist in video memory
                                    ; Page 0 is the visible page in standard text mode
    mov dh, 04h                     ; DH = 04h: Row position 4 (to avoid title)
    mov dl, 05h                     ; DL = 05h: Column position 5 (indent from left)
    int 10h                         ; Call BIOS interrupt 10h (Video Services)
                                    ; Cursor is now at position (4,5)
    
    ; Display star at top-left area
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset star             ; Load offset address of star character
    int 21h                         ; Display "*" at position (4,5)
    
    ; Display label for top-left
    mov ah, 02h                     ; AH = 02h: Set cursor position
    mov bh, 00h                     ; BH = page 0
    mov dh, 04h                     ; DH = row 4 (same row as star)
    mov dl, 07h                     ; DL = column 7 (2 spaces after star)
    int 10h                         ; Position cursor for label
    
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg_tl           ; Load offset of "Top-Left (0,0)" message
    int 21h                         ; Display label

    ;---------------------------------------------------------------------------
    ; SERVICE 02h - Position 2: TOP-RIGHT CORNER (Row 0, Column 79)
    ;---------------------------------------------------------------------------
    ; Column 79 is the rightmost column (0-indexed, so 80th column)
    ; Text printed here will appear at the right edge
    ;---------------------------------------------------------------------------
    mov ah, 02h                     ; AH = 02h:  BIOS function to set cursor position
    mov bh, 00h                     ; BH = 00h: Display page 0
    mov dh, 06h                     ; DH = 06h: Row position 6
    mov dl, 74h                     ; DL = 74h (116 decimal): Column 74 (near right edge)
                                    ; We use column 74 to leave room for label
    int 10h                         ; Call BIOS interrupt to set cursor at (6,74)
    
    ; Display star at top-right area
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset star             ; Load offset address of star
    int 21h                         ; Display "*" at position (6,74)
    
    ; Display label for top-right
    mov ah, 02h                     ; AH = 02h: Set cursor position
    mov bh, 00h                     ; BH = page 0
    mov dh, 07h                     ; DH = row 7 (next row)
    mov dl, 60h                     ; DL = column 60h (96 decimal) for label
    int 10h                         ; Position cursor for label
    
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg_tr           ; Load offset of "Top-Right" message
    int 21h                         ; Display label

    ;---------------------------------------------------------------------------
    ; SERVICE 02h - Position 3: CENTER OF SCREEN (Row 12, Column 40)
    ;---------------------------------------------------------------------------
    ; Row 12 is the middle row (12 out of 0-24 = 25 rows)
    ; Column 40 is the middle column (40 out of 0-79 = 80 columns)
    ; This is the mathematical center of the screen
    ;---------------------------------------------------------------------------
    mov ah, 02h                     ; AH = 02h: BIOS function to set cursor position
    mov bh, 00h                     ; BH = 00h: Display page 0
    mov dh, 0Ch                     ; DH = 0Ch (12 decimal): Row 12 (middle row)
                                    ; 12 is halfway between 0 and 24
    mov dl, 28h                     ; DL = 28h (40 decimal): Column 40 (middle column)
                                    ; 40 is halfway between 0 and 79
    int 10h                         ; Call BIOS interrupt to position at screen center
    
    ; Display star at center
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset star             ; Load offset address of star
    int 21h                         ; Display "*" at center position (12,40)
    
    ; Display label for center
    mov ah, 02h                     ; AH = 02h: Set cursor position
    mov bh, 00h                     ; BH = page 0
    mov dh, 0Ch                     ; DH = row 12 (same as star)
    mov dl, 2Ah                     ; DL = column 2Ah (42 decimal, 2 spaces after star)
    int 10h                         ; Position cursor for label
    
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg_center       ; Load offset of "CENTER" message
    int 21h                         ; Display label

    ;---------------------------------------------------------------------------
    ; SERVICE 02h - Position 4: BOTTOM-LEFT CORNER (Row 24, Column 0)
    ;---------------------------------------------------------------------------
    ; Row 24 is the bottom row (last of 25 rows, 0-indexed)
    ; Column 0 is the leftmost column
    ; This is often where status bars or prompts appear
    ;---------------------------------------------------------------------------
    mov ah, 02h                     ; AH = 02h: BIOS function to set cursor position
    mov bh, 00h                     ; BH = 00h: Display page 0
    mov dh, 18h                     ; DH = 18h (24 decimal): Row 24 (bottom row)
                                    ; This is the last row of standard 80x25 text mode
    mov dl, 05h                     ; DL = 05h: Column 5 (indent from left edge)
    int 10h                         ; Call BIOS interrupt to position at bottom-left area
    
    ; Display star at bottom-left area
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset star             ; Load offset address of star
    int 21h                         ; Display "*" at position (24,5)
    
    ; Display label for bottom-left
    mov ah, 02h                     ; AH = 02h: Set cursor position
    mov bh, 00h                     ; BH = page 0
    mov dh, 18h                     ; DH = row 24 (same as star)
    mov dl, 07h                     ; DL = column 7 (2 spaces after star)
    int 10h                         ; Position cursor for label
    
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg_bl           ; Load offset of "Bottom-Left" message
    int 21h                         ; Display label

    ;---------------------------------------------------------------------------
    ; SERVICE 02h - Position 5: BOTTOM-RIGHT CORNER (Row 24, Column 79)
    ;---------------------------------------------------------------------------
    ; This is the absolute last position on the screen
    ; Row 24 (bottom), Column 79 (rightmost)
    ; Text here may wrap to next line if too long
    ;---------------------------------------------------------------------------
    mov ah, 02h                     ; AH = 02h: BIOS function to set cursor position
    mov bh, 00h                     ; BH = 00h: Display page 0
    mov dh, 16h                     ; DH = 16h (22 decimal): Row 22 (near bottom)
    mov dl, 69h                     ; DL = 69h (105 decimal): Column 69 (near right)
                                    ; We use row 22 to avoid overwriting bottom-left label
    int 10h                         ; Call BIOS interrupt to position near bottom-right
    
    ; Display star at bottom-right area
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset star             ; Load offset address of star
    int 21h                         ; Display "*" at position (22,69)
    
    ; Display label for bottom-right
    mov ah, 02h                     ; AH = 02h: Set cursor position
    mov bh, 00h                     ; BH = page 0
    mov dh, 17h                     ; DH = row 23 (next row)
    mov dl, 60h                     ; DL = column 60h (96 decimal) for label
    int 10h                         ; Position cursor for label
    
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg_br           ; Load offset of "Bottom-Right" message
    int 21h                         ; Display label

    ;---------------------------------------------------------------------------
    ; Position Cursor for Exit Message (Bottom Center)
    ;---------------------------------------------------------------------------
    mov ah, 02h                     ; AH = 02h: Set cursor position
    mov bh, 00h                     ; BH = page 0
    mov dh, 17h                     ; DH = row 23 (near bottom)
    mov dl, 1Eh                     ; DL = column 1Eh (30 decimal, center-left area)
    int 10h                         ; Position cursor for exit message
    
    ; Display exit message
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg_exit         ; Load offset of exit message
    int 21h                         ; Display "Press any key to exit..."

    ;---------------------------------------------------------------------------
    ; Wait for User Input Before Exiting
    ;---------------------------------------------------------------------------
    mov ah, 01h                     ; DOS function 01h: Read single character from keyboard
    int 21h                         ; Call DOS interrupt, waits for keypress
                                    ; Character is stored in AL (not used here)

    ;---------------------------------------------------------------------------
    ; Exit Program
    ;---------------------------------------------------------------------------
    mov ah, 4ch                     ; DOS function 4Ch:  Terminate program with return code
    int 21h                         ; Call DOS interrupt to exit program and return to DOS
end                                 ; End of program (marks end of source code for assembler)

;===============================================================================
; CURSOR POSITION REFERENCE
;===============================================================================
; Screen Layout (80x25 Text Mode):
;
;      Columns (DL register):
;      0    10   20   30   40   50   60   70   79
;      ├────┼────┼────┼────┼────┼────┼────┼────┤
; R 0  │ (0,0)                          (0,79)  │  <- Top edge
; o 1  │                                         │
; w 5  │                                         │
; s 10 │                                         │
;   12 │                  (12,40) Center        │
;   15 │                                         │
;   20 │                                         │
;   24 │ (24,0)                        (24,79)  │  <- Bottom edge
;      └─────────────────────────────────────────┘
;
; Input Registers for INT 10h, AH=02h:
;   AH = 02h (function:  set cursor position)
;   BH = Page number (usually 0)
;   DH = Row (0-24 for 80x25 mode)
;   DL = Column (0-79 for 80x25 mode)
;
; Notes:
;   - Position (0,0) is top-left corner
;   - Position (24,79) is bottom-right corner
;   - Center of screen is approximately (12,40)
;   - Cursor wraps to next line at column 80
;   - Scrolling occurs when writing past row 24
;===============================================================================