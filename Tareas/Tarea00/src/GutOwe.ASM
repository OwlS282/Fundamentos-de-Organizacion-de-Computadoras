; --------------------------------------------------------------------
; Tarea de ASM: Numeraciones en ASM
; Curso:        Fundamentos de Organizacion de Computadoras
; Grupo:        02
; Profesor:     Kirstein Gatjens Soto
; Estudiante:   Owel Jafet Gutierrez Ortiz
; Carne:        2026800869
; Archivo:      GutOwe.ASM
; Entrega:      20/11/2026
; --------------------------------------------------------------------


; --------------------------------------------------------------------
; MANUAL DE USUARIO
; --------------------------------------------------------------------
;
; DESCRIPCION
;    GutOwe convierte un numero natural de una numeracion a otra.
;    Trabaja con numeros de 16 bits sin signo (de 0 a 65535) y con
;    exactamente seis numeraciones: Numedrez, Vocumero, Virtumero,
;    Gasumero, Tengwar y Vesteroena.
;
; REQUISITOS
;    DOSBox con TASM 3.2 y TLINK 3.01 en la carpeta montada.
;
; COMO ENSAMBLAR Y ENLAZAR
;      tasm GutOwe
;      tlink GutOwe
;
; COMO EJECUTARLO
;    GutOwe <fuente><destino> <numero>
;
;    fuente   Letra MAYUSCULA de la numeracion en que viene el numero.
;    destino  Letra MAYUSCULA de la numeracion a la que se convierte.
;             Las dos letras van juntas, sin espacio entre ellas.
;    numero   Digitos (en MINUSCULA) de la numeracion fuente, separados
;             de las letras por al menos un espacio.
;
;    Sin parametros, el programa muestra la ayuda y termina.
;
; NUMERACIONES DISPONIBLES
;    El primer digito de cada lista vale 0, el segundo 1, y asi
;    sucesivamente.
;
;    Letra  Numeracion   Base  Digitos
;    N      Numedrez     6     p a c t d r
;    A      Vocumero     5     o i u e a
;    V      Virtumero    7     d x p c t g h
;    G      Gasumero     11    h e n o f m c a k x r
;    T      Tengwar      12    m i a n c l e o t r s q
;    K      Vesteroena   15    t l y b a s u g m h w r d f x
;
; SALIDA DEL PROGRAMA
;    Cuando no se muestra la ayuda, el programa imprime:
;      - Dos renglones de "acerca de" y una linea en blanco.
;      - Tres renglones con el resultado: el numero en la numeracion
;        fuente, el numero en decimal y el numero en la numeracion
;        destino.
;
; EJEMPLOS
;      C:\> GutOwe NG ptc
;      Numedrez: ptc
;      Decimal: 20
;      Gasumero: ex
;
;      C:\> GutOwe KN bl
;      Vesteroena: bl
;      Decimal: 46
;      Numedrez: aad
;
;      C:\> GutOwe AG aoaaiuo
;      Vocumero: aoaaiuo
;      Decimal: 65535
;      Gasumero: fmnck
;
; MENSAJES DE ERROR
;    Se muestran despues del "acerca de" y el programa termina.
;
;    Syntax error
;      La linea de comandos esta mal escrita. Ocurre cuando una letra
;      de numeracion no es una de las seis, esta en minuscula, falta
;      el espacio, falta el numero, o sobra texto despues del numero.
;      Ejemplos:  GutOwe NX ptc    GutOwe ng ptc    GutOwe NGptc
;                 GutOwe NG        GutOwe NG ptc extra
;
;    Invalid digit for the source numbering
;      El numero contiene un caracter que no es digito de la
;      numeracion fuente (por ejemplo una letra en mayuscula).
;      Ejemplo:  GutOwe NG pxc   (la x no es un digito de Numedrez)
;
;    Overflow while representing the number
;      El numero no cabe en 16 bits sin signo (es mayor que 65535).
;      Ejemplo:  GutOwe AG aoaaiui   (equivale a 65536)
;
; 9. NOTAS
;    - Los ceros a la izquierda se aceptan, pero no se muestran en el
;      resultado: GutOwe NN pa da "a" en la numeracion destino.
;    - Se permiten varios espacios entre las letras y el numero.
;    - Si el numero tiene un digito invalido y ademas es demasiado
;      grande, se informa el digito invalido.
; --------------------------------------------------------------------

