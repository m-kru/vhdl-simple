--------------------------------------------------------------------------------
-- vhdl_simple library
-- https://github.com/m-kru/vhdl_simple
--------------------------------------------------------------------------------
--
-- Entity: Saturated signed adder with parameterizable widths and limits.
--
-- Description:
--  Simple signed adder for saturated math (without overflowing). For example,
--  in case of 8-bits signed numbers the result of 127 + 1 = 127, not -128.
--  It has parameterizable width of inputs and output. In case when
--  G_MAX_VALUE = 0 and G_MIN_VALUE = 0, the maximum and minimum limits are
--  established based on the result width.
--
--------------------------------------------------------------------------------
-- Copyright (c) 2019 Michal Kruszewski
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
  use ieee.numeric_std.all;

entity saturated_signed_adder is
  generic (
    G_A_WIDTH          : positive := 8;
    G_B_WIDTH          : positive := 8;
    G_RESULT_WIDTH     : positive := 8;
    G_MAX_VALUE        : integer  := 0;
    G_MIN_VALUE        : integer  := 0;
    G_REGISTER_OUTPUTS : boolean  := true
  );
  port (
    clk_i       : in    std_logic := '0';
    a_i         : in    signed(G_A_WIDTH - 1 downto 0);
    b_i         : in    signed(G_B_WIDTH - 1 downto 0);
    result_o    : out   signed(G_RESULT_WIDTH - 1 downto 0);
    overflow_o  : out   std_logic;
    underflow_o : out   std_logic
  );

begin 
  assert (G_MAX_VALUE > G_MIN_VALUE) or (G_MAX_VALUE = 0 and G_MIN_VALUE = 0)
    report "G_MAX_VALUE (" & integer'image(G_MAX_VALUE) & ") must be greater than G_MIN_VALUE (" & integer'image(G_MIN_VALUE) & ")"
    severity failure;

  assert (G_MAX_VALUE < 2 ** (G_RESULT_WIDTH - 1)) or (G_MAX_VALUE = 0 and G_MIN_VALUE = 0)
    report "G_MAX_VALUE (" & integer'image(G_MAX_VALUE) & ") is grater than the maximum value for given G_RESULT_WIDTH (" & integer'image(G_RESULT_WIDTH) & ")"
    severity failure;

  assert (G_MIN_VALUE >= (- 1) * (2 ** (G_RESULT_WIDTH - 1))) or (G_MAX_VALUE = 0 and G_MIN_VALUE = 0)
    report "G_MIN_VALUE (" & integer'image(G_MIN_VALUE) & ") is lesser than the minimum value for given G_RESULT_WIDTH (" & integer'image(G_RESULT_WIDTH) & ")"
    severity failure;
end entity saturated_signed_adder;

architecture rtl of saturated_signed_adder is

  function set_max_constant (
    result_width : positive;
    max_value : integer;
    min_value : integer) return signed is
  begin

    if max_value = 0 and min_value = 0 then
      return to_signed(2 ** (G_RESULT_WIDTH - 1) - 1, G_RESULT_WIDTH);
    else
      return to_signed(max_value, G_RESULT_WIDTH);
    end if;

  end set_max_constant;

  function set_min_constant (
    result_width : positive;
    max_value : integer;
    min_value : integer) return signed is
  begin

    if max_value = 0 and min_value = 0 then
      return to_signed((- 1) * 2 ** (G_RESULT_WIDTH - 1), G_RESULT_WIDTH);
    else
      return to_signed(min_value, G_RESULT_WIDTH);
    end if;

  end set_min_constant;

  constant C_MAX_VALUE : signed(G_RESULT_WIDTH - 1 downto 0) := set_max_constant(G_RESULT_WIDTH, G_MAX_VALUE, G_MIN_VALUE);
  constant C_MIN_VALUE : signed(G_RESULT_WIDTH - 1 downto 0) := set_min_constant(G_RESULT_WIDTH, G_MAX_VALUE, G_MIN_VALUE);

  signal s_full_result : signed(MAXIMUM(G_A_WIDTH, G_B_WIDTH) downto 0);

  signal s_result      : signed(G_RESULT_WIDTH - 1 downto 0);
  signal s_overflow    : std_logic;
  signal s_underflow   : std_logic;

begin

  s_full_result <= resize(a_i, s_full_result'length) + resize(b_i, s_full_result'length);

  sum : process (s_full_result) is
  begin

    if s_full_result > C_MAX_VALUE then
      s_result    <= C_MAX_VALUE;
      s_overflow  <= '1';
      s_underflow <= '0';
    elsif s_full_result < C_MIN_VALUE then
      s_result    <= C_MIN_VALUE;
      s_overflow  <= '0';
      s_underflow <= '1';
    else
      s_result    <= resize(s_full_result, s_result'length);
      s_overflow  <= '0';
      s_underflow <= '0';
    end if;

  end process sum;

  register_outputs : if G_REGISTER_OUTPUTS generate

    sync_outputs : process (clk_i) is
    begin

      if rising_edge(clk_i) then
        result_o    <= s_result;
        overflow_o  <= s_overflow;
        underflow_o <= s_underflow;
      end if;

    end process sync_outputs;

  else generate

    result_o    <= s_result;
    overflow_o  <= s_overflow;
    underflow_o <= s_underflow;

  end generate register_outputs;

end architecture rtl;
