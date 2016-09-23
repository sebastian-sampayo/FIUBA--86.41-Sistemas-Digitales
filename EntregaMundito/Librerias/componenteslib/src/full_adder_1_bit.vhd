-------------------------------------------------------------------------------
--  Facultad de Ingeniería de la Universidad de Buenos Aires
--  Sistemas Digitales
--  2° Cuatrimestre de 2015
-- 
--  Sampayo, Sebastián Lucas
--  Padrón: 93793
--  e-mail: sebisampayo@gmail.com
-------------------------------------------------------------------------------

--------------------------------
-- Full adder
--------------------------------
-- Implementado combinacionalmente con XOR y AND
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
-------------------------------------------------------------------------------
entity full_adder_1_bit is 
	port(
		A: in std_logic;
		B: in std_logic;
		Cin: in std_logic;
		S: out std_logic;
		Cout: out std_logic
	);
end;
-------------------------------------------------------------------------------
architecture full_adder_1_bit_beh of full_adder_1_bit is
begin
	S <= A XOR B XOR Cin;
	Cout <= (A AND B) OR (A AND Cin) OR (B AND Cin);
end;
-------------------------------------------------------------------------------
