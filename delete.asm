extern RealNumber

extern COMPLEX
extern FRACTION
extern POLAR

%include "macros.mac"

global DeleteContainerElements
DeleteContainerElements:
section .data
    .ten   dq  10.0
section .bss
    .pcont              resq    1   ; адрес контейнера
    .len                resq    1   ; адрес для сохранения числа введенных элементов
    .averageReal        resq    1   ; 
    .real               resq    1   ; вычисленная вещественная часть
    .newCont            resq    1   ;
    .newLen             resq    1   ; 
section .text
push rbp
mov rbp, rsp

    mov     [.pcont], rdi               ; сохраняется указатель на контейнер
    mov     [.len], esi                 ; сохраняется число элементов
    movsd   [.averageReal], xmm0        ; сохраняется указатель на среднее арифметическое вещественных значений

    ; В rdi адрес начала контейнера
    mov     ebx, esi        ; число цифр
    xor     ecx, ecx        ; счетчик цифр

    xor     rsi, rsi
    mov     [.newCont], rdx
    mov     [.newLen], rsi

.loop:
    cmp     ecx, ebx        ; проверка на окончание цикла
    jge     .return         ; перебрали все цифры

    push rbx
    push rcx

    mov     r10, rdi                    ; сохранение начала цифры
    mov     rdi, [.pcont]
    call    RealNumber                  ; получение вещественного значения числа
    movsd   [.real], xmm0               ; сохранение вещественного значения
    movsd   xmm1, [.averageReal]             
    comisd  xmm0, xmm1                  ; проверка на превосходство над средним значением
    jbe    .delete
    jmp    .countNewLength

.nextNumber:
    pop rcx
    pop rbx
    inc ecx

    mov rdi, [.pcont]
    add rdi, 32             ; адрес следующей цифры
    mov [.pcont], rdi
    jmp .loop

.delete:
    mov edi, [.pcont]
    lea eax, [edi-4]
    mov [edi], eax          ; удаление
    add edi, 4
    jmp .nextNumber

.countNewLength:
    mov rsi, [.newLen]
    inc rsi
    mov [.newLen], rsi
    jmp .nextNumber

.return:
    mov rsi, [.newLen]
leave
ret