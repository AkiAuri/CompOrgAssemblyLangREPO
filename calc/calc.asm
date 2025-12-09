.model small                        ; Define memory model as 'small' (code and data each fit in 64KB)
.stack 100h                        ; Allocate 256 bytes (100h) for the stack

.data                               ; Start of data segment (where variables and constants are stored)
    ; Menu messages
    msg_menu db 10,13,"===== CALCULATOR MENU =====",10,13  ; Menu title with newlines (10=LF, 13=CR)
             db "1. Add",10,13                             ; Menu option 1 with newline
             db "2. Subtract",10,13                        ; Menu option 2 with newline
             db "3. Multiply",10,13                        ; Menu option 3 with newline
             db "4. Divide",10,13                          ; Menu option 4 with newline
             db "5. Exit",10,13                            ; Menu option 5 with newline
             db "Enter your choice:  $"                    ; Prompt for choice ($ terminates string)
    
    ; Input prompts
    msg_num1 db 10,13,"Enter first number (0-9): $"        ; Prompt for first number with newline
    msg_num2 db 10,13,"Enter second number (0-9): $"       ; Prompt for second number with newline
    
    ; Result messages
    msg_result db 10,13,"The result is:  $"                ; Result display message with newline
    msg_invalid db 10,13,"Invalid choice!  Try again.$"    ; Error message for invalid menu choice
    msg_divzero db 10,13,"Error:  Cannot divide by zero!  $" ; Error message for division by zero
    
    ; Variables
    choice db 0                     ; Variable to store user's menu choice (1 byte)
    num1 db 0                       ; Variable to store first input number (1 byte)
    num2 db 0                       ; Variable to store second input number (1 byte)
    result db 0                     ; Variable to store calculation result (1 byte)
    is_multi_digit db 0             ; Flag to indicate if result needs two digits (1=yes, 0=no)

.code                               ; Start of code segment (where program instructions are stored)
    mov ax, @data                   ; Load the address of data segment into AX register
    mov ds, ax                      ; Move AX value into DS (Data Segment register) to access variables

menu_loop:                          ; Label 'menu_loop' - main program loop starts here
    mov ah, 09h                     ; DOS function 09h: Display string terminated by '$'
    mov dx, offset msg_menu         ; Load offset address of msg_menu into DX register
    int 21h                         ; Call DOS interrupt 21h to display the menu
    
    mov ah, 01h                     ; DOS function 01h: Read single character from keyboard
    int 21h                         ; Call DOS interrupt, character stored in AL (echoed to screen)
    mov choice, al                  ; Store the input character from AL into 'choice' variable
    
    ; Check for Exit (choice 5)
    cmp choice, '5'                 ; Compare 'choice' with ASCII character '5'
    jne check_valid                 ; Jump to 'check_valid' if NOT equal (if choice is not 5)
    jmp exit_program                ; Unconditional jump to exit program (choice was 5)
    
check_valid:                        ; Label 'check_valid' - validate that choice is between 1-4
    ; Validate choice (1-4)
    cmp choice, '1'                 ; Compare 'choice' with ASCII character '1'
    jl show_invalid                 ; Jump to 'show_invalid' if less (choice < 1 is invalid)
    cmp choice, '4'                 ; Compare 'choice' with ASCII character '4'
    jg show_invalid                 ; Jump to 'show_invalid' if greater (choice > 4 is invalid)
    jmp get_numbers                 ; Unconditional jump to get numbers (choice is valid 1-4)
    
show_invalid:                       ; Label 'show_invalid' - display error for invalid choice
    mov ah, 09h                     ; DOS function 09h: Display string terminated by '$'
    mov dx, offset msg_invalid      ; Load offset address of msg_invalid into DX register
    int 21h                         ; Call DOS interrupt to display "Invalid choice!  Try again."
    jmp menu_loop                   ; Unconditional jump back to menu_loop to show menu again

