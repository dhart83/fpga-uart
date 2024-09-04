library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity baud_gen_tb is
end entity;

architecture testbench of baud_gen_tb is

  component baud_gen is
    generic (
      G_CLK_FREQ  : integer := 100_000_000;
      G_OS_FACTOR : integer := 16
    );
    port (
      i_clk         : in  std_logic;
      i_rst_n       : in  std_logic;
      i_clk_en      : in  std_logic;
      i_baud_sel    : in  std_logic_vector(2 downto 0);
      o_baud_tick   : out std_logic;
      o_sample_tick : out std_logic
    );
  end component;

  constant C_BAUD_9600    : std_logic_vector(2 downto 0) := "000";
  constant C_BAUD_19200   : std_logic_vector(2 downto 0) := "001";
  constant C_BAUD_38400   : std_logic_vector(2 downto 0) := "010";
  constant C_BAUD_57600   : std_logic_vector(2 downto 0) := "011";
  constant C_BAUD_115200  : std_logic_vector(2 downto 0) := "100";
  constant C_BAUD_230400  : std_logic_vector(2 downto 0) := "101";
  constant C_BAUD_460800  : std_logic_vector(2 downto 0) := "110";
  constant C_BAUD_921600  : std_logic_vector(2 downto 0) := "111";

  constant C_TOLERANCE_UPPER  : real := 1.02; -- +2% tolerance
  constant C_TOLERANCE_LOWER  : real := 0.98; -- -2% tolerance

  constant C_BAUD_9600_PERIOD       : time := 104_167 ns;
  constant C_BAUD_9600_UPPER_TOL    : time := C_BAUD_9600_PERIOD * C_TOLERANCE_UPPER;
  constant C_BAUD_9600_LOWER_TOL    : time := C_BAUD_9600_PERIOD * C_TOLERANCE_LOWER;

  constant C_BAUD_19200_PERIOD      : time := 52_083 ns;
  constant C_BAUD_19200_UPPER_TOL   : time := C_BAUD_19200_PERIOD * C_TOLERANCE_UPPER;
  constant C_BAUD_19200_LOWER_TOL   : time := C_BAUD_19200_PERIOD * C_TOLERANCE_LOWER;

  constant C_BAUD_38400_PERIOD      : time := 26_042 ns;
  constant C_BAUD_38400_UPPER_TOL   : time := C_BAUD_38400_PERIOD * C_TOLERANCE_UPPER;
  constant C_BAUD_38400_LOWER_TOL   : time := C_BAUD_38400_PERIOD * C_TOLERANCE_LOWER;

  constant C_BAUD_57600_PERIOD      : time := 17_361 ns;
  constant C_BAUD_57600_UPPER_TOL   : time := C_BAUD_57600_PERIOD * C_TOLERANCE_UPPER;
  constant C_BAUD_57600_LOWER_TOL   : time := C_BAUD_57600_PERIOD * C_TOLERANCE_LOWER;
    
  constant C_BAUD_115200_PERIOD     : time := 8_681 ns;
  constant C_BAUD_115200_UPPER_TOL  : time := C_BAUD_115200_PERIOD * C_TOLERANCE_UPPER;
  constant C_BAUD_115200_LOWER_TOL  : time := C_BAUD_115200_PERIOD * C_TOLERANCE_LOWER;
    
  constant C_BAUD_230400_PERIOD     : time := 4_340 ns;
  constant C_BAUD_230400_UPPER_TOL  : time := C_BAUD_230400_PERIOD * C_TOLERANCE_UPPER;
  constant C_BAUD_230400_LOWER_TOL  : time := C_BAUD_230400_PERIOD * C_TOLERANCE_LOWER;
    
  constant C_BAUD_460800_PERIOD     : time := 2_170 ns;
  constant C_BAUD_460800_UPPER_TOL  : time := C_BAUD_460800_PERIOD * C_TOLERANCE_UPPER;
  constant C_BAUD_460800_LOWER_TOL  : time := C_BAUD_460800_PERIOD * C_TOLERANCE_LOWER;
    
  constant C_BAUD_921600_PERIOD     : time := 1_085 ns;
  constant C_BAUD_921600_UPPER_TOL  : time := C_BAUD_921600_PERIOD * C_TOLERANCE_UPPER;
  constant C_BAUD_921600_LOWER_TOL  : time := C_BAUD_921600_PERIOD * C_TOLERANCE_LOWER;

  signal clk_i         : std_logic                    := '0';
  signal rst_n_i       : std_logic                    := '0';
  signal clk_en_i      : std_logic                    := '1';
  signal baud_sel_i    : std_logic_vector(2 downto 0) := (others => '0');
  signal baud_tick_i   : std_logic                    := '0';
  signal samp_tick_i   : std_logic                    := '0';

  constant C_CLK_PERIOD     : time := 10 ns;

