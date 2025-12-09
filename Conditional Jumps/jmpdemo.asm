;===============================================================================
; PROGRAM:  Conditional Jump Instructions Demonstration
; PURPOSE: Demonstrates all conditional JMP instructions (JZ, JNZ, JC, JNC,
;          JE, JNE, JG, JGE, JL, JLE) with practical Y/N input validation
; DESCRIPTION: Shows how each conditional jump works based on flag registers
;              Includes Y/N validation loop as practical example
;===============================================================================

.model small                        ; Define memory model as 'small' (code and data each fit in 64KB)
.stack 100h                         ; Allocate 256 bytes (100h) for the stack

.data                               ; Start of data segment (variables and strings)
    
    ;---------------------------------------------------------------------------
    ; CONDITIONAL JUMP INSTRUCTION REFERENCE
    ;---------------------------------------------------------------------------
    ; All conditional jumps check the FLAG REGISTER set by previous operations
    ; Flags are set by instructions like CMP, TEST, ADD, SUB, etc.
    ;
    ; Flag Register Bits:
    ;   ZF (Zero Flag):      Set to 1 if result is zero, 0 otherwise
    ;   CF (Carry Flag):     Set to 1 if carry/borrow occurred
    ;   SF (Sign Flag):      Set to 1 if result is negative
    ;   OF (Overflow Flag):  Set to 1 if signed overflow occurred
    ;   PF (Parity Flag):    Set to 1 if even number of 1 bits
    ;---------------------------------------------------------------------------
    ; YOUR NOTES - CONDITIONAL JUMP INSTRUCTIONS: 
    ; ① JZ  - if comparison equal to zero
    ; ② JNZ - if comparison not equal to 0
    ; ③ JC  - jump if carry
    ; ④ JNC - jump if no carry
    ; ⑤ JE  - jump if equal
    ; ⑥ JNE - jump if not equal
    ; ⑦ JG  - jump if >
    ; ⑧ JGE - jump if >=
    ; ⑨ JL  - jump if <
    ; ⑩ JLE - jump if <=
    ;---------------------------------------------------------------------------
    
    title_msg db "=== Conditional Jump Instructions Demo ===",10,13,10,13,"$"
    
    ; Messages for demonstrating each jump type
    msg_jz  db "Testing JZ  (Jump if Zero).. .$"
    msg_jnz db "Testing JNZ (Jump if Not Zero)...$"
    msg_jc  db "Testing JC  (Jump if Carry)...$"
    msg_jnc db "Testing JNC (Jump if No Carry)...$"
    msg_je  db "Testing JE  (Jump if Equal)...$"
    msg_jne db "Testing JNE (Jump if Not Equal)...$"
    msg_jg  db "Testing JG  (Jump if Greater)...$"
    msg_jge db "Testing JGE (Jump if Greater or Equal)...$"
    msg_jl  db "Testing JL  (Jump if Less)...$"
    msg_jle db "Testing JLE (Jump if Less or Equal)...$"
    
    msg_jump_taken db " -> Jump TAKEN! ",10,13,"$"
    msg_jump_not_taken db " -> Jump NOT taken",10,13,"$"
    
    ; Y/N validation messages
    msg_question db 10,13,10,13,"Do you want another (Y/N)? $"
    msg_repeat db 10,13,"You chose Y - Repeating the question...",10,13,"$"
    msg_terminate db 10,13,"You chose N - Terminating the code...",10,13,"$"
    msg_invalid db 10,13,"Invalid input!  Please enter Y or N.",10,13,"$"
    
    newline db 10,13,"$"
    press_key db "Press any key to continue...$"
    
    user_choice db 0                ; Variable to store user's Y/N input

