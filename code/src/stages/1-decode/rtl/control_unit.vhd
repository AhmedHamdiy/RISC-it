LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY control_unit IS
    PORT (
        opcode : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        in_enable : OUT STD_LOGIC;
        out_enable : OUT STD_LOGIC;
        reg_write : OUT STD_LOGIC;
        mem_write : OUT STD_LOGIC;
        mem_read : OUT STD_LOGIC;
        mem_to_reg : OUT STD_LOGIC;
        alu_operation : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        is_immediate : OUT STD_LOGIC;
        stack_operation : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        branch : OUT STD_LOGIC;
        jump_type : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
        call : OUT STD_LOGIC;
        ret : OUT STD_LOGIC;
        interrupt : OUT STD_LOGIC;
        rti : OUT STD_LOGIC;
        freeze : OUT STD_LOGIC;
        store_op : OUT STD_LOGIC
    );
END control_unit;
ARCHITECTURE behavioral OF control_unit IS
    SIGNAL control_signals : STD_LOGIC_VECTOR(19 DOWNTO 0);
BEGIN
    CASE opcode IS
            -- one operand instructions
        WHEN "00001" =>
            control_signals <= x"000100"; --hlt
        WHEN "00010" =>
            control_signals <= x"000060"; --setc
        WHEN "00011" =>
            control_signals <= x"080050"; --not rd,rs
        WHEN "00100" =>
            control_signals <= x"080040"; --inc rd,rs
        WHEN "00101" =>
            control_signals <= x"080002"; --in rd
        WHEN "00110" =>
            control_signals <= x"000001"; --out rs
            -- two operand instructions
        WHEN "01000" =>
            control_signals <= x"080000"; --add rd,rs,rt
        WHEN "01001" =>
            control_signals <= x"080010"; --sub rd,rs,rt
        WHEN "01010" =>
            control_signals <= x"080020"; --and rd,rs,rt
        WHEN "01011" =>
            control_signals <= x"080030"; --mov rd,rs
        WHEN "01100" =>
            control_signals <= x"080080"; --iadd rd,rs,imm
            -- memory instructions
        WHEN "10000" =>
            control_signals <= x"04000C"; --push rs
        WHEN "10001" =>
            control_signals <= x"0B0008"; --pop rd
        WHEN "10010" =>
            control_signals <= x"140080"; --std rs,offset(rt)
        WHEN "10011" =>
            control_signals <= x"0B0080"; --ld rd,offset(rs)
        WHEN "10100" =>
            control_signals <= x"0B00F0"; --ldm rd,imm
            -- branch instructions
        WHEN "11000" =>
            control_signals <= x"003800"; --jz rd
        WHEN "11001" =>
            control_signals <= x"002800"; --jn rd
        WHEN "11010" =>
            control_signals <= x"001800"; --jc rd
        WHEN "11011" =>
            control_signals <= x"000800"; --jmp rd
        WHEN "11100" =>
            control_signals <= x"04040C"; --call rs
        WHEN "11101" =>
            control_signals <= x"020208"; --ret
        WHEN "11110" =>
            control_signals <= x"04800C"; --int index
        WHEN "11111" =>
            control_signals <= x"024008"; --rti
        WHEN OTHERS =>
            control_signals <= x"000000"; --nop
    END CASE
    out_enable <= control_signals(0);
    in_enable <= control_signals(1);
    stack_operation <= control_signals(3 DOWNTO 2);
    alu_operation <= control_signals(6 DOWNTO 4);
    is_immediate <= control_signals(7);
    freeze <= control_signals(8);
    ret <= control_signals(9);
    call <= control_signals(10);
    branch <= control_signals(11);
    jump_type <= control_signals(13 DOWNTO 12);
    rti <= control_signals(14);
    interrupt <= control_signals(15);
    mem_to_reg <= control_signals(16);
    mem_read <= control_signals(17);
    mem_write <= control_signals(18);
    reg_write <= control_signals(19);
    store_op <= control_signals(20);
END behavioral;