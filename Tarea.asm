.model small
.stack 100h

.data
    filename db 20 dup('$'),0
    filename_C db 100 dup('$')
    cleaned_filename db 100 dup(0) 
    buffer db 100 dup(0)
    text db "Mi nombre es Nicolasooo a @",0
    msg db "Enter the filename: $"
    error_msg db "Error $"
count db 3 dup(0)
    newline db 13, 10, "$"

.code
start:
    mov ax, @data
    mov ds, ax

    call get_filename
    call clean_filename
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
    lea dx, filename
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



clean_filename proc
    mov si, offset filename
    mov di, offset cleaned_filename ; Create a destination pointer
    cld ; Set the direction flag to forward for string operations

cln_f_loop:
    mov al, [si]
    cmp al, 0
    je end_loop_c
    cmp al, 'A'
    jb not_letter_or_period
    cmp al, 'Z'
    jbe letter_or_period
    cmp al, 'a'
    jb not_letter_or_period
    cmp al, 'z'
    jbe letter_or_period
    cmp al, '.'
    je letter_or_period

not_letter_or_period:
    mov byte ptr [di], 0 ; Write null character to cleaned string
    jmp end_loop_c

letter_or_period:
    mov [di], al ; Copy the letter or period to the cleaned string
    inc di

end_loop_c:
    inc si
    jmp cln_f_loop

clean_filename endp



 mov ah, 4ch
 int 21h

end start