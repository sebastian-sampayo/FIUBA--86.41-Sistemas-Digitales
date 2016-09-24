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
-- Rotador XYZ
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

use work.cordic_pkg.all;
library componenteslib;
use componenteslib.my_components.all;
-------------------------------------------------------------------------------

entity xyz_rotator is
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
end entity xyz_rotator;
-------------------------------------------------------------------------------

architecture xyz_rotator_arch of xyz_rotator is
  
  signal zrot_load : std_logic := '0';
  signal zrot_RxRdy : std_logic := '0';
  signal zrot_angle: std_logic_vector(Nangle-1 downto 0) := (others => '0');
  signal zrot_x0: std_logic_vector(Nxy-1 downto 0) := (others => '0');
  signal zrot_y0: std_logic_vector(Nxy-1 downto 0) := (others => '0');
  signal zrot_x1: std_logic_vector(Nxy-1 downto 0) := (others => '0');
  signal zrot_y1: std_logic_vector(Nxy-1 downto 0) := (others => '0');

  signal yrot_load : std_logic := '0';
  signal yrot_RxRdy : std_logic := '0';
  signal yrot_angle: std_logic_vector(Nangle-1 downto 0) := (others => '0');
  signal yrot_x0: std_logic_vector(Nxy-1 downto 0) := (others => '0');
  signal yrot_y0: std_logic_vector(Nxy-1 downto 0) := (others => '0');
  signal yrot_x1: std_logic_vector(Nxy-1 downto 0) := (others => '0');
  signal yrot_x1_delay: std_logic_vector(Nxy-1 downto 0) := (others => '0');
  signal yrot_y1: std_logic_vector(Nxy-1 downto 0) := (others => '0');

  signal xrot_load : std_logic := '0';
  signal xrot_RxRdy : std_logic := '0';
  signal xrot_angle: std_logic_vector(Nangle-1 downto 0) := (others => '0');
  signal xrot_x0: std_logic_vector(Nxy-1 downto 0) := (others => '0');
  signal xrot_y0: std_logic_vector(Nxy-1 downto 0) := (others => '0');
  signal xrot_x1: std_logic_vector(Nxy-1 downto 0) := (others => '0');
  signal xrot_x1_delay: std_logic_vector(Nxy-1 downto 0) := (others => '0');
  signal xrot_y1: std_logic_vector(Nxy-1 downto 0) := (others => '0');

  signal out_reg_in : std_logic_vector(1+3*Nxy-1 downto 0) := (others => '0');
  signal out_reg_out : std_logic_vector(1+3*Nxy-1 downto 0) := (others => '0');
  signal in_reg_in : std_logic_vector(1+3*Nxy+3*Nangle-1 downto 0) := (others => '0');
  signal in_reg_out : std_logic_vector(1+3*Nxy+3*Nangle-1 downto 0) := (others => '0');

  signal load_delay : std_logic := '0';
  signal x0_delay: std_logic_vector(Nxy-1 downto 0) := (others => '0');
  signal x0_delay_delay: std_logic_vector(Nxy-1 downto 0) := (others => '0');
  signal y0_delay: std_logic_vector(Nxy-1 downto 0) := (others => '0');
  signal z0_delay: std_logic_vector(Nxy-1 downto 0) := (others => '0');
  signal alpha_delay : std_logic_vector(Nangle-1 downto 0) := (others => '0');
  signal beta_delay : std_logic_vector(Nangle-1 downto 0) := (others => '0');
  signal gamma_delay : std_logic_vector(Nangle-1 downto 0) := (others => '0');

