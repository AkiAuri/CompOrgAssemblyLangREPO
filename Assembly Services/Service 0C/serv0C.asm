;===============================================================================
; PROGRAM: Service 0Ch - Write Graphics Pixel
; PURPOSE:   Demonstrates INT 10h, AH=0Ch (Write Graphics Pixel)
; DESCRIPTION: This service writes a pixel at a specific coordinate in graphics
;              mode.   It's used for drawing individual pixels, lines, shapes,
;              and graphics.   Requires graphics mode (not text mode).
;===============================================================================

.model small                        ; Define memory model as 'small' (code and data each fit in 64KB)
.stack 100h                         ; Allocate 256 bytes (100h) for the stack

.data                               ; Start of data segment (where variables and constants are stored)
    msg_start db "Entering Graphics Mode 13h (320x200, 256 colors)",10,13
              db "Press any key to start drawing.. .$"
    msg_exit db "Press any key to return to text mode...$"

.code                               ; Start of code segment (where program instructions are stored)
    mov ax, @data                   ; Load the address of data segment into AX register
    mov ds, ax                      ; Move AX value into DS (Data Segment register) to access variables

    ;---------------------------------------------------------------------------
    ; Display Initial Message in Text Mode
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h:  Display string terminated by '$'
    mov dx, offset msg_start        ; Load offset address of start message
    int 21h                         ; Display message
    
    mov ah, 01h                     ; DOS function 01h: Read character from keyboard
    int 21h                         ; Wait for keypress

    ;---------------------------------------------------------------------------
    ; GRAPHICS MODE EXPLANATION
    ;---------------------------------------------------------------------------
    ; Text mode (03h): 80x25 characters, no pixel control
    ; Graphics modes allow pixel-by-pixel control: 
    ;
    ; Common Graphics Modes:
    ;   04h: 320x200, 4 colors (CGA)
    ;   06h: 640x200, 2 colors (CGA)
    ;   0Dh: 320x200, 16 colors (EGA)
    ;   0Eh: 640x200, 16 colors (EGA)
    ;   10h: 640x350, 16 colors (EGA)
    ;   12h: 640x480, 16 colors (VGA)
    ;   13h: 320x200, 256 colors (VGA/MCGA) - Most common for demos
    ;
    ; Mode 13h (320x200x256) is popular because:
    ;   - Easy to program (linear video memory)
    ;   - 256 colors (good color depth)
    ;   - Decent resolution for games/demos
    ;   - One byte per pixel
    ;---------------------------------------------------------------------------

    ;---------------------------------------------------------------------------
    ; Set Graphics Mode 13h (320x200, 256 colors)
    ;---------------------------------------------------------------------------
    mov ah, 00h                     ; AH = 00h:  BIOS function to set video mode
    mov al, 13h                     ; AL = 13h: Graphics mode 13h
                                    ; Mode 13h specifications:
                                    ;   - Resolution: 320 pixels wide x 200 pixels tall
                                    ;   - Colors: 256 colors (0-255)
                                    ;   - Video memory: 0A000h: 0000h (segment A000h)
                                    ;   - One byte per pixel
                                    ;   - Linear addressing:  pixel = row*320 + column
    int 10h                         ; Call BIOS interrupt to enter graphics mode
                                    ; Screen is now in graphics mode (not text)

    ;---------------------------------------------------------------------------
    ; PIXEL COORDINATE SYSTEM
    ;---------------------------------------------------------------------------
    ; In mode 13h: 
    ;   - X coordinate (CX): 0 to 319 (left to right)
    ;   - Y coordinate (DX): 0 to 199 (top to bottom)
    ;   - Color (AL): 0 to 255
    ;
    ; Origin (0,0) is at TOP-LEFT corner
    ;     X:  0                         319
    ;     ├──────────────────────────────┤
    ; Y: 0 │ (0,0)                  (0,319)
    ;     │
    ; 100 │        (100,160) Center
    ;     │
    ; 199 │ (199,0)              (199,319)
    ;---------------------------------------------------------------------------

    ;---------------------------------------------------------------------------
    ; Demo 1: Draw Individual Pixels in Different Colors
    ;---------------------------------------------------------------------------
    ; Draw a single RED pixel at position (100, 100)
    mov ah, 0Ch                     ; AH = 0Ch:  BIOS function to write graphics pixel
    mov al, 04h                     ; AL = 04h: Color value (4 = red in default palette)
                                    ; Mode 13h has 256 colors: 
                                    ;   0 = Black, 1 = Blue, 2 = Green, 3 = Cyan
                                    ;   4 = Red, 5 = Magenta, 6 = Brown, 7 = Light Gray
                                    ;   8-15 = Bright versions
                                    ;   16-255 = Various other colors
    mov bh, 00h                     ; BH = 00h: Page number (always 0 in mode 13h)
                                    ; Graphics modes typically use only page 0
    mov cx, 100                     ; CX = 100: X coordinate (column, 0-319)
                                    ; 100 pixels from left edge
    mov dx, 100                     ; DX = 100: Y coordinate (row, 0-199)
                                    ; 100 pixels from top edge
    int 10h                         ; Call BIOS interrupt 10h (Video Services)
                                    ; One red pixel is drawn at (100,100)
    
    ; Draw a YELLOW pixel at (105, 100)
    mov ah, 0Ch                     ; AH = 0Ch: Write pixel
    mov al, 0Eh                     ; AL = 0Eh: Yellow color (14)
    mov bh, 00h                     ; BH = page 0
    mov cx, 105                     ; CX = 105: X coordinate
    mov dx, 100                     ; DX = 100: Y coordinate
    int 10h                         ; Draw yellow pixel
    
    ; Draw a GREEN pixel at (110, 100)
    mov ah, 0Ch                     ; AH = 0Ch: Write pixel
    mov al, 02h                     ; AL = 02h: Green color (2)
    mov bh, 00h                     ; BH = page 0
    mov cx, 110                     ; CX = 110: X coordinate
    mov dx, 100                     ; DX = 100: Y coordinate
    int 10h                         ; Draw green pixel
    
    ; Draw a CYAN pixel at (115, 100)
    mov ah, 0Ch                     ; AH = 0Ch: Write pixel
    mov al, 03h                     ; AL = 03h: Cyan color (3)
    mov bh, 00h                     ; BH = page 0
    mov cx, 115                     ; CX = 115: X coordinate
    mov dx, 100                     ; DX = 100: Y coordinate
    int 10h                         ; Draw cyan pixel

    ;---------------------------------------------------------------------------
    ; Demo 2: Draw a Horizontal Line (using pixel loop)
    ;---------------------------------------------------------------------------
    ; Draw a white horizontal line from (50, 50) to (150, 50)
    mov cx, 50                      ; CX = 50: Starting X coordinate
    
