User
.model small
.stack 100h

.data
    filename db 101 dup(0)
    buffer db 100 dup("$")
    buffer2 db 100 dup("$")
    text db "Mi nombre es Nicolasooo a @",0
    msg db "Ingrese el nombre del archivo::: $"
    charCount db 0
    wordCount db 0
    newline db 13, 10, "$"

.code
start:
    mov ax, @data
    mov ds, ax

    call read_file
    call count_characters
    call count_words

    mov ah, 4ch
    int 21h

count_characters proc
    xor bx, bx  ; Reset BX to zero
    mov si, offset buffer

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
    mov charCount, al

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
    xor bx, bx  ; Reset BX to zero
    mov si, offset buffer

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
    mov wordCount, al

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

read_file proc
    mov ah, 9
    mov dx, offset msg
    int 21h
    mov ah, 0Ah
    mov dx, offset filename
    int 21h

    mov ah, 9
    lea dx, filename
    int 21h

    mov ah ,filename
    mov filename, buffer
    mov buffer, buffer2
    int 21h

    mov ah, 3dh
    mov al, 0
    lea dx, filename
    int 21h
    jc error_handler  ; Handle file open error

    mov bx, ax

    mov ah, 3fh  ; Read from file
    mov bx, ax   ; Move the file handle to BX

    mov cx, 100  ; Number of bytes to read
    lea dx, buffer2  ; Destination buffer
    int 21h

    mov ah, 3eh  ; Close the file
    int 21h

    mov ah, 9h   ; Display the content
    lea dx, buffer
    int 21h

    ret

error_handler proc
    mov ah, 9
    mov dx, offset newline
    int 21h
    ret
error_handler endp

end