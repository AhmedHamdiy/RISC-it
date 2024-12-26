LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY mux2to1_16bit IS
    PORT (
        d0 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        d1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        sel : IN STD_LOGIC;
        y : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
END mux2to1_16bit;

ARCHITECTURE mux2to1_16bit_arch OF mux2to1_16bit IS
BEGIN
    PROCESS (d0, d1, sel)
    BEGIN
        IF sel = '0' THEN
            y <= d0;
        ELSE
            y <= d1;
        END IF;
    END PROCESS;
END mux2to1_16bit_arch;