.code                               ; Start of code segment
    mov ax, @data                   ; Load data segment address
    mov ds, ax                      ; Initialize DS register

    ;---------------------------------------------------------------------------
    ; Display Title
    ;---------------------------------------------------------------------------
    mov ah, 09h
    mov dx, offset title_msg
    int 21h

    ;===========================================================================
    ; DEMONSTRATION 1: JZ - Jump if Zero
    ;===========================================================================
    ; JZ checks the Zero Flag (ZF)
    ; Jumps if ZF = 1 (result of previous operation was zero)
    ; Typically used after CMP or SUB instructions
    ;---------------------------------------------------------------------------
    ; Your notes: "① JZ - if comparison equal to zero"
    ;---------------------------------------------------------------------------
    
    mov ah, 09h
    mov dx, offset msg_jz
    int 21h
    
    ; Test case 1: Result IS zero
    mov al, 5                       ; AL = 5
    sub al, 5                       ; AL = 5 - 5 = 0
                                    ; SUB sets ZF = 1 (result is zero)
                                    ; ZF (Zero Flag) is now SET (ZF = 1)
    
    jz jump_taken_1                 ; JZ:   Jump if Zero (checks ZF flag)
                                    ; Since ZF = 1 (result was zero), jump IS taken
                                    ; CPU jumps to 'jump_taken_1' label
                                    ; This demonstrates:  "if comparison equal to zero"
    
    ; This line won't execute because jump was taken
    mov ah, 09h
    mov dx, offset msg_jump_not_taken
    int 21h
    jmp continue_1
    
jump_taken_1:
    mov ah, 09h
    mov dx, offset msg_jump_taken   ; Display "Jump TAKEN!"
    int 21h                         ; This executes because ZF was 1
    
continue_1:
    mov ah, 09h
    mov dx, offset newline
    int 21h

    ;===========================================================================
    ; DEMONSTRATION 2: JNZ - Jump if Not Zero
    ;===========================================================================
    ; JNZ checks the Zero Flag (ZF)
    ; Jumps if ZF = 0 (result of previous operation was NOT zero)
    ; Opposite of JZ
    ;---------------------------------------------------------------------------
    ; Your notes: "② JNZ - if comparison not equal to 0"
    ;---------------------------------------------------------------------------
    
    mov ah, 09h
    mov dx, offset msg_jnz
    int 21h
    
    ; Test case 2: Result is NOT zero
    mov al, 5                       ; AL = 5
    sub al, 2                       ; AL = 5 - 2 = 3
                                    ; SUB sets ZF = 0 (result is NOT zero)
                                    ; ZF (Zero Flag) is CLEAR (ZF = 0)
    
    jnz jump_taken_2                ; JNZ:   Jump if Not Zero (checks ZF flag)
                                    ; Since ZF = 0 (result was NOT zero), jump IS taken
                                    ; CPU jumps to 'jump_taken_2' label
                                    ; This demonstrates: "if comparison not equal to 0"
    
    mov ah, 09h
    mov dx, offset msg_jump_not_taken
    int 21h
    jmp continue_2
    
jump_taken_2:
    mov ah, 09h
    mov dx, offset msg_jump_taken   ; Display "Jump TAKEN!"
    int 21h                         ; Executes because ZF was 0
    
continue_2:
    mov ah, 09h
    mov dx, offset newline
    int 21h

    ;===========================================================================
    ; DEMONSTRATION 3: JC - Jump if Carry
    ;===========================================================================
    ; JC checks the Carry Flag (CF)
    ; Jumps if CF = 1 (carry occurred in arithmetic operation)
    ; Used for unsigned arithmetic overflow detection
    ;---------------------------------------------------------------------------
    ; Your notes: "③ JC - jump if carry"
    ;---------------------------------------------------------------------------
    
    mov ah, 09h
    mov dx, offset msg_jc
    int 21h
    
    ; Test case 3: Create a carry
    mov al, 255                     ; AL = 255 (maximum unsigned 8-bit value)
                                    ; In binary: 11111111
    add al, 1                       ; AL = 255 + 1 = 256 (overflows 8-bit)
                                    ; Result:  AL = 0 (only 8 bits kept:  00000000)
                                    ; Carry bit goes into CF
                                    ; CF (Carry Flag) is SET (CF = 1)
                                    ; This happens because 256 can't fit in 8 bits
    
    jc jump_taken_3                 ; JC:  Jump if Carry (checks CF flag)
                                    ; Since CF = 1 (carry occurred), jump IS taken
                                    ; CPU jumps to 'jump_taken_3' label
                                    ; This demonstrates: "jump if carry"
    
    mov ah, 09h
    mov dx, offset msg_jump_not_taken
    int 21h
    jmp continue_3
    
jump_taken_3:
    mov ah, 09h
    mov dx, offset msg_jump_taken   ; Display "Jump TAKEN!"
    int 21h                         ; Executes because CF was 1
    
