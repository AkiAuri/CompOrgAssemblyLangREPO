;===============================================================================
; PROGRAM: Service 0Eh - Write Character in TTY Mode (Teletype Output)
; PURPOSE:   Demonstrates INT 10h, AH=0Eh (Write Teletype)
; DESCRIPTION:  This is the simplest text output service.   It writes a character
;              at the cursor position and automatically advances the cursor.
;              It interprets control characters like newline and backspace.
;              This is like an old teletype terminal - sequential output.
;===============================================================================

.model small                        ; Define memory model as 'small' (code and data each fit in 64KB)
.stack 100h                         ; Allocate 256 bytes (100h) for the stack

.data                               ; Start of data segment (where variables and constants are stored)
    title_str db "Service 0Eh - Teletype Output Demonstration", 0Dh, 0Ah
              db "============================================", 0Dh, 0Ah, 0Ah, 0
    
    msg1 db "1. Basic teletype output:", 0Dh, 0Ah
         db "   Hello, World!", 0Dh, 0Ah, 0Ah, 0
    
    msg2 db "2. Cursor advances automatically", 0Dh, 0Ah
         db "   No need to move cursor manually!", 0Dh, 0Ah, 0Ah, 0
    
    msg3 db "3. Control characters work:", 0Dh, 0Ah, 0
    
    msg4 db "   Newline test:", 0Dh, 0Ah
         db "   Line 1", 0Dh, 0Ah
         db "   Line 2", 0Dh, 0Ah
         db "   Line 3", 0Dh, 0Ah, 0Ah, 0
    
    msg5 db "4. Tab character test:", 0Dh, 0Ah
         db "   A", 09h, "B", 09h, "C", 09h, "D", 0Dh, 0Ah, 0Ah, 0
    
    msg6 db "5. Backspace test (watch carefully):", 0Dh, 0Ah
         db "   XXXXX", 0
    
    msg7 db "6. Bell/Beep character (you should hear a beep):", 0Dh, 0Ah, 0
    
    msg8 db 0Dh, 0Ah, 0Ah, "7. Character-by-character output:", 0Dh, 0Ah
         db "   ", 0
    
    char_array db "TELETYPE", 0     ; String to print character by character
    
    msg9 db 0Dh, 0Ah, 0Ah, "8. Scrolling test (fills screen):", 0Dh, 0Ah, 0
    
    msg_exit db 0Dh, 0Ah, "Press any key to exit...", 0

.code                               ; Start of code segment (where program instructions are stored)
    mov ax, @data                   ; Load the address of data segment into AX register
    mov ds, ax                      ; Move AX value into DS (Data Segment register) to access variables

    ;---------------------------------------------------------------------------
    ; SERVICE 0Eh - TELETYPE MODE EXPLANATION
    ;---------------------------------------------------------------------------
    ; Service 0Eh is called "Teletype" because it mimics old teletype terminals: 
    ;   - Writes one character at a time
    ;   - Cursor automatically advances after each character
    ;   - Interprets control characters (CR, LF, TAB, BELL, BS)
    ;   - Screen scrolls when cursor reaches bottom
    ;   - Simplest way to display text (like printf or cout)
    ;
    ; Advantages:
    ;   - Automatic cursor advancement (no manual positioning needed)
    ;   - Handles control characters (newlines, tabs, etc.)
    ;   - Automatic scrolling at screen bottom
    ;   - Very simple to use
    ;
    ; Disadvantages:
    ;   - Can't specify color (uses current attribute)
    ;   - Sequential only (no random positioning)
    ;   - Slower than other methods for bulk output
    ;
    ; Control Characters Supported:
    ;   07h (BEL): Bell/Beep sound
    ;   08h (BS):  Backspace (move cursor left, erase character)
    ;   09h (TAB): Tab (move to next 8-column boundary)
    ;   0Ah (LF):  Line Feed (move cursor down one line)
    ;   0Dh (CR):  Carriage Return (move cursor to start of line)
    ;---------------------------------------------------------------------------

    ;---------------------------------------------------------------------------
    ; Clear Screen
    ;---------------------------------------------------------------------------
    mov ah, 00h                     ; AH = 00h: Set video mode
    mov al, 03h                     ; AL = 03h: 80x25 text mode
    int 10h                         ; Clear screen and reset cursor

    ;---------------------------------------------------------------------------
    ; Demo 1: Display Title String Using Teletype
    ;---------------------------------------------------------------------------
    mov si, offset title_str        ; SI = offset of title string
                                    ; SI will be used as pointer to walk through string
    
