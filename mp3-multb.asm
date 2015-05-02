ORIGIN 0
SEGMENT CODE:
MULT1:
    LEA R0, DATA
    LDR R1, R0, ONE
    LDR R2, R0, TEN
    LDR R7, R0, ONE
ADDLOOP: 
    ADD R3, R3, R1
    ADD R2, R2, -1    
    BRp ADDLOOP
MULT2:
	AND R3, R3, 0
	LDR R1, R0, OVERFLOW
	LDR R2, R0, FOUR
    LDR R7, R0, TWO
ADDLOOP2:
	ADD R3, R3, R1
	ADD R2, R2, -1
	BRp ADDLOOP2
MULT3:
    AND R3, R3, 0
    LDR R1, R0, NEG1
    LDR R2, R0, NEG2
    NOT R1, R1
    ADD R1, R1, 1
    NOT R2, R2
    ADD R2, R2, 1
ADDLOOP3:
    ADD R3, R3, R1
    ADD R2, R2, -1
    BRp ADDLOOP3
HALT:
    BRnzp HALT

SEGMENT DATA:
    ONE: DATA2 4x0001
    TWO: DATA2 4x0002
    THREE: DATA2 4x0003
    FOUR: DATA2 4X0004
    TEN: DATA2 4x000A
    OVERFLOW: DATA2 4xABCD
    NEG1: DATA2 4xFFFF
    NEG2: DATA2 4xFFFE

