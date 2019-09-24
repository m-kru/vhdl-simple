--------------------------------------------------------------------------------
-- vhdl_simple library
-- https://github.com/m-kru/vhdl_simple
--------------------------------------------------------------------------------
--
-- Entity: Reset synchronizer
--
-- Description:
--   Standard reset synchroniser. It follows typical and recommended
--   "asynchronous assertion -> synchronous deassertion" practice.
--   Can be used to drive both synchronous and asynchronous FFs.
--   Will assert reset even without active clock signal.
--   Needs two clock cycles to deassert reset.
--   This circuit guarantess zero metastability problems.
--
--------------------------------------------------------------------------------
-- Copyright (c) 2018 Adrian Byszuk <adrian.byszuk@gmail.com>
--------------------------------------------------------------------------------
-- MIT License
--------------------------------------------------------------------------------
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity reset_synchronizer is
  generic (
    G_INPUT_POSITIVE  : boolean := true; -- TRUE for positive polarity
    G_OUTPUT_POSITIVE : boolean := true
  );
  port (
    clk_i : in std_logic;
    rst_i : in std_logic;
    rst_o : out std_logic
  );

end entity reset_synchronizer;

architecture rtl of reset_synchronizer is

  attribute dont_touch : string;

  signal rst_ff1, rst_ff2, rst_in_p : std_logic := '0';
  attribute dont_touch of rst_ff1 : signal is "true";
  attribute dont_touch of rst_ff2 : signal is "true";

begin  -- architecture beh

  -- vsg_off concurrent_007
  rst_in_p <= rst_i when G_INPUT_POSITIVE else not(rst_i);
  rst_o <= rst_ff2 when G_OUTPUT_POSITIVE else not(rst_ff2);
  -- vsg_on

  sync: process(clk_i, rst_in_p) is
  begin
    if rst_in_p = '1' then -- asynchronous reset (active high)
      rst_ff1 <= '1';
      rst_ff2 <= '1';
    elsif rising_edge(clk_i) then
      -- metastability can happen only at rst_ff
      -- rst_out_p will always de-assert clean
      rst_ff1 <= '0';
      rst_ff2 <= rst_ff1;
    end if;
  end process sync;

end architecture rtl;
