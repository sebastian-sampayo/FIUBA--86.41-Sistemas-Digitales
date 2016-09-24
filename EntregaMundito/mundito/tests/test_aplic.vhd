--  Universidad de Buenos Aires - Facultad de Ingenieria
--  66.17 - Sistemas Digitales
--  Pagina web de la materia: http://cactus.fi.uba.ar/6617/
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library componenteslib;
use componenteslib.my_components.all;
use work.cordic_pkg.all;

entity testbench is
end entity testbench;


architecture RTL of testbench is
  --------------------------------------------------------
  -- PUertos del board_top
    signal xtal_i           :  std_logic := '0';
    signal write_reset_in  : std_logic := '0';
    signal read_reset_in  : std_logic := '0';
    signal bypass_cordic : std_logic := '0';
    signal speed : std_logic_vector(1 downto 0);
    signal rot_switches_in : std_logic_vector(5 downto 0);
    signal leds_out :  std_logic_vector(7 downto 0) := (others => '0');
    -- VGA
    signal hsync : std_logic := '0';
    signal vsync : std_logic := '0';
		signal red_out :  std_logic_vector(2 downto 0) := (others => '0');
    signal grn_out :  std_logic_vector(2 downto 0) := (others => '0');
    signal blu_out :  std_logic_vector(1 downto 0) := (others => '0');
    ----------
    -- UART --
    ----------
    signal   rx_i        : std_logic := '0';
    -----------------------------------------------
    -- Signals from the controller to the memory --
    -----------------------------------------------
    signal   clock_out		:		STD_LOGIC := '0';
    signal   ADDRESS			:	STD_LOGIC_VECTOR (22 downto 0) := (others => '0');
    signal   ADV					:	STD_LOGIC := '0';
    signal   CRE					:	STD_LOGIC := '0';
    signal   CE					:	STD_LOGIC := '0';
    signal   OE					:	STD_LOGIC := '0';
    signal   WE					:	STD_LOGIC := '0';
    signal   LB					:	STD_LOGIC := '0';
    signal   UB					:	STD_LOGIC := '0';
    signal   DATA				:	STD_LOGIC_VECTOR (15 downto 0) := (others => '0');
  --------------------------------------------------------

  -- SENIALES UTILIZADAS:
  constant N_bits_row : natural := 4;
  constant N_bits_col : natural := N_bits_row;
  -- constant N_ROWS : natural := 2**N_bits_row;
  -- constant N_COLS : natural := 2**N_bits_col;
  constant N_ROWS : natural := 10;
  constant N_COLS : natural := 10;
  constant CENTER_ROW : natural := N_ROWS/2;
  constant CENTER_COL : natural := N_COLS/2;
  constant memo_size : integer := N_rows * N_cols;
  constant TOP_MARGIN : natural := 10;
  constant LEFT_MARGIN : natural := 10;
  constant Nangle : natural := 16;
  constant Nxy : natural := 16;
  constant Nits : natural := Nxy-2;
  constant N_ROWS_VEC : std_logic_vector(N_bits_row-1 downto 0) := std_logic_vector(to_unsigned(N_ROWS, N_bits_row));
  constant N_COLS_VEC : std_logic_vector(N_bits_col-1 downto 0) := std_logic_vector(to_unsigned(N_COLS, N_bits_col));
   signal clock : std_logic := '0';

  -- Video RAM
   signal A_row : std_logic_vector(N_bits_row-1 downto 0) := (others => '0');
   signal B_row : std_logic_vector(N_bits_row-1 downto 0) := (others => '0');
   signal A_col : std_logic_vector(N_bits_col-1 downto 0) := (others => '0');
   signal B_col : std_logic_vector(N_bits_col-1 downto 0) := (others => '0');
   signal A_row_aux : std_logic_vector(N_bits_row-1 downto 0) := (others => '0');
   signal A_col_aux : std_logic_vector(N_bits_col-1 downto 0) := (others => '0');
   signal data_A : std_logic := '0';
   signal data_B : std_logic := '0';
   signal video_write_enable : std_logic := '0';

  -- Clear video ram
   signal row_counter : std_logic_vector(N_bits_row-1 downto 0) := (others => '0');
   signal col_counter : std_logic_vector(N_bits_col-1 downto 0) := (others => '0');

  -- VGA
   signal pixel_row : std_logic_vector(10-1 downto 0) := (others => '0');
   signal pixel_col : std_logic_vector(10-1 downto 0) := (others => '0');
  signal enable_vga : std_logic := '0';
  signal enable_vga_delay : std_logic := '0';
  signal vga_pixel_in : std_logic := '0';
  signal vga_start : std_logic := '0';
  signal vga_stop : std_logic := '0';

  -- ext RAM
  signal data_out_ram : std_logic_vector(15 downto 0) := (others => '0');
  signal data_in_ram : std_logic_vector(15 downto 0) := (others => '0');
  signal address_in_ram : std_logic_vector(22 downto 0) := (others => '0');
  signal go_in_ram : std_logic := '0';
  signal write_in_ram : std_logic := '0';
  signal busy_ram : std_logic := '0';
  signal RxRdy_ram : std_logic := '0';
  signal extRam_reset : std_logic := '0';

  ------
  -- global control
  signal delta_angle: std_logic_vector(Nangle-1 downto 0) := (others => '0');
  signal alpha: std_logic_vector(Nangle-1 downto 0)       := (others => '0');
  signal beta: std_logic_vector(Nangle-1 downto 0)        := (others => '0');
  signal gamma: std_logic_vector(Nangle-1 downto 0)       := (others => '0');
  signal clear_enable: std_logic    := '0';
  signal clear_stop: std_logic      := '0';
  signal clear_reset: std_logic      := '0';
  signal read_start: std_logic      := '0';
  signal read_stop: std_logic       := '0';
  signal read_stop_delay: std_logic       := '0';
  signal read_reset_out: std_logic  := '0';
  signal write_reset_out: std_logic := '0';

  -------------------------------------------------------------------

     -- UART
      constant Divisor : std_logic_vector := "000000011011"; -- Divisor=27 para 115200 baudios
      signal sig_Din	: std_logic_vector(7 downto 0) := (others => '0');
      signal uart_Dout	: std_logic_vector(7 downto 0) := (others => '0');
      signal sig_RxErr	: std_logic := '0';
      signal uart_RxRdy	: std_logic := '0';
      signal sig_TxBusy	: std_logic := '0';
      signal sig_StartTx: std_logic := '0'; -- no se usa porq la uart es usada solo como receptor ??
      signal rx, tx : std_logic := '0';

  ---
  -- extRam Loader
  signal loader_RxRdy	: std_logic := '0';
  signal loader_RxRdy_delay	: std_logic := '0';

  -- XYZ loader
  signal reset_xyz : std_logic := '0';
  signal enable_xyz : std_logic := '0';
  signal RxRdy_xyz : std_logic := '0';
  signal x0 : std_logic_vector(Nxy-1 downto 0) := (others => '0');
  signal y0 : std_logic_vector(Nxy-1 downto 0) := (others => '0');
  signal z0 : std_logic_vector(Nxy-1 downto 0) := (others => '0');

  -- Rotador XYZ
  signal x : std_logic_vector(Nxy-1 downto 0) := (others => '0');
  signal y : std_logic_vector(Nxy-1 downto 0) := (others => '0');
  signal z : std_logic_vector(Nxy-1 downto 0) := (others => '0');
  signal rotator_RxRdy : std_logic := '0';
  signal x_screen : std_logic_vector((Nxy+N_bits_col)-1 downto 0) := (others => '0');
  signal y_screen : std_logic_vector((Nxy+N_bits_row)-1 downto 0) := (others => '0');
  -- signal x_screen_aux : std_logic_vector((Nxy+N_bits_col)-1 downto 0) := (others => '0');
  -- signal y_screen_aux : std_logic_vector((Nxy+N_bits_row)-1 downto 0) := (others => '0');


  -- Interconexiones
  signal reset_read_extram_counter : std_logic := '0';
  signal write_address_ram_counter : std_logic_vector(22 downto 0) := (others => '0');
  signal read_address_ram_counter : std_logic_vector(22 downto 0) := (others => '0');
  signal read_ram_ctrl : std_logic := '0';
  signal pixel_row_aux : std_logic_vector(N_bits_row-1 downto 0) := (others => '0');
  signal pixel_col_aux : std_logic_vector(N_bits_col-1 downto 0) := (others => '0');
  signal button_down : std_logic := '0';

