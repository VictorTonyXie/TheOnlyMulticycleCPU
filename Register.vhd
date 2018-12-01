----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:52:59 12/01/2018 
-- Design Name: 
-- Module Name:    Register - Behavioral 
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

entity SpecRegister is
	Port(
		Enable: in std_logic;
		Clk: in std_logic;
		Input: in std_logic_vector(15 downto 0);
		Output: out std_logic_vector(15 downto 0)
	);
end SpecRegister;

architecture Behavioral of SpecRegister is
	--signal Data: std_logic_vector(15 downto 0);
begin
	--Output <= Data;

	process(Clk)
	begin
		if rising_edge(Clk) and Enable = '1' then
			--Data <= Input;
			Output <= Input;
		end if;
	end process;

end Behavioral;

