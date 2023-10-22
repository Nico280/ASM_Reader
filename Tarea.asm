.model small
.stack 100h

.data
filename db 100 dup(0) 
    buffer db 100 dup("$")
    msg db "Ingrese el nombre del archivo: $"

.code
    mov ax, @data
    mov ds, ax

    call read_file 

    mov ah, 4ch
    int 21h
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

        mov ah, 9h
        lea dx, buffer
        int 21h

        mov ah, 3eh
        int 21h       
    read_file endp

    end 
