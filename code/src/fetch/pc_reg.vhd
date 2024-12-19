LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.numeric_std.ALL;

ENTITY pc_reg IS
    PORT (
        clk, rst, pc_in : IN STD_LOGIC;
        next_ins : OUT STD_LOGIC;
    );
END ENTITY pc_reg;

ARCHITECTURE pc_reg_arch OF pc_reg IS
BEGIN
    PROCESS (clk)
        IF (NOT rst AND rising_edge(clk)) THEN
            next_ins <= pc_in;
        END IF;
    END PROCESS
END ARCHITECTURE;