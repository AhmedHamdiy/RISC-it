LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

LIBRARY std;
USE std.textio.ALL;

ENTITY instruction_memory IS
    PORT (
        clk : IN STD_LOGIC;
        address : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        inst : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
        first_inst : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
        empty_stack : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
        invalid_mem_add : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
        INT0 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
        INT2 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0')
    );
END ENTITY instruction_memory;

ARCHITECTURE instruction_memory_arch OF instruction_memory IS
    CONSTANT mem_depth : INTEGER := 4096;
    CONSTANT word_width : INTEGER := 16;
    TYPE ram_type IS ARRAY(mem_depth - 1 DOWNTO 0) OF STD_LOGIC_VECTOR (word_width - 1 DOWNTO 0);

    IMPURE FUNCTION init_ram_from_file RETURN ram_type IS
        FILE ram_file : TEXT OPEN READ_MODE IS "instruction_memory.txt";
        VARIABLE text_line : LINE;
        VARIABLE ram_content : ram_type;
        VARIABLE bv : BIT_VECTOR(word_width - 1 DOWNTO 0);
        VARIABLE i : INTEGER := 0;
    BEGIN
        WHILE NOT ENDFILE(ram_file) LOOP
            READLINE(ram_file, text_line);
            READ(text_line, bv);
            ram_content(i) := TO_STDLOGICVECTOR(bv);
            i := i + 1;
        END LOOP;
        RETURN ram_content;
    END FUNCTION;
    SIGNAL ram : ram_type := init_ram_from_file;
BEGIN

    PROCESS (address)
    BEGIN
        IF (TO_INTEGER(UNSIGNED(address)) < mem_depth) THEN
            inst <= ram(TO_INTEGER(UNSIGNED(address)));
        ELSE
            inst <= (OTHERS => '0');
        END IF;
    END PROCESS;
    first_inst <= ram(0);
    empty_stack <= ram(1);
    invalid_mem_add <= ram(2);
    INT0 <= ram(3);
    INT2 <= ram(4);
END ARCHITECTURE;