print_title:                        ; Label for title printing loop
    mov al, [si]                    ; Load character from string at address [SI] into AL
                                    ; [SI] means "contents of memory at address SI"
    cmp al, 0                       ; Compare AL with 0 (null terminator)
                                    ; Strings end with 0 (not '$' like DOS function 09h)
    je title_done                   ; If AL = 0, jump to title_done (end of string)
    
    ; SERVICE 0Eh - Write character in teletype mode
    mov ah, 0Eh                     ; AH = 0Eh:  BIOS function for teletype output
    mov bh, 00h                     ; BH = 00h: Display page number (usually page 0)
                                    ; Different pages allow multiple screen buffers
    mov bl, 0Fh                     ; BL = 0Fh: Foreground color (white = 15)
                                    ; In text modes, BL sets text color
                                    ; In graphics modes, BL is ignored
                                    ; Note: Background color comes from current screen attribute
    int 10h                         ; Call BIOS interrupt 10h (Video Services)
                                    ; Character in AL is displayed and cursor advances
                                    ; Control characters (CR, LF) are interpreted
    
    inc si                          ; Increment SI to point to next character in string
    jmp print_title                 ; Jump back to process next character
    
title_done:                         ; Label when title printing is complete

    ;---------------------------------------------------------------------------
    ; Demo 2: Display Basic Message
    ;---------------------------------------------------------------------------
    mov si, offset msg1             ; SI = offset of msg1
    
print_msg1:                         ; Label for msg1 printing loop
    mov al, [si]                    ; Load character from string
    cmp al, 0                       ; Check for null terminator
    je msg1_done                    ; If end of string, jump to done
    
    mov ah, 0Eh                     ; AH = 0Eh:  Teletype output
    mov bh, 00h                     ; BH = page 0
    mov bl, 0Ah                     ; BL = 0Ah: Green color (10)
    int 10h                         ; Display character
    
    inc si                          ; Move to next character
    jmp print_msg1                  ; Continue loop
    
msg1_done:                           ; End of msg1

    ;---------------------------------------------------------------------------
    ; Demo 3: Show Automatic Cursor Advancement
    ;---------------------------------------------------------------------------
    mov si, offset msg2             ; SI = offset of msg2
    
print_msg2:                         ; Label for msg2 printing loop
    mov al, [si]                    ; Load character
    cmp al, 0                       ; Check for end
    je msg2_done                    ; If done, exit loop
    
    mov ah, 0Eh                     ; AH = 0Eh:  Teletype output
    mov bh, 00h                     ; BH = page 0
    mov bl, 0Eh                     ; BL = 0Eh: Yellow color (14)
    int 10h                         ; Display character (cursor advances automatically)
                                    ; No need to call INT 10h, AH=02h to move cursor! 
    
    inc si                          ; Next character
    jmp print_msg2                  ; Continue
    
msg2_done:                          ; End of msg2

    ;---------------------------------------------------------------------------
    ; Demo 4: Control Characters - Newlines
    ;---------------------------------------------------------------------------
    mov si, offset msg3             ; SI = offset of msg3
    call print_string               ; Call reusable print function (defined at bottom)
    
    mov si, offset msg4             ; SI = offset of msg4 (contains CR and LF characters)
    call print_string               ; Print string with newlines
                                    ; Notice: 0Dh (CR) and 0Ah (LF) are interpreted
                                    ; 0Dh = Carriage Return (move to start of line)
                                    ; 0Ah = Line Feed (move down one line)
                                    ; Together (0Dh, 0Ah) create a complete newline

    ;---------------------------------------------------------------------------
    ; Demo 5: Tab Character
    ;---------------------------------------------------------------------------
    mov si, offset msg5             ; SI = offset of msg5 (contains TAB characters)
    call print_string               ; Print string with tabs
                                    ; TAB (09h) moves cursor to next 8-column boundary
                                    ; If at column 5, TAB moves to column 8
                                    ; If at column 10, TAB moves to column 16
                                    ; Tab stops:  0, 8, 16, 24, 32, 40, 48, 56, 64, 72

    ;---------------------------------------------------------------------------
    ; Demo 6: Backspace Character
    ;---------------------------------------------------------------------------
    mov si, offset msg6             ; SI = offset of msg6
    call print_string               ; Print "XXXXX"
    
    ; Now send backspace characters to erase the X's
    mov cx, 5                       ; CX = 5: Number of backspaces to send
    
