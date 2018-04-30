/* ********************** GetMailboxBase function ********************** */

.globl GetMailboxBase
GetMailboxBase:
    ldr r0,=0x2000B880
    mov pc,lr

/* ********************** MailboxWrite function ********************** */

.globl MailboxWrite
MailboxWrite:
    /* Validate first four bits of message are empty */
    tst r0,#0b1111
    movne pc,lr
    /* Validate mailbox is lower than 16 */
    cmp r1,#15
    movhi pc,lr

    channel .req r1
    value .req r2
    mov value,r0
    push {lr}
    bl GetMailboxBase
    mailbox .req r0

    wait1$:
        status .req r3
        ldr status,[mailbox,#0x18]
        /* Checks if high bit of status is 0 */
        tst status,#0x80000000
        .unreq status
        bne wait1$

    /* Combines value with channel */
    add value,channel
    .unreq channel

    str value,[mailbox,#0x20]
    .unreq value
    .unreq mailbox
    pop {pc}

/* ********************** MailboxRead function ********************** */

.globl MailboxRead
MailboxRead:
    cmp r0,#15
    movhi pc,lr

    channel .req r1
    mov channel,r0
    push {lr}
    bl GetMailboxBase
    mailbox .req r0

    rightmail$:
        wait2$:
            status .req r2
            /* Gets status */
            ldr status,[mailbox,#0x18]
            /* Checks taht 30th bit is 1 */
            tst status,#0x40000000
            .unreq status
            bne wait2$
        mail .req r2
        /* Loads message */
        ldr mail,[mailbox,#0]

        inchan .req r3
        /* Gets last four bits of mail == channel */
        and inchan,mail,#0b1111
        /* Checks that channel is right */
        teq inchan,channel
        .unreq inchan
        bne rightmail$
        .unreq mailbox
        .unreq channel

        /* Gets message part of mail */
        and r0,mail,#0xfffffff0
        .unreq mail
        pop {pc}
