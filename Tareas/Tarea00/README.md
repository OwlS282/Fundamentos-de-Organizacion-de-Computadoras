# Tarea de ASM - Numeraciones en ASM

## Descripción
Esta tarea consiste en un programa en lenguaje ensamblador (TASM, 16 bits, para DOS) llamado **GutOwe**, que convierte un número natural de una numeración a otra. El programa:
- Trabaja con números de 16 bits sin signo (de 0 a 65535)
- Maneja exactamente seis numeraciones inventadas: Numedrez, Vocumero, Virtumero, Gasumero, Tengwar y Vesteroena
- Lee los parámetros desde la línea de comandos (PSP)
- Convierte el número fuente a binario con el método de Horner y luego al sistema destino con divisiones sucesivas
- Muestra el número en la numeración fuente, en decimal y en la numeración destino
- Informa errores de sintaxis, de dígito inválido y de desbordamiento

## Requisitos del problema

### Numeraciones disponibles
El primer dígito de cada lista vale 0, el segundo 1, y así sucesivamente.

| Letra | Numeración | Base | Dígitos |
|-------|------------|------|---------|
| N | Numedrez | 6 | `p a c t d r` |
| A | Vocumero | 5 | `o i u e a` |
| V | Virtumero | 7 | `d x p c t g h` |
| G | Gasumero | 11 | `h e n o f m c a k x r` |
| T | Tengwar | 12 | `m i a n c l e o t r s q` |
| K | Vesteroena | 15 | `t l y b a s u g m h w r d f x` |

### Línea de comandos
```
GutOwe <fuente><destino> <numero>
```
- **fuente**: Letra MAYÚSCULA de la numeración en que viene el número
- **destino**: Letra MAYÚSCULA de la numeración a la que se convierte (va junto a la letra fuente, sin espacio)
- **numero**: Dígitos (en MINÚSCULA) de la numeración fuente, separados de las letras por al menos un espacio

Sin parámetros, el programa muestra la ayuda y termina.

### Salida del programa
Cuando no se muestra la ayuda, el programa imprime:
- Dos renglones de "acerca de" y una línea en blanco
- Tres renglones con el resultado: el número en la numeración fuente, el número en decimal y el número en la numeración destino

### Mensajes de error
Se muestran después del "acerca de" y el programa termina.

| Mensaje | Cuándo ocurre | Ejemplo |
|---------|---------------|---------|
| `Syntax error` | Una letra de numeración no es una de las seis, está en minúscula, falta el espacio, falta el número o sobra texto después del número | `GutOwe NX ptc`, `GutOwe ng ptc`, `GutOwe NGptc`, `GutOwe NG`, `GutOwe NG ptc extra` |
| `Invalid digit for the source numbering` | El número contiene un carácter que no es dígito de la numeración fuente | `GutOwe NG pxc` (la `x` no es dígito de Numedrez) |
| `Overflow while representing the number` | El número no cabe en 16 bits sin signo (es mayor que 65535) | `GutOwe AG aoaaiui` (equivale a 65536) |

## Reglas del programa
- Los números van de 0 a 65535 (16 bits sin signo).
- Las letras de numeración van en mayúscula y los dígitos del número en minúscula.
- Las dos letras de numeración van juntas, sin espacio entre ellas.
- Se permiten varios espacios antes de las letras, entre las letras y el número, y después del número.
- Los ceros a la izquierda se aceptan, pero no se muestran en el resultado.
- Si el número tiene un dígito inválido y además es demasiado grande, se informa el dígito inválido.
- Si el número es 0, el resultado se muestra con un solo dígito (el que vale 0 en la numeración destino).

## Conceptos de ensamblador implementados

- **Segmentos**: Segmento de datos (`dataSegment`), de pila (`stackSegment`, 256 bytes) y de código (`codeSegment`)
- **Línea de comandos**: Lectura directa del PSP, que contiene la línea de comandos desde el desplazamiento `81h` hasta el carácter 13
- **Procedimientos**: `Proc` / `EndP` con `Call` y `Ret`, preservando registros con `Push` y `Pop`
- **Tabla de registros**: `numberTable` con seis registros de 6 bytes (letra, base, dígitos y nombre)
- **Direccionamiento**: Directo, indirecto por registro (`[bx]`, `[si]`), con desplazamiento (`[bx+2]`) y base más índice (`[bx+si]`)
- **Aritmética**: `Mul` y `Div` de 16 bits, `Add` con detección de acarreo (`jc`)
- **Método de Horner**: `acumulado = acumulado * base + dígito` para pasar a binario
- **Divisiones sucesivas**: Para pasar de binario a la base destino, usando la pila para invertir los residuos
- **Control de flujo**: `Cmp`, saltos condicionales e incondicionales, y `Loop`
- **Interrupciones del DOS**: `INT 21h` con las funciones `02h` (imprimir un carácter), `09h` (imprimir una cadena terminada en `$`) y `4Ch` (terminar el programa)
- **Manejo de errores**: Códigos de error en `ax` y en la variable `errorcodeSegment`