draw_h_line:                        ; Label for horizontal line loop
    mov ah, 0Ch                     ; AH = 0Ch: Write pixel
    mov al, 0Fh                     ; AL = 0Fh: White color (15)
    mov bh, 00h                     ; BH = page 0
                                    ; CX already contains current X position
    mov dx, 50                      ; DX = 50: Y coordinate (constant for horizontal line)
    int 10h                         ; Draw one pixel in the line
    
    inc cx                          ; Increment X coordinate (move right one pixel)
    cmp cx, 150                     ; Compare current X with ending X (150)
    jle draw_h_line                 ; If CX <= 150, continue drawing (jump back to loop)
                                    ; Loop continues until entire line is drawn

    ;---------------------------------------------------------------------------
    ; Demo 3: Draw a Vertical Line
    ;---------------------------------------------------------------------------
    ; Draw a magenta vertical line from (200, 30) to (200, 100)
    mov dx, 30                      ; DX = 30: Starting Y coordinate
    
draw_v_line:                        ; Label for vertical line loop
    mov ah, 0Ch                     ; AH = 0Ch: Write pixel
    mov al, 05h                     ; AL = 05h: Magenta color (5)
    mov bh, 00h                     ; BH = page 0
    mov cx, 200                     ; CX = 200: X coordinate (constant for vertical line)
                                    ; DX already contains current Y position
    int 10h                         ; Draw one pixel in the line
    
    inc dx                          ; Increment Y coordinate (move down one pixel)
    cmp dx, 100                     ; Compare current Y with ending Y (100)
    jle draw_v_line                 ; If DX <= 100, continue drawing (jump back to loop)
                                    ; Loop continues until entire line is drawn

    ;---------------------------------------------------------------------------
    ; Demo 4: Draw a Rectangle (outline)
    ;---------------------------------------------------------------------------
    ; Draw a blue rectangle from (80, 120) to (180, 170)
    
    ; Top edge (horizontal line)
    mov cx, 80                      ; CX = starting X (left edge)
rect_top:                           ; Label for top edge loop
    mov ah, 0Ch                     ; AH = 0Ch: Write pixel
    mov al, 01h                     ; AL = 01h: Blue color (1)
    mov bh, 00h                     ; BH = page 0
                                    ; CX has current X position
    mov dx, 120                     ; DX = 120: Y coordinate (top edge)
    int 10h                         ; Draw pixel
    inc cx                          ; Move right
    cmp cx, 180                     ; Check if reached right edge
    jle rect_top                    ; Continue if not done
    
    ; Bottom edge (horizontal line)
    mov cx, 80                      ; CX = starting X (left edge)
