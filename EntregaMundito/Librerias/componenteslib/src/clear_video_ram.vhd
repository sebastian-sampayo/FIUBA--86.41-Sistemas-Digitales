-------------------------------------------------------------------------------
--  Facultad de Ingeniería de la Universidad de Buenos Aires
--  Sistemas Digitales
--  2° Cuatrimestre de 2015
-- 
--  Sampayo, Sebastián Lucas
--  Padrón: 93793
--  e-mail: sebisampayo@gmail.com
-------------------------------------------------------------------------------
-- Clear Video RAM
-------------------------------------------------------------------------------
-- Genera 2 contadores (fila y columna) para barrer la video ram
-- Si tiene N columnas/filas, cuenta de 0 a N-1
-- Tarda N_ROWS*N_COLS ciclos de clock en completar la tarea.
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.my_components.all;
-------------------------------------------------------------------------------

entity clear_video_ram is
  generic(
    N_bits_row: natural := 2;
    N_bits_col: natural := 2;
    N_ROWS: natural := 2;
    N_COLS: natural := 2
  );
	port(
    clock: in std_logic;
    reset: in std_logic;
    enable: in std_logic;
    row_counter: out std_logic_vector(N_bits_row-1 downto 0);
    col_counter: out std_logic_vector(N_bits_col-1 downto 0);
    carry_out: out std_logic
	);
end entity clear_video_ram;
-------------------------------------------------------------------------------

architecture clear_video_ram_arch of clear_video_ram is

  signal row_enable_aux : std_logic := '0';
  signal row_enable : std_logic := '0';

begin

  col_counter_inst: counter
   generic map(
     N_bits => N_bits_col,
     MAX_COUNT => N_COLS-1
   )
   port map(
    clock => clock,
    reset => reset,
    enable => enable,
    counter_output => col_counter,
    carry_out => row_enable_aux
  );

  -- Contador de filas
  row_enable <= enable AND row_enable_aux;
  row_counter_inst: counter
   generic map(
     N_bits => N_bits_row,
     MAX_COUNT => N_ROWS-1
   )
   port map(
    clock => clock,
    reset => reset,
    enable => row_enable,
    counter_output => row_counter,
    carry_out => carry_out
  );

end clear_video_ram_arch;
-------------------------------------------------------------------------------
