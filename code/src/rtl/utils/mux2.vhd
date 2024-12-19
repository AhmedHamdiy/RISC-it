LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY mux2 IS
    PORT (
        d0 : IN STD_LOGIC;
        d1 : IN STD_LOGIC;
        sel : IN STD_LOGIC;
        y : OUT STD_LOGIC
    );
END ENTITY mux2;

ARCHITECTURE mux2_arch OF mux2 IS
BEGIN
    PROCESS (d0, d1, sel)
    BEGIN
        IF sel = '0' THEN
            y <= d0;
        ELSE
            y <= d1;
        END IF;
    END PROCESS;
END ARCHITECTURE mux2_arch;