----------------------------------------------------------------------------------
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
-- Inputs         : clk         - System clock input.
--                  rst_n       - Active-low reset signal.
--                  clk_en      - Input to enable/disable baud pulse (out baud_tick)
--                  baud_select - Input for selecting the baud rate (can be configured via switches).
--
-- Outputs        : baud_tick   - A single-cycle pulse that occurs at the desired baud rate.
--
--
-- Author         : Don Hartman
-- Date           : 09/02/2024
--
--
-- Revision       : v1.0   - 09/02/2024  - Initial version
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;


entity baud_gen is
  generic (
    CLK_FREQ : integer := 100_000_000
  );
  port (
    clk         : in  std_logic;
    rst_n       : in  std_logic;
    clk_en      : in  std_logic;
    baud_sel    : in  std_logic_vector(2 downto 0); -- Example: 3 bits for baud rate selection
    baud_tick   : out std_logic
  );
end entity baud_gen;


architecture Behavioral of baud_gen is


  constant BAUD_PERIOD_9600    : integer := CLK_FREQ / 9600;
  constant BAUD_PERIOD_19200   : integer := CLK_FREQ / 19200;
  constant BAUD_PERIOD_38400   : integer := CLK_FREQ / 38400;
  constant BAUD_PERIOD_57600   : integer := CLK_FREQ / 57600;
  constant BAUD_PERIOD_115200  : integer := CLK_FREQ / 115200;
  constant BAUD_PERIOD_230400  : integer := CLK_FREQ / 230400;
  constant BAUD_PERIOD_460800  : integer := CLK_FREQ / 460800;
  constant BAUD_PERIOD_921600  : integer := CLK_FREQ / 921600;

  signal clk_cnt_i      : integer     := 0;
  signal baud_tick_i    : std_logic   := '0';
  signal baud_period_i  : integer     := BAUD_PERIOD_9600;


begin


  baud_tick <= baud_tick_i and clk_en;


  tick_gen_proc : process (clk)
  begin
    if rst_n = '0' then
      clk_cnt_i   <= 0;
      baud_tick_i <= '0';
    elsif rising_edge(clk) then
      if clk_cnt_i >= baud_period_i - 1 then
        baud_tick_i <= '1';
        clk_cnt_i   <= 0;
      else
        baud_tick_i <= '0';
        clk_cnt_i   <= clk_cnt_i + 1;
      end if;
    end if;
  end process;


  baud_sel_proc : process (clk)
  begin
    if rst_n = '0' then
      baud_period_i <= BAUD_PERIOD_9600;
    elsif rising_edge(clk) then
      case baud_sel is
        when "000"  => baud_period_i <= BAUD_PERIOD_9600;
        when "001"  => baud_period_i <= BAUD_PERIOD_19200;
        when "010"  => baud_period_i <= BAUD_PERIOD_38400;
        when "011"  => baud_period_i <= BAUD_PERIOD_57600;
        when "100"  => baud_period_i <= BAUD_PERIOD_115200;
        when "101"  => baud_period_i <= BAUD_PERIOD_230400;
        when "110"  => baud_period_i <= BAUD_PERIOD_460800;
        when "111"  => baud_period_i <= BAUD_PERIOD_921600;
        when others => baud_period_i <= BAUD_PERIOD_9600;
      end case;
    end if;
  end process;


end architecture Behavioral;
