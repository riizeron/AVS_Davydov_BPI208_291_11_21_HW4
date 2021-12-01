; file.asm - использование файлов в NASM
extern printf
extern fscanf
extern fprintf

extern COMPLEX
extern FRACTION
extern POLAR

;----------------------------------------------
;  Ввод параметров комплексного числа из файла
;----------------------------------------------
global InComplex
InComplex:
section .data
    .infmt db "%d%d",0
section .bss
    .FILE   resq    1   ; временное хранение указателя на файл
    .comp  resq    1   ; адрес комплексного числа
section .text
push rbp
mov rbp, rsp

    ; Сохранение принятых аргументов
    mov     [.comp], rdi          ; сохраняется адрес комплексного числа
    mov     [.FILE], rsi          ; сохраняется указатель на файл

    ; Ввод комплексного числа из файла
    mov     rdi, [.FILE]
    mov     rsi, .infmt         ; Формат - 1-й аргумент
    mov     rdx, [.comp]        ; &x
    mov     rcx, [.comp]
    add     rcx, 4              ; &y = &x + 4
    mov     rax, 0              ; нет чисел с плавающей точкой
    call    fscanf

leave
ret

;-------------------------------------------
; Ввод параметров треугольника из файла
;-------------------------------------------
global InFraction
InFraction:
section .data
    .infmt db "%d%d%d",0
section .bss
    .FILE   resq    1   ; временное хранение указателя на файл
    .frac   resq    1   ; адрес дроби
section .text
push rbp
mov rbp, rsp

    ; Сохранение принятых аргументов
    mov     [.frac], rdi          ; сохраняется адрес дроби
    mov     [.FILE], rsi          ; сохраняется указатель на файл

    ; Ввод дроби из файла
    mov     rdi, [.FILE]
    mov     rsi, .infmt         ; Формат - 1-й аргумент
    mov     rdx, [.frac]        ; &a
    mov     rcx, [.frac]
    add     rcx, 4              ; &b = &a + 4
    mov     rax, 0              ; нет чисел с плавающей точкой
    call    fscanf

leave
ret

;------------------------------------
; Ввод полярной координаты из файла
;------------------------------------
global InPolar
InPolar:
section .data
    .infmt db "%d%d%d",0
section .bss
    .FILE   resq    1   ; временное хранение указателя на файл
    .pol    resq    1   ; адрес полярной коорддинаты
section .text
push rbp
mov rbp, rsp

    ; Сохранение принятых аргументов
    mov     [.pol], rdi           ; сохраняется адрес полярной координаты
    mov     [.FILE], rsi          ; сохраняется указатель на файл

    ; Ввод полярной координаты из файла
    mov     rdi, [.FILE]
    mov     rsi, .infmt         ; Формат - 1-й аргумент
    mov     rdx, [.pol]         ; &r
    mov     rcx, [.pol]
    add     rcx, 4              ; &phi = &r + 4
    mov     rax, 0              ; нет чисел с плавающей точкой
    call    fscanf

leave
ret

;----------------------------------------------
; Ввод параметров обобщенного числа из файла
;----------------------------------------------
global InNumber
InNumber:
section .data
    .tagFormat   db      "%d",0
    .tagOutFmt   db      "Tag is: %d",10,0
section .bss
    .FILE       resq    1   ; временное хранение указателя на файл
    .pnum       resq    1   ; адрес числа
    .numTag     resd    1   ; признак числа
section .text
push rbp
mov rbp, rsp

    ; Сохранение принятых аргументов
    mov     [.pnum], rdi            ; сохраняется адрес числа
    mov     [.FILE], rsi            ; сохраняется указатель на файл

    ; чтение признака числа и его обработка
    mov     rdi, [.FILE]
    mov     rsi, .tagFormat
    mov     rdx, [.pnum]        ; адрес начала числа (ее признак)
    xor     rax, rax            ; нет чисел с плавающей точкой
    call    fscanf

    ; Тестовый вывод признака фигуры
;     mov     rdi, .tagOutFmt
;     mov     rax, [.pshape]
;     mov     esi, [rax]
;     call    printf

    mov rcx, [.pnum]            ; загрузка адреса начала числа
    mov eax, [rcx]              ; и получение прочитанного признака
    cmp eax, [COMPLEX]
    je .compIn
    cmp eax, [FRACTION]
    je .fracIn
    cmp eax, [POLAR]
    je .polIn
    xor eax, eax                ; Некорректный признак - обнуление кода возврата
    jmp     .return
.compIn:
    ; Ввод комплексного числа
    mov     rdi, [.pnum]
    add     rdi, 4
    mov     rsi, [.FILE]
    call    InComplex
    mov     rax, 1  ; Код возврата - true
    jmp     .return
.fracIn:
    ; Ввод дроби
    mov     rdi, [.pnum]
    add     rdi, 4
    mov     rsi, [.FILE]
    call    InFraction
    mov     rax, 1  ; Код возврата - true
    jmp     .return
.polIn:
    ; Ввод полярной координаты
    mov     rdi, [.pnum]
    add     rdi, 4
    mov     rsi, [.FILE]
    call    InPolar
    mov     rax, 1  ; Код возврата - true
.return:

leave
ret

;----------------------------------------------------
; Ввод содержимого контейнера из указанного файла
;----------------------------------------------------
global InContainer
InContainer:
section .bss
    .pcont  resq    1   ; адрес контейнера
    .plen   resq    1   ; адрес для сохранения числа введенных элементов
    .FILE   resq    1   ; указатель на файл
section .text
push rbp
mov rbp, rsp

    mov [.pcont], rdi   ; сохраняется указатель на контейнер
    mov [.plen], rsi    ; сохраняется указатель на длину
    mov [.FILE], rdx    ; сохраняется указатель на файл
    ; В rdi адрес начала контейнера
    xor rbx, rbx        ; число чисел = 0
    mov rsi, rdx        ; перенос указателя на файл
.loop:
    ; сохранение рабочих регистров
    push rdi
    push rbx

    mov     rsi, [.FILE]
    mov     rax, 0      ; нет чисел с плавающей точкой
    call    InNumber    ; ввод числа
    cmp rax, 0          ; проверка успешности ввода
    jle  .return        ; выход, если признак меньше или равен 0

    pop rbx
    inc rbx

    pop rdi
    add rdi, 16             ; адрес следующего числа

    jmp .loop
.return:
    mov rax, [.plen]    ; перенос указателя на длину
    mov [rax], ebx      ; занесение длины
leave
ret

