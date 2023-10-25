.model small
.stack 100h

.data
    filename db 100 dup(0)
    buffer db 100 dup("$")
    text db "Mi nombre es Nicolasooo@",0
    msg db "Ingrese el nombre del archivo: $"
    count db 3 dup(0)
    newline db 13, 10, "$" ; Newline characters for display

.code
start:
    mov ax, @data
    mov ds, ax

    call count_characters

    mov ah, 4ch
    int 21h

count_characters proc
    mov si, offset text
    mov cx, 0
    mov bx, 0  ; Variable to store the count
loop1:
    mov al, [si]
    cmp al, '@'  ; Check for the '@' character
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
    inc bx      ; Increment the count
next_char:
    inc si
    jmp loop1

end_loop1:
    ; Store the count in the 'count' variable
    mov al, bl  ; Copy the count from bx to al
    mov count, al

    ; Convert the count (in al) to an ASCII string
    mov ah, 0   ; Clear ah
    mov cx, 10
    mov di, offset buffer + 9  ; Start storing digits from the end of the buffer

convert_loop:
    xor dx, dx   ; Clear any previous remainder
    div cx       ; Divide AL by 10, result in AL, remainder in DX
    add dl, '0'  ; Convert remainder to ASCII
    dec di       ; Move DI backward in the buffer
    mov [di], dl ; Store the ASCII digit in the buffer
    test al, al  ; Check if AL is zero
    jnz convert_loop

    ; Display the converted count (ASCII string)
    mov ah, 9
    lea dx, [di]
    int 21h

    ; Display a newline
    lea dx, newline
    int 21h

    ret
count_characters endp

end
