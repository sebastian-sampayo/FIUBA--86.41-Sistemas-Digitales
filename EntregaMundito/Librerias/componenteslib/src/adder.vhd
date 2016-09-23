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
-- Sumador/Restador de N bits (A+-B)
--------------------------------
-- Implementado con N full adders en cascada. Si control = '1' resta.
library IEEE;
use IEEE.std_logic_1164.all;
use work.my_components.all;

entity adder is 
	generic (N:natural:=8);
	port(
		A: in std_logic_vector(N-1 downto 0);
		B: in std_logic_vector(N-1 downto 0);
		control: in std_logic;
		S: out std_logic_vector(N-1 downto 0);
		Cout: out std_logic
	);
end;

architecture adder_beh of adder is

	signal Coutput: std_logic_vector(N downto 0);
	signal B_aux: std_logic_vector(N-1 downto 0);
		
	begin
		Coutput(0) <= control;
		ciclo: for i in 1 to N generate
			B_aux(i-1) <= B(i-1) XOR control;
			full_adder_1_bit_inst: full_adder_1_bit 
        port map(
          A(i-1),
          B_aux(i-1),
          Coutput(i-1), 
          S(i-1), 
          Coutput(i)
        );
		end generate;
	Cout <= Coutput(N);
end architecture;
