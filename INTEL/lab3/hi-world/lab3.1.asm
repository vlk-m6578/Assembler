name "hi-world"

.model tiny 
.code
org 100h 
 mov ah,9 
 mov dx,offset message 
 int 21h 
 ret 
message db "Hello World!",'$' 
