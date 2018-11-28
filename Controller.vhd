----------------------------------------------------------------------------------
-- Company:
-- Engineer:
--
-- Create Date:    02:49:19 11/20/2018
-- Design Name:
-- Module Name:    Controller - Behavioral
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

entity Controller is
	Port(
		rst, clk: in std_logic;
		BranchT, BranchZF: in std_logic;
		instruction: in std_logic_vector(15 downto 0);
		light: out std_logic_vector(15 downto 0)
	);
end Controller;

architecture Behavioral of Controller is
	signal WritePC: std_logic;
	signal WriteMem: std_logic;
	signal WriteIR: std_logic;
	signal WriteReg: std_logic;
	signal WriteT: std_logic;
	signal WriteIH: std_logic;
	signal WriteSP: std_logic;
	signal WriteRA: std_logic;

	signal ChooseAddr: std_logic_vector(1 downto 0);
	signal ChooseWrite: std_logic_vector(1 downto 0);
	signal ChooseND: std_logic_vector(1 downto 0);
	signal ChooseDI: std_logic_vector(2 downto 0);
	signal SignExtend: std_logic_vector(15 downto 0);
	signal ChooseSP: std_logic;
	signal ChooseRCSrc: std_logic(1 downto 0);
	signal ChooseALUSrcA: std_logic(1 downto 0);
	signal ChooseALUSrcB: std_logic(2 downto 0);
	signal ChooseALUOp: std_logic(2 downto 0);

	type ctrl_states is (
		s0,  s1,  s2,  s3,  s4,
		s5,  s6,  s7,  s8,  s9,
		s10, s11, s12, s13, s14,
		s15, s16, s17, s18, s19,
		s20, s21, s22, s23, s24,
		s25, s26, s27, s28, s29,
		s30, s31, s32, s33, s34
	);
	signal state: ctrl_states;
