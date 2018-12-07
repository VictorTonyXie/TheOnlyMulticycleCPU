library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity ps2test is
  port
  (
    clk: in std_logic;
		rst: in std_logic;
    ps2_data: in std_logic;
    ps2_clk: in std_logic;
    onclick : out std_logic;
		ascii_out: out std_logic_vector(7 downto 0)
  );
end;

architecture behavioral of ps2test is

  type state_type is (s_wait, s_begin, s_data, s_parity, s_end, s_done, s_reset);
  signal data0, data, ps2_clk_buff, clk1, clk2, parity: std_logic;
  signal frame: std_logic_vector(7 downto 0);
  signal state: state_type;
  signal data_cnt : integer range 0 to 7;
	signal counter : std_logic := '0';

  function decode(a: std_logic_vector(7 downto 0)) return std_logic_vector is
  begin
    case a is
      --Capital Letter
      when x"1C" => return x"41";
      when x"32" => return x"42";
      when x"21" => return x"43";
      when x"23" => return x"44";
      when x"24" => return x"45";
      when x"2B" => return x"46";
      when x"34" => return x"47";
      when x"33" => return x"48";
  		when x"43" => return x"49";
      when x"3B" => return x"4A";
      when x"42" => return x"4B";
      when x"4B" => return x"4C";
      when x"3A" => return x"4D";
      when x"31" => return x"4E";
      when x"44" => return x"4F";
      when x"4D" => return x"50";
      when x"15" => return x"51";
      when x"2D" => return x"52";
      when x"1B" => return x"53";
      when x"2C" => return x"54";
      when x"3C" => return x"55";
      when x"2A" => return x"56";
      when x"1D" => return x"57";
      when x"22" => return x"58";
      when x"35" => return x"59";
      when x"1A" => return x"5A";

      --keyboard 0 to 9
      when x"45" => return x"30";
      when x"16" => return x"31";
      when x"1E" => return x"32";
      when x"26" => return x"33";
      when x"25" => return x"34";
      when x"2E" => return x"35";
      when x"36" => return x"36";
      when x"3D" => return x"37";
      when x"3E" => return x"38";
      when x"46" => return x"39";

      --num pad 0 to 9
      when x"70" => return x"30";
      when x"69" => return x"31";
      when x"72" => return x"32";
      when x"7A" => return x"33";
      when x"6B" => return x"34";
      when x"73" => return x"35";
      when x"74" => return x"36";
      when x"6C" => return x"37";
      when x"75" => return x"38";
      when x"7D" => return x"39";

      -- enter
      when x"5A" => return x"0A";
			-- space
			when x"29" => return x"29";
			--backspace
			when x"66" => return x"08";
			
      -- unshowable
      when others => return x"FF";

    end case;
  end decode;

begin
  clk1 <= ps2_clk when rising_edge(clk);
  clk2 <= clk1 when rising_edge(clk);
  ps2_clk_buff <= (not clk1) and clk2;

  data0 <= ps2_data when rising_edge(clk);
  data <= data0 when rising_edge(clk);

  process(clk)
  begin
		if rst = '0' then
			state <= s_begin;
			frame <= (others => '0');
			parity <= '0';
			data_cnt <= 0;
      onclick <= '1';
      ascii_out <= (others => '0');
    elsif clk'event and clk = '1' then
      case state is
        when s_begin =>
					onclick <= '1';
          if ps2_clk_buff = '1' then
            if data = '0' then
              state <= s_data;
              data_cnt <= 0;
              parity <= '0';
            end if;
          end if;

        when s_data =>
          if ps2_clk_buff = '1' then
            frame <= data & frame(7 downto 1) ;
            parity <= parity xor data;
            if data_cnt = 7 then
              state <= s_parity;
            else
              data_cnt <= data_cnt + 1;
            end if;
          end if;

        when s_parity =>
          if ps2_clk_buff = '1' then
            if (data xor parity) = '1' then
              state <= s_end;
            else
              state <= s_begin;
            end if;
          end if;

        when s_end =>
          if ps2_clk_buff = '1' then
            if data = '1' then
							if decode(frame) /= x"FF" then
								if counter = '0' then
									ascii_out <= decode(frame);
									state <= s_done;
									--onclick <= '0';
								else
									state <= s_begin;
									frame <= (others => '0');
									ascii_out <= (others => '0');
								end if;
								counter <= NOT counter;
							else
								state <= s_begin;
							end if;
            else
              state <= s_begin;
            end if;
          end if;

        when s_done =>
					state <= s_begin;
					onclick <= '0';
        when others =>
          state <= s_begin;
      end case;
    end if;
  end process;
end behavioral;