rect_bottom:                        ; Label for bottom edge loop
    mov ah, 0Ch                     ; AH = 0Ch: Write pixel
    mov al, 01h                     ; AL = blue
    mov bh, 00h                     ; BH = page 0
                                    ; CX has current X position
    mov dx, 170                     ; DX = 170: Y coordinate (bottom edge)
    int 10h                         ; Draw pixel
    inc cx                          ; Move right
    cmp cx, 180                     ; Check if reached right edge
    jle rect_bottom                 ; Continue if not done
    
    ; Left edge (vertical line)
    mov dx, 120                     ; DX = starting Y (top edge)
rect_left:                          ; Label for left edge loop
    mov ah, 0Ch                     ; AH = 0Ch: Write pixel
    mov al, 01h                     ; AL = blue
    mov bh, 00h                     ; BH = page 0
    mov cx, 80                      ; CX = 80: X coordinate (left edge)
                                    ; DX has current Y position
    int 10h                         ; Draw pixel
    inc dx                          ; Move down
    cmp dx, 170                     ; Check if reached bottom edge
    jle rect_left                   ; Continue if not done
    
    ; Right edge (vertical line)
    mov dx, 120                     ; DX = starting Y (top edge)
rect_right:                         ; Label for right edge loop
    mov ah, 0Ch                     ; AH = 0Ch: Write pixel
    mov al, 01h                     ; AL = blue
    mov bh, 00h                     ; BH = page 0
    mov cx, 180                     ; CX = 180: X coordinate (right edge)
                                    ; DX has current Y position
    int 10h                         ; Draw pixel
    inc dx                          ; Move down
    cmp dx, 170                     ; Check if reached bottom edge
    jle rect_right                  ; Continue if not done

    ;---------------------------------------------------------------------------
    ; Demo 5: Draw a Filled Rectangle
    ;---------------------------------------------------------------------------
    ; Draw a yellow filled rectangle from (220, 140) to (280, 180)
    mov dx, 140                     ; DX = starting Y coordinate (top)
    
fill_rect_row:                      ; Label for outer loop (rows)
    mov cx, 220                     ; CX = starting X coordinate (left)
    
fill_rect_col:                      ; Label for inner loop (columns)
    mov ah, 0Ch                     ; AH = 0Ch: Write pixel
    mov al, 0Eh                     ; AL = 0Eh: Yellow color (14)
    mov bh, 00h                     ; BH = page 0
                                    ; CX has current X position
                                    ; DX has current Y position
    int 10h                         ; Draw pixel
    
    inc cx                          ; Move to next column (right)
    cmp cx, 280                     ; Check if reached right edge
    jle fill_rect_col               ; Continue filling this row if not done
    
    inc dx                          ; Move to next row (down)
    cmp dx, 180                     ; Check if reached bottom edge
    jle fill_rect_row               ; Continue filling next row if not done
                                    ; Nested loops fill entire rectangle pixel by pixel

    ;---------------------------------------------------------------------------
    ; Demo 6: Draw a Diagonal Line (simple algorithm)
    ;---------------------------------------------------------------------------
    ; Draw a cyan diagonal line from (10, 10) to (100, 100)
    mov cx, 10                      ; CX = starting X
    mov dx, 10                      ; DX = starting Y
    
draw_diagonal:                      ; Label for diagonal line loop
    mov ah, 0Ch                     ; AH = 0Ch: Write pixel
    mov al, 0Bh                     ; AL = 0Bh: Light cyan color (11)
    mov bh, 00h                     ; BH = page 0
                                    ; CX has current X position
                                    ; DX has current Y position
    int 10h                         ; Draw pixel
    
    inc cx                          ; Increment X (move right)
    inc dx                          ; Increment Y (move down)
                                    ; Since both increment equally, creates 45° diagonal
    cmp cx, 100                     ; Check if reached end X
    jle draw_diagonal               ; Continue if not done
                                    ; This creates a perfect diagonal (slope = 1)

    ;---------------------------------------------------------------------------
    ; Demo 7: Draw a Color Gradient Bar
    ;---------------------------------------------------------------------------
    ; Draw a horizontal gradient bar showing colors 0-255
    mov dx, 10                      ; DX = 10: Y coordinate (top of screen)
    mov cx, 10                      ; CX = 10: Starting X coordinate
    mov bl, 00h                     ; BL = color counter (starts at 0)
    
