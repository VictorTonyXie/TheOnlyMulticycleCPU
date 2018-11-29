----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    19:33:44 11/29/2018
-- Design Name:
-- Module Name:    alu - Behavioral
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

entity alu is
    Port ( input_a : in  STD_LOGIC_VECTOR (15 downto 0);
           input_b : in  STD_LOGIC_VECTOR (15 downto 0);
           control_signal : in  STD_LOGIC;
			  zeroflag : out STD_LOGIC;
           output : out  STD_LOGIC_VECTOR (15 downto 0));
end alu;

architecture Behavioral of alu is
	variable zero : STD_LOGIC := 0;
begin
	case control_signal is
		when "000" =>
			--plus
			--ADDIU ADDIU3 ADDSP ADDU B LW LW_SP SW SW_RS SW_SP
			output <= input_a + input_b;
		when "001" =>
			--minus
			--BEQZ BNEZ BTEQZ BTNEZ CMP CMPI SLTI SLTUI SRA SUBU
			output <= input_a - input_b;
			if input_a - input_b = "0000000000000000" =>
				zero := 1;
			end if;
		when "010" =>
			--and
			--AND
			output <= input_a AND input_b;
		when "011" =>
			--or
			--OR
			output <= input_a OR input_b;
		when "100" =>
			--sll
			--SLL
			output <= input_a SLL input_b;
		when "101" =>
			--sra
			--SRA
			output <= input_a SRA input_b;
		when "110" =>
			--SLTI STLUI
			if input_a < input_b then
				output <= "1111111111111111";
			else
				output <= "0000000000000000";
			end if;
		when others =>
			--MUST NOT HAPPEN
			output <= "1010101010101010";
	end case;
	zeroflag <= zero;
end Behavioral;