; --------------------------------------------------------------------
; SEGMENTO DE DATOS
; --------------------------------------------------------------------
dataSegment Segment

    ; digitos de cada numeracion (la posicion de cada letra = su valor)
    baseN db 'pactdr', 0            ; Numedrez, base 6
    baseA db 'oiuea', 0             ; Vocumero, base 5
    baseV db 'dxpctgh', 0           ; Virtumero, base 7
    baseG db 'henofmcakxr', 0       ; Gasumero, base 11
    baseT db 'miancleotrsq', 0      ; Tengwar, base 12
    baseK db 'tlybasugmhwrdfx', 0   ; Vesteroena, base 15

    ; nombres que se imprimen en la salida
    nameN db 'Numedrez$'
    nameA db 'Voc', 0A3h, 'mero$'
    nameV db 'Virt', 0A3h, 'mero$'
    nameG db 'Gas', 0A3h, 'mero$'
    nameT db 'Tengwar$'
    nameK db 'Vesteroena$'

    ; tabla de numeraciones: registros de 6 bytes
    ;   +0 letra (db)  +1 base (db)  +2 digitos (dw)  +4 nombre (dw)
    numberTable db 'N', 6
                dw offset baseN, offset nameN
                db 'A', 5
                dw offset baseA, offset nameA
                db 'V', 7
                dw offset baseV, offset nameV
                db 'G', 11
                dw offset baseG, offset nameG
                db 'T', 12
                dw offset baseT, offset nameT
                db 'K', 15
                dw offset baseK, offset nameK

    ; variables del programa
    source              dw 0            ; direccion del registro de la numeracion fuente
    target              dw 0            ; direccion del registro de la numeracion destino
    numberValue         dw 0            ; el numero ya convertido a binario (16 bits)
    isOverflow          dw 0            ; 1 si el numero no cabe en 16 bits
    errorcodeSegment    dw 0            ; 0 ok, 1 sintaxis, 2 digito, 3 overflow
    sourceText          db 128 dup(0)   ; el numero como se digito
    targetText          db 20 dup(0)    ; el resultado en la base destino

    ; mensajes
    msgLineBreak    db 13, 10, '$'
    msgSeparator    db ': $'
    msgDecimalLabel db 'Decimal: $'

    ; acerca de: dos renglones y una linea en blanco
    msgAbout        db 'Numbering Converter - Short ASM Assignment', 13, 10
                    db 'Owel Jafet Guti', 82h, 'rrez Ortiz - Carnet: 2026800869', 13, 10
                    db 13, 10, '$'

    msgSyntaxError   db 'Syntax error', 13, 10, '$'
    msgDigitError    db 'Invalid digit for the source numbering', 13, 10, '$'
    msgOverflowError db 'Overflow while representing the number', 13, 10, '$'

    msgHelp   db 'HELP', 13, 10
              db 'Numbering converter', 13, 10
              db 'Usage:  GutOwe <source><target> <number>', 13, 10
              db '  source, target: uppercase letter of the numbering', 13, 10
              db '  number: digits (lowercase) of the source numbering', 13, 10
              db 'Available numberings:', 13, 10
              db '  N Numedrez    base 6   digits: p a c t d r', 13, 10
              db '  A Vocumero    base 5   digits: o i u e a', 13, 10
              db '  V Virtumero   base 7   digits: d x p c t g h', 13, 10
              db '  G Gasumero    base 11  digits: h e n o f m c a k x r', 13, 10
              db '  T Tengwar     base 12  digits: m i a n c l e o t r s q', 13, 10
              db '  K Vesteroena  base 15  digits: t l y b a s u g m h w r d f x', 13, 10
              db 'The first digit in the list is 0, the second is 1, etc.', 13, 10
              db 'Allowed range: 0 to 65535 (larger values cause overflow).', 13, 10
              db 'Example: GutOwe NG ptc', 13, 10
              db 'Output: source number, decimal, and number in the target base.', 13, 10
              db '$'
