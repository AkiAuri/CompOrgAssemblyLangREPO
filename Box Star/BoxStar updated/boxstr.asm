;===============================================================================
; PROGRAM:  Box Star Pattern Generator
; PURPOSE: Demonstrates string input, CMP statement, JMP statement
; DESCRIPTION: Accepts number of rows and columns, then displays a box
;              pattern made of asterisks (*)
; SAMPLE OUTPUT:
;   Enter number of rows: 3
;   Enter number of columns:  4
;   * * * *
;   * * * *
;   * * * *
;===============================================================================

.model small                        ; Define memory model as 'small' (code and data each fit in 64KB)
                                    ; Small model:  one code segment, one data segment
                                    ; Suitable for simple programs

.stack 100h                         ; Allocate 256 bytes (100h) for the stack
                                    ; Stack used for:  PUSH/POP, procedure calls, return addresses
                                    ; 256 bytes sufficient for this program

.data                               ; Start of data segment (variables and strings stored here)
                                    ; DS register will point to this segment
    
    ;---------------------------------------------------------------------------
    ; MESSAGE STRINGS FOR USER PROMPTS
    ;---------------------------------------------------------------------------
    ; All strings terminated with '$' for DOS INT 21h, AH=09h display function
    ;---------------------------------------------------------------------------
    
    msg_rows db "Enter number of rows: $"     ; Prompt for row count
                                    ; db = Define Byte (1 byte per character)
                                    ; $ = terminator (tells DOS where string ends)
    
    msg_cols db 10,13,"Enter number of columns: $"  ; Prompt for column count
                                    ; 10 (0Ah) = Line Feed (LF) - move cursor down
                                    ; 13 (0Dh) = Carriage Return (CR) - move to line start
                                    ; Together they create a newline
    
    ;---------------------------------------------------------------------------
    ; STRING VARIABLE DECLARATION
    ;---------------------------------------------------------------------------
    ; SERVICE 0Ah (INT 21h) - Accept String Input
    ; Format for string buffer: 
    ;   Byte 1: Maximum length (how many chars buffer can hold)
    ;   Byte 2: Actual length (filled by DOS with number of chars entered)
    ;   Byte 3+: The actual characters entered by user
    ;   Last:  '$' terminator for display
    ;---------------------------------------------------------------------------
    ; Your notes: "To declare a string variable:"
    ;             str db maxlength, init_value, actuallength, DUP('$')
    ;             Example: str db 30, 0, 28, DUP('$')
    ;---------------------------------------------------------------------------
    
    str_input db 30, 0, 28 DUP('$')  ; String buffer for user input
                                    ; Byte [0] = 30: Maximum length (can accept up to 30 chars)
                                    ;              This is "maxlength" in your notes
                                    ;              Tells DOS:  "don't accept more than 30 chars"
                                    ; Byte [1] = 0: Initial value for actual length
                                    ;             This is "init_value" in your notes
                                    ;             DOS will fill this with actual char count
                                    ; Byte [2-29] = 28 DUP('$'): Reserve 28 bytes, fill with '$'
                                    ;                This is "actuallength, DUP('$')" part
                                    ;                DUP means "duplicate"
                                    ;                Creates 28 bytes all containing '$'
                                    ;                Total buffer: 30 bytes (2 header + 28 data)
                                    ; Your notes: "-2 to the max length" (30-2=28)
                                    ; Format: [maxlen][actlen][char1][char2].. .[char28]
    
    ; Alternative declaration shown in notes:
    ; ex: str db 30, 0, 28, DUP('$')
    ;     ML IV AL Depth
    ;     ^  ^  ^  ^
    ;     |  |  |  +-- Depth:  how many bytes to fill with '$'
    ;     |  |  +-- Actual Length: filled by DOS after input
    ;     |  +-- Initial Value: starting value for actual length
    ;     +-- Max Length: maximum characters allowed
    
    ; SI (Source Index) is used as pointer to access string
    ; Your notes: "SI (Source Index), Pointer = str Name[0] = 30"
    ; SI points to start of string, SI+0 = max length byte
    
    ;---------------------------------------------------------------------------
    ; VARIABLES FOR STORING ROW AND COLUMN COUNTS
    ;---------------------------------------------------------------------------
    
    num_rows db 0                   ; Variable to store number of rows
                                    ; Will be filled from user input
                                    ; Single byte can hold 0-255
    
    num_cols db 0                   ; Variable to store number of columns
                                    ; Will be filled from user input
    
    newline db 10,13,'$'            ; Newline string (LF + CR + terminator)
                                    ; Used to move to next line after each row