continue_3:
    mov ah, 09h
    mov dx, offset newline
    int 21h

    ;===========================================================================
    ; DEMONSTRATION 4: JNC - Jump if No Carry
    ;===========================================================================
    ; JNC checks the Carry Flag (CF)
    ; Jumps if CF = 0 (no carry occurred)
    ; Opposite of JC
    ;---------------------------------------------------------------------------
    ; Your notes: "④ JNC - jump if no carry"
    ;---------------------------------------------------------------------------
    
    mov ah, 09h
    mov dx, offset msg_jnc
    int 21h
    
    ; Test case 4: No carry
    mov al, 100                     ; AL = 100
    add al, 50                      ; AL = 100 + 50 = 150
                                    ; Result fits in 8 bits (150 < 256)
                                    ; No carry occurs
                                    ; CF (Carry Flag) is CLEAR (CF = 0)
    
    jnc jump_taken_4                ; JNC: Jump if No Carry (checks CF flag)
                                    ; Since CF = 0 (no carry), jump IS taken
                                    ; CPU jumps to 'jump_taken_4' label
                                    ; This demonstrates: "jump if no carry"
    
    mov ah, 09h
    mov dx, offset msg_jump_not_taken
    int 21h
    jmp continue_4
    
jump_taken_4:
    mov ah, 09h
    mov dx, offset msg_jump_taken   ; Display "Jump TAKEN!"
    int 21h                         ; Executes because CF was 0
    
continue_4:
    mov ah, 09h
    mov dx, offset newline
    int 21h

    ;===========================================================================
    ; DEMONSTRATION 5: JE - Jump if Equal
    ;===========================================================================
    ; JE checks the Zero Flag (ZF)
    ; Jumps if ZF = 1 (comparison showed equality)
    ; Used after CMP instruction
    ; JE and JZ are identical (same opcode), just different names
    ;---------------------------------------------------------------------------
    ; Your notes: "⑤ JE - jump if equal"
    ;---------------------------------------------------------------------------
    
    mov ah, 09h
    mov dx, offset msg_je
    int 21h
    
    ; Test case 5: Values are equal
    mov al, 42                      ; AL = 42
    cmp al, 42                      ; Compare AL with 42
                                    ; CMP performs subtraction:  AL - 42 = 0
                                    ; Result is zero, so ZF = 1
                                    ; ZF (Zero Flag) is SET (ZF = 1)
                                    ; This means operands were equal
    
    je jump_taken_5                 ; JE: Jump if Equal (checks ZF flag)
                                    ; Since ZF = 1 (operands equal), jump IS taken
                                    ; CPU jumps to 'jump_taken_5' label
                                    ; This demonstrates: "jump if equal"
                                    ; JE is same as JZ, just more semantic name
    
    mov ah, 09h
    mov dx, offset msg_jump_not_taken
    int 21h
    jmp continue_5
    
jump_taken_5:
    mov ah, 09h
    mov dx, offset msg_jump_taken   ; Display "Jump TAKEN!"
    int 21h                         ; Executes because values were equal
    
continue_5:
    mov ah, 09h
    mov dx, offset newline
    int 21h

    ;===========================================================================
    ; DEMONSTRATION 6: JNE - Jump if Not Equal
    ;===========================================================================
    ; JNE checks the Zero Flag (ZF)
    ; Jumps if ZF = 0 (comparison showed inequality)
    ; Opposite of JE
    ; JNE and JNZ are identical (same opcode), just different names
    ;---------------------------------------------------------------------------
    ; Your notes: "⑥ JNE - jump if not equal"
    ;---------------------------------------------------------------------------
    
    mov ah, 09h
    mov dx, offset msg_jne
    int 21h
    
    ; Test case 6: Values are NOT equal
    mov al, 42                      ; AL = 42
    cmp al, 99                      ; Compare AL with 99
                                    ; CMP performs subtraction: AL - 99 = -57
                                    ; Result is NOT zero, so ZF = 0
                                    ; ZF (Zero Flag) is CLEAR (ZF = 0)
                                    ; This means operands were NOT equal
    
    jne jump_taken_6                ; JNE: Jump if Not Equal (checks ZF flag)
                                    ; Since ZF = 0 (operands not equal), jump IS taken
                                    ; CPU jumps to 'jump_taken_6' label
                                    ; This demonstrates: "jump if not equal"
                                    ; JNE is same as JNZ, just more semantic name
    
    mov ah, 09h
    mov dx, offset msg_jump_not_taken
    int 21h
    jmp continue_6
    
