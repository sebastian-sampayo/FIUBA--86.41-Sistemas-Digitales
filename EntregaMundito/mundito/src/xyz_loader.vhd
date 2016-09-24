-------------------------------------------------------------------------------
--  Facultad de Ingeniería de la Universidad de Buenos Aires
--  Sistemas Digitales
--  2° Cuatrimestre de 2015
-- 
--  Sampayo, Sebastián Lucas
--  Padrón: 93793
--  e-mail: sebisampayo@gmail.com
-- 
--  TP Cordic
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- XYZ Loader
-------------------------------------------------------------------------------
-- Lee de la RAM externa y carga los puntos X, Y, Z.
-- Reset, Start, RxRdy_out
-- Con start empieza a leer y se mantiene en un bucle infinito X->Y->Z->X->...
--  hasta que un reset lo detenga.
-- Al recibir el RxRdy_ram cambia de estado y lee un nuevo dato
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
-------------------------------------------------------------------------------

entity xyz_loader is
	port(
    clock: in std_logic;
    reset: in std_logic;
    enable: in std_logic;
    start: in std_logic;
    data_in: in std_logic_vector(15 downto 0);
    go_ram: out std_logic;
    RxRdy_ram: in std_logic;
    busy_ram: in std_logic;
    RxRdy_out: out std_logic;
    x: out std_logic_vector(15 downto 0);
    y: out std_logic_vector(15 downto 0);
    z: out std_logic_vector(15 downto 0)
	);
end entity xyz_loader;
-------------------------------------------------------------------------------

architecture xyz_loader_arch of xyz_loader is

  type state_t is (IDLE, X_st, Y_st, Z_st);
  signal state: state_t := IDLE;

begin

  FSM: process(clock, reset, start, RxRdy_ram, busy_ram)
  begin
    -- RESET
    if reset = '1' then
      -- x <= (others => '0');
      -- y <= (others => '0');
      -- z <= (others => '0');
      -- RxRdy_out <= '0';
      go_ram <= '0';
      state <= IDLE;

    elsif rising_edge(clock) then
      -- defaults
      RxRdy_out <= '0';
      go_ram <= '0';

      if enable = '1' then
        case state is
          -- IDLE
          when IDLE =>
            if start = '1' and busy_ram = '0' then
              -- Pido un dato (X)
              go_ram <= '1';
              state <= X_st;
            end if;

          -- X
          when X_st =>
            if RxRdy_ram = '1' then
              -- Recibí X, pido Y
              x <= data_in;
              go_ram <= '1';
              state <= Y_st;
            end if;

          -- Y
          when Y_st =>
            if RxRdy_ram = '1' then
              -- Recibí Y, pido Z
              y <= data_in;
              go_ram <= '1';
              state <= Z_st;
            end if;

          -- Z
          when Z_st =>
            if RxRdy_ram = '1' then
              -- Recibí Z, vuelvo a IDLE
              RxRdy_out <= '1';
              z <= data_in;
              go_ram <= '1';
              state <= X_st;
            end if;

        end case;
      end if;
    end if;
  end process;

end xyz_loader_arch;
-------------------------------------------------------------------------------