gradient_loop:                      ; Label for gradient loop
    mov ah, 0Ch                     ; AH = 0Ch: Write pixel
    mov al, bl                      ; AL = current color (0-255)
                                    ; This cycles through all 256 colors
    mov bh, 00h                     ; BH = page 0
                                    ; CX has current X position
                                    ; DX = 10 (constant Y position)
    int 10h                         ; Draw pixel in current color
    
    ; Draw pixel below as well (make bar 2 pixels tall)
    push dx                         ; Save current Y coordinate
    mov dx, 11                      ; DX = 11: Y coordinate (one pixel below)
    int 10h                         ; Draw second pixel
    pop dx                          ; Restore original Y coordinate
    
    inc cx                          ; Move to next X position
    inc bl                          ; Increment color value
    cmp cx, 266                     ; Check if drawn 256 colors (10 + 256 = 266)
    jl gradient_loop                ; Continue if not done
                                    ; Result: horizontal bar showing color gradient

    ;---------------------------------------------------------------------------
    ; Wait for Keypress (Graphics Mode Input)
    ;---------------------------------------------------------------------------
    ; Note: DOS INT 21h still works in graphics mode for keyboard input
    mov ah, 01h                     ; DOS function 01h: Read character from keyboard
    int 21h                         ; Wait for keypress
                                    ; User can see the graphics before returning to text mode

    ;---------------------------------------------------------------------------
    ; Return to Text Mode
    ;---------------------------------------------------------------------------
    mov ah, 00h                     ; AH = 00h: Set video mode
    mov al, 03h                     ; AL = 03h: Text mode 80x25, 16 colors
    int 10h                         ; Return to standard text mode
                                    ; Graphics are cleared, text mode restored

    ;---------------------------------------------------------------------------
    ; Display Exit Message
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg_exit         ; Load offset of exit message
    int 21h                         ; Display "Press any key to return..."
    
    mov ah, 01h                     ; DOS function 01h: Read character
    int 21h                         ; Wait for final keypress

    ;---------------------------------------------------------------------------
    ; Exit Program
    ;---------------------------------------------------------------------------
    mov ah, 4ch                     ; DOS function 4Ch:   Terminate program with return code
    int 21h                         ; Call DOS interrupt to exit program and return to DOS
end                                 ; End of program (marks end of source code for assembler)

;===============================================================================
; SERVICE 0Ch REFERENCE
;===============================================================================
; INT 10h, AH=0Ch - Write Graphics Pixel
;
; INPUT:
;   AH = 0Ch (function number)
;   AL = Pixel color/value
;        Mode 04h (320x200x4): 0-3
;        Mode 06h (640x200x2): 0-1
;        Mode 0Dh (320x200x16): 0-15
;        Mode 13h (320x200x256): 0-255
;   BH = Page number (usually 0)
;   CX = X coordinate (column, horizontal position)
;        Mode 13h:  0-319
;        Mode 12h: 0-639
;   DX = Y coordinate (row, vertical position)
;        Mode 13h: 0-199
;        Mode 12h: 0-479
;
; OUTPUT:
;   None (pixel displayed on screen)
;
; NOTES:
;   - Only works in GRAPHICS modes (not text mode)
;   - Must set graphics mode first (INT 10h, AH=00h)
;   - Coordinate (0,0) is TOP-LEFT corner
;   - Drawing many pixels is SLOW using BIOS
;     (Direct video memory access is much faster for games)
;   - Can read pixel color with Service 0Dh (AH=0Dh)
;
; COMMON GRAPHICS MODES:
;   Mode 13h (320x200x256):
;     - Most popular for DOS games/demos
;     - CX range: 0-319, DX range: 0-199
;     - AL range: 0-255 colors
;     - Video memory: A000h: 0000h
;     - Linear:  address = y*320 + x
;
;   Mode 12h (640x480x16):
;     - Higher resolution VGA mode
;     - CX range:  0-639, DX range: 0-479
;     - AL range: 0-15 colors
;     - Better quality but fewer colors
;
; DRAWING TECHNIQUES:
;   - Point:  Single pixel
;   - Line: Loop incrementing coordinates
;   - Rectangle outline: Four line loops
;   - Filled rectangle:  Nested loops (rows and columns)
;   - Circle: Use trigonometric calculations
;   - Diagonal: Increment both X and Y equally
;
; PERFORMANCE: 
;   - BIOS pixel writes are slow (interrupt overhead)
;   - For fast graphics, write directly to video memory: 
;     * Segment A000h in mode 13h
;     * Address calculation: offset = y*320 + x
;     * Direct write:  MOV [ES:offset], color
;===============================================================================