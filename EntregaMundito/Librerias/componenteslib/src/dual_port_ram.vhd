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
-- Dual Port RAM
-------------------------------------------------------------------------------
-- Del lado A escribe, del lado B lee.
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
-------------------------------------------------------------------------------

entity dual_port_ram is
  generic(
    DATA_WIDTH : natural := 1;
    ADDRESS_WIDTH : natural := 18
  );
	port(
    clock: in std_logic;
    write_enable : in std_logic;
    address_A : in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    address_B : in std_logic_vector(ADDRESS_WIDTH-1 downto 0);
    data_A : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    data_B : out std_logic_vector(DATA_WIDTH-1 downto 0)
	);
end entity dual_port_ram;
-------------------------------------------------------------------------------

architecture dual_port_ram_arch of dual_port_ram is

  -- Con esto reduzco el tamaño de la memoria a lo que realmente voy a usar
  -- constant memo_size : natural := N_rows*N_cols;
  -- constant memo_size : natural := N_rows*(2**N_bits_col);
  -- Este sería el tamaño que corresponde según la cantidad de bits de address
  constant memo_size : natural := 2**(ADDRESS_WIDTH);
  subtype word_t is std_logic_vector(DATA_WIDTH-1 downto 0);
  type memo is array(0 to (memo_size-1)) of word_t;
  signal RAM : memo := (others => (others => '0'));

  -- DEBUG
  type memo_aux is array(0 to (memo_size-1)) of std_logic;
  signal RAM_aux : memo_aux := (others => '0');
  --

  signal address_A_int : integer := 0;
  signal address_B_int : integer := 0;

  attribute ram_style : string;
  attribute ram_style of ram: signal is "block";

begin
  --DEBUG
  ram_test: for i in 0 to memo_size-1 generate
    RAM_aux(i) <= RAM(i)(0);
  end generate;
  --


  address_A_int <= to_integer(unsigned(address_A));
  address_B_int <= to_integer(unsigned(address_B));

  process(clock)
  begin
    if rising_edge(clock) then
      if write_enable = '1' then
        RAM( address_A_int ) <= data_A;
      end if;
        data_B <= RAM( address_B_int );
    end if;
  end process;
  -- Read Asincrónico (DRAM)
  --       data_B <= RAM( address_B_int );

end dual_port_ram_arch;
-------------------------------------------------------------------------------
