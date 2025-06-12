LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY lab8 IS
    PORT (
		  Clock	  : IN STD_LOGIC; 
		  Reset	  : IN STD_LOGIC; 
        SW       : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

        -- Outputs to 7-Segment Displays
        HEX0, HEX1, HEX2, HEX3, HEX4, HEX5 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
END ENTITY lab8;

ARCHITECTURE behavioral OF lab8 IS

    COMPONENT hex_to_7seg IS
        PORT (
            hex_in  : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
            seg_out : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
        );
    END COMPONENT;

    -- Register File: 4 registers, 8 bits each
    TYPE T_REGISTER_FILE IS ARRAY (0 TO 3) OF STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL s_registers : T_REGISTER_FILE := (OTHERS => (OTHERS => '0'));

    -- Signals for display
    SIGNAL s_rs_display_addr, s_rt_display_addr : STD_LOGIC_VECTOR(1 DOWNTO 0) := "00";
    SIGNAL s_rs_val_to_display, s_rt_val_to_display : STD_LOGIC_VECTOR(7 DOWNTO 0);

    -- Signals for button handling
    SIGNAL s_exec_key_q1, s_exec_key_q2, s_exec_key_q3 : STD_LOGIC;
    SIGNAL s_exec_pulse : STD_LOGIC;

BEGIN

    --==================================================================
    -- I/O & Display Connections
    --==================================================================
    s_rs_val_to_display <= s_registers(TO_INTEGER(UNSIGNED(s_rs_display_addr)));
    s_rt_val_to_display <= s_registers(TO_INTEGER(UNSIGNED(s_rt_display_addr)));

    -- Display BUS value (SW[7:0]) on HEX1, HEX0
    disp_bus_h: hex_to_7seg PORT MAP(hex_in => SW(7 DOWNTO 4), seg_out => HEX1);
    disp_bus_l: hex_to_7seg PORT MAP(hex_in => SW(3 DOWNTO 0), seg_out => HEX0);

    -- Display Rs value on HEX3, HEX2
    disp_rs_h: hex_to_7seg PORT MAP(hex_in => s_rs_val_to_display(7 DOWNTO 4), seg_out => HEX3);
    disp_rs_l: hex_to_7seg PORT MAP(hex_in => s_rs_val_to_display(3 DOWNTO 0), seg_out => HEX2);

    -- Display Rt value on HEX5, HEX4
    disp_rt_h: hex_to_7seg PORT MAP(hex_in => s_rt_val_to_display(7 DOWNTO 4), seg_out => HEX5);
    disp_rt_l: hex_to_7seg PORT MAP(hex_in => s_rt_val_to_display(3 DOWNTO 0), seg_out => HEX4);

    PROCESS (Reset, Clock)        
        -- Local variables for instruction decoding
        VARIABLE v_instruction : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE v_data_bus    : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE v_opcode      : STD_LOGIC_VECTOR(3 DOWNTO 0);
        VARIABLE v_rs_addr     : STD_LOGIC_VECTOR(1 DOWNTO 0);
        VARIABLE v_rt_addr     : STD_LOGIC_VECTOR(1 DOWNTO 0);
        
        -- Local variables for calculation
        VARIABLE v_rs_val, v_rt_val, v_result : STD_LOGIC_VECTOR(7 DOWNTO 0);
        VARIABLE v_rs_addr_int, v_rt_addr_int : INTEGER;
    BEGIN
        IF Reset = '1' THEN
            -- Asynchronous Reset
            s_registers <= (OTHERS => (OTHERS => '0'));
            s_rs_display_addr <= "00";
            s_rt_display_addr <= "00";

        ELSIF rising_edge(Clock) THEN
            -- 只在偵測到按鈕脈衝時才執行
                
				 -- Step 1: 在脈衝當下，鎖存 (Latch) 所有來自開關的輸入值
				 v_instruction := SW(15 DOWNTO 8);
				 v_data_bus    := SW(7 DOWNTO 0);
				 
				 -- Step 2: 從鎖存的指令中解碼
				 v_opcode  := v_instruction(7 DOWNTO 4);
				 v_rs_addr := v_instruction(3 DOWNTO 2);
				 v_rt_addr := v_instruction(1 DOWNTO 0);

				 -- Step 3: 更新七段顯示器的位址指針
				 s_rs_display_addr <= v_rs_addr;
				 s_rt_display_addr <= v_rt_addr;
				 
				 -- Step 4: 讀取暫存器目前的值以供運算
				 v_rs_addr_int := TO_INTEGER(UNSIGNED(v_rs_addr));
				 v_rt_addr_int := TO_INTEGER(UNSIGNED(v_rt_addr));
				 v_rs_val := s_registers(v_rs_addr_int);
				 v_rt_val := s_registers(v_rt_addr_int);

				 -- Step 5: 根據 Opcode 執行指令並更新暫存器
				 CASE v_opcode IS
					  WHEN "0000" => s_registers(v_rs_addr_int) <= v_data_bus;
					  WHEN "0001" => s_registers(v_rs_addr_int) <= v_rt_val;
					  WHEN "0010" => s_registers(v_rs_addr_int) <= STD_LOGIC_VECTOR(UNSIGNED(v_rs_val) + UNSIGNED(v_rt_val));
					  WHEN "0011" => s_registers(v_rs_addr_int) <= v_rs_val AND v_rt_val;
					  WHEN "0101" => s_registers(v_rs_addr_int) <= STD_LOGIC_VECTOR(UNSIGNED(v_rs_val) - UNSIGNED(v_rt_val));
					  WHEN "1001" => s_registers(v_rs_addr_int) <= STD_LOGIC_VECTOR(UNSIGNED(v_rt_val) - UNSIGNED(v_rs_val));
					  WHEN "0100" =>
							IF (UNSIGNED(v_rs_val) < UNSIGNED(v_rt_val)) THEN
								 s_registers(v_rs_addr_int) <= "00000001";
							ELSE
								 s_registers(v_rs_addr_int) <= "00000000";
							END IF;
					  WHEN OTHERS => NULL;
				 END CASE;
        END IF;
    END PROCESS;

END ARCHITECTURE behavioral;