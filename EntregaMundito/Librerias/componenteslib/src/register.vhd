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
-- Registro
----------------
-- Igual que un Flip-Flop-D pero entrada y salida vector de N elementos.
-- Otra opción es generar N Flip-Flops D en paralelo.
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use work.my_components.all;
-------------------------------------------------------------------------------
entity register_N is
	generic(N: natural:= 8);
	port(
		clock: in std_logic;
		reset: in std_logic;
		enable: in std_logic;
		D: in std_logic_vector(N-1 downto 0);
		Q: out std_logic_vector(N-1 downto 0)
	);
end entity register_N;
-------------------------------------------------------------------------------
architecture register_N_arch of register_N is
begin
  
  -- N flip-flops-D en paralelo
  cicle: for i in 0 to N-1 generate
    ffd_inst : ffd
      port map(
        clk => clock,
        rst => reset,
        enable => enable,
        D => D(i),
        Q => Q(i)
      );
  end generate;

	-- process(clock, reset)
	-- begin
	-- 	if reset = '1' then
	-- 		Q <= (others => '0');
	-- 	elsif rising_edge(clock) then
	-- 	  if enable = '1' then
  -- 			Q <= D;
  -- 	  end if;
	-- 	end if;
	-- end process;
end architecture register_N_arch;
-------------------------------------------------------------------------------
