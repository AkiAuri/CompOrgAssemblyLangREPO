;===============================================================================
; PROGRAM: Service 03h - Get Cursor Position and Shape
; PURPOSE:  Demonstrates INT 10h, AH=03h (Get Cursor Position and Shape)
; DESCRIPTION: This program shows how to retrieve the current cursor position
;              and shape information.  This is useful when you need to save
;              cursor state, or display cursor information to the user.
;===============================================================================

.model small                        ; Define memory model as 'small' (code and data each fit in 64KB)
.stack 100h                         ; Allocate 256 bytes (100h) for the stack

.data                               ; Start of data segment (where variables and constants are stored)
    title_msg db "Get Cursor Position and Shape Demo",10,13,10,13,"$"
    msg1 db "Initial cursor information:",10,13,"$"
    msg_row db "Row (DH): $"        ; Label for row display
    msg_col db "  Column (DL): $"   ; Label for column display
    msg_start db "  Start Line (CH): $"  ; Label for start scan line
    msg_end db "  End Line (CL): $" ; Label for end scan line
    newline db 10,13,"$"            ; Newline characters
    
    msg2 db 10,13,"Moving cursor to center (12,40)...",10,13,"$"
    msg3 db 10,13,"New cursor information:",10,13,"$"
    
    msg4 db 10,13,"Changing cursor shape to block...",10,13,"$"
    msg5 db 10,13,"Cursor shape information:",10,13,"$"
    
    msg_exit db 10,13,"Press any key to exit...$"
    
    ; Variables to store cursor information
    cur_row db 0                    ; Current row position
    cur_col db 0                    ; Current column position
    cur_start db 0                  ; Cursor start scan line
    cur_end db 0                    ; Cursor end scan line

