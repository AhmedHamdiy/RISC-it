LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY mux IS
    PORT (
        sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
        d0, d1, d2, d3 : IN STD_LOGIC;
        y : OUT STD_LOGIC
    );
END mux;

ARCHITECTURE Behavioral OF mux IS
BEGIN
    PROCESS (sel, d0, d1, d2, d3)
    BEGIN
        CASE sel IS
            WHEN "00" =>
                y <= d0;
            WHEN "01" =>
                y <= d1;
            WHEN "10" =>
                y <= d2;
            WHEN "11" =>
                y <= d3;
            WHEN OTHERS =>
                y <= '0';
        END CASE;
    END PROCESS;
END Behavioral;