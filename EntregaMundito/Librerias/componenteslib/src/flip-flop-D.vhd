-------------------------------------------------------------------------------
--  Facultad de Ingeniería de la Universidad de Buenos Aires
--  Sistemas Digitales
--  2° Cuatrimestre de 2015
-- 
--  Sampayo, Sebastián Lucas
--  Padrón: 93793
--  e-mail: sebisampayo@gmail.com
-------------------------------------------------------------------------------

----------------
-- Flip-Flop D
----------------
library IEEE;
use IEEE.std_logic_1164.all;
-------------------------------------------------------------------------------
entity ffd is
	port(
    rst: in std_logic;
		clk: in std_logic;
		enable: in std_logic;
		D: in std_logic;
		Q: out std_logic
	);
end entity ffd;
-------------------------------------------------------------------------------
architecture ffd_arch of ffd is
begin
	process(clk, rst, enable)
	begin
		if rst = '1' then
			Q <= '0';
		elsif clk'event and clk = '1' then -- Cuando hay un flanco ascendente
			if enable = '1' then 
				Q <= D;
			end if;
		end if;
	end process;
end ffd_arch;
-------------------------------------------------------------------------------
