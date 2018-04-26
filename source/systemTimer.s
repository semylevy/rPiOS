/* ********************** GetTimerAddress function ********************** */

.globl GetTimerAddress
GetTimerAddress:
    ldr r0,=0x20003000 /* GPIO base address */
    mov pc,lr

/* ********************** GetTimeStamp function ********************** */

.globl GetTimeStamp
GetTimeStamp:
    push {lr}
    bl GetTimerAddress
    ldrd r0,r1,[r0,#4]  /* Read timer */
    pop {pc}

/* ********************** TimerFunction function ********************** */

.globl TimerFunction
TimerFunction:
    waitTime .req r3
    mov waitTime,r0 /* saves r0 so it's not lost on function call */
    push {lr}
    bl GetTimeStamp
    startTime .req r2
    mov startTime,r0
    currentTime .req r0

    /* r0 = current time */
    /* r2 = start time */
    /* r3 = wait time */
    /* if(r2 - r1 >= r4) */

    loop$:
        /* push {lr} */
        bl GetTimeStamp
        elapsed .req r1
        sub elapsed,currentTime,startTime
        cmp elapsed,waitTime
        .unreq elapsed
        bls loop$

    .unreq waitTime
    .unreq currentTime
    .unreq startTime
    pop {pc}
