;===============================================================================
; PROGRAM:  Service 00h - Set Video Mode
; PURPOSE: Demonstrates INT 10h, AH=00h (Set Video Mode)
; DESCRIPTION: This program shows how to change video modes using BIOS
;              interrupt 10h.  It cycles through different video modes to
;              demonstrate text and graphics mode capabilities.
;===============================================================================

.model small                        ; Define memory model as 'small' (code and data each fit in 64KB)
.stack 100h                         ; Allocate 256 bytes (100h) for the stack

.data                               ; Start of data segment (where variables and constants are stored)
    msg1 db "Video Mode 03h:  80x25 Text, 16 Colors",10,13,"$"   ; Message for mode 3
    msg2 db "Press any key for next mode...",10,13,"$"          ; Prompt message
    msg3 db "Video Mode 00h: 40x25 Text, 16 Colors",10,13,"$"   ; Message for mode 0
    msg4 db "Video Mode 02h: 80x25 Text, Monochrome",10,13,"$"  ; Message for mode 2
    msg5 db "Returning to Mode 03h...",10,13,"$"                ; Final message

.code                               ; Start of code segment (where program instructions are stored)
    mov ax, @data                   ; Load the address of data segment into AX register
    mov ds, ax                      ; Move AX value into DS (Data Segment register) to access variables

    ;---------------------------------------------------------------------------
    ; SERVICE 00h - Set Video Mode to 03h (80x25 Text, 16 Colors)
    ;---------------------------------------------------------------------------
    ; This is the standard text mode used by DOS
    ; Resolution: 80 columns x 25 rows
    ; Colors: 16 foreground colors, 8 background colors
    ; Character size: 8x16 pixels
    ;---------------------------------------------------------------------------
    mov ah, 00h                     ; AH = 00h:  BIOS function to set video mode
    mov al, 03h                     ; AL = 03h:  Video mode 3 (80x25 text, 16 colors)
                                    ; Mode 03h is the most commonly used text mode
                                    ; It clears the screen and resets cursor to (0,0)
    int 10h                         ; Call BIOS interrupt 10h (Video Services)
                                    ; After this call, screen is cleared and ready for text
    
    ; Display message for mode 03h
    mov ah, 09h                     ; DOS function 09h: Display string terminated by '$'
    mov dx, offset msg1             ; Load offset address of msg1 into DX register
    int 21h                         ; Call DOS interrupt to display message
    
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg2             ; Load offset address of msg2 (prompt)
    int 21h                         ; Display "Press any key..."
    
    ; Wait for keypress
    mov ah, 01h                     ; DOS function 01h: Read single character from keyboard
    int 21h                         ; Call DOS interrupt, waits for user input
                                    ; Character is stored in AL and echoed to screen

    ;---------------------------------------------------------------------------
    ; SERVICE 00h - Set Video Mode to 00h (40x25 Text, 16 Colors)
    ;---------------------------------------------------------------------------
    ; This mode has wider characters (40 columns instead of 80)
    ; Useful for large text display or low-resolution monitors
    ; Resolution: 40 columns x 25 rows
    ; Colors: 16 foreground colors, 8 background colors
    ;---------------------------------------------------------------------------
    mov ah, 00h                     ; AH = 00h: BIOS function to set video mode
    mov al, 00h                     ; AL = 00h: Video mode 0 (40x25 text, 16 colors)
                                    ; Characters appear twice as wide as mode 03h
                                    ; Often used for presentations or visual impairment
    int 10h                         ; Call BIOS interrupt 10h
                                    ; Screen is cleared and cursor reset
    
    ; Display message for mode 00h
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg3             ; Load offset address of msg3
    int 21h                         ; Display message about mode 00h
    
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg2             ; Load offset address of prompt message
    int 21h                         ; Display "Press any key..."
    
    ; Wait for keypress
    mov ah, 01h                     ; DOS function 01h: Read character
    int 21h                         ; Wait for user input

    ;---------------------------------------------------------------------------
    ; SERVICE 00h - Set Video Mode to 02h (80x25 Text, Monochrome)
    ;---------------------------------------------------------------------------
    ; This is the monochrome text mode
    ; Resolution: 80 columns x 25 rows
    ; Colors:  Monochrome (typically green or amber on black)
    ; Used with MDA (Monochrome Display Adapter) or for monochrome effect
    ;---------------------------------------------------------------------------
    mov ah, 00h                     ; AH = 00h:  BIOS function to set video mode
    mov al, 02h                     ; AL = 02h: Video mode 2 (80x25 monochrome text)
                                    ; Same resolution as mode 03h but monochrome
                                    ; On color displays, appears as white on black
    int 10h                         ; Call BIOS interrupt 10h
                                    ; Screen cleared and ready for monochrome text
    
    ; Display message for mode 02h
    mov ah, 09h                     ; DOS function 09h:  Display string
    mov dx, offset msg4             ; Load offset address of msg4
    int 21h                         ; Display message about mode 02h
    
    mov ah, 09h                     ; DOS function 09h:  Display string
    mov dx, offset msg2             ; Load offset address of prompt message
    int 21h                         ; Display "Press any key..."
    
    ; Wait for keypress
    mov ah, 01h                     ; DOS function 01h: Read character
    int 21h                         ; Wait for user input

    ;---------------------------------------------------------------------------
    ; Return to Standard Video Mode 03h
    ;---------------------------------------------------------------------------
    mov ah, 00h                     ; AH = 00h: Set video mode
    mov al, 03h                     ; AL = 03h:  Return to standard 80x25 color text
    int 10h                         ; Call BIOS interrupt to restore normal mode
    
    ; Display final message
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg5             ; Load offset address of msg5
    int 21h                         ; Display "Returning to Mode 03h..."
    
    ; Wait before exit
    mov ah, 01h                     ; DOS function 01h: Read character
    int 21h                         ; Wait for final keypress

    ;---------------------------------------------------------------------------
    ; Exit Program
    ;---------------------------------------------------------------------------
    mov ah, 4ch                     ; DOS function 4Ch:  Terminate program with return code
    int 21h                         ; Call DOS interrupt to exit program and return to DOS
end                                 ; End of program (marks end of source code for assembler)

;===============================================================================
; VIDEO MODE REFERENCE TABLE
;===============================================================================
; Mode | Resolution | Type     | Colors | Description
;------|------------|----------|--------|----------------------------------------
; 00h  | 40x25      | Text     | 16     | 40 column text, 16 colors
; 01h  | 40x25      | Text     | 16     | 40 column text, 16 colors
; 02h  | 80x25      | Text     | Mono   | 80 column text, monochrome
; 03h  | 80x25      | Text     | 16     | 80 column text, 16 colors (STANDARD)
; 04h  | 320x200    | Graphics | 4      | CGA graphics, 4 colors
; 05h  | 320x200    | Graphics | 4      | CGA graphics, 4 colors (monochrome)
; 06h  | 640x200    | Graphics | 2      | CGA graphics, 2 colors
; 0Dh  | 320x200    | Graphics | 16     | EGA graphics, 16 colors
; 0Eh  | 640x200    | Graphics | 16     | EGA graphics, 16 colors
; 0Fh  | 640x350    | Graphics | Mono   | EGA graphics, monochrome
; 10h  | 640x350    | Graphics | 16     | EGA graphics, 16 colors
; 11h  | 640x480    | Graphics | 2      | VGA graphics, 2 colors
; 12h  | 640x480    | Graphics | 16     | VGA graphics, 16 colors
; 13h  | 320x200    | Graphics | 256    | VGA graphics, 256 colors (MCGA)
;===============================================================================