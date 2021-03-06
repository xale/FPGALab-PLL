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
use WORK.FPGALabDeclares.all;

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
	sig3	: out	std_logic;
	
	-- PLL-enabled LED
	lsdp	: out	std_logic
);
end LabPLL;

architecture Structural of LabPLL is
	
	-- Constants
	-- Divisor for toggle-switch sample clock
	constant TOGGLE_SAMP_CLK_DIV	: integer	:= 3_000_000;
	
	-- Internal signals
	-- Inverted (active-high) reset
	signal reset		: std_logic;
	
	-- Master clock
	signal masterClk	: std_logic;
	
	-- Toggle-switch sampling clock
	signal toggleSampleClk	: std_logic;
	signal sampleHeartbeat	: std_logic;
	
	-- PLL-enable/pass-through signal
	signal PLLEnable	: std_logic;
	
begin
	
	-- Tie flash-controller off
	fceb <= AL_OFF;
	
	-- Invert external reset signal
	reset <= NOT swrst;
	
	-- Add buffers to master clock
	ClkBuf: IBUFG port map(I => clk100, O => masterClk);
	
	-- Instantiate PLL-enable-control toggle entity (and sampling-clock divider)
	ToggleClkDiv: CounterClockDivider
	generic map (MAX_DIVISOR => TOGGLE_SAMP_CLK_DIV)
	port map
	(
		clkIn => masterClk,
		reset => reset,
		divisor => TOGGLE_SAMP_CLK_DIV,
		clkOut => toggleSampleClk
	);
	EnableToggle: ToggleD
	port map
	(
		buttonRaw_AL => sw1,
		clk => toggleSampleClk,
		reset => reset,
		bufferedRawOut => open,
		--bufferedRawOut => lsdp,	-- FIXME: TESTING
		--Q => PLLEnable
		Q => open -- FIXME: TESTING
	);
	
	
	PLLEnable <= '0'; -- FIXME: TESTING
	
	process (toggleSampleClk, reset)
	begin
		if (reset = AH_ON) then
			sampleHeartbeat <= AH_OFF;
		elsif rising_edge(toggleSampleClk) then
			sampleHeartbeat <= NOT sampleHeartbeat;
		end if;
	end process;
	lsdp <= sampleHeartbeat; -- FIXME: TESTING
	
	sig3 <= masterClk; -- FIXME: TESTING
	
	-- Show enabled/disabled status on an LED
	--lsdp <= PLLEnable; -- FIXME: TESTING
	
	-- Instantiate PLL component
	PLL: PhaseLockedLoop250kHz
	port map
	(
		-- Connect master clock
		clk100MHz => masterClk,
		
		-- Connect global reset
		reset => reset,
		
		-- Connect external signal
		lockSignal_external	=> sig1,
		
		-- Enable/disable phase-lock based on toggle switch
		lockEnable => PLLEnable,
		
		-- Route output signal to a pin
		--signalOut => sig3
		signalOut => open -- FIXME: TESTING
	);
	
end Structural;
