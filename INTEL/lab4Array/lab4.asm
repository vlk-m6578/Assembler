.model small
.stack 100h
.data
    mess_error db "Error!", 0Ah, 0Dh, '$'
    mess_incorrectInput db "Incorrect number input!", 0Ah, 0Dh, '$'
    mess_number db "Enter the number of numbers(up to 30): ", '$'  
    mess_enterNumber db "Enter the number: ", '$'  
    mess_increasingSeq db "Increasing sequence of numbers.", 0Ah, 0Dh, '$'
    mess_decreasingSeq db "Decreasing sequence of numbers.", 0Ah, 0Dh, '$'
    mess_randomSeq db "Random sequence of numbers.", 0Ah, 0Dh, '$'
    mess_equalSeq db "All numbers are equal.", 0Ah, 0Dh, '$'
    mess db 0Ah, 0Dh, '$'
    enterNumberBuffer db 10
    enterCountNumbers db ?
    enterNumber db 10 dup('$') 
    numberNumbers db 0
    numberArray dw 30 dup(0)
    
.code
output macro message
    lea dx, message
    mov ah, 09h
    int 21h
endm

mainCompare proc near
        push bp
        mov bp, sp
        mov ax, [bp+6]
        mov bx, [bp+4]
        and ax, 0x8000
        jnz negative
        and bx, 0x8000
        jnz greater
        mov ax, [bp+6]
        mov bx, [bp+4]
        cmp ax, bx
        je equal
        jg greater
        jmp less
        negative:
            and bx, 0x8000
            jz less
            mov ax, [bp+6]
            mov bx, [bp+4]
            cmp ax, bx
            je equal
            jl less
            jmp greater
        greater:
            mov ax, 0x01
            pop bp
            ret 4
        less:
            mov ax, 0x02
            pop bp
            ret 4
        equal:
            xor ax, ax
            pop bp
            ret 4
mainCompare endp

checkNumber proc near
    push bp
    mov bx, offset enterCountNumbers
    mov al, [bx]
    cmp al, 6
    jg incorrectNumber
    cmp al, 0
    je incorrectNumber
    mov bx, offset enterNumber
    mov ah, [bx]
    cmp ah, '-'
    jne positiveNumber
        inc bx
        dec al
    positiveNumber:
        cmp al, 5
        jg incorrectNumber
    startCheck:
        mov ah, [bx]
        cmp ah, 0Dh
        je correctNumber
        cmp ah, '0'
        jl incorrectNumber
        cmp ah, '9'
        jg incorrectNumber
        inc bx
        jmp startCheck
    incorrectNumber:
        mov ax, 0
        pop bp
        ret
    correctNumber:
        mov ax, 1
        pop bp
        ret
checkNumber endp 

transform proc near
        push bp
        xor ax, ax
        xor dx, dx
        xor cx, cx
        mov cx, 10
        mov bx, offset enterNumber
        mov dl, [bx]
        cmp dl, '-'
        jne startTransform_loop
        inc bx
        startTransform_loop:
            mov dl, [bx]
            cmp dl, 0Dh
            je endTransform_loop
            mul cx
            cmp dx, 0 ;check overflow
            jne printIncorrect ;overflow
            mov dl, [bx]
            sub dl, '0'
            add ax, dx
            inc bx
            jmp startTransform_loop
        endTransform_loop:
            mov bx, offset enterNumber
            mov dl, [bx]
            cmp dl, '-'
            jne returnTransform
            xor ax, 0xFFFF ;coma
            inc ax ;+1 in additional code
            push ax
            and ax, 0x8000;1000....0
            jz printIncorrect
            pop ax
            pop bp
            ret
        returnTransform:
            push ax
            and ax, 0x8000
            jnz printIncorrect
            pop ax
            pop bp
            ret    
transform endp 

start:
    mov ax, @data
    mov ds, ax 
    
    output mess_number
    
    mov ah, 0Ah
    mov dx, offset enterNumberBuffer
    int 21h 
    
    output mess 
    
    ;check the count of the numbers
    mov bx, offset enterCountNumbers
    mov ah, [bx]
    cmp ah, 2
    jg error
    cmp ah, 0
    je error 
    
    ;check first symbol
    mov bx, offset enterNumber
    mov ah, [bx]
    cmp ah, '0'
    jl error
    cmp ah, '9'
    jg error
    sub ah, '0'
    inc bx
    cmp [bx], 0Dh
    je next
    
    ;->->->
    mov al, ah
    mov ah, 10
    mul ah
    mov ah, al
    
    cmp [bx], '0'
    jl error
    cmp [bx], '9'
    jg error
    
    ;check second symbol
    add ah, [bx]
    sub ah, '0'
    cmp ah, 30
    jg error
      
    next:
        cmp ah, 2
        jl error
        mov bx, offset numberNumbers
        mov [bx], ah 
        
    mov bx, offset numberNumbers
    mov cx, [bx]
    mov bx, offset numberArray 
    
    startInput_loop:
        cmp cx, 0
        je endInput_loop
           
        output mess_enterNumber
        
        mov ah, 0Ah
        mov dx, offset enterNumberBuffer
        int 21h
        
        output mess
        
        push bx
        push cx
        call checkNumber
        cmp ax, 0
        je printIncorrect
        call transform 
        pop cx
        pop bx
        mov [bx], ax
        inc bx
        inc bx
        dec cx
        jmp startInput_loop
        
    endInput_loop: 
    mov bx, offset numberArray  
    mov cl, [numberNumbers]
    mov ax, [bx]
    mov dx, ax
    
    checkEquality:
    add bx, 2
    dec cx
    cmp cx, 0
    je allEqual

    cmp ax, [bx]
    jne notEqual
    jmp checkEquality

    notEqual:
    jmp contInp

    allEqual:
    jmp printEqual
    
    contInp:
    mov bx, offset numberNumbers
    xor cx, cx
    mov cl, [bx]
    dec cx
    mov bx, offset numberArray
    xor dx, dx
     
    startCompare:
        cmp cx, 0
        je endCompare
        dec cx
        push bx
        mov ax, [bx]
        push ax
        add bx, 2
        mov ax, [bx]
        push ax
        
        
        call mainCompare
        pop bx
        cmp ax, 0x01
        jl printRandomSeq
        je greaterr
        jg lless
        add bx, 2
        jmp startCompare 
        
        greaterr:
            or dx, 0x01
            add bx, 2
            jmp startCompare 
        lless:       
            or dx, 0x02
            add bx, 2
            jmp startCompare 
            
    endCompare:
    cmp dx, 0x01
    je printDecreasingSeq
    cmp dx, 0x02
    je printIncreasingSeq
    jmp printRandomSeq
    
printIncreasingSeq:
    output mess_increasingSeq
    jmp endProg 
    
printDecreasingSeq:
    output mess_decreasingSeq
    jmp endProg
    
printRandomSeq:
    output mess_randomSeq
    jmp endProg 
            
printIncorrect:
    output mess_incorrectInput
    pop cx
    pop bx
    jmp startInput_loop
    ;jmp endProg 

printEqual:
    output mess_equalSeq
    jmp endProg

error:
    output mess_error
    jmp start
    ;jmp endProg
      
endProg:
    mov ah, 4Ch
    int 21h 
    
end start