begin

  -- 1a versión: Solo rota en Z
  -- zrot_load <= load;
  -- -- RxRdy <= zrot_RxRdy;
  -- zrot_gamma <= gamma;
  -- zrot_x0 <= x0;
  -- zrot_y0 <= y0;
  -- -- x1 <= zrot_x1;
  -- -- y1 <= zrot_y1;
  --

  -------------------------------------
  -- Registro de salida --
  -------------------------------------
  in_reg_in <= load & x0 & y0 & z0 & alpha & beta & gamma;
  pipe_reg_in: register_N
    generic map(
      N => 1 + 3*Nxy + 3*Nangle
    )
    port map(
      clock => clock,
      reset => reset,
      enable => '1',
      D => in_reg_in,
      Q => in_reg_out
    );

  load_delay <= in_reg_out(1+3*Nxy+3*Nangle-1);
  x0_delay <= in_reg_out(1+3*Nxy+3*Nangle-1 -1 downto 1+3*Nxy+3*Nangle-1 -Nxy);
  y0_delay <= in_reg_out(1+3*Nxy+3*Nangle-1 -Nxy-1 downto 1+3*Nxy+3*Nangle-1 -2*Nxy);
  z0_delay <= in_reg_out(1+3*Nxy+3*Nangle-1 -2*Nxy-1 downto 1+3*Nxy+3*Nangle-1 -3*Nxy);
  alpha_delay <= in_reg_out(1+3*Nxy+3*Nangle-1 -3*Nxy -1 downto 1+3*Nxy+3*Nangle-1 -3*Nxy -Nangle);
  beta_delay <= in_reg_out(1+3*Nxy+3*Nangle-1 -3*Nxy -Nangle-1 downto 1+3*Nxy+3*Nangle-1 -3*Nxy -2*Nangle);
  gamma_delay <= in_reg_out(1+3*Nxy+3*Nangle-1 -3*Nxy -2*Nangle-1 downto 1+3*Nxy+3*Nangle-1 -3*Nxy -3*Nangle);

  -------------------------------------
  -- Rotador según eje X
  -------------------------------------
  xrot_load <= load_delay;
  xrot_x0 <= y0_delay;
  xrot_y0 <= z0_delay;
  xrot_angle <= alpha_delay;

  X_rot: cordic
    generic map(
      Nxy => Nxy,
      Nangle => Nangle,
      Nits => Nits
    )
    port map(
      clock => clock,
      reset => reset,
      load => xrot_load,
      angle => xrot_angle,
      x0 => xrot_x0,
      y0 => xrot_y0,
      x1 => xrot_x1,
      y1 => xrot_y1,
      RxRdy => xrot_RxRdy
    );

  -------------------------------------
  -- Delay para x
  -------------------------------------
  X_del: delay_reg
    generic map(
      N => Nxy,
      DELAY => Nits +1
    )
    port map(
     clock => clock,
     reset => reset,
     enable => '1',
     A => x0_delay,
     B => x0_delay_delay
   );

  -------------------------------------
  -- Rotador según eje Y 
  -------------------------------------
  yrot_load <= xrot_RxRdy;
  yrot_x0 <= xrot_y1;
  yrot_y0 <= x0_delay_delay;
  yrot_angle <= beta_delay;

  Y_rot: cordic
    generic map(
      Nxy => Nxy,
      Nangle => Nangle,
      Nits => Nits
    )
    port map(
      clock => clock,
      reset => reset,
      load => yrot_load,
      angle => yrot_angle,
      x0 => yrot_x0,
      y0 => yrot_y0,
      x1 => yrot_x1,
      y1 => yrot_y1,
      RxRdy => yrot_RxRdy
    );

  -------------------------------------
  -- Delay para y
  -------------------------------------
  Y_del: delay_reg
    generic map(
      N => Nxy,
      DELAY => Nits +1
    )
    port map(
     clock => clock,
     reset => reset,
     enable => '1',
     A => xrot_x1,
     B => xrot_x1_delay
   );

  -------------------------------------
  -- Rotador según eje Z (plano XY)
  -------------------------------------
  zrot_load <= yrot_RxRdy;
  zrot_x0 <= yrot_y1;
  zrot_y0 <= xrot_x1_delay;
  zrot_angle <= gamma_delay;

  Z_rot: cordic
    generic map(
      Nxy => Nxy,
      Nangle => Nangle,
      Nits => Nits
    )
    port map(
      clock => clock,
      reset => reset,
      load => zrot_load,
      angle => zrot_angle,
      x0 => zrot_x0,
      y0 => zrot_y0,
      x1 => zrot_x1,
      y1 => zrot_y1,
      RxRdy => zrot_RxRdy
    );

  -------------------------------------
  -- Delay para Z
  -------------------------------------
  Z_del: delay_reg
    generic map(
      N => Nxy,
      DELAY => Nits +1
    )
    port map(
     clock => clock,
     reset => reset,
     enable => '1',
     A => yrot_x1,
     B => yrot_x1_delay
   );

  -------------------------------------
  -- Registro de salida --
  -------------------------------------
  out_reg_in <= zrot_RxRdy & zrot_x1 & zrot_y1 & yrot_x1_delay;
  pipe_reg_out: register_N
    generic map(
      N => 1 + 3*Nxy
    )
    port map(
      clock => clock,
      reset => reset,
      enable => '1',
      D => out_reg_in,
      Q => out_reg_out
    );

    RxRdy <= out_reg_out(1+3*Nxy-1);
    x1 <= out_reg_out(1+3*Nxy-1-1 downto 1+3*Nxy-1-Nxy);
    y1 <= out_reg_out(1+3*Nxy-1-Nxy-1 downto 1+3*Nxy-1-2*Nxy);
    z1 <= out_reg_out(1+3*Nxy-1-2*Nxy-1 downto 0);


end xyz_rotator_arch;
-------------------------------------------------------------------------------
