library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity mux8to1 is
    Port ( data0 : in  STD_LOGIC_VECTOR (15 downto 0);
           data1 : in  STD_LOGIC_VECTOR (15 downto 0);
           data2 : in  STD_LOGIC_VECTOR (15 downto 0);
           data3 : in  STD_LOGIC_VECTOR (15 downto 0);
           data4 : in  STD_LOGIC_VECTOR (15 downto 0);
           data5 : in  STD_LOGIC_VECTOR (15 downto 0);
           data6 : in  STD_LOGIC_VECTOR (15 downto 0);
           data7 : in  STD_LOGIC_VECTOR (15 downto 0);
           control_signal : in  STD_LOGIC_VECTOR (2 downto 0);
           output : out  STD_LOGIC_VECTOR (15 downto 0) := "0000000000000000");
end mux8to1;

architecture Behavioral of mux8to1 is
begin
  process(data0, data1, data2, data3, data4, data5, data6, data7, control_signal)
  begin
		case control_signal is
			when "000" =>
				output <= data0;
			when "001" =>
				output <= data1;
			when "010" =>
				output <= data2;
			when "011" =>
				output <= data3;
			when "100" =>
				output <= data4;
			when "101" =>
				output <= data5;
			when "110" =>
				output <= data6;
			when "111" =>
				output <= data7;
			when others =>
				output <= "0000000000000000";
		end case;
  end process;
end Behavioral;
