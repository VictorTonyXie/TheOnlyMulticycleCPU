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
		light: out std_logic_vector(15 downto 0) := "0000000000000000";
		
		WritePC: out std_logic := '0';
		WriteMem: out std_logic_vector(1 downto 0) := "00";
		WriteIR: out std_logic := '0';
		WriteReg: out std_logic := '0';
		WriteT: out std_logic := '0';
		WriteIH: out std_logic := '0';
		WriteSP: out std_logic := '0';
		WriteRA: out std_logic := '0';

		ChooseAddr: out std_logic_vector(1 downto 0) := "00";
		ChooseWrite: out std_logic_vector(1 downto 0) := "11";
		ChooseND: out std_logic_vector(1 downto 0) := "00";
		ChooseDI: out std_logic_vector(2 downto 0) := "000";
		SignExtend: out std_logic_vector(4 downto 0) := "00000";
		ChooseSP: out std_logic := '0';
		ChoosePCSrc: out std_logic_vector(1 downto 0) := "00";
		ChooseALUSrcA: out std_logic_vector(1 downto 0) := "00";
		ChooseALUSrcB: out std_logic_vector(2 downto 0) := "000";
		ChooseALUOp: out std_logic_vector(2 downto 0) := "000"
	);
end Controller;

architecture Behavioral of Controller is

	type ctrl_states is (
		instruction_fetch,
		decode,
		execute,
		mem_control,
		write_reg
	);
	signal state: ctrl_states;
