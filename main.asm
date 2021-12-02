;------------------------------------------------------------------------------
; main.asm - содержит главную функцию,
; обеспечивающую простое тестирование
;------------------------------------------------------------------------------
; main.asm

global  COMPLEX
global  FRACTION
global  POLAR

extern InRndContainer
extern DeleteContainerElements
extern ContainerRealAverage

%include "macros.mac"

section .data
    COMPLEX     dd  1
    FRACTION    dd  2
    POLAR       dd  3
    oneDouble   dq  1.0
    erMsg1  db "Incorrect number of arguments = %d: ",10,0
    rndGen  db "-n",0
    fileGen  db "-f",0
    errMessage1 db  "incorrect command line!", 10,"  Waited:",10
                db  "     command -f infile outfile01 outfile02",10,"  Or:",10
                db  "     command -n number outfile01 outfile02",10,0
    errMessage2 db  "incorrect qualifier value!", 10,"  Waited:",10
                db  "     command -f infile outfile01 outfile02",10,"  Or:",10
                db  "     command -n number outfile01 outfile02",10,0
    len         dd  0           ; Количество элементов в массиве
section .bss
    argc        resd    1
    num         resd    1
    averageReal         resq    1
    start       resq    1       ; начало отсчета времени
    delta       resq    1       ; интервал отсчета времени
    startTime   resq    2       ; начало отсчета времени
    endTime     resq    2       ; конец отсчета времени
    deltaTime   resq    2       ; интервал отсчета времени
    ifst        resq    1       ; указатель на файл, открываемый файл для чтения чисел
    ofst1       resq    1       ; указатель на файл, открываемый файл для записи контейнера
    ofst2       resq    1       ; указатель на файл, открываемый файл для записи вещественного значения
    cont        resb    160000  ; Массив используемый для хранения данных

section .text
    global main
main:
push rbp
mov rbp,rsp

    mov dword [argc], edi ;rdi contains number of arguments
    mov r12, rdi ;rdi contains number of arguments
    mov r13, rsi ;rsi contains the address to the array of arguments

.printArguments:
    PrintStrLn "The command and arguments:", [stdout]
    mov rbx, 0
.printLoop:
    PrintStrBuf qword [r13+rbx*8], [stdout]
    PrintStr    10, [stdout]
    inc rbx
    cmp rbx, r12
    jl .printLoop

    PrintStrLn  "", [stdout]

    cmp r12, 5      ; проверка количества аргументов
    je .start
    PrintStrBuf errMessage1, [stdout]
    jmp .return
.start:
    ; время начала
    mov rax, 228
    xor edi, edi
    lea rsi, [startTime]
    syscall

    
    PrintStrLn "Start", [stdout]
    ; Проверка второго аргумента
    mov rdi, rndGen     ; признак для сравнения
    mov rsi, [r13+8]    ; второй аргумент командной строки
    call strcmp
    cmp rax, 0
    je .next2
    mov rdi, fileGen
    mov rsi, [r13+8]
    call strcmp
    cmp rax, 0
    je .next3
    PrintStrBuf errMessage2, [stdout]
    jmp .return
    
.next2:
    ; Генерация случайных чисел
    mov rdi, [r13+16]
    call atoi
    mov [num], eax
    mov eax, [num]
    cmp eax, 1
    jl .fall1
    cmp eax, 10000
    jg .fall1

    ; Начальная установка генератора случайных чисел
    xor     rdi, rdi
    xor     rax, rax
    call    time
    mov     rdi, rax
    xor     rax, rax
    call    srand
    ; Заполнение контейнера случайными фигурами
    mov     rdi, cont   ; передача адреса контейнера
    mov     rsi, len    ; передача адреса для длины
    mov     edx, [num]  ; передача количества порождаемых фигур
    call    InRndContainer
    jmp     .checkLen

.next3:
    ; Получение чисел из файла
    FileOpen [r13+16], "r", ifst
    ; Заполнение контейнера числами из файла
    mov     rdi, cont           ; адрес контейнера
    mov     rsi, len            ; адрес для установки числа элементов
    mov     rdx, [ifst]         ; указатель на файл
    xor     rax, rax
    call    InContainer         ; ввод данных в контейнер
    FileClose [ifst]
    jmp .checkLen

