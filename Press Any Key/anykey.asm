;===============================================================================
; PROGRAM: Press Any Key Example
; DATE:  11/26/25
; PURPOSE: Demonstrates a program that asks user to press any key and outputs
;          the key that was pressed
; DESCRIPTION: This program shows:
;              1. How to display a prompt message
;              2. How to wait for keyboard input (INT 21h, AH=01h)
;              3. How to store the input character
;              4. How to display the character that was pressed
;              Complete example with full explanation of each step
;===============================================================================

.model small                        ; Define memory model as 'small' (code and data each fit in 64KB)
                                    ; Small model:   code in one segment, data in another
                                    ; Most common model for simple DOS programs
.stack 100h                         ; Allocate 256 bytes (100h hexadecimal) for the stack
                                    ; Stack is used for:  
                                    ;   - Storing return addresses
                                    ;   - Temporary data storage (PUSH/POP)
                                    ;   - Local variables in procedures
                                    ; 256 bytes is sufficient for most simple programs

.data                               ; Start of data segment (where variables and strings are stored)
                                    ; All variables declared here are stored in memory
                                    ; DS register will point to this segment during execution
    
    ;---------------------------------------------------------------------------
    ; MESSAGE STRINGS
    ;---------------------------------------------------------------------------
    ; Strings in assembly must end with a terminator
    ; For DOS INT 21h, AH=09h:  use '$' as terminator
    ; '$' tells DOS where the string ends
    ;---------------------------------------------------------------------------
    
    msg1 db "Press any key:  $"      ; First message (prompt for user)
                                    ; db = Define Byte (allocates 1 byte per character)
                                    ; "Press any key: " = the text string
                                    ; $ = terminator (tells DOS to stop displaying here)
                                    ; This string is 16 bytes:  15 characters + 1 terminator
                                    ; Memory layout:  'P','r','e','s','s',' ','a','n','y',' ','k','e','y',':',' ','$'
    
    inp db 0                        ; Variable to store user's input character
                                    ; db 0 = Define Byte initialized to 0
                                    ; This reserves 1 byte of memory
                                    ; Initial value is 0 (will be overwritten with user input)
                                    ; This is equivalent to "binary or any" note in image
                                    ; Can store any ASCII character (0-255)
    
    msg2 db 0Ah, 0Dh, "You pressed: $"  ; Second message (shows what user pressed)
                                    ; 0Ah = Line Feed (LF) - ASCII 10 decimal
                                    ;       Moves cursor DOWN one line (vertical movement)
                                    ; 0Dh = Carriage Return (CR) - ASCII 13 decimal  
                                    ;       Moves cursor to BEGINNING of line (horizontal movement)
                                    ; Together 0Ah, 0Dh create a newline (like pressing Enter)
                                    ; Note: Can also write as 10,13 in decimal
                                    ; "You pressed: " = text to display after newline
                                    ; $ = terminator
                                    ; This string is 17 bytes: LF + CR + 13 characters + terminator

