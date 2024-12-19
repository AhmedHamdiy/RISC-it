LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY tb_mux4to1 IS
END tb_mux4to1;

ARCHITECTURE Behavioral OF tb_mux4to1 IS
    COMPONENT mux4to1
        PORT (
            sel : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            d0, d1, d2, d3 : IN STD_LOGIC;
            y : OUT STD_LOGIC
        );
    END COMPONENT;

    SIGNAL sel : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL d0, d1, d2, d3 : STD_LOGIC;
    SIGNAL y : STD_LOGIC;

BEGIN
    uut : mux4to1
    PORT MAP(
        sel => sel,
        d0 => d0,
        d1 => d1,
        d2 => d2,
        d3 => d3,
        y => y
    );

    stimulus : PROCESS
    BEGIN
        d0 <= '0';
        d1 <= '1';
        d2 <= '0';
        d3 <= '1';

        -- Test case 1: sel = "00"
        sel <= "00";
        WAIT FOR 10 ns;

        -- Test case 2: sel = "01"
        sel <= "01";
        WAIT FOR 10 ns;

        -- Test case 3: sel = "10"
        sel <= "10";
        WAIT FOR 10 ns;

        -- Test case 4: sel = "11"
        sel <= "11";
        WAIT FOR 10 ns;

        WAIT;
    END PROCESS;
END Behavioral;