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

    random .req r5
    color .req r6
    x0 .req r9
    x1 .req r10
    y0 .req r11
    y1 .req r12
    mov random, #0
    mov color, #0
    mov x0, #0
    mov y0, #0

    render$:
        mov r0, random
        bl Random
        mov x1, r0

        bl Random
        mov y1, r0

        mov random, y1

        mov r0, color
        add color,#1
        lsl color,#16
        lsr color,#16
        bl SetForeColour

        mov r0,x0
        mov r1,y0
        lsr x1, x1, #22
        lsr y1, y1, #22

        cmp y1, #768
        bhs render$
        mov r2,x1
        mov r3,y1
        mov x0, x1
        mov y0, y1
        bl DrawLine
        b render$

    .unreq random
    .unreq color
    .unreq x0
    .unreq x1
    .unreq y0
    .unreq y1

    
