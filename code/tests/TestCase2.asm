# all numbers in hex format
# we always start by reset signal
# this is a commented line

# all numbers in hex format
# we always start by reset signal
# this is a commented line
# you should ignore empty lines

.ORG 0  #this is the reset address
200

.ORG 1  #this is the address of the empty stack exception handler
400

.ORG 2  #this is the address of the invalid memory address exception handler
600

.ORG 6  #this is the address of INT0
800

.ORG 8  #this is the address of INT2
0A00

# Empty Stack Exception Handler
.ORG 400
NOP
HLT

# Invalid Memory Address Exception Handler
.ORG 600
NOP
HLT

# INT0
.ORG 800
NOP
RTI

# INT2
.ORG 0A00
NOP
RTI

.ORG 200
IN R1       #add 6 in R1
IN R2       #add 20 in R2
LDM R3, FFFC
LDM R4, F322
IADD R5,R3,2  #R5 = FFFE, N-->1, Z-->0
ADD  R4,R1,R4    #R4= F328 , C-->0, N-->1, Z-->0
SUB  R6,R5,R4    #R6= 0CD6 , C-->0, N-->0,Z-->0  // R6 = R5 - R4
AND  R6,R7,R6    #R6= 00000000 , C-->no change, N-->0, Z-->1
OR   R1,R2,R1    #R1=0026  , C--> no change, N-->0, Z--> 0
MOV  R3,R1    #R3=0026, no change for flags
ADD  R2,R5,R2    #R2= 001E, C-->1, N-->1, Z-->0
