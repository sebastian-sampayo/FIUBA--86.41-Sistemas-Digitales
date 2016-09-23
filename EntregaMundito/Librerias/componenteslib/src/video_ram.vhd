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
-- Video RAM
-------------------------------------------------------------------------------
-- Del lado A escribe, del lado B lee, según fila y columna indicada.
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.my_components.all;
-------------------------------------------------------------------------------

entity video_ram is
  generic(
    N_bits_row : integer := 10;
    N_bits_col : integer := 10;
    N_rows : integer := 480;
    N_cols : integer := 640
  );
	port(
    clock: in std_logic;
    write_enable : in std_logic;
    A_row : in std_logic_vector(N_bits_row-1 downto 0);
    B_row : in std_logic_vector(N_bits_row-1 downto 0);
    A_col : in std_logic_vector(N_bits_col-1 downto 0);
    B_col : in std_logic_vector(N_bits_col-1 downto 0);
    data_A : in std_logic;
    data_B : out std_logic
	);
end entity video_ram;
-------------------------------------------------------------------------------

architecture video_ram_arch of video_ram is

  signal A_address : std_logic_vector(N_bits_row + N_bits_col - 1 downto 0) := (others => '0');
  signal B_address : std_logic_vector(N_bits_row + N_bits_col - 1 downto 0) := (others => '0');

begin

  A_address <= A_row & A_col;
  B_address <= B_row & B_col;

  mem: dual_port_ram
    generic map(
      DATA_WIDTH => 1,
      ADDRESS_WIDTH => N_bits_row + N_bits_col
    )
    port map(
      clock => clock,
      write_enable => write_enable,
      address_A => A_address,
      address_B => B_address,
      data_A(0) => data_A,
      data_B(0) => data_B
    );

end video_ram_arch;
-------------------------------------------------------------------------------
