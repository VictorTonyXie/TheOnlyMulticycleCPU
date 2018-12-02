----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:57:56 12/01/2018 
-- Design Name: 
-- Module Name:    Memorizer - Behavioral 
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

entity Memorizer is
	Port(
		WriteMem: in std_logic;
		Addr: in std_logic_vector(15 downto 0);
		ToRead: out std_logic_vector(15 downto 0);
		ToWrite: in std_logic_vector(15 downto 0);
		RamAddr: out std_logic_vector(17 downto 0);
		RamData: inout std_logic_vector(15 downto 0);
		OE_L: out std_logic;
		WE_L: out std_logic
	);
end Memorizer;

architecture Behavioral of Memorizer is

begin
	RamAddr <= "00" & Addr;
	
	ToRead <= RamData;

	process(WriteMem)
	begin
		if WriteMem = '0' then
			--todo: write memory
			OE_L <= '1';
			WE_L <= '0';
			RamData <= ToWrite;
		else
			--todo: read memory
			OE_L <= '0';
			WE_L <= '1';
			RamData <= "ZZZZZZZZZZZZZZZZ";
		end if;
	end process;

end Behavioral;