.code                               ; Start of code segment (program instructions)
                                    ; CS register points to this segment
    
    ;---------------------------------------------------------------------------
    ; INITIALIZE DATA SEGMENT
    ;---------------------------------------------------------------------------
    ; Must set DS to point to data segment before accessing variables
    ; DS cannot be loaded directly (CPU limitation), must use AX as intermediate
    ;---------------------------------------------------------------------------
    
    mov ax, @data                   ; Load address of data segment into AX
                                    ; @data = assembler symbol for data segment address
    
    mov ds, ax                      ; Move AX into DS (Data Segment register)
                                    ; DS now points to our . data segment
                                    ; Required before accessing any variables

    ;---------------------------------------------------------------------------
    ; STEP 1: DISPLAY "Enter number of rows:" PROMPT
    ;---------------------------------------------------------------------------
    
    mov ah, 09h                     ; AH = 09h:  DOS function "Display String"
                                    ; Service to display string terminated by '$'
    
    mov dx, offset msg_rows         ; DX = offset address of msg_rows
                                    ; offset gets memory address of variable
                                    ; DOS will display string starting from DS:DX
    
    int 21h                         ; Call DOS interrupt 21h
                                    ; Displays "Enter number of rows: "
                                    ; Cursor positioned after prompt

    ;---------------------------------------------------------------------------
    ; STEP 2: ACCEPT STRING INPUT FOR ROWS (Using SERVICE 0Ah)
    ;---------------------------------------------------------------------------
    ; SERVICE 0Ah - Accept String Input
    ; This is the buffered keyboard input function
    ; User types a string, presses Enter
    ; DOS stores the characters in our buffer
    ;---------------------------------------------------------------------------
    ; Your notes: "Accept String Input"
    ;             "Service 0Ah, INT 21h - accept a string input"
    ;             "Inputs:  AH = 0Ah, DX = offset <var>, INT 21h"
    ;---------------------------------------------------------------------------
    
    mov ah, 0Ah                     ; AH = 0Ah:  DOS function "Buffered Keyboard Input"
                                    ; Service 0Ah reads a line of text from keyboard
                                    ; Allows backspace editing before Enter is pressed
                                    ; Stops reading when user presses Enter (CR)
                                    ; Your notes show: "AH = 0Ah"
    
    mov dx, offset str_input        ; DX = offset address of str_input buffer
                                    ; Points to our 30-byte string buffer
                                    ; DOS will store input here
                                    ; Format: [maxlen][actlen][chars...]
                                    ; Your notes: "DX = offset <var>"
    
    int 21h                         ; Call DOS interrupt 21h
                                    ; Your notes: "INT 21h"
                                    ; Program PAUSES here waiting for user input
                                    ; User types (e.g., "3"), presses Enter
                                    ; After Enter: 
                                    ;   str_input[0] = 30 (max length, unchanged)
                                    ;   str_input[1] = 1 (actual chars entered, set by DOS)
                                    ;   str_input[2] = '3' (first character typed)
                                    ;   str_input[3] = 13 (CR - Enter key code)
                                    ; DOS fills byte [1] with actual character count
                                    ; Does NOT include the CR in the count

    ;---------------------------------------------------------------------------
    ; STEP 3: EXTRACT THE NUMERIC VALUE FROM STRING
    ;---------------------------------------------------------------------------
    ; User entered a digit character (e.g., '3')
    ; str_input[2] contains the first character (ASCII)
    ; Need to convert from ASCII to numeric value
    ; ASCII '0'='30h, '1'=31h, .. ., '9'=39h
    ; To convert: subtract 30h
    ;---------------------------------------------------------------------------
    
    mov al, str_input[2]            ; AL = first character from input buffer
                                    ; str_input[2] is the first actual character typed
                                    ; [0]=maxlen, [1]=actlen, [2]=first char
                                    ; Example: if user typed '3', AL = 33h (ASCII '3')
    
    sub al, 30h                     ; Convert ASCII digit to numeric value
                                    ; Subtract 30h to get actual number
                                    ; Example: '3' (33h) - 30h = 3 (numeric)
                                    ; '5' (35h) - 30h = 5 (numeric)
    
    mov num_rows, al                ; Store numeric value in num_rows variable
                                    ; num_rows now contains actual number (e.g., 3)
                                    ; This is how many rows of stars to print

    ;---------------------------------------------------------------------------
    ; STEP 4: DISPLAY "Enter number of columns:" PROMPT
    ;---------------------------------------------------------------------------
    
    mov ah, 09h                     ; AH = 09h: Display string
    mov dx, offset msg_cols         ; DX = address of column prompt
                                    ; msg_cols includes newline (LF, CR) at start
    int 21h                         ; Display "Enter number of columns: "

    ;---------------------------------------------------------------------------
    ; STEP 5: ACCEPT STRING INPUT FOR COLUMNS
    ;---------------------------------------------------------------------------
    ; Same process as rows - reuse the same buffer
    ;---------------------------------------------------------------------------
    
    mov ah, 0Ah                     ; AH = 0Ah:  Buffered keyboard input
    mov dx, offset str_input        ; DX = address of string buffer (reusing same buffer)
    int 21h                         ; Accept input (e.g., user types "4")
                                    ; After input:
                                    ;   str_input[1] = number of chars entered
                                    ;   str_input[2] = first character typed

    ;---------------------------------------------------------------------------
    ; STEP 6: EXTRACT NUMERIC VALUE FOR COLUMNS
    ;---------------------------------------------------------------------------
    
    mov al, str_input[2]            ; AL = first character from input
                                    ; Example: if user typed '4', AL = 34h
    
    sub al, 30h                     ; Convert ASCII to numeric
                                    ; '4' (34h) - 30h = 4 (numeric)
    
    mov num_cols, al                ; Store in num_cols variable
                                    ; num_cols now contains column count (e.g., 4)

    ;---------------------------------------------------------------------------
    ; STEP 7: PRINT NEWLINE BEFORE STARTING PATTERN
    ;---------------------------------------------------------------------------
    
    mov ah, 09h                     ; AH = 09h: Display string
    mov dx, offset newline          ; DX = address of newline string
    int 21h                         ; Print newline to start on fresh line

    ;---------------------------------------------------------------------------
    ; STEP 8: OUTER LOOP - PROCESS EACH ROW
    ;---------------------------------------------------------------------------
    ; Use CH register as row counter
    ; Loop through each row (num_rows times)
    ;---------------------------------------------------------------------------
    ; CMP STATEMENT EXPLANATION:
    ; CMP (Compare) compares two operands and sets flag registers
    ; Your notes: "CMP Statement - used to compare 2 operands and set the
    ;              flag register based on the result of the comparison"
    ; Syntax: CMP <reg>, <reg> or CMP <reg>, <const>
    ; Sets flags: ZF (Zero Flag), SF (Sign Flag), CF (Carry Flag), etc.
    ; Does NOT change operands, only sets flags
    ;---------------------------------------------------------------------------
    ; JMP STATEMENT EXPLANATION:
    ; JMP (Jump) loads a new address to IP (Instruction Pointer)
    ; Your notes: "JMP Statement - load a new address to the Instruction
    ;              Pointer (IP) causing the CPU to execute a new line of code"
    ; Types:  Unconditional (JMP) and Conditional (JE, JNE, JL, JG, etc.)
    ; Syntax: JMP <label> (unconditional)
    ;---------------------------------------------------------------------------
    
    mov ch, 0                       ; CH = 0: Initialize row counter to 0
                                    ; CH will count from 0 to (num_rows - 1)
                                    ; We use CH to track current row number