begin


	process(rst, clk)
	begin
		if (rst = '0') then
			state <= instruction_fetch;
			
			WritePC <= '0';
			WriteMem <= "00";
			WriteIR <= '0';
			WriteReg <= '0';
			WriteT <= '0';
			WriteIH <= '0';
			WriteSP <= '0';
			WriteRA <= '0';
			
			ChooseAddr <= "00";
			ChooseWrite <= "00";
			ChooseND <= "00";
			ChooseDI <= "000";
			SignExtend <= "00000";
			ChooseSP <= '0';
			ChoosePCSrc <= "00";
			ChooseALUSrcA <= "00";
			ChooseALUSrcB <= "000";
			ChooseALUOp <= "000";
		elsif rising_edge(clk) then
			case state is
				when instruction_fetch =>
					WritePC <= '1';
					WriteMem <= "10";
					WriteIR <= '1';
					WriteReg <= '0';
					WriteT <= '0';
					WriteIH <= '0';
					WriteSP <= '0';
					WriteRA <= '0';
					
					ChooseAddr <= "00";
					ChooseWrite <= "11";
					ChooseND <= "00";
					ChooseDI <= "000";
					SignExtend <= "00000";
					ChooseSP <= '0';
					ChoosePCSrc <= "01";
					ChooseALUSrcA <= "01";
					ChooseALUSrcB <= "010";
					ChooseALUOp <= "000";
					
					state <= decode;
				when decode =>
					--init signals: calc pc + se(immediate)
					WritePC <= '0';
					WriteMem <= "00";
					WriteIR <= '0';
					WriteReg <= '0';
					WriteT <= '0';
					WriteIH <= '0';
					WriteSP <= '0';
					WriteRA <= '1';
					
					ChooseAddr <= "00";
					ChooseWrite <= "11";
					ChooseND <= "00";
					ChooseDI <= "000";
					SignExtend <= "11000";--Choose SignExtend(8): for BEQZ, BNEZ, BTEQZ, BTNEZ
					ChooseSP <= '0';
					ChoosePCSrc <= "00";
					ChooseALUSrcA <= "01";--Choose PC
					ChooseALUSrcB <= "100";--Choose SE(immediate)
					ChooseALUOp <= "000";--Choose ADD
					--end init signals
					
					--default state
					state <= execute;
					
					
				when execute =>
					--init signals
					WritePC <= '0';
					WriteMem <= "00";
					WriteIR <= '0';
					WriteReg <= '0';
					WriteT <= '0';
					WriteIH <= '0';
					WriteSP <= '0';
					WriteRA <= '0';
					
					ChooseAddr <= "00";
					ChooseWrite <= "11";
					ChooseND <= "00";
					ChooseDI <= "000";
					SignExtend <= "00000";
					ChooseSP <= '0';
					ChoosePCSrc <= "00";
					ChooseALUSrcA <= "00";
					ChooseALUSrcB <= "000";
					ChooseALUOp <= "000";
					--end init signals
					
					--default state
					state <= mem_control;
					
					case instruction(15 downto 11) is
						when "00001" =>
							--NOP
							state <= instruction_fetch;
						when "00010" =>
							--B
							SignExtend <= "11011";--SE(11)
							ChooseALUOp <= "000";--Choose ADD
							ChooseALUSrcA <= "01";--Choose PC
							ChooseALUSrcB <= "100";--Choose SE(immediate)
							ChoosePCSrc <= "01";--Choose ALUR
							WritePC <= '1';
							state <= instruction_fetch;
						when "00100" =>
							--BEQZ
							ChooseALUOp <= "001";--Choose SUB
							ChooseALUSrcA <= "10";--Choose R[rx]
							ChooseALUSrcB <= "110";--Choose 0
							state <= write_reg;
						when "00101" =>
							--BNEQ
							ChooseALUOp <= "001";--Choose SUB
							ChooseALUSrcA <= "10";--Choose R[rx]
							ChooseALUSrcB <= "110";--Choose 0
							state <= write_reg;
						when "00110" =>
							--SLL SRA
							WriteRA <= '1';
							SignExtend <= "00011";
							ChooseALUSrcA <= "11";--Choose R[ry]
							state <= write_reg;
							case instruction(1 downto 0) is
								when "00" =>
									--SLL
									ChooseALUOp <= "100";--Choose SLL
								when "11" =>
									--SRA
									ChooseALUOp <= "101";--Choose SRA
								when others => null;
							end case;
							case instruction(4 downto 2) is
								when "000" =>
									--immediate == 0
									ChooseALUSrcB <= "011";--Choose 8
								when others =>
									--immediate != 0
									ChooseALUSrcB <= "100";--Choose SE(immediate)
							end case;
						when "01000" =>
							--ADDIU3
							WriteRA <= '1';
							SignExtend <= "10100";
							state <= write_reg;
							ChooseALUOp <= "000";--Choose ADD
							ChooseALUSrcA <= "10";--Choose R[rx]
							ChooseALUSrcB <= "100";--Choose SE(immediate)
						when "01001" =>
							--ADDIU
							WriteRA <= '1';
							SignExtend <= "11000";
							state <= write_reg;
							ChooseALUOp <= "000";--Choose ADD
							ChooseALUSrcA <= "10";--Choose R[rx]
							ChooseALUSrcB <= "100";--Choose SE(immediate)
						when "01010" =>
							--SLTI
							WriteT <= '1';
							SignExtend <= "11000";
							state <= instruction_fetch;
							ChooseALUOp <= "110";--Choose SLTI
							ChooseALUSrcA <= "10";--Choose R[rx]
							ChooseALUSrcB <= "100";--Choose SE(immediate)
						when "01011" =>
							--SLTUI
							WriteT <= '1';
							SignExtend <= "01000";
							state <= instruction_fetch;
							ChooseALUOp <= "111";--Choose SLTUI
							ChooseALUSrcA <= "10";--Choose R[rx]
							ChooseALUSrcB <= "100";--Choose SE(immediate)
						when "01100" =>
							--ADDSP BTEQZ BTNEZ MTSP SW_RS
							case instruction(10 downto 8) is
								when "011" =>
									--ADDSP
									SignExtend <= "11000";
									ChooseSP <= '0';--Choose ALUR
									ChooseALUOp <= "000";--Choose ADD
									ChooseALUSrcA <= "00";--Choose SP
									ChooseALUSrcB <= "100";--Choose SE(immediate)
									WriteSP <= '1';
									state <= instruction_fetch;
								when "000" =>
									--BTEQZ
									SignExtend <= "11000";
									WritePC <= not BranchT;
									ChoosePCSrc <= "10";--Choose RA
									state <= instruction_fetch;
								when "001" =>
									--BTNEZ
									SignExtend <= "11000";
									WritePC <= BranchT;
									ChoosePCSrc <= "10";--Choose RA
									state <= instruction_fetch;
								when "100" =>
									--MTSP
									ChooseSP <= '1';--Choose R[ry]
									WriteSP <= '1';
									state <= instruction_fetch;
								when "010" =>
									--SW_RS
									SignExtend <= "11000";
									ChooseALUOp <= "000";--Choose ADD
									ChooseALUSrcA <= "00";--Choose SP
									ChooseALUSrcB <= "100";--Choose SE(immediate)
									--Important: do not write RA! this instruction is mem<-RA, and writeRA will destroy RA
									--WriteRA <= '1';
									state <= mem_control;
								when others => null;
							end case;
						when "01101" =>
							--LI
							SignExtend <= "01000";
							ChooseND <= "00";--Choose R[rx]
							ChooseDI <= "101";--Choose ZE(immediate)
							WriteReg <= '1';
							state <= instruction_fetch;
						when "01110" =>
							--CMPI
							SignExtend <= "11000";
							ChooseALUOp <= "001";--Choose SUB
							ChooseALUSrcA <= "10";--Choose R[rx]
							ChooseALUSrcB <= "100";--Choose SE(immediate)
							WriteT <= '1';
							state <= instruction_fetch;
						when "10010" =>
							--LW_SP
							SignExtend <= "11000";
							ChooseALUOp <= "000";--Choose ADD
							ChooseALUSrcA <= "00";--Choose SP
							ChooseALUSrcB <= "100";--Choose SE(immediate)
							WriteRA <= '1';
							ChooseAddr <= "10";--Choose ALUR
							state <= mem_control;
						when "10011" =>
							--LW
							SignExtend <= "10101";
							ChooseALUOp <= "000";--Choose ADD
							ChooseALUSrcA <= "10";--Choose R[rx]
							ChooseALUSrcB <= "100";--Choose SE(immediate)
							WriteRA <= '1';
							ChooseAddr <= "10";--Choose ALUR
							state <= mem_control;
						when "11010" =>
							--SW_SP
							SignExtend <= "11000";
							ChooseALUOp <= "000";--Choose ADD
							ChooseALUSrcA <= "00";--Choose SP
							ChooseALUSrcB <= "100";--Choose SE(immediate)
							WriteRA <= '1';
							state <= mem_control;--wait for regA ready
						when "11011" =>
							--SW
							SignExtend <= "10101";
							ChooseALUOp <= "000";--Choose ADD
							ChooseALUSrcA <= "10";--Choose R[rx]
							ChooseALUSrcB <= "100";--Choose SE(immediate)
							WriteRA <= '1';
							state <= mem_control;
						when "11100" =>
							--ADDU SUBU
							case instruction(1 downto 0) is
								when "01" =>
									--ADDU
									ChooseALUOp <= "000";--Choose ADD
									ChooseALUSrcA <= "10";--Choose R[rx]
									ChooseALUSrcB <= "001";--Choose R[ry]
									WriteRA <= '1';
									state <= write_reg;
								when "11" =>
									--SUBU
									ChooseALUOp <= "001";--Choose SUB
									ChooseALUSrcA <= "10";--Choose R[rx]
									ChooseALUSrcB <= "001";--Choose R[ry]
									WriteRA <= '1';
									state <= write_reg;
								when others => null;
							end case;
						when "11101" =>
							--AND CMP JR MFPC OR
							case instruction(4 downto 0) is
								when "01100" =>
									--AND
									ChooseALUOp <= "010";--Choose AND
									ChooseALUSrcA <= "10";--Choose R[rx]
									ChooseALUSrcB <= "001";--Choose R[ry]
									WriteRA <= '1';
									state <= write_reg;
								when "01010" =>
									--CMP
									ChooseALUOp <= "001";--Choose SUB
									ChooseALUSrcA <= "10";--Choose R[rx]
									ChooseALUSrcB <= "001";--Choose R[ry]
									WriteT <= '1';
									state <= instruction_fetch;
								when "00000" =>
									--JR MFPC
									case instruction(7 downto 5) is
										when "000" =>
											--JR
											WritePC <= '1';
											ChoosePCSrc <= "00";--Choose RegA
											state <= instruction_fetch;
										when "010" =>
											--MFPC
											WriteReg <= '1';
											ChooseND <= "00";--Choose R[rx]
											ChooseDI <= "010";--Choose PC
											state <= instruction_fetch;
										when others => null;
									end case;
								when "01101" =>
									--OR
									ChooseALUOp <= "011";--Choose OR
									ChooseALUSrcA <= "10";--Choose R[rx]
									ChooseALUSrcB <= "001";--Choose R[ry]
									WriteRA <= '1';
									state <= write_reg;
								when others => null;
							end case;
						when "11110" =>
							--MFIH MTIH
							case instruction(4 downto 0) is
								when "00000" =>
									--MFIH
									ChooseND <= "00";--Choose R[rx]
									ChooseDI <= "001";--Choose IH
									WriteReg <= '1';
									state <= instruction_fetch;
								when "00001" =>
									--MTIH
									WriteIH <= '1';
									state <= instruction_fetch;
								when others => null;
							end case;
						when others => null;
					end case;
				when mem_control =>
					--init signals
					WritePC <= '0';
					WriteMem <= "00";
					WriteIR <= '0';
					WriteReg <= '0';
					WriteT <= '0';
					WriteIH <= '0';
					WriteSP <= '0';
					WriteRA <= '0';
					
					ChooseAddr <= "00";
					ChooseWrite <= "11";
					ChooseND <= "00";
					ChooseDI <= "000";
					SignExtend <= "00000";
					ChooseSP <= '0';
					ChoosePCSrc <= "00";
					ChooseALUSrcA <= "00";
					ChooseALUSrcB <= "000";
					ChooseALUOp <= "000";
					--end init signals
					
					--default state
					state <= write_reg;
					
					case instruction(15 downto 11) is
						when "00010" =>
							--B
						when "00100" =>
							--BEQZ
						when "00101" =>
							--BNEQ
						when "00110" =>
							--SLL SRA
							case instruction(1 downto 0) is
								when "00" =>
									--SLL
								when "11" =>
									--SRA
								when others => null;
							end case;
						when "01000" =>
							--ADDIU3
						when "01001" =>
							--ADDIU
						when "01010" =>
							--SLTI
						when "01011" =>
							--SLTUI
						when "01100" =>
							--ADDSP BTEQZ BTNEZ MTSP SW_RS
							case instruction(10 downto 8) is
								when "011" =>
									--ADDSP
								when "000" =>
									--BTEQZ
								when "001" =>
									--BTNEZ
								when "100" =>
									--MTSP
								when "010" =>
									--SW_RS
									ChooseAddr <= "10";--Choose ALUR: SP + SE(immediate)
									ChooseWrite <= "00";--Choose RA
									WriteMem <= "01";
									state <= instruction_fetch;
								when others => null;
							end case;
						when "01101" =>
							--LI
						when "01110" =>
							--CMPI
						when "10010" =>
							--LW_SP
							--keep alu result
							SignExtend <= "11000";
							ChooseALUOp <= "000";--Choose ADD
							ChooseALUSrcA <= "00";--Choose SP
							ChooseALUSrcB <= "100";--Choose SE(immediate)
							
							WriteMem <= "10";
							ChooseAddr <= "10";--keep ALUR
							state <= write_reg;
						when "10011" =>
							--LW
							--keep alu result
							SignExtend <= "10101";
							ChooseALUOp <= "000";--Choose ADD
							ChooseALUSrcA <= "10";--Choose R[rx]
							ChooseALUSrcB <= "100";--Choose SE(immediate)
							
							WriteMem <= "10";
							ChooseAddr <= "10";--keep ALUR
							state <= write_reg;
						when "11010" =>
							--SW_SP
							--keep alu result
							SignExtend <= "11000";
							ChooseALUOp <= "000";--Choose ADD
							ChooseALUSrcA <= "00";--Choose SP
							ChooseALUSrcB <= "100";--Choose SE(immediate)
							
							ChooseAddr <= "01";--Choose RA
							ChooseWrite <= "01";--Choose RegA
							WriteMem <= "01";
							state <= instruction_fetch;
						when "11011" =>
							--SW
							ChooseAddr <= "01";--Choose RA
							ChooseWrite <= "10";--Choose RegB
							WriteMem <= "01";
							state <= instruction_fetch;
						when "11100" =>
							--ADDU SUBU
							case instruction(1 downto 0) is
								when "01" =>
									--ADDU
								when "11" =>
									--SUBU
								when others => null;
							end case;
						when "11101" =>
							--AND CMP JR MFPC OR
							case instruction(4 downto 0) is
								when "01100" =>
									--AND
								when "01010" =>
									--CMP
								when "00000" =>
									--JR MFPC
									case instruction(7 downto 5) is
										when "000" =>
											--JR
										when "010" =>
											--MFPC
										when others => null;
									end case;
								when "01101" =>
									--OR
								when others => null;
							end case;
						when "11110" =>
							--MFIH MTIH
							case instruction(4 downto 0) is
								when "00000" =>
									--MFIH
								when "00001" =>
									--MTIH
								when others => null;
							end case;
						when others => null;
					end case;
				when write_reg =>
					--init signals
					WritePC <= '0';
					WriteMem <= "00";
					WriteIR <= '0';
					WriteReg <= '0';
					WriteT <= '0';
					WriteIH <= '0';
					WriteSP <= '0';
					WriteRA <= '0';
					
					ChooseAddr <= "00";
					ChooseWrite <= "11";
					ChooseND <= "00";
					ChooseDI <= "000";
					SignExtend <= "00000";
					ChooseSP <= '0';
					ChoosePCSrc <= "00";
					ChooseALUSrcA <= "00";
					ChooseALUSrcB <= "000";
					ChooseALUOp <= "000";
					--end init signals
					
					--default state
					state <= instruction_fetch;
					
					case instruction(15 downto 11) is
						when "00010" =>
							--B
							ChoosePCSrc <= "10";
							WritePC <= '1';
							state <= instruction_fetch;
						when "00100" =>
							--BEQZ
							ChoosePCSrc <= "10";
							WritePC <= not BranchZF;--Branch when R[rx]=0 <=> ZF = 0
							state <= instruction_fetch;
						when "00101" =>
							--BNEQ
							ChoosePCSrc <= "10";
							WritePC <= BranchZF;--Branch when R[rx]!=0 <=> ZF != 0
							state <= instruction_fetch;
						when "00110" =>
							--SLL SRA
							WriteReg <= '1';
							ChooseND <= "00";--Choose R[rx]
							ChooseDI <= "000";--Choose RA(R[ry] SLL/SRA ALUSrcB)
							state <= instruction_fetch;
						when "01000" =>
							--ADDIU3
							WriteReg <= '1';
							ChooseND <= "01";--Choose R[ry]
							ChooseDI <= "000";--Choose RA(R[rx] ADD SE(immediate))
							state <= instruction_fetch;
						when "01001" =>
							--ADDIU
							WriteReg <= '1';
							ChooseND <= "00";--Choose R[rx]
							ChooseDI <= "000";--Choose RA(R[rx] ADD SE(immediate))
							state <= instruction_fetch;
						when "01010" =>
							--SLTI
						when "01011" =>
							--SLTUI
						when "01100" =>
							--ADDSP BTEQZ BTNEZ MTSP SW_RS
							case instruction(10 downto 8) is
								when "011" =>
									--ADDSP
								when "000" =>
									--BTEQZ
								when "001" =>
									--BTNEZ
								when "100" =>
									--MTSP
								when "010" =>
									--SW_RS
								when others => null;
							end case;
						when "01101" =>
							--LI
						when "01110" =>
							--CMPI
						when "10010" =>
							--LW_SP
							ChooseND <= "00";--Choose R[rx]
							ChooseDI <= "100";--Choose Mem[RA]
							WriteReg <= '1';
							state <= instruction_fetch;
						when "10011" =>
							--LW
							ChooseND <= "01";--Choose R[ry]
							ChooseDI <= "100";--Choose Mem[RA]
							WriteReg <= '1';
							state <= instruction_fetch;
						when "11010" =>
							--SW_SP
						when "11011" =>
							--SW
						when "11100" =>
							--ADDU SUBU
							case instruction(1 downto 0) is
								when "01" =>
									--ADDU
									WriteReg <= '1';
									ChooseND <= "10";--Choose R[rz]
									ChooseDI <= "000";--Choose RA
									state <= instruction_fetch;
								when "11" =>
									--SUBU
									WriteReg <= '1';
									ChooseND <= "10";--Choose R[rz]
									ChooseDI <= "000";--Choose RA
									state <= instruction_fetch;
								when others => null;
							end case;
						when "11101" =>
							--AND CMP JR MFPC OR
							case instruction(4 downto 0) is
								when "01100" =>
									--AND
									WriteReg <= '1';
									ChooseND <= "00";--Choose R[rx]
									ChooseDI <= "000";--Choose RA
									state <= instruction_fetch;
								when "01010" =>
									--CMP
								when "00000" =>
									--JR MFPC
									case instruction(7 downto 5) is
										when "000" =>
											--JR
										when "010" =>
											--MFPC
										when others => null;
									end case;
								when "01101" =>
									--OR
									WriteReg <= '1';
									ChooseND <= "00";--Choose R[rx]
									ChooseDI <= "000";--Choose RA
									state <= instruction_fetch;
								when others => null;
							end case;
						when "11110" =>
							--MFIH MTIH
							case instruction(4 downto 0) is
								when "00000" =>
									--MFIH
								when "00001" =>
									--MTIH
								when others => null;
							end case;
						when others => null;
					end case;
				when others =>
					state <= instruction_fetch;
			end case;
		end if;
	end process;

end Behavioral;