begin


	process(rst, clk)
	begin
		if (rst = '0') then
			state <= s0;

			WritePC <= '0';
			WriteMem <= '0';
			WriteIR <= '0';
			WriteReg <= '0';
			WriteT <= '0';
			WriteSP <= '0';
			WrtiteRA <= '0';

			ChooseAddr <= "00";
			ChooseWrite <= "00";
			ChooseND <= "00";
			ChooseDI <= "00";
			SignExtend <= x"0000";
			ChooseSP <= '0';
			ChooseRCSrc <= "00";
			ChooseALUSrcA <= "00";
			ChooseALUSrcB <= "000";
			ChooseALUOp <= "000";
		elsif rising_edge(clk) then
			case state is
				when s0 =>
					ChooseAddr <= "00";
					ChooseALUOp <= "000";
					ChooseALUSrcA <= "01";
					ChooseALUSrcB <= "01";
					ChoosePCSrc <= "01";
					
					case instruction(15 downto 11) is
						when "00001" =>
							--when the instruction is NOP => do not change the state
							null;
						when others =>
							--when the instruction is not NOP change state to s1
							state <= s1;
					end case;
				when s1 =>
					ChooseALUSrcA <= "01";
					ChooseALUSrcB <= "010";
					ChooseALUOp <= "000";
					
					case instruction(15 downto 11) is
						when "00000" => null;
						when "00001" =>
							--NOP: do nothing for this instruction has been occurred above
							--state <= s30;
						when "00010" =>
							--B
							state <= s30;
						when "00011" => null;
						when "00100" =>
						  --BEQZ
						  state <= s31;
						when "00101" =>
						  --BNEZ
						  state <= s31;
						when "00110" =>
						  --SLL SRA
						  state <= s19;
									when "00111" => null;
						when "01000" =>
						  --ADDIU3
						  state <= s16;
						when "01001" =>
						  --ADDIU
						  state <= s16;
						when "01010" =>
						  --SLTI
						  state <= s28;
									when "01011" => null;
						when "01100" =>
						  --ADDSP BTEQZ BTNEZ MTSP SW_RS
						  --todo
						when "01101" =>
						  --LI
						when "01110" =>
						  --CMPI
						  state <= s27;
									when "01111" => null;
									when "10000" => null;
									when "10001" => null;
						when "10010" =>
						  --LW_SP
						  state <= s3;
						when "10011" =>
						  --LW
						  state <= s2;
									when "10100" => null;
									when "10101" => null;
									when "10110" => null;
									when "10111" => null;
									when "11000" => null;
									when "11001" => null;
						when "11010" =>
						  --SW_SP
						  state <= s3;
						when "11011" =>
						  --SW
						  state <= s2;
						when "11100" =>
						  --ADDU SUBU
						  state <= s15;
						when "11101" =>
						  --AND CMP JR MFPC OR SLTUI
						  --todo
						when "11110" =>
						  --MFIH MTIH
						  --todo
						when "11111" => null;
						when others => null;
					end case;
				when s2 =>
					SignExtend <= '1';
					
					ChooseALUOp <= "000";
					ChooseALUSrcA <= "10";
					ChooseALUSrcB <= "100";
					
					case instruction is
						when "10011" => state <= s4; --LW
						when "11011" => state <= s5; --SW
					end case;
				when s3 =>
					ChooseALUOp <= "000";
					ChooseALUSrcA <= "00";
					ChooseALUSrcB <= "100";
					
					SignExtend <= '1';
					
					case instruction is
						when "10010" => state <= s6; --LW_SP
						when "01100" => state <= s7; --SW_RS
						when "11010" => state <= s8; --SW_SP
					end case;
				when s4 =>
					ChooseAddr <= "01";
					
					state <= s9;
				when s5 =>
					ChooseAddr <= "01";
					ChooseWrite <= "10";
					
					state <= s0;
				when s6 =>
					ChooseAddr <= "01";
					
					state <= s10;
				when s7 =>
					ChooseAddr <= "10";
					ChooseWrite <= "00";
					
					state <= s0;
				when s8 =>
					ChooseAddr <= "01";
					ChooseWrite <= "01";
					
					state <= s0;
				when s9 =>
					ChooseDI <= "100";
					ChooseND <= "01";
					
					WriteReg <= '1';
					
					state <= s0;
				when s10 =>
					ChooseDI <= "100";
					ChooseND <= "00";
					
					WriteReg <= '1';
					
					state <= s0;
				when s11 =>
					ChooseND <= "00";
					ChooseDI <= "000";
					
					WriteReg <= '1';
					
					state <= s0;
				when s12 =>
					ChooseND <= "01";
					ChooseDI <= "000";
					
					WriteReg <= '1';
					
					state <= s0;
				when s13 =>
					ChooseND <= "10";
					ChooseDI <= "000";
					
					WriteReg <= '1';
					
					state <= '0';
				when s14 =>		--RA WriteBack SP
					ChooseSP <= '0';

					WriteSP <= '1';

					state <= s0;
				when s15 =>		--ADDU / SUBU / AND / OR
					ChooseALUSrcA <= "10";
					ChooseALUSrcB <= "001";
					ChooseALUOp <= ALUOp;

					case instruction is
						when "11100" =>
							--ADDU / SUBU
							state <= s13;
						when "11101" =>
							--AND / OR
							state <= s11;
					end case;
				when s16 =>		--ADDIU
					ChooseALUSrcA <= "10";
					ChooseALUSrcB <= "100";
					ChooseALUOp <= ALUOp;

					state <= s11;
				when s17 =>		--ADDSP3 / ADDSP
					ChooseALUSrcA <= "00";
					ChooseALUSrcB <= "100";
					ChooseALUOp <= ALUOp;

					state <= s11;
				when s18 =>

				when s19 =>	--SLL / SRA
					ChooseALUSrcA <= "11";
					ChooseALUSrcB <= "100";
					ChooseALUOp <= ALUOp;

					state <= s11;
				when s20 =>	--MFIH
					ChooseND <= "00";
					ChooseDI <= "001";

					WriteReg <= '1';

					state <= s0;
				when s21 =>	--MFPC
					ChooseND <= "00";
					ChooseDI <= "010";

					WriteReg <= '1';

					state <= s0;
				when s22 =>	--MTIH
					WriteIH <= '1';

					state <= s0;
				when s23 =>	--MTSP
					ChooseSP <= '1';

					WriteIH <= '1';

					state <= s0;
				when s24 =>

				when s25 =>		--ZF Writeback T
					WriteT <= '1';

					state <= s0;
				when s26 =>		--CMP
					ChooseALUSrcA <= "10";
					ChooseALUSrcB <= "001";
					ChooseALUOp <= "001";

					state <= s25;
				when s27 =>		--CMPI
					ChooseALUSrcA <= "10";
					ChooseALUSrcB <= "100";
					ChooseALUOp <= "001";

					state <= s25;
				when s28 =>		--SLTI
					ChooseALUSrcA <= "10";
					ChooseALUSrcB <= "100";
					ChooseALUOp <= "110";

					state <= s25;
				when s29 =>		--SLTUI
					ChooseALUSrcA <= "10";
					ChooseALUSrcB <= "100";
					ChooseALUOp <= "111";

					state <= s25;
				when s30 =>		--B
					PCSrc <= "10";
					WritePC <= '1';

					state <= s0;
				when s31 =>		--BEQZ / BNEZ
					ChosseALUSrcA <= "10";
					ChooseALUSrcB <= "110";
					ChooseALUOp <= "001";
					PCSrc <= "10";

					state <= s0;
				when s32 =>	--BTEQZ / BTNEZ
					PCSrc <= "10";

					state <= s0;
				when s33 =>
          null;
				when s34 =>
          null;
				when others =>
					null;
			end case;
		end if;
	end process;

end Behavioral;
