----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:41:03 12/01/2018 
-- Design Name: 
-- Module Name:    MultiCycleCPU - Behavioral 
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

entity MultiCycleCPU is
	Port(
		Clk: in std_logic;
		ram_addr: out std_logic_vector(17 downto 0);
		ram_data: inout std_logic_vector(15 downto 0);
		we_l: out std_logic;
		oe_l: out std_logic;
		wrn: out std_logic;
		rdn: out std_logic
		

	);
end MultiCycleCPU;

architecture Behavioral of MultiCycleCPU is
	component Controller
	Port(
		rst, clk: in std_logic;
		BranchT, BranchZF: in std_logic;
		instruction: in std_logic_vector(15 downto 0);
		light: out std_logic_vector(15 downto 0);
		
		WritePC: out std_logic;
		WriteMem: out std_logic_vector(1 downto 0);
		WriteIR: out std_logic;
		WriteReg: out std_logic;
		WriteT: out std_logic;
		WriteIH: out std_logic;
		WriteSP: out std_logic;
		WriteRA: out std_logic;

		ChooseAddr: out std_logic_vector(1 downto 0);
		ChooseWrite: out std_logic_vector(1 downto 0);
		ChooseND: out std_logic_vector(1 downto 0);
		ChooseDI: out std_logic_vector(2 downto 0);
		SignExtend: out std_logic_vector(4 downto 0);
		ChooseSP: out std_logic;
		ChoosePCSrc: out std_logic_vector(1 downto 0);
		ChooseALUSrcA: out std_logic_vector(1 downto 0);
		ChooseALUSrcB: out std_logic_vector(2 downto 0);
		ChooseALUOp: out std_logic_vector(2 downto 0)
	);
	end component;
	
	component LeftOne
	Port(
		Input: in std_logic_vector(15 downto 0);
		Output: out std_logic_vector(15 downto 0)
	);
	end component;
	
	component Memorizer
	Port(
		WriteMem: in std_logic_vector(1 downto 0);
		Addr: in std_logic_vector(15 downto 0);
		ToRead: out std_logic_vector(15 downto 0);
		ToWrite: in std_logic_vector(15 downto 0);
		RamAddr: out std_logic_vector(17 downto 0);
		RamData: inout std_logic_vector(15 downto 0);
		OE_L: out std_logic;
		WE_L: out std_logic
	);
	end component;
	
	component SpecRegister
	Port(
		Enable: in std_logic;
		Clk: in std_logic;
		Input: in std_logic_vector(15 downto 0);
		Output: out std_logic_vector(15 downto 0)
	);
	end component;
	
	component alu
	Port (
		input_a : in  STD_LOGIC_VECTOR (15 downto 0);
		input_b : in  STD_LOGIC_VECTOR (15 downto 0);
		control_signal : in  STD_LOGIC_VECTOR (2 downto 0);
		zero_markflag : out STD_LOGIC;
		output : out  STD_LOGIC_VECTOR (15 downto 0)
	);
	end component;
	
	component extender
	Port (
		imm : in  STD_LOGIC_VECTOR (10 downto 0);
		SignExtend : in STD_LOGIC_VECTOR (4 downto 0);
		output : out  STD_LOGIC_VECTOR (15 downto 0)
	);
	end component;
	
	component mux2to1
	Port (
		data0 : in  STD_LOGIC_VECTOR (15 downto 0);
		data1 : in  STD_LOGIC_VECTOR (15 downto 0);
		control_signal : in  STD_LOGIC;
		output : out  STD_LOGIC_VECTOR (15 downto 0)
	);
	end component;
	
	component mux4to1
	Port (
		data0 : in  STD_LOGIC_VECTOR (15 downto 0);
		data1 : in  STD_LOGIC_VECTOR (15 downto 0);
		data2 : in  STD_LOGIC_VECTOR (15 downto 0);
		data3 : in  STD_LOGIC_VECTOR (15 downto 0);
		control_signal : in  STD_LOGIC_VECTOR (1 downto 0);
		output : out  STD_LOGIC_VECTOR (15 downto 0)
	);
	end component;
	
	component mux8to1
	Port (
		data0 : in  STD_LOGIC_VECTOR (15 downto 0);
		data1 : in  STD_LOGIC_VECTOR (15 downto 0);
		data2 : in  STD_LOGIC_VECTOR (15 downto 0);
		data3 : in  STD_LOGIC_VECTOR (15 downto 0);
		data4 : in  STD_LOGIC_VECTOR (15 downto 0);
		data5 : in  STD_LOGIC_VECTOR (15 downto 0);
		data6 : in  STD_LOGIC_VECTOR (15 downto 0);
		data7 : in  STD_LOGIC_VECTOR (15 downto 0);
		control_signal : in  STD_LOGIC_VECTOR (2 downto 0);
		output : out  STD_LOGIC_VECTOR (15 downto 0)
	);
	end component;
	
	component registerFile
	Port (
		n1 : in STD_LOGIC_VECTOR (2 downto 0);
		n2 : in STD_LOGIC_VECTOR (2 downto 0);
		nd : in STD_LOGIC_VECTOR (2 downto 0);
		di : in STD_LOGIC_VECTOR (15 downto 0);
		WriteReg : in STD_LOGIC;
		clk : in STD_LOGIC;
		q1 : out STD_LOGIC_VECTOR (15 downto 0);
		q2 : out STD_LOGIC_VECTOR (15 downto 0)
	);
	end component;
	
	--signal for special registers' in & out
	signal PCIn, PCOut: std_logic_vector(15 downto 0);
	signal IROut: std_logic_vector(15 downto 0);--IRIn <=> MemToRead
	signal IHOut: std_logic_vector(15 downto 0);--IHIn <=> RegAOut
	signal DROut: std_logic_vector(15 downto 0);--DRIn <=> MemToRead
	signal RegAIn, RegAOut: std_logic_vector(15 downto 0);
	signal RegBIn, RegBOut: std_logic_vector(15 downto 0);
	signal SPIn, SPOut: std_logic_vector(15 downto 0);
	signal TIn, TOut: std_logic_vector(15 downto 0);
	signal RAIn, RAOut: std_logic_vector(15 downto 0);
	
	--signal for special registers' writing control
	signal WritePC, WriteIR, WriteIH, WriteDR, WriteRegA, WriteRegB, WriteRA, WriteSP, WriteT: std_logic:= '0';
	
	--signal for other writing control
	signal WriteReg: std_logic:= '0';
	signal WriteMem: std_logic_vector(1 downto 0):= "00";
	
	--signal for Choos***
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
	
	--signal all_zeros/all_ones always_zero/always_one
	signal all_zeros: std_logic_vector(15 downto 0):= "0000000000000000";
	signal all_ones: std_logic_vector(15 downto 0):= "1111111111111111";
	signal logic_zero: std_logic:= '0';
	signal logic_one: std_logic:= '1';
	
	--signal constant
	signal always_one: std_logic_vector(15 downto 0):= "0000000000000001";
	signal always_two: std_logic_vector(15 downto 0):= "0000000000000010";
	signal always_eight: std_logic_vector(15 downto 0):= "0000000000001000";
	signal always_z: std_logic_vector(15 downto 0):= "ZZZZZZZZZZZZZZZZ";
	
	--signal for mux
	--signal CAddrOut: std_logic_vector(15 downto 0);-- <=> MemAddr
	signal CWriteOut: std_logic_vector(15 downto 0);
	signal CNDOut: std_logic_vector(15 downto 0);
	signal CDIOut: std_logic_vector(15 downto 0);
	signal CALUSrcAOut: std_logic_vector(15 downto 0);
	signal CALUSrcBOut: std_logic_vector(15 downto 0);
	--signal CSPOut: std_logic_vector(15 downto 0);-- <=> SPIn
	--signal CPCSrcOut: std_logic_vector(15 downto 0);-- <=> PCIn
	
	--signal for immediate
	signal SEImmediate: std_logic_vector(15 downto 0);
	signal ImmediateLeftOne: std_logic_vector(15 downto 0);
	
	--signal for ALU
	signal ZF: std_logic;
	
	--signal for Memorizer
	signal MemAddr, MemToWrite, MemToRead: std_logic_vector(15 downto 0);
	
	--light?
	signal light: std_logic_vector(15 downto 0);
	
	--rx ry rz of 16 bits
	signal rx16, ry16, rz16: std_logic_vector(15 downto 0);
