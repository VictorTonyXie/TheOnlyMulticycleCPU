----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    03:22:17 12/06/2018 
-- Design Name: 
-- Module Name:    vga - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity vga is
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
end vga;

architecture Behavioral of vga is
	--when
	--clk_d = '0': visit/write char
	--clk_d = '1': visit pixel
	signal clk_d: std_logic:= '1';
	signal cnt_col: std_logic_vector(15 downto 0);
	signal cnt_row: std_logic_vector(15 downto 0);
	signal hs, vs: std_logic;
	
	signal to_write_data: std_logic_vector(15 downto 0);
	signal wait_for_write: std_logic := '0';
	signal start_row: std_logic_vector(3 downto 0) := "0000";
	signal char_row: std_logic_vector(3 downto 0);
	signal char_col: std_logic_vector(5 downto 0);
	signal write_row: std_logic_vector(3 downto 0) := "0000";
	signal write_col: std_logic_vector(5 downto 0) := "000000";
	signal pixel_row: std_logic_vector(4 downto 0);
	signal pixel_col: std_logic_vector(3 downto 0);
	signal wait_for_flush: std_logic_vector(5 downto 0);--cols that wait to be set null
	signal has_flush: std_logic_vector(5 downto 0);--cols that has been flushed
	
	signal to_read: std_logic_vector(15 downto 0);
	signal whether_wait: std_logic := '0';
	
	--is_enable: whether the next pixel should be white
	signal is_enable: std_logic;
	
	--for test
	signal write_vga: std_logic;
	
	--for temp_write
	signal to_write_row: std_logic_vector(3 downto 0) := "0000";
	signal to_write_col: std_logic_vector(5 downto 0) := "000000";
	signal to_start_row: std_logic_vector(3 downto 0) := "0000";
	
	--init
	signal init: std_logic := '0';
	signal init_addr: std_logic_vector(10 downto 0) := "00000000000";
	
	signal wel, oel: std_logic;
begin
	WE_L <= wel;
	OE_L <= oel;

	process(WriteVGA)
	begin
		--write a char
		if falling_edge(WriteVGA) then
			to_start_row <= start_row;
			to_write_col <= write_col;
			to_write_row <= write_row;
			wait_for_write <= not wait_for_write;
			to_write_data <= "00000000" & DataChar;
			if DataChar = "00001000" then
				if write_col > "000000" then
					write_col <= write_col - "000001";
				elsif write_row > "0000" then
					write_col <= "100111";
					write_row <= write_row - "0001";
				end if;
			elsif write_col = "100111" or DataChar = "00001010" then
				--new line when a line ends or the input is \n
				wait_for_flush <= wait_for_flush + "111111";--delete the chars in the new line: total forty chars
				if write_row /= "1110" then
					write_row <= write_row + "0001";
				else
					to_write_row <= write_row;
					if start_row = "1110" then
						start_row <= "0000";
					else
						start_row <= start_row + "0001";
					end if;
				end if;
				write_col <= "000000";
			else
				to_write_row <= write_row;
				write_col <= write_col + "0001";
			end if;
		end if;
	end process;

	hs_o <= hs;
	vs_o <= vs;
	
	calc_charpos: process(cnt_col, cnt_row)
	begin
		--calculate char_row and char_col
		pixel_row <= cnt_row(4 downto 0);
		pixel_col <= cnt_col(3 downto 0);
		char_row <= cnt_row(8 downto 5);
		char_col <= cnt_col(9 downto 4);
	end process;

	clk_divide: process(clk)
	begin
		if rising_edge(clk) then
			clk_d <= not clk_d;
		end if;
	end process;
	
	to_read <= RamData;
	
	visit_ram: process(clk)
	begin
		if rising_edge(clk) then
			if init_addr /= "10000000000" then
				RamAddr <= "0000100" & init_addr;
				if wel = '1' then
					wel <= '0';
					init_addr <= init_addr + "00000000001";
				else
					wel <= '1';
				end if;
				oel <= '1';
				RamData <= x"0000";
			else
				case clk_d is
					when '0' =>
						--visit char
						if has_flush = wait_for_flush then
							if wait_for_write = whether_wait then
								--read char ascii
								wel <= '1';
								oel <= '0';
								if char_row < "1111" - start_row then
									RamAddr <= "00001000" & (start_row + char_row) & char_col;
								else
									RamAddr <= "00001000" & (start_row - ("1111" - char_row)) & char_col;
								end if;
								RamData <= "ZZZZZZZZZZZZZZZZ";
							else
								--write char ascii
								wel <= '0';
								oel <= '1';
								if to_write_row < "1111" - to_start_row then
									RamAddr <= "00001000" & (to_start_row + to_write_row) & to_write_col;
								else
									RamAddr <= "00001000" & (to_start_row - ("1111" - to_write_row)) & to_write_col;
								end if;
								RamData <= to_write_data;
								whether_wait <= not whether_wait;
							end if;
						else
							--flush the line
							wel <= '0';
							oel <= '1';
							if write_row < "1111" - start_row then
								RamAddr <= "00001000" & (start_row + write_row) & (wait_for_flush - has_flush - "000001");
							else
								RamAddr <= "00001000" & (start_row - ("1111" - write_row)) & (wait_for_flush - has_flush - "000001");
							end if;
							RamData <= "0000000000000000";
							has_flush <= has_flush + "000001";
						end if;
					when '1' =>
						--read pixel
						wel <= '1';
						oel <= '0';
						RamAddr <= "00000" & to_read(7 downto 0) & pixel_row;
						RamData <= "ZZZZZZZZZZZZZZZZ";
					when others =>
						wel <= '1';
						oel <= '1';
				end case;
			end if;
		end if;
	end process;
	
	process(clk_d)
	begin
		if rising_edge(clk_d) then
			if cnt_col < x"0290" then
				hs <= '1';
				cnt_col <= cnt_col + x"0001";
			elsif cnt_col < x"02F0" then
				hs <= '0';
				cnt_col <= cnt_col + x"0001";
			elsif cnt_col < x"0320" then
				hs <= '1';
				cnt_col <= cnt_col + x"0001";
			else
				cnt_col <= x"0000";
				cnt_row <= cnt_row + x"0001";
			end if;
			if cnt_row < x"01EA" then
				vs <= '1';
			elsif cnt_row < x"01EC" then
				vs <= '0';
			elsif cnt_row < x"020D" then
				vs <= '1';
			else
				cnt_row <= x"0000";
				vs <= '1';
				null;
			end if;
		end if;
	end process;
	
	set_color: process(clk_d)
	begin
		if char_row = write_row and char_col = write_col then
			r <= "111";
			g <= "111";
			b <= "000";
		elsif (char_row > write_row) or (char_row = write_row and char_col > write_col) then
			r <= "000";
			g <= "000";
			b <= "000";
		elsif char_row < "1111" and char_col < "101000" then
			if to_read(conv_integer(pixel_col)) = '1' then
				r <= "000";
				g <= "000";
				b <= "000";
			else
				r <= "111";
				g <= "111";
				b <= "111";
			end if;
		else
			r <= "000";
			g <= "000";
			b <= "000";
		end if;
	end process;

end Behavioral;

