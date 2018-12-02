library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity extender is
    Port ( imm : in  STD_LOGIC_VECTOR (10 downto 0);
           SignExtend : in STD_LOGIC_VECTOR (4 downto 0);
           output : out  STD_LOGIC_VECTOR (15 downto 0));
end extender;

architecture Behavioral of extender is
  shared variable extendType : integer := 0;
  shared variable extendLength : integer := 0;
begin
  process(imm, SignExtend)
  begin
    extendType := CONV_INTEGER(SignExtend(4));
    extendLength := CONV_INTEGER(SignExtend(3 downto 0));
    case extendLength is
      when 3 =>
      --SLL SRA, WARNING it still return 16-bit
      output <= EXT(imm(4 downto 2), 16);
      when 4 =>
      --ADDIU3
      output <= SXT(imm(3 downto 0), 16);
      when 5 =>
      --LW SW
      output <= SXT(imm(4 downto 0), 16);
      when 8 =>
      --ADDIU ADDSP BEQZ BNEZ BTEQZ BTNEZ CMPI LI SLTI SLTUI SW_RS SW_SP
      if extendType = 0 then
        --EXT
        output <= EXT(imm(7 downto 0), 16);
      elsif extendType = 1 then
        --SXT
        output <= SXT(imm(7 downto 0), 16);
      end if;
      when 11 =>
      --B
      output <= SXT(imm(10 downto 0), 16);
      when others =>
      --MUST NOT HAPPEN
      output <= "0000000000000000";
    end case;
  end process;
end Behavioral;