## Requisitos técnicos
- DOSBox
- TASM 3.2 y TLINK 3.01 en la carpeta montada de DOSBox
- Editor: Visual Studio Code (o cualquier editor de texto)

## Estructura del proyecto

```
Tarea ASM/
└── GutOwe.ASM      - Código fuente del programa
```

Al ensamblar y enlazar se generan los archivos `GutOwe.OBJ` y `GutOwe.EXE` (y, según las opciones, `GutOwe.MAP` y `GutOwe.LST`), que no se suben al repositorio.

## Compilación y ejecución

### En DOSBox:
1. Montar la carpeta donde están TASM, TLINK y el archivo fuente:
```
mount c <ruta de la carpeta>
c:
```
2. Ensamblar y enlazar:
```
tasm GutOwe
tlink GutOwe
```
3. Ejecutar:
```
GutOwe NG ptc
```

### En Visual Studio Code:
El código se edita en VS Code y se ensambla y ejecuta en DOSBox con los comandos anteriores.

## Ejemplos de ejecución

```
C:\> GutOwe NG ptc
Numbering Converter - Short ASM Assignment
Owel Jafet Gutiérrez Ortiz - Carnet: 2026800869

Numedrez: ptc
Decimal: 20
Gasumero: ex
```

```
C:\> GutOwe KN bl
Numbering Converter - Short ASM Assignment
Owel Jafet Gutiérrez Ortiz - Carnet: 2026800869

Vesteroena: bl
Decimal: 46
Numedrez: aad
```

```
C:\> GutOwe AG aoaaiuo
Numbering Converter - Short ASM Assignment
Owel Jafet Gutiérrez Ortiz - Carnet: 2026800869

Vocumero: aoaaiuo
Decimal: 65535
Gasumero: fmnck
```

Ejemplo de error:

```
C:\> GutOwe AG aoaaiui
Numbering Converter - Short ASM Assignment
Owel Jafet Gutiérrez Ortiz - Carnet: 2026800869

Overflow while representing the number
```

Sin parámetros se muestra solo la ayuda:

```
C:\> GutOwe
HELP
Numbering converter
Usage:  GutOwe <source><target> <number>
  ...
```

---

# DIAGRAMA DEL PROGRAMA

## Flujo principal

```
┌────────────────────────────────────────────┐
│  start (ds = PSP → es = PSP, ds = datos)   │
└────────────────────────────────────────────┘
                      │
                      ▼
┌────────────────────────────────────────────┐
│                commandLine                 │
└────────────────────────────────────────────┘
                      │
                      ▼
        ax = 4 (sin parámetros)?
   sí ◄────────┴────────► no
   │                        │
   ▼                        ▼
 showHelp               showAbout
   │                        │
   │             ax ≠ 0 (sintaxis)? ── sí ──► showError
   │                        │ no
   │                        ▼
   │                    toBinary
   │             ax ≠ 0 (dígito/overflow)? ── sí ──► showError
   │                        │ no
   │                        ▼
   │                   fromBinary
   │                        │
   │                        ▼
   │                  printResults
   │                        │
   └────────────┬───────────┘
                ▼
      finish (INT 21h, función 4Ch)

(Después de showError el programa también va a finish.)
```

## Algoritmos de conversión

```
Fuente → binario (toBinary, método de Horner)
  acumulado = 0
  para cada dígito del número:
      valor = posición del dígito en la tira de la numeración fuente
      si no está en la tira → error 2 (dígito inválido)
      acumulado = acumulado * base + valor
      si no cabe en 16 bits (dx ≠ 0 o acarreo) → marcar overflow
  si hubo overflow → error 3

Binario → destino (fromBinary, divisiones sucesivas)
  repetir:
      cociente, residuo = acumulado / base destino
      guardar el residuo en la pila
  hasta que el cociente sea 0
  sacar los residuos de la pila (salen en orden inverso)
  escribir el dígito de la numeración destino en la posición de cada residuo
```

## Orden de los errores

```
1. Sintaxis        → commandLine (antes de convertir)
2. Dígito inválido → toBinary    (aunque además haya overflow)
3. Overflow        → toBinary    (solo si todos los dígitos son válidos)
```

---

# DIAGRAMA DE ESTRUCTURAS Y PROCEDIMIENTOS