.code                               ; Start of code segment (where program instructions are stored)
                                    ; CS register points to this segment
                                    ; IP register contains offset within this segment
                                    ; Execution begins at first instruction after . code
    
    ;---------------------------------------------------------------------------
    ; INITIALIZE DATA SEGMENT
    ;---------------------------------------------------------------------------
    ; Before accessing variables, we must set DS register to point to data segment
    ; DS cannot be loaded directly with immediate value (CPU limitation)
    ; Must use AX as intermediate register
    ;---------------------------------------------------------------------------
    
    mov ax, @data                   ; Load address of data segment into AX register
                                    ; @data is a special assembler symbol
                                    ; It represents the segment address where . data is located
                                    ; For example, if data segment is at 1000h, AX = 1000h
                                    ; AX is 16-bit register, can hold segment addresses
    
    mov ds, ax                      ; Move AX value into DS (Data Segment register)
                                    ; DS now points to our data segment
                                    ; Now we can access msg1, inp, msg2 using DS:  prefix
                                    ; This step is REQUIRED before accessing any variables
                                    ; Without this, accessing variables would read wrong memory! 
    
    ;---------------------------------------------------------------------------
    ; STEP 1: DISPLAY PROMPT MESSAGE "Press any key: "
    ;---------------------------------------------------------------------------
    ; Use DOS INT 21h, AH=09h to display a string
    ; This service displays characters from DS:DX until it finds '$'
    ;---------------------------------------------------------------------------
    
    mov ah, 09h                     ; AH = 09h: DOS function number for "Display String"
                                    ; INT 21h uses AH to determine which service to call
                                    ; 09h = Display string terminated by '$'
                                    ; This is one of the most commonly used DOS functions
    
    mov dx, offset msg1             ; DX = offset address of msg1 within data segment
                                    ; offset gets the memory address (offset from DS) of msg1
                                    ; For example, if msg1 is at DS:0100h, DX = 0100h
                                    ; DOS will read string starting from DS:DX
                                    ; Continues reading until it encounters '$'
                                    ; This is the "display msg1" annotation in your notes
    
    int 21h                         ; Call DOS interrupt 21h (DOS system services)
                                    ; int = interrupt instruction
                                    ; 21h = interrupt number for DOS services
                                    ; When this executes: 
                                    ;   1. CPU saves current state
                                    ;   2. Jumps to DOS interrupt handler
                                    ;   3. DOS looks at AH (09h) to know what to do
                                    ;   4. DOS reads string from DS:DX and displays it
                                    ;   5. DOS returns control back to our program
                                    ; Screen now shows: "Press any key: " (cursor after space)
    
    ;---------------------------------------------------------------------------
    ; STEP 2: WAIT FOR USER TO PRESS A KEY (ACCEPT INPUT)
    ;---------------------------------------------------------------------------
    ; Use DOS INT 21h, AH=01h to read one character from keyboard
    ; This service waits until user presses a key
    ; The character is echoed (displayed) on screen
    ; ASCII code of key is returned in AL register
    ;---------------------------------------------------------------------------
    
    mov ah, 01h                     ; AH = 01h: DOS function for "Input Character with Echo"
                                    ; Service 01h = Read one character from keyboard
                                    ; "with Echo" means character is automatically displayed
                                    ; This is the "accept any ASCII code" annotation
                                    ; Program will PAUSE here until user presses a key
    
    int 21h                         ; Call DOS interrupt 21h
                                    ; When this executes:
                                    ;   1. Program PAUSES and waits for keyboard input
                                    ;   2. User presses a key (e.g., 'A')
                                    ;   3. Character is displayed on screen (echoed)
                                    ;   4. ASCII code is placed in AL register
                                    ;   5. Control returns to our program
                                    ; Example: if user presses 'A', AL = 41h (65 decimal)
                                    ; Note: AH is destroyed by INT 21h (changed to 41h)
                                    ; This is why the note says "A=41h, AL gets the code"
    
    ;---------------------------------------------------------------------------
    ; STEP 3: STORE THE CHARACTER THAT WAS PRESSED
    ;---------------------------------------------------------------------------
    ; AL now contains the ASCII code of the key pressed
    ; We save it to variable 'inp' for later use
    ;---------------------------------------------------------------------------
    
    mov inp, al                     ; Store AL (the input character) into variable 'inp'
                                    ; AL contains ASCII code from INT 21h, AH=01h
                                    ; inp is our 1-byte variable in data segment
                                    ; This saves the character so we can use it later
                                    ; Example: if user pressed 'A', inp now equals 41h (65)
                                    ; The variable 'inp' in memory now holds this value
    
    ;---------------------------------------------------------------------------
    ; STEP 4: DISPLAY NEWLINE AND "You pressed: " MESSAGE
    ;---------------------------------------------------------------------------
    ; Display msg2 which contains:   LF, CR, "You pressed: $"
    ; LF (Line Feed) moves cursor down
    ; CR (Carriage Return) moves cursor to start of line
    ; Together they create a newline effect
    ;---------------------------------------------------------------------------
    
    mov ah, 09h                     ; AH = 09h: DOS function to display string
                                    ; We're reusing the same service as before
                                    ; AH must be set to 09h again because INT 21h may change it
    
    mov dx, offset msg2             ; DX = offset address of msg2
                                    ; msg2 contains:  0Ah, 0Dh, "You pressed: $"
                                    ; offset gets the memory location of msg2
                                    ; This is the "display LF & CR and msg2" annotation
    
    int 21h                         ; Call DOS interrupt 21h to display msg2
                                    ; When this executes:
                                    ;   1. DOS reads 0Ah (Line Feed) - cursor moves down
                                    ;   2. DOS reads 0Dh (Carriage Return) - cursor moves to column 0
                                    ;   3. DOS displays "You pressed: "
                                    ;   4. DOS stops at '$' terminator
                                    ; Screen now shows:
                                    ;   "Press any key: A" (on first line, if user pressed A)
                                    ;   "You pressed: " (on second line, cursor after space)
    
    ;---------------------------------------------------------------------------
    ; STEP 5: DISPLAY THE CHARACTER THAT USER PRESSED
    ;---------------------------------------------------------------------------
    ; Use DOS INT 21h, AH=02h to display a single character
    ; The character to display must be in DL register
    ; We load DL with the value we saved in 'inp' variable
    ;---------------------------------------------------------------------------
    
    mov ah, 02h                     ; AH = 02h: DOS function for "Display Character"
                                    ; Service 02h displays ONE character from DL register
                                    ; This is the "display the input character" annotation
    
    mov dl, inp                     ; DL = value stored in 'inp' variable
                                    ; Loads the character user pressed (saved earlier)
                                    ; Example: if inp contains 41h ('A'), DL = 41h
                                    ; DL is 8-bit register used for character output with service 02h
    
    int 21h                         ; Call DOS interrupt 21h to display character
                                    ; When this executes:
                                    ;   1. DOS reads DL register
                                    ;   2. DOS displays the character (e.g., 'A')
                                    ; Screen now shows:
                                    ;   "Press any key: A"
                                    ;   "You pressed: A"
                                    ; Program has successfully echoed user's input! 
    
    ;---------------------------------------------------------------------------
    ; STEP 6: TERMINATE PROGRAM (EXIT TO DOS)
    ;---------------------------------------------------------------------------
    ; Use DOS INT 21h, AH=4Ch to properly exit program
    ; AL register can contain return code (0 = success)
    ; This is the PROPER way to end a DOS program
    ;---------------------------------------------------------------------------
    
    mov ah, 4ch                     ; AH = 4Ch: DOS function to terminate program
                                    ; Service 4Ch exits program and returns control to DOS
                                    ; This is the proper way to exit (not just stopping)
                                    ; Cleans up resources and returns to command prompt
    
    int 21h                         ; Call DOS interrupt 21h to exit
                                    ; When this executes:
                                    ;   1. Program terminates immediately
                                    ;   2. All resources are cleaned up
                                    ;   3. Control returns to DOS command prompt
                                    ;   4. Nothing after this line will execute
                                    ; User is back at DOS prompt (e.g., C:\>)

