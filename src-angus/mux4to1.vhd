library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity mux4to1 is
    Port ( data0 : in  STD_LOGIC_VECTOR (15 downto 0);
           data1 : in  STD_LOGIC_VECTOR (15 downto 0);
           data2 : in  STD_LOGIC_VECTOR (15 downto 0);
           data3 : in  STD_LOGIC_VECTOR (15 downto 0);
           control_signal : in  STD_LOGIC_VECTOR (1 downto 0);
           output : out  STD_LOGIC_VECTOR (15 downto 0));
end mux4to1;

architecture Behavioral of mux4to1 is
begin
  process(data0, data1, data2, data3, control_signal)
  begin
		case control_signal is
			when "00" =>
				output <= data0;
			when "01" =>
				output <= data1;
			when "10" =>
				output <= data2;
			when "11" =>
				output <= data3;
      when others =>
        output <= "0000000000000000";
		end case;
  end process;
end Behavioral;
