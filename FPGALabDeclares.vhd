--Example package for 424 class. Contains examples of declarations and functions.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

--For correct simulation of a module that instantiates a XILINX library primitive, 
--  add the following library declaration to the code.
--library UNISIM;
--use UNISIM.VComponents.all;

---*******************************
PACKAGE FPGALabDeclares is
---*******************************
constant YES:		std_logic := '1';	--examples of declaring a constant.
constant NO:		std_logic := '0';
constant HI:  	   	std_logic := '1';	--Such entries can be used in signal assignments for readability
constant LO:		std_logic := '0';
constant DIV16HZ:	integer   := 3124999;	--divisor for 16hz from 50Mhz.
----example of a ROM implementation-----------------
type ROM16X4 is array (0 to 11) of std_logic_vector (3 downto 0); --define a new signal type
constant LUT_L: ROM16X4:=	("1000", "1101","0010","1100", --initilize a constant of that type
"0100","0101","0100","0010","1101","0000","0100","0001");
-----Example of a user defined array type--------------
type EIGHT_BYTE is array (1 to 8) of std_logic_vector(7 downto 0); --used in USB interface
----some function examples------------------------------
function LOG2(v: in natural) return natural;
function UNSIGNED_TO_STDV (ARG:unsigned) return std_logic_vector;
function STDV_TO_UNSIGNED (ARG:std_logic_vector) return unsigned;
function ENCODE (vect:std_logic_vector) return integer;

-----------Xilinx library primitives declarations------
component BUFG port(I: in std_logic; O: out std_logic); end component;
component IBUFG port(I: in std_logic; O: out std_logic); end component;
component IBUF port(I: in std_logic; O: out std_logic); end component;

-----------User VHDL component declarations-----------
component fulladd   -- single bit full adder cell by structure
  port (I1: in std_logic;
        I2: in std_logic;
        cin: in std_logic;
        sum: out std_logic;
        cout: out std_logic );
  end component;
---------------------------------
component Toggle1   
  port (S: in std_logic; 	--S is usually an Xstend pushbutton(active low).
        reset: in std_logic; 	--reset is NOT-swrst pushbutton
        Q: out std_logic );   	--output state toggles on button push
end component;
---------------------------------
component GenClks is		--clock generation module for 520.424 class projects
      port (clkext: in std_logic;
  	reset: 	in std_logic;
  	clk10m: out std_logic;
	clk16hz: out std_logic );
end component;
---------------------------------
component JTAG_IFC  is
  port(bscan:			out std_logic_vector(3 downto 0);
	dat_to_pc:		in  std_logic_vector(63 downto 0);
	dat_from_pc:	out std_logic_vector(63 downto 0)
	);
end component;
----------------------------------
component Virt_ledc  is		
port(clkext: 	in 	std_logic;			--50mhz clk in 
	vclk:		in	std_logic;			--bit clock in from parallel port
	reset: 		in 	std_logic; 
	d1,d2,d3,d4: in std_logic_vector(3 downto 0);	--4 hex values for display
	pps: 		out std_logic_vector(5 downto 3)	--data out to parallel port-S
	);  end component;
-------------------------------
component PortD200  is	--interface to port-D for xsa200+ uses only ppd(5 4 3 2 0)
port(clkext:in 	std_logic;				--50 Mhz external clock
	ppd: 	in  std_logic_vector(4 downto 0);  --Port-D data in
	reset: 	in  std_logic;
	pdbyte:	out std_logic_vector(7 downto 0)  --port-D byte written by PC as 2 nibbles
	);  end component;
---------------------------------------
component SMCNVRT is	-- keyboard make-code to ASCII converter
port(sm2clk: in	std_logic;	-- State-machine clock
	reset: in	std_logic;
	newcode: in	std_logic;	-- Input-ready signal (assert to start conversion)
	keycode: in	std_logic_vector(7 downto 0);	-- Input bus (one byte)
	convdone: out	std_logic;	-- Conversion-done signal (asserted when ready for read)
	hdout: out	std_logic_vector(15 downto 0);	-- Output bus (two bytes)
	wrdone: in	std_logic	-- Write-done signal (assert when converted value has been read)
	);	end component;

---********************************************************
END PACKAGE FPGALabDeclares; 
---********************************************************

--A Package body includes functions or procedures that a user or project team has 
--developed to handle their own signal types and processes.
--The below examples won't be used in the class, but let you see how a function is defined.
--Later you'll write your own function, and add it to the package body for use in your projects.
---***************************************
PACKAGE BODY FPGALabDeclares  is	 
---***************************************
--These functions are included as examples.
function LOG2(v: in natural) return natural is	--return Log2 of arg.
	variable n: natural;
	variable logn: natural;
begin
	n := 1;
	for i in 0 to 128 loop
		logn := i;
		exit when (n>=v);
		n := n * 2;
	end loop;
	return logn;
end function log2;
-----------------------------------------------------
function STDV_TO_UNSIGNED (ARG:std_logic_vector) return UNSIGNED is
 -- Convert std_logic_vector to unsigned vector
variable result: unsigned(ARG'HIGH downto ARG'LOW);
begin
for i in ARG'HIGH downto ARG'LOW loop --notice, attributes are used for generality
	result(i):=ARG(i);
end loop;
return result;
end function STDV_TO_UNSIGNED;
-----------------------------------------------------
function UNSIGNED_TO_STDV (ARG:UNSIGNED) return STD_LOGIC_VECTOR is
 -- Convert unsigned vector to std_logic_vector
variable result: std_logic_vector(ARG'HIGH downto ARG'LOW);
begin
for i in ARG'HIGH downto ARG'LOW loop
	result(i):= ARG(i);
end loop;
return result;
end UNSIGNED_TO_STDV;
-----------------------------------------------------
function ENCODE (vect: std_logic_vector) return integer is
--Assumes vect has elements M downto 0, returns integer of range 0 to M.
--The returned value is the largest subscript of any element in vect that is a '1'.
variable numlit: integer range 0 to 1+vect'HIGH;
begin
numlit:=0;
for j in vect'HIGH downto 0 loop
    if vect(j)='1' then
		if numlit=0 then
        	numlit:= j;
		else
			numlit:=1+vect'HIGH;
 		    exit;
		end if;
     end if;
end loop;
return numlit;
end ENCODE;
-----------------------------------------------

----*****************************************************
END PACKAGE BODY FPGALabDeclares; 
----*****************************************************