begin


  UUT : baud_gen
    generic map (
      G_CLK_FREQ  => 100_000_000,
      G_OS_FACTOR => 16
    )
    port map (
      i_clk         => clk_i,
      i_rst_n       => rst_n_i,
      i_clk_en      => clk_en_i,
      i_baud_sel    => baud_sel_i,
      o_baud_tick   => baud_tick_i,
      o_sample_tick => samp_tick_i
    );


  clk_process : process
  begin
    clk_i <= '0';
    wait for C_CLK_PERIOD / 2;
    clk_i <= '1';
    wait for C_CLK_PERIOD / 2;
  end process;


  stimulus : process

    variable v_samp_count   : integer := 0;
    variable v_start_time   : time    := 0 ns;
    variable v_baud_time    : time    := 0 ns;

  begin

    -- Reset
    rst_n_i <= '0';
    wait for 100 ns;
    rst_n_i <= '1';


    wait for C_CLK_PERIOD * 10;


    -- Test BAUD_9600
    baud_sel_i <= C_BAUD_9600;
    wait for C_CLK_PERIOD;
    wait until baud_tick_i = '1';
    v_start_time := now;
    wait until baud_tick_i = '1';
    v_baud_time   := now - v_start_time;
    assert (v_baud_time <= C_BAUD_9600_UPPER_TOL) and 
          (v_baud_time >= C_BAUD_9600_LOWER_TOL)
      report "BAUD_9600: Simulation time now = " & time'image(now - v_start_time) & 
            ", Expected upper = " & time'image(C_BAUD_9600_UPPER_TOL) & 
            ", Expected lower = " & time'image(C_BAUD_9600_LOWER_TOL)
      severity error;


    -- Test BAUD_19200
    baud_sel_i <= C_BAUD_19200;
    wait for C_CLK_PERIOD;
    wait until baud_tick_i = '1';
    v_start_time := now;
    wait until baud_tick_i = '1';
    v_baud_time   := now - v_start_time;
    assert (v_baud_time <= C_BAUD_19200_UPPER_TOL) and 
          (v_baud_time >= C_BAUD_19200_LOWER_TOL)
      report "BAUD_19200: Simulation time now = " & time'image(now - v_start_time) & 
            ", Expected upper = " & time'image(C_BAUD_19200_UPPER_TOL) & 
            ", Expected lower = " & time'image(C_BAUD_19200_LOWER_TOL)
      severity error;


    -- Test BAUD_38400
    baud_sel_i <= C_BAUD_38400;
    wait for C_CLK_PERIOD;
    wait until baud_tick_i = '1';
    v_start_time := now;
    wait until baud_tick_i = '1';
    v_baud_time   := now - v_start_time;
    assert (v_baud_time <= C_BAUD_38400_UPPER_TOL) and 
          (v_baud_time >= C_BAUD_38400_LOWER_TOL)
      report "BAUD_38400: Simulation time now = " & time'image(now - v_start_time) & 
            ", Expected upper = " & time'image(C_BAUD_38400_UPPER_TOL) & 
            ", Expected lower = " & time'image(C_BAUD_38400_LOWER_TOL)
      severity error;


    -- Disable clock enable
    clk_en_i <= '0';
    wait for C_BAUD_38400_PERIOD * 2;
    assert baud_tick_i = '0' and samp_tick_i = '0'
      report "Clock enable failure, baud_tick and samp_tick should be low" severity error;
    clk_en_i <= '1';


    -- Test BAUD_57600
    baud_sel_i <= C_BAUD_57600;
    wait for C_CLK_PERIOD;
    wait until baud_tick_i = '1';
    v_start_time := now;
    wait until baud_tick_i = '1';
    v_baud_time   := now - v_start_time;
    assert (v_baud_time <= C_BAUD_57600_UPPER_TOL) and 
          (v_baud_time >= C_BAUD_57600_LOWER_TOL)
      report "BAUD_57600: Simulation time now = " & time'image(now - v_start_time) & 
            ", Expected upper = " & time'image(C_BAUD_57600_UPPER_TOL) & 
            ", Expected lower = " & time'image(C_BAUD_57600_LOWER_TOL)
      severity error;


    -- Test BAUD_115200
    baud_sel_i <= C_BAUD_115200;
    wait for C_CLK_PERIOD;
    wait until baud_tick_i = '1';
    v_start_time := now;
    wait until baud_tick_i = '1';
    v_baud_time   := now - v_start_time;
    assert (v_baud_time <= C_BAUD_115200_UPPER_TOL) and 
          (v_baud_time >= C_BAUD_115200_LOWER_TOL)
      report "BAUD_115200: Simulation time now = " & time'image(now - v_start_time) & 
            ", Expected upper = " & time'image(C_BAUD_115200_UPPER_TOL) & 
            ", Expected lower = " & time'image(C_BAUD_115200_LOWER_TOL)
      severity error;


    -- Test BAUD_230400
    baud_sel_i <= C_BAUD_230400;
    wait for C_CLK_PERIOD;
    wait until baud_tick_i = '1';
    v_start_time := now;
    wait until baud_tick_i = '1';
    v_baud_time   := now - v_start_time;
    assert (v_baud_time <= C_BAUD_230400_UPPER_TOL) and 
          (v_baud_time >= C_BAUD_230400_LOWER_TOL)
      report "BAUD_230400: Simulation time now = " & time'image(now - v_start_time) & 
            ", Expected upper = " & time'image(C_BAUD_230400_UPPER_TOL) & 
            ", Expected lower = " & time'image(C_BAUD_230400_LOWER_TOL)
      severity error;


    -- Test BAUD_460800
    baud_sel_i <= C_BAUD_460800;
    wait for C_CLK_PERIOD;
    wait until baud_tick_i = '1';
    v_start_time := now;
    wait until baud_tick_i = '1';
    v_baud_time   := now - v_start_time;
    assert (v_baud_time <= C_BAUD_460800_UPPER_TOL) and 
          (v_baud_time >= C_BAUD_460800_LOWER_TOL)
      report "BAUD_460800: Simulation time now = " & time'image(now - v_start_time) & 
            ", Expected upper = " & time'image(C_BAUD_460800_UPPER_TOL) & 
            ", Expected lower = " & time'image(C_BAUD_460800_LOWER_TOL)
      severity error;


    -- Test BAUD_921600
    baud_sel_i <= C_BAUD_921600;
    wait for C_CLK_PERIOD;
    wait until baud_tick_i = '1';
    v_start_time := now;
    wait until baud_tick_i = '1';
    v_baud_time   := now - v_start_time;
    assert (v_baud_time <= C_BAUD_921600_UPPER_TOL) and 
          (v_baud_time >= C_BAUD_921600_LOWER_TOL)
      report "BAUD_921600: Simulation time now = " & time'image(now - v_start_time) & 
            ", Expected upper = " & time'image(C_BAUD_921600_UPPER_TOL) & 
            ", Expected lower = " & time'image(C_BAUD_921600_LOWER_TOL)
      severity error;

    wait;
  end process;

end testbench;
