.model small
.stack 100h

.data
    filename db "EXAMPLE.TXT", 0
    buffer db 100 dup("$")

.code
    mov ax, @data
    mov ds, ax

    ; open file
    mov ah, 3dh
    mov al, 0
    lea dx, filename
    int 21h
    mov bx, ax

    ; read file
    mov ah, 3fh
    mov cx, 100
    lea dx, buffer
    int 21h

    ; print file contents
    mov ah, 9h
    lea dx, buffer
    int 21h

    ; close file
    mov ah, 3eh
    int 21h

    mov ah, 4ch
    int 21h
end
