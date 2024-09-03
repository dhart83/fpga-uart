library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity baud_gen_tb is
end entity;

architecture testbench of baud_gen_tb is

  component baud_gen is
    generic (
      CLK_FREQ : integer := 100_000_000
    );
    port (
      clk         : in  std_logic;
      rst_n       : in  std_logic;
      clk_en      : in  std_logic;
      baud_sel    : in  std_logic_vector(2 downto 0);
      baud_tick   : out std_logic
    );
  end component;

  constant BAUD_9600    : std_logic_vector(2 downto 0) := "000";
  constant BAUD_19200   : std_logic_vector(2 downto 0) := "001";
  constant BAUD_38400   : std_logic_vector(2 downto 0) := "010";
  constant BAUD_57600   : std_logic_vector(2 downto 0) := "011";
  constant BAUD_115200  : std_logic_vector(2 downto 0) := "100";
  constant BAUD_230400  : std_logic_vector(2 downto 0) := "101";
  constant BAUD_460800  : std_logic_vector(2 downto 0) := "110";
  constant BAUD_921600  : std_logic_vector(2 downto 0) := "111";

  constant tolerance_upper  : real := 1.02; -- +2% tolerance
  constant tolerance_lower  : real := 0.98; -- -2% tolerance

  constant baud_9600_period       : time := 104_167 ns;
  constant baud_9600_upper_tol    : time := baud_9600_period * tolerance_upper;
  constant baud_9600_lower_tol    : time := baud_9600_period * tolerance_lower;

  constant baud_19200_period      : time := 52_083 ns;
  constant baud_19200_upper_tol   : time := baud_19200_period * tolerance_upper;
  constant baud_19200_lower_tol   : time := baud_19200_period * tolerance_lower;

  constant baud_38400_period      : time := 26_042 ns;
  constant baud_38400_upper_tol   : time := baud_38400_period * tolerance_upper;
  constant baud_38400_lower_tol   : time := baud_38400_period * tolerance_lower;

  constant baud_57600_period      : time := 17_361 ns;
  constant baud_57600_upper_tol   : time := baud_57600_period * tolerance_upper;
  constant baud_57600_lower_tol   : time := baud_57600_period * tolerance_lower;
    
  constant baud_115200_period     : time := 8_681 ns;
  constant baud_115200_upper_tol  : time := baud_115200_period * tolerance_upper;
  constant baud_115200_lower_tol  : time := baud_115200_period * tolerance_lower;
    
  constant baud_230400_period     : time := 4_340 ns;
  constant baud_230400_upper_tol  : time := baud_230400_period * tolerance_upper;
  constant baud_230400_lower_tol  : time := baud_230400_period * tolerance_lower;
    
  constant baud_460800_period     : time := 2_170 ns;
  constant baud_460800_upper_tol  : time := baud_460800_period * tolerance_upper;
  constant baud_460800_lower_tol  : time := baud_460800_period * tolerance_lower;
    
  constant baud_921600_period     : time := 1_085 ns;
  constant baud_921600_upper_tol  : time := baud_921600_period * tolerance_upper;
  constant baud_921600_lower_tol  : time := baud_921600_period * tolerance_lower;

  signal clk         : std_logic                    := '0';
  signal rst_n       : std_logic                    := '0';
  signal clk_en      : std_logic                    := '1';
  signal baud_sel    : std_logic_vector(2 downto 0) := (others => '0');
  signal baud_tick   : std_logic                    := '0';

  constant clk_period     : time := 10 ns;

