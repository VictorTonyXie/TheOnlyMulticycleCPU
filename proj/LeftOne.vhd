----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:22:30 12/02/2018 
-- Design Name: 
-- Module Name:    LeftOne - Behavioral 
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

entity LeftOne is
	Port(
		Input: in std_logic_vector(15 downto 0);
		Output: out std_logic_vector(15 downto 0)
	);
end LeftOne;

architecture Behavioral of LeftOne is

begin
	Output <= Input(14 downto 0) & "0";

end Behavioral;

