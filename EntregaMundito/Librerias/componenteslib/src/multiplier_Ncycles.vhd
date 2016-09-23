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
-- Multiplicador de N bits (A*B)
--------------------------------
-- Operandos de entrada de N bits
-- Resultado de 2N bits. 
-- Los operadores se cargan con "load" en '1' en un flanco ascendente de clock
-- Luego de N ciclos, en el siguiente flanco ascendente de clock (ciclo N+1)
--  y luego de 2 deltas, se pone en '1' "done" y se puede leer el resultado.
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use work.my_components.all;
-------------------------------------------------------------------------------
entity multiplier is
	generic (N:integer:=8);
	port(	
		clock: in std_logic;
		load: in std_logic;
		A: in std_logic_vector(N-1 downto 0);
		B: in std_logic_vector(N-1 downto 0);
		result: out std_logic_vector(2*N-1 downto 0);
    done: out std_logic
	);
end entity;
-------------------------------------------------------------------------------
architecture multiplier_beh of multiplier is

	--Señales
	signal aux, regA_in, regB_in, regA_out, regB_out, regP_in, regP_out, adder_out: std_logic_vector(N-1 downto 0);
	signal Co: std_logic;
	signal enable_aux: std_logic:='1';
  signal done_aux: std_logic := '0';
	
	begin

		--instanciación del registro A
		regA_inst: register_N generic map (N) port map(clock, '0', '1', regA_in, regA_out);
		--instanciación del registro B
		regB_inst: register_N generic map (N) port map(clock, '0', '1', regB_in, regB_out);
		--instanciación del registro p
		regP_inst: register_N generic map (N) port map(clock, load, '1', regP_in, regP_out);
		--instanciación del sumador
		adder_inst: adder generic map (N) port map(aux, regP_out, '0', adder_out, Co);
		--

		regA_in <= A;
    -- Es necesario poner el registro P en cero cuando se cargan nuevos datos,
    -- además de resetear la salida.
		regP_in <= Co & adder_out(N-1 downto 1) when load = '0'
               else (others => '0');
		regB_in <= B when (load='1') else
			adder_out (0) & regB_out(N-1 downto 1);
		aux <= regA_out when regB_out(0)='1' else
			(others=>'0');
			
    -- para poder controlar desde el process inmediatamente:
    done <= done_aux;
    -- Muestro la salida únicamente cuando es válida.
		result <= regP_out & regB_out when done_aux = '1'
              else (others => 'X');

    -- Este proceso controla la validez de la salida
    process (clock)
			variable i: integer:=0;
			begin
				if rising_edge(clock) then
					if load = '1' then
						i := 0;
            done_aux <= '0';
					end if;

					if i<N then
						i := i+1;
					elsif i=N then
            done_aux <= '1';
            i := i+1;
          else 
            done_aux <= '0';
					end if;
				end if;
		end process;

end architecture;
-------------------------------------------------------------------------------
