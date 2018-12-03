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
		WriteMem: in std_logic_vector(1 downto 0);
		Addr: in std_logic_vector(15 downto 0);
		ToRead: out std_logic_vector(15 downto 0) := "0000000000000000";
		ToWrite: in std_logic_vector(15 downto 0);
		RamAddr: out std_logic_vector(17 downto 0) := "000000000000000000";
		RamData: inout std_logic_vector(15 downto 0);
		OE_L: out std_logic;
		WE_L: out std_logic;
		EN_L: out std_logic;
		wrn: out std_logic;
		rdn: out std_logic;
		data_ready: in std_logic;
		tbre: in std_logic;
		tsre: in std_logic
	);
end Memorizer;

architecture Behavioral of Memorizer is
	signal rdn_i, wrn_i: std_logic:= '1';
	type write_states is (
		write_init,
		write_set,
		write_end
	);
	signal write_state: write_states:= write_init;
begin
	rdn <= rdn_i;
	wrn <= wrn_i;
	ToRead <= RamData;
	
	process(WriteMem, ToWrite, Addr, data_ready)
	begin
		if (Addr = x"BF01") or (Addr = x"BF00") then
			EN_L <= '1';
			WE_L <= '1';
			OE_L <= '1';
			if (WriteMem = "01") and (tbre = '1') and (tsre = '1') then
				RamData <= ToWrite;
				wrn_i <= '0';
				rdn_i <= '1';
			elsif (WriteMem = "10") and (data_ready = '1') then
				RamData <= "ZZZZZZZZZZZZZZZZ";
				wrn_i <= '1';
				rdn_i <= '0';
			else
				RamData <= "ZZZZZZZZZZZZZZZZ";
				wrn_i <= '1';
				rdn_i <= '1';
			end if;
		else
			EN_L <= '0';
			rdn_i <= '1';
			wrn_i <= '1';
			write_state <= write_init;
			
			RamAddr <= "00" & Addr;

			if WriteMem = "01" then
				--todo: write memory
				OE_L <= '1';
				WE_L <= '0';
				RamData <= ToWrite;
			elsif WriteMem = "10" then
				--todo: read memory
				OE_L <= '0';
				WE_L <= '1';
				RamData <= "ZZZZZZZZZZZZZZZZ";
			else
				OE_L <= '1';
				WE_L <= '1';
				RamData <= "ZZZZZZZZZZZZZZZZ";
			end if;
		end if;
	end process;

end Behavioral;

