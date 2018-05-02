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

    mov r4,#0
    loop$:
    ldr r0,=format
    mov r1,#formatEnd-format
    ldr r2,=formatEnd
    lsr r3,r4,#4
    push {r3}
    push {r3}
    push {r3}
    push {r3}
    bl FormatString
    add sp,#16

    mov r1,r0
    ldr r0,=formatEnd
    mov r2,#0
    mov r3,r4

    add r3,#10
    cmp r3,#768-16
    subhi r3,#664
    addhi r2,#20
    bl DrawString
    ldr r0,=100000
    bl TimerFunction

    add r4,#16
    b loop$

    .section .data
    format:
    .ascii "HOLA KAREN"
    formatEnd:

