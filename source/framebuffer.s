.section .data
.align 4
.globl FrameBufferInfo
FrameBufferInfo:
    .int 1024 /* #0 Physical Width */
    .int 768 /* #4 Physical Height */
    .int 1024 /* #8 Virtual Width */
    .int 768 /* #12 Virtual Height */
    .int 0 /* #16 GPU - Pitch */
    .int 16 /* #20 Bit Depth */
    .int 0 /* #24 X */
    .int 0 /* #28 Y */
    .int 0 /* #32 GPU - Pointer */
    .int 0 /* #36 GPU - Size */

.section .text
.globl InitialiseFrameBuffer
InitialiseFrameBuffer:
    /* Validate inputs */
    width .req r0
    height .req r1
    bitDepth .req r2
    cmp width,#4096
    cmpls height,#4096
    cmpls bitDepth,#32
    result .req r0
    movhi result,#0
    movhi pc,lr

    fbInfoAddr .req r3
    push {lr}
    /* Gets frame buffer info address */
    ldr fbInfoAddr,=FrameBufferInfo
    /* Stores all the parameters to data */
    str width,[fbInfoAddr,#0]
    str height,[fbInfoAddr,#4]
    str width,[fbInfoAddr,#8]
    str height,[fbInfoAddr,#12]
    str bitDepth,[fbInfoAddr,#20]
    .unreq width
    .unreq height
    .unreq bitDepth

    /* Sets mailbox to 1 */
    mov r0,fbInfoAddr
    /* Makes sure cache is not cleared/used */
    add r0,#0x40000000
    /* Write to mailbox 1 */
    mov r1,#1
    bl MailboxWrite

    /* Read from mailbox 1 */
    mov r0,#1
    bl MailboxRead
    /* Checks is result is 0 */
    teq result,#0
    /* If result is 0 == OK, if not load 0 into result */
    movne result,#0
    popne {pc}
    /* If OK, return address to frame buffer info */
    mov result,fbInfoAddr
    pop {pc}
    .unreq result
    .unreq fbInfoAddr
