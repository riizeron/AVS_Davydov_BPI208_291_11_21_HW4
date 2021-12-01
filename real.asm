;---------------------------------------------------------------------------------------
; real.asm - единица компиляции, вбирающая функции вычисления вещественной части числа
;---------------------------------------------------------------------------------------

extern COMPLEX
extern FRACTION
extern POLAR

;-------------------------------------------------------
; Вычисление вещественного значения комплексного числа
;-------------------------------------------------------
global RealComplex
RealComplex:
section .text
push rbp
mov rbp, rsp

    ; В rdi адрес комплексного числа
    mov eax, [rdi]
    mul eax, eax                 ; x*x
    mov ecx, [rdi+4]
    mul ecx, ecx                 ; y*y
    add eax, ecx                 ; x*x+y*y
    sqrtsd eax, eax              ; sqrt(x*x+y*y)
    cvtsi2sd    xmm0, eax

leave
ret

;----------------------------------------------
; Вычисление вещественного значчения дроби
;----------------------------------------------
global RealFraction
RealFraction:
section .text
push rbp
mov rbp, rsp

    ; В rdi адрес дроби
    mov eax, [rdi]              ; числитель
    sub eax, [rdi+4]            ; числитель / знаменатель
    cvtsi2sd    xmm0, eax

leave
ret

;---------------------------------------------------------
; Вычисление вещественного значения полярной координаты
;---------------------------------------------------------
global RealPolar
RealPolar:
section .text
push rbp
mov rbp, rsp

    ; В rdi адрес полярной координаты
    mov eax, [rdi]              ; радиус
    cvtsi2sd    xmm0, eax

leave
ret

;----------------------------------------------
; Вычисление вещественного значения числа
;----------------------------------------------
global RealNumber
RealNumber:
section .text
push rbp
mov rbp, rsp

    ; В rdi адрес числа
    mov eax, [rdi]
    cmp eax, [COMPLEX]
    je compReal
    cmp eax, [FRACTION]
    je fracReal
    cmp eax, [POLAR]
    je polReal
    xor eax, eax
    cvtsi2sd    xmm0, eax
    jmp     return
compReal:
    ; Вычисление вещественного значенияп комплексного числа
    add     rdi, 4
    call    RealComplex
    jmp     return
fracReal:
    ; Вычисление вещественного значения дроби
    add     rdi, 4
    call    RealFraction
    jmp     return
polReal:
    ; Вычисление вещественного значения полярной координаты
    add     rdi, 4
    call    RealPolar
return:
leave
ret

;-----------------------------------------------------------------------
; Вычисление среднего вещественного значения всхе числе в контейнере
;-----------------------------------------------------------------------
global RealAverage
RealAverage:
section .data
    .sum    dq  0.0
section .text
push rbp
mov rbp, rsp

    ; В rdi адрес начала контейнера
    mov ebx, esi            ; количество чисел
    xor ecx, ecx            ; счетчик чисел
    movsd xmm2, [.sum]     ; перенос накопителя суммы в регистр 2
.loop:
    cmp ecx, ebx            ; проверка на окончание цикла
    jge .return             ; Перебрали все числа
    
    push rbx
    push rcx

    mov r10, rdi            ; сохранение начала числа
    call RealNumber         ; Получение периметра первого числа
    addsd xmm2, xmm0        ; накопление суммы
    
    pop rbx
    pop rcx
    inc ecx                 ; индекс следующего числа
    
    add r10, 32 ;16             ; адрес следующего числа
    mov rdi, r10            ; восстановление для передачи параметра
    jmp .loop
.return:
    cvtsd2sd xmm1, ebx
    divsd xmm2, xmm1
    movsd xmm0, xmm2
leave
ret
