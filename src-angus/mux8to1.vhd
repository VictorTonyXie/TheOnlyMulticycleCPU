----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    19:14:47 11/29/2018
-- Design Name:
-- Module Name:    mux8to1 - Behavioral
-- Project Name:
-- Target Devices:
-- Tool versions:
-- Description:
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mux8to1 is
    Port ( data0 : in  STD_LOGIC_VECTOR (15 downto 0);
           data1 : in  STD_LOGIC_VECTOR (15 downto 0);
           data2 : in  STD_LOGIC_VECTOR (15 downto 0);
           data3 : in  STD_LOGIC_VECTOR (15 downto 0);
           data4 : in  STD_LOGIC_VECTOR (15 downto 0);
           data5 : in  STD_LOGIC_VECTOR (15 downto 0);
           data6 : in  STD_LOGIC_VECTOR (15 downto 0);
           data7 : in  STD_LOGIC_VECTOR (15 downto 0);
           enable : in  STD_LOGIC;
           control_signal : in  STD_LOGIC_VECTOR (2 downto 0);
           output : out  STD_LOGIC_VECTOR (15 downto 0));
end mux8to1;

architecture Behavioral of mux8to1 is
begin
	if enable = '0' then
		output <= "0000000000000000";
	else
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
	end if;
end Behavioral;
