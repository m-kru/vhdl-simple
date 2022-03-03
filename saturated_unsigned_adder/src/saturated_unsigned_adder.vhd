-- SPDX-License-Identifier: MIT
-- https://github.com/m-kru/vhdl-simple
-- Copyright (c) 2019 Michał Kruszewski

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

-- Saturated unsigned adder with parameterizable widths and limits.
--
-- Simple unsigned adder for saturated math (without overflowing). For example,
-- in case of 8-bits unsigned numbers the result of 250 + 7 = 255, not 1.
-- It has parameterizable width of inputs and output. In case when
-- MAX_VALUE = 0 and MIN_VALUE = 0, the maximum and minimum limits are
-- established based on the result width.
entity Saturated_Unsigned_Adder is
  generic (
    A_WIDTH          : positive;
    B_WIDTH          : positive;
    RESULT_WIDTH     : positive;
    MAX_VALUE        : natural := 0;
    MIN_VALUE        : natural := 0;
    REGISTER_OUTPUTS : boolean := true
  );
  port (
    clk_i       : in  std_logic := '-';
    a_i         : in  unsigned(A_WIDTH - 1 downto 0);
    b_i         : in  unsigned(B_WIDTH - 1 downto 0);
    result_o    : out unsigned(RESULT_WIDTH - 1 downto 0);
    overflow_o  : out std_logic;
    underflow_o : out std_logic
  );

begin
  assert REGISTER_OUTPUTS = false or clk_i /= '-'
    report "clk_i port not mapped to any signal"
    severity failure;

  assert (MAX_VALUE > MIN_VALUE) or (MAX_VALUE = 0 and MIN_VALUE = 0)
    report "MAX_VALUE (" & integer'image(MAX_VALUE) & ") must be greater than MIN_VALUE (" & integer'image(MIN_VALUE) & ")"
    severity failure;

  assert (MAX_VALUE < 2 ** RESULT_WIDTH) or (MAX_VALUE = 0 and MIN_VALUE = 0)
    report "MAX_VALUE (" & integer'image(MAX_VALUE) & ") is grater than the maximum value for given RESULT_WIDTH (" & integer'image(RESULT_WIDTH) & ")"
    severity failure;
end entity;


architecture rtl of Saturated_Unsigned_Adder is

  function set_max_constant (
    result_width : positive;
    max_value : natural) return unsigned is
  begin

    if max_value = 0 then
      return to_unsigned((2 ** RESULT_WIDTH) - 1, RESULT_WIDTH);
    else
      return to_unsigned(max_value, RESULT_WIDTH);
    end if;

  end set_max_constant;

  constant C_MAX_VALUE : unsigned(RESULT_WIDTH - 1 downto 0) := set_max_constant(RESULT_WIDTH, MAX_VALUE);
  constant C_MIN_VALUE : unsigned(RESULT_WIDTH - 1 downto 0) := to_unsigned(MIN_VALUE, RESULT_WIDTH);

  signal s_full_result : unsigned(MAXIMUM(A_WIDTH, B_WIDTH) downto 0);

  signal s_result      : unsigned(RESULT_WIDTH - 1 downto 0);
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

  output_registers : if REGISTER_OUTPUTS generate

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

  end generate output_registers;

end architecture;
