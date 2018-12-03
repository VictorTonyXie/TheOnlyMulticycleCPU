library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity alu is
    Port ( input_a : in  STD_LOGIC_VECTOR (15 downto 0);
           input_b : in  STD_LOGIC_VECTOR (15 downto 0);
           control_signal : in  STD_LOGIC_VECTOR (2 downto 0);
			     zero_markflag : out STD_LOGIC := '0';
           output : out  STD_LOGIC_VECTOR (15 downto 0) := "0000000000000000");
end alu;

architecture Behavioral of alu is
	shared variable zero_mark : STD_LOGIC := '1';
	signal res_add, res_sub, res_and, res_or, res_sll, res_sra: std_logic_vector(15 downto 0);
	signal res_slti, res_sltui: std_logic_vector(17 downto 0);
begin
	res_add <= input_a + input_b;
	res_sub <= input_a - input_b;
	res_and <= input_a and input_b;
	res_or <= input_a or input_b;
	res_sll <= to_stdlogicvector(to_bitvector(input_a) sll conv_integer(input_b));
	res_sra <= to_stdlogicvector(to_bitvector(input_a) sra conv_integer(input_b));
	res_slti <= SXT(input_a, 18) - SXT(input_b, 18);
	res_sltui <= EXT(input_a, 18) - EXT(input_b, 18);
	
	process(res_add, res_sub, res_and, res_or, res_sll, res_sra, res_slti, res_sltui, control_signal)
	begin
		case control_signal is
			when "000" =>
				--add
				output <= res_add;
			when "001" =>
				--sub
				output <= res_sub;
				if res_sub = "0000000000000000" then
					zero_markflag <= '0';
				else
					zero_markflag <= '1';
				end if;
			when "010" =>
				--and
				output <= res_and;
			when "011" =>
				--or
				output <= res_or;
			when "100" =>
				--sll
				output <= res_sll;
			when "101" =>
				--sra
				output <= res_sra;
			when "110" =>
				--slti
				output <= res_sub;
				zero_markflag <= res_slti(17);
			when "111" =>
				--sltui
				output <= res_sub;
				zero_markflag <= res_sltui(17);
			when others =>
				output <= "0000000000000000";
		end case;
	end process;
end Behavioral;
