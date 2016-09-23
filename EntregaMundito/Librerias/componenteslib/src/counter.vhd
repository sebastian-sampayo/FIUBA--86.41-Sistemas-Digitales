-------------------------------------------------------------------------------
--  Facultad de Ingeniería de la Universidad de Buenos Aires
--  Sistemas Digitales
--  2° Cuatrimestre de 2015
-- 
--  Sampayo, Sebastián Lucas
--  Padrón: 93793
--  e-mail: sebisampayo@gmail.com
-------------------------------------------------------------------------------
-- Contador de N bits
-------------------------------------------------------------------------------
-- 
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
--use work.my_components.all;
-------------------------------------------------------------------------------

entity counter is
  generic(
    N_bits : natural := 2;
    MAX_COUNT : natural := 2
  );
	port(
    clock: in std_logic;
    reset: in std_logic;
    enable: in std_logic;
    counter_output: out std_logic_vector(N_bits-1 downto 0);
    carry_out: out std_logic
	);
end entity counter;
-------------------------------------------------------------------------------

architecture counter_arch of counter is

  -- Comportamiento
  signal counter_aux : unsigned(N_bits-1 downto 0) := (others => '0');
  -- Estructural
  --signal aux : std_logic_vector(N_bits-1 downto 0) := (others => '0');

begin

  
  -- Comportamiento
  counter_output <= std_logic_vector(counter_aux);
  process(clock, enable, reset)
  begin
    -- RESET
    if reset = '1' then
      counter_aux <= (others => '0');
      carry_out <= '0';
    -- Flanco ascendente de CLOCK
    elsif rising_edge(clock) then
      -- ENABLE
      if enable = '1' then
        if counter_aux = MAX_COUNT then
          counter_aux <= (others => '0');
          -- CARRY
          carry_out <= '1';
        else
          counter_aux <= counter_aux + 1;
          carry_out <= '0';
        end if;
      end if;
    end if;
  end process;


  -- Estructural:
  -- counter_output <= aux;
  -- aux(0) <= clock ;
  -- delay: for i in 1 to N_bits-1 generate
  --   ffd_delay: ffd
  --     port map(
  --       D => aux(i-1),
  --       Q => aux(i),
  --       clk => clock,
  --       rst => reset,
  --       enable => enable
  --     );
  -- end generate;

end counter_arch;
-------------------------------------------------------------------------------