backspace_loop:                     ; Label for backspace loop
    mov ah, 0Eh                     ; AH = 0Eh:  Teletype output
    mov al, 08h                     ; AL = 08h: Backspace character (BS)
                                    ; Backspace moves cursor left and erases character
    mov bh, 00h                     ; BH = page 0
    mov bl, 0Fh                     ; BL = white color
    int 10h                         ; Send backspace
                                    ; Cursor moves left and character is erased
    
    ; Small delay so user can see the backspaces happening
    push cx                         ; Save loop counter
    mov cx, 0FFFFh                  ; CX = delay count (large number)
delay_bs:                           ; Delay loop
    loop delay_bs                   ; Decrement CX and loop until CX=0
    pop cx                          ; Restore loop counter
    
    loop backspace_loop             ; Repeat for all 5 X's
                                    ; Result: X's disappear one by one

    ;---------------------------------------------------------------------------
    ; Wait for keypress before continuing
    ;---------------------------------------------------------------------------
    mov ah, 01h                     ; DOS function 01h: Read character
    int 21h                         ; Wait for user input

    ;---------------------------------------------------------------------------
    ; Demo 7: Bell Character (Beep)
    ;---------------------------------------------------------------------------
    mov si, offset msg7             ; SI = offset of msg7
    call print_string               ; Display message
    
    mov ah, 0Eh                     ; AH = 0Eh:  Teletype output
    mov al, 07h                     ; AL = 07h: Bell character (BEL)
                                    ; Produces a beep sound from PC speaker
                                    ; Does not display anything on screen
    mov bh, 00h                     ; BH = page 0
    mov bl, 0Fh                     ; BL = white
    int 10h                         ; Send bell character (you should hear a beep!)
                                    ; On modern systems, may produce system beep
    
    ; Print newline after beep
    mov al, 0Dh                     ; CR
    int 10h
    mov al, 0Ah                     ; LF
    int 10h

    ;---------------------------------------------------------------------------
    ; Demo 8: Character-by-Character Output (Typewriter Effect)
    ;---------------------------------------------------------------------------
    mov si, offset msg8             ; SI = offset of msg8
    call print_string               ; Display intro message
    
    mov si, offset char_array       ; SI = offset of "TELETYPE" string
    
typewriter_loop:                    ; Label for typewriter effect loop
    mov al, [si]                    ; Load character
    cmp al, 0                       ; Check for end of string
    je typewriter_done              ; If done, exit
    
    mov ah, 0Eh                     ; AH = 0Eh: Teletype output
    mov bh, 00h                     ; BH = page 0
    mov bl, 0Ch                     ; BL = 0Ch: Light red color (12)
    int 10h                         ; Display one character
    
    ; Delay to create typewriter effect (pause between characters)
    push si                         ; Save SI register
    mov cx, 0FFFFh                  ; CX = delay count
delay_type:                         ; Delay loop
    nop                             ; No operation (just waste time)
    loop delay_type                 ; Decrement CX and loop
    pop si                          ; Restore SI
    
    inc si                          ; Move to next character
    jmp typewriter_loop             ; Continue
    
typewriter_done:                     ; Typewriter effect complete

    ;---------------------------------------------------------------------------
    ; Wait for keypress before scrolling demo
    ;---------------------------------------------------------------------------
    mov ah, 01h                     ; DOS function 01h: Read character
    int 21h                         ; Wait for user

    ;---------------------------------------------------------------------------
    ; Demo 9: Automatic Scrolling
    ;---------------------------------------------------------------------------
    ; When cursor reaches row 24 (bottom), screen automatically scrolls up
    mov si, offset msg9             ; SI = offset of msg9
    call print_string               ; Display intro message
    
    ; Print many lines to force scrolling
    mov cx, 30                      ; CX = 30: Number of lines to print
                                    ; Since screen has 25 lines, this will cause scrolling
    
