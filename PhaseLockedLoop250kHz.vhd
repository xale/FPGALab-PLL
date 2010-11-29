----------------------------------------------------------------------------------
-- Company:			JHU ECE
-- Engineer:		Alex Heinz
-- 
-- Create Date:		19:37:04 11/28/2010 
-- Design Name:		LabPLL
-- Module Name:		PhaseLockedLoop250kHz - Behavioral 
-- Project Name:	LabPLL
-- Target Devices:	Xilinx Spartan3 XC3S1000
-- Description:		A phase-locked loop entity designed to lock onto an external
--					square-wave signal clocked at or near 250 kHz.
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
	
begin
	
end Behavioral;
