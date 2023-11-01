.model small
.stack 100h

.data
    filename db 100 dup(0)
    buffer db 100 dup(0)
    text db 100 dup(0)
    msg db "Enter the filename: $"
    charCount db 0
    wordCount db 0
    newline db 13, 10, "$"

.code
start:
    mov ax, @data
    mov ds, ax

    call get_filename
    call read_file
    call count_characters
    call count_words

get_filename proc
    mov ah, 09h           ; DOS function to print a string
    lea dx, msg           ; Load the address of the prompt string
    int 21h               ; Call DOS to print the prompt

    mov ah, 0Ah           ; DOS function to read a string from the user
    mov dx, offset filename ; Load the address of the input buffer
    int 21h 

    save proc
    mov ax ,0000
    mov ah, 01h
    int 21h 
    save endp 
    
    cmp al, 0dh 
    mov filename[si], al
    inc si 
    call save

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

    error_handler proc
    mov ah, 9
    mov dx, offset newline
    int 21h
    ret
error_handler endp

read_file endp



count_characters proc
    xor bx, bx  ; Reset BX to zero
    mov si, offset buffer

loop1:
    mov al, [si]
    cmp al, 0     ; Check for null terminator
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
    mov charCount, al

    mov ah, 0
    mov cx, 10
    mov di, offset text

convert_loop:
    xor dx, dx
    div cx
    add dl, '0'
    dec di
    mov [di], dl
    test al, al
    jnz convert_loop

    mov ah, 9
    lea dx, text
    int 21h

    lea dx, newline
    int 21h

    ret
count_characters endp

count_words proc
    xor bx, bx      ; Reset BX to zero
    mov si, offset buffer

word_loop:
    mov al, [si]
    cmp al, 0      ; Check for the null terminator to determine the end of the string
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
    mov wordCount, al

    mov ah, 0
    mov cx, 10
    mov di, offset text

convert_loop_W:
    xor dx, dx
    div cx
    add dl, '0'
    dec di
    mov [di], dl
    test al, al
    jnz convert_loop_W

    mov ah, 9
    lea dx, text
    int 21h

    lea dx, newline
    int 21h

    ret
count_words endp

    mov ah, 4ch
    int 21h

end
