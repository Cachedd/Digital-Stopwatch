;--------------------- Stage3 --------------------------------------
// Press 'P' to pause
// Press 'S' to split
// Press 'A' to start
// Press 'R' to reset
;--------------------- Start --------------------------------------
MOV R0, #47 ; seconds one digit
MOV R1, #48 ; seconds tens digit
MOV R2, #48 ; minutes ones digit
MOV R3, #48 ; minutes tens digit
BL delay

mainLoop:
BL checkInput
B mainLoop
HALT

;---------------------- checkInput Function ----------------------------
checkInput: ; depending the key pressed it goes to start, stop or reset
PUSH {R11}

input:
LDR R11, .LastKeyAndReset ; loads the last key pressed into R11

CMP R11, #80 ; compares key pressed with P which is stop
BEQ stop 

CMP R11, #82 ; compares key pressed with R which is reset
BEQ reset

CMP R11, #83 ; compares key pressed with S which is split
BEQ split
B cont
;-----------------------------------------------------------------
start: ; start loop 
PUSH {LR}
BL delay ; nested loop
POP {LR}
B cont 
;-----------------------------------------------------------------
stop: ; stop loop
LDR R11, .LastKey ; loads the last key pressed again in the loop

CMP R11, #65 ; it will go to start state and increment if A is pressed
BEQ start

CMP R11, #82 ; it will reset the clock and stay stopped
BEQ reset

B stop ; keeps on looping until 'A' is pressed
;-----------------------------------------------------------------
split:
PUSH {LR}
BL splitDisplay
POP {LR}
B input
;-----------------------------------------------------------------
reset: ; reset loop
PUSH {LR}
BL resetDisplay
POP {LR}

PUSH {LR}
BL splitDisplay
POP {LR}

PUSH {LR}
BL updateDisplay
POP {LR}

B stop
;-----------------------------------------------------------------
cont:
POP {R11}
PUSH {LR}
BL increment
POP {LR}
RET

;------------------------- increment function -----------------------
// Inputs R0 - Seconds Ones, R1 - Seconds Tens, R2 - MinutesOnes, R3 - MinutesTens
increment: 
PUSH {R4, R5, R6, R7}
MOV R4, R0 ; representing the seconds ones digit --> 00:0(0)
MOV R5, R1 ; representing the seconds tens digit --> 00:(0)0
MOV R6, R2 ; representing the minutes ones digit --> 0(0):00
MOV R7, R3 ; representing the minutes tens digit --> (0)0:00

; R4 IS INCREMENTED HERE (seconds ones)
addSecondsOneloop: 
CMP R4, #57 ; 9
BEQ addSecondsTensLoop ; it needs to increment the tens place and reset the ones place

; after checking for the condition, it will increment the seconds ones place
ADD R4, R4, #1 
B display

;-----------------------------------------------------------------
// R5 is incremented here (seconds tens)
addSecondsTensLoop:
CMP R5, #53 ; 5
BEQ addMinutesOnesLoop

; after checking for the condition, it will increment the seconds tens place
MOV R4, #48 ; make the ones place zero 
ADD R5, R5, #1
B display

;-----------------------------------------------------------------
// R6 is incremented here (minutesOnes)
addMinutesOnesLoop:
CMP R6, #57 ; 9
BEQ addMinutesTensLoop

; after checking for the condition, it will increment the minutes ones place
MOV R4, #48 ; make the seconds ones place zero 
MOV R5, #48 ; makes the seconds tens place zero
ADD R6, R6, #1
B display

;-----------------------------------------------------------------
// R7 is incremented here (minutesTens)
addMinutesTensLoop:
CMP R7, #57 ; 9
BEQ resetDigits

; after checking for the condition, it will increment the minutes tens place
MOV R4, #48 ; make the seconds ones place zero 
MOV R5, #48 ; makes the seconds tens place zero
MOV R6, #48 ; makes the munites ones place zero
ADD R7, R7, #1
B display

resetDigits: ; check this and make digits zeros
PUSH {LR}
BL resetDisplay
POP {LR}
B return