.checkLen:
    mov     eax, [len]
    cmp     eax, 1
    jl      .fall1
    cmp     eax, 10000
    jg      .fall1
    jmp     .task2

.task2:
    AverageReal cont, [len], [averageReal]
    ; Вывод содержимого контейнера
    PrintStrLn "Filled container:", [stdout]
    PrintStr "Container contains ", [stdout]
    PrintInt [len], [stdout]
    PrintStrLn " elements.", [stdout]
    PrintContainer cont, [len], [stdout]
    PrintStrLn "", [stdout]

    FileOpen [r13+24], "w", ofst1
    PrintStrLn "Filled container:", [ofst1]
    PrintStr "Container contains ", [ofst1]
    PrintInt [len], [ofst1]
    PrintStrLn " elements.", [ofst1]
    PrintContainer cont, [len], [ofst1]
    PrintStrLn "", [ofst1]
    PrintStr    "Average real = ", [ofst1]
    PrintDouble [averageReal], [ofst1]
    PrintStrLn "", [ofst1]
    PrintStr    "--Calculaton time = ", [ofst1]
    PrintLLUns  [deltaTime], [ofst1]
    PrintStr    " sec, ", [ofst1]
    PrintLLUns  [deltaTime+8], [ofst1]
    PrintStr    " nsec", [ofst1]
    PrintStr    10, [ofst1]
    FileClose [ofst1]

.deleteElemsFromCont:
    
    DeleteContainerNumbers cont, [len], [averageReal]
    mov [len], rsi

    ; Вычисление времени завершения
    mov rax, 228   ; 228 is system call for sys_clock_gettime
    xor edi, edi   ; 0 for system clock (preferred over "mov rdi, 0")
    lea rsi, [endTime]
    syscall        ; [time] contains number of seconds
                   ; [time + 8] contains number of nanoseconds


    
    ; Получение времени работы
    mov rax, [endTime]
    sub rax, [startTime]
    mov rbx, [endTime+8]
    mov rcx, [startTime+8]
    cmp rbx, rcx
    jge .subNanoOnly
    ; иначе занимаем секунду
    dec rax
    add rbx, 1000000000
.subNanoOnly:
    sub rbx, [startTime+8]
    mov [deltaTime], rax
    mov [deltaTime+8], rbx

    ; Вывод вещественного значения нескольких чисел
    PrintStrLn  "", [stdout]
    PrintStrLn  "Container after deleting numbers:", [stdout]
    PrintStr "Container contains ", [stdout]
    PrintInt [len], [stdout]
    PrintStrLn " elements.", [stdout]
    PrintContainer cont, [len], [stdout]
    PrintStrLn  "", [stdout]
    PrintStr   "Average real = ", [stdout]
    PrintDouble [averageReal], [stdout]
    PrintStrLn "", [stdout]
    PrintStr    "--Calculaton time = ", [stdout]
    PrintLLUns  [deltaTime], [stdout]
    PrintStr    " sec, ", [stdout]
    PrintLLUns  [deltaTime+8], [stdout]
    PrintStr    " nsec", [stdout]
    PrintStr    10, [stdout]

    FileOpen    [r13+32], "w", ofst2
    PrintStrLn  "Container after deleting numbers:", [ofst2]
    PrintStr "Container contains ", [ofst2]
    PrintInt [len], [ofst2]
    PrintStrLn " elements.", [ofst2] 
    PrintContainer cont, [len], [ofst2]
    PrintStrLn    "Average real = ", [ofst2]
    PrintDouble [averageReal], [ofst2]
    PrintStrLn "", [ofst2]
    PrintStr    "--Calculaton time = ", [ofst2]
    PrintLLUns  [deltaTime], [ofst2]
    PrintStr    " sec, ", [ofst2]
    PrintLLUns  [deltaTime+8], [ofst2]
    PrintStr    " nsec", [ofst2]
    PrintStr    10, [ofst2]
    FileClose   [ofst2]

    PrintStrLn "Stop", [stdout]
    jmp .return
.fall1:
    PrintStr "incorrect numer of numbers = ", [stdout]
    PrintInt [num], [stdout]
    PrintStrLn ". Set 0 < number <= 10000", [stdout]
.return:
leave
ret
