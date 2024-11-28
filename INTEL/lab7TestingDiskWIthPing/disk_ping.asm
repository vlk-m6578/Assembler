section .data
    disk_name db "/home/milana/projects/test/file.txt", 0
    buffer db 1024 dup('A')

section .bss
    start_time resq 1
    end_time resq 1
    disk_descriptor resq 1

section .text
global open_disk
global write_block
global read_block
global close_disk
global get_time

open_disk:
    ;ОТКРЫТИЕ ДИСКА 
    ;дескриптор - rdi, имя файла - rsi, флаги - rdx, mode - r10
    ;возврат: дескприптор диска - rax
    mov rax, 257 ;syscall for open
    lea rsi, [rel disk_name]
    mov rdx, 2 ;O_RDWR (read/write)
    mov r10, 0 ;no special flags (mode)
    syscall
    mov [rel disk_descriptor], rax

    cmp rax, -1 ;проверка на ошибку
    je open_error
    ret

open_error:
    mov rax, 60 ;syscall для выхода
    mov rdi, 1 ;код ошибки
    syscall

get_time:
    ; ПОЛУЧЕНИЕ ТЕКУЩЕГО ВРЕМЕНИ
    rdtsc 
    shl rdx, 32 
    or rax, rdx 
    ret

    ;mov rax, 228 ;clock_gettime
    ;mov rdi, 0 ;CLOCK_REALTIME 
    ;lea rsi, [rel start_time] ;(структура timespec) - start_time
    ;syscall
    ;ret

write_block:
    ;ЗАПИСЬ БЛОКА НА ДИСК 
    ;дескриптор - rdi, буфер с данными - rsi, количество байт - rdx 
    ;rdi - первый параметр функции (размер блока данных в байтах)
    call get_time
    mov rbx, rax

    mov rax, 1 ;sys_write
    mov rdx, rdi
    mov rdi, [rel disk_descriptor]
    lea rsi, [rel buffer]
    syscall

    ;получаем время после записи
    call get_time
    mov [rel end_time], rax
    mov rax, [rel end_time]
    sub rax, rbx ;вычисляем время записи

    cmp rax, -1 ;проверка на ошибку
    je write_error
    ret

write_error:
    mov rax, 60 ;syscall для выхода
    mov rdi, 2 ;код ошибки
    syscall

read_block:
    ;ЧТЕНИЕ ДАННЫХ С ДИСКА
    ;дескриптор - rdi, буфер - rsi, количество байт - rdx
    call get_time
    mov rbx, rax

    mov rax, 0 ;sys_read
    mov rdx, rdi
    mov rdi, [rel disk_descriptor]
    lea rsi, [rel buffer]
    syscall

    ;получаем время после чтения
    call get_time
    mov [rel end_time], rax
    sub rax, rbx ;вычисляем время чтения

    cmp rax, -1 ;проверка на ошибку
    je read_error
    ret

read_error:
    mov rax, 60 ;syscall для выхода
    mov rdi, 3 ;код ошибки
    syscall

close_disk:
    ;ЗАКРЫТИЕЕ ФАЙЛА
    mov rax, 3 ;syscall для close
    mov rdi, [rel disk_descriptor]
    syscall
    ret

section .note.GNU-stack