scroll_loop:                        ; Label for scrolling loop
    push cx                         ; Save loop counter
    
    ; Print line number (simplified, just prints asterisks)
    mov ah, 0Eh                     ; AH = 0Eh:  Teletype output
    mov al, '*'                     ; AL = asterisk character
    mov bh, 00h                     ; BH = page 0
    mov bl, 09h                     ; BL = 09h: Light blue color (9)
    int 10h                         ; Display asterisk
    
    ; Print several more characters on this line
    mov al, '*'
    int 10h
    mov al, '*'
    int 10h
    mov al, ' '
    int 10h
    
    ; Convert loop counter to display
    pop cx                          ; Get loop counter
    push cx                         ; Save it again
    
    ; Print "Line X"
    mov al, 'L'
    int 10h
    mov al, 'i'
    int 10h
    mov al, 'n'
    int 10h
    mov al, 'e'
    int 10h
    mov al, ' '
    int 10h
    
    ; Print newline
    mov al, 0Dh                     ; Carriage return
    int 10h
    mov al, 0Ah                     ; Line feed
    int 10h                         ; When this reaches row 24, screen scrolls up! 
                                    ; Top line disappears, all content moves up one line
                                    ; Cursor stays at row 24 (bottom line)
    
    pop cx                          ; Restore loop counter
    loop scroll_loop                ; Continue for all 30 lines
                                    ; Watch the screen scroll automatically!

    ;---------------------------------------------------------------------------
    ; Display Exit Message
    ;---------------------------------------------------------------------------
    mov si, offset msg_exit         ; SI = offset of exit message
    call print_string               ; Display "Press any key to exit..."
    
    mov ah, 01h                     ; DOS function 01h: Read character
    int 21h                         ; Wait for keypress

    ;---------------------------------------------------------------------------
    ; Exit Program
    ;---------------------------------------------------------------------------
    mov ah, 4ch                     ; DOS function 4Ch:  Terminate program with return code
    int 21h                         ; Call DOS interrupt to exit program and return to DOS

;===============================================================================
; REUSABLE SUBROUTINE:  Print Null-Terminated String
;===============================================================================
print_string proc                   ; Start of procedure
    push si                         ; Save SI (preserve caller's value)
    push ax                         ; Save AX
    
ps_loop:                            ; Label for print string loop
    mov al, [si]                    ; Load character from string at [SI]
    cmp al, 0                       ; Check if null terminator (end of string)
    je ps_done                      ; If end, jump to done
    
    mov ah, 0Eh                     ; AH = 0Eh: Teletype output
    mov bh, 00h                     ; BH = page 0
    mov bl, 0Fh                     ; BL = white color
    int 10h                         ; Display character
    
    inc si                          ; Move to next character
    jmp ps_loop                     ; Continue loop
    
ps_done:                            ; String printing complete
    pop ax                          ; Restore AX
    pop si                          ; Restore SI
    ret                             ; Return to caller
print_string endp                   ; End of procedure

end                                 ; End of program (marks end of source code for assembler)

;===============================================================================
; SERVICE 0Eh REFERENCE
;===============================================================================
; INT 10h, AH=0Eh - Write Character in TTY (Teletype) Mode
;
; INPUT:
;   AH = 0Eh (function number)
;   AL = Character to write (ASCII code or control character)
;   BH = Display page number (usually 0)
;   BL = Foreground color (in graphics modes)
;        In text modes, uses current attribute
;
; OUTPUT:
;   None (character displayed, cursor advances)
;
; CONTROL CHARACTERS INTERPRETED:
;   07h (BEL): Bell/Beep - produces sound
;   08h (BS):  Backspace - moves cursor left, erases character
;   09h (TAB): Tab - moves to next 8-column boundary
;   0Ah (LF):  Line Feed - moves cursor down one line
;   0Dh (CR):  Carriage Return - moves cursor to column 0
;
; BEHAVIOR:
;   - Cursor automatically advances after each character
;   - Control characters are interpreted (not displayed)
;   - Screen scrolls up when cursor reaches bottom (row 24)
;   - Uses current screen attribute for color
;   - Works in both text and graphics modes
;
; ADVANTAGES:
;   - Simplest text output method
;   - Automatic cursor advancement
;   - Handles newlines and other control characters
;   - Automatic scrolling
;   - Sequential output (like console/terminal)
;
; DISADVANTAGES:
;   - Cannot specify exact position (sequential only)
;   - Cannot easily specify color per character
;   - Slower than direct video memory writes
;   - No way to disable scrolling
;
; COMMON USES:
;   - Console-style output (like printf, cout)
;   - Debug messages
;   - Simple text display
;   - Terminal emulation
;   - Logging output
;   - Typewriter effects
;
; COMPARISON WITH OTHER SERVICES:
;   Service 09h (AH=09h):
;     - Writes with specific attribute (color)
;     - Cursor does NOT advance
;     - For positioned, colored text
;
;   Service 0Ah (AH=0Ah):
;     - Writes without changing attribute
;     - Cursor does NOT advance
;     - For updating existing text
;
;   Service 0Eh (AH=0Eh):
;     - Uses current attribute
;     - Cursor DOES advance
;     - For sequential text output (THIS SERVICE)
;
; USAGE EXAMPLE:
;   mov ah, 0Eh        ; Teletype output
;   mov al, 'A'        ; Character to display
;   mov bh, 00h        ; Page 0
;   mov bl, 0Fh        ; White color
;   int 10h            ; Display 'A' and advance cursor
;===============================================================================