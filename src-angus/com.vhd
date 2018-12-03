library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity com is
  Port (clk : in std_logic;
        rst : in std_logic;
			  data_ready : in std_logic;
			  rdn, wrn : out std_logic;
        sw : in std_logic;
			  data_ram1 : inout std_logic_vector(15 downto 0);
        l : out std_logic_vector(15 downto 0);
        dyp : out std_logic_vector(6 downto 0);
        dyp2 : out std_logic_vector(6 downto 0);
			  addr_ram1 : inout std_logic_vector(15 downto 0);
			  ram1_en: out std_logic;
			  ram1_oe: out std_logic;
			  ram1_rw: out std_logic);
end com;

architecture Behavioral of com is
type main_state is (waiting, read0, read1, write0, write1, write2, write3, write4, done);
signal state : main_state := waiting;
signal high : std_logic := '1';
signal data_tmp : std_logic_vector(15 downto 0);
signal sendflag : std_logic := '0';

begin
  ram1_en <= '0';
  process(clk, rst)
  begin
    if rst = '0' then
      state <= waiting;
      dyp <= "1001111";
      dyp2 <= "1111110";
      high <= '1';
      wrn <= '1';
      rdn <= '1';
      ram1_rw <= '1';
      ram1_oe <= '1';
      data_ram1 <= (others => 'Z');
      sendflag <= '0';
      addr_ram1 <= "1011111100000000";
    elsif clk = '1' and clk'event then
      case state is
        when waiting =>
          case sw is
            when '1' =>
              --read
              dyp <= "0011111";
              dyp2 <= "1111110";
              state <= read0;
            when '0' =>
              --write
              dyp <= "1110111";
              dyp2 <= "1111110";
              state <= write0;
            when others =>
              null;
          end case;
        when write0 =>
          high <= '0';
          sendflag <= '0';
          state <= write1;
          dyp <= "1110111";
          dyp2 <= "0110000";
        when write1 =>
          wrn <= '1';
          if sendflag = '1' then
            state <= done;
            dyp <= "0001101";
            dyp2 <= "0001101";
          else
            state <= write2;
            dyp <= "1110111";
            dyp2 <= "1101101";
          end if;
        when write2 =>
          state <= write3;
          ram1_oe <= '0';
          data_ram1 <= (others => 'Z');
          dyp <= "1110111";
          dyp2 <= "1111001";
        when write3 =>
          l <= data_ram1;
          data_tmp <= data_ram1;
          ram1_oe <= '1';
          state <= write4;
          dyp <= "1110111";
          dyp2 <= "0110011";
        when write4 =>
          wrn <= '0';
          if high = '1' then
            sendflag <= '1';
            data_ram1(7 downto 0) <= data_tmp(15 downto 8);
            high <= '0';
          else
            data_ram1(7 downto 0) <= data_tmp(7 downto 0);
            high <= '1';
          end if;
          state <= write1;
          dyp <= "1110111";
          dyp2 <= "1111110";

        when read0 =>
          if data_ready = '1' then
            if high = '1' then
              high <= '0';
            else
              high <= '1';
            end if;
            rdn <= '0';
            data_ram1 <= (others => 'Z');
            state <= read1;
            dyp <= "0011111";
            dyp2 <= "0110000";
          end if;
        when read1 =>
          rdn <= '1';
          if high = '0' then
            data_tmp(7 downto 0) <= data_ram1(7 downto 0);
            dyp <= "0011111";
            dyp2 <= "1111110";
            state <= read0;
          else
            data_ram1(7 downto 0) <= data_tmp(7 downto 0);
            data_ram1(15 downto 8) <= data_ram1(7 downto 0);
            dyp <= "0001101";
            dyp2 <= "0001101";
            ram1_rw <= '0';
            state <= done;
          end if;
        when done =>
          dyp <= "1001111";
          dyp2 <= "1111110";
          high <= '1';
          wrn <= '1';
          rdn <= '1';
          ram1_rw <= '1';
          ram1_oe <= '1';
          data_ram1 <= (others => 'Z');
          sendflag <= '0';
          addr_ram1 <= "1011111100000000";
          state <= waiting;
      end case;
		end if;
	end process;

end Behavioral;
