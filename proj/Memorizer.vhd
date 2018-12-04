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
	signal data_temp: std_logic_vector(15 downto 0);
	type main_states is (
		waiting,
		read0,
		read1,
		read2,
		read3,
		read4,
		read5,
		write0,
		write1,
		write2,
		write3,
		write4,
		write5,
		done
	);
	signal write_state: main_states:= waiting;
	signal read_state: main_states:= waiting;
	signal state: main_states:= waiting;
begin
	rdn <= rdn_i;
	wrn <= wrn_i;
	
	process(RamData, state)
	begin
		if (Addr = x"BF01") or (Addr = x"BF00") then
			case state is
				when write1 => ToRead <= x"0001";
				when read1 => ToRead <= x"0002";
				when others => ToRead <= RamData;
			end case;
		else
			ToRead <= RamData;
		end if;
	end process;
	
	process(WriteMem, ToWrite, Addr)
	begin
		if (Addr = x"BF01") or (Addr = x"BF00") then
			EN_L <= '1';
			WE_L <= '1';
			OE_L <= '1';
			--judge whether to promote state until being able to s/l com
			case state is
				when waiting =>
					state <= write0;
				when write0 =>
					if (tsre = '1') and (tbre = '1') then
						--can write--state change => toread=0x0001
						state <= write1;
					else
						--cannot write
						state <= read0;
					end if;
				when write1 =>
					--do SW
					state <= waiting;
					wrn_i <= '0';
					RamData <= ToWrite;
				when read0 =>
					if (data_ready = '1') then
						--can read
						state <= read1;--state change => toread=0x0002
						RamData <= "ZZZZZZZZZZZZZZZZ";
					else
						--cannot read
						state <= waiting;
					end if;
				when read1 =>
					--do LW
					state <= waiting;
					rdn_i <= '0';
				when others => null;
			end case;
		else
			EN_L <= '0';
			rdn_i <= '1';
			wrn_i <= '1';
			
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

