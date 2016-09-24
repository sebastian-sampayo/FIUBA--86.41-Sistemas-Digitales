-------------------------------------------------------------------------------
--  Facultad de Ingeniería de la Universidad de Buenos Aires
--  Sistemas Digitales
--  2° Cuatrimestre de 2015
-- 
--  Sampayo, Sebastián Lucas
--  Padrón: 93793
--  e-mail: sebisampayo@gmail.com
-------------------------------------------------------------------------------
-- extRam Loader
-------------------------------------------------------------------------------
-- Carga la memoria RAM externa con los datos de la UART. (Toma LSB y MSB de la uart)
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
-------------------------------------------------------------------------------

entity extRam_loader is
	port(
    clock: in std_logic;
    reset: in std_logic;
    data_in: in std_logic_vector(7 downto 0);
    data_out: out std_logic_vector(15 downto 0);
    RxRdy_in: in std_logic;
    RxRdy_out: out std_logic
	);
end entity extRam_loader;
-------------------------------------------------------------------------------

architecture extRam_loader_arch of extRam_loader is

  type state_t is (LSB, MSB);
  signal state : state_t := LSB;

begin

  FSM: process(clock, reset)
  begin
    -- RESET
    if reset = '1' then
      data_out <= (others => '0');
      state <= LSB;
      RxRdy_out <= '0';
    elsif rising_edge(clock) then
      RxRdy_out <= '0';
      case state is
        -- LSByte
        when LSB =>
          if RxRdy_in = '1' then
            data_out(7 downto 0) <= data_in;
            RxRdy_out <= '0';
            state <= MSB;
          end if;
        -- MSByte
        when MSB =>
          if RxRdy_in = '1' then
            data_out(15 downto 8) <= data_in;
            RxRdy_out <= '1';
            state <= LSB;
          end if;
      end case;
    end if;
  end process;

end extRam_loader_arch;
-------------------------------------------------------------------------------
