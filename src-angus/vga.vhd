library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity vgatest is
	Port(
		clk: in std_logic;
		rst: in std_logic;
		r: out std_logic_vector(2 downto 0);
		g: out std_logic_vector(2 downto 0);
		b: out std_logic_vector(2 downto 0);
		hs: out std_logic;
		vs: out std_logic
	);
end vgatest;

architecture Behavioral of vgatest is
	signal cnt : integer := 0;
begin
	process(clk, rst)
	variable i, j : integer :=0 ;

	begin
		if rst = '0' then
			i := 0;
			j := 0;
		elsif clk'event and clk = '1' then
			if cnt = 0 then
				cnt <= 1;
			elsif cnt = 1 then
				cnt <= 0;
				for i in 0 to 524 loop
					for j in 0 to 799 loop
						if j >= 640 or i >= 480 then
							r <= "000";
							g <= "000";
							b <= "000";
						else
							r <= "000";
							g <= "100";
							b <= "000";
						end if;
						if j >= 656 and j <= 751 then
							hs <= '0';
						else
							hs <= '1';
						end if;
					end loop;
					if i = 490 or i = 491 then
						vs <= '0';
					else
						vs <= '1';
					end if;
				end loop;
			end if;
		end if;
	end process;
end Behavioral;

