-------------------------------------------------------------------------------
--  Facultad de Ingeniería de la Universidad de Buenos Aires
--  Sistemas Digitales
--  2° Cuatrimestre de 2015
-- 
--  Sampayo, Sebastián Lucas
--  Padrón: 93793
--  e-mail: sebisampayo@gmail.com
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Barrel Shifter
-------------------------------------------------------------------------------
-- Desplaza una palabra en N posiciónes a izquierda o a derecha según left
-- Si left = '1' => izquierda
-- Si left = '0' => derecha
-- Combinacional.
-- A izquierda agrega 0's en el LSB
-- A derecha agrega el MSB de x en el MSB de y para mantener el signo.
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
-------------------------------------------------------------------------------

entity barrel_shifter is
  generic(
    N : natural := 8
  );
	port(
    left : in std_logic;
    M : in natural;
    x : in std_logic_vector(N-1 downto 0);
    y : out std_logic_vector(N-1 downto 0)
	);
end entity barrel_shifter;
-------------------------------------------------------------------------------

architecture barrel_shifter_arch of barrel_shifter is

  type aux_t is array(natural range <>) of std_logic_vector(N-1 downto 0);
  signal x_aux : aux_t(0 to N);

begin

  -- Desplazo de a 1 bit. Por lo tanto se suma un retardo combinacional (delta)
  -- por cada desplazamiento. El combinational path se puede hacer muy largo.
  x_aux(0) <= x;
  -- Genero el resultado para todas las posibilidades (N+1 posibilidades)
  -- es decir, cuando M = 0, M = 1, M = 2, ... , M = N
  cicle: for i in 1 to N generate
    x_aux(i) <= x_aux(i-1)(N-1) & x_aux(i-1)(N-1 downto 1) when left = '0' -- A derecha
                else x_aux(i-1)(N-2 downto 0) & '0';                     -- A izquierda
  end generate;
  y <= x_aux(M);

  -- No acepta índices variables el XST.
  -- y <= ((N-1 downto N-M => x(N-1)) & x(N-1 downto M)) when left = '0' -- A derecha
  --      else (x(N-M-1 downto 0) & (M-1 downto 0 => '0'));            -- A izquierda

end barrel_shifter_arch;
-------------------------------------------------------------------------------
