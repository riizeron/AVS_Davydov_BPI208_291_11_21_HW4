; file.asm - использование файлов в NASM
extern printf
extern rand

extern COMPLEX
extern POLAR
extern FRACTION 

;--------------------------------------------------------------------
; rnd.c - содержит генератор случайных чисел в диапазоне от 1 до 20
;--------------------------------------------------------------------
global Random
Random:
section .data
    .i20     dq      20
    .rndNumFmt       db "Random number = %d",10,0
section .text
push rbp
mov rbp, rsp

    xor     rax, rax    ;
    call    rand        ; запуск генератора случайных чисел
    xor     rdx, rdx    ; обнуление перед делением
    idiv    qword[.i20]       ; (/%) -> остаток в rdx
    mov     rax, rdx
    inc     rax         ; должно сформироваться случайное число

    ;mov     rdi, .rndNumFmt
    ;mov     esi, eax
    ;xor     rax, rax
    ;call    printf


leave
ret

;----------------------------------------------
; Случайный ввод параметров комплексного числа
;----------------------------------------------
global InRndComplex
InRndComplex:
section .bss
    .pcomp  resq 1   ; адрес комплексного числа
section .text
push rbp
mov rbp, rsp

    ; В rdi адрес комплексного числа
    mov     [.pcomp], rdi
    ; Генерация значений комплексного числа
    call    Random
    mov     rbx, [.pcomp]
    mov     [rbx], eax
    call    Random
    mov     rbx, [.pcomp]
    mov     [rbx+4], eax

leave
ret

;----------------------------------------------
; Случайный ввод параметров дроби
;----------------------------------------------
global InRndFraction
InRndFraction:
section .bss
    .pfrac  resq 1   ; адрес дроби
section .text
push rbp
mov rbp, rsp

    ; В rdi адрес дроби
    mov     [.pfrac], rdi
    ; Генерация числителя и значенателя
    call    Random
    mov     rbx, [.pfrac]
    mov     [rbx], eax
.repeat:
    call    Random
    mov     rbx, [.pfrac]
    mov     [rbx+4], eax
    mov     ebx, eax        ; знамеатель
    cmp     ebx, 0          ; проверка на то что значенатель равен нулю
    je      .repeat

leave
ret

;-----------------------------------------------
; Случайный ввод знаяений полярной координаты
;-----------------------------------------------
global InRndPolar
InRndPolar:
section .bss
    .ppol  resq 1   ; адрес полярной координаты
section .text
push rbp
mov rbp, rsp

    ; В rdi адрес полярной координаты
    mov     [.ppol], rdi
    ; Генерация значений полярной координаты
    call    Random
    mov     rbx, [.ppol]
    mov     [rbx+4], eax    ; угол
.repeat:
    call    Random
    mov     rbx, [.ppol]
    mov     [rbx], eax
    mov     ebx, eax        ; радиус
    cmp     ebx, 0          ; проверка на отрицательность радиуса
    js      .repeat

leave
ret


;----------------------------------------------
; Случайный ввод обобщенного числа
;----------------------------------------------
global InRndNmber
InRndNumber:
section .data
    .keys       dq 3
section .bss
    .pnum       resq    1   ; адрес числа
    .key        resd    1   ; ключ
section .text
push rbp
mov rbp, rsp

    ; В rdi адрес числа
    mov [.pnum], rdi
    
    ; Формирование признака числа
    xor     eax, eax    ;
    call    rand        ; запуск генератора случайных чисел
    
    xor     edx, edx
    idiv    qword[.keys]
    mov     eax, edx      ; очистка результата кроме младшего разряда (0 или 1)
    inc     eax         ; фомирование признака числа (1 или 2 или 3)

    ;mov     [.key], eax
    ;mov     rdi, .rndNumFmt
    ;mov     esi, [.key]
    ;xor     rax, rax
    ;call    printf
    ;mov     eax, [.key]

    mov     rdi, [.pnum]
    mov     [rdi], eax      ; запись ключа в фигуру
    cmp eax, [COMPLEX]
    je .compInRnd
    cmp eax, [FRACTION]
    je .fracInRnd
    cmp eax, [POLAR]
    je .polInRnd
    xor eax, eax        ; код возврата = 0
    jmp     .return
.compInRnd:
    ; Генерация комплексного числав
    add     rdi, 4
    call    InRndComplex
    mov     eax, 1      ;код возврата = 1
    jmp     .return
.fracInRnd:
    ; Генерация дроби
    add     rdi, 4
    call    InRndFraction
    mov     eax, 1      ;код возврата = 1
    jmp     .return
.polInRnd:
    ; Генерация полярной координаты
    add     rdi, 4
    call    InRndPolar
    mov     eax, 1      ;код возврата = 1
.return:
leave
ret

;----------------------------------------------
; Случайный ввод содержимого контейнера
;----------------------------------------------
global InRndContainer
InRndContainer:
section .bss
    .pcont  resq    1   ; адрес контейнера
    .plen   resq    1   ; адрес для сохранения числа введенных элементов
    .psize  resd    1   ; число порождаемых элементов
section .text
push rbp
mov rbp, rsp

    mov [.pcont], rdi   ; сохраняется указатель на контейнер
    mov [.plen], rsi    ; сохраняется указатель на длину
    mov [.psize], edx   ; сохраняется число порождаемых элементов
    ; В rdi адрес начала контейнера
    xor ebx, ebx        ; число чисел = 0
.loop:
    cmp ebx, edx
    jge     .return
    ; сохранение рабочих регистров
    push rdi
    push rbx
    push rdx

    call    InRndNumber     ; ввод числа
    cmp rax, 0          ; проверка успешности ввода
    jle  .return        ; выход, если признак меньше или равен 0

    pop rdx
    pop rbx
    inc rbx

    pop rdi
    add rdi, 32            ; адрес следующего числа

    jmp .loop
.return:
    mov rax, [.plen]    ; перенос указателя на длину
    mov [rax], ebx      ; занесение длины
leave
ret
