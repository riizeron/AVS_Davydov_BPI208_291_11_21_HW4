; file.asm - использование файлов в NASM
extern printf
extern fprintf

extern RealComplex
extern RealFraction
extern RealPolar

extern COMPLEX
extern FRACTION
extern POLAR

;----------------------------------------------
; Вывод параметров комплексного числа в файл
;----------------------------------------------
global OutComplex
OutComplex:
section .data
    .outfmt db "It is Complex: x = %d, y = %d. Real = %g",10,0
section .bss
    .pcomp  resq  1
    .FILE   resq  1       ; временное хранение указателя на файл
    .p      resq  1       ; вычисленное вещественного значение комплексного числа
section .text
push rbp
mov rbp, rsp

    ; Сохранени принятых аргументов
    mov     [.pcomp], rdi          ; сохраняется адрес комплексного чсила
    mov     [.FILE], rsi           ; сохраняется указатель на файл

    ; Вычисление вещественного значения копмдексного числа (адрес уже в rdi)
    call    RealComplex
    movsd   [.p], xmm0          ; сохранение (может лишнее) вещественного значения

    ; Вывод информации о комплексном числе в консоль
;     mov     rdi, .outfmt        ; Формат - 1-й аргумент
;     mov     rax, [.pcomp]       ; адрес косплексного числа
;     mov     esi, [rax]          ; x
;     mov     edx, [rax+4]        ; y
;     movsd   xmm0, [.p]
;     mov     rax, 1              ; есть числа с плавающей точкой
;     call    printf

    ; Вывод информации о комплексном числе в файл
    mov     rdi, [.FILE]
    mov     rsi, .outfmt        ; Формат - 2-й аргумент
    mov     rax, [.pcomp]       ; адрес комплексного числа
    mov     edx, [rax]          ; x
    mov     ecx, [rax+4]        ; y
    movsd   xmm0, [.p]
    mov     rax, 1              ; есть числа с плавающей точкой
    call    fprintf

leave
ret

;----------------------------------------------
; Вывод параметров дроби в файл
;----------------------------------------------
global OutFraction
OutFraction:
section .data
    .outfmt db "It is Fraction: a = %d, b = %d. Real = %g",10,0
section .bss
    .pfrac  resq  1
    .FILE   resq  1       ; временное хранение указателя на файл
    .p      resq  1       ; вычисленное вещественное значение дроби
section .text
push rbp
mov rbp, rsp

    ; Сохранени принятых аргументов
    mov     [.pfrac], rdi         ; сохраняется адрес дроби
    mov     [.FILE], rsi          ; сохраняется указатель на файл

    ; Вычисление вещественного значения дроби (адрес уже в rdi)
    call    RealFraction
    movsd   [.p], xmm0          ; сохранение (может лишнее) вещественного значения

    ; Вывод информации о дроби в консоль
;     mov     rdi, .outfmt        ; Формат - 1-й аргумент
;     mov     rax, [.pfrac]       ; адрес треугольника
;     mov     esi, [rax]          ; числитель
;     mov     edx, [rax+4]        ; знаменатель
;     movsd   xmm0, [.p]
;     mov     rax, 1              ; есть числа с плавающей точкой
;     call    printf

    ; Вывод информации о дроби в файл
    mov     rdi, [.FILE]
    mov     rsi, .outfmt        ; Формат - 2-й аргумент
    mov     rax, [.pfrac]       ; адрес дроби
    mov     edx, [rax]          ; числитель
    mov     ecx, [rax+4]        ; знаменатель
    movsd   xmm0, [.p]
    mov     rax, 1              ; есть числа с плавающей точкой
    call    fprintf

leave
ret

;----------------------------------------------
; Вывод параметров полярной координаты в файл
;----------------------------------------------
global OutPolar
OutPolar:
section .data
    .outfmt db "It is Polar: r = %d, phi = %d. Real = %g",10,0
