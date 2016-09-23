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
-- Delay.
-------------------------------------------------------------------------------
-- Genera un retardo de DELAY ciclos para un vector de N bits
-- DELAY registros en cascada.
library IEEE;
use IEEE.std_logic_1164.all;
--use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;
use work.my_components.all;

entity delay_reg is
  generic(
    N: natural:= 8;
    DELAY: natural:= 0
  );
  port(
    clock: in std_logic;
    reset: in std_logic;
    enable: in std_logic;
    A: in std_logic_vector(N-1 downto 0);
    B: out std_logic_vector(N-1 downto 0)
  );
end entity delay_reg;

architecture delay_arch of delay_reg is
  type aux_t is array(0 to DELAY+1) of std_logic_vector(N-1 downto 0);
  signal aux: aux_t;
   
begin

  aux(0) <= A;
  
  gen_retardo:
  for i in 0 to DELAY generate
    sin_retardo:
    if i = 0 generate
      aux(1) <= aux(0);
    end generate sin_retardo;
    con_retardo:
    if i > 0 generate
      aa: register_N 
        generic map (N)
        port map(
          clock => clock,
          reset => reset, 
          enable => enable,
          D => aux(i), 
          Q => aux(i+1)
        );
    end generate con_retardo;
  end generate gen_retardo;
  
  B <= aux(DELAY+1);
  
end architecture delay_arch;
