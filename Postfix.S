.data

.balign 4
return: .word 0

.balign 4
operations: .asciz "+-*/^"

.balign 4
    output: .space 100

.balign 4
    spa: .asciz " "

.balign 4
    operators: .asciz "+-o*/o()^"
.balign 4
    prefix: .space 100

.balign 4
     message: .asciz "hello\n"
.text
.global printf

.global main

main:
    ldr r0, [r1, #4] //load address of first character in expression
    ldr r1, =return
    str lr, [r1] //store r1 in lr
    ldr r2,=output //load address of output on r2
    ldr r3, =spa //load address of space variable
    ldrb r3, [r3] //load character ' ' onto r3

loop:
    ldrb r7, [r0]
    cmp r7, #0 //check if reached end of input
    beq pref //if so go to end
    ldr r1, =operations //load the address of  operations string in r1

loop2:;
    ldrb r7, [r1]
    cmp r7, #0 //check if reached end of operation string
    beq loop4 //means the current character in output isn't an operator
    ldrb r5, [r1] //else load value of r1 in r5, the current operator
    ldrb r6, [r0] //load current value in input string to r6
    cmp r5, r6 //compare the two values
    beq loop3 //if equal go to loop3
    add r1, r1, #1 //if not increment address of r1
    b loop2 //start next iteration of loop2

loop3:
    strb r3, [r2] //since current character is an operator, store space first
    add r2, r2, #1 //increment address of r2 by one to get to next slot in array
    b loop4 //on output string. Then go to loop4

loop4:
    strb r6, [r2] //store the current character, stored in r6, in r2
    add r0, r0, #1 //increment address of r0 by 1 to get to next character
    add r2, r2, #1 //increment address of r2 by one to get to next slot in array
    b loop //start next iteration of loop

pref:
    ldr r0, =output
    ldr r1, =prefix
    mov r3, #0
    mov r4, #0
loop5:
    ldrb r7, [r0] //load current character of infix to r7
    cmp r7, #0 //if reached end, r7 = 0, go to end
    beq end
    ldr r2, =operators //load address of operators to r2
    mov r5, #0 //keeps track of index in operator

loop6:
    ldrb r7,[r2] //load current character of operators to r7
    cmp r7, #0 //if reached end go to loop 7
    beq loop7
    ldrb r8, [r0] //load current character of infix to r8
    cmp r7, r8 //compare character in operator to current character in infix
    beq loop8 //if equal go to loop8
    add r2, r2, #1 //increment address of operators by 1
    add r5, r5, #1 //increment index by 1
    b loop6 //go through next iteration of loop6

loop7:
    strb r8, [r1] //since r8 not an operator store it in r1
    add r1, r1, #1 //increment address of prefix by 1
    add r0, r0, #1 //increment address of infix expression by 1
    b loop5 //go to next iteration of loop5

loop8:
    cmp r8, #40 //check if current character is (
    streq r8, [sp, #-4]! //if it is store it on stack
    cmp r8, #40 
    add r3, r3, #1 //and if it is (, increment size of stack by 1
    cmp r3, #1 //if stack was empty
    moveq r4, r8 //save the last element in stack to r4
    cmp r8, #40 //after that,increment address of infix expression by 1
    addeq r0, r0, #1 
    cmp r8, #40 //then go back to loop5
    beq loop5
    cmp r8, #41 //if current character is ) 
    beq loop9 //go to loop9
    b loop11 //else go to loop11

loop9:
    sub r7, r4, #40 //r7 is 0 if r4 is (, nonzero otherwise
    mul r9, r7, r3  //r9 is 0 if either r7 or r4 are 0
    cmp r9, #0 //if r4 is ( or the stack is empty
    beq loop11 //go to loop10
    ldrb r9, [sp], #4 //pop off the stack and store it in r9
    strb r9, [r1] //store r9 in current address of prefix expression
    add r1, r1, #1 //increment address of prefix expression by 1
    sub r3, r3, #1 //subtract size of stack by 1
    b loop9 //begin next iteration of loop9

loop10:
    ldrb r9, [sp, #-4]! //pop off stack
    sub r3, r3, #1 //subtract size of stack by 1
    add r0, r0, #1 //increment address of infix expression by 1
    b loop5 //begin next iteration of loop5

loop11:
    sub r7, r4, #40 //r7 is 0 if r4 is (, nonzero otherwise
    ldr r6, =operators //load address of operators in r6
    mov r9, #0 //current index of operators

loop12:
    ldr r10, [r6] //load current character of operators onto r10
    cmp r10, #0 //check if reached end of operators string
    beq loop13 //if so go to loop13
    cmp r10, r4 //compare current character of operators to character at end of stack
    beq loop13 //if equal go to loop 13
    add r9, r9, #1
    add r6, r6, #1 //increment address of operators string
    b loop12 //start next iteration of loop12

loop13:
    cmp r8, #94 //this is just an adjustment thing
    subeq r5, r5, #3 //since () aren't operators
    sub r10, r5, r9 //store difference priority num of current char in infix from that of end of stack character
    cmp r10, #1 //if priority difference greater than one, mov r10 to 0
    movgt r10, #0 
    mul r9, r10, r3 //sets up and statements, r9 is 0 if r10 or length of stack is 0
    mul r10, r9, r7 //r10 is 0 if r9 is 0 or current character is 0
    cmp r10, #0     //check if r10 is 0
    beq loop14   //if it is exit out of loop 13
    ldrb r10, [sp], #4 //else pop off stack pointer
    strb r10, [r1] //store that value in the current address of prefix
    add r1, r1, #1 //increment address of r1
    sub r3, r3, #1 //decrement length of stack
    b loop11 //start while loop again

loop14:
    strb r8, [sp, #-4]! //store current character in infix to stack
    add r3, r3, #1 //increment size of stack
    cmp r3, #1 //if stack was empty 
    moveq r4, r8 //store last element of stack in r4
    add r0, r0, #1 //increment address of infix expression
    b loop5 //go all the way back to loop5

end:
    cmp r3, #0 //if size is 0
    beq terminate //go to terminate
    ldrb r5, [sp], #4 //else store top of stack on r5
    strb r5, [r1] //store value of r5 in current address of prefix expression
    add r1, r1, #1 //increment address of prefix expression by 1
    sub r3, r3, #1 //decrement size of stack by 1
    b end //start next iteration of end
terminate:
    ldr r0, =prefix //load address of prefix onto r0
    bl printf //print it out
    ldr lr, =return //restore link register
    ldr lr, [lr]
    bx lr
   
