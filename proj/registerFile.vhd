library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity registerFile is
    Port ( n1 : in STD_LOGIC_VECTOR (2 downto 0);
           n2 : in STD_LOGIC_VECTOR (2 downto 0);
           nd : in STD_LOGIC_VECTOR (2 downto 0);
           di : in STD_LOGIC_VECTOR (15 downto 0);
           WriteReg : in STD_LOGIC;
           clk : in STD_LOGIC;
           q1 : out STD_LOGIC_VECTOR (15 downto 0);
           q2 : out STD_LOGIC_VECTOR (15 downto 0));
end registerFile;

architecture Behavioral of registerFile is
  type reg is array (integer range 0 to 7) of std_logic_vector (15 downto 0);
  signal regManager : reg := ("0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000",
  "0000000000000000", "0000000000000000", "0000000000000000", "0000000000000000");
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if WriteReg = '1' then
        --write to Register
        regManager(conv_integer(nd)) <= di;
      end if;
    end if;
  end process;

  process(n1, n2, regManager)
  begin
    --if WriteReg = '0' then
      --Read from register
      q1 <= regManager(conv_integer(n1));
      q2 <= regManager(conv_integer(n2));
    --end if;
  end process;
end Behavioral;
