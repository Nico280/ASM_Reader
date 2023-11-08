.model small
.stack 100h

.data
    filename db 20 dup('$'),0
    filename_C db 20 dup(' ')
    cleaned_filename db 20 dup(' ') 
    buffer db 100 dup(' ')
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
  mov ah, 3Dh              ; DOS function to open a file
    lea dx, cleaned_filename ; Load the address of the cleaned filename
    mov al, 0               ; Open file for reading (AL = 0)
    int 21h                 ; Call DOS to open the file

    jc file_error           ; Jump if the file opening fails

    mov bx, ax              ; Store the file handle in BX

    mov ah, 3Fh              ; DOS function to read from a file
    mov cx, 100              ; Number of bytes to read
    lea dx, buffer           ; Load the address of the buffer
    int 21h                  ; Call DOS to read from the file

    jc file_error           ; Jump if the file reading fails

    mov ah, 3Eh              ; DOS function to close a file
    mov bx, ax              ; Get the file handle back into BX
    int 21h                 ; Call DOS to close the file

    jmp file_read_success

file_error:
    lea dx, error_msg
    int 21h

file_read_success:
    ret

read_file endp

count_characters proc
    mov si, offset buffer
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
    mov si, offset buffer
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
    cmp al, ' '
    je end_loop_c
    cmp al, '.'
    je letter_or_period
    cmp al, 'A'
    jb not_letter_or_period
    cmp al, 'Z'
    jbe letter_or_period
    cmp al, 'a'
    jb not_letter_or_period
    cmp al, 'z'
    jbe letter_or_period
  

not_letter_or_period:
    mov byte ptr [di], 0 ; Write null character to cleaned string
    jmp cont_loop_c

letter_or_period:
    mov [di], al ; Copy the letter or period to the cleaned string
    inc di

cont_loop_c:
    inc si
    jmp cln_f_loop
end_loop_c:
    ret

clean_filename endp



 mov ah, 4ch
 int 21h

end start