-------------------------------------------------------------------------------
--  Facultad de Ingeniería de la Universidad de Buenos Aires
--  Sistemas Digitales
--  2° Cuatrimestre de 2015
-- 
--  Sampayo, Sebastián Lucas
--  Padrón: 93793
--  e-mail: sebisampayo@gmail.com
-------------------------------------------------------------------------------
-- Paquete de componentes específicos para el TP de Cordic
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
-------------------------------------------------------------------------------
package cordic_pkg is

  component extRam_loader is
    port(
      clock: in std_logic;
      reset: in std_logic;
      data_in: in std_logic_vector(7 downto 0);
      data_out: out std_logic_vector(15 downto 0);
      RxRdy_in: in std_logic;
      RxRdy_out: out std_logic
    );
  end component extRam_loader;
  ----

  component xyz_loader is
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
  end component xyz_loader;
  ----

  component global_ctrl is
    generic(
      Nangle : natural := 16
    );
    port(
      clock: in std_logic;
      write_reset_in: in std_logic;
      read_reset_in: in std_logic;
      sw_x_pos: in std_logic;
      sw_x_neg: in std_logic;
      sw_y_pos: in std_logic;
      sw_y_neg: in std_logic;
      sw_z_pos: in std_logic;
      sw_z_neg: in std_logic;
      delta_angle: in std_logic_vector(Nangle-1 downto 0);
      alpha: out std_logic_vector(Nangle-1 downto 0);
      beta: out std_logic_vector(Nangle-1 downto 0);
      gamma: out std_logic_vector(Nangle-1 downto 0);
      clear_reset: out std_logic;
      clear_enable: out std_logic;
      clear_stop: in std_logic;
      read_start: out std_logic;
      read_stop: in std_logic;
      read_reset_out: out std_logic;
      write_reset_out: out std_logic;
      vga_start: in std_logic;
      vga_stop: in std_logic
    );
  end component global_ctrl;
  ----

  component cordic is
    generic(
      Nxy : natural := 16;
      Nangle : natural := 16;
      Nits : natural := 16
      -- angle : real := 0.703125
    );
    port(
      clock: in std_logic;
      reset: in std_logic;
      load: in std_logic;
      angle : in std_logic_vector(Nangle-1 downto 0);
      x0 : in std_logic_vector(Nxy-1 downto 0);
      y0 : in std_logic_vector(Nxy-1 downto 0);
      x1 : out std_logic_vector(Nxy-1 downto 0);
      y1 : out std_logic_vector(Nxy-1 downto 0);
      RxRdy : out std_logic
    );
  end component cordic;
  ----

  component xyz_rotator is
    generic(
      Nxy : natural := 16;
      Nangle : natural := 16;
      Nits : natural := 16
    );
    port(
      clock: in std_logic;
      reset: in std_logic;
      load: in std_logic;
      RxRdy: out std_logic;
      alpha: in std_logic_vector(Nangle-1 downto 0);
      beta: in std_logic_vector(Nangle-1 downto 0);
      gamma: in std_logic_vector(Nangle-1 downto 0);
      x0: in std_logic_vector(Nxy-1 downto 0);
      y0: in std_logic_vector(Nxy-1 downto 0);
      z0: in std_logic_vector(Nxy-1 downto 0);
      x1: out std_logic_vector(Nxy-1 downto 0);
      y1: out std_logic_vector(Nxy-1 downto 0);
      z1: out std_logic_vector(Nxy-1 downto 0)
    );
  end component xyz_rotator;
  ----

end cordic_pkg;
-------------------------------------------------------------------------------
-- package body cordic_pkg is
-- 
-- end package body cordic_pkg;
-------------------------------------------------------------------------------
