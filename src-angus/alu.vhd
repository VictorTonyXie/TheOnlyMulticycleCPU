library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity alu is
    Port ( input_a : in  STD_LOGIC_VECTOR (15 downto 0);
           input_b : in  STD_LOGIC_VECTOR (15 downto 0);
           control_signal : in  STD_LOGIC_VECTOR (2 downto 0);
			     zero_markflag : out STD_LOGIC;
           output : out  STD_LOGIC_VECTOR (15 downto 0));
end alu;

architecture Behavioral of alu is
begin
  process(input_a, input_b, control_signal)
    variable zero_mark : STD_LOGIC := '1';
  begin
  	case control_signal is
  		when "000" =>
  			--plus
  			--ADDIU ADDIU3 ADDSP ADDU B LW LW_SP SW SW_RS SW_SP
  			output <= input_a + input_b;
  		when "001" =>
  			--minus
  			--BEQZ BNEZ BTEQZ BTNEZ CMP CMPI SLTI SLTUI SRA SUBU
  			output <= input_a - input_b;
  			if input_a - input_b = "0000000000000000" then
  				zero_mark := '0';
  			else
          zero_mark := '1';
        end if;
  		when "010" =>
  			--and
  			--AND
  			output <= input_a AND input_b;
  		when "011" =>
  			--or
  			--OR
  			output <= input_a OR input_b;
  		when "100" =>
  			--sll
  			--SLL
  			output <= to_stdlogicvector(to_bitvector(input_a) sll conv_integer(input_b));
  		when "101" =>
  			--sra
  			--SRA
  			output <= to_stdlogicvector(to_bitvector(input_a) sra conv_integer(input_b));
  		when "110" =>
  			--SLTI STLUI
  			if input_a < input_b then
  				output <= "1111111111111111";
          zero_mark := '1';
  			else
  				output <= "0000000000000000";
          zero_mark := '0';
  			end if;
  		when others =>
  			--MUST NOT HAPPEN
  			output <= "1010101010101010";
    end case;
  	zero_markflag <= zero_mark;
  end process;
end Behavioral;
