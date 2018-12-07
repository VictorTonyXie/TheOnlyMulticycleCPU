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
		clk: in std_logic;
		WriteMem: in std_logic_vector(1 downto 0);
		Addr: in std_logic_vector(15 downto 0);
		ToRead: out std_logic_vector(15 downto 0) := "0000000000000000";
		ToWrite: in std_logic_vector(15 downto 0);
		RamAddr: out std_logic_vector(17 downto 0) := "000000000000000000";
		RamData: inout std_logic_vector(15 downto 0);
		OE_L: out std_logic:= '1';
		WE_L: out std_logic:= '1';
		EN_L: out std_logic:= '1';
		wrn: inout std_logic:= '1';
		rdn: inout std_logic:= '1';
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
		read_done,
		write0,
		write1,
		write2,
		write3,
		write4,
		write5,
		write_done,
		done
	);
	signal write_state: main_states:= waiting;
	signal read_state: main_states:= waiting;
	signal state: main_states:= waiting;
begin
	process(RamData, write_state, read_state, Addr, data_ready)
	begin
		if (Addr = x"BF01") then
			ToRead <= x"0000";
			if (data_ready = '1') and (read_state = read0) then
				ToRead(1) <= '1';
			end if;
			if (write_state = write0) then
				ToRead(0) <= '1';
			end if;
		elsif (Addr = x"BF00") then
			ToRead <= RamData;
		else
			ToRead <= RamData;
		end if;
	end process;
	
	wrn <= wrn_i;
	rdn <= rdn_i;
			
	RamAddr <= "00" & Addr;
	
	process(clk, WriteMem, Addr, ToWrite, tbre, tsre)
	begin
		if (Addr = x"BF01") then
			--TESTW/TESTR
			OE_L <= '1';
			WE_L <= '1';
			EN_L <= '1';
			--to get data_ready and so on
			--to prepare
			if (WriteMem = "10") then
				--state changes only when instuction is lw
				write_state <= waiting;
				read_state <= waiting;
				wrn_i <= '1';
				rdn_i <= '1';
				--can read
				RamData <= "ZZZZZZZZZZZZZZZZ";
				read_state <= read0;
				if (tbre = '1') and (tsre = '1') then
					--can write
					write_state <= write0;
				end if;
			else
				write_state <= waiting;
				read_state <= waiting;
				wrn_i <= '1';
				rdn_i <= '1';
			end if;
		elsif (Addr = x"BF00") then
			--LW/SW
			OE_L <= '1';
			WE_L <= '1';
			EN_L <= '1';
			case WriteMem is
				when "10" =>
					--to read
					wrn_i <= '1';
					rdn_i <= '0';
					if rdn_i = '1' then
					RamData <= "ZZZZZZZZZZZZZZZZ";
					end if;
				when "01" =>
					--to write
					if clk'event and clk = '0' then
					wrn_i <= '0';
					end if;
					--wrn_i <= '1';
					rdn_i <= '1';
					RamData <= ToWrite;
				when others =>
					wrn_i <= '1';
					rdn_i <= '1';
					RamData <= "ZZZZZZZZZZZZZZZZ";
			end case;
		else
			EN_L <= '0';
			rdn_i <= '1';
			wrn_i <= '1';

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

