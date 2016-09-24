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
-- Algoritmo CORDIC
-------------------------------------------------------------------------------
-- Versión iterativa.
-- load carga las entradas x0, y0, angle. Debe mantenerse en alto en el primer
--  flanco ascendente del clock.
-- RxRdy se activa cuando la salida x1, y1 es válida.
--
-- Versión angle:real
-- El ángulo "angle", debe ser un número real en grados, ej: 32.4°
-- 
-- Versión angle:std_logic_vector
-- El ángulo "angle", debe ser un std_logic_vector(Nangle-1 downto 0)
--  resultado de hacer: std_logic_vector(round( angle_rad * 2**(Nangle) / 2pi ))
--  donde angle_rad es el ángulo en radianes, entre (0, 2pi)
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.MATH_REAL.all;

library componenteslib;
use componenteslib.my_components.all;
-------------------------------------------------------------------------------

entity cordic is
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
end entity cordic;
-------------------------------------------------------------------------------

architecture cordic_arch of cordic is

  -- Usar MATH_PI de la librería ieee.MATH_REAL
  -- signal angle_rad : real := (angle * real(MATH_PI)) / real(180);
  -- signal angle_int : integer := integer(round( angle_rad * real(2**(Nangle-1)) ));
  --                                              -- / real(MATH_PI) ));
  -- signal angle_std : std_logic_vector(Nangle-1 downto 0) := 
  --         std_logic_vector( to_signed( angle_int, Nangle ));

  -- atan(1/2^-i), i=0:31
  -- fprintf("%.30f\n", x)

  -- constant Nxy2 : natural := Nxy ;
  -- INTERNAMENTE UTILIZO Nxy + Np bits de precisión
  constant Np : natural := 2;
  constant Nxy2 : natural := Nxy + Np;

  constant Nrom : natural := 32;
  type ROM_t is array(natural range <>) of std_logic_vector(Nangle-1 downto 0);
  constant ROM_ATAN : ROM_t(0 to Nrom-1) := (
    std_logic_vector(to_unsigned(integer(round(0.785398163397448278999490867136 * real(2**(Nangle-0)) / (2.0*MATH_PI) )), Nangle)),
    std_logic_vector(to_unsigned(integer(round(0.463647609000806093515478778500 * real(2**(Nangle-0)) / (2.0*MATH_PI) )), Nangle)),
    std_logic_vector(to_unsigned(integer(round(0.244978663126864143473326862477 * real(2**(Nangle-0)) / (2.0*MATH_PI) )), Nangle)),
    std_logic_vector(to_unsigned(integer(round(0.124354994546761438156678991618 * real(2**(Nangle-0)) / (2.0*MATH_PI) )), Nangle)),
    std_logic_vector(to_unsigned(integer(round(0.062418809995957350023054743815 * real(2**(Nangle-0)) / (2.0*MATH_PI) )), Nangle)),
    std_logic_vector(to_unsigned(integer(round(0.031239833430268277442154456480 * real(2**(Nangle-0)) / (2.0*MATH_PI) )), Nangle)),
    std_logic_vector(to_unsigned(integer(round(0.015623728620476831294161534913 * real(2**(Nangle-0)) / (2.0*MATH_PI) )), Nangle)),
    std_logic_vector(to_unsigned(integer(round(0.007812341060101111143987306917 * real(2**(Nangle-0)) / (2.0*MATH_PI) )), Nangle)),
    std_logic_vector(to_unsigned(integer(round(0.003906230131966971757390139075 * real(2**(Nangle-0)) / (2.0*MATH_PI) )), Nangle)),
    std_logic_vector(to_unsigned(integer(round(0.001953122516478818758434155001 * real(2**(Nangle-0)) / (2.0*MATH_PI) )), Nangle)),
    std_logic_vector(to_unsigned(integer(round(0.000976562189559319459436492750 * real(2**(Nangle-0)) / (2.0*MATH_PI) )), Nangle)),
    std_logic_vector(to_unsigned(integer(round(0.000488281211194898289926213941 * real(2**(Nangle-0)) / (2.0*MATH_PI) )), Nangle)),
    std_logic_vector(to_unsigned(integer(round(0.000244140620149361771244744812 * real(2**(Nangle-0)) / (2.0*MATH_PI) )), Nangle)),
    std_logic_vector(to_unsigned(integer(round(0.000122070311893670207853065945 * real(2**(Nangle-0)) / (2.0*MATH_PI) )), Nangle)),
    std_logic_vector(to_unsigned(integer(round(0.000061035156174208772593501454 * real(2**(Nangle-0)) / (2.0*MATH_PI) )), Nangle)),
    std_logic_vector(to_unsigned(integer(round(0.000030517578115526095727154735 * real(2**(Nangle-0)) / (2.0*MATH_PI) )), Nangle)),
    std_logic_vector(to_unsigned(integer(round(0.000015258789061315761542377868 * real(2**(Nangle-0)) / (2.0*MATH_PI) )), Nangle)),
    std_logic_vector(to_unsigned(integer(round(0.000007629394531101969981038997 * real(2**(Nangle-0)) / (2.0*MATH_PI) )), Nangle)),
    std_logic_vector(to_unsigned(integer(round(0.000003814697265606496141750756 * real(2**(Nangle-0)) / (2.0*MATH_PI) )), Nangle)),
    std_logic_vector(to_unsigned(integer(round(0.000001907348632810186964779285 * real(2**(Nangle-0)) / (2.0*MATH_PI) )), Nangle)),
    std_logic_vector(to_unsigned(integer(round(0.000000953674316405960844127631 * real(2**(Nangle-0)) / (2.0*MATH_PI) )), Nangle)),
    std_logic_vector(to_unsigned(integer(round(0.000000476837158203088842281064 * real(2**(Nangle-0)) / (2.0*MATH_PI) )), Nangle)),
    std_logic_vector(to_unsigned(integer(round(0.000000238418579101557973667688 * real(2**(Nangle-0)) / (2.0*MATH_PI) )), Nangle)),
    std_logic_vector(to_unsigned(integer(round(0.000000119209289550780680899739 * real(2**(Nangle-0)) / (2.0*MATH_PI) )), Nangle)),
    std_logic_vector(to_unsigned(integer(round(0.000000059604644775390552208106 * real(2**(Nangle-0)) / (2.0*MATH_PI) )), Nangle)),
    std_logic_vector(to_unsigned(integer(round(0.000000029802322387695302573833 * real(2**(Nangle-0)) / (2.0*MATH_PI) )), Nangle)),
    std_logic_vector(to_unsigned(integer(round(0.000000014901161193847654595639 * real(2**(Nangle-0)) / (2.0*MATH_PI) )), Nangle)),
    std_logic_vector(to_unsigned(integer(round(0.000000007450580596923828125000 * real(2**(Nangle-0)) / (2.0*MATH_PI) )), Nangle)),
    std_logic_vector(to_unsigned(integer(round(0.000000003725290298461914062500 * real(2**(Nangle-0)) / (2.0*MATH_PI) )), Nangle)),
    std_logic_vector(to_unsigned(integer(round(0.000000001862645149230957031250 * real(2**(Nangle-0)) / (2.0*MATH_PI) )), Nangle)),
    std_logic_vector(to_unsigned(integer(round(0.000000000931322574615478515625 * real(2**(Nangle-0)) / (2.0*MATH_PI) )), Nangle)),
    std_logic_vector(to_unsigned(integer(round(0.000000000465661287307739257812 * real(2**(Nangle-0)) / (2.0*MATH_PI) )), Nangle))
  );
  



  -- k = 1./sqrt(1 + 2.^(-2*i))
  constant Nk : natural := Nxy/2;
  -- constant Nk : natural := 8;
  type ROM_K_t is array(natural range <>) of std_logic_vector(Nk-1 downto 0);
  constant ROM_K : ROM_K_t(0 to Nrom-1) := (
    std_logic_vector(to_signed(integer(round( real(2**Nk) * 0.707106781186547461715008466854)), Nk)), 
    std_logic_vector(to_signed(integer(round( real(2**Nk) * 0.632455532033675771330649695301)), Nk)), 
    std_logic_vector(to_signed(integer(round( real(2**Nk) * 0.613571991077896283783843500714)), Nk)), 
    std_logic_vector(to_signed(integer(round( real(2**Nk) * 0.608833912517752429138795378094)), Nk)), 
    std_logic_vector(to_signed(integer(round( real(2**Nk) * 0.607648256256168139977091868786)), Nk)), 
    std_logic_vector(to_signed(integer(round( real(2**Nk) * 0.607351770141295932425862247328)), Nk)), 
    std_logic_vector(to_signed(integer(round( real(2**Nk) * 0.607277644093526025592666428565)), Nk)), 
    std_logic_vector(to_signed(integer(round( real(2**Nk) * 0.607259112298892733683430833480)), Nk)), 
    std_logic_vector(to_signed(integer(round( real(2**Nk) * 0.607254479332562269178197311703)), Nk)), 
    std_logic_vector(to_signed(integer(round( real(2**Nk) * 0.607253321089875175431416209904)), Nk)), 
    std_logic_vector(to_signed(integer(round( real(2**Nk) * 0.607253031529134346122589249717)), Nk)), 
    std_logic_vector(to_signed(integer(round( real(2**Nk) * 0.607252959138944836681162087189)), Nk)), 
    std_logic_vector(to_signed(integer(round( real(2**Nk) * 0.607252941041397154009473524638)), Nk)), 
    std_logic_vector(to_signed(integer(round( real(2**Nk) * 0.607252936517010177830400152743)), Nk)), 
    std_logic_vector(to_signed(integer(round( real(2**Nk) * 0.607252935385913406030056194140)), Nk)), 
    std_logic_vector(to_signed(integer(round( real(2**Nk) * 0.607252935103139268591121435747)), Nk)), 
    std_logic_vector(to_signed(integer(round( real(2**Nk) * 0.607252935032445706475812130520)), Nk)), 
    std_logic_vector(to_signed(integer(round( real(2**Nk) * 0.607252935014772288191409188585)), Nk)), 
    std_logic_vector(to_signed(integer(round( real(2**Nk) * 0.607252935010353933620308453101)), Nk)), 
    std_logic_vector(to_signed(integer(round( real(2**Nk) * 0.607252935009249372733108884859)), Nk)), 
    std_logic_vector(to_signed(integer(round( real(2**Nk) * 0.607252935008973260266884608427)), Nk)), 
    std_logic_vector(to_signed(integer(round( real(2**Nk) * 0.607252935008904204394752923690)), Nk)), 
    std_logic_vector(to_signed(integer(round( real(2**Nk) * 0.607252935008886884915568771248)), Nk)), 
    std_logic_vector(to_signed(integer(round( real(2**Nk) * 0.607252935008882666068075195653)), Nk)), 
    std_logic_vector(to_signed(integer(round( real(2**Nk) * 0.607252935008881555845050570497)), Nk)), 
    std_logic_vector(to_signed(integer(round( real(2**Nk) * 0.607252935008881222778143182950)), Nk)), 
    std_logic_vector(to_signed(integer(round( real(2**Nk) * 0.607252935008881222778143182950)), Nk)), 
    std_logic_vector(to_signed(integer(round( real(2**Nk) * 0.607252935008881222778143182950)), Nk)), 
    std_logic_vector(to_signed(integer(round( real(2**Nk) * 0.607252935008881222778143182950)), Nk)), 
    std_logic_vector(to_signed(integer(round( real(2**Nk) * 0.607252935008881222778143182950)), Nk)), 
    std_logic_vector(to_signed(integer(round( real(2**Nk) * 0.607252935008881222778143182950)), Nk)), 
    std_logic_vector(to_signed(integer(round( real(2**Nk) * 0.607252935008881222778143182950)), Nk))
  );




  -- constant K_real : real := 1.0/sqrt(1.0 + 1.0/real(2**(2*Nits)));
  -- constant K : integer := integer(K_real);
  
  signal d : std_logic := '0';
  signal not_d : std_logic := '1';

  signal x02 :std_logic_vector(Nxy2-1 downto 0) := (others => '0');
  signal y02 :std_logic_vector(Nxy2-1 downto 0) := (others => '0');
  signal x_in_reg :std_logic_vector(Nxy2-1 downto 0) := (others => '0');
  signal y_in_reg :std_logic_vector(Nxy2-1 downto 0) := (others => '0');
  signal z_in_reg :std_logic_vector(Nangle-1 downto 0) := (others => '0');
  signal x_out_reg :std_logic_vector(Nxy2-1 downto 0) := (others => '0');
  signal y_out_reg :std_logic_vector(Nxy2-1 downto 0) := (others => '0');
  signal z_out_reg :std_logic_vector(Nangle-1 downto 0) := (others => '0');
  signal x_adder_out :std_logic_vector(Nxy2-1 downto 0) := (others => '0');
  signal y_adder_out :std_logic_vector(Nxy2-1 downto 0) := (others => '0');
  signal z_adder_out :std_logic_vector(Nangle-1 downto 0) := (others => '0');
  signal x_adder_out_reg :std_logic_vector(Nxy2-1 downto 0) := (others => '0');
  signal y_adder_out_reg :std_logic_vector(Nxy2-1 downto 0) := (others => '0');
  signal x_out_reg_shift :std_logic_vector(Nxy2-1 downto 0) := (others => '0');
  signal y_out_reg_shift :std_logic_vector(Nxy2-1 downto 0) := (others => '0');

  subtype natural_i is natural range 0 to 31;
  signal i : natural_i := Nits;
  signal rom_atan_i : std_logic_vector(Nangle-1 downto 0) := (others => '0'); 
  signal enable_reg : std_logic := '0';

  signal x1_aux : std_logic_vector((Nxy2+Nk)-1 downto 0) := (others => '0');
  signal y1_aux : std_logic_vector((Nxy2+Nk)-1 downto 0) := (others => '0');
  signal x0_init : std_logic_vector(Nxy2-1 downto 0) := (others => '0');
  signal y0_init : std_logic_vector(Nxy2-1 downto 0) := (others => '0');
  signal minus_x0 : std_logic_vector(Nxy2-1 downto 0) := (others => '0');
  signal minus_y0 : std_logic_vector(Nxy2-1 downto 0) := (others => '0');
  signal angle_init : std_logic_vector(Nangle-1 downto 0) := (others => '0');
  
  signal RxRdy_reg_in : std_logic := '0';

  -- Indica el cuadrante en el que se encuentra el ángulo a rotar (angle)
  -- 00:  90 > angle >= 0
  -- 01: 180 > angle >= 90
  -- 10: 270 > angle >= 180
  -- 11: 360 > angle >= 270
  signal quadrant : std_logic_vector(1 downto 0) := "00";

  type state_t is (IDLE, LOADING, ROTATING, READY);
  signal state : state_t := IDLE;

  signal load_st_test : std_logic := '0';
  signal rotating_st : std_logic := '0';
  signal rom_i_test : std_logic_vector(Nk-1 downto 0);

