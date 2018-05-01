.section .init
.globl _start
_start:

b main

.section .text
main:
    mov sp,#0x8000

    /* Set screen size */
    mov r0,#1024
    mov r1,#768
    /* Set color (GPU pitch) */
    mov r2,#16
    bl InitialiseFrameBuffer

    /* Check for errors */
    teq r0,#0
    bne noError$

    /* If errors, turn on ACT LED */
    mov r0,#16
    mov r1,#1
    bl SetGpioFunction
    mov r0,#16
    mov r1,#0
    bl SetGpio

    /* Inifinite loop */
    error$:
        b error$

    noError$:
        bl SetGraphicsAddress

    mov r0,#9
    bl FindTag
    ldr r1,[r0]
    lsl r1,#2
    sub r1,#8
    add r0,#8
    mov r2,#0
    mov r3,#0
    bl DrawString

    loop$:
    b loop$
