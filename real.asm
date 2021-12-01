;---------------------------------------------------------------------------------------
; real.asm - единица компиляции, вбирающая функции вычисления вещественной части числа
;---------------------------------------------------------------------------------------

extern COMPLEX
extern FRACTION
extern POLAR        

extern printf

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
    imul eax, eax                 ; x*x
    mov ecx, [rdi+4]
    imul ecx, ecx                 ; y*y
    add eax, ecx 
    cvtsi2sd xmm0, eax            ; x*x+y*y
    sqrtsd xmm0, xmm0             ; sqrt(x*x+y*y)

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
    mov edx, [rdi+4]
    cvtsi2sd    xmm0, eax
    cvtsi2sd    xmm1, edx  
    divsd xmm0, xmm1                ; числитель / знаменатель

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
global ContainerRealAverage
ContainerRealAverage:
section .data
    .sum    dq  0.0   
section .text
push rbp
mov rbp, rsp

    ; В rdi адрес начала контейнера
    mov     ebx, esi        ; число фигур
    xor     ecx, ecx        ; счетчик фигур
    movsd   xmm2, [.sum]    ; перенос накопителя суммы в регистр 2

.loop:
    cmp     ecx, ebx        ; проверка на окончание цикла
    jge     .return         ; перебрали все фигуры

    push rbx
    push rcx

    mov     r10, rdi        ; сохранение начала фигуры
    call    RealNumber  ; получение периметра фигуры
    addsd   xmm2, xmm0      ; накопление суммы периметров

    pop rcx
    pop rbx
    inc ecx

    add     r10, 32         ; адрес следующей фигуры
    mov     rdi, r10        ; восстановление для передачи параметра
    jmp     .loop
.return:
    cvtsi2sd    xmm1, ebx
    divsd   xmm2, xmm1
    movsd   xmm0, xmm2
leave
ret
