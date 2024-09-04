------------------------------------------------------------------------------------------------------
-- Module Name    : baud_gen
--
--
-- Description    : This module generates a baud tick signal based on the selected
--                  baud rate. The tick signal is used to time the transmission
--                  and reception of UART data bits. Each tick is asserted at the 
--                  start of a new bit period.
--
--                  Baud Rate (bps)         Baud Period (ns)	      Clock Cycles per Baud
--                  ------------------------------------------------------------------
--                  9600	                  104,167	                10,417
--                  19200	                  52,083	                5,208
--                  38400	                  26,042	                2,604
--                  57600	                  17,361	                1,736
--                  115200	                8,681	                  868
--                  230400	                4,340	                  434
--                  460800	                2,170	                  217
--                  921600	                1,085	                  109
--
--
-- Generics       : G_CLK_FREQ    - System clock frequency
--                  G_OS_FACTOR   - Oversampling factor
-- 
--
-- Inputs         : i_clk         - System clock input.
--                  i_rst_n       - Active-low reset signal.
--                  i_clk_en      - Input to enable/disable baud pulse (out o_baud_tick)
--                  i_baud_sel    - Input for selecting the baud rate (can be configured via switches).
--
--
-- Outputs        : o_baud_tick   - A single-cycle pulse that occurs at the desired baud rate.
--                  o_sample_tick - A single-cycle pulse that occurs at the desired sample rate.
--
--
-- Author         : Don Hartman
-- Date           : 09/02/2024
--
--
-- Revision       : v1.0   - 09/02/2024  - Initial version
--                  v1.1   - 09/03/2024  - Added an oversampling pulse output
------------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity baud_gen is
  generic (
    G_CLK_FREQ  : integer := 100_000_000;
    G_OS_FACTOR : integer := 16
  );
  port (
    i_clk         : in  std_logic;
    i_rst_n       : in  std_logic;
    i_clk_en      : in  std_logic;
    i_baud_sel    : in  std_logic_vector(2 downto 0); -- Example: 3 bits for baud rate selection
    o_baud_tick   : out std_logic;
    o_sample_tick : out std_logic
  );
end entity baud_gen;


architecture Behavioral of baud_gen is

  constant C_BAUD_PERIOD_9600    : integer := G_CLK_FREQ /    9_600;
  constant C_BAUD_PERIOD_19200   : integer := G_CLK_FREQ /   19_200;
  constant C_BAUD_PERIOD_38400   : integer := G_CLK_FREQ /   38_400;
  constant C_BAUD_PERIOD_57600   : integer := G_CLK_FREQ /   57_600;
  constant C_BAUD_PERIOD_115200  : integer := G_CLK_FREQ /  115_200;
  constant C_BAUD_PERIOD_230400  : integer := G_CLK_FREQ /  230_400;
  constant C_BAUD_PERIOD_460800  : integer := G_CLK_FREQ /  460_800;
  constant C_BAUD_PERIOD_921600  : integer := G_CLK_FREQ /  921_600;

  constant C_SAMP_PERIOD_9600    : integer := G_CLK_FREQ / (  9_600 * G_OS_FACTOR);
  constant C_SAMP_PERIOD_19200   : integer := G_CLK_FREQ / ( 19_200 * G_OS_FACTOR);
  constant C_SAMP_PERIOD_38400   : integer := G_CLK_FREQ / ( 38_400 * G_OS_FACTOR);
  constant C_SAMP_PERIOD_57600   : integer := G_CLK_FREQ / ( 57_600 * G_OS_FACTOR);
  constant C_SAMP_PERIOD_115200  : integer := G_CLK_FREQ / (115_200 * G_OS_FACTOR);
  constant C_SAMP_PERIOD_230400  : integer := G_CLK_FREQ / (230_400 * G_OS_FACTOR);
  constant C_SAMP_PERIOD_460800  : integer := G_CLK_FREQ / (460_800 * G_OS_FACTOR);
  constant C_SAMP_PERIOD_921600  : integer := G_CLK_FREQ / (921_600 * G_OS_FACTOR);

  signal baud_counter_i : integer     := 0;
  signal samp_counter_i : integer     := 0;
  signal baud_tick_i    : std_logic   := '0';
  signal samp_tick_i    : std_logic   := '0';
  signal baud_period_i  : integer     := C_BAUD_PERIOD_9600;
  signal samp_period_i  : integer     := C_SAMP_PERIOD_9600;

begin

  o_baud_tick   <= baud_tick_i and i_clk_en;
  o_sample_tick <= samp_tick_i and i_clk_en;


  baud_tick_proc : process (i_clk)
  begin
    if rising_edge(i_clk) then
      if i_rst_n = '0' then
        baud_counter_i  <= 0;
        baud_tick_i     <= '0';
      else
        if baud_counter_i >= baud_period_i - 1 then
          baud_tick_i     <= '1';
          baud_counter_i  <= 0;
        else
          baud_tick_i     <= '0';
          baud_counter_i  <= baud_counter_i + 1;
        end if;
      end if;
    end if;
  end process;


  samp_tick_proc : process (i_clk)
  begin
    if rising_edge(i_clk) then
      if i_rst_n = '0' then
        samp_counter_i  <= 0;
        samp_tick_i     <= '0';
      else
        if samp_counter_i >= samp_period_i - 1 then
          samp_tick_i     <= '1';
          samp_counter_i  <= 0;
        else
          samp_tick_i     <= '0';
          samp_counter_i  <= samp_counter_i + 1;
        end if;
      end if;
    end if;
  end process;


  baud_sel_proc : process (i_clk)
  begin
    if i_rst_n = '0' then
      baud_period_i <= C_BAUD_PERIOD_9600;
    elsif rising_edge(i_clk) then
      case i_baud_sel is
        when "000"  => baud_period_i <= C_BAUD_PERIOD_9600; 
        when "001"  => baud_period_i <= C_BAUD_PERIOD_19200;
        when "010"  => baud_period_i <= C_BAUD_PERIOD_38400;
        when "011"  => baud_period_i <= C_BAUD_PERIOD_57600;
        when "100"  => baud_period_i <= C_BAUD_PERIOD_115200;
        when "101"  => baud_period_i <= C_BAUD_PERIOD_230400;
        when "110"  => baud_period_i <= C_BAUD_PERIOD_460800;
        when "111"  => baud_period_i <= C_BAUD_PERIOD_921600;
        when others => baud_period_i <= C_BAUD_PERIOD_9600;
      end case;
    end if;
  end process;


  samp_sel_proc : process (i_clk)
  begin
    if i_rst_n = '0' then
      samp_period_i <= C_SAMP_PERIOD_9600;
    elsif rising_edge(i_clk) then
      case i_baud_sel is
        when "000"  => samp_period_i <= C_SAMP_PERIOD_9600; 
        when "001"  => samp_period_i <= C_SAMP_PERIOD_19200;
        when "010"  => samp_period_i <= C_SAMP_PERIOD_38400;
        when "011"  => samp_period_i <= C_SAMP_PERIOD_57600;
        when "100"  => samp_period_i <= C_SAMP_PERIOD_115200;
        when "101"  => samp_period_i <= C_SAMP_PERIOD_230400;
        when "110"  => samp_period_i <= C_SAMP_PERIOD_460800;
        when "111"  => samp_period_i <= C_SAMP_PERIOD_921600;
        when others => samp_period_i <= C_SAMP_PERIOD_9600;
      end case;
    end if;
  end process;

end architecture Behavioral;
