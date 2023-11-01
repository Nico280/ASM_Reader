.model small
.stack 100h

.data
    filename db 100 dup('$')
    filename_C db 100 dup('$')
    buffer db 100 dup(0)
    text db 100 dup(0)
    msg db "Enter the filename: $"
    error_msg db "Error $"
    charCount db 0
    wordCount db 0
    newline db 13, 10, "$"

.code
start:
    mov ax, @data
    mov ds, ax

    call get_filename

    lea si, filename
    lea di, filename_C
    call Clean_text

    call read_file
    call count_characters
    call count_words

    mov ah, 4Ch
    int 21h

get_filename proc
    mov ah, 09h           ; DOS function to print a string
    lea dx, msg           ; Load the address of the prompt string
    int 21h               ; Call DOS to print the prompt

    mov ah, 0Ah           ; DOS function to read a string from the user
    lea dx, filename ; Load the address of the input buffer
    int 21h

    ret
get_filename endp

read_file proc
    mov ah, 3Dh     ; Open the file
    mov al, 0       ; Open for read-only
    lea dx, filename_C
    int 21h
    jc error_handler  ; Handle file open error
    mov bx, ax

    mov ah, 3Fh
    mov cx, 100      ; Number of bytes to read
    mov dx, offset buffer
    mov bx, ax       ; Move the file handle to BX
    int 21h
    jc error_handler

    ret

error_handler:
    mov ah, 9
    mov dx, offset newline
    int 21h
    mov dx, offset error_msg
    int 21h

read_file endp

count_characters proc
    mov si, offset text
    mov cx, 0
    mov bx, 0  
loop1:
    mov al, [si]
    cmp al, '@'  
    je end_loop1
    cmp al, 'A'
    jb next_char
    cmp al, 'Z'
    jbe letter
    cmp al, 'a'
    jb next_char
    cmp al, 'z'
    jbe letter

letter:
    inc bx      
next_char:
    inc si
    jmp loop1

end_loop1:
   
    mov al, bl  
    mov count, al

   
    mov ah, 0   
    mov cx, 10
    mov di, offset buffer + 9 

convert_loop:
    xor dx, dx   
    div cx      
    add dl, '0' 
    dec di       
    mov [di], dl 
    test al, al  
    jnz convert_loop


    mov ah, 9
    lea dx, [di]
    int 21h

    lea dx, newline
    int 21h

    ret
count_characters endp

count_words proc
    mov si, offset text
    mov cx, 0
    mov bx, 0
    mov dx, 0

word_loop:
    mov al, [si]
    cmp al, '@'
    je end_word_loop
    cmp al, ' ' 
    je space_found
    jmp next_char_W

space_found:
    inc bx 

next_char_W:
    inc si
    jmp word_loop

end_word_loop:
    mov al, bl 
    mov count, al

    mov ah, 0
    mov cx, 10
    mov di, offset buffer + 9

convert_loop_W:
    xor dx, dx
    div cx
    add dl, '0'
    dec di
    mov [di], dl
    test al, al
    jnz convert_loop_W

    mov ah, 9
    lea dx, [di]
    int 21h

    lea dx, newline
    int 21h

    ret
count_words endp

Clean_text proc
   xor cx, cx  ; Clear CX to use it as a counter

    modify_loop:
    mov al, [si]    ; Load the character at SI into AL
    cmp al, 0       ; Check if it's the null terminator (end of string)
    je done         ; If it's the end of the string, exit the loop

    ; Check if the character is a letter (A-Z, a-z) or a period '.'
    cmp al, 'A'
    jl not_a_letter_or_period
    cmp al, 'Z'
    jbe is_a_letter_or_period
    cmp al, 'a'
    jl not_a_letter_or_period
    cmp al, 'z'
    ja not_a_letter_or_period
    cmp al, '.'     ; Check if it's a period
    jne not_a_letter_or_period

    is_a_letter_or_period:
    ; If it's a letter or period, keep it in the output string
    mov [di], al
    jmp character_processed

    not_a_letter_or_period:
    ; If it's not a letter or period, replace it with '0'
    mov al, '0'
    mov [di], al

    character_processed:
    inc si  ; Move to the next character in the input string
    inc di  ; Move to the next character in the output string
    inc cx  ; Increment the counter
    jmp modify_loop

    done:
    ; Null-terminate the output string
    mov byte ptr [di], 0

    ret
 Clean_text endp

end start