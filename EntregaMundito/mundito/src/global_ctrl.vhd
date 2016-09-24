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
-- Módulo de control global. 
-------------------------------------------------------------------------------
-- Botones de entrada, resets, clears, y ángulos de salida

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
-------------------------------------------------------------------------------

entity global_ctrl is
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
end entity global_ctrl;
-------------------------------------------------------------------------------

architecture global_ctrl_arch of global_ctrl is

  type state_t is (IDLE, CLEARING, READING, REFRESHING);
  signal state : state_t := IDLE;

  signal ctrl_alpha : std_logic_vector(1 downto 0) := (others => '0');
  signal ctrl_beta : std_logic_vector(1 downto 0) := (others => '0');
  signal ctrl_gamma : std_logic_vector(1 downto 0) := (others => '0');
  
  signal alpha_aux: std_logic_vector(Nangle-1 downto 0) := (others => '0');
  signal beta_aux: std_logic_vector(Nangle-1 downto 0) := (others => '0');
  signal gamma_aux: std_logic_vector(Nangle-1 downto 0) := (others => '0');

  signal delta_alpha: std_logic_vector(Nangle-1 downto 0) := (others => '0');
  signal delta_beta: std_logic_vector(Nangle-1 downto 0) := (others => '0');
  signal delta_gamma: std_logic_vector(Nangle-1 downto 0) := (others => '0');

  signal minus_delta_angle: std_logic_vector(Nangle-1 downto 0) := (others => '0');

  type substate_t is (WAITING, REFRESHING);
  signal refresh_substate : substate_t := WAITING;

  signal button_down : std_logic := '0';

begin

  button_down <= ( (sw_x_pos XOR sw_x_neg) OR (sw_y_pos XOR sw_y_neg) OR (sw_z_pos XOR sw_z_neg)
                  OR write_reset_in OR read_reset_in );

  clear_enable <= '1' when (state = CLEARING) else '0';
  read_reset_out <= '1' when (state = CLEARING) else '0';
  read_start <= '1' when (state = READING) else '0';
  write_reset_out <= write_reset_in;

  -- FSM: process(clock, write_reset_in, read_reset_in, sw_x_pos, sw_x_neg,
  --              sw_y_pos, sw_y_neg, sw_z_pos, sw_z_neg)
  FSM: process(clock, button_down)
  begin
    if rising_edge(clock) then

      case state is
        -- IDLE
        when IDLE =>
          refresh_substate <= WAITING;
          -- Si algún botón es presionado
          if button_down = '1' then
            state <= CLEARING;
            clear_reset <= '0';
          end if;

        -- Borro la memoria de video
        when CLEARING =>
          if clear_stop = '1' then
            clear_reset <= '1';
            state <= READING;
          end if;

        -- Leo los nuevos datos
        when READING =>
          clear_reset <= '0';
          if read_stop = '1' then
            state <= REFRESHING;
          end if;

        -- OJO que el vga_carry dura 2 ciclos
        -- 2da versión. Usar vga_start, vga_stop
        -- Espero a que refresque la pantalla con los nuevos datos leídos
        when REFRESHING =>
          clear_reset <= '0';
          case refresh_substate is
            when WAITING =>
              if vga_start = '1' then
                refresh_substate <= REFRESHING;
              -- else
              --   refresh_substate <= WAITING;;
              end if;

            when REFRESHING => 
              if vga_stop = '1' then
                state <= IDLE;
                refresh_substate <= WAITING;
              -- else
              --   refresh_substate <= REFRESHING;
              end if;
          end case;
          
      end case;
    end if;
  end process;

  -- Angulos
  -- Ctrl +/- (selector del mux)
  ctrl_alpha <= sw_x_pos & sw_x_neg;
  ctrl_beta <= sw_y_pos & sw_y_neg;
  ctrl_gamma <= sw_z_pos & sw_z_neg;

  -- Menos delta (-delta)
  minus_delta_angle <= std_logic_vector(unsigned(not delta_angle) + 1);

  -- Mux
  delta_alpha <= delta_angle when ctrl_alpha = "10" else
                 minus_delta_angle when ctrl_alpha = "01" else
                 (others => '0');

  delta_beta <= delta_angle when ctrl_beta = "10" else
                 minus_delta_angle when ctrl_beta = "01" else
                 (others => '0');

  delta_gamma <= delta_angle when ctrl_gamma = "10" else
                 minus_delta_angle when ctrl_gamma = "01" else
                 (others => '0');

  alpha <= alpha_aux;
  beta <= beta_aux;
  gamma <= gamma_aux;

  -- Acumulador de ángulos
  process(clock, state)
  begin
    if rising_edge(clock) then
      if state = IDLE then
        alpha_aux <= std_logic_vector( unsigned(alpha_aux) + unsigned(delta_alpha) );
        beta_aux <= std_logic_vector( unsigned(beta_aux) + unsigned(delta_beta) );
        gamma_aux <= std_logic_vector( unsigned(gamma_aux) + unsigned(delta_gamma) );
      end if;
    end if;
  end process;



end global_ctrl_arch;
-------------------------------------------------------------------------------
