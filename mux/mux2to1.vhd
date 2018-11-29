----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:54:12 11/29/2018 
-- Design Name: 
-- Module Name:    mux2to1 - Behavioral 
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

entity mux2to1 is
    Port ( data0 : in  STD_LOGIC_VECTOR (15 downto 0);
           data1 : in  STD_LOGIC_VECTOR (15 downto 0);
           enable : in  STD_LOGIC;
           control_signal : in  STD_LOGIC;
           output : out  STD_LOGIC_VECTOR (15 downto 0));
end mux2to1;

architecture Behavioral of mux2to1 is
begin
	if enable = '0' then
		output <= "0000000000000000";
	else
		case control_signal is
			when '0' =>
				output <= data0;
			when '1' =>
				output <= data1;
			when others =>
				output <= "0000000000000000";
		end case;
	end if;
end Behavioral;