begin


  UUT : baud_gen
    generic map (
      CLK_FREQ => 100_000_000
    )
    port map (
      clk       => clk,
      rst_n     => rst_n,
      clk_en    => clk_en,
      baud_sel  => baud_sel,
      baud_tick => baud_tick
    );


  clk_process : process
  begin
    clk <= '0';
    wait for clk_period / 2;
    clk <= '1';
    wait for clk_period / 2;
  end process;


  stimulus : process

    variable tick_count   : integer := 0;
    variable start_time   : time    := 0 ns;
    variable baud_time    : time    := 0 ns;

  begin

    -- Reset
    rst_n <= '0';
    wait for 100 ns;
    rst_n <= '1';


    wait for clk_period * 10;


    -- Test BAUD_9600
    baud_sel <= BAUD_9600;
    wait for clk_period;
    wait until baud_tick = '1';
    start_time := now;
    wait until baud_tick = '1';
    baud_time   := now - start_time;
    assert (baud_time <= baud_9600_upper_tol) and 
          (baud_time >= baud_9600_lower_tol)
      report "BAUD_9600: Simulation time now = " & time'image(now - start_time) & 
            ", Expected upper = " & time'image(baud_9600_upper_tol) & 
            ", Expected lower = " & time'image(baud_9600_lower_tol)
      severity error;


    -- Test BAUD_19200
    baud_sel <= BAUD_19200;
    wait for clk_period;
    wait until baud_tick = '1';
    start_time := now;
    wait until baud_tick = '1';
    baud_time   := now - start_time;
    assert (baud_time <= baud_19200_upper_tol) and 
          (baud_time >= baud_19200_lower_tol)
      report "BAUD_19200: Simulation time now = " & time'image(now - start_time) & 
            ", Expected upper = " & time'image(baud_19200_upper_tol) & 
            ", Expected lower = " & time'image(baud_19200_lower_tol)
      severity error;


    -- Test BAUD_38400
    baud_sel <= BAUD_38400;
    wait for clk_period;
    wait until baud_tick = '1';
    start_time := now;
    wait until baud_tick = '1';
    baud_time   := now - start_time;
    assert (baud_time <= baud_38400_upper_tol) and 
          (baud_time >= baud_38400_lower_tol)
      report "BAUD_38400: Simulation time now = " & time'image(now - start_time) & 
            ", Expected upper = " & time'image(baud_38400_upper_tol) & 
            ", Expected lower = " & time'image(baud_38400_lower_tol)
      severity error;


    -- Disable clock enable
    clk_en <= '0';
    wait for baud_38400_period * 2;
    assert baud_tick = '0'
      report "Clock enable failure, baud_tick should be low" severity error;
    clk_en <= '1';


    -- Test BAUD_57600
    baud_sel <= BAUD_57600;
    wait for clk_period;
    wait until baud_tick = '1';
    start_time := now;
    wait until baud_tick = '1';
    baud_time   := now - start_time;
    assert (baud_time <= baud_57600_upper_tol) and 
          (baud_time >= baud_57600_lower_tol)
      report "BAUD_57600: Simulation time now = " & time'image(now - start_time) & 
            ", Expected upper = " & time'image(baud_57600_upper_tol) & 
            ", Expected lower = " & time'image(baud_57600_lower_tol)
      severity error;


    -- Test BAUD_115200
    baud_sel <= BAUD_115200;
    wait for clk_period;
    wait until baud_tick = '1';
    start_time := now;
    wait until baud_tick = '1';
    baud_time   := now - start_time;
    assert (baud_time <= baud_115200_upper_tol) and 
          (baud_time >= baud_115200_lower_tol)
      report "BAUD_115200: Simulation time now = " & time'image(now - start_time) & 
            ", Expected upper = " & time'image(baud_115200_upper_tol) & 
            ", Expected lower = " & time'image(baud_115200_lower_tol)
      severity error;


    -- Test BAUD_230400
    baud_sel <= BAUD_230400;
    wait for clk_period;
    wait until baud_tick = '1';
    start_time := now;
    wait until baud_tick = '1';
    baud_time   := now - start_time;
    assert (baud_time <= baud_230400_upper_tol) and 
          (baud_time >= baud_230400_lower_tol)
      report "BAUD_230400: Simulation time now = " & time'image(now - start_time) & 
            ", Expected upper = " & time'image(baud_230400_upper_tol) & 
            ", Expected lower = " & time'image(baud_230400_lower_tol)
      severity error;


    -- Test BAUD_460800
    baud_sel <= BAUD_460800;
    wait for clk_period;
    wait until baud_tick = '1';
    start_time := now;
    wait until baud_tick = '1';
    baud_time   := now - start_time;
    assert (baud_time <= baud_460800_upper_tol) and 
          (baud_time >= baud_460800_lower_tol)
      report "BAUD_460800: Simulation time now = " & time'image(now - start_time) & 
            ", Expected upper = " & time'image(baud_460800_upper_tol) & 
            ", Expected lower = " & time'image(baud_460800_lower_tol)
      severity error;


    -- Test BAUD_921600
    baud_sel <= BAUD_921600;
    wait for clk_period;
    wait until baud_tick = '1';
    start_time := now;
    wait until baud_tick = '1';
    baud_time   := now - start_time;
    assert (baud_time <= baud_921600_upper_tol) and 
          (baud_time >= baud_921600_lower_tol)
      report "BAUD_921600: Simulation time now = " & time'image(now - start_time) & 
            ", Expected upper = " & time'image(baud_921600_upper_tol) & 
            ", Expected lower = " & time'image(baud_921600_lower_tol)
      severity error;

    wait;
  end process;

end testbench;
