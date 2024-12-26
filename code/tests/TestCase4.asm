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
LDM R2, FE19        #R2=FE19 add FE19 in R2
LDM R3, FFFF        #R3=FFFF
LDM R4, F320        #R4=F320
IN  R1    	    #R1=F5
PUSH R1      	    #SP=FFE, M[0FFF] = F5
PUSH R2      	    #SP=FFD, M[FFE] = FE19
POP R1       	    #SP=FFE, R1 = FE19
POP R2       	    #SP=FFF, R2 = F5
LDM R0, 01B0
STD R2, 50(R0)    #M[200] = F5
STD R1, 51(R0)    #M[201] = FE19
LDD R3, 51(R0)    #R3 = FE19
LDD R4, 50(R0)    #R4 = F5
STD R3, 0(R4)     #M[F5] = FE19
STD R4, 0(R4)     #M[F5] = F5
LDD R5, 0(R4)     #R5 = F5