dataSegment EndS

; SEGMENTO DE PILA
stackSegment Segment Stack
    db 256 dup(0)
stackSegment EndS

; SEGMENTO DE CODIGO
codeSegment Segment
    Assume cs:codeSegment, ds:dataSegment, ss:stackSegment

start:
    ; Al arrancar, ds apunta al PSP (ahi esta la linea de comandos).
    Mov ax, ds
    Mov es, ax                      ; es = PSP
    Mov ax, dataSegment
    Mov ds, ax                      ; ds = nuestros datos

    Call commandLine                ; ax = 0 ok, 1 sintaxis, 4 sin parametros
    Cmp ax, 4
    Jne withAbout
    Call showHelp                   ; sin parametros: solo la ayuda
    Jmp finish
withAbout:
    Mov errorcodeSegment, ax               ; se guarda el codigo para consultarlo despues
    Call showAbout
    Cmp errorcodeSegment, 0
    Jne reportError

    Call toBinary                   ; ax = 0 ok, 2 digito invalido, 3 overflow
    Mov errorcodeSegment, ax
    Cmp errorcodeSegment, 0
    Jne reportError

    Call fromBinary                 ; llena targetText
    Call printResults               ; los tres renglones de salida
    Jmp finish
reportError:
    Mov ax, errorcodeSegment
    Call showError
finish:
    Mov ax, 4C00h                   ; funcion 4Ch: terminar el programa
    Int 21h

; findNumber: busca una letra en la tabla de numeraciones
; Entrada: al = letra     Salida: bx = registro de la tabla, 0 si no existe
findNumber Proc
    Push cx
    Mov bx, offset numberTable      ; bx = primer registro
    Mov cx, 6                       ; hay 6 numeraciones
findLoop:
    Cmp al, [bx]                    ; es la letra buscada?
    je findFound
    Add bx, 6                       ; siguiente registro (6 bytes)
    Loop findLoop
    Xor bx, bx                      ; no se encontro: bx = 0
findFound:
    Pop cx
    Ret
findNumber EndP

; commandLine: lee la linea de comandos del PSP (desde 81h hasta el 13)
; Guarda source, target y copia el numero a sourceText
; Salida: ax = 0 correcto, 1 error de sintaxis, 4 sin parametros
commandLine Proc
    Push si
    Push di
    Push bx

    Mov si, 81h                     ; si = el "dedo" sobre la linea de comandos
clFirstSkip:                        ; saltar espacios iniciales
    Mov al, es:[si]
    Cmp al, 13                      ; Enter sin haber encontrado nada
    je clNoParams
    Cmp al, ' '
    Jne clLetters
    Inc si
    Jmp clFirstSkip
clLetters:
    Mov al, es:[si]                 ; letra de la numeracion fuente
    Call findNumber
    Cmp bx, 0
    je clSyntaxError
    Mov source, bx
    Inc si

    Mov al, es:[si]                 ; letra de la numeracion destino
    Call findNumber
    Cmp bx, 0
    je clSyntaxError
    Mov target, bx
    Inc si

    Mov al, es:[si]                 ; debe haber al menos un espacio
    Cmp al, ' '
    Jne clSyntaxError
clSecondSkip:                       ; saltar espacios antes del numero
    Mov al, es:[si]
    Cmp al, ' '
    Jne clCheckNumber
    Inc si
    Jmp clSecondSkip
clCheckNumber:
    Cmp al, 13                      ; falta el numero
    je clSyntaxError
    Mov di, offset sourceText       ; di = donde se copia el numero
clCopy:
    Mov al, es:[si]
    Cmp al, 13                      ; fin de la linea
    je clCopyEnd
    Cmp al, ' '                     ; fin del numero
    je clCopyEnd
    Mov [di], al
    Inc si
    Inc di
    Jmp clCopy
clCopyEnd:
    Mov byte ptr [di], 0            ; cerrar la tira con 0
