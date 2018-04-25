.section .init
.globl _start
_start:

b main

.section .text
main:
mov sp,#0x8000


/*ldr r0,=0x20200000  /* Load GPIO address into r0 */
/* To get pin 16 address, pin 6 from second section (10-19) is needed (each pin is 3 bits, so 6*3) */
/*mov r1,#1
/*lsl r1,#18  /* 1 left shift 18 == memory address of pin 16. */
/*str r1,[r0,#4]  /* Add 4 bytes to reference second section */

pinNum .req r0
pinFunc .req r1
mov pinNum,#16
mov pinFunc,#1
bl SetGpioFunction
.unreq pinNum
.unreq pinFunc

loop$:

/* mov r1,#1
/* lsl r1,#16 /* Left shift 16 to denote 16th pin */
/* str r1,[r0,#40] /* Address 40 + GPIO address == turn pin off */

pinNum .req r0
pinVal .req r1
mov pinNum,#16
mov pinVal,#0
bl SetGpio
.unreq pinNum
.unreq pinVal

/* Generic wait function, just substracts a number */
mov r2,#0x3F0000
wait1$:
sub r2,#1
cmp r2,#0
bne wait1$

/* str r1,[r0,#28] /* Address 40 + GPIO address == turn pin off */

pinNum .req r0
pinVal .req r1
mov pinNum,#16
mov pinVal,#1
bl SetGpio
.unreq pinNum
.unreq pinVal

/* Generic wait function, just substracts a number */
mov r2,#0x3F0000
wait2$:
sub r2,#1
cmp r2,#0
bne wait2$

b loop$ /* Infinite loop */
