library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux2to1 is
    Port ( data0 : in  STD_LOGIC_VECTOR (15 downto 0);
           data1 : in  STD_LOGIC_VECTOR (15 downto 0);
           control_signal : in  STD_LOGIC;
           output : out  STD_LOGIC_VECTOR (15 downto 0));
end mux2to1;

architecture Behavioral of mux2to1 is
begin
  process
  begin
		case control_signal is
			when '0' =>
				output <= data0;
			when '1' =>
				output <= data1;
			when others =>
				output <= "0000000000000000";
		end case;
  end process;
end Behavioral;