clRest:                             ; despues del numero solo espacios
    Mov al, es:[si]
    Cmp al, 13
    je clOk
    Cmp al, ' '
    Jne clSyntaxError
    Inc si
    Jmp clRest
clOk:
    Xor ax, ax                      ; ax = 0
    Jmp clExit
clNoParams:
    Mov ax, 4
    Jmp clExit
clSyntaxError:
    Mov ax, 1
clExit:
    Pop bx
    Pop di
    Pop si
    Ret
commandLine EndP

; digitValue: valor de un digito en una numeracion
; Entrada: al = caracter, bx = registro de la numeracion
; Salida:  ax = valor (0 a base-1), o 0FFFFh si no es digito valido
digitValue Proc
    Push cx
    Push si
    Mov si, [bx+2]                  ; si = digitos de la numeracion
    Xor cx, cx                      ; cx = posicion actual
digitValueLoop:
    Cmp byte ptr [si], 0            ; se acabo la tira: no es digito
    je digitValueInvalid
    Cmp al, [si]
    je digitValueFound
    Inc si
    Inc cx
    Jmp digitValueLoop
digitValueFound:
    Mov ax, cx                      ; la posicion es el valor
    Jmp digitValueExit
digitValueInvalid:
    Mov ax, 0FFFFh
digitValueExit:
    Pop si
    Pop cx
    Ret
digitValue EndP

; toBinary: metodo de Horner
;   acumulado = acumulado * base + digito
; Si hay overflow se marca pero se siguen validando los digitos
; Salida: ax = 0 correcto, 2 digito invalido, 3 overflow
toBinary Proc
    Push bx
    Push cx
    Push dx
    Push si
    Push di

    Mov numberValue, 0
    Mov isOverflow, 0
    Mov bx, source                  ; bx = registro de la numeracion fuente
    Mov al, [bx+1]                  ; al = base
    Xor ah, ah
    Mov di, ax                      ; di = base de 16 bits
    Mov si, offset sourceText
toBinaryLoop:
    Mov al, [si]
    Cmp al, 0                       ; fin del numero
    je toBinaryEnd
    Call digitValue                 ; ax = valor o 0FFFFh
    Cmp ax, 0FFFFh
    je toBinaryDigitError
    Cmp isOverflow, 0               ; si ya hubo overflow solo se valida
    Jne toBinaryNext
    Mov cx, ax                      ; cx = valor del digito
    Mov ax, numberValue
    Mul di                          ; dx:ax = numberValue * base
    Cmp dx, 0                       ; dx distinto de 0: no cabe en 16 bits
    Jne toBinaryOverflow
    Add ax, cx                      ; sumar el digito
    jc toBinaryOverflow             ; carry: no cabe en 16 bits
    Mov numberValue, ax
    Jmp toBinaryNext
toBinaryOverflow:
    Mov isOverflow, 1
toBinaryNext:
    Inc si
    Jmp toBinaryLoop
toBinaryEnd:
    Mov ax, 0
    Cmp isOverflow, 0
    je toBinaryExit
    Mov ax, 3
    Jmp toBinaryExit
toBinaryDigitError:
    Mov ax, 2
toBinaryExit:
    Pop di
    Pop si
    Pop dx
    Pop cx
    Pop bx
    Ret
toBinary EndP

; fromBinary: divisiones sucesivas entre la base destino
; Los residuos salen al reves: se guardan en la pila y se sacan despues
fromBinary Proc
    Push ax
    Push bx
    Push cx
    Push dx
    Push si
    Push di

    Mov bx, target                  ; bx = registro de la numeracion destino
    Mov al, [bx+1]                  ; al = base destino
    Xor ah, ah
    Mov si, ax                      ; si = base (divisor)
    Mov bx, [bx+2]                  ; bx = digitos del destino
    Mov ax, numberValue             ; ax = dividendo
    Xor cx, cx                      ; cx = cantidad de digitos
fromBinaryDivide:
    Xor dx, dx
    Div si                          ; ax = cociente, dx = residuo
    Push dx
    Inc cx
    Cmp ax, 0
    Jne fromBinaryDivide

    Mov di, offset targetText       ; di = donde se escribe el resultado
