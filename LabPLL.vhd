----------------------------------------------------------------------------------
-- Company:			JHU ECE
-- Engineer:		Alex Heinz
-- 
-- Create Date:		20:12:46 11/28/2010 
-- Design Name:		LabPLL
-- Module Name:		LabPLL - Structural 
-- Project Name:	LabPLL
-- Target Devices:	Xilinx Spartan3 XC3S1000
-- Tool versions:	Xilinx ISE 11
-- Description:		Top-level entity for a 250kHz-range phase-locked loop unit.
--
-- Dependencies:	IEEE standard libraries, AHeinzDeclares package,
--					PhaseLockedLoop250kHz entity, ToggleD entity,
--					CounterClockDivider entity
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use WORK.AHeinzDeclares.all;

entity LabPLL is
port
(
	-- 100 MHz global clock
	clk100	: in	std_logic;
	
	-- Reset switch (active-low)
	swrst	: in	std_logic;
	
	-- PLL-enable toggle switch
	sw1		: in	std_logic;
	
	-- PLL input signal
	sig1	: in	std_logic;
	
	-- Flash-controller disable
	fceb	: out	std_logic;
	
	-- PLL output signal
	sig2	: out	std_logic
);
end LabPLL;

architecture Structural of LabPLL is
	
begin
	
end Structural;
