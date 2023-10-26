.model small
.stack 100h

.data
    filename db 100 dup(0)
    buffer db 100 dup("$")
    text db "Mi nombre es Nicolasooo a @",0
    msg db "Ingrese el nombre del archivo::: $"
    count db 3 dup(0)
    newline db 13, 10, "$" 

.code
start:
    mov ax, @data
    mov ds, ax

    call count_characters
    call count_words
    mov ah, 4ch
    int 21h

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

end
