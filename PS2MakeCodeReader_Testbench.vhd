----------------------------------------------------------------------------------
-- Company:			JHU ECE
-- Engineer:		Alex Heinz
-- 
-- Create Date:		18:23 12/1/2010 
-- Design Name:		Lab PLL
-- Module Name:		PhaseLockedLoop250kHz_Testbench
-- Project Name:	Lab PLL
-- Target Devices:	N/A (Behavioral Simulation)
-- Description:		Test bench for a 250kHz-range second-order phase-locked loop.
--
-- Dependencies:	IEEE standard libraries, PhaseLockedLoop250kHz entity
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PhaseLockedLoop250kHz_Testbench is
end PhaseLockedLoop250kHz_Testbench;

architecture model of PhaseLockedLoop250kHz_Testbench is

	-- Component declaration for Unit Under Test (UUT)
	component PhaseLockedLoop250kHz is
	port
	(
		clk100MHz	: in	std_logic;
		reset		: in	std_logic;
		lockSignal_external	: in	std_logic;
		lockEnable	: in	std_logic;
		signalOut	: out	std_logic;
		phaseOut	: out	signed(31 downto 0)
	);

	end component;
	
	-- UUT control clock
	signal clk			: std_logic := '0';
	constant CLK_PERIOD	: time := 10 ns;
	
	-- Inputs to UUT
	signal reset		: std_logic	:= '1';
	signal lockEnable	: std_logic	:= '0';
	
	-- Outputs read from UUT
	signal signalOut	: std_logic;
	signal phaseOut		: signed(31 downto 0);

begin

	-- Instantiate UUT, mapping inputs and outputs to local signals
	uut: PhaseLockedLoop250kHz
	port map
	(
		clk100MHz	=> clk,
		reset => reset,
		lockSignal_external => '0',
		lockEnable => lockEnable,
		signalOut => signalOut,
		phaseOut => phaseOut
	);
	
	-- Clock tick process
	process is begin
	
		-- Clock low for half period
		clk <= '0';
		wait for (CLK_PERIOD / 2);
	
		-- Clock high for half period
		clk <= '1';
		wait for (CLK_PERIOD / 2);
	
		-- (Repeats forever)
		
	end process;
	
	-- Model process
	process is begin
	
		wait for CLK_PERIOD;
		
		reset <= '0';
		lockEnable <= '1';
		
		-- Loop forever
		
	end process;

end model;
