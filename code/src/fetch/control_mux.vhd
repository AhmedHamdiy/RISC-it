LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.numeric_std.ALL;

ENTITY control_mux IS
    PORT (
        next_ins, pc, INT : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        pc_control : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
        control_mux_out : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
    );
END ENTITY control_mux;

ARCHITECTURE control_mux_arch OF control_mux IS
BEGIN
    PROCESS (pc_control, next_ins, pc, INT)
    BEGIN
        IF (pc_control = "10") THEN
            control_mux_out <= INT;
        ELSIF (pc_control = "11") THEN
            control_mux_out <= pc;
        ELSE
            control_mux_out <= next_ins;
        END IF;
    END PROCESS;
END ARCHITECTURE;