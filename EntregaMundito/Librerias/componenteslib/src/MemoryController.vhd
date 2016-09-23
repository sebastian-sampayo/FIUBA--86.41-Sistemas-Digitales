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
-- Engineer:				Sebastián Lucas Sampayo
--
-- Create Date:			02/2016
-- Module Name:			MemoryController - Behavioral
-- Target Devices: 		Digilent Nexys 2 500k/1200k, or any board with the Micron
--								MT45W8MW16BGX CellularRam
--
-- Description: 			Asynchronous read and write from/to the Micron MT45W8MW16BGX
--								CellularRam.
-------------------------------------------------------------------------------------
-- Revisión: Proceso, en cada flanco ascendente del clock:
--            1er ciclo: Se detecta go_in=1, write_in, por lo tanto se cambia de estado
--            2,3,4,5 ciclo: Se setean las señales de control de la RAM (OE, WE, CE) 
--                            y se espera a que pasen los 70ns 
--                            (en total 80ns, para 50Mhz: 4 ciclos: 2,3,4,5)
--            4to ciclo: Se activa la DATA a la salida (en READING)
--            5to ciclo: Se activa read_ready_out durante 1 ciclo(en READING)
--                        (por lo tanto recién puede ser detectado en el 6to ciclo
--
-- Nota: El read_ready_out se podría adelantar 1 ciclo, de modo que sea detectado en 
--        el flanco del 5to ciclo.
--       De cualquier modo, como se conoce de antemano que hay que esperar 4 ciclos 
--        para tener la salida válida, el read_ready_out no sería necesario...
-- Nota2: Ver diagrama de tiempos, con deltas, en carpeta.
-------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MemoryController is
    Generic (
        clock_frec : integer := 50 -- MHz
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
end entity MemoryController;

architecture Behavioral of MemoryController is

	type state_t is (INIT, IDLE, WRITING, READING);
  signal state : state_t := INIT;
  -- signal state : state_t := IDLE; -- DEBUG
  -- TODO: usar alguna función de redondeo, floor, ceil, etc.
  constant clock_period_ns : integer := (1000/clock_frec); -- nanoseconds (50MHz => 20ns, 100MHz => 10ns)
  constant init_period_us : integer := 151; -- microseconds (151 us)
	constant init_counter : integer := (init_period_us * 1000 / clock_period_ns); -- 151 microseconds
	constant timing_counter : integer := (80 / clock_period_ns); -- 80 nanoseconds (70ns)
	
	signal counter : integer range 0 to init_counter := 0;
	
  -- Controls the input data to write to the RAM
	signal writing_out : STD_LOGIC := '0';
	
	-- signal current_data_out, next_data_out : std_logic_vector(15 downto 0):= (others => '0');

  -- Agregado:
  signal address_aux : std_logic_vector(22 downto 0) := (others => '0');
  signal data_in_aux : std_logic_vector(15 downto 0) := (others => '0');

begin

	-- ADDRESS <= address_in;
  -- Agregado: (utilizo señal auxiliar para poder inicializar correctamente)
  -- (de modo que no quede indefinido su valor antes del primer go_in)
	--address_aux <= address_in when go_in = '1' else address_aux ; 
	ADDRESS <= address_aux ;
  -- Esto es para que ADDRESS tome el valor de address_in cuando go_in='1'
  --  y mantenga dicho valor durante los 4 ciclos de trabajo. Idem para
  --  DATA.
  address_process: process (clock, reset)
  begin
    if reset = '1' then
      address_aux <= (others => '0');
      data_in_aux <= (others => '0');
    elsif rising_edge(clock) then
      if go_in = '1' then
        address_aux <= address_in;
        data_in_aux <= data_in;
      end if;
    end if;
  end process;
  --

	clock_out <= '0'; -- always '0' since this controller operates in asynchronous mode
	CRE <= '0'; -- always '0' because this controller uses the default configuration
	
	-- DATA <= data_in when writing_out='1' else (others => 'Z');
  -- Agregado: (utilizo señal auxiliar para poder inicializar correctamente)
  -- (de modo que no quede indefinido su valor antes del primer go_in)
  -- data_in_aux <= data_in when go_in = '1';
	DATA <= data_in_aux when writing_out='1' else (others => 'Z');
  --

  -- Señales de control
  busy <= '1' when (state = WRITING OR state = READING OR state = INIT) else '0';
  ADV <= '1' when state = INIT else '0';
  CE <= '0' when (state = WRITING OR state = READING) else '1';
  LB <= '0' when (state = WRITING OR state = READING) else '1';
  UB <= '0' when (state = WRITING OR state = READING) else '1';
  WE <= '0' when state = WRITING else '1';
  OE <= '0' when state = READING else '1';
  writing_out <= '1' when state = WRITING else '0';
	
	-- FSM process
  FSM: process (clock, reset)
  begin
    -- RESET
    if reset = '1' then
      state <= INIT;
      -- state <= IDLE; -- DEBUG

    elsif rising_edge(clock) then
      case state is
        -- INIT
        when INIT => 
          read_ready_out <= '0';
          data_out <= (others => '0');

          if (counter >= init_counter) then
            counter <= 0;
            state <= IDLE;
          else
            counter <= counter + 1;
          end if;

        -- IDLE
        when IDLE => 
          read_ready_out <= '0';
          data_out <= (others => '0');

          if go_in = '1' then
            if write_in = '1' then
              state <= WRITING;
            else
              state <= READING;
            end if;
          end if;

        -- WRITING
        when WRITING =>
          if (counter >= timing_counter - 1) then
            counter <= 0;
            state <= IDLE;
          else
            counter <= counter + 1;
          end if;

        -- READING
        when READING =>
          -- En el último ciclo de la cuenta
          if (counter = timing_counter - 2) then
            data_out <= DATA;
            counter <= counter + 1;
            -- Adelanto el read_ready_out para leer en el 5to flanco
            read_ready_out <= '1';
          -- Cuando termina de contar
          elsif (counter >= timing_counter - 1) then
            counter <= 0;
            state <= IDLE;
            data_out <= DATA;
            --read_ready_out <= '1';
            read_ready_out <= '0';
          else
            counter <= counter + 1;
          end if;

        when others =>
          state <= IDLE;

     end case;
   end if;
 end process; -- FSM

end Behavioral;