jump_taken_6:
    mov ah, 09h
    mov dx, offset msg_jump_taken   ; Display "Jump TAKEN!"
    int 21h                         ; Executes because values were not equal
    
continue_6:
    mov ah, 09h
    mov dx, offset newline
    int 21h

    ;===========================================================================
    ; DEMONSTRATION 7: JG - Jump if Greater
    ;===========================================================================
    ; JG is for SIGNED comparison
    ; Jumps if first operand > second operand (signed)
    ; Checks:  ZF=0 AND SF=OF (Zero Flag clear, Sign equals Overflow)
    ; Used after CMP instruction
    ;---------------------------------------------------------------------------
    ; Your notes: "⑦ JG - jump if >"
    ;---------------------------------------------------------------------------
    
    mov ah, 09h
    mov dx, offset msg_jg
    int 21h
    
    ; Test case 7: First operand IS greater
    mov al, 10                      ; AL = 10
    cmp al, 5                       ; Compare AL with 5
                                    ; CMP performs:  AL - 5 = 10 - 5 = 5
                                    ; Result is positive (not zero)
                                    ; For signed comparison: 10 > 5
                                    ; ZF = 0 (not equal)
                                    ; SF = OF (sign matches overflow for positive result)
    
    jg jump_taken_7                 ; JG: Jump if Greater (signed comparison)
                                    ; Since 10 > 5, jump IS taken
                                    ; CPU jumps to 'jump_taken_7' label
                                    ; This demonstrates: "jump if >"
                                    ; JG is for SIGNED numbers (-128 to +127)
    
    mov ah, 09h
    mov dx, offset msg_jump_not_taken
    int 21h
    jmp continue_7
    
jump_taken_7:
    mov ah, 09h
    mov dx, offset msg_jump_taken   ; Display "Jump TAKEN!"
    int 21h                         ; Executes because 10 > 5
    
continue_7:
    mov ah, 09h
    mov dx, offset newline
    int 21h

    ;===========================================================================
    ; DEMONSTRATION 8: JGE - Jump if Greater or Equal
    ;===========================================================================
    ; JGE is for SIGNED comparison
    ; Jumps if first operand >= second operand (signed)
    ; Checks: SF=OF (Sign equals Overflow)
    ; Used after CMP instruction
    ;---------------------------------------------------------------------------
    ; Your notes: "⑧ JGE - jump if >="
    ;---------------------------------------------------------------------------
    
    mov ah, 09h
    mov dx, offset msg_jge
    int 21h
    
    ; Test case 8: First operand equals second
    mov al, 7                       ; AL = 7
    cmp al, 7                       ; Compare AL with 7
                                    ; CMP performs: AL - 7 = 7 - 7 = 0
                                    ; Result is zero (equal)
                                    ; For signed comparison: 7 >= 7 is TRUE
                                    ; SF = OF (condition met for >=)
    
    jge jump_taken_8                ; JGE: Jump if Greater or Equal (signed)
                                    ; Since 7 >= 7, jump IS taken
                                    ; CPU jumps to 'jump_taken_8' label
                                    ; This demonstrates: "jump if >="
                                    ; Would also jump if first operand > second
    
    mov ah, 09h
    mov dx, offset msg_jump_not_taken
    int 21h
    jmp continue_8
    
jump_taken_8:
    mov ah, 09h
    mov dx, offset msg_jump_taken   ; Display "Jump TAKEN!"
    int 21h                         ; Executes because 7 >= 7
    
continue_8:
    mov ah, 09h
    mov dx, offset newline
    int 21h

    ;===========================================================================
    ; DEMONSTRATION 9: JL - Jump if Less
    ;===========================================================================
    ; JL is for SIGNED comparison
    ; Jumps if first operand < second operand (signed)
    ; Checks: SF≠OF (Sign NOT equal to Overflow)
    ; Used after CMP instruction
    ;---------------------------------------------------------------------------
    ; Your notes:  "⑨ JL - jump if <"
    ;---------------------------------------------------------------------------
    
    mov ah, 09h
    mov dx, offset msg_jl
    int 21h
    
    ; Test case 9: First operand IS less
    mov al, 3                       ; AL = 3
    cmp al, 8                       ; Compare AL with 8
                                    ; CMP performs: AL - 8 = 3 - 8 = -5
                                    ; Result is negative
                                    ; For signed comparison:   3 < 8
                                    ; SF ≠ OF (condition for less than)
    
    jl jump_taken_9                 ; JL: Jump if Less (signed comparison)
                                    ; Since 3 < 8, jump IS taken
                                    ; CPU jumps to 'jump_taken_9' label
                                    ; This demonstrates:   "jump if <"
                                    ; JL is for SIGNED numbers
    
    mov ah, 09h
    mov dx, offset msg_jump_not_taken
    int 21h
    jmp continue_9
    