begin
  xtal_i <= not xtal_i after 10 ns;
  -- read_enable <= '1';
  clock <= xtal_i;    
  -- DATA <= (others => '0'), "0000000000100101" after 171570 ns, --2-5
  --                          "0000000100110111" after 685400 ns; --1-3-7
  DATA <= (others => '0'), "0100000000000000" after 171570 ns; ---0.5

  -- reset <= '1';
  rot_switches_in <= "000010";
  speed <= "11";
  bypass_cordic <= '0';


  -------------------------------------------------------------------
  -- Señalización:
  -------------------------------------------------------------------
  button_down <= ( (rot_switches_in(5) XOR rot_switches_in(4)) OR 
                   (rot_switches_in(3) XOR rot_switches_in(2)) OR 
                   (rot_switches_in(1) XOR rot_switches_in(0)) OR 
                   write_reset_in OR read_reset_in );
  -- leds_out(7) <= button_down;
  -- leds_out(6) <= clear_enable;
  -- leds_out(5) <= read_start;
  -- leds_out(4) <= read_stop;
  -- leds_out(3 downto 0) <= write_address_ram_counter(3 downto 0);
  leds_out <= button_down & clear_enable & read_start & read_stop & write_address_ram_counter(3 downto 0);

  -------------------------------------------------------------------
  -- Bloque: Control Global
  -------------------------------------------------------------------
  control_global: global_ctrl
    generic map(Nangle)
    port map(
      clock => clock,
      write_reset_in  => write_reset_in ,     
      read_reset_in   => read_reset_in  ,  
      sw_x_pos        => rot_switches_in(5) ,     
      sw_x_neg        => rot_switches_in(4) ,     
      sw_y_pos        => rot_switches_in(3) ,     
      sw_y_neg        => rot_switches_in(2) ,     
      sw_z_pos        => rot_switches_in(1) ,     
      sw_z_neg        => rot_switches_in(0) ,     
      delta_angle     => delta_angle    ,   
      alpha           => alpha          ,    
      beta            => beta           ,  
      gamma           => gamma          ,  
      clear_reset     => clear_reset    ,
      clear_enable    => clear_enable   ,     
      clear_stop      => clear_stop     ,  
      read_start      => read_start     ,   
      read_stop       => read_stop      ,     
      read_reset_out  => read_reset_out ,  
      write_reset_out => write_reset_out,
      vga_start       => vga_start      ,
      vga_stop        => vga_stop
    );
      
  -- f(alpha_deg) = alpha_deg * pi/180 * 2^16 / (2*pi)
  -- Delta: 0.703125° = 128_int => w = (17 ~ 35) °/s
  -- Delta: 0.3° = 54,6 ~ 55_int => w = (7.5 ~ 15) °/s
  -- Delta: 0.1° = 18,2 ~ 18_int => w = (2.5 ~ 5) °/s
  -- Delta: 0.02° = 3.64 ~ 4 int => w = (.5 ~ 1) °/s
  -- delta_angle <= std_logic_vector(to_unsigned(128, Nangle));
  -- 
  delta_angle <= std_logic_vector(to_unsigned(4, Nangle)) when speed = "00" else
                 std_logic_vector(to_unsigned(18, Nangle)) when speed = "01" else
                 std_logic_vector(to_unsigned(55, Nangle)) when speed = "10" else
                 std_logic_vector(to_unsigned(128, Nangle)) when speed = "11";

  read_stop <= '1' when (unsigned(read_address_ram_counter) 
                       = unsigned(write_address_ram_counter)) 
               else '0';

  -------------------------------------------------------------------
  -- Bloque: CLEAR VIDEO RAM
  -------------------------------------------------------------------
  clear_inst: clear_video_ram
    generic map(
      N_bits_row => N_bits_row,
      N_bits_col => N_bits_col,
      N_ROWS => N_ROWS,
      N_COLS => N_COLS
    )
    port map(
      clock => clock,
      reset => clear_reset,
      enable => clear_enable,
      row_counter => row_counter,
      col_counter => col_counter,
      carry_out => clear_stop
    );
  -------------------------------------------------------------------

  -------------------------------------------------------------------
  -- UART 8bits --> 16bits
  -------------------------------------------------------------------
  -- 8 -> 16 : Toma los datos de la UART
  -- Acá tiene q ir el ram loader, uart_RxRdy=>RxRdy_ram
  data_loader: extRam_loader
    port map(
      clock => clock,
      reset => write_reset_out,
      data_in => uart_Dout,
      data_out => data_in_ram,
      RxRdy_in => uart_RxRdy,
      RxRdy_out => loader_RxRdy
    );
  -- Almaceno en la ram el caracter recibido por la uart.
  -- go_in se prende cuando se pide escribir (loader_RxRdy viene de la uart) y leer 
  --  (read_ram_ctrl, habilitado por not_read_stop, es decir, si los contadores de lectura
  --   y escritura son iguales, que no lea nada.)
  go_in_ram <= loader_RxRdy OR (read_ram_ctrl and (not read_stop));
  write_in_ram <= loader_RxRdy;
  address_in_ram <= write_address_ram_counter when loader_RxRdy = '1'
                    else read_address_ram_counter;

  ------------------------------------
  -- Retardo para RxRdy
  ------------------------------------
  RdRdy_delay: ffd_serie
    generic map(N => 5)
    port map(
      clock => clock,
      reset => write_reset_out,
      enable => '1',
      D => loader_RxRdy,
      Q => loader_RxRdy_delay
    );

  -------------------------------------------------------------------
  -- Contador de escritura de la RAM Externa
  -------------------------------------------------------------------
  write_extram_counter: counter
    generic map(
      N_bits => 23,
      MAX_COUNT => 2**23-1
    )
    port map(
      clock => clock,
      reset => write_reset_out,
      enable => loader_RxRdy_delay,
      counter_output => write_address_ram_counter,
      carry_out => open
    );

  -------------------------------------------------------------------
  -- Contador de lectura de la RAM Externa
  -------------------------------------------------------------------
  reset_read_extram_counter <= loader_RxRdy_delay OR read_reset_out;
  read_extram_counter: counter
    generic map(
      N_bits => 23,
      MAX_COUNT => 2**23
    )
    port map(
      clock => clock,
      reset => reset_read_extram_counter,
      -- enable => read_ram_ctrl_delay,
      enable => RxRdy_ram,
      counter_output => read_address_ram_counter,
      carry_out => open
    );


  -------------------------------------------------------------------
  -- Lectura de la RAM externa
  -------------------------------------------------------------------
  -- XYZ LOADER
  xyz_loader_inst: xyz_loader
    port map(
      clock => clock,
      reset => read_stop_delay,
      enable => enable_xyz,
      start => read_start,
      data_in => data_out_ram,
      go_ram => read_ram_ctrl,
      RxRdy_ram => RxRdy_ram,
      busy_ram => busy_ram,
      RxRdy_out => RxRdy_xyz,
      x => x0,
      y => y0,
      z => z0
    );

  enable_xyz <= '1';
  read_stop_ffd: ffd
    port map(
      clk => clock,
      rst => '0',
      enable => '1',
      D => read_stop,
      Q => read_stop_delay
    );

  -------------------------------------------------------------------
  -- Bloque: Rotador XYZ
  -------------------------------------------------------------------
  rotator: xyz_rotator
    generic map(
      Nxy => Nxy,
      Nangle => Nangle,
      Nits => Nits
    )
    port map(
      clock => clock,
      reset => read_reset_out,
      load => RxRdy_xyz,
      RxRdy => rotator_RxRdy,
      alpha => alpha,
      beta => beta,
      gamma => gamma,
      x0 => x0,
      y0 => y0,
      z0 => z0,
      x1 => x,
      y1 => y,
      z1 => z
    );
      
  -- x <= x0;
  -- y <= y0;
  -- z <= z0;

  -------------------------------------------------------------------
  -- Escalado de la salida del rotador
  -------------------------------------------------------------------
  -- Agrego escalado a tamaño de pantalla: 
  --  X,Y se encuentran entre (-2^(Nxy-2), 2^(Nxy-2))
  --  Lo llevo a (-2^(Nbits_row-1), 2^(Nbits_row-1))
  --  Lo llevo a (-N_ROWS/2, N_ROWS/2)
  --  Equivale a quedarse con los N_bits_row más significativos
  -- Agrego cambio de coordenadas de XY(modelo) a fila-columna(pantalla)
  -- A_row_aux <= std_logic_vector(CENTER_ROW - signed(y(Nxy-1 downto Nxy-N_bits_row)));
  -- A_col_aux <= std_logic_vector(CENTER_COL + signed(x(Nxy-1 downto Nxy-N_bits_col)));
  x_screen <= std_logic_vector(unsigned(x) *  unsigned(N_COLS_VEC) ) when bypass_cordic = '0' else
              std_logic_vector(unsigned(x0) * unsigned(N_COLS_VEC) );
  y_screen <= std_logic_vector(unsigned(y) *  unsigned(N_ROWS_VEC) ) when bypass_cordic = '0' else
              std_logic_vector(unsigned(y0) * unsigned(N_ROWS_VEC) );

  -- Dividir por 2**(Nxy-1) es equivalente a desplazar a derecha en Nxy-1, que equivale a tomar los segundos Nxy-1 bits
  -- x_screen <= x_screen_aux((Nxy+N_bits_col)-1 downto Nxy-1);
  -- y_screen <= y_screen_aux((Nxy+N_bits_row)-1 downto Nxy-1);
  A_row_aux <= std_logic_vector(CENTER_ROW - signed(y_screen((Nxy+N_bits_row)-2 downto Nxy-1)));
  A_col_aux <= std_logic_vector(CENTER_COL + signed(x_screen((Nxy+N_bits_col)-2 downto Nxy-1)));


  -------------------------------------------------------------------
  -- Video RAM
  -------------------------------------------------------------------
  video_RAM_inst : video_ram
    generic map (
      N_bits_row => N_bits_row,
      N_bits_col => N_bits_col,
      N_rows => N_rows,
      N_cols => N_cols
    )
    port map(
      clock => clock,
      write_enable => video_write_enable, 
      A_row => A_row,
      B_row  => B_row  , 
      A_col  => A_col  , 
      B_col  => B_col  , 
      data_A => data_A , 
      data_B => data_B  
    );

  -- Escritura
  -- row/col_counter: del CLEAR
  -- A_row/col_aux: de x,y,z, luego de transformarlos y escalarlos
  A_row <= row_counter when clear_enable = '1' else A_row_aux;
  A_col <= col_counter when clear_enable = '1' else A_col_aux;
  data_A <= '0' when clear_enable = '1' else '1';
  video_write_enable <= rotator_RxRdy OR clear_enable when bypass_cordic = '0' else
                        RxRdy_xyz OR clear_enable;

  -- Lectura
  -- Con el contador de salida de la VGA, leo la video ram,
  --  solo cuando está habilitada la escritura.
  B_row <= pixel_row_aux when enable_vga = '1' else (others => '0');
  B_col <= pixel_col_aux when enable_vga = '1' else (others => '0');

  -------------------------------------------------------------------
  -- VGA
  -------------------------------------------------------------------
  -- Señales para indicar el barrido de la vga.
  -- Avisa cuando empieza a barrer la pantalla
  vga_start <= '1' when (unsigned(B_row) = 0) and (unsigned(B_col) = 0) and (enable_vga = '1')
                else '0';
  -- Avisa cuando se terminó una barrida completa de la pantalla.
  vga_stop <= '1' when (unsigned(B_row) = N_ROWS-1) and (unsigned(B_col) = N_COLS-1) 
                else '0';

  -- Entrada de color de la VGA.
  vga_pixel_in <= data_B and enable_vga_delay;
  -- Retraso enable_vga en 1 ciclo de clock
  delay_vga: ffd
    port map(
      clk => clock,
      rst => '0',
      enable => '1',
      D => enable_vga,
      Q => enable_vga_delay
    );

  -- Resto el offset de los contadores de filas y columnas de pantalla(vga)
  pixel_row_aux <= std_logic_vector(unsigned(
                   pixel_row(N_bits_row-1 downto 0)) - TOP_MARGIN);
  pixel_col_aux <= std_logic_vector(unsigned(
                   pixel_col(N_bits_col-1 downto 0)) - LEFT_MARGIN);
  -- enable vga
  -- Habilito la escritura en la VGA solo cuando me encuentro
  --  entre los márgenes permitidos para imprimir en pantalla.
  process(pixel_row, pixel_col)
  begin
    if TOP_MARGIN - 1 < unsigned(pixel_row) and
       unsigned(pixel_row) < TOP_MARGIN + N_rows and 
       LEFT_MARGIN - 1 < unsigned(pixel_col) and
       unsigned(pixel_col) < LEFT_MARGIN + N_cols then

      enable_vga <= '1';
    else
      enable_vga <= '0';
    end if;
  end process;


	vga: vga_ctrl 
    port map(
      mclk => clock, 
      red_i => vga_pixel_in, 
      grn_i => vga_pixel_in, 
      blu_i => vga_pixel_in, 
      hs => hsync, 
      vs => vsync, 
      red_o => red_out, 
      grn_o => grn_out, 
      blu_o => blu_out, 
      pixel_row => pixel_row, 
      pixel_col => pixel_col
    );

  -------------------------------------------------------------------
  -- UART
  -------------------------------------------------------------------
  rx <= rx_i;
	UART_receiver : uart
	generic map (
		F 	=> 50000,
		min_baud => 1200,
		num_data_bits => 8
	)
	port map (
    Rx	=> rx,
	 	Tx	=> tx,
	 	Din	=> sig_Din,
	 	StartTx	=> sig_StartTx,
		TxBusy	=> sig_TxBusy,
		Dout	=> uart_Dout,
		RxRdy	=> uart_RxRdy,
		RxErr	=> sig_RxErr,
		Divisor	=> Divisor,
		clk	=> clock,
		rst	=> write_reset_out
	);

  -------------------------------------------------------------------
  -- Controlador de la RAM Externa
  -------------------------------------------------------------------
  ext_RAM: MemoryController
    generic map (clock_frec => 50)
    port map (
      clock			 => 	clock			,	
      reset      =>   '0',
      address_in => 	address_in_ram,	
      go_in			 => 	go_in_ram			,	
      write_in	 => 	write_in_ram	,	
      data_in		 => 	data_in_ram		,	
      data_out	 => 	data_out_ram	,	
      read_ready_out => RxRdy_ram,
      busy       =>   busy_ram,
      ---------- => ------------,--
      clock_out	 => 	clock_out	,	
      ADDRESS		 => 	ADDRESS		,	
      ADV				 => 	ADV				,	
      CRE				 => 	CRE				,	
      CE				 => 	CE				,	
      OE				 => 	OE				,	
      WE				 => 	WE				,	
      LB				 => 	LB				,	
      UB				 => 	UB				,	
      DATA			 => 	DATA				
    );

end architecture RTL; -- Entity: board_top

