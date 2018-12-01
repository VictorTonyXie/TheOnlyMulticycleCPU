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
	signal SignExtend: std_logic_vector(4 downto 0);
	signal ChooseSP: std_logic;
	signal ChoosePCSrc: std_logic_vector(1 downto 0);
	signal ChooseALUSrcA: std_logic_vector(1 downto 0);
	signal ChooseALUSrcB: std_logic_vector(2 downto 0);
	signal ChooseALUOp: std_logic_vector(2 downto 0);

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
			WriteMem <= '0';
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
					WriteMem <= '1';
					WriteIR <= '1';
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
					
					case instruction(15 downto 11) is
						when "00001" =>
							--NOP
							state <= instruction_fetch;
						when others =>
							state <= decode;
					end case;
				when decode =>
					--init signals
					WritePC <= '0';
					WriteMem <= '0';
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
					--end init signals
					
					state <= execute;
					
					--SignExtend
					case instruction(15 downto 11) is
						when "00010" =>
							--B
							SignExtend <= "11011";
							WritePC <= '1';
							ChoosePCSrc <= "01";--PC <- ALUR
							state <= instruction_fetch;
						when "00100" =>
							--BEQZ
							SignExtend <= "11000";
							WriteRA <= '1';
							ChoosePCSrc <= "10";--PC <- RA
							state <= execute;
						when "00101" =>
							--BNEQ
							SignExtend <= "11000";
							WriteRA <= '1';
							ChoosePCSrc <= "10";--PC <- RA
							state <= execute;
						when "00110" =>
							--SLL SRA
							case instruction(1 downto 0) is
								when "00" =>
									--SLL
									SignExtend <= "00011";
								when "11" =>
									--SRA
									SignExtend <= "00011";
								when others => null;
							end case;
						when "01000" =>
							--ADDIU3
							SignExtend <= "10100";
						when "01001" =>
							--ADDIU
							SignExtend <= "11000";
						when "01010" =>
							--SLTI
							SignExtend <= "11000";
						when "01011" =>
							--SLTUI
							SignExtend <= "01000";
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
									ChoosePCSrc <= "10";--Choose ALUR
									ChooseALUOp <= "000";--Choose ADD
									ChooseALUSrcA <= "01";--Choose PC
									ChooseALUSrcB <= "100";--Choose SE(immediate)
									WritePC <= not BranchT;
									state <= instruction_fetch;
								when "001" =>
									--BTNEZ
									SignExtend <= "11000";
									SignExtend <= "11000";
									ChoosePCSrc <= "10";--Choose ALUR
									ChooseALUOp <= "000";--Choose ADD
									ChooseALUSrcA <= "01";--Choose PC
									ChooseALUSrcB <= "100";--Choose SE(immediate)
									WritePC <= BranchT;
									state <= instruction_fetch;
								when "100" =>
									--MTSP
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
							state <= instruction_fetch;
						when "01110" =>
							--CMPI
							SignExtend <= "11000";
						when "10010" =>
							--LW_SP
							SignExtend <= "11000";
							ChooseALUOp <= "000";--Choose ADD
							ChooseALUSrcA <= "00";--Choose SP
							ChooseALUSrcB <= "100";--Choose SE(immediate)
							WriteRA <= '1';
							state <= mem_control;
						when "10011" =>
							--LW
							SignExtend <= "10101";
						when "11010" =>
							--SW_SP
							SignExtend <= "11000";
							ChooseALUOp <= "000";--Choose ADD
							ChooseALUSrcA <= "00";--Choose SP
							ChooseALUSrcB <= "100";--Choose SE(immediate)
							WriteRA <= '1';
							state <= execute;
						when "11011" =>
							--SW
							SignExtend <= "10101";
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
										when "110" =>
											--JR
										when "010" =>
											--MFPC
											ChooseND <= "00";--Choose R[rx]
											ChooseDI <= "010";--Choose PC
											state <= instruction_fetch;
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
									ChooseND <= "00";--Choose R[rx]
									ChooseDI <= "001";--Choose IH
									state <= instruction_fetch;
								when "00001" =>
									--MTIH
								when others => null;
							end case;
						when others => null;
					end case;
				when execute =>
					case instruction(15 downto 11) is
						when "00010" =>
							--B
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
							state <= write_reg;
							case instruction(1 downto 0) is
								when "00" =>
									--SLL
									ChooseALUOp <= "100";--Choose SLL
									ChooseALUSrcA <= "11";--Choose R[ry]
								when "11" =>
									--SRA
									ChooseALUOp <= "101";--Choose SRA
									ChooseALUSrcA <= "11";--Choose R[ry]
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
							state <= write_reg;
							ChooseALUOp <= "000";--Choose ADD
							ChooseALUSrcA <= "10";--Choose R[rx]
							ChooseALUSrcB <= "100";--Choose SE(immediate)
						when "01001" =>
							--ADDIU
							WriteRA <= '1';
							state <= write_reg;
							ChooseALUOp <= "000";--Choose ADD
							ChooseALUSrcA <= "10";--Choose R[rx]
							ChooseALUSrcB <= "100";--Choose SE(immediate)
						when "01010" =>
							--SLTI
							WriteT <= '1';
							state <= instruction_fetch;
							ChooseALUOp <= "110";--Choose SLT
							ChooseALUSrcA <= "10";--Choose R[rx]
							ChooseALUSrcB <= "100";--Choose SE(immediate)
						when "01011" =>
							--SLTUI
							WriteT <= '1';
							state <= instruction_fetch;
							ChooseALUOp <= "110";--Choose SLT
							ChooseALUSrcA <= "10";--Choose R[rx]
							ChooseALUSrcB <= "100";--Choose SE(immediate)
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
									ChooseSP <= '1';--Choose R[rx]
									WriteSP <= '1';
								when "010" =>
									--SW_RS
								when others => null;
							end case;
						when "01101" =>
							--LI
						when "01110" =>
							--CMPI
							ChooseALUOp <= "001";--Choose SUB
							ChooseALUSrcA <= "10";--Choose R[rx]
							ChooseALUSrcB <= "100";--Choose SE(immediate)
							WriteT <= '1';
							state <= instruction_fetch;
						when "10010" =>
							--LW_SP
						when "10011" =>
							--LW
							ChooseALUOp <= "000";--Choose ADD
							ChooseALUSrcA <= "10";--Choose R[rx]
							ChooseALUSrcB <= "100";--Choose SE(immediate)
							WriteRA <= '1';
							state <= mem_control;
						when "11010" =>
							--SW_SP
							state <= mem_control;--wait for regA ready
						when "11011" =>
							--SW
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
										when "110" =>
											--JR
											WritePC <= '1';
											ChoosePCSrc <= "00";--Choose RegA
											state <= instruction_fetch;
										when "010" =>
											--MFPC
										when others => null;
									end case;
								when "01101" =>
									--OR
									ChooseALUOp <= "011";--Choose AND
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
								when "00001" =>
									--MTIH
									WriteIH <= '1';
									state <= instruction_fetch;
								when others => null;
							end case;
						when others => null;
					end case;
				when mem_control =>
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
									WriteMem <= '1';
								when others => null;
							end case;
						when "01101" =>
							--LI
						when "01110" =>
							--CMPI
						when "10010" =>
							--LW_SP
							ChooseAddr <= "01";--Choose RA
							state <= write_reg;
						when "10011" =>
							--LW
							ChooseAddr <= "01";--Choose RA
							state <= write_reg;
						when "11010" =>
							--SW_SP
							ChooseAddr <= "01";--Choose RA
							ChooseWrite <= "01";--Choose RegA
							WriteMem <= '1';
							state <= instruction_fetch;
						when "11011" =>
							--SW
							ChooseAddr <= "01";--Choose RA
							ChooseWrite <= "10";--Choose RegB
							WriteMem <= '1';
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
										when "110" =>
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
					state <= instruction_fetch;
					
					case instruction(15 downto 11) is
						when "00010" =>
							--B
						when "00100" =>
							--BEQZ
							WritePC <= not BranchZF;--Branch when R[rx]=0 <=> ZF = 0
						when "00101" =>
							--BNEQ
							WritePC <= BranchZF;--Branch when R[rx]!=0 <=> ZF != 0
						when "00110" =>
							--SLL SRA
							WriteReg <= '1';
							ChooseND <= "00";--Choose R[rx]
							ChooseDI <= "000";--Choose RA(R[ry] SLL/SRA ALUSrcB)
						when "01000" =>
							--ADDIU3
							WriteReg <= '1';
							ChooseND <= "01";--Choose R[ry]
							ChooseDI <= "000";--Choose RA(R[rx] ADD SE(immediate))
						when "01001" =>
							--ADDIU
							WriteReg <= '1';
							ChooseND <= "00";--Choose R[rx]
							ChooseDI <= "000";--Choose RA(R[rx] ADD SE(immediate))
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
									ChooseND <= "10";--Choose R[rz]
									ChooseDI <= "000";--Choose RA
									state <= instruction_fetch;
								when "11" =>
									--SUBU
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
									ChooseND <= "00";--Choose R[rx]
									ChooseDI <= "000";--Choose RA
									state <= instruction_fetch;
								when "01010" =>
									--CMP
								when "00000" =>
									--JR MFPC
									case instruction(7 downto 5) is
										when "110" =>
											--JR
										when "010" =>
											--MFPC
										when others => null;
									end case;
								when "01101" =>
									--OR
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