end                                 ; End of program (marks end of source code)
                                    ; This tells assembler where program ends
                                    ; No code after 'end' will be assembled
                                    ; Assembler uses this to know compilation is complete

;===============================================================================
; PROGRAM FLOW SUMMARY
;===============================================================================
; 
; 1. Initialize Data Segment (mov ax, @data / mov ds, ax)
;    - Sets up DS register to access variables
;
; 2. Display Prompt (INT 21h, AH=09h with msg1)
;    - Shows "Press any key: " on screen
;
; 3. Wait for Input (INT 21h, AH=01h)
;    - Program pauses until user presses a key
;    - Character is echoed to screen
;    - ASCII code returned in AL
;
; 4. Store Input (mov inp, al)
;    - Saves the character for later use
;
; 5. Display "You pressed:" (INT 21h, AH=09h with msg2)
;    - Shows newline and message
;
; 6. Display Pressed Key (INT 21h, AH=02h with inp)
;    - Shows the character user pressed
;
; 7. Exit Program (INT 21h, AH=4Ch)
;    - Returns to DOS properly
;
;===============================================================================
; SAMPLE OUTPUT
;===============================================================================
; 
; If user presses 'A': 
; 
; Press any key: A
; You pressed: A
; 
; Explanation:
; - "Press any key: " is displayed by step 2
; - "A" after the prompt is displayed by step 3 (echo from AH=01h)
; - Newline moves to next line
; - "You pressed: " is displayed by step 5
; - "A" after the message is displayed by step 6
;
;===============================================================================
; DOS SERVICES USED
;===============================================================================
;
; INT 21h, AH=09h - Display String
;   Input:   DX = offset of string (terminated by '$')
;   Output: String displayed on screen
;   Notes:  Control characters (CR, LF) are interpreted
;
; INT 21h, AH=01h - Input Character with Echo
;   Input:   None
;   Output: AL = ASCII code of key pressed
;   Notes:  Waits for keypress, character is echoed
;
; INT 21h, AH=02h - Display Character
;   Input:   DL = ASCII character to display
;   Output: Character displayed on screen
;   Notes:   Displays single character from DL
;
; INT 21h, AH=4Ch - Terminate Program
;   Input:  AL = return code (usually 0)
;   Output: Program exits to DOS
;   Notes:  Proper way to end program
;
;===============================================================================
; REGISTER USAGE IN THIS PROGRAM
;===============================================================================
;
; AX:  Used for loading data segment address (@data)
;     AH used for DOS function numbers (09h, 01h, 02h, 4Ch)
;     AL receives ASCII code from keyboard input (service 01h)
;
; DX: Used for string addresses (offset msg1, offset msg2)
;     DL used for character output (service 02h)
;
; DS: Data Segment register, points to . data segment
;     Must be initialized before accessing variables
;
;===============================================================================
; CONTROL CHARACTERS USED
;===============================================================================
;
; 0Ah (10 decimal) = Line Feed (LF)
;   - Moves cursor down one line (vertical)
;   - Like the down arrow key
;
; 0Dh (13 decimal) = Carriage Return (CR)
;   - Moves cursor to beginning of current line (horizontal)
;   - Like the Home key
;
; Together 0Ah + 0Dh = Newline
;   - Equivalent to pressing Enter key
;   - Moves to beginning of next line
;
; Note: Order can be either way (LF+CR or CR+LF)
;       Common convention is CR+LF (0Dh, 0Ah) but both work
;
;===============================================================================