display:
MOV R0, R4 ; MOVe the updated value to R0 for displaying on the screen
MOV R1, R5 ; MOVe the updated value to R1 for displaying on the screen
MOV R2, R6 ; MOVe the updated value to R2 for displaying on the screen
MOV R3, R7 ; MOVe the updated value to R0 for displaying on the screen

return:
PUSH {LR}
// add push to R0 - R3
BL updateDisplay ; updates the display
// add POP to R0 - R3
POP {LR}
POP {R4, R5, R6, R7}
RET

;--------------------- updateDisplay function -----------------------------------------
//  Inputs R0 - Seconds Ones, R1 - Seconds Tens, R2 - MinutesOnes, R3 - MinutesTens
updateDisplay: 
PUSH {R4, R5, R6, R7, R8, R9}
MOV R4, R0 ; MOVe the recieved argument to R4
MOV R5, R1 ; MOVe the digit to be updated to R5
MOV R6, R2 ; MOVe the digit to be updated to R6
MOV R7, R3 ; MOVe the digit to be updated to R7

; it then displays the character on the screen
MOV R8, #.CharScreen ; R8 is used to store CharScreen 
STRB R4, [R8 + 4] ; displays seconds ones digit
STRB R5, [R8 + 3] ; displays seconds tens digit
;-------------------
MOV R9, #58  ; MOVes ':' to display 
STRB R9, [R8 + 2]
;-------------------
STRB R6, [R8 + 1] ; displays minutes one digit after seconds tens on the display
STRB R7, [R8] ; displays minutes tens digit before ones on the display

; then it delays for one second
PUSH {LR}
BL delay
POP {LR}
POP {R4, R5, R6, R7, R8, R9}
RET

;------------------- resetDisplay function ----------------------------------
// Inputs R0 - Seconds Ones, R1 - Seconds Tens, R2 - MinutesOnes, R3 - MinutesTens
resetDisplay: 
PUSH {R4, R5, R6, R7}
MOV R4, R0 ; representing the seconds ones digit --> 00:0(0)
MOV R5, R1 ; representing the seconds tens digit --> 00:(0)0
MOV R6, R2 ; representing the minutes ones digit --> 0(0):00
MOV R7, R3 ; representing the minutes tens digit --> (0)0:00

; resets the display to 00:00
MOV R4, #48 
MOV R5, #48
MOV R6, #48
MOV R7, #48

MOV R0, R4
MOV R1, R5
MOV R2, R6
MOV R3, R7

POP {R4, R5, R6, R7}
RET

;---------------------- splitDisplay function -------------------------------------
//  Inputs R0 - Seconds Ones, R1 - Seconds Tens, R2 - MinutesOnes, R3 - MinutesTens
splitDisplay:
PUSH {R4, R5, R6, R7, R8, R9}
MOV R4, R0 ; MOVe the digit to be updated to R4
MOV R5, R1 ; MOVe the digit to be updated to R5
MOV R6, R2 ; MOVe the digit to be updated to R6
MOV R7, R3 ; MOVe the digit to be updated to R7

; it then displays the character on the screen
MOV R8, #.CharScreen ; R8 is used to store CharScreen 
STRB R4, [R8 + 10] ; displays seconds ones digit
STRB R5, [R8 + 9] ; displays seconds tens digit
;-------------------
MOV R9, #58  ; moves ':' to display 
STRB R9, [R8 + 8]
;-------------------
STRB R6, [R8 + 7] ; displays minutes one digit after seconds tens on the display
STRB R7, [R8 + 6] ; displays minutes tens digit before ones on the display

POP {R4, R5, R6, R7, R8, R9}
RET
;-------------------- delay function -----------------------------------------
delay: 
PUSH {R4, R5, R6}
LDR R4, .Time ; start time
timer:
LDR R5, .Time ; current time 
SUB R6, R5, R4 ; elapsed time = current time - start time
CMP R6, #1 ; compares with 1 sec
BLT timer
POP {R4, R5, R6}
RET