```
╔══════════════════════════════════════════════════════════════╗
║ REGISTRO DE NUMERACIÓN (6 bytes, tabla numberTable)          ║
╠══════════════════════════════════════════════════════════════╣
║ Offset  Tamaño  Campo     Contenido                          ║
║ +0      db      letra     'N', 'A', 'V', 'G', 'T' o 'K'      ║
║ +1      db      base      6, 5, 7, 11, 12 o 15               ║
║ +2      dw      dígitos   dirección de la tira de dígitos (asciiZ)║
║ +4      dw      nombre    dirección del nombre (termina en '$')║
╚══════════════════════════════════════════════════════════════╝

╔══════════════════════════════════════════════════════════════╗
║ SEGMENTO DE DATOS (dataSegment)                              ║
╠══════════════════════════════════════════════════════════════╣
║ Dígitos (asciiZ):                                            ║
║ baseN, baseA, baseV, baseG, baseT, baseK                     ║
║                                                              ║
║ Nombres (terminan en '$'):                                   ║
║ nameN, nameA, nameV, nameG, nameT, nameK                     ║
║                                                              ║
║ Tabla:                                                       ║
║ numberTable: 6 registros de 6 bytes                          ║
║                                                              ║
║ Variables:                                                   ║
║ source: dw            registro de la numeración fuente       ║
║ target: dw            registro de la numeración destino      ║
║ numberValue: dw       número en binario (16 bits sin signo)  ║
║ isOverflow: dw        1 si el número no cabe en 16 bits      ║
║ errorcodeSegment: dw  0 ok, 1 sintaxis, 2 dígito, 3 overflow ║
║ sourceText: db 128    número tal como se digitó              ║
║ targetText: db 20     resultado en la numeración destino     ║
║                                                              ║
║ Mensajes:                                                    ║
║ msgAbout, msgHelp, msgSyntaxError, msgDigitError,            ║
║ msgOverflowError, msgDecimalLabel, msgSeparator, msgLineBreak║
╚══════════════════════════════════════════════════════════════╝

╔══════════════════════════════════════════════════════════════╗
║ PROCEDIMIENTOS (codeSegment)                                 ║
╠══════════════════════════════════════════════════════════════╣
║ findNumber                                                   ║
║   Entrada: al = letra                                        ║
║   Salida:  bx = registro de la tabla, 0 si no existe         ║
║                                                              ║
║ commandLine                                                  ║
║   Lee la línea de comandos del PSP (desde 81h hasta 13)      ║
║   Guarda source, target y copia el número a sourceText       ║
║   Salida:  ax = 0 correcto, 1 sintaxis, 4 sin parámetros     ║
║                                                              ║
║ digitValue                                                   ║
║   Entrada: al = carácter, bx = registro de la numeración     ║
║   Salida:  ax = valor del dígito, 0FFFFh si no es válido     ║
║                                                              ║
║ toBinary                                                     ║
║   Método de Horner: acumulado = acumulado * base + dígito    ║
║   Salida:  ax = 0 correcto, 2 dígito inválido, 3 overflow    ║
║                                                              ║
║ fromBinary                                                   ║
║   Divisiones sucesivas entre la base destino; los residuos   ║
║   se guardan en la pila y se sacan al revés en targetText    ║
║                                                              ║
║ printAscii     imprime una tira asciiZ (INT 21h, función 02h)║
║ printDecimal   imprime en base 10 el número de ax            ║
║ printLine      imprime  nombre: número  y cambia de línea    ║
║ printResults   imprime los tres renglones de salida          ║
║ showAbout      imprime las dos líneas de "acerca de"         ║
║ showHelp       imprime la ayuda                              ║
║ showError      imprime el mensaje según el código de ax      ║
╚══════════════════════════════════════════════════════════════╝
```

---

## Características implementadas

### Línea de comandos
- Lee la línea de comandos directamente del PSP
- Acepta varios espacios antes, entre y después de los parámetros
- Distingue entre mayúsculas (letras de numeración) y minúsculas (dígitos)
- Muestra la ayuda cuando no se reciben parámetros

### Conversión
- Convierte de cualquiera de las seis numeraciones a cualquier otra
- Usa una tabla de registros para no repetir código por cada numeración
- Detecta desbordamiento de 16 bits en la multiplicación (`dx ≠ 0`) y en la suma (acarreo)
- Sigue validando los dígitos aunque ya haya overflow, para informar primero el dígito inválido

### Salida
- Imprime el "acerca de" y los tres renglones de resultado
- Imprime el número decimal con divisiones entre 10
- Usa los códigos 0 a 3 para decidir qué mensaje de error mostrar

## Notas importantes
- Los nombres `Vocumero`, `Virtumero` y `Gasumero` se imprimen con `ú` usando el código `0A3h`, y `Gutiérrez` con `é` usando el código `82h` (página de códigos 437 de DOS), por eso se ven correctos en DOSBox.
- Los mensajes de error y de ayuda están en inglés, como lo pide la tarea.
- La línea de comandos del DOS tiene un máximo de 127 caracteres, por lo que el buffer `sourceText` de 128 bytes es suficiente.
- Se siguieron las convenciones de nombres con `camelCase` para etiquetas y procedimientos.

## Autor
Owel Jafet Gutiérrez Ortiz

## Carnet
2026800869

## Curso
Fundamentos de Organización de Computadoras - Grupo 02

## Profesor
Kirstein Gatjens Soto

## Fecha de entrega
20/11/2026

## Institución
Instituto Tecnológico de Costa Rica
Escuela de Computación
Bachillerato en Ingeniería en Computación