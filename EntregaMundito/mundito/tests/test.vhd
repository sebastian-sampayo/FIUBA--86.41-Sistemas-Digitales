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
-- Test de la Video RAM
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
-------------------------------------------------------------------------------

entity testbench is
end entity testbench;
-------------------------------------------------------------------------------

architecture testbench_arch of testbench is
  component video_ram is
    generic(
      N_bits_row : integer := 10;
      N_bits_col : integer := 10;
      N_rows : integer := 480;
      N_cols : integer := 640
    );
    port(
      clock: in std_logic;
      reset : in std_logic;
      A_row : in std_logic_vector(N_bits_row-1 downto 0);
      B_row : in std_logic_vector(N_bits_row-1 downto 0);
      A_col : in std_logic_vector(N_bits_col-1 downto 0);
      B_col : in std_logic_vector(N_bits_col-1 downto 0);
      data_A : in std_logic;
      data_B : out std_logic
    );
  end component video_ram;

-- Señales
   signal A_row : std_logic_vector(10-1 downto 0) := (others => '0');
   signal B_row : std_logic_vector(10-1 downto 0) := (others => '0');
   signal A_col : std_logic_vector(10-1 downto 0) := (others => '0');
   signal B_col : std_logic_vector(10-1 downto 0) := (others => '0');
   signal data_A : std_logic := '0';
   signal data_B : std_logic := '0';

   signal clock : std_logic := '0';
   signal reset : std_logic := '0';
   signal row_counter : unsigned(9 downto 0) := (others => '0');
   signal col_counter : unsigned(9 downto 0) := (others => '0');
   signal next_row_enable : std_logic := '0';
   signal write_enable : std_logic := '1';
begin

  clock <= not clock after 5 ns;
  --reset <= '0', '1' after 12 ns, '0' after 20 ns;
  write_enable <= '1', '0' after 100 ns;

  -- Contador de columnas
  process(clock)
  begin
    if rising_edge(clock) then
      if write_enable = '1' then
        if col_counter = 3 then
          col_counter <= (others => '0');
          next_row_enable <= '1';
        else
          col_counter <= col_counter + 1;
          next_row_enable <= '0';
        end if;
      end if;
    end if;
  end process;

  -- Contador de filas
  process(clock)
  begin
    if rising_edge(clock) then
      if write_enable = '1' then
        if next_row_enable = '1' then
          if row_counter = 3 then
            row_counter <= (others => '0');
            --count_enable <= '0';
          else
            row_counter <= row_counter + 1;
          end if;
        end if;
      end if;
    end if;
  end process;

  -- Dibujo (escribo la ram)
  process(row_counter, col_counter)
  begin
    if (row_counter < col_counter) then
      data_A <= '1';
    else
      data_A <= '0';
    end if;
  end process;

  A_row <= std_logic_vector(row_counter);
  A_col <= std_logic_vector(col_counter);

 -- data_A <= '1', '0' after 10 ns, '1' after 20 ns; 
 -- A_row <= (9 downto 2 => '0') & "01",
 --          (9 downto 2 => '0') & "10" after 10 ns,
 --          (9 downto 2 => '0') & "11" after 20 ns;

 B_col <= (9 downto 2 => '0') & "01" after 125 ns,
          (9 downto 2 => '0') & "10" after 130 ns,
          (9 downto 2 => '0') & "11" after 135 ns,
          (9 downto 2 => '1') & "10" after 150 ns;

  DUT : video_ram
    port map(
      clock => clock,
      reset => reset, 
      A_row => A_row,
      B_row  => B_row  , 
      A_col  => A_col  , 
      B_col  => B_col  , 
      data_A => data_A , 
      data_B => data_B  
    );

end testbench_arch;
-------------------------------------------------------------------------------
