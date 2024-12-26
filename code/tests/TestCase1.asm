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
NOT R1,R1     #R1 =FFFF , C--> no change, N --> 1, Z --> 0
NOP            #No change
INC R1,R1     #R1 =0000 , C --> 1 , N --> 0 , Z --> 1
IN R1        #R1= 000E, add E on the in port, flags no change	
IN R2          #R2= 0010, add 10 on the in port, flags no change
NOT R2,R2     #R2= FFEF, C--> no change, N -->1,Z-->0
INC R1,R1     #R1= 000F, C --> 0, N -->0, Z-->0
LDM R3, 0005
SUB R2,R2,R3    #R2= FFEA, C-->1 , N-->1, Z-->0
OUT R1
OUT R2
