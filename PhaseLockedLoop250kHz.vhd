----------------------------------------------------------------------------------
-- Company:			JHU ECE
-- Engineer:		Alex Heinz
-- 
-- Create Date:		19:37:04 11/28/2010 
-- Design Name:		LabPLL
-- Module Name:		PhaseLockedLoop250kHz - Behavioral 
-- Project Name:	LabPLL
-- Target Devices:	Xilinx Spartan3 XC3S1000
-- Description:		A second-order phase-locked loop entity designed to lock onto
--					an external square-wave signal clocked at or near 250 kHz.
--
-- Dependencies:	IEEE standard libraries, AHeinzDeclares package
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use WORK.AHeinzDeclares.all;

entity PhaseLockedLoop250kHz is
port
(
	-- Internal (i.e., FPGA-local) 100 MHz sampling clock
	clk100MHz	: in	std_logic;
	
	-- Reset
	reset		: in	std_logic;
	
	-- External signal, with which this entity will attempt to synchronize
	lockSignal_external	: in	std_logic;
	
	-- Lock-enable; if clear, this entity is a pass-through for the external signal
	lockEnable	: in	std_logic;
	
	-- Output signal
	signalOut	: out	std_logic
);
end PhaseLockedLoop250kHz;

architecture Behavioral of PhaseLockedLoop250kHz is
	
	-- Constants
	constant INITIAL_PHASE_INCREMENT	: signed(31 downto 0)	:= TO_SIGNED(107_374_182, 32);
	
	-- Internal signals
	-- Clock-synched input signal
	signal lockSignal	: std_logic;
	
	-- Phase-accumulator value
	signal phaseAccumulator		: signed(31 downto 0);
	signal nextAccumulatorValue	: signed(31 downto 0);
	
	-- Alias for MSB of phase accumulator
	alias accumulatorMSB		: std_logic is phaseAccumulator(31);
	
	-- Phase-accumulator increment
	signal phaseIncrement		: signed(31 downto 0);
	signal nextIncrement		: signed(31 downto 0);
	attribute INIT of phaseIncrement	: signal is "INITIAL_PHASE_INCREMENT";
	
begin
	
	-- Input-signal synchronizer process
	process (clk100MHz, reset)
	begin
		-- Clear latched signal value on reset
		if (reset = AH_ON) then
			lockSignal <= '0';
		-- Latch new signal value from input signal on clock edges
		elsif rising_edge(clk100MHz) then
			lockSignal <= lockSignal_external;
		end if;
	end process;
	
	-- Accumulator process
	process (clk100MHz, reset)
	begin
		-- Clear accumulator on reset
		if (reset = AH_ON) then
			phaseAccumulator <= (others => '0');
		-- Latch next accumulator value on clock edges
		elsif rising_edge(clk100MHz) then
			phaseAccumulator <= nextAccumulatorValue;
		end if;
	end process;
	
	-- Next-accumulator-value logic
	-- Add the phase-increment value on every cycle
	nextAccumulatorValue <=	(phaseAccumulator + phaseIncrement);
	
	-- Frequency/phase locking adjustments process
	process (lockSignal, reset)
	begin
		-- On reset, reinitialize the phase-increment value
		if (reset = AH_ON) then
			phaseIncrement <= INITIAL_PHASE_INCREMENT;
			-- FIXME: other stuff?
		elsif falling_edge(lockSignal) then
			-- FIXME: WRITEME
		end if;
	end process;
	
	-- FIXME: WRITEME: next-values logic
	
	-- Output signal:
	-- If the lock is disabled, pass the input through; (after synching)
	-- otherwise, use the MSB of the accumulator
	signalOut <= accumulatorMSB when (lockEnable = AH_ON) else lockSignal;
	
end Behavioral;
