class Assembler:
    def __init__(self):
        self.index = 0
        self.ram  = ["0000000000000000" for _ in range(258)]
        self.zero_operand_opcodes = {
            "NOP": "00000",
            "HLT": "00001",
            "SETC": "00010",
            "RET": "11101",
            "RTI": "11111"
        }
        self.one_operand_opcodes = {
            "IN": "00101",
            "OUT": "00110",
            "PUSH": "10000",
            "POP": "10001",
            "JZ": "11000",
            "JN": "11001",
            "JC": "11010",
            "JMP": "11011",
            "CALL": "11100",
            "INT": "11110",
        }
        self.two_operand_opcodes = {
            "NOT": "00011",
            "INC": "00100",
            "MOV": "01011",
            "LDM": "10100",
        }
        self.three_operand_opcodes = {
            "ADD": "01000",
            "SUB": "01001",
            "AND": "01010",
            "IADD": "01100",
        }
        self.four_operand_opcodes = {
            "STD": "10010",
            "LDD": "10011",
        }
        self.registers = {
            "R0": "000",
            "R1": "001",
            "R2": "010",
            "R3": "011",
            "R4": "100",
            "R5": "101",
            "R6": "110",
            "R7": "111",
        }
    
    def remove_comments_and_spaces(self,line):
        if line =="\n": #empty line
            return ""
        cleaned_line = line.split('#')[0].strip()
        return cleaned_line
    
    def read_line(self,line,index):
        cleaned_line = self.remove_comments_and_spaces(line)
        if cleaned_line == "":
            return [None,index]
        if cleaned_line[0] == ".": #handle .ORG
            return [None,int(cleaned_line.split(" ")[1])]
        return [cleaned_line.split(" ")[0],index]
    
    def get_instruction_type(self,instruction):
        instruction = instruction.upper()
        if instruction in self.zero_operand_opcodes:
            return 0
        if instruction in self.one_operand_opcodes:
            return 1
        if instruction in self.two_operand_opcodes:
            return 2
        if instruction in self.three_operand_opcodes:
            return 3
        if instruction in self.four_operand_opcodes:
            return 4
        return -1
        

    def get_opcode(self,instruction,instruction_type):
        instruction = instruction.upper()
        if instruction_type == 0:
            return self.zero_operand_opcodes[instruction]
        if instruction_type == 1:
            return self.one_operand_opcodes[instruction]
        if instruction_type == 2:
            return self.two_operand_opcodes[instruction]
        if instruction_type == 3:
            return self.three_operand_opcodes[instruction]
        if instruction_type == 4:
            return self.four_operand_opcodes[instruction]
        return -1
    
    def decimal_to_binary(self,value):
        return bin(value)[2:]
    
    def convert_immediate(self,value):
        # Convert the hexadecimal string to an integer
        num = int(value, 16)
        # Convert the integer to a binary string, pad with leading zeros to make it 16-bit
        binary_str = f"{num:016b}"
        return binary_str
    
    def check_immediate(self,value):
        if value[0] == "#":
            return True
        return False

    def assemble_zero_operand(self,instruction):
        instruction = instruction[:-1]
        instruction_slices = instruction.split(" ")
        instruction_slices[0] = instruction_slices[0].upper()
        print("zero :",instruction_slices[0])
        opcode = self.get_opcode(instruction_slices[0],0)
        instruction_out = opcode+"00000000000"
        return instruction_out

    def assemble_one_operand(self,instruction):
        instruction = instruction.upper()
        instruction = instruction[:-1]
        print("one operand:",instruction)
        instruction_slices = instruction.split(" ")
        opcode = self.get_opcode(instruction_slices[0].upper(),1)
        if (opcode == self.one_operand_opcodes["INT"]):  #INT instruction
            instruction_out = opcode + "0000000000" + instruction_slices[1]
        else:
            first_operand = self.registers[instruction_slices[1]]
            instruction_out = opcode + first_operand + "00000000"
        return instruction_out

    def assemble_two_operand(self,instruction):
        instruction = instruction.upper()
        instruction = instruction[:-1]
        print("two operand:",instruction)
        instruction_slices = instruction.split(" ")
        opcode = self.get_opcode(instruction_slices[0].upper(),2)
        if (opcode == self.two_operand_opcodes["LDM"]):  #INT instruction
            first_operand = self.registers[ instruction_slices[1][:-1]]
            instruction_out = opcode +first_operand+"00000000"
            self.ram[self.index] = instruction_out
            self.index += 1
            instruction_out = self.convert_immediate(instruction_slices[2])
        else:
            operands = instruction_slices[1].split(",")
            registers = "".join([self.registers[operand] for operand in operands])
            instruction_out = opcode + registers + "00000"
        return instruction_out

    def assemble_three_operand(self,instruction):
        instruction = instruction.upper()
        instruction = instruction[:-1]
        print("three operand:",instruction)
        instruction_slices = instruction.split(" ")
        opcode = self.get_opcode(instruction_slices[0].upper(),3)
        if (opcode == self.three_operand_opcodes["IADD"]):  #INT instruction
            operands = instruction_slices[1].split(",")
            instruction_out = opcode +self.registers[operands[0]]+self.registers[operands[1]]+"00000"
            self.ram[self.index] = instruction_out
            self.index += 1
            instruction_out = self.convert_immediate(instruction_slices[2])
        else:
            operands = instruction_slices[1].split(",")
            registers = "".join([self.registers[operand] for operand in operands])
            instruction_out = opcode +registers+ "00"
        return instruction_out


    def assemble_memory_offset_operand(self,instruction):
        instruction = instruction.upper()
        instruction = instruction[:-1]
        print("four operand:",instruction)
        instruction_slices = instruction.split(" ")
        opcode = self.get_opcode(instruction_slices[0].upper(),4)
        first_operand = instruction_slices[1][:-1]
        first_operand = self.registers[first_operand]
        immediate_value = instruction_slices[2][:instruction_slices[2].index("(")]
        print("immediate:",immediate_value)
        immediate = self.convert_immediate(immediate_value)
        print("immediate:",immediate)
        print("first operand:",first_operand)
        print(instruction_slices[2])
        second_operand = instruction_slices[2][instruction_slices[2].index('(')+1:instruction_slices[2].index(')')]
        second_operand = self.registers[second_operand]
        instruction_out = opcode +first_operand+second_operand+ "00000"
        self.ram[self.index] = instruction_out
        self.index += 1
        instruction_out = immediate
        return instruction_out

    def assemble(self,file_path):
        f = open(file_path, "r")
        lines = f.readlines()
        for line in lines:
            print("new line:",line," ,index:",self.index)
            [instruction,self.index] = self.read_line(line,self.index)
            if instruction == None:
                continue
            instruction_type = self.get_instruction_type(instruction)
            if instruction_type == 0:
                instruction = self.assemble_zero_operand(line)
            if instruction_type == 1:
                instruction = self.assemble_one_operand(line)
            if instruction_type == 2:
                instruction = self.assemble_two_operand(line)
            if instruction_type == 3:
                instruction = self.assemble_three_operand(line)
            if instruction_type == 4:
                instruction = self.assemble_memory_offset_operand(line)
            self.ram[self.index] = instruction
            self.index += 1
        f.close()
    
    def generate_instruction_memory(self,file_path):
        with open(file_path, 'w') as file: # Write each element of the array to a new line
            file.writelines('\n'.join((instruction for instruction in self.ram)))
        file.close()
        return

def main():
    assembler = Assembler()
    assembler.assemble("./code/assembler/program.txt")
    assembler.generate_instruction_memory("./code/instruction_memory.txt")
    
if __name__ == "__main__":
    main()