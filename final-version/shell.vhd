----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    03:39:17 12/07/2018 
-- Design Name: 
-- Module Name:    shell - Behavioral 
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

entity shell is
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
end shell;

architecture Behavioral of shell is
	component ps2test
	port(
		clk: in std_logic;
		rst: in std_logic;
		ps2_data: in std_logic;
		ps2_clk: in std_logic;
		onclick : out std_logic;
		--dyp: out std_logic_vector(7 downto 0);
		ascii_out: out std_logic_vector(7 downto 0)
	);
	end component;
	
	component vga
	Port(
		clk: in std_logic;
		rst: in std_logic;
		r: out std_logic_vector(2 downto 0) := "111";
		g: out std_logic_vector(2 downto 0) := "111";
		b: out std_logic_vector(2 downto 0) := "111";
		hs_o: out std_logic := '1';
		vs_o: out std_logic := '1';
		--DataChar indicates the char to input next time
		DataChar: in std_logic_vector(7 downto 0);
		--WriteVGA tells whether to write the char DataChar: similar to WE_L
		WriteVGA: in std_logic;
		--WE_L communicates with ram2
		WE_L: out std_logic;
		--OE_L communicates with ram2
		OE_L: out std_logic;
		RamAddr: out std_logic_vector(17 downto 0);
		RamData: inout std_logic_vector(15 downto 0)
	);
	end component;
	
	signal onclick: std_logic;
	signal ascii_out: std_logic_vector(7 downto 0);
begin
	ps2: ps2test port map(clk, rst, ps2_data, ps2_clk, onclick, ascii_out);
	screen: vga port map(clk, rst, r, g, b, hs_o, vs_o, ascii_out, onclick, WE_L, OE_L, RamAddr, RamData);

end Behavioral;