.code                               ; Start of code segment (where program instructions are stored)
    mov ax, @data                   ; Load the address of data segment into AX register
    mov ds, ax                      ; Move AX value into DS (Data Segment register) to access variables

    ;---------------------------------------------------------------------------
    ; Clear Screen
    ;---------------------------------------------------------------------------
    mov ah, 00h                     ; AH = 00h: Set video mode
    mov al, 03h                     ; AL = 03h:  80x25 text mode
    int 10h                         ; Clear screen and reset cursor

    ;---------------------------------------------------------------------------
    ; Display Title
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h: Display string terminated by '$'
    mov dx, offset title_msg        ; Load offset address of title
    int 21h                         ; Display title

    ;---------------------------------------------------------------------------
    ; SERVICE 03h - Get Initial Cursor Position and Shape
    ;---------------------------------------------------------------------------
    ; This service returns the current cursor position and shape
    ; It's useful when you need to: 
    ;   1. Save cursor state before moving it
    ;   2. Display cursor information to user
    ;   3. Restore cursor to previous position
    ;   4. Check current page information
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg1             ; Load offset of "Initial cursor information"
    int 21h                         ; Display message
    
    ; SERVICE 03h - Get cursor position and shape
    mov ah, 03h                     ; AH = 03h:  BIOS function to get cursor position and shape
    mov bh, 00h                     ; BH = 00h:  Page number to query (page 0)
                                    ; Different pages can have different cursor positions
    int 10h                         ; Call BIOS interrupt 10h (Video Services)
                                    ; Returns: 
                                    ;   CH = Cursor start scan line (top of cursor)
                                    ;   CL = Cursor end scan line (bottom of cursor)
                                    ;   DH = Row position (0-24)
                                    ;   DL = Column position (0-79)
    
    ; Save cursor information to variables
    mov cur_row, dh                 ; Store row position from DH into cur_row variable
    mov cur_col, dl                 ; Store column position from DL into cur_col variable
    mov cur_start, ch               ; Store cursor start line from CH into cur_start
    mov cur_end, cl                 ; Store cursor end line from CL into cur_end

    ;---------------------------------------------------------------------------
    ; Display Row Position
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg_row          ; Load offset of "Row (DH):" label
    int 21h                         ; Display label
    
    ; Convert row value to displayable digit
    mov dl, cur_row                 ; Load row value into DL
    add dl, 30h                     ; Convert to ASCII (add 48 to get '0'-'9')
                                    ; This only works for single digit (0-9)
                                    ; For values 10+, need multi-digit conversion
    mov ah, 02h                     ; DOS function 02h: Display single character
    int 21h                         ; Display row digit

    ;---------------------------------------------------------------------------
    ; Display Column Position
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg_col          ; Load offset of "Column (DL):" label
    int 21h                         ; Display label
    
    ; Convert column value to displayable digit
    mov dl, cur_col                 ; Load column value into DL
    add dl, 30h                     ; Convert to ASCII
    mov ah, 02h                     ; DOS function 02h:  Display character
    int 21h                         ; Display column digit

    ;---------------------------------------------------------------------------
    ; Display Cursor Start Line
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg_start        ; Load offset of "Start Line (CH):" label
    int 21h                         ; Display label
    
    ; Convert start line to displayable digit
    mov dl, cur_start               ; Load cursor start line value
    add dl, 30h                     ; Convert to ASCII
    mov ah, 02h                     ; DOS function 02h: Display character
    int 21h                         ; Display start line digit

    ;---------------------------------------------------------------------------
    ; Display Cursor End Line
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg_end          ; Load offset of "End Line (CL):" label
    int 21h                         ; Display label
    
    ; Convert end line to displayable digit
    mov dl, cur_end                 ; Load cursor end line value
    add dl, 30h                     ; Convert to ASCII
    mov ah, 02h                     ; DOS function 02h: Display character
    int 21h                         ; Display end line digit

    ;---------------------------------------------------------------------------
    ; Wait for User Input
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset newline          ; Load newline
    int 21h                         ; Print newline
    
    mov ah, 01h                     ; DOS function 01h: Read character
    int 21h                         ; Wait for keypress

    ;---------------------------------------------------------------------------
    ; Move Cursor to Center of Screen
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h:  Display string
    mov dx, offset msg2             ; Load offset of "Moving cursor to center..." message
    int 21h                         ; Display message
    
    ; Set cursor to center position
    mov ah, 02h                     ; AH = 02h: Set cursor position
    mov bh, 00h                     ; BH = page 0
    mov dh, 0Ch                     ; DH = 12 decimal (row 12, middle row)
    mov dl, 28h                     ; DL = 40 decimal (column 40, middle column)
    int 10h                         ; Move cursor to center (12,40)

    ;---------------------------------------------------------------------------
    ; SERVICE 03h - Get New Cursor Position After Moving
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg3             ; Load offset of "New cursor information:" message
    int 21h                         ; Display message
    
    ; Get cursor position again
    mov ah, 03h                     ; AH = 03h: Get cursor position and shape
    mov bh, 00h                     ; BH = page 0
    int 10h                         ; Call BIOS interrupt
                                    ; Returns updated position in DH, DL
    
    ; Save new cursor information
    mov cur_row, dh                 ; Store new row position
    mov cur_col, dl                 ; Store new column position
    mov cur_start, ch               ; Store cursor start line (unchanged)
    mov cur_end, cl                 ; Store cursor end line (unchanged)

    ;---------------------------------------------------------------------------
    ; Display New Row Position
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h:  Display string
    mov dx, offset msg_row          ; Load offset of "Row (DH):" label
    int 21h                         ; Display label
    
    ; Display row as two digits (for values 10-24)
    mov al, cur_row                 ; Load row value into AL
    mov ah, 0                       ; Clear AH for division
    mov bl, 10                      ; Divisor = 10 (to get tens and ones)
    div bl                          ; Divide AL by 10: quotient in AL, remainder in AH
    
    ; Display tens digit
    mov dl, al                      ; Move tens digit to DL
    add dl, 30h                     ; Convert to ASCII
    push ax                         ; Save AX (contains remainder in AH)
    mov ah, 02h                     ; DOS function 02h: Display character
    int 21h                         ; Display tens digit
    pop ax                          ; Restore AX
    
    ; Display ones digit
    mov dl, ah                      ; Move ones digit (remainder) to DL
    add dl, 30h                     ; Convert to ASCII
    mov ah, 02h                     ; DOS function 02h: Display character
    int 21h                         ; Display ones digit

    ;---------------------------------------------------------------------------
    ; Display New Column Position
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h:  Display string
    mov dx, offset msg_col          ; Load offset of "Column (DL):" label
    int 21h                         ; Display label
    
    ; Display column as two digits (for values 10-79)
    mov al, cur_col                 ; Load column value into AL
    mov ah, 0                       ; Clear AH for division
    mov bl, 10                      ; Divisor = 10
    div bl                          ; Divide:  tens in AL, ones in AH
    
    ; Display tens digit
    mov dl, al                      ; Move tens digit to DL
    add dl, 30h                     ; Convert to ASCII
    push ax                         ; Save AX
    mov ah, 02h                     ; DOS function 02h:  Display character
    int 21h                         ; Display tens digit
    pop ax                          ; Restore AX
    
    ; Display ones digit
    mov dl, ah                      ; Move ones digit to DL
    add dl, 30h                     ; Convert to ASCII
    mov ah, 02h                     ; DOS function 02h: Display character
    int 21h                         ; Display ones digit

    ;---------------------------------------------------------------------------
    ; Wait for User Input
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset newline          ; Load newline
    int 21h                         ; Print newline
    
    mov ah, 01h                     ; DOS function 01h:  Read character
    int 21h                         ; Wait for keypress

    ;---------------------------------------------------------------------------
    ; Change Cursor Shape to Block
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg4             ; Load offset of "Changing cursor shape..." message
    int 21h                         ; Display message
    
    ; Set cursor shape to block
    mov ah, 01h                     ; AH = 01h: Set cursor shape
    mov ch, 00h                     ; CH = 0:  Start line 0 (top)
    mov cl, 07h                     ; CL = 7: End line 7 (bottom) - creates block
    int 10h                         ; Change cursor to block shape

    ;---------------------------------------------------------------------------
    ; SERVICE 03h - Get Cursor Shape After Change
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg5             ; Load offset of "Cursor shape information:" message
    int 21h                         ; Display message
    
    ; Get cursor information again to show new shape
    mov ah, 03h                     ; AH = 03h: Get cursor position and shape
    mov bh, 00h                     ; BH = page 0
    int 10h                         ; Call BIOS interrupt
                                    ; Returns new shape values in CH, CL
    
    ; Save new cursor shape information
    mov cur_start, ch               ; Store new cursor start line
    mov cur_end, cl                 ; Store new cursor end line

    ;---------------------------------------------------------------------------
    ; Display New Cursor Start Line
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h:  Display string
    mov dx, offset msg_start        ; Load offset of "Start Line (CH):" label
    int 21h                         ; Display label
    
    mov dl, cur_start               ; Load cursor start line value
    add dl, 30h                     ; Convert to ASCII
    mov ah, 02h                     ; DOS function 02h: Display character
    int 21h                         ; Display start line digit

    ;---------------------------------------------------------------------------
    ; Display New Cursor End Line
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; DOS function 09h:  Display string
    mov dx, offset msg_end          ; Load offset of "End Line (CL):" label
    int 21h                         ; Display label
    
    mov dl, cur_end                 ; Load cursor end line value
    add dl, 30h                     ; Convert to ASCII
    mov ah, 02h                     ; DOS function 02h: Display character
    int 21h                         ; Display end line digit

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
; SERVICE 03h REFERENCE
;===============================================================================
; INT 10h, AH=03h - Get Cursor Position and Shape
;
; INPUT:
;   AH = 03h (function number)
;   BH = Page number (0-7 for text modes, usually 0)
;
; OUTPUT:
;   CH = Cursor start scan line (0-15, bits 0-4)
;        Bit 5 set (20h) means cursor is hidden
;   CL = Cursor end scan line (0-15)
;   DH = Row (0-24 for 80x25 text mode)
;   DL = Column (0-79 for 80x25 text mode)
;
; USES:
;   - Save cursor position before moving it
;   - Restore cursor to saved position later
;   - Display current cursor information to user
;   - Check if cursor is visible (test bit 5 of CH)
;   - Get cursor shape for display or logging
;
; NOTES:
;   - Each video page has its own cursor position
;   - Cursor shape is shared across all pages
;   - Page 0 is the default visible page
;   - Some BIOS may return different scan line values
;===============================================================================