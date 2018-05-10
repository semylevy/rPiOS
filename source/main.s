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

    bl UsbInitialise

    mov r4, #0
    mov r5, #0

    loopForever$:
        bl KeyboardUpdate
        teq r0, #0
        beq LedOn$

        bl KeyboardGetChar

        teq r0, #0
        beq loopForever$

        mov r1, r4
        mov r2, r5
        bl DrawCharacter

        add r4, r0 /* Add width to x */

        teq r4, #1024
        addge r5, r1
        movge r4, #0
        teqeq r5, #768
        moveq r5,#0

        b loopForever$

    LedOn$:
        /* If errors, turn on ACT LED */
        mov r0,#16
        mov r1,#1
        bl SetGpioFunction
        mov r0,#16
        mov r1,#0
        bl SetGpio
        /* Inifinite loop */
    error1$:
        b error1$
