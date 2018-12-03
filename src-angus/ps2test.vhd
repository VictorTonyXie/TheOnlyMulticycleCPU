library ieee;
use ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;

entity ps2test is
    port
    (
        CLK: in std_logic;
        RST: in std_logic;
        PS2_DATA: in std_logic;
        PS2_CLK: in std_logic;
				l: out std_logic_vector(7 downto 0)
				--dyp : out std_logic_vector(6 downto 0);
				--dyp2 : out std_logic_vector(6 downto 0)
    );
end;

architecture behavioral of ps2test is
    constant TIMEOUT_TICKS: integer := 1000000;

    type state_type is (s_wait, s_begin, s_data, s_parity, s_end, s_done);
    signal data0, data, ps2_clk_buff, clk1, clk2, parity: std_logic; 
    signal frame: std_logic_vector(7 downto 0); 
    signal state: state_type;
    signal data_cnt : integer range 0 to 7;
    signal timeout_counter : integer range 0 to TIMEOUT_TICKS;
    
    signal data_ready: std_logic;
begin
    clk1 <= PS2_CLK when rising_edge(CLK);
    clk2 <= clk1 when rising_edge(CLK);
    ps2_clk_buff <= (not clk1) and clk2;
    
    data0 <= PS2_DATA when rising_edge(CLK);
    data <= data0 when rising_edge(CLK);
    
    process(RST, CLK)
    begin
        if RST = '0' then
            state <= s_begin;
            frame <= (others => '0');
            parity <= '0';
            data_cnt <= 0;
            timeout_counter <= 0;
        elsif rising_edge(CLK) then
            case state is 
                when s_begin =>
                    if ps2_clk_buff = '1' then
                        if data = '0' then
                            state <= s_data;
                            data_cnt <= 0;
                            parity <= '0';
                        end if;
                        timeout_counter <= 0;
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
                        timeout_counter <= 0;
                    else
                        if timeout_counter = TIMEOUT_TICKS then
                            state <= s_begin;
                            timeout_counter <= 0;
                        else
                            timeout_counter <= timeout_counter + 1;
                        end if;
                    end if;
                when s_parity =>
                    if ps2_clk_buff = '1' then
                        if (data xor parity) = '1' then
                            state <= s_end;
                        else
                            state <= s_begin;
                        end if;
                        timeout_counter <= 0;
                    else
                        if timeout_counter = TIMEOUT_TICKS then
                            state <= s_begin;
                            timeout_counter <= 0;
                        else
                            timeout_counter <= timeout_counter + 1;
                        end if;
                    end if;
                when s_end =>
                    if ps2_clk_buff = '1' then
                        if data = '1' then
														l(7 downto 0) <= frame;
                            state <= s_done;
                        else
                            state <= s_begin;
                        end if;
                        timeout_counter <= 0;
                    else
                        if timeout_counter = TIMEOUT_TICKS then
                            state <= s_begin;
                            timeout_counter <= 0;
                        else
                            timeout_counter <= timeout_counter + 1;
                        end if;
                    end if;
                when s_done =>
                    state <= s_begin;
                when others =>
                    state <= s_begin;
            end case; 
        end if;
    end process;
end behavioral;