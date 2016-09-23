-------------------------------------------------------------------------------
--  Facultad de Ingeniería de la Universidad de Buenos Aires
--  Sistemas Digitales
--  2° Cuatrimestre de 2015
-- 
--  Sampayo, Sebastián Lucas
--  Padrón: 93793
--  e-mail: sebisampayo@gmail.com
-------------------------------------------------------------------------------

----------------
-- Paquete de componentes
----------------
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
-------------------------------------------------------------------------------
package my_components is
  -- Functions
  ----
  function to_std_logic (value: integer) return std_logic;
  function to_integer (value: std_logic) return integer;
  ---- 

  -- Components
  -----

  component ffd_serie is
    generic(
      N : natural := 1
    );
    port(
      clock: in std_logic;
      reset: in std_logic;
      enable: in std_logic;
      D : in std_logic;
      Q : out std_logic
    );
  end component ffd_serie;
  -----

  component ffd is
	  port(
      rst: in std_logic;
		  clk: in std_logic;
		  enable: in std_logic;
		  D: in std_logic;
		  Q: out std_logic
	  );
  end component ffd;
  -----

  component register_N is
	  generic(N: natural:= 8);
	  port(
		  clock: in std_logic;
		  reset: in std_logic;
		  enable: in std_logic;
		  D: in std_logic_vector(N-1 downto 0);
		  Q: out std_logic_vector(N-1 downto 0)
	  );
  end component register_N;
  -----

  component delay_reg is
    generic(
      N: natural:= 8;
      DELAY: natural:= 0
    );
    port(
      clock: in std_logic;
      reset: in std_logic;
      enable: in std_logic;
      A: in std_logic_vector(N-1 downto 0);
      B: out std_logic_vector(N-1 downto 0)
    );
  end component delay_reg;
  -----

	component full_adder_1_bit is 
		port(
			A: in std_logic;
			B: in std_logic;
			Cin: in std_logic;
			S: out std_logic;
			Cout: out std_logic
		);
	end component full_adder_1_bit;
  -----

  component adder is 
  generic (N:natural:=8);
  port(
    A: in std_logic_vector(N-1 downto 0);
    B: in std_logic_vector(N-1 downto 0);
    control: in std_logic;
    S: out std_logic_vector(N-1 downto 0);
    Cout: out std_logic
  );
  end component adder;
  -----

  component multiplier is
    generic (N:integer:=8);
    port(	
      clock: in std_logic;
      load: in std_logic;
      A: in std_logic_vector(N-1 downto 0);
      B: in std_logic_vector(N-1 downto 0);
      result: out std_logic_vector(2*N-1 downto 0);
      done: out std_logic
    );
  end component;
  -----

  component delta_delay is
    generic(
      N : natural := 1
    );
    port(
      A : in std_logic;
      Z : out std_logic
    );
  end component delta_delay;
  -----

  component vga_ctrl is
    port (
      mclk: in std_logic;
      red_i: in std_logic;
      grn_i: in std_logic;
      blu_i: in std_logic;
      hs: out std_logic;
      vs: out std_logic;
      red_o: out std_logic_vector(2 downto 0);
      grn_o: out std_logic_vector(2 downto 0);
      blu_o: out std_logic_vector(1 downto 0);
      pixel_row: out std_logic_vector(9 downto 0);
      pixel_col: out std_logic_vector(9 downto 0)
    );
  end component vga_ctrl;
  -----

  component uart is
    generic (
      F : natural := 50000;	-- Device clock frequency [KHz].
      min_baud : natural := 1200;
      num_data_bits : natural := 8
    );
    port (
      Rx	: in std_logic;
      Tx	: out std_logic;
      Din	: in std_logic_vector(7 downto 0);
      StartTx	: in std_logic;
      TxBusy	: out std_logic;
      Dout	: out std_logic_vector(7 downto 0);
      RxRdy	: out std_logic;
      RxErr	: out std_logic;
      Divisor	: in std_logic_vector;
      clk	: in std_logic;
      rst	: in std_logic
    );
  end component uart;
  -----

  -- Componentes de la UART
  -----
  component timing is
    generic (
      F : natural;
      min_baud : natural
    );
    port (
            CLK : in std_logic;
            RST : in std_logic;
            divisor : in std_logic_vector;
            ClrDiv : in std_logic;
            Top16 : buffer std_logic;
            TopTx : out std_logic;
            TopRx : out std_logic
    );
  end component;
  -----

  component transmit is
    generic (
            NDBits : natural := 8
    );
    port (
      CLK : in std_logic;
      RST : in std_logic;
      Tx : out std_logic;
      Din  : in std_logic_vector (NDBits-1 downto 0);
      TxBusy : out std_logic;
      TopTx : in std_logic;
      StartTx : in std_logic
    );
  end component;
  -----

  component receive is
    generic (
      NDBits : natural := 8
    );
    port (
      CLK : in std_logic;
      RST : in std_logic;
      Rx : in std_logic;
      Dout : out std_logic_vector (NDBits-1 downto 0);
      RxErr : out std_logic;
      RxRdy : out std_logic;
      Top16 : in std_logic;
      ClrDiv : out std_logic;
      TopRx : in std_logic
    );
  end component;
  -----

  component MemoryController is
    Generic (
      clock_frec : integer := 50
    );
    Port ( 
      -----------------------------------------------
      --        Signals for the controller         --
      -----------------------------------------------
      clock				:	in		STD_LOGIC;								-- 100MHz/50MHz
      reset				:	in		STD_LOGIC;								
      address_in	:	in		STD_LOGIC_VECTOR (22 downto 0);	-- RAM address
      go_in				:	in		STD_LOGIC;								-- if='1' starts the operation
      write_in		:	in		STD_LOGIC;								-- if='0' => read; if='1' => write
      data_in			:	in		STD_LOGIC_VECTOR (15 downto 0);	-- data that has to be written
      data_out		:	out	STD_LOGIC_VECTOR (15 downto 0);	-- data that has been read
      read_ready_out : out STD_LOGIC; -- if='1' valid data_out
      busy : out STD_LOGIC; -- if='1' RAM is busy (go_in won't take effect)
      -----------------------------------------------
      -- Signals from the controller to the memory --
      -----------------------------------------------
      clock_out		:	out 	STD_LOGIC;
      ADDRESS			:	out	STD_LOGIC_VECTOR (22 downto 0);
      ADV					:	out	STD_LOGIC;
      CRE					:	out	STD_LOGIC;
      CE					:	out	STD_LOGIC;
      OE					:	out	STD_LOGIC;
      WE					:	out	STD_LOGIC;
      LB					:	out	STD_LOGIC;
      UB					:	out	STD_LOGIC;
      DATA				:	inout	STD_LOGIC_VECTOR (15 downto 0)
     );
  end component MemoryController;
  -----

  component counter is
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
  end component counter;
  -----

  component clear_video_ram is
    generic(
      N_bits_row: natural := 2;
      N_bits_col: natural := 2;
      N_ROWS: natural := 2;
      N_COLS: natural := 2
    );
    port(
      clock: in std_logic;
      reset: in std_logic;
      enable: in std_logic;
      row_counter: out std_logic_vector(N_bits_row-1 downto 0);
      col_counter: out std_logic_vector(N_bits_col-1 downto 0);
      carry_out: out std_logic
    );
  end component clear_video_ram;
  -----

  component dual_port_ram is
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
  end component dual_port_ram;
  -----

  component video_ram is
    generic(
      N_bits_row : integer := 10;
      N_bits_col : integer := 10;
      N_rows : integer := 480;
      N_cols : integer := 640
    );
    port(
      clock: in std_logic;
      write_enable : in std_logic;
      A_row : in std_logic_vector(N_bits_row-1 downto 0);
      B_row : in std_logic_vector(N_bits_row-1 downto 0);
      A_col : in std_logic_vector(N_bits_col-1 downto 0);
      B_col : in std_logic_vector(N_bits_col-1 downto 0);
      data_A : in std_logic;
      data_B : out std_logic
    );
  end component video_ram;
  -----

  component barrel_shifter is
    generic(
      N : natural := 8
    );
    port(
      left : in std_logic;
      M : natural;
      x : in std_logic_vector(N-1 downto 0);
      y : out std_logic_vector(N-1 downto 0)
    );
  end component barrel_shifter;
  -----

end my_components;
-------------------------------------------------------------------------------

package body my_components is
  ----
  function to_std_logic (value: integer) return std_logic is
  begin
    if value = 0 then
      return '0';
    else
      return '1';
    end if;
  end function to_std_logic;
  ----

  function to_integer (value: std_logic) return integer is
  begin
    if value = '0' then
      return 0;
    else
      return 1;
    end if;
  end function to_integer;
  ----

end package body my_components;
-------------------------------------------------------------------------------