jump_taken_9:
    mov ah, 09h
    mov dx, offset msg_jump_taken   ; Display "Jump TAKEN!"
    int 21h                         ; Executes because 3 < 8
    
continue_9:
    mov ah, 09h
    mov dx, offset newline
    int 21h

    ;===========================================================================
    ; DEMONSTRATION 10: JLE - Jump if Less or Equal
    ;===========================================================================
    ; JLE is for SIGNED comparison
    ; Jumps if first operand <= second operand (signed)
    ; Checks: ZF=1 OR SF≠OF (Zero Flag set OR Sign NOT equal Overflow)
    ; Used after CMP instruction
    ;---------------------------------------------------------------------------
    ; Your notes: "⑩ JLE - jump if <="
    ;---------------------------------------------------------------------------
    
    mov ah, 09h
    mov dx, offset msg_jle
    int 21h
    
    ; Test case 10: First operand equals second
    mov al, 15                      ; AL = 15
    cmp al, 15                      ; Compare AL with 15
                                    ; CMP performs: AL - 15 = 15 - 15 = 0
                                    ; Result is zero (equal)
                                    ; For signed comparison: 15 <= 15 is TRUE
                                    ; ZF = 1 (equal condition met)
    
    jle jump_taken_10               ; JLE: Jump if Less or Equal (signed)
                                    ; Since 15 <= 15, jump IS taken
                                    ; CPU jumps to 'jump_taken_10' label
                                    ; This demonstrates: "jump if <="
                                    ; Would also jump if first operand < second
    
    mov ah, 09h
    mov dx, offset msg_jump_not_taken
    int 21h
    jmp continue_10
    
jump_taken_10:
    mov ah, 09h
    mov dx, offset msg_jump_taken   ; Display "Jump TAKEN!"
    int 21h                         ; Executes because 15 <= 15
    
continue_10:
    mov ah, 09h
    mov dx, offset newline
    int 21h

    ;===========================================================================
    ; PRACTICAL EXAMPLE: Y/N INPUT VALIDATION WITH CONDITIONAL JUMPS
    ;===========================================================================
    ; Your notes show sample output: 
    ; "Do you want another (Y/N)?"
    ; If Y/y → repeat the question
    ; If any = N/n → terminate the code
    ; If any != Y/y & N/n → invalid input, repeat the question
    ;---------------------------------------------------------------------------
    
    mov ah, 09h
    mov dx, offset press_key
    int 21h
    mov ah, 01h
    int 21h