begin
	
	--constant
	all_zeros <= "0000000000000000";
	all_ones <= "1111111111111111";
	logic_zero <= '0';
	logic_one <= '1';
	always_two <= "0000000000000010";
	always_eight <= "0000000000001000";
	always_z <= "ZZZZZZZZZZZZZZZZ";
	
	wrn <= '1';
	rdn <= '1';
	
	--equal
	TIn <= "000000000000000" & ZF;
	rx16 <= "0000000000000" & IROut(10 downto 8);
	ry16 <= "0000000000000" & IROut(7 downto 5);
	rz16 <= "0000000000000" & IROut(4 downto 2);
	
	--registers
	PC: SpecRegister port map(WritePC, Clk, PCIn, PCOut);
	IR: SpecRegister port map(WriteIR, Clk, MemToRead, IROut);
	DR: SpecRegister port map(logic_one, Clk, MemToRead, DROut);
	RegA: SpecRegister port map(logic_one, Clk, RegAIn, RegAOut);
	RegB: SpecRegister port map(logic_one, Clk, RegBIn, RegBOut);
	IH: SpecRegister port map(WriteIH, Clk, RegAOut, IHOut);
	SP: SpecRegister port map(WriteSP, Clk, SPIn, SPOut);
	T: SpecRegister port map(WriteT, Clk, TIn, TOut);
	RA: SpecRegister port map(WriteRA, Clk, RAIn, RAOut);
	
	--mux
	MuxAddr: mux4to1 port map(PCOut, RAOut, RAIn, all_zeros, ChooseAddr, MemAddr);
	MuxWrite: mux4to1 port map(RAOut, RegAOut, RegBOut, always_z, ChooseWrite, MemToWrite);
	MuxND: mux4to1 port map(rx16, ry16, rz16, all_zeros, ChooseND, CNDOut);
	MuxDI: mux8to1 port map(RAOut, IHOut, PCOut, RegBOut, DROut, SEImmediate, all_zeros, all_zeros, ChooseDI, CDIOut);
	MuxALUSrcA: mux4to1 port map(SPOut, PCOut, RegAOut, RegBOut, ChooseALUSrcA, CALUSrcAOut);
	MuxALUSrcB: mux8to1 port map(RegAOut, RegBOut, always_one, always_eight, SEImmediate, ImmediateLeftOne, all_zeros, all_zeros, ChooseALUSrcB, CALUSrcBOut);
	MuxSP: mux2to1 port map(RAIn, RegAOut, ChooseSP, SPIn);
	MuxPCSrc: mux4to1 port map(RegAOut, RAIn, RAOut, all_zeros, ChoosePCSrc, PCIn);
	
	--Memorizer
	MemControl: Memorizer port map(WriteMem, MemAddr, MemToRead, MemToWrite, ram_addr, ram_data, oe_l, we_l);
	
	--RegisterFile
	RegFile: registerFile port map(IROut(10 downto 8), IROut(7 downto 5), CNDOut(2 downto 0), CDIOut, WriteReg, Clk, RegAIn, RegBIn);
	
	--immediate
	ExtendImm: extender port map(IROut(10 downto 0), SignExtend, SEImmediate);
	ImmLeftOne: LeftOne port map(SEImmediate, ImmediateLeftOne);
	
	--ALU
	ALUPart: alu port map(CALUSrcAOut, CALUSrcBOut, ChooseALUOp, ZF, RAIn);
	
	--Controller
	CtrlPart: Controller port map(logic_one, Clk, Tout(0), ZF, IROut, light,
		WritePC, WriteMem, WriteIR, WriteReg, WriteT, WriteIH, WriteSP, WriteRA,
		ChooseAddr, ChooseWrite, ChooseND, ChooseDI, SignExtend, ChooseSP, ChoosePCSrc, ChooseALUSrcA, ChooseALUSrcB, ChooseALUOp
	);

end Behavioral;

