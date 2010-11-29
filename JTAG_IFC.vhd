--Copywrite Johns Hopkins University ECE Dept - R.E. Jenkins
--Lab class BSCAN interface for JTAG operations.
-----------------------------------------------
--BSCAN primitive handles JTAG 8 byte data exchanges with the PC. 
--With XSUSB connection, jtag pins are controlled by the XSUSB interface.
--With the XSUSB, each time a new packet is processed, we expect the BSCAN 
--   to go thru CAPTURE, SHIFTDR(to shift tdi/tdo data), UPDATE states.
---------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all; 

entity JTAG_IFC  is	--generic(PK_SIZE:natural:=64)	
port(
	--clk100:		in std_logic;		--sync clock for bscan drck
	bscan:			out std_logic_vector(3 downto 0); --state of some BSCAN outputs
	dat_to_pc:		in  std_logic_vector(63 downto 0); --current bits to go out via tdo
	dat_from_pc:	out std_logic_vector(63 downto 0)  --last bits received from PC via tdi
	);
end JTAG_IFC;
--------
architecture ARCH of JTAG_IFC is

-- Boundary Scan primitive for connecting internal logic to Spartan-3 JTAG.
component BSCAN_SPARTAN3 port(
 CAPTURE:	out std_logic; 	-- CAPTURE output from TAP controller
 DRCK1	:	out std_logic; 	-- Data register output for USER1 functions
 DRCK2	:	out std_logic; 	-- Data register output for USER2 functions
 RESET	:	out std_logic; 	-- Reset output from TAP controller
 SEL1		:	out std_logic; 	-- USER1 active output
 SEL2		:	out std_logic; 	-- USER2 active output
 SHIFT	:	out std_logic; 	-- SHIFT output from TAP controller
 TDI		:	out std_logic; 	-- TDI output from TAP controller
 UPDATE 	:	out std_logic; 	-- UPDATE output from TAP controller
 TDO1		:	in std_logic; 	-- Data input for USER1 function
 TDO2		:	in std_logic 	-- Data input for USER2 function
	);    end component;
-----------------------------------------------
signal CAPTURE,DRCK1,RESET,SEL1,SHIFT,TDI,UPDATE,TDO1: std_logic;
--signal sreg: std_logic_vector(3 downto 0); 		--for sync'ing drck1.
--attribute shreg_extract : string;					--Don't infer primitive SR's
--attribute shreg_extract of sreg: signal is "no"; 	--  to avoid reset problems.
--attribute INIT: string;
--attribute INIT of sreg: signal is "1111";
signal tclk: std_logic;	--sync'ed version of drck1
signal bitcnt: integer range 0 to 512;				--counter for data bits shifted
signal tdidat: std_logic_vector(dat_from_pc'HIGH downto 0); --reg to receive tdi bits
attribute clock_signal : string;
attribute clock_signal of tclk : signal is "yes";

begin

-- Instantiate the spartan-3 Boundary Scan primitive
UBSCAN_SP3 : BSCAN_SPARTAN3 --note we only operate in USER1 mode
 port map (
	CAPTURE 	=> CAPTURE,  --CAPTURE output from TAP controller
	DRCK1 	=> DRCK1, 	-- Data register output for USER1 functions
	DRCK2 	=> open, 	-- Data register output for USER2 functions
	RESET 	=> RESET, 	-- Reset output from TAP controller
	SEL1 		=> SEL1, 	-- USER1 active output
	SEL2 		=> open, 	-- USER2 active output
	SHIFT 	=> SHIFT, 	-- SHIFT output from TAP controller
	TDI 	   => TDI, 	   -- TDI output from TAP controller
	UPDATE 	=> UPDATE, 	-- UPDATE output from TAP controller
	TDO1 		=> TDO1, 	-- Data input for USER1 function
	TDO2 		=> '0' 	   -- Data input for USER2 function
	);
--output the BSCAN state for debug or control
bscan(3 downto 0)<= (RESET, UPDATE, SHIFT, SEL1);
------------------------
--Generate a single-cycle pulse on the rising edge of drck1.
--clean-up the drck which seems to get glitches when the SDRAM refreshes on the XSA-3S Brd.
--process(RESET, sclk, sreg) is begin
--if RESET = '1' then
--	sreg <= (others=> '1');
--	tclk<= '1';
--elsif rising_edge(sclk) then
--   sreg <= DRCK1 & sreg(sreg'high downto 1);
--   if sreg = "1100" then  -- make sure we have a clean edge on drck
--      tclk <= '1';
--   else  --sreg = "0011" then
--		tclk <= '0';
--   end if;
--end if;
--end process;
tclk<= DRCK1;   --According to Dave, we might have to debounce this as above. 
-------------------------
--the tdo pin will reflect the new TDO1 value on drck falling edge
TDO1<= dat_to_pc(bitcnt); 

--These processes only respond when USER1 state is active, i.e. SEL1 = '1'
Process (tclk, CAPTURE, TDI, bitcnt) is begin
if CAPTURE = '1' then  --capture only active in the user1 state
  bitcnt<= 0;	--when CAPTURE goes high we are starting a new jtag operation
--we only get a shift clock when TAP is in USER1/SHIFTDR state
elsif rising_edge(tclk) then  
   bitcnt<= bitcnt + 1;
   tdidat(bitcnt)<= TDI;
end if;
end process;
----------
--Latch the received packet when TAP goes into UPDATE state,
--which indicates the end of the current tdi_tdo_cmd operation
Process (UPDATE) is begin
if rising_edge(UPDATE) then  
   dat_from_pc<= tdidat;  --latch the tdi bits of the last tdi_cmd
end if;
end process;
-----------------------
END  ARCH;