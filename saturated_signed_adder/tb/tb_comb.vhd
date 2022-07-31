library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library simple;

entity tb_saturated_signed_adder_comb is
end entity;

architecture tb of tb_saturated_signed_adder_comb is

   constant C_WIDTH : positive := 8;

  constant C_COMB_DELAY : time := 10 ns;

  constant C_MAX_VALUE : integer := 20;
  constant C_MIN_VALUE : integer := -18;

  signal s_a : signed(7 downto 0);
  signal s_b : signed(7 downto 0);

  signal s_result : signed(7 downto 0);
  signal s_overflow : std_logic;
  signal s_underflow : std_logic;

begin
  
  DUT : entity simple.saturated_signed_adder
  generic map (
    A_WIDTH => C_WIDTH,
    B_WIDTH => C_WIDTH,
    RESULT_WIDTH => C_WIDTH,
    MAX_VALUE => C_MAX_VALUE,
    MIN_VALUE => C_MIN_VALUE,
    REGISTER_OUTPUTS => false
  )
  port map (
    a_i    => s_a,
    b_i    => s_b,
    result_o     => s_result,
    overflow_o   => s_overflow,
    underflow_o  => s_underflow
  );

  stimuli_generator: process
    variable a, b, res : integer;
  begin
    for i in -128 to 127 loop
      for j in -128 to 127 loop
        s_a <= to_signed(i, s_a'length);
        s_b <= to_signed(j, s_b'length);

        wait for C_COMB_DELAY;

        a := to_integer(s_a);
        b := to_integer(s_b);
        res := to_integer(s_result);
    
        if a + b > C_MAX_VALUE then
          assert res = C_MAX_VALUE report "Result is too big" severity failure;
          assert s_overflow = '1' report "overflow should be set to 1" severity failure;
          assert s_underflow = '0' report "underflow should be set to 0" severity failure;
        elsif a + b < C_MIN_VALUE then
          assert res = C_MIN_VALUE report "Result is too small" severity failure;
          assert s_overflow = '0' report "overflow should be set to 0" severity failure;
          assert s_underflow = '1' report "underflow should be set to 1" severity failure;
        else
          assert (a + b) = res report "Result is wrong" severity failure;
          assert s_overflow = '0' report "overflow should be set to 0" severity failure;
          assert s_underflow = '0' report "underflow should be set to 0" severity failure;
        end if;

      end loop;
    end loop;

    report "End of testbench. All tests passed." severity note;
    std.env.finish;
  end process;

end architecture tb;