question_loop:                      ; LABEL: Main question loop starts here
                                    ; This is where we return to ask again
    
    ;---------------------------------------------------------------------------
    ; Display the question
    ;---------------------------------------------------------------------------
    mov ah, 09h                     ; AH = 09h:  Display string
    mov dx, offset msg_question     ; DX = address of "Do you want another (Y/N)?"
    int 21h                         ; Display question

    ;---------------------------------------------------------------------------
    ; Get user input (Y or N)
    ;---------------------------------------------------------------------------
    mov ah, 01h                     ; AH = 01h: Input character with echo
    int 21h                         ; Wait for keypress, character returned in AL
                                    ; User presses a key (e.g., 'Y', 'y', 'N', 'n', or other)
    
    mov user_choice, al             ; Store input in user_choice variable
                                    ; AL contains ASCII code of key pressed

    ;---------------------------------------------------------------------------
    ; CHECK 1: Is it uppercase 'Y'?
    ;---------------------------------------------------------------------------
    ; Your notes: "If Y/y repeat the question"
    ;---------------------------------------------------------------------------
    
    cmp user_choice, 'Y'            ; CMP: Compare user_choice with 'Y' (ASCII 59h)
                                    ; If user typed 'Y', ZF = 1 (equal)
                                    ; If user typed anything else, ZF = 0 (not equal)
                                    ; This is the comparison that sets flags
    
    je repeat_question              ; JE: Jump if Equal (checks ZF flag)
                                    ; If user_choice == 'Y', jump to repeat_question
                                    ; This demonstrates practical use of JE
                                    ; Your notes: "If Y/y repeat the question"

    ;---------------------------------------------------------------------------
    ; CHECK 2: Is it lowercase 'y'?
    ;---------------------------------------------------------------------------
    
    cmp user_choice, 'y'            ; CMP:  Compare user_choice with 'y' (ASCII 79h)
                                    ; Check for lowercase 'y'
                                    ; Sets ZF = 1 if match, ZF = 0 if no match
    
    je repeat_question              ; JE: Jump if Equal
                                    ; If user_choice == 'y', jump to repeat_question
                                    ; Handles both uppercase and lowercase Y
                                    ; Your notes: "If Y/y repeat the question"

    ;---------------------------------------------------------------------------
    ; CHECK 3: Is it uppercase 'N'?
    ;---------------------------------------------------------------------------
    ; Your notes:   "If any = N/n terminate the code"
    ;---------------------------------------------------------------------------
    
    cmp user_choice, 'N'            ; CMP: Compare user_choice with 'N' (ASCII 4Eh)
                                    ; Check if user wants to terminate
                                    ; Sets ZF = 1 if match, ZF = 0 if no match
    
    je terminate_program            ; JE: Jump if Equal
                                    ; If user_choice == 'N', jump to terminate_program
                                    ; This exits the program
                                    ; Your notes: "If any = N/n terminate the code"

    ;---------------------------------------------------------------------------
    ; CHECK 4: Is it lowercase 'n'?
    ;---------------------------------------------------------------------------
    
    cmp user_choice, 'n'            ; CMP: Compare user_choice with 'n' (ASCII 6Eh)
                                    ; Check for lowercase 'n'
                                    ; Sets ZF = 1 if match, ZF = 0 if no match
    
    je terminate_program            ; JE:   Jump if Equal
                                    ; If user_choice == 'n', jump to terminate_program
                                    ; Handles both uppercase and lowercase N
                                    ; Your notes: "If any = N/n terminate the code"

    ;---------------------------------------------------------------------------
    ; If we reach here, input was INVALID (not Y, y, N, or n)
    ;---------------------------------------------------------------------------
    ; Your notes: "If any != Y/y & N/n → invalid input & repeat the question"
    ;---------------------------------------------------------------------------
    
    mov ah, 09h                     ; AH = 09h: Display string
    mov dx, offset msg_invalid      ; DX = address of "Invalid input!" message
    int 21h                         ; Display error message
                                    ; Tell user their input was invalid
    
    jmp question_loop               ; JMP:  Unconditional jump back to question_loop
                                    ; Ask the question again
                                    ; This is the "repeat the question" part
                                    ; Your notes: "If any != Y/y & N/n → invalid input
                                    ;              & repeat the question"

repeat_question:                    ; LABEL: User chose Y or y
                                    ; This section executes when user wants to repeat
    
    mov ah, 09h                     ; AH = 09h: Display string
    mov dx, offset msg_repeat       ; DX = address of "You chose Y - Repeating..." message
    int 21h                         ; Display confirmation message
                                    ; Shows user we understood their choice
    
    jmp question_loop               ; JMP: Jump back to question_loop
                                    ; Ask the question again
                                    ; This creates the repeat functionality
                                    ; Your notes:  "If Y/y repeat the question"

terminate_program:                  ; LABEL:   User chose N or n
                                    ; This section executes when user wants to exit
    
    mov ah, 09h                     ; AH = 09h: Display string
    mov dx, offset msg_terminate    ; DX = address of "You chose N - Terminating..." message
    int 21h                         ; Display exit message
                                    ; Shows user we're exiting
                                    ; Your notes: "If any = N/n terminate the code"

    ;---------------------------------------------------------------------------
    ; EXIT PROGRAM
    ;---------------------------------------------------------------------------
    mov ah, 4ch                     ; AH = 4Ch:  Terminate program
                                    ; DOS function to exit
    int 21h                         ; Call DOS to exit program
                                    ; Program ends here

end                                 ; End of program

