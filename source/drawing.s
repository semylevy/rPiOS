/* ********************** Pixe color data ********************** */

.section .data
/* Stores pixel color */
.align 1
foreColour:
    .hword 0xFFFF

/* ********************** Buffer pointer address ********************** */

/* Stores frame buffer graphics address */
.align 2
graphicsAddress:
    .int 0

/* ********************** SetForeColor function ********************** */

.section .text
.globl SetForeColour
SetForeColour:
    /* Validate input */
    cmp r0,#0x10000
    movhs pc,lr
    /* Gets color address */
    ldr r1,=foreColour
    /* Sets color from r0 */
    strh r0,[r1]
    mov pc,lr

/* ********************** SetGraphicsAddress function ********************** */

.globl SetGraphicsAddress
SetGraphicsAddress:
    /* Stores graphics address from r0 */
    ldr r1,=graphicsAddress
    str r0,[r1]
    mov pc,lr

/* ********************** DrawPixel function ********************** */


.globl DrawPixel
DrawPixel:
    px .req r0
    py .req r1
    addr .req r2
    ldr addr,=graphicsAddress
    ldr addr,[addr]

    height .req r3
    ldr height,[addr,#4]
    sub height,#1
    /* Checks that py is within height limits */
    cmp py,height
    movhi pc,lr
    .unreq height

    width .req r3
    ldr width,[addr,#0]
    sub width,#1
    /* Checks that px is within width limit */
    cmp px,width
    movhi pc,lr

    /* Gets pointer to frame buffer */
    ldr addr,[addr,#32]
    add width,#1
    /* Calculates pixel address, ((py*width) + px) */
    mla px,py,width,px
    .unreq width
    .unreq py
    /* Address + (px) * pixelSize (2) */
    add addr, px,lsl #1
    .unreq px

    fore .req r3
    ldr fore,=foreColour
    ldrh fore,[fore]

    /* Stores color in correct pixel address */
    strh fore,[addr]
    .unreq fore
    .unreq addr
    mov pc,lr

/* ********************** DrawLine function ********************** */

.globl DrawLine
DrawLine:
    push {r4,r5,r6,r7,r8,r9,r10,r11,r12,lr}
    x0 .req r9
    x1 .req r10
    y0 .req r11
    y1 .req r12

    mov x0,r0
    mov x1,r2
    mov y0,r1
    mov y1,r3

    dx .req r4
    dyn .req r5 /* Note that we only ever use -deltay, so I store its negative for speed. (hence dyn) */
    sx .req r6
    sy .req r7
    err .req r8

    cmp x0,x1
    subgt dx,x0,x1
    movgt sx,#-1
    suble dx,x1,x0
    movle sx,#1

    cmp y0,y1
    subgt dyn,y1,y0
    movgt sy,#-1
    suble dyn,y0,y1
    movle sy,#1

    add err,dx,dyn
    add x1,sx
    add y1,sy

    pixelLoop$:
        teq x0,x1
        teqne y0,y1
        popeq {r4,r5,r6,r7,r8,r9,r10,r11,r12,pc}

        mov r0,x0
        mov r1,y0
        bl DrawPixel

        cmp dyn, err,lsl #1
        addle err,dyn
        addle x0,sx

        cmp dx, err,lsl #1
        addge err,dx
        addge y0,sy

        b pixelLoop$

    .unreq x0
    .unreq x1
    .unreq y0
    .unreq y1
    .unreq dx
    .unreq dyn
    .unreq sx
    .unreq sy
    .unreq err
