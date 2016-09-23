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
-- N FFD's en serie
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

use work.my_components.all;
-------------------------------------------------------------------------------
entity ffd_serie is
  generic(
    N : natural := 1
  );
	port(
    clock: in std_logic;
    reset: in std_logic;
    enable: in std_logic;
    D : in std_logic;
    Q : out std_logic
	);
end entity ffd_serie;
-------------------------------------------------------------------------------

architecture ffd_serie_arch of ffd_serie is

  signal aux : std_logic_vector( N downto 0);

begin
  aux(0) <= D;
  delay: for i in 1 to N generate
    ffd_delay: ffd
      port map(
        D => aux(i-1),
        Q => aux(i),
        clk => clock,
        rst => reset,
        enable => enable 
      );
  end generate;
  Q <= aux(N);

end architecture ffd_serie_arch;
-------------------------------------------------------------------------------
