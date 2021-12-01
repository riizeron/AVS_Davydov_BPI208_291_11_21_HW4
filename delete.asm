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
    .pcontainer         resq    1   ; адрес контейнера
    .length             resq    1   ; адрес для сохранения числа введенных элементов
    .averageReal        resq    1   ; 
    .real               resq    1   ; вычисленная вещественная часть
    .newContainer       resq    1   ;
    .newLength          resq    1   ; 
section .text
push rbp
mov rbp, rsp

    mov     [.pcontainer], rdi          ; сохраняется указатель на контейнер
    mov     [.length], esi              ; сохраняется число элементов
    movsd   [.averageReal], xmm0        ; сохраняется указатель на среднее арифметическое вещественных значений

    ; В rdi адрес начала контейнера
    mov     ebx, esi        ; число цифр
    xor     ecx, ecx        ; счетчик цифр

    xor     rsi, rsi
    mov     [.newContainer], rdx
    mov     [.newLength], rsi

.loop:
    cmp     ecx, ebx        ; проверка на окончание цикла
    jge     .return         ; перебрали все цифры

    push rbx
    push rcx

    mov     r10, rdi                    ; сохранение начала цифры
    mov     rdi, [.pcontainer]
    call    RealNumber                  ; получение вещественного значения числа
    movsd   [.real], xmm0               ; сохранение вещественного значения
    subsd   xmm0, [.averageReal]        ; находим разницу вещественного значения числа и среднего вещественного значения всех фигур
    mulsd   xmm0, [.ten]                ; умножаем на 10, чтобы точно была ненулевая целая часть
    cvtsd2si eax, xmm0                  ; берём целую часть от разницы вещественных значений

    cmp     eax, 0                      ; если вещественное значение больше 0, то добавляем цифру                       
    jl     .delete
    jmp    .countNewLength

.nextNumber:
    pop rcx
    pop rbx
    inc ecx

    mov rdi, [.pcontainer]
    add rdi, 32             ; адрес следующей цифры
    mov [.pcontainer], rdi
    jmp .loop

.delete:
    mov edi, [.pcontainer]
    lea eax, [edi-4]
    mov [edi], eax          ; удаление
    add edi, 4
    jmp .nextNumber

.countNewLength:
    mov rsi, [.newLength]
    inc rsi
    mov [.newLength], rsi
    jmp .nextNumber

.return:
    mov rsi, [.newLength]
    
leave
ret