row_loop:                           ; LABEL: Start of row loop
                                    ; This is where outer loop begins
                                    ; Label is a marker that JMP can jump to
    
    ;---------------------------------------------------------------------------
    ; CMP STATEMENT USAGE
    ;---------------------------------------------------------------------------
    ; Compare current row counter with total rows needed
    ;---------------------------------------------------------------------------
    
    cmp ch, num_rows                ; CMP statement:  Compare CH with num_rows
                                    ; Your notes: "cmp <reg>, <reg>"
                                    ; Example: if CH=3, num_rows=3, then CH == num_rows
                                    ; Sets Zero Flag (ZF) = 1 if they're equal
                                    ; Sets ZF = 0 if they're different
                                    ; This is the "compare 2 operands" from your notes
                                    ; Result of comparison stored in flag registers
    
    ;---------------------------------------------------------------------------
    ; JMP STATEMENT USAGE - Conditional Jump
    ;---------------------------------------------------------------------------
    ; JE = "Jump if Equal" (conditional jump)
    ; Checks if ZF (Zero Flag) is set by previous CMP
    ; If ZF=1 (operands were equal), jump is taken
    ;---------------------------------------------------------------------------
    
    je done_rows                    ; JE: Jump if Equal (conditional jump)
                                    ; Your notes: "JMP statement - load a new address to IP"
                                    ; If CH == num_rows (we've printed all rows):
                                    ;   - Jump to 'done_rows' label
                                    ;   - IP (Instruction Pointer) is changed
                                    ;   - CPU starts executing at 'done_rows'
                                    ; If CH < num_rows (more rows to print):
                                    ;   - Don't jump, continue to next instruction
                                    ;   - Fall through to column loop
                                    ; This is the "execute a new line of code" from notes

    ;---------------------------------------------------------------------------
    ; STEP 9: INNER LOOP - PRINT STARS IN CURRENT ROW
    ;---------------------------------------------------------------------------
    ; Use CL register as column counter
    ; Loop through each column (num_cols times)
    ;---------------------------------------------------------------------------
    
    mov cl, 0                       ; CL = 0: Initialize column counter
                                    ; CL counts columns in current row

col_loop:                           ; LABEL: Start of column loop
                                    ; Inner loop for printing stars in one row
    
    cmp cl, num_cols                ; CMP:  Compare CL with num_cols
                                    ; Check if we've printed all columns in this row
                                    ; Sets flags based on comparison
    
    je done_cols                    ; JE: Jump if Equal (CL == num_cols)
                                    ; If we've printed all columns:
                                    ;   - Jump to 'done_cols'
                                    ;   - Move to next row
                                    ; If more columns to print:
                                    ;   - Continue to print next star

    ;---------------------------------------------------------------------------
    ; PRINT ONE STAR
    ;---------------------------------------------------------------------------
    
    mov ah, 02h                     ; AH = 02h: DOS function "Display Character"
                                    ; Display single character from DL
    
    mov dl, '*'                     ; DL = '*':  Asterisk character
                                    ; Character to display
    
    int 21h                         ; Call DOS to display '*'
                                    ; One star printed

    ;---------------------------------------------------------------------------
    ; PRINT SPACE AFTER STAR (for readability)
    ;---------------------------------------------------------------------------
    
    mov ah, 02h                     ; AH = 02h: Display character
    mov dl, ' '                     ; DL = space character
    int 21h                         ; Print space after star
                                    ; Makes pattern look like: * * * *

    ;---------------------------------------------------------------------------
    ; INCREMENT COLUMN COUNTER AND LOOP BACK
    ;---------------------------------------------------------------------------
    
    inc cl                          ; Increment CL (column counter)
                                    ; CL = CL + 1
                                    ; Move to next column position
    
    ;---------------------------------------------------------------------------
    ; JMP STATEMENT - Unconditional Jump
    ;---------------------------------------------------------------------------
    
    jmp col_loop                    ; JMP:  Unconditional jump back to col_loop
                                    ; Your notes: "Syntax: jmp <label>"
                                    ; Always jumps (no condition checked)
                                    ; IP is loaded with address of 'col_loop'
                                    ; CPU starts executing from 'col_loop' again
                                    ; This creates the inner loop
                                    ; Continues until CL == num_cols

done_cols:                          ; LABEL:  Reached when row is complete
                                    ; All columns in current row have been printed
    
    ;---------------------------------------------------------------------------
    ; PRINT NEWLINE AFTER COMPLETING ONE ROW
    ;---------------------------------------------------------------------------
    
    mov ah, 09h                     ; AH = 09h: Display string
    mov dx, offset newline          ; DX = address of newline (LF + CR)
    int 21h                         ; Print newline
                                    ; Cursor moves to start of next line
                                    ; Ready to print next row

    ;---------------------------------------------------------------------------
    ; INCREMENT ROW COUNTER AND LOOP BACK
    ;---------------------------------------------------------------------------
    
    inc ch                          ; Increment CH (row counter)
                                    ; CH = CH + 1
                                    ; Move to next row
    
    jmp row_loop                    ; JMP: Jump back to row_loop (unconditional)
                                    ; Start processing next row
                                    ; Continues until CH == num_rows

done_rows:                          ; LABEL:  Reached when all rows complete
                                    ; Pattern printing is finished
    
    ;---------------------------------------------------------------------------
    ; STEP 10: TERMINATE PROGRAM
    ;---------------------------------------------------------------------------
    
    mov ah, 4ch                     ; AH = 4Ch: Terminate program
                                    ; DOS function to exit program
    
    int 21h                         ; Call DOS to exit
                                    ; Program ends, return to DOS prompt

end                                 ; End of program
                                    ; Marks end of source code for assembler

;===============================================================================
; PROGRAM FLOW SUMMARY
;===============================================================================
;
; 1. Display "Enter number of rows: "
; 2. Accept string input (Service 0Ah) → str_input
; 3. Extract digit from str_input[2], convert to number → num_rows
; 4. Display "Enter number of columns: "
; 5. Accept string input (Service 0Ah) → str_input
; 6. Extract digit, convert to number → num_cols
; 7. Print newline
; 8. OUTER LOOP (rows):
;    - CMP CH with num_rows
;    - JE done_rows (if equal, exit outer loop)
;    - INNER LOOP (columns):
;      * CMP CL with num_cols
;      * JE done_cols (if equal, exit inner loop)
;      * Print '*' and space
;      * INC CL
;      * JMP col_loop (repeat inner loop)
;    - Print newline
;    - INC CH
;    - JMP row_loop (repeat outer loop)
; 9. Exit program
;
;===============================================================================
; SAMPLE EXECUTION
;===============================================================================
;
; Input:
;   Enter number of rows: 3
;   Enter number of columns: 4
;
; Output:
;   * * * *
;   * * * *
;   * * * *
;
; Explanation:
; - Outer loop runs 3 times (rows: 0, 1, 2)
; - Inner loop runs 4 times per row (columns: 0, 1, 2, 3)
; - Each iteration prints one '*' and one space
; - After each row, newline is printed
; - Total:  3 rows × 4 columns = 12 stars
;
;===============================================================================
; STRING INPUT BUFFER STRUCTURE (SERVICE 0Ah)
;===============================================================================
;
; Declaration:  str_input db 30, 0, 28 DUP('$')
;
; Memory Layout:
; Offset | Description          | Initial | After Input "3"
; -------|---------------------|---------|----------------
;   [0]  | Max length          | 30      | 30 (unchanged)
;   [1]  | Actual length       | 0       | 1 (set by DOS)
;   [2]  | First character     | '$'     | '3' (33h)
;   [3]  | Second character    | '$'     | 13 (CR)
;   [4]  | Third character     | '$'     | '$'
;   ...   | ...                 | '$'     | '$'
;  [29]  | Last character      | '$'     | '$'
;
; Key Points:
; - Byte [0]:  Maximum characters DOS will accept (not including CR)
; - Byte [1]: Filled by DOS with actual number of characters entered
; - Byte [2] onwards: The actual characters typed by user
; - CR (13) is stored but not counted in actual length
; - Buffer size = max_length + 2 (for length bytes)
; - Your notes: "-2 to the max length" means 30-2=28 for DUP
;
;===============================================================================
; CMP STATEMENT (Compare)
;===============================================================================
;
; Purpose: Compare two operands and set flag registers
; Your notes: "Used to compare 2 operands and set the flag register
;              based on the result of the comparison"
;
; Syntax: 
;   CMP <reg>, <reg>     ; Compare two registers
;   CMP <reg>, <const>   ; Compare register with constant
;
; Examples:
;   CMP CH, num_rows     ; Compare CH register with num_rows variable
;   CMP AL, 5            ; Compare AL with constant 5
;
; Flags Set:
;   ZF (Zero Flag): Set to 1 if operands are equal, 0 otherwise
;   SF (Sign Flag): Set based on sign of result
;   CF (Carry Flag): Set if unsigned underflow
;   OF (Overflow Flag): Set if signed overflow
;
; Important:  CMP does NOT change operands, only sets flags
;            It performs subtraction (operand1 - operand2) but discards result
;
;===============================================================================
; JMP STATEMENT (Jump)
;===============================================================================
;
; Purpose: Load new address to IP (Instruction Pointer)
; Your notes: "Load a new address to the Instruction Pointer (IP)
;              causing the CPU to execute a new line of code"
;
; Types:
;   1. Unconditional Jump: 
;      JMP <label>              ; Always jumps
;      Example: JMP row_loop
;
;   2. Conditional Jumps (check flags from previous CMP):
;      JE  <label>  ; Jump if Equal (ZF=1)
;      JNE <label>  ; Jump if Not Equal (ZF=0)
;      JL  <label>  ; Jump if Less (SF≠OF)
;      JG  <label>  ; Jump if Greater (ZF=0 and SF=OF)
;      JLE <label>  ; Jump if Less or Equal
;      JGE <label>  ; Jump if Greater or Equal
;
; Your notes show: "Syntax: jmp <label>"
;
; How it works:
;   1. CPU has IP (Instruction Pointer) register
;   2. IP contains address of next instruction to execute
;   3. JMP changes IP to point to a different address (label)
;   4. CPU starts executing from new address
;   5. This "causes CPU to execute a new line of code" (your notes)
;
; Example Flow:
;   row_loop:           ; IP points here
;       cmp ch, 3       ; Compare, set flags
;       je done_rows    ; If CH==3, change IP to 'done_rows'
;       inc ch          ; If not equal, IP moves here
;       jmp row_loop    ; Change IP back to 'row_loop'
;   done_rows:          ; IP comes here if jump taken
;
;===============================================================================
; DOS SERVICES USED
;===============================================================================
;
; INT 21h, AH=09h - Display String
;   Input: DX = offset of string (terminated by '$')
;   Output: String displayed on screen
;
; INT 21h, AH=0Ah - Buffered Keyboard Input (Accept String)
;   Input: DX = offset of buffer (first byte = max length)
;   Output: Buffer filled with characters entered
;           Buffer[1] = actual length entered
;           Buffer[2+] = characters typed
;
; INT 21h, AH=02h - Display Character
;   Input: DL = ASCII character to display
;   Output:  Character displayed on screen
;
; INT 21h, AH=4Ch - Terminate Program
;   Input: AL = return code (usually 0)
;   Output: Program exits to DOS
;
;===============================================================================
; REGISTER USAGE
;===============================================================================
;
; AX: Used for DOS function calls (AH = function number)
; DX: Used for addresses (offset of strings/buffers) and character output (DL)
; CH: Row counter for outer loop
; CL: Column counter for inner loop
; AL:  Temporary storage for character conversion
;
;===============================================================================