begin
  load_st_test <= '1' when state = LOADING else '0';
  rotating_st <= '1' when state = ROTATING else '0';
  -- Versión con romK integer
  -- rom_i_test <= std_logic_vector(to_unsigned(ROM_K(i), Nxy2));
  -- Versión con romK vector
  rom_i_test <= ROM_K(i); 

  -- Contador de control. Setea RxRdy y i.
  counter_i: process(clock, reset, load)
  begin
    -- RESET
    if reset = '1' then
      i <= Nits;
      state <= IDLE;
      -- RxRdy <= '0';
      -- enable_reg <= '0';
    -- Carga asincrónica
    -- elsif load = '1' then
    --    i <= 0;
    --    state <= LOADING;
    --   -- RxRdy <= '0';
    --   enable_reg <= '1';
    elsif rising_edge(clock) then
      if load = '1' then
        state <= LOADING;
        i <= 0;
        -- RxRdy <= '0';
        -- enable_reg <= '1';
      -- Cuenta completa
      elsif i = Nits-2 then
        state <= READY;
        i <= i + 1;
        -- RxRdy <= '1';
        -- enable_reg <= '0';
      --   i <= i + 1;
      -- -- Cuento una más para poner en 0 RxRdy.
      -- elsif i = Nits-1 then
      --   -- i <= 0;
      --   RxRdy <= '0';
      --   enable_reg <= '0';
      -- Cuenta
      elsif i < Nits-2 then
        state <= ROTATING;
        i <= i + 1;
        -- RxRdy <= '0';
        -- enable_reg <= '1';
      else
        state <= IDLE;
      end if;
    end if;
  end process;

  enable_reg <= '1' when (state = LOADING) OR (state = ROTATING) OR (load = '1') else
                '0'; 

  -- RxRdy <= '1' when (state = READY) else '0';
  RxRdy_reg_in <= '1' when (state = READY) else '0';

  -------------
  -- Init
  -------------
  -- Cuadrante del ángluo
  -- angle pertenece a (0, 2pi) * 2^Nangle / 2pi = (0, 2^Nangle)
  -- Por lo tanto, los 2 bits más significativo me indican en que
  -- cuadrante del plano XY se encuentra el ángulo a rotar.
  quadrant <= angle(Nangle-1 downto Nangle-2);
  -------------

  -- Rotación inicial
  -- Seteo rotación "inicial" según el cuadrante en el que se encuentra el punto
  --  Esto se debe a que el CORDIC solo rota ángulos menores a 100°.
  --  Para resolverlo realizo una rotacón inicial de 90°, 180° o -90° según
  --  el cuadrante en el que se encuentre el ángulo a rotar (angle).
  x0_init <= x02 when quadrant = "00" else
             minus_y0 when quadrant = "01" else
             minus_x0 when quadrant = "10" else
             y02 when quadrant = "11";
  
  y0_init <= y02 when quadrant = "00" else
             x02 when quadrant = "01" else
             minus_y0 when quadrant = "10" else
             minus_x0 when quadrant = "11";

  minus_x0 <= std_logic_vector(signed(not x02) + 1);
  minus_y0 <= std_logic_vector(signed(not y02) + 1);
  -- x02 <= x0;
  -- y02 <= y0;

  -- Versión que usa 2 bits más de precisión
  -- x02 <= x0(Nxy-1) & x0(Nxy-1) & x0;
  -- y02 <= y0(Nxy-1) & y0(Nxy-1) & y0;

  -- Versión que usa Np bits más de precisión
  x02 <= (Np-1 downto 0 => x0(Nxy-1)) & x0;
  y02 <= (Np-1 downto 0 => y0(Nxy-1)) & y0;

  -------------

  -- Corrección del ángulo
  -- Restar 90, 180 o 270, es equivalente a poner en '0' los 2 bits más significativos.
  -- (ya que en cada caso es lo que corresponde... revisar cada cuadrante)
  angle_init <= "00" & angle(Nangle-3 downto 0);
  -- Para optimizar se puede usar un vector más corto (de Nangle-2) pero de cualquier
  -- modo, el ISE después seguro lo hace automáticamente.
  -------------

  -- Mux X
  x_in_reg <= x0_init when load = '1'
  --- x_in_reg <= x0_init when state = LOADING
              else x_adder_out;

  -- Mux Y
  y_in_reg <= y0_init when load = '1'
  -- y_in_reg <= y0_init when state = LOADING
              else y_adder_out;

  -- Registro X
  reg_x : register_N
    generic map(
      N => Nxy2
    )
    port map(
      clock => clock,
      reset => reset,
      enable => enable_reg,
      D => x_in_reg,
      Q => x_out_reg
    );

  -- Registro Y
  reg_y : register_N
    generic map(
      N => Nxy2
    )
    port map(
      clock => clock,
      reset => reset,
      enable => enable_reg,
      D => y_in_reg,
      Q => y_out_reg
    );

  -- Barrel Shifter X
  shifter_x: barrel_shifter
    generic map(
      N => Nxy2
    )
    port map(
      left => '0',
      M => i,
      x => x_out_reg,
      y => x_out_reg_shift
    );

  -- Barrel Shifter Y
  shifter_y: barrel_shifter
    generic map(
      N => Nxy2
    )
    port map(
      left => '0',
      M => i,
      x => y_out_reg,
      y => y_out_reg_shift
    );

  -- -- Sumador X
  -- x_adder: adder
  --   generic map(
  --     N => Nxy2
  --   )
  --   port map(
  --     A => x_out_reg,
  --     B => y_out_reg_shift,
  --     control => not_d,
  --     S => x_adder_out,
  --     Cout => open
  --   );

  -- -- Sumador Y
  -- y_adder: adder
  --   generic map(
  --     N => Nxy2
  --   )
  --   port map(
  --     A => y_out_reg,
  --     B => x_out_reg_shift,
  --     control => d,
  --     S => y_adder_out,
  --     Cout => open
  --   );

  -- Versión sin sumadores propios.
  x_adder_out <= std_logic_vector(unsigned(x_out_reg) + unsigned(y_out_reg_shift)) when not_d = '0' else
                 std_logic_vector(unsigned(x_out_reg) - unsigned(y_out_reg_shift)) ;
  y_adder_out <= std_logic_vector(unsigned(y_out_reg) + unsigned(x_out_reg_shift)) when d = '0' else
                 std_logic_vector(unsigned(y_out_reg) - unsigned(x_out_reg_shift)) ;

  -------------
  -- Z
  -- Mux Z
  z_in_reg <= angle_init when load = '1'
  -- z_in_reg <= angle_init when state = LOADING
              else z_adder_out;

  -- Registro Z
  reg_z : register_N
    generic map(
      N => Nangle
    )
    port map(
      clock => clock,
      reset => reset,
      enable => enable_reg,
      D => z_in_reg,
      Q => z_out_reg
    );

  rom_atan_i <= ROM_ATAN(i);
  -- -- Sumador Z
  -- z_adder: adder
  --   generic map(
  --     N => Nangle
  --   )
  --   port map(
  --     A => z_out_reg,
  --     B => rom_atan_i,
  --     control => not_d,
  --     S => z_adder_out,
  --     Cout => open
  --   );

  -- Versión sin sumadores propios
  z_adder_out <= std_logic_vector(unsigned(z_out_reg) + unsigned(rom_atan_i)) when not_d = '0' else
                 std_logic_vector(unsigned(z_out_reg) - unsigned(rom_atan_i)) ;
  ------------

  -- d
  -- d <= z_out_reg(Nangle-1);
  -- d <= z_out_reg(Nangle-1) when load = '0'
       -- else '0'; --angle(Nangle-1); --'0' when SIGN(angle) = 1.0
         -- else '1';
  d <= z_out_reg(Nangle-1) when (state = ROTATING) else '0';
  not_d <= not d;
  ------------

  -- Salida escalada
  -- -- x1_aux <= std_logic_vector(to_signed(to_integer(signed(x_adder_out)) * ROM_K(i), 2*Nxy2));
  -- -- y1_aux <= std_logic_vector(to_signed(to_integer(signed(y_adder_out)) * ROM_K(i), 2*Nxy2));
  -- x1_aux <= std_logic_vector( unsigned(x_adder_out) * ROM_K(i) );
  -- y1_aux <= std_logic_vector( unsigned(y_adder_out) * ROM_K(i) );

  -- Agrego registro de salida, de modo que el retardo combinacional de la multiplicación 
  -- no sea tan heavy
  pipe_reg_x: register_N
    generic map(
      N => Nxy2
    )
    port map(
      clock => clock,
      reset => reset,
      enable => '1',
      D => x_adder_out,
      Q => x_adder_out_reg
    );
  pipe_reg_y: register_N
    generic map(
      N => Nxy2
    )
    port map(
      clock => clock,
      reset => reset,
      enable => '1',
      D => y_adder_out,
      Q => y_adder_out_reg
    );

  delay_RxRdy: ffd
    port map(
      clk => clock,
      rst => reset,
      enable => '1',
      D => RxRdy_reg_in,
      Q => RxRdy
    );
      
  -- Versión ROM_K integer
  -- x1_aux <= std_logic_vector( unsigned(x_adder_out_reg) * ROM_K(i) );
  -- y1_aux <= std_logic_vector( unsigned(y_adder_out_reg) * ROM_K(i) );
  -- -- La constante K está multiplicada por 2**Nxy2 y almacenada en memoria como integer
  -- -- por lo tanto tengo que dividir el resultado por 2**Nxy2, lo que es lo mismo que desplazar
  -- -- en Nxy a derecha, lo que es igual a quedarse con los Nxy2 bits más significativos.
  -- -- Como el resultado debe ser de Nxy bits, saco los 2 más significativos.
  -- -- x1 <= x1_aux(2*Nxy2-1-2 downto Nxy2);
  -- -- y1 <= y1_aux(2*Nxy2-1-2 downto Nxy2);
  -- x1 <= x1_aux(2*Nxy2-1-4 downto Nxy);
  -- y1 <= y1_aux(2*Nxy2-1-4 downto Nxy);

  -- Versión ROM_K std_logic_vector
  -- x1_aux <= std_logic_vector( unsigned(x_adder_out_reg) * unsigned(ROM_K(i)) );
  -- y1_aux <= std_logic_vector( unsigned(y_adder_out_reg) * unsigned(ROM_K(i)) );
  -- Versión Signed
  x1_aux <= std_logic_vector( signed(x_adder_out_reg) * signed(ROM_K(i)) );
  y1_aux <= std_logic_vector( signed(y_adder_out_reg) * signed(ROM_K(i)) );

  -- x1 <= x1_aux((Nxy2+Nk)-1 downto (Nxy2+Nk)-1-Nxy+1);
  -- y1 <= y1_aux((Nxy2+Nk)-1 downto (Nxy2+Nk)-1-Nxy+1);

  -- Versión que utiliza 2 bits más de precisión
  -- x1 <= x1_aux((Nxy2+Nk)-1-2 downto (Nxy2+Nk)-1-2-Nxy+1);
  -- y1 <= y1_aux((Nxy2+Nk)-1-2 downto (Nxy2+Nk)-1-2-Nxy+1);

  -- Versión que utiliza Np bits más de precisión
  x1 <= x1_aux((Nxy2+Nk)-1-Np downto (Nxy2+Nk)-1-Np-Nxy+1);
  y1 <= y1_aux((Nxy2+Nk)-1-Np downto (Nxy2+Nk)-1-Np-Nxy+1);

end cordic_arch;
-------------------------------------------------------------------------------