get_numbers:                        ; Label 'get_numbers' - get two numbers from user
    ; Get first number
    mov ah, 09h                     ; DOS function 09h: Display string terminated by '$'
    mov dx, offset msg_num1         ; Load offset address of msg_num1 into DX register
    int 21h                         ; Call DOS interrupt to display "Enter first number (0-9): "
    
    mov ah, 01h                     ; DOS function 01h: Read single character from keyboard
    int 21h                         ; Call DOS interrupt, character stored in AL (echoed to screen)
    sub al, 30h                     ; Convert ASCII to decimal (subtract 48 to get actual number)
    mov num1, al                    ; Store the numeric value from AL into 'num1' variable
    
    ; Get second number
    mov ah, 09h                     ; DOS function 09h: Display string terminated by '$'
    mov dx, offset msg_num2         ; Load offset address of msg_num2 into DX register
    int 21h                         ; Call DOS interrupt to display "Enter second number (0-9): "
    
    mov ah, 01h                     ; DOS function 01h: Read single character from keyboard
    int 21h                         ; Call DOS interrupt, character stored in AL (echoed to screen)
    sub al, 30h                     ; Convert ASCII to decimal (subtract 48 to get actual number)
    mov num2, al                    ; Store the numeric value from AL into 'num2' variable
    
    ; Clear multi-digit flag
    mov is_multi_digit, 0           ; Reset multi-digit flag to 0 (assume single digit result)
    
    ; Perform operation based on choice
    cmp choice, '1'                 ; Compare 'choice' with ASCII character '1' (Add)
    je do_add                       ; Jump to 'do_add' if equal (user chose addition)
    
    cmp choice, '2'                 ; Compare 'choice' with ASCII character '2' (Subtract)
    je do_subtract                  ; Jump to 'do_subtract' if equal (user chose subtraction)
    
    cmp choice, '3'                 ; Compare 'choice' with ASCII character '3' (Multiply)
    je do_multiply                  ; Jump to 'do_multiply' if equal (user chose multiplication)
    
    cmp choice, '4'                 ; Compare 'choice' with ASCII character '4' (Divide)
    je do_divide                    ; Jump to 'do_divide' if equal (user chose division)
    jmp menu_loop                   ; Safety jump back to menu (should not reach here)

do_add:                             ; Label 'do_add' - perform addition operation
    mov al, num1                    ; Load first number from 'num1' into AL register
    add al, num2                    ; Add second number from 'num2' to AL (result in AL)
    mov result, al                  ; Store the sum from AL into 'result' variable
    mov is_multi_digit, 1           ; Set flag to 1 (addition can produce two-digit result like 9+9=18)
    jmp display_result              ; Unconditional jump to display the result

do_subtract:                        ; Label 'do_subtract' - perform subtraction operation
    mov al, num1                    ; Load first number from 'num1' into AL register
    sub al, num2                    ; Subtract second number from AL (result in AL, may be negative)
    mov result, al                  ; Store the difference from AL into 'result' variable
    jmp display_result              ; Unconditional jump to display the result

do_multiply:                        ; Label 'do_multiply' - perform multiplication operation
    mov al, num1                    ; Load first number from 'num1' into AL register
    mul num2                        ; Multiply AL by 'num2' (result in AX, we use lower byte AL)
    mov result, al                  ; Store the product from AL into 'result' variable (lower byte)
    mov is_multi_digit, 1           ; Set flag to 1 (multiplication can produce two-digit result like 4×5=20)
    jmp display_result              ; Unconditional jump to display the result

do_divide:                          ; Label 'do_divide' - perform division operation
    cmp num2, 0                     ; Compare second number with 0 (check for division by zero)
    jne div_ok                      ; Jump to 'div_ok' if NOT equal (divisor is not zero, safe to divide)
    
    mov ah, 09h                     ; DOS function 09h: Display string terminated by '$'
    mov dx, offset msg_divzero      ; Load offset address of msg_divzero into DX register
    int 21h                         ; Call DOS interrupt to display "Error: Cannot divide by zero!"
    jmp menu_loop                   ; Unconditional jump back to menu (skip division, return to menu)

