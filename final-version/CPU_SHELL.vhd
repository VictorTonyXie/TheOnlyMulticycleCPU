----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    07:49:36 12/07/2018 
-- Design Name: 
-- Module Name:    CPU_SHELL - Behavioral 
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

entity CPU_SHELL is
	Port (
		clk_in: in std_logic;
		ram_addr: out std_logic_vector(17 downto 0);
		ram_data: inout std_logic_vector(15 downto 0);
		we_l: out std_logic;
		oe_l: out std_logic;
		en_l: out std_logic;
		wrn: inout std_logic;
		rdn: inout std_logic;
		data_ready: in std_logic;
		tbre: in std_logic;
		tsre: in std_logic;
		l: out std_logic_vector(15 downto 0):= "0000000000000000";
		clk: in std_logic;
		rst: in std_logic;
		ps2_data: in std_logic;
		ps2_clk: in std_logic;
		r: out std_logic_vector(2 downto 0) := "111";
		g: out std_logic_vector(2 downto 0) := "111";
		b: out std_logic_vector(2 downto 0) := "111";
		hs_o: out std_logic := '1';
		vs_o: out std_logic := '1';
		--WE_L communicates with ram2
		WE_L2: out std_logic;
		--OE_L communicates with ram2
		OE_L2: out std_logic;
		RamAddr2: out std_logic_vector(17 downto 0);
		RamData2: inout std_logic_vector(15 downto 0)
	);
end CPU_SHELL;

architecture Behavioral of CPU_SHELL is
	component MultiCycleCPU
		Port(
			clk_in: in std_logic;
			ram_addr: out std_logic_vector(17 downto 0);
			ram_data: inout std_logic_vector(15 downto 0);
			we_l: out std_logic;
			oe_l: out std_logic;
			en_l: out std_logic;
			wrn: inout std_logic;
			rdn: inout std_logic;
			data_ready: in std_logic;
			tbre: in std_logic;
			tsre: in std_logic;
			l: out std_logic_vector(15 downto 0):= "0000000000000000"
		);
	end component;
	
	component shell
		Port(
			clk: in std_logic;
			rst: in std_logic;
			ps2_data: in std_logic;
			ps2_clk: in std_logic;
			r: out std_logic_vector(2 downto 0) := "111";
			g: out std_logic_vector(2 downto 0) := "111";
			b: out std_logic_vector(2 downto 0) := "111";
			hs_o: out std_logic := '1';
			vs_o: out std_logic := '1';
			--WE_L communicates with ram2
			WE_L: out std_logic;
			--OE_L communicates with ram2
			OE_L: out std_logic;
			RamAddr: out std_logic_vector(17 downto 0);
			RamData: inout std_logic_vector(15 downto 0)
		);
	end component;
begin
	cpu: MultiCycleCPU port map(clk_in, ram_addr, ram_data, we_l, oe_l, en_l, wrn, rdn, data_ready, tbre, tsre, l);
	vga: shell port map(clk, rst, ps2_data, ps2_clk, r, g, b, hs_o, vs_o, WE_L2, OE_L2, RamAddr2, RamData2);

end Behavioral;