fromBinaryOutput:
    Pop si                          ; si = residuo = posicion del digito
    Mov al, [bx+si]                 ; al = caracter del digito
    Mov [di], al
    Inc di
    Loop fromBinaryOutput
    Mov byte ptr [di], 0

    Pop di
    Pop si
    Pop dx
    Pop cx
    Pop bx
    Pop ax
    Ret
fromBinary EndP

; printAscii: imprime una tira asciiZ.   Entrada: si = tira
printAscii Proc
    Push ax
    Push dx
    Push si
printAsciiLoop:
    Mov dl, [si]
    Cmp dl, 0
    je printAsciiExit
    Mov ah, 02h                     ; funcion 02h: imprimir dl
    Int 21h
    Inc si
    Jmp printAsciiLoop
printAsciiExit:
    Pop si
    Pop dx
    Pop ax
    Ret
printAscii EndP

; printDecimal: imprime en base 10 el numero que viene en ax
printDecimal Proc
    Push ax
    Push bx
    Push cx
    Push dx
    Xor cx, cx                      ; cx = cantidad de digitos
    Mov bx, 10
printDecimalDivide:
    Xor dx, dx
    Div bx                          ; residuo = ultimo digito
    Push dx
    Inc cx
    Cmp ax, 0
    Jne printDecimalDivide
printDecimalPrint:
    Pop dx
    Add dl, '0'                     ; digito a caracter
    Mov ah, 02h
    Int 21h
    Loop printDecimalPrint
    Pop dx
    Pop cx
    Pop bx
    Pop ax
    Ret
printDecimal EndP

; printLine: imprime  nombre: numero  y cambia de linea
; Entrada: bx = registro de la numeracion, si = tira del numero
printLine Proc
    Push ax
    Push dx
    Mov dx, [bx+4]                  ; dx = nombre de la numeracion
    Mov ah, 09h
    Int 21h
    Mov dx, offset msgSeparator
    Mov ah, 09h
    Int 21h
    Call printAscii                 ; imprime la tira de si
    Mov dx, offset msgLineBreak
    Mov ah, 09h
    Int 21h
    Pop dx
    Pop ax
    Ret
printLine EndP

; printResults: los tres renglones de salida
printResults Proc
    Push ax
    Push bx
    Push dx
    Push si

    Mov bx, source                  ; renglon 1: numero fuente
    Mov si, offset sourceText
    Call printLine

    Mov dx, offset msgDecimalLabel  ; renglon 2: decimal
    Mov ah, 09h
    Int 21h
    Mov ax, numberValue
    Call printDecimal
    Mov dx, offset msgLineBreak
    Mov ah, 09h
    Int 21h

    Mov bx, target                  ; renglon 3: numero destino
    Mov si, offset targetText
    Call printLine

    Pop si
    Pop dx
    Pop bx
    Pop ax
    Ret
printResults EndP

; showAbout, showHelp, showError: imprimen mensajes
showAbout Proc
    Push ax
    Push dx
    Mov dx, offset msgAbout
    Mov ah, 09h
    Int 21h
    Pop dx
    Pop ax
    Ret
showAbout EndP

showHelp Proc
    Push ax
    Push dx
    Mov dx, offset msgHelp
    Mov ah, 09h
    Int 21h
    Pop dx
    Pop ax
    Ret
showHelp EndP

; Entrada: ax = codigo (1 sintaxis, 2 digito invalido, 3 overflow)
showError Proc
    Push ax
    Push dx
    Mov dx, offset msgSyntaxError   ; por defecto: sintaxis
    Cmp ax, 2
    Jne showErrorThirdCheck
    Mov dx, offset msgDigitError
    Jmp showErrorPrint
showErrorThirdCheck:
    Cmp ax, 3
    Jne showErrorPrint
    Mov dx, offset msgOverflowError
showErrorPrint:
    Mov ah, 09h
    Int 21h
    Pop dx
    Pop ax
    Ret
showError EndP

codeSegment EndS
End start