.section .data

/* ********************** Normal keys look up table ********************** */

.align 3
KeysNormal:
    .byte 0x0, 0x0, 0x0, 0x0, 'a', 'b', 'c', 'd'
    .byte 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l'
    .byte 'm', 'n', 'o', 'p', 'q', 'r', 's', 't'
    .byte 'u', 'v', 'w', 'x', 'y', 'z', '1', '2'
    .byte '3', '4', '5', '6', '7', '8', '9', '0'
    .byte '\n', 0x0, '\b', '\t', ' ', '-', '=', '['
    .byte ']', '\\', '#', ';', '\'', '`', ',', '.'
    .byte '/', 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0
    .byte 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0
    .byte 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0
    .byte 0x0, 0x0, 0x0, 0x0, '/', '*', '-', '+'
    .byte '\n', '1', '2', '3', '4', '5', '6', '7'
    .byte '8', '9', '0', '.', '\\', 0x0, 0x0, '='

/* ********************** Shift keys look up table ********************** */

.align 3
KeysShift:
	.byte 0x0, 0x0, 0x0, 0x0, 'A', 'B', 'C', 'D'
	.byte 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L'
	.byte 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T'
	.byte 'U', 'V', 'W', 'X', 'Y', 'Z', '!', '"'
	.byte '#', '$', '%', '^', '&', '*', '(', ')'
	.byte '\n', 0x0, '\b', '\t', ' ', '_', '+', '{'
	.byte '}', '|', '~', ':', '@', '.', '<', '>'
	.byte '?', 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0
	.byte 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0
	.byte 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0, 0x0
	.byte 0x0, 0x0, 0x0, 0x0, '/', '*', '-', '+'
	.byte '\n', '1', '2', '3', '4', '5', '6', '7'
	.byte '8', '9', '0', '.', '|', 0x0, 0x0, '='

.align 2 /* ensures the address of the next line is a multiple of 2 */
KeyboardAddress:
    .int 0
KeyboardOldDown:
    .rept 6     /* Repeat 6 times */
    .hword 0    /* Only a half word (2 bytes) */
    .endr       /* End repeat */

/* ********************** Keyboard update function ********************** */

.section .text
.globl KeyboardUpdate
KeyboardUpdate:
    push {r4,r5,lr}

    address .req r4
    ldr r0, =KeyboardAddress    /* Get keyboard address */
    ldr address, [r0]

    teq r0,#0       /* Check if keyboard is loaded */
    bne keyboardPresent$

    newKeyboard$:
        bl UsbCheckForChange        /* Check for active keyboards */
        bl KeyboardCount
        teq r0, #0 /* Get number of connected keyboards */
        ldreq r1, =KeyboardAddress
        streq r0, [r1]
        beq return$   /* If there are no keyboards return */
        mov r0, #0      /* First parameter */
        bl KeyboardGetAddress
        
        ldr address, =KeyboardAddress
        str r0, [address]    /* Store keyboard address */
        teq r0, #0
        beq return$   /* There is some kind of error */
        ldr address, [address]

    keyboardPresent$:
        count .req r5
        mov count, #0   /* Goes up to 6 (keys per moment) */
        getKeyLoop$:
            mov r0, address
            mov r1, count
            bl KeyboardGetKeyDown   /* Gets key at index */
            ldr r1, =KeyboardOldDown
            add r1, count,lsl #1 /* Increments address (by 2n) to store keys */
            strh r0, [r1] /* Stores keys */
            add count,#1
            cmp count,#6
            blt getKeyLoop$
        .unreq count
        mov r0, address
        bl KeyboardPoll     /* Call keyboard poll */
        teq r0, #0      /* Probably disconnected */
        bne newKeyboard$
    return$:
        .unreq address
        pop {r4,r5,pc}

/* ********************** Key was down function ********************** */

.globl KeyWasDown
KeyWasDown:
    keyOldDown .req r1
    count .req r2
    ldr keyOldDown, =KeyboardOldDown    /* Gets pressed keys */
    mov count, #0

    compareKey$:
        ldrh r3, [keyOldDown]    /* Loops thrpugh pressed keys */
        teq r0, r3      /* Checks if pressed key is equal to input r0 */
        moveq r0, #1
        beq return1$
        add keyOldDown, count,lsl #1 /* Increments address (by 2n) to store keys */
        add count,#1
        cmp count,#6
        blt compareKey$
    mov r0, #0
    return1$:
        .unreq count
        .unreq keyOldDown
        mov pc, lr

/* ********************** Keyboard get char function ********************** */

.globl KeyboardGetChar
KeyboardGetChar:
    push {r4,r5,r6,lr}
    address .req r4
    ldr r1, =KeyboardAddress    /* Get keyboard address */
    ldr address, [r1]
    teq address, #0     /* Check if there is no keyboard */
    moveq r0, #0
    beq return2$
    count .req r5
    mov count, #0
    scanCode .req r6
    getKey$:        /* Loop up to 6 times */
        mov r0, address
        mov r1, count
        bl KeyboardGetKeyDown
        teq r0, #0      /* No key */
        beq break$
        mov scanCode, r0    
        bl KeyWasDown   /* Was key already pressed? */
        teq r0, #1
        beq continue$
        cmp scanCode, #104  /* Is key higher than 103? */
        bge continue$
        mov r0, address
        bl KeyboardGetModifiers /* Is a modifier key pressed? */
        tst r0, #0b00100010     /* Ones mean right and left shift. Computes r0 AND value, compares to 0 */
        ldrne r0, =KeysShift    /* If shift is pressed, get special keys */
        ldreq r0, =KeysNormal   /* If not, get normal ones */
        ldrb r0, [r0, scanCode]    /* Gets actual ascii code */
        teq r0, #0      /* Checks if scan code is 0 */
        bne return2$

    continue$:          /* When weird things happen */
        add count,#1    /* Continue loop */
        cmp count,#6
        blt getKey$

    break$:
        mov r0, #0      /* Nothing found, return 0 */
    return2$:
        .unreq address
        .unreq scanCode
        .unreq count
        pop {r4,r5,r6,pc}
