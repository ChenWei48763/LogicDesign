LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- This component converts a 4-bit hex digit to a 7-segment display pattern.
-- 0=lit, 1=unlit (for common anode displays)
ENTITY hex_to_7seg IS
    PORT (
        hex_in  : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
        seg_out : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
END ENTITY hex_to_7seg;

ARCHITECTURE behavior OF hex_to_7seg IS
BEGIN
    PROCESS (hex_in)
    BEGIN
        CASE hex_in IS
            WHEN "0000" => seg_out <= "0000001"; -- 0
            WHEN "0001" => seg_out <= "1001111"; -- 1
            WHEN "0010" => seg_out <= "0010010"; -- 2
            WHEN "0011" => seg_out <= "0000110"; -- 3
            WHEN "0100" => seg_out <= "1001100"; -- 4
            WHEN "0101" => seg_out <= "0100100"; -- 5
            WHEN "0110" => seg_out <= "0100000"; -- 6
            WHEN "0111" => seg_out <= "0001111"; -- 7
            WHEN "1000" => seg_out <= "0000000"; -- 8
            WHEN "1001" => seg_out <= "0000100"; -- 9
            WHEN "1010" => seg_out <= "0001000"; -- A
            WHEN "1011" => seg_out <= "1100000"; -- b
            WHEN "1100" => seg_out <= "0110001"; -- C
            WHEN "1101" => seg_out <= "1000010"; -- d
            WHEN "1110" => seg_out <= "0110000"; -- E
            WHEN "1111" => seg_out <= "0111000"; -- F
            WHEN OTHERS => seg_out <= "1111111"; -- Off
        END CASE;
    END PROCESS;
END ARCHITECTURE behavior;