div_ok:                             ; Label 'div_ok' - safe to perform division (divisor is not zero)
    mov al, num1                    ; Load first number (dividend) from 'num1' into AL register
    mov ah, 0                       ; Clear AH register to 0 (required for division, AX = dividend)
    div num2                        ; Divide AX by 'num2' (quotient in AL, remainder in AH)
    mov result, al                  ; Store the quotient from AL into 'result' variable
    jmp display_result              ; Unconditional jump to display the result

display_result:                     ; Label 'display_result' - display the calculation result
    mov ah, 09h                     ; DOS function 09h: Display string terminated by '$'
    mov dx, offset msg_result       ; Load offset address of msg_result into DX register
    int 21h                         ; Call DOS interrupt to display "The result is: "
    
    ; Check if multi-digit result (addition or multiplication)
    cmp is_multi_digit, 1           ; Compare flag with 1 (check if result needs two digits)
    je display_multi                ; Jump to 'display_multi' if equal (handle two-digit display)
    
    mov al, result                  ; Load result from 'result' into AL register
    test al, 80h                    ; Test if bit 7 (sign bit) is set using bitwise AND with 10000000
    jz positive_result              ; Jump to 'positive_result' if zero flag set (number is positive)
    
    ; Handle negative result
    mov ah, 02h                     ; DOS function 02h: Display single character
    mov dl, '-'                     ; Load minus sign character '-' into DL register
    int 21h                         ; Call DOS interrupt to display minus sign
    
    mov al, result                  ; Load result from 'result' into AL register again
    neg al                          ; Negate AL using two's complement (convert negative to positive)
    mov dl, al                      ; Move the positive value from AL to DL register
    add dl, 30h                     ; Convert decimal digit to ASCII (add 48 to get ASCII character)
    mov ah, 02h                     ; DOS function 02h: Display single character
    int 21h                         ; Call DOS interrupt to display the digit
    jmp menu_loop                   ; Unconditional jump back to menu_loop to show menu again
    
positive_result:                    ; Label 'positive_result' - display single positive digit
    mov dl, result                  ; Load result from 'result' into DL register
    add dl, 30h                     ; Convert decimal digit to ASCII (add 48 to get ASCII character)
    mov ah, 02h                     ; DOS function 02h: Display single character
    int 21h                         ; Call DOS interrupt to display the digit
    jmp menu_loop                   ; Unconditional jump back to menu_loop to show menu again

display_multi:                      ; Label 'display_multi' - display two-digit result (10-81)
    mov al, result                  ; Load result from 'result' into AL register
    mov ah, 0                       ; Clear AH register to 0 (prepare AX for division)
    mov bl, 10                      ; Load divisor 10 into BL register (to separate tens and ones)
    div bl                          ; Divide AX by 10 (quotient/tens in AL, remainder/ones in AH)
    
    ; Check if tens digit exists
    cmp al, 0                       ; Compare quotient (tens digit) with 0
    je skip_tens                    ; Jump to 'skip_tens' if equal (no tens digit, only ones)
    
    mov dl, al                      ; Move tens digit from AL to DL register
    add dl, 30h                     ; Convert decimal digit to ASCII (add 48 to get ASCII character)
    push ax                         ; Save AX register on stack (preserve remainder in AH)
    mov ah, 02h                     ; DOS function 02h: Display single character
    int 21h                         ; Call DOS interrupt to display tens digit
    pop ax                          ; Restore AX register from stack (get remainder back in AH)
    
skip_tens:                          ; Label 'skip_tens' - display ones digit
    mov dl, ah                      ; Move ones digit (remainder) from AH to DL register
    add dl, 30h                     ; Convert decimal digit to ASCII (add 48 to get ASCII character)
    mov ah, 02h                     ; DOS function 02h: Display single character
    int 21h                         ; Call DOS interrupt to display ones digit
    
    jmp menu_loop                   ; Unconditional jump back to menu_loop to show menu again

exit_program:                       ; Label 'exit_program' - terminate the program
    mov ah, 4ch                     ; DOS function 4Ch: Terminate program with return code
    int 21h                         ; Call DOS interrupt to exit program and return to DOS
end                                 ; End of program (marks end of source code for assembler)