section .bss
    .ppol  resq  1
    .FILE   resq  1       ; временное хранение указателя на файл
    .p      resq  1       ; вычисленное вещественное значение полярной координаты
section .text
push rbp
mov rbp, rsp

    ; Сохранени принятых аргументов
    mov     [.ppol], rdi          ; сохраняется адрес полярной координаты
    mov     [.FILE], rsi          ; сохраняется указатель на файл

    ; Вычисление вещественного значения полярной координаты (адрес уже в rdi)
    call    RealPolar
    movsd   [.p], xmm0          ; сохранение (может лишнее) вещественного значения

    ; Вывод информации о полярной координате в консоль
;     mov     rdi, .outfmt        ; Формат - 1-й аргумент
;     mov     rax, [.ppol]        ; адрес треугольника
;     mov     esi, [rax]          ; r
;     mov     edx, [rax+4]        ; phi
;     movsd   xmm0, [.p]
;     mov     rax, 1              ; есть числа с плавающей точкой
;     call    printf

    ; Вывод информации о полярной координате в файл
    mov     rdi, [.FILE]
    mov     rsi, .outfmt        ; Формат - 2-й аргумент
    mov     rax, [.ppol]      ; адрес треугольника
    mov     edx, [rax]          ; r
    mov     ecx, [rax+4]        ; phi
    movsd   xmm0, [.p]
    mov     rax, 1              ; есть числа с плавающей точкой
    call    fprintf

leave
ret

;----------------------------------------------
; Вывод параметров текущего числа в файл
;----------------------------------------------
global OutNumber
OutNumber:
section .data
    .erNumber db "Incorrect number!",10,0
section .text
push rbp
mov rbp, rsp

    ; В rdi адрес фигуры
    mov eax, [rdi]
    cmp eax, [COMPLEX]
    je compOut
    cmp eax, [FRACTION]
    je fracOut
    cmp eax, [POLAR]
    je polOut
    mov rdi, .erNumber
    mov rax, 0
    call fprintf
    jmp     return
compOut:
    ; Вывод комплексного числа
    add     rdi, 4
    call    OutComplex
    jmp     return
fracOut:
    ; Вывод дроби
    add     rdi, 4
    call    OutFraction
    jmp     return
polOut:
    ; Вывод полярной координаты
    add     rdi, 4
    call    OutPolar
return:
leave
ret

;----------------------------------------------
;  Вывод содержимого контейнера в файл
;----------------------------------------------
global OutContainer
OutContainer:
section .data
    numFmt  db  "%d: ",0
section .bss
    .pcont  resq    1   ; адрес контейнера
    .len    resd    1   ; адрес для сохранения числа введенных элементов
    .FILE   resq    1   ; указатель на файл
section .text
push rbp
mov rbp, rsp

    mov [.pcont], rdi    ; сохраняется указатель на контейнер
    mov [.len],   esi    ; сохраняется число элементов
    mov [.FILE],  rdx    ; сохраняется указатель на файл

    ; В rdi адрес начала контейнера
    mov rbx, rsi            ; число чисел
    xor ecx, ecx            ; счетчик фигур = 0
    mov rsi, rdx            ; перенос указателя на файл
.loop:
    cmp ecx, ebx            ; проверка на окончание цикла
    jge .return             ; Перебрали все числа

    push rbx
    push rcx

    ; Вывод номера числа
    mov     rdi, [.FILE]    ; текущий указатель на файл
    mov     rsi, numFmt     ; формат для вывода числа
    mov     edx, ecx        ; индекс текущего числа
    xor     rax, rax,       ; только целочисленные регистры
    call fprintf

    ; Вывод текущего числа
    mov     rdi, [.pcont]
    mov     rsi, [.FILE]
    call OutNumber     ; Получение периметра первого числа

    pop rcx
    pop rbx
    inc ecx                 ; индекс следующего числа

    mov     rax, [.pcont]
    add     rax, 16         ; адрес следующего числа
    mov     [.pcont], rax
    jmp .loop
.return:
leave
ret

