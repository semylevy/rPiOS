.section .init
.globl _start
_start:

b main

.section .text
main:
mov sp,#0x8000

/* Sets pin 16 to 001 */
pinNum .req r0
pinFunc .req r1
mov pinNum,#16
mov pinFunc,#1
bl SetGpioFunction
.unreq pinNum
.unreq pinFunc

ptrn .req r4
ldr ptrn,=pattern
ldr ptrn,[ptrn]
seq .req r5
mov seq,#0

/* Turns LED on if pattern at sequence is 1 */
loop$:
pinNum .req r0
pinVal .req r1

mov pinVal,#1
lsl pinVal,seq
and pinVal,ptrn

mov pinNum,#16
bl SetGpio
.unreq pinNum
.unreq pinVal

/* Waits */
ldr r0,=250000
bl TimerFunction

add seq,#1
and seq,#0b11111
b loop$ /* Infinite loop */

.section .data
.align 2
pattern:
.int 0b11111111101010100010001000101010