;===============================================================================
; CONDITIONAL JUMP INSTRUCTION SUMMARY
;===============================================================================
;
; Based on Zero Flag (ZF):
;   JZ  / JE    Jump if Zero / Jump if Equal             ZF=1
;   JNZ / JNE   Jump if Not Zero / Jump if Not Equal     ZF=0
;
; Based on Carry Flag (CF):
;   JC          Jump if Carry                            CF=1
;   JNC         Jump if No Carry                         CF=0
;
; Signed Comparisons (use SF, OF, ZF):
;   JG          Jump if Greater                          ZF=0 AND SF=OF
;   JGE         Jump if Greater or Equal                 SF=OF
;   JL          Jump if Less                             SF≠OF
;   JLE         Jump if Less or Equal                    ZF=1 OR SF≠OF
;
; Unsigned Comparisons (use CF, ZF):
;   JA          Jump if Above (unsigned >)               CF=0 AND ZF=0
;   JAE         Jump if Above or Equal (unsigned >=)     CF=0
;   JB          Jump if Below (unsigned <)               CF=1
;   JBE         Jump if Below or Equal (unsigned <=)     CF=1 OR ZF=1
;
; Note: JE and JZ are the same instruction (same opcode)
;       JNE and JNZ are the same instruction (same opcode)
;       Use JE/JNE after CMP for clarity (semantic meaning)
;       Use JZ/JNZ after arithmetic operations
;
;===============================================================================
; Y/N VALIDATION LOGIC FLOW
;===============================================================================
;
; 1. Display question:  "Do you want another (Y/N)?"
; 2. Get user input character
; 3. Compare with 'Y' → if equal, repeat question
; 4. Compare with 'y' → if equal, repeat question
; 5. Compare with 'N' → if equal, terminate program
; 6. Compare with 'n' → if equal, terminate program
; 7. If none matched → display "Invalid input", repeat question
;
; Flow diagram:
;           ┌─────────────────┐
;           │  Ask Question   │
;           └────────┬────────┘
;                    ↓
;           ┌────────────────┐
;           │   Get Input    │
;           └────────┬───────┘
;                    ↓
;           ┌────────────────┐
;      ┌────│  Is it Y/y?    │────┐
;      │    └────────────────┘    │
;     YES                          NO
;      │                           │
;      ↓                           ↓
; ┌─────────┐          ┌──────────────────┐
; │ Repeat  │          │  Is it N/n?       │
; │Question │          └─────┬──────┬─────┘
; └────┬────┘               YES    NO
;      │                     │      │
;      │                     ↓      ↓
;      │              ┌──────────┐ ┌────────────┐
;      │              │   Exit   │ │   Invalid  │
;      │              │  Program │ │   Input    │
;      │              └──────────┘ └──────┬─────┘
;      │                                   │
;      └───────────────────────────────────┘
;
;===============================================================================
; PRACTICAL USES OF CONDITIONAL JUMPS
;===============================================================================
;
; 1. Input Validation:
;    - Check if input is within valid range
;    - Verify Y/N responses
;    - Validate numeric input
;
; 2. Loop Control:
;    - Check if counter reached limit
;    - Exit loop when condition met
;    - Continue loop while condition true
;
; 3. Comparison Operations:
;    - Find maximum/minimum values
;    - Sort algorithms
;    - Search algorithms
;
; 4. Error Handling:
;    - Check for overflow (JC)
;    - Check for zero division (JZ)
;    - Validate calculation results
;
; 5. Menu Systems:
;    - Compare user choice with options
;    - Branch to different functions
;    - Return to menu or exit
;
;===============================================================================
; FLAG REGISTER REFERENCE
;===============================================================================
;
; The FLAGS register is 16-bit with these important bits:
;
; Bit | Flag | Name           | Set When
; ----|------|----------------|------------------------------------------
;  0  |  CF  | Carry Flag     | Carry/borrow in arithmetic
;  2  |  PF  | Parity Flag    | Even number of 1 bits in result
;  4  |  AF  | Auxiliary Flag | Carry from bit 3 to bit 4 (BCD)
;  6  |  ZF  | Zero Flag      | Result is zero
;  7  |  SF  | Sign Flag      | Result is negative (bit 7 set)
;  11 |  OF  | Overflow Flag  | Signed arithmetic overflow
;
; Instructions that affect flags:
;   CMP:   Sets all flags based on subtraction (doesn't store result)
;   TEST: Sets ZF, SF, PF based on bitwise AND (doesn't store result)
;   ADD:  Sets CF, ZF, SF, OF based on addition
;   SUB:   Sets CF, ZF, SF, OF based on subtraction
;   INC:  Sets ZF, SF, OF (doesn't affect CF)
;   DEC:  Sets ZF, SF, OF (doesn't affect CF)
;
;===============================================================================