name "hi-world-2"

.model small
.stack 100h
.data
message db "Hello World!",'$'
.code
start: mov ax, @data
       mov ds, ax
       mov dx, offset message
       mov ah, 9
       int 21h
       mov ax, 4Ch
       int 21h
end start
