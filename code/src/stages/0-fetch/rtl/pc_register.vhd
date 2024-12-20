LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.numeric_std.ALL;

ENTITY pc_reg IS
    PORT (
        pc_in : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        enable, clk : IN STD_LOGIC;
        next_ins_address : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
    );
END ENTITY pc_reg;

ARCHITECTURE pc_reg_arch OF pc_reg IS
BEGIN
    PROCESS (clk)
    BEGIN
        IF (RISING_EDGE(clk)) THEN
            IF (enable = '0') THEN
                next_ins_address <= pc_in;
            END IF;
        END IF;
    END PROCESS;
END ARCHITECTURE;