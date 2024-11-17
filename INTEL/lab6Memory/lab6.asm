.model small

.data
;VARIABLES  
filename db 80 dup(0)  
cmdLengthFact dw ?
arguments db 120 dup(0)

EPB dw 0                     ;occupied space for EPB
    dw offset commandline, 0  ;ptr for CMD
    dw 005Ch, 0, 006Ch, 0    ;ptrs for FCB
commandline db 125
            db " /?"
size dw ?
 
;MESSAGES
mess_noData db "No data.", 0Ah, 0Dh, '$'    
mess_start db "...start...", 0Ah, 0Dh, '$'
messOK db "OK", 0Ah, 0Dh, '$' 
mess_error db "ERROR", 0Ah, 0Dh, '$'
mess_errorNumber db "The number must be in the range [1; 255].", 0Ah, 0Dh, '$'
mess_errorOpen db "Don't open!", 0Ah, 0Dh, '$'  
mess_error02h db "ERROR(02h): the file was not found.", 0Ah, 0Dh, '$'  
mess_error05h db "ERROR(05h): access to the file is denied.", 0Ah, 0Dh, '$'
mess_error08h db "ERROR(08h): not enough memory.", 0Ah, 0Dh, '$'
mess_error0Ah db "ERROR(0Ah): the wrong environment.", 0Ah, 0Dh, '$'
mess_error0Bh db "ERROR(0Bh): incorrect format.", 0Ah, 0Dh, '$'
mess_click db 0Ah,0Dh,"Click...$"
dsize dw $-filename

 
.stack 256
.code         
;MACROS
display macro str
    push dx
    push ax  
    lea dx, str
    mov ah, 09h
    int 21h
    pop ax 
    pop dx
endm

;PROCEDURES  
sizeInput proc
    lea di, arguments
    xor ax, ax
    xor bx, bx
    
parseLoop:
    mov bl, [di]
    cmp bl, 0Dh
    je endParsee
    cmp bl, 0
    je endParsee
    cmp bl, '0'
    jb invalidInput
    cmp bl, '9'
    ja invalidInput
    
    sub bl, '0'
    mov cx, 10
    mul cx
    add ax, bx
    
    inc di
    jmp parseLoop
    
invalidInput:
    jmp endParsee
endParsee:
    mov size, ax
    ret
sizeInput endp      

;define fileName and arguments
get_name proc
    push ax  
    push cx
    push di
    push si
   
    xor cx, cx
    mov cl, es:[80h]  ;get count of symbols
    mov cmdLengthFact, cx
    cmp cl, 0
    je endParse
    
    mov di, 82h       ;start PSP
    lea si, filename
    
cicle1:
    mov al, es:[di]   
    cmp al, ' '       
    je end_get_name
    cmp al, 0Dh
    je endParse
    mov [si], al      
    inc di            
    inc si            
    jmp cicle1 

end_get_name: 
    mov [si], 0
    inc di 
    lea si, arguments
    
cycle2: 
    mov al, es:[di]
    cmp al, ' '
    je skip
    cmp al, 0Dh
    je endParse
    mov [si], al
    inc di
    inc si
    jmp cycle2
    
skip:
    mov al, es:[di]
    cmp al, ' '
    je skip
    cmp al, 0Dh
    je endParse
    
    lea si, arguments
    mov [si], 0
    
endParse:
    dec si       
    lea si, arguments
    
    pop si            
    pop di
    pop cx
    pop ax   
    ret
get_name endp

 
start:
    mov ax, @data            
    mov ds, ax  
    
    ;get arguments of CMD
    call get_name
    ;check CMD
    mov ax, cmdLengthFact
    cmp ax, 1
    jle noData

    display mess_start
    ;convert to decimal
    call sizeInput
    ;check number
    mov ax, size
    cmp ax, 1
    jl errorNumber
    cmp ax, 255
    jg errorNumber

    ;mov ax, 03
    ;int 10h
    
    ;stack setup and memory allocation    
    mov sp, csize + 100h + 200h            
    mov ah, 4ah   
    mov bx, (csize/16)+256/16+(dsize/16)+20
    int 21h           
    jc er  ;check flags  

    mov ax, cs  
    ;fill EPB
    mov word ptr EPB+02h, ax   
    mov word ptr EPB+06h, ax   
    mov word ptr EPB+0Ah, ax 
    
    mov cx, size
         
openProgram:
    ;mov ah, 02h
    ;mov dl, cl
    ;int 21h
         
    mov ax, 4B00h       
    lea dx, filename    
    lea bx, EPB         
    int 21h
    jc  erOpen
    loop openProgram

click: 
    display mess_click
    mov ah, 1                
    int 21h
    mov ax, 4C00h            
    int 21h
noData:
    display mess_noData
    jmp click
er: 
    display mess_error
    jmp click
erOpen:
    display mess_errorOpen
    cmp ax, 02h
    je error02h
    cmp ax, 05h
    je error05h
    cmp ax, 08h
    je error08h
    cmp ax, 0Ah
    je error0Ah
    cmp ax, 0Bh
    je error0Bh 
error02h: 
    display mess_error02h
    jmp click
error05h: 
    display mess_error05h
    jmp click
error08h: 
    display mess_error08h
    jmp click
error0Ah: 
    display mess_error0Ah
    jmp click
error0Bh: 
    display mess_error0Bh
    jmp click
errorNumber:
    display mess_errorNumber
    jmp click   
csize dw $-start 
end start