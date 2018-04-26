/* ********************** GetGPIOAddress function ********************** */

.globl GetGpioAddress
GetGpioAddress:
    ldr r0,=0x20200000 /* GPIO base address */
    mov pc,lr

/* ********************** SetGPIOAddress function ********************** */

.globl SetGpioFunction
SetGpioFunction:
    cmp r0,#53 /* Checks that pin number is lower than 54 */
    cmpls r1,#7 /* Checks that function number is lower than 8 */
    movhi pc,lr

    push {lr}
    mov r2,r0 /* saves r0 so it's not lost on function call */
    bl GetGpioAddress

    functionLoop$:
        cmp r2,#9 /* Checks if r2 is not on first GPIO section */
        subhi r2,#10 /* Substracts 10 (size of section chunk) */
        addhi r0,#4 /* Increases GPIO address by 4 bytes (memory size of section)   */
        bhi functionLoop$

    add r2, r2,lsl #1 /* Multiply by 3 (function size) */
    lsl r1,r2 /* Gets function on correct pin position, with all other pins set to 0 */

    mov r3,#7   /* eq to 111 */
    lsl r3,r2   /* gets mask */
    mvn r3,r3   /* negates mask */

    ldr r2,[r0] /* gets current pin configuration on section */
    and r2,r3   /* deletes bits from desired pin */

    orr r1,r2   /* gets new configuration, keeping previous pin configuration */

    str r1,[r0] /* stores into GPIO address */
    pop {pc}

/* ********************** GetGPIO function ********************** */

.globl SetGpio
SetGpio:
    pinNum .req r0
    pinVal .req r1

/* Checks that pin number is valid, gets GPIO address */
    cmp pinNum,#53
    movhi pc,lr
    push {lr}
    mov r2,pinNum
    .unreq pinNum
    pinNum .req r2
    bl GetGpioAddress
    gpioAddr .req r0

/* Divides pin number by 32, multiples by 4, gets section, adds to GPIO address */
    pinBank .req r3
    lsr pinBank,pinNum,#5
    lsl pinBank,#2
    add gpioAddr,pinBank
    .unreq pinBank

/* Get correct bit position on desired set. Do this by calculating remainder of pin / 32 */
    and pinNum,#31
    setBit .req r3
    mov setBit,#1
    lsl setBit,pinNum
    .unreq pinNum

/* Checks for on/off variable, stores at correct address */
    teq pinVal,#0
    .unreq pinVal
    streq setBit,[gpioAddr,#40]
    strne setBit,[gpioAddr,#28]
    .unreq setBit
    .unreq gpioAddr
    pop {pc}
