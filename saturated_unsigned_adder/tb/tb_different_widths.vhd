library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library simple;

entity tb_saturated_unsigned_adder_different_widths is
end entity;

architecture tb of tb_saturated_unsigned_adder_different_widths is

  constant C_CLK_PERIOD : time := 10 ns;
  signal s_clk : std_logic := '0';

  signal s_a : unsigned(8 downto 0);
  signal s_b : unsigned(4 downto 0);

  signal s_result : unsigned(6 downto 0);
  signal s_overflow : std_logic;
  signal s_underflow : std_logic;

begin
  
  s_clk <= not s_clk after C_CLK_PERIOD/2;

  saturated_unsigned_adder_0 : entity simple.saturated_unsigned_adder
  generic map (
    A_WIDTH => 9,
    B_WIDTH => 5,
    RESULT_WIDTH => 7,
    MAX_VALUE => 111,
    MIN_VALUE => 7
  )
  port map (
    clk_i  => s_clk,
    a_i    => s_a,
    b_i    => s_b,
    result_o     => s_result,
    overflow_o   => s_overflow,
    underflow_o  => s_underflow
  );

  stimuli_generator: process
  begin
    for i in 0 to 511 loop
      for j in 0 to 31 loop
        s_a <= to_unsigned(i, s_a'length);
        s_b <= to_unsigned(j, s_b'length);

        wait until falling_edge(s_clk);
      end loop;
    end loop;

    report "End of testbench. All tests passed." severity note;
    std.env.finish;
  end process;

  response_checker: process
    variable a, b, res : integer;
  begin
    wait until rising_edge(s_clk);
    wait for C_CLK_PERIOD/4;

    a := to_integer(s_a);
    b := to_integer(s_b);
    res := to_integer(s_result);

    if a + b > 111 then
      assert res = 111 report "Result is too big" severity failure;
      assert s_overflow = '1' report "overflow should be set to 1" severity failure;
      assert s_underflow = '0' report "underflow should be set to 0" severity failure;
    elsif a + b < 7 then
      assert res = 7 report "Result is too small" severity failure;
      assert s_overflow = '0' report "overflow should be set to 0" severity failure;
      assert s_underflow = '1' report "underflow should be set to 1" severity failure;
    else
      assert (a + b) = res report "Result is wrong" severity failure;
      assert s_overflow = '0' report "overflow should be set to 0" severity failure;
      assert s_underflow = '0' report "underflow should be set to 0" severity failure;
    end if;

  end process;

end architecture tb;
