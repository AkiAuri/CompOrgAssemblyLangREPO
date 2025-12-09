;===============================================================================
; PROGRAM: INT 21h DOS Services Demonstration
; PURPOSE: Demonstrates commonly used DOS interrupt 21h services
; DESCRIPTION: Shows how to use DOS functions for character I/O, string display,
;              and program termination with detailed explanations
;===============================================================================

.model small                        ; Define memory model as 'small' (code and data each fit in 64KB)
.stack 100h                         ; Allocate 256 bytes (100h) for the stack

.data                               ; Start of data segment (where variables and constants are stored)
    title_msg db "=== INT 21h DOS Services Demonstration ===",10,13,10,13,"$"
    
    ;---------------------------------------------------------------------------
    ; INT 21h - DOS FUNCTION CALLS
    ;---------------------------------------------------------------------------
    ; INT 21h is the main DOS interrupt for system services
    ; AH register specifies which service/function to call
    ; Other registers provide parameters and receive return values
    ; Available services include:
    ;   - Character input/output
    ;   - String input/output
    ;   - File operations
    ;   - Memory management
    ;   - Date/time functions
    ;   - And many more! 
    ;---------------------------------------------------------------------------
    
    ;---------------------------------------------------------------------------
    ; SERVICE 02h - Display Single ASCII Character
    ;---------------------------------------------------------------------------
    ; Input:   AH = 02h (function number)
    ;         DL = ASCII character code to display
    ; Output: Character displayed on screen
    ; Notes:  - Character in DL is sent to standard output
    ;         - Cursor advances automatically
    ;         - Control characters (like newline) are interpreted
    ;---------------------------------------------------------------------------
    msg_service02 db 10,13,"1. SERVICE 02h - Display Character",10,13
                  db "   Input:   AH = 02h, DL = ASCII character",10,13
                  db "   Output:  Displays character from DL",10,13,10,13
                  db "   Example - Displaying 'A' (ASCII 65):",10,13
                  db "   Character: $"
    
    ;---------------------------------------------------------------------------
    ; SERVICE 4Ch - Terminate Program
    ;---------------------------------------------------------------------------
    ; Input:   AH = 4Ch (function number)
    ;         AL = Return code (exit code, usually 0 for success)
    ; Output: Program terminates, control returns to DOS
    ; Notes:  - This is the PROPER way to exit a DOS program
    ;         - Cleans up resources and returns to command prompt
    ;         - AL contains exit code (0 = success, non-zero = error)
    ;---------------------------------------------------------------------------
    msg_service4c db 10,13,10,13,"2. SERVICE 4Ch - Terminate Program",10,13
                  db "   Input:  AH = 4Ch, AL = return code",10,13
                  db "   Output: Program exits to DOS",10,13
                  db "   This service will be called at the end! ",10,13,"$"
    
    ;---------------------------------------------------------------------------
    ; SERVICE 09h - Display String
    ;---------------------------------------------------------------------------
    ; Input:  AH = 09h (function number)
    ;         DX = Offset address of string (in DS segment)
    ; Output: String displayed on screen until '$' terminator
    ; Notes:  - String MUST end with '$' character
    ;         - '$' is not displayed (it's the terminator)
    ;         - Control characters (CR, LF) are interpreted
    ;         - Very common function for text output
    ;---------------------------------------------------------------------------
    msg_service09 db 10,13,10,13,"3. SERVICE 09h - Display String",10,13
                  db "   Input:  AH = 09h, DX = offset of string",10,13
                  db "   Output:  Displays string until '$'",10,13,10,13
                  db "   Example string: $"
    
    example_string db "Hello from DOS!$"
    
    ;---------------------------------------------------------------------------
    ; SERVICE 01h - Input Character with Echo
    ;---------------------------------------------------------------------------
    ; Input:  AH = 01h (function number)
    ; Output: AL = ASCII code of character typed
    ; Notes:   - Waits for user to press a key
    ;         - Character is ECHOED (displayed) on screen
    ;         - AL contains the ASCII code of the key pressed
    ;         - Special keys (F1, arrows) return 0 in AL first,
    ;           then extended code on second call
    ;---------------------------------------------------------------------------
    msg_service01 db 10,13,10,13,"4. SERVICE 01h - Input Character with Echo",10,13
                  db "   Input:  AH = 01h",10,13
                  db "   Output: AL = ASCII code of key pressed",10,13
                  db "   Note:   Character is echoed to screen",10,13,10,13
                  db "   Press any key to test:  $"
    
    msg_you_pressed db 10,13,"   You pressed: $"
    msg_ascii_code db " (ASCII code stored in AL)$"
    
    ; Variable to store the character pressed
    char_pressed db 0               ; Will store the character typed by user
                                    ; Initially 0, will be updated after input

.code                               ; Start of code segment (where program instructions are stored)
    mov ax, @data                   ; Load the address of data segment into AX register
                                    ; @data is a special symbol representing data segment address
    mov ds, ax                      ; Move AX value into DS (Data Segment register)
                                    ; DS now points to our data segment
                                    ; Required before accessing any variables

    ;---------------------------------------------------------------------------
    ; Clear Screen (using BIOS INT 10h, not INT 21h)
    ;---------------------------------------------------------------------------
    mov ah, 00h                     ; AH = 00h:  BIOS function to set video mode
    mov al, 03h                     ; AL = 03h: 80x25 text mode, 16 colors
    int 10h                         ; Call BIOS interrupt 10h (Video Services)
                                    ; This clears the screen and resets cursor

    ;---------------------------------------------------------------------------
    ; Display Title
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; AH = 09h: DOS function to display string
                                    ; This is SERVICE 09h we're demonstrating! 
    mov dx, offset title_msg        ; DX = offset address of title_msg
                                    ; offset gets the memory location of variable
                                    ; DX must point to start of string
    int 21h                         ; Call DOS interrupt 21h
                                    ; DOS reads string from DS:DX until it finds '$'

    ;---------------------------------------------------------------------------
    ; DEMO 1: SERVICE 02h - Display Single Character
    ;---------------------------------------------------------------------------
    ; This service displays ONE character at a time
    ; Character code must be in DL register
    ; Useful for displaying individual characters or building output
    ;---------------------------------------------------------------------------
    
    ; Display explanation message
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg_service02    ; Load address of SERVICE 02h explanation
    int 21h                         ; Display explanation

    ; *** THIS IS SERVICE 02h IN ACTION ***
    mov ah, 02h                     ; AH = 02h: DOS function to display single character
                                    ; This tells DOS which service we want
    mov dl, 'A'                     ; DL = 'A' (ASCII 65)
                                    ; DL holds the character to display
                                    ; 'A' is automatically converted to ASCII code 65
    int 21h                         ; Call DOS interrupt 21h
                                    ; DOS displays the character in DL
                                    ; Output: 'A' appears on screen

    ; Display another character using SERVICE 02h
    mov ah, 02h                     ; DOS function 02h: Display character
    mov dl, 'B'                     ; DL = 'B' (ASCII 66)
    int 21h                         ; Display 'B'
                                    ; Now 'AB' is displayed

    ; Display a digit using SERVICE 02h
    mov ah, 02h                     ; DOS function 02h: Display character
    mov dl, '5'                     ; DL = '5' (ASCII 53, not number 5!)
    int 21h                         ; Display '5'
                                    ; Important: '5' (ASCII 53) is different from number 5
                                    ; To display number 5, use:  mov dl, 5 + 30h

    ; Display a space
    mov ah, 02h                     ; DOS function 02h:  Display character
    mov dl, ' '                     ; DL = space character (ASCII 32)
    int 21h                         ; Display space

    ; Demonstrate displaying ASCII code stored in a variable
    mov bl, 72                      ; BL = 72 (ASCII code for 'H')
    mov ah, 02h                     ; DOS function 02h: Display character
    mov dl, bl                      ; Move BL value to DL
                                    ; This shows we can use any 8-bit register as source
    int 21h                         ; Display 'H' (ASCII 72)

    ;---------------------------------------------------------------------------
    ; Wait for User Keypress
    ;---------------------------------------------------------------------------
    mov ah, 01h                     ; DOS function 01h: Read character with echo
    int 21h                         ; Wait for keypress (demonstration of SERVICE 01h)

    ;---------------------------------------------------------------------------
    ; DEMO 2: SERVICE 4Ch Information (Demonstration Only)
    ;---------------------------------------------------------------------------
    ; We'll explain SERVICE 4Ch but won't call it yet
    ; (It will be called at the very end to exit the program)
    ;---------------------------------------------------------------------------
    
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg_service4c    ; Load address of SERVICE 4Ch explanation
    int 21h                         ; Display explanation
                                    ; This tells user about exit function

    ; Wait for keypress
    mov ah, 01h                     ; DOS function 01h: Input character with echo
    int 21h                         ; Wait for user to read the information

    ;---------------------------------------------------------------------------
    ; DEMO 3: SERVICE 09h - Display String
    ;---------------------------------------------------------------------------
    ; This is the most commonly used DOS function for text output
    ; Much easier than calling SERVICE 02h repeatedly
    ; String MUST end with '$' character (not null like C strings)
    ;---------------------------------------------------------------------------
    
    ; Display explanation
    mov ah, 09h                     ; DOS function 09h:  Display string
    mov dx, offset msg_service09    ; Load address of SERVICE 09h explanation
    int 21h                         ; Display explanation
                                    ; We're using SERVICE 09h to explain itself!

    ; *** THIS IS SERVICE 09h DISPLAYING A STRING ***
    mov ah, 09h                     ; AH = 09h: DOS function to display string
                                    ; This is the function we're demonstrating
    mov dx, offset example_string   ; DX = address of "Hello from DOS! $"
                                    ; DX must point to beginning of string
                                    ; String must end with '$'
    int 21h                         ; Call DOS interrupt 21h
                                    ; DOS displays entire string until '$'
                                    ; Output: "Hello from DOS!" ($ not shown)

    ; Demonstrate displaying newline using string
    mov ah, 09h                     ; DOS function 09h:  Display string
    mov dx, offset newline          ; Display newline character(s)
    int 21h                         ; Move to next line

    ; Wait for keypress
    mov ah, 01h                     ; DOS function 01h: Input character
    int 21h                         ; Wait

    ;---------------------------------------------------------------------------
    ; DEMO 4: SERVICE 01h - Input Character with Echo
    ;---------------------------------------------------------------------------
    ; This service waits for user to press a key
    ; The character is automatically displayed (echoed) on screen
    ; ASCII code of key is returned in AL register
    ; This is the basic way to get keyboard input in DOS programs
    ;---------------------------------------------------------------------------
    
    ; Display explanation and prompt
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg_service01    ; Load address of SERVICE 01h explanation
    int 21h                         ; Display explanation and prompt

    ; *** THIS IS SERVICE 01h IN ACTION ***
    mov ah, 01h                     ; AH = 01h: DOS function to input character with echo
                                    ; This tells DOS to wait for keyboard input
                                    ; Character will be echoed (displayed) automatically
    int 21h                         ; Call DOS interrupt 21h
                                    ; Program PAUSES here until user presses a key
                                    ; When key is pressed: 
                                    ;   1. Character is echoed (displayed) on screen
                                    ;   2. ASCII code is returned in AL register
                                    ; For example: if user presses 'X', AL = 58h (88 decimal)

    ; Store the character that was pressed
    mov char_pressed, al            ; Save AL (character code) into variable
                                    ; AL contains ASCII code of key pressed
                                    ; Now we've saved it for later use

    ; Display "You pressed: " message
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg_you_pressed  ; Load address of "You pressed:" message
    int 21h                         ; Display message

    ; Display the character again using SERVICE 02h
    mov ah, 02h                     ; DOS function 02h: Display single character
    mov dl, char_pressed            ; DL = the character user pressed
                                    ; We're displaying it again to show it's stored in AL
    int 21h                         ; Display the character

    ; Display additional message
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset msg_ascii_code   ; Load ASCII code message
    int 21h                         ; Display message

    ;---------------------------------------------------------------------------
    ; Additional Examples of INT 21h Usage
    ;---------------------------------------------------------------------------
    
    ; Example:  Display newline (CR + LF) using SERVICE 02h
    mov ah, 02h                     ; DOS function 02h: Display character
    mov dl, 0Dh                     ; DL = 0Dh:  Carriage Return (CR)
                                    ; Moves cursor to beginning of line
    int 21h                         ; Output CR
    
    mov ah, 02h                     ; DOS function 02h: Display character
    mov dl, 0Ah                     ; DL = 0Ah: Line Feed (LF)
                                    ; Moves cursor down one line
    int 21h                         ; Output LF
                                    ; Together CR+LF create a newline (like pressing Enter)

    ; Example: Display a number digit by digit
    ; To display number 5, we need ASCII '5' (53 decimal, not 5)
    mov ah, 02h                     ; DOS function 02h: Display character
    mov dl, 5                       ; DL = 5 (the number)
    add dl, 30h                     ; Add 30h (48 decimal) to convert to ASCII
                                    ; 5 + 48 = 53 = ASCII '5'
                                    ; This converts digit to displayable character
    int 21h                         ; Display '5'

    ; Wait before exit
    mov ah, 09h                     ; DOS function 09h: Display string
    mov dx, offset press_key_exit   ; Display exit prompt
    int 21h                         ; Show message
    
    mov ah, 01h                     ; DOS function 01h: Input character
    int 21h                         ; Wait for final keypress

    ;---------------------------------------------------------------------------
    ; DEMO 5: SERVICE 4Ch - Exit Program (CALLED HERE)
    ;---------------------------------------------------------------------------
    ; This is the PROPER way to end a DOS program
    ; ALWAYS use this service to exit cleanly
    ; AL register contains return code (0 = success, non-zero = error)
    ;---------------------------------------------------------------------------
    
    ; *** THIS IS SERVICE 4Ch IN ACTION ***
    mov ah, 4ch                     ; AH = 4Ch: DOS function to terminate program
                                    ; This is the most important DOS function!
                                    ; Every DOS program should end with this
    mov al, 00h                     ; AL = 00h: Return code (0 = success)
                                    ; Return code can be checked by DOS batch files
                                    ; 0 typically means "no error"
                                    ; Non-zero values indicate different error conditions
    int 21h                         ; Call DOS interrupt 21h
                                    ; Program terminates here
                                    ; Control returns to DOS command prompt
                                    ; All resources are cleaned up automatically
                                    ; THIS IS THE END OF THE PROGRAM!

    ; Nothing after this line will execute! 
    ; Service 4Ch terminates the program immediately

; Define additional strings after code (still in data segment conceptually)
newline db 10,13,"$"                ; Newline:  Line Feed (10) + Carriage Return (13)
press_key_exit db 10,13,10,13,"Press any key to exit program.. .$"

end                                 ; End of program (marks end of source code for assembler)

;===============================================================================
; INT 21h SERVICE SUMMARY
;===============================================================================
;
; SERVICE 01h - Input Character with Echo
;   Input:   AH = 01h
;   Output: AL = ASCII code of character pressed
;   Notes:  - Character is echoed (displayed) on screen
;           - Waits for keypress
;           - Handles Ctrl+C (terminates program)
;
; SERVICE 02h - Display Single Character
;   Input:  AH = 02h, DL = ASCII character to display
;   Output: Character displayed on screen
;   Notes:   - Displays ONE character from DL
;           - Control characters are interpreted
;           - Cursor advances automatically
;
; SERVICE 09h - Display String
;   Input:  AH = 09h, DX = offset of string (in DS segment)
;   Output: String displayed until '$' terminator
;   Notes:  - String MUST end with '$'
;           - Very common for text output
;           - Control characters (CR, LF) are interpreted
;           - '$' is NOT displayed
;
; SERVICE 4Ch - Terminate Program
;   Input:  AH = 4Ch, AL = return code
;   Output: Program exits to DOS
;   Notes:  - PROPER way to exit DOS program
;           - AL contains exit code (0 = success)
;           - Cleans up resources automatically
;           - MUST be called to exit cleanly
;
; Register Usage Convention:
;   AH = Function number (which service to call)
;   AL = Often used for return values or parameters
;   DL = Used for character I/O (Service 02h)
;   DX = Used for address pointers (Service 09h)
;
;===============================================================================