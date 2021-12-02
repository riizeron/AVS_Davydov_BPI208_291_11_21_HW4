# Fourth homework

## Task: Various numbers,Variant 291 (11, 21)

### Autor: Davydov Vyacheslav Olegovich

## Task

>Various numbers
> * 1. Complex (real and imaginary parts - a pair of real numbers)
> * 2. Simple fractions (numerator, denominator - a pair of integers)
> * 3. Polar coordinates (angle [radian] - real; coordinates of the end point on the plane

------

### Functions common to all alternatives

Converting each value to a real number equivalent to the written one. For example, for a complex number it is carried out according to the formula: sqrt (d^2 + i^2)), and for polar coordinates - distance.
---------

### Basic alternatives

> _Procedural_
>> * presence, absence of abstract data types - boolean

> _Object-oriented_
>> * inheritance: single, multiple, interface - enumerated

> _Functional_
>> * typing - enumerated type = strong, dynamic
>> * lazy evaluation support - boolean

### Functional

_After placing the data in the container, it is necessary to process it in accordance with the task variant.
The processed data are then entered into a separate result file.

Remove from the container those elements for which the value obtained using the function common to all alternatives is less than
the arithmetic mean for all elements of the container, obtained using the same function. Move other elements to the beginning
container while maintaining order.

---------

## Testing

The initial data for testing is contained in the `output` directory.

File with test results `output / reports.txt`

```
$ sh compilefile.sh
```
## Procedural (C ++)

Program runtime on different sizes of input data:

Number of numbers | Running time, seconds | Memory consumed, KB
--- | --- | --- 
`7` | < `0.002` | `~2750`
`100` | < `0.01` | `~2892`
`1000` | `0.01` | `~3674`
`5000` | `0.15` | `~4622`
`10000` | `0.96` | `~4877`


## Object Oriented (C++)

Program runtime on different sizes of input data:

Number of numbers | Running time, seconds | Memory consumed, KB
--- | --- | --- 
`7` | < `0.001` | `~2600`
`100` | < `0.01` | `~2800`
`1000` | `0.01` | `~3500`
`5000` | `0.14` | `~4150`
`10000` | `0.90` | `~4625`

## Dynamic typing (Python)

Program runtime on different sizes of input data:

Number of numbers | Running time, seconds | Memory consumed, KB
--- | --- | --- 
`10` | `Source: 0.002 Sort: 0.002` | `~4420`
`100` | `Source: 0.005 Sort: 0.023` | `~5650`
`1000` | `Source: 0.038 Sort: 1.911` | `~8652`
`5000` | `Source: 0.069 Sort: 2.233` | `~10841`
`10000` | `Source: 0.423 Sort: 169.316` | `~20532`

---
## Difference between procedural, object-oriented, dynamic typing with an assembly program

--------
> Of course, a program in Assembler is more difficult to write than a program in a high-level language. However, Assembler also has advantages.
>> First, a program written in a high-level language
is still translated into an assembler program,
and in a very suboptimal way.
That is, an assembler program will almost always be
run faster and take up significantly less memory.
>
>> Second, access to many hardware resources
can only be obtained using Assembler. Please note that an __assembler__ program can be written in any editor!

## Metrics that define the characteristics of the program:

| Metric | Value |
| : ---: | --- |
| The total size of the source code of the program | 17.211 KB |
| The size of the release build executable file (GCC, Linux) __ * __ | 32.12 KB |

__ * __ Versions in more detail:

```
gcc --version:
gcc (Ubuntu 9.3.0-17ubuntu1~20.04) 9.3.0
Copyright (C) 2019 Free Software Foundation, Inc.

nasm --version
NASM version 2.14.02

Processor:
Intel(R) Pentium(R) Silver N5000 CPU @ 1.10GHz

lsb_release -a:
No LSB modules are available.
Distributor ID: Ubuntu
Description:    Ubuntu 20.04 LTS
Release:        20.04
Codename:       focal

uname -a:
Linux riizeron 5.10.16.3-microsoft-standard-WSL2 #1 SMP Fri Apr 2 22:23:49 UTC 2021 x86_64 x86_64 x86_64 GNU/Linux
