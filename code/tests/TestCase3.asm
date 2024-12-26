.ORG 0  #this is the reset address
200

.ORG 1  #this is the address of the empty stack exception handler
400
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

# INT1
.ORG 0A00
NOP
RTI

# Main loop
.ORG 200
IN R0           # Force FFFF on IN port
INC R1,R0       # R1 -> 0, Z -> 1, C-->1, N-->1, Z-->0
NOT R1,R1       # R1 -> FFFF, N -> 1, Z -> 0
OUT R1
IADD R0,R0,10   # R0 -> 000F, C-->1, N-->0, Z-->0
ADD R4,R0,R1    # R4 -> 000E, C -> 1, Z -> 0, N -> 0  ALU-ALU Forwarding
SUB R5,R0,R1    # R5 -> 0010, C -> 1, Z -> 0, N -> 0  Memory-ALU Forwarding
AND R6,R0,R1    # R6 -> 000F, Z -> 0, N -> 0          No forwarding
LDM R2, 300      # Function address
JC R2           # Should be executed
LDM R3, 200      # Main loop address
JMP R3          # Main loop jump, Shouldn't be executed

# Function
.ORG 300
LDM R3, 200      # Main loop address
JC R3           # Should be executed and fail
SETC            # Sets Carry Flag
MOV R7,R6       # R7 -> 000F
NOP
NOP
NOP
NOP
JZ R2           # Should be executed and fail
HLT